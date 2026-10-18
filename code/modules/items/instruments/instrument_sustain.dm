#define INSTRUMENT_NOTE_RELEASE_TIME (0.4 SECONDS)
#define INSTRUMENT_NOTE_MAX_POLYPHONY 32
#define INSTRUMENT_NOTE_RELEASE_STEPS 16

/// Channel ownership is tracked per listener because the ordinary sound pool reuses channels.
var/global/list/instrument_note_channels = list()

/proc/clear_instrument_note_listener(client/listener, sound_channel)
	var/list/notes = global.instrument_note_channels?["[sound_channel]"]
	if (!listener || !notes)
		return
	for (var/datum/instrument_note/note as anything in notes)
		if (!(listener in note.listeners))
			continue
		note.listeners -= listener
		note.listener_packets -= listener
		note.last_sent_volumes -= listener
		if (!length(note.listeners))
			release_instrument_note_channel(note)

/proc/release_instrument_note_channel(datum/instrument_note/note)
	if (!note?.sound_channel || !global.instrument_note_channels)
		return
	var/channel_key = "[note.sound_channel]"
	var/list/notes = global.instrument_note_channels[channel_key]
	if (!notes)
		return
	notes -= note
	if (!length(notes))
		global.instrument_note_channels -= channel_key

/datum/instrument_note
	var/datum/weakref/instrument_ref
	var/datum/weakref/user_ref
	var/list/listeners
	var/list/listener_packets
	var/sound_channel = null
	var/volume = 0
	var/duration = 0
	var/pitch = 1
	var/start_time = 0
	var/active = FALSE
	var/releasing = FALSE
	var/velocity = 80
	var/requested_volume = 0
	var/sound_path
	var/release_time = INSTRUMENT_NOTE_RELEASE_TIME
	var/is_release_voice = FALSE
	var/datum/instrument_note/release_voice
	var/release_level = 1
	var/list/last_sent_volumes

/datum/instrument_note/New(atom/source, soundin, requested_volume, mob/user, \
	velocity = 80, resonant = FALSE, list/override_sample = null)
	. = ..()
	src.velocity = velocity
	src.requested_volume = requested_volume
	src.sound_path = soundin
	src.is_release_voice = !isnull(override_sample)
	var/list/sample_data = override_sample || get_instrument_piano_sample(soundin, velocity, resonant) \
		|| global.instrument_sustain_samples?[soundin]
	if (!islist(sample_data) || !sample_data["file"] || !isnum(sample_data["duration"]) || sample_data["duration"] <= 0)
		return
	src.last_sent_volumes = list()

	src.duration = sample_data["duration"]
	src.pitch = isnum(sample_data["pitch"]) && sample_data["pitch"] > 0 ? sample_data["pitch"] : 1
	var/gain = isnum(sample_data["gain"]) ? max(sample_data["gain"], 0) : 1
	src.volume = requested_volume * gain
	if (isnum(sample_data["release"]))
		src.release_time = sample_data["release"] * (1 SECOND)
	src.listeners = list()
	src.listener_packets = list()
	src.instrument_ref = get_weakref(source)
	if (user)
		src.user_ref = get_weakref(user)
	var/sound/note_sound = sound(sample_data["file"], wait = FALSE)
	src.start_time = world.time
	src.active = TRUE
	playsound(source, note_sound, src.volume, FALSE, pitch = src.pitch, channel = VOLUME_CHANNEL_INSTRUMENTS, \
		sound_listeners = src.listeners, sound_listener_packets = src.listener_packets, \
		volume_scale = isnum(sample_data["volume_scale"]) ? sample_data["volume_scale"] : 1, limiter_id = ref(src))
	// playsound assigns the channel to the supplied sound datum.
	src.sound_channel = note_sound.channel
	if (!src.sound_channel)
		return
	var/channel_key = "[src.sound_channel]"
	global.instrument_note_channels[channel_key] ||= list()
	global.instrument_note_channels[channel_key] += src
	for (var/client/listener as anything in src.listener_packets)
		var/sound/packet = src.listener_packets[listener]
		src.last_sent_volumes[listener] = packet.volume

	var/datum/weakref/note_ref = get_weakref(src)
	SPAWN(src.duration / src.pitch * (1 SECOND))
		var/datum/instrument_note/natural_note = note_ref?.deref()
		if (natural_note?.active)
			natural_note.finish_recording()

/datum/instrument_note/proc/channel_is_owned()
	return src.sound_channel && (src in global.instrument_note_channels?["[src.sound_channel]"])

/// Keep the note identity after playback ends so key-up can trigger its release recording.
/datum/instrument_note/proc/finish_recording()
	src.stop_clients()
	release_instrument_note_channel(src)
	src.sound_channel = null
	src.listeners = null
	src.listener_packets = null
	if (src.is_release_voice)
		qdel(src)

/datum/instrument_note/proc/begin_release()
	if (!src.active || src.releasing)
		return
	src.releasing = TRUE
	var/atom/source = src.instrument_ref?.deref()
	var/list/release_sample = get_instrument_piano_sample(src.sound_path, src.velocity, FALSE, TRUE)
	var/completion_time = src.release_time
	if (source && release_sample)
		src.release_voice = new(source, src.sound_path, src.requested_volume, null, \
			src.velocity, FALSE, release_sample)
		if (src.release_voice.active)
			completion_time = max(completion_time, src.release_voice.duration / src.release_voice.pitch * (1 SECOND))
		else
			qdel(src.release_voice)
			src.release_voice = null
	var/datum/weakref/note_ref = get_weakref(src)
	var/release_duration = src.release_time
	var/release_started = world.time
	SPAWN(0)
		for (var/step in 1 to INSTRUMENT_NOTE_RELEASE_STEPS)
			// Absolute deadlines keep tick rounding from accumulating across fade steps.
			sleep(max(0, release_started + release_duration * step / INSTRUMENT_NOTE_RELEASE_STEPS - world.time))
			var/datum/instrument_note/releasing_note = note_ref?.deref()
			if (!releasing_note?.active)
				return
			var/progress = releasing_note.release_progress(release_started)
			releasing_note.update_release_volume(progress)
			if (progress >= 1)
				break
		// Sub-tick sleeps can round down, leaving the final step ahead of its deadline.
		UNTIL(world.time >= release_started + release_duration || !note_ref?.deref(), 0)
		var/datum/instrument_note/faded_note = note_ref?.deref()
		if (faded_note?.active)
			faded_note.update_release_volume(1)
			faded_note.finish_recording()
		// The release recording can outlast the main fade.
		var/remaining_time = release_started + completion_time - world.time
		if (remaining_time > 0)
			sleep(remaining_time)
		var/datum/instrument_note/finished_note = note_ref?.deref()
		if (finished_note?.active)
			qdel(finished_note)

/datum/instrument_note/proc/update_release_volume(progress)
	if (!src.active || !src.channel_is_owned())
		return
	src.release_level = src.release_gain(progress)
	for (var/client/C as anything in src.listeners)
		src.apply_release_volume(C)

/datum/instrument_note/proc/apply_release_volume(client/C)
	if (!src.active || !src.channel_is_owned() || !C)
		return
	var/stored_volume = src.listeners?[C]
	if (!isnum(stored_volume))
		return
	var/volume = stored_volume * src.release_level
	var/list/channel_state = C.sound_playing[src.sound_channel]
	if (channel_state)
		channel_state[1] = volume
		channel_state[2] = VOLUME_CHANNEL_INSTRUMENTS
	var/output_volume = volume * C.getVolume(VOLUME_CHANNEL_INSTRUMENTS) / 100
	if (src.last_sent_volumes?[C] == output_volume)
		return
	src.last_sent_volumes[C] = output_volume
	var/sound/update = src.release_packet(src.listener_packets?[C], \
		output_volume)
	if (update)
		C << update

/datum/instrument_note/proc/release_gain(progress)
	return (1 + cos(180 * clamp(progress, 0, 1))) / 2

/datum/instrument_note/proc/release_progress(release_started, current_time = world.time)
	return src.release_time > 0 ? clamp((current_time - release_started) / src.release_time, 0, 1) : 1

/datum/instrument_note/proc/release_packet(sound/initial_packet, volume)
	if (!initial_packet || !src.channel_is_owned() || initial_packet.channel != src.sound_channel)
		return null
	return sound_update_packet(initial_packet, volume)

/datum/instrument_note/proc/stop_clients()
	if (!src.channel_is_owned())
		return
	for (var/client/C as anything in src.listeners)
		if (!C)
			continue
		var/list/channel_state = C.sound_playing[src.sound_channel]
		if (channel_state)
			channel_state[1] = 0
			channel_state[2] = VOLUME_CHANNEL_INSTRUMENTS
		var/sound/stop_sound = sound(null, wait = FALSE, channel = src.sound_channel)
		C << stop_sound

/datum/instrument_note/disposing()
	if (src.release_voice)
		qdel(src.release_voice)
		src.release_voice = null
	if (src.active)
		src.stop_clients()
	src.active = FALSE
	release_instrument_note_channel(src)
	var/obj/item/instrument/instrument = src.instrument_ref?.deref()
	var/mob/user = src.user_ref?.deref()
	if (instrument)
		instrument.remove_sustained_note(src, user)
	src.listeners = null
	src.listener_packets = null
	src.last_sent_volumes = null
	src.instrument_ref = null
	src.user_ref = null
	. = ..()

/obj/item/instrument/proc/start_sustained_note(mob/user, voice, note, volume, \
	velocity = null, resonant = FALSE)
	if (!user || !istext(voice) || !length(voice) || !src.use_new_interface || note < 1 || note > length(src.sounds_instrument))
		return FALSE
	if ((!isnull(velocity) && (!isnum(velocity) || velocity != floor(velocity) || velocity < 1 || velocity > 127)) \
		|| !(resonant == TRUE || resonant == FALSE))
		return FALSE
	if (isnull(velocity))
		velocity = 80

	src.sustained_notes ||= list()
	var/list/user_notes = src.sustained_notes[user]
	if (!user_notes)
		user_notes = list()
		src.sustained_notes[user] = user_notes
	if (user_notes[voice])
		return FALSE
	if (src.get_sustained_note_count() >= INSTRUMENT_NOTE_MAX_POLYPHONY && !src.steal_releasing_note())
		return FALSE
	// Stealing the last note may remove this user's map from the instrument.
	src.sustained_notes[user] = user_notes

	var/datum/instrument_note/new_note = new(src, src.sounds_instrument[note], volume, user, \
		velocity, resonant)
	if (!new_note?.sound_channel)
		qdel(new_note)
		return FALSE
	user_notes[voice] = new_note
	return TRUE

/obj/item/instrument/proc/stop_sustained_note(mob/user, voice, immediate = FALSE)
	var/list/user_notes = src.sustained_notes?[user]
	var/datum/instrument_note/note = user_notes?[voice]
	if (!note)
		return FALSE
	if (immediate)
		qdel(note)
	else
		note.begin_release()
	return TRUE

/obj/item/instrument/proc/stop_sustained_notes(mob/user = null)
	if (user)
		var/list/user_notes = src.sustained_notes?[user]
		for (var/voice in user_notes)
			var/datum/instrument_note/note = user_notes[voice]
			qdel(note)
		return
	for (var/mob/held_user as anything in src.sustained_notes)
		var/list/user_notes = src.sustained_notes[held_user]
		for (var/voice in user_notes)
			var/datum/instrument_note/note = user_notes[voice]
			qdel(note)

/// Reclaim the oldest release tail to make room for a new note.
/obj/item/instrument/proc/steal_releasing_note()
	var/datum/instrument_note/oldest_note
	for (var/mob/held_user as anything in src.sustained_notes)
		var/list/user_notes = src.sustained_notes[held_user]
		for (var/voice in user_notes)
			var/datum/instrument_note/note = user_notes[voice]
			if (note.releasing && (!oldest_note || note.start_time < oldest_note.start_time))
				oldest_note = note
	if (!oldest_note)
		return FALSE
	qdel(oldest_note)
	return TRUE

/obj/item/instrument/proc/get_sustained_note_count()
	var/note_count = 0
	for (var/mob/held_user as anything in src.sustained_notes)
		note_count += length(src.sustained_notes[held_user])
	return note_count

/obj/item/instrument/proc/remove_sustained_note(datum/instrument_note/note, mob/user)
	var/list/user_notes = src.sustained_notes?[user]
	if (!user_notes)
		return
	for (var/voice in user_notes)
		if (user_notes[voice] == note)
			user_notes -= voice
	if (!length(user_notes))
		src.sustained_notes -= user

#undef INSTRUMENT_NOTE_RELEASE_TIME
#undef INSTRUMENT_NOTE_MAX_POLYPHONY
#undef INSTRUMENT_NOTE_RELEASE_STEPS
