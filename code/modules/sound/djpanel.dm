/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=DJ PANEL BY ZEWAKA-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

#define DJ_MAX_FREQUENCY 4

client/proc/open_dj_panel()
	set name = "DJ Panel"
	set desc = "Get your groove on!"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	SHOW_VERB_DESC
	if (!isadmin(src) && !src.non_admin_dj)
		boutput(src, "Only administrators or those with access may use this command.")
		return FALSE

	global.dj_panel.ui_interact(src.mob)

/**
 * # DJ Panel for Admins
 *
 *  Allows for easily accessible music/sound playing for admins/allowed players.
 */
/datum/dj_panel
	var/loaded_sound = null // holds current song file
	var/sound_volume = 50
	var/sound_frequency = 1
	var/list/datum/dj_library_sound/sound_library = list()
	var/datum/dj_music_track/active_music
	var/looping = FALSE

/datum/dj_panel/ui_state(mob/user)
	return tgui_always_state

/datum/dj_panel/ui_status(mob/user)
	return max(
		tgui_admin_state.can_use_topic(src, user),
		src.dj_access_check(user)
	)

/// Checks if the passed mob is an admin or has dj access
/datum/dj_panel/proc/dj_access_check(mob/user)
	if (isadmin(user) || user?.client?.non_admin_dj)
		return UI_INTERACTIVE
	else
		return UI_CLOSE

/datum/dj_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DJPanel")
		ui.open()

/datum/dj_panel/ui_data(mob/user)
	var/list/sounds = list()
	for (var/name in src.sound_library)
		var/datum/dj_library_sound/upload = src.sound_library[name]
		sounds += list(list(
			"name" = name,
			"sizeBytes" = upload.size_bytes,
			"preloadState" = upload.preloaded ? "requested" : "none",
		))
	var/list/now_playing
	if (src.active_music)
		var/datum/dj_music_track/track = src.active_music
		var/track_frequency = abs(track.frequency) || 1
		now_playing = list(
			"name" = "[track.file]",
			"channel" = track.channel,
			"paused" = track.paused,
			"elapsed" = track.get_elapsed(),
			"duration" = track.duration / track_frequency,
		)
	. = list(
		"loadedSound" = "[src.loaded_sound]",
		"volume" = src.sound_volume,
		"frequency" = src.sound_frequency,
		"announceMode" = user.client?.djmode,
		"sounds" = sounds,
		"isAdmin" = isadmin(user),
		"soundsEnabled" = config.allow_admin_sounds,
		"looping" = src.looping,
		"nowPlaying" = now_playing,
	)

/datum/dj_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	var/mob/user = ui.user
	var/client/actor = user?.client
	var/name = params["name"]
	var/datum/dj_library_sound/named_sound = istext(name) ? src.sound_library[name] : null

	// Stop and management controls remain available while sounds are disabled.
	switch (action)
		if ("stop-music")
			src.stop_music()
			. = TRUE
		if ("stop-all")
			src.stop_music(stop_playback = FALSE)
			for (var/client/C in clients)
				C.stop_the_music()
			. = TRUE
		if ("stop-radio")
			SPAWN(0)
				var/sound/stopsound = sound(null, wait = 0, channel = SOUNDCHANNEL_RADIO)
				for (var/client/C in clients)
					C << stopsound
					LAGCHECK(LAG_MED)
		if ("remove-sound")
			if (!named_sound)
				return FALSE
			if (src.loaded_sound == named_sound.file)
				src.loaded_sound = null
			src.sound_library.Remove(name)
			. = TRUE
		if ("toggle-announce")
			if (!actor)
				return TRUE
			actor.djmode = !actor.djmode
			boutput(user, SPAN_NOTICE("DJ mode now [(actor.djmode ? "On" : "Off")]."))

			logTheThing(LOG_ADMIN, user, "set their DJ mode to [(actor.djmode ? "On" : "Off")]")
			logTheThing(LOG_DIARY, user, "set their DJ mode to [(actor.djmode ? "On" : "Off")]", "admin")
			message_admins("[key_name(user)] set their DJ mode to [(actor.djmode ? "On" : "Off")]")
			. = TRUE
		if ("toggle-player-dj")
			if (isadmin(actor))
				var/client/target = input(user, "Choose a client:", "Choose a client:", null) as null|anything in clients
				if (!target) return FALSE
				src.toggledj(target, actor)
			else
				boutput(user, "You must be an admin to use this command.")

	if (.)
		return

	if (!config.allow_admin_sounds)
		return FALSE

	switch(action)

		if("set-file")
			var/foundsound = input(user, "Upload a file:", "File Uploader - Do not use for full songs, use ]remotemusic in discord instead!!!", null) as null|sound
			src.loaded_sound = foundsound
			if(foundsound)
				src.sound_library["[foundsound]"] = new /datum/dj_library_sound(foundsound)
			. = TRUE

		if("set-volume")
			var/new_volume = text2num_safe(params["volume"])
			if(new_volume != null)
				src.sound_volume = clamp(new_volume, 0, ADMIN_SOUND_MAX_VOLUME)
				src.update_music()
				. = TRUE

		if("reset-volume")
			src.sound_volume = initial(src.sound_volume)
			src.update_music()
			. = TRUE

		if("set-freq")
			var/new_freq = text2num_safe(params["frequency"])
			if(new_freq != null)
				src.sound_frequency = clamp(new_freq || 1, -DJ_MAX_FREQUENCY, DJ_MAX_FREQUENCY)
				src.update_music()
				. = TRUE

		if("reset-freq")
			src.sound_frequency = initial(src.sound_frequency)
			src.update_music()
			. = TRUE

		if("play-sound")
			actor?.play_sound_real(src.loaded_sound, src.sound_volume, src.sound_frequency)
			. = TRUE

		if("play-music")
			if(src.loaded_sound)
				src.start_music(src.sound_library["[src.loaded_sound]"], actor)
			. = TRUE

		if("play-ambience")
			logTheThing(LOG_ADMIN, user, "played ambient sound [src.loaded_sound]")
			logTheThing(LOG_DIARY, user, "played ambient sound [src.loaded_sound]", "admin")
			message_admins("[admin_key(actor)] played ambient sound [src.loaded_sound]")
			playsound(user, src.loaded_sound, src.sound_volume, vary = FALSE, pitch = src.sound_frequency)

		if("play-remote")
			actor?.play_youtube_audio()

		if("play-player")
			var/client/C = input(user, "Choose a client:", "Choose a client:", user) as null|anything in clients
			if (!C) return FALSE
			logTheThing(LOG_ADMIN, user, "played sound [src.loaded_sound] to [C]")
			logTheThing(LOG_DIARY, user, "played sound [src.loaded_sound] to [C]", "admin")
			message_admins("[admin_key(actor)] played sound [src.loaded_sound] to [C]")
			playsound(C.mob, src.loaded_sound, src.sound_volume, vary = FALSE, pitch = src.sound_frequency)

		if("preload-sound")
			. = src.request_preload(named_sound, actor)

		if("load-sound")
			if(!named_sound)
				return FALSE
			src.loaded_sound = named_sound.file
			. = TRUE

		if("toggle-pause")
			src.update_music(toggle_pause = TRUE)
			. = TRUE

		if("toggle-loop")
			src.looping = !src.looping
			src.update_music()
			. = TRUE

/**
 * Moves the global admin sound channel up or down one
 *
 * * backwards - Moves it backwards if true
 */
/datum/dj_panel/proc/move_admin_sound_channel(backwards = FALSE)
	if (backwards)
		if (admin_sound_channel > SOUNDCHANNEL_ADMIN_LOW)
			admin_sound_channel--
		else
			admin_sound_channel = SOUNDCHANNEL_ADMIN_HIGH
	else
		if (admin_sound_channel < SOUNDCHANNEL_ADMIN_HIGH)
			admin_sound_channel++
		else
			admin_sound_channel = SOUNDCHANNEL_ADMIN_LOW

/**
 * Toggles the DJ Mode for a given client
 *
 * * required C - Client to toggle the DJ Mode of
 * * required actor - The client actor toggled the DJ Mode
 */
/datum/dj_panel/proc/toggledj(client/C, client/actor)
	C.non_admin_dj = !C.non_admin_dj
	if (C.non_admin_dj)
		C.verbs += /client/proc/open_dj_panel
		C.verbs += /client/proc/cmd_dectalk
	else
		C.verbs -= /client/proc/cmd_dectalk
		C.verbs -= /client/proc/open_dj_panel

	logTheThing(LOG_ADMIN, actor, "has [C.non_admin_dj ? "given" : "removed"] the ability for [constructTarget(C,"admin")] to DJ and use dectalk.")
	logTheThing(LOG_DIARY, actor, "has [C.non_admin_dj ? "given" : "removed"] the ability for [constructTarget(C,"diary")] to DJ and use dectalk.", "admin")
	message_admins("[key_name(actor)] has [C.non_admin_dj ? "given" : "removed"] the ability for [key_name(C)] to DJ and use dectalk.")
	boutput(C, SPAN_ALERT("<b>You [C.non_admin_dj ? "can now" : "no longer can"] DJ with the 'DJ Panel' and use text2speech with 'Dectalk' commands under 'Special Verbs'.</b>"))

/datum/dj_panel/proc/request_preload(datum/dj_library_sound/upload, client/actor)
	if (!upload)
		return FALSE
	upload.preloaded = TRUE
	message_admins("[admin_key(actor)] requested preload of sound [upload.file]")
	SPAWN(0)
		for (var/client/C in clients)
			C << load_resource(upload.file, -1)
			LAGCHECK(LAG_MED)
	return TRUE

/datum/dj_panel/proc/start_music(datum/dj_library_sound/upload, client/actor)
	src.stop_music()
	var/datum/dj_music_track/track = new(upload.file, upload.duration)
	src.active_music = track
	track.channel = admin_sound_channel
	track.frequency = src.sound_frequency
	track.position = track.frequency < 0 ? track.duration : 0
	track.looping = src.looping
	track.updated_at = TIME
	return actor.play_music_real(track.file, track.frequency, src)

/// Fileless updates preserve each client's playback position.
/datum/dj_panel/proc/music_packet(client/listener, update = TRUE)
	var/datum/dj_music_track/track = src.active_music
	var/sound/packet = sound(update ? null : track.file, channel = track.channel)
	packet.status = (update ? SOUND_UPDATE : 0) | (track.paused ? SOUND_PAUSED : 0)
	packet.repeat = track.looping
	packet.frequency = track.frequency
	packet.volume = src.sound_volume * listener.getVolume(VOLUME_CHANNEL_ADMIN) / 100
	packet.priority = SOUND_PRIORITY_ADMIN
	packet.environment = SOUND_ENVIRONMENT_NONE
	packet.echo = SOUND_ECHO_NONE
	listener.sound_playing[track.channel][1] = src.sound_volume
	listener.sound_playing[track.channel][2] = VOLUME_CHANNEL_ADMIN
	return packet

/datum/dj_panel/proc/update_music(toggle_pause = FALSE)
	var/datum/dj_music_track/track = src.active_music
	if (!track)
		return
	if (toggle_pause || track.frequency != src.sound_frequency || track.looping != src.looping)
		track.sync_position()
		track.frequency = src.sound_frequency
		track.looping = src.looping
		if (toggle_pause)
			track.paused = !track.paused
		src.schedule_completion()
	for (var/client/C in clients)
		C << src.music_packet(C)

/datum/dj_panel/proc/stop_music(stop_playback = TRUE)
	if (!src.active_music)
		return
	var/datum/dj_music_track/track = src.active_music
	src.active_music = null
	if (stop_playback)
		var/sound/stop = sound(null, channel = track.channel)
		for (var/client/C in clients)
			C << stop
			C.sound_playing[track.channel][1] = 0
	qdel(track)

/datum/dj_panel/proc/schedule_completion()
	var/datum/dj_music_track/track = src.active_music
	var/timer_id = ++track.end_timer_id
	var/delay = track.completion_delay()
	if (isnull(delay))
		return
	SPAWN(max(world.tick_lag, ceil(delay)))
		if (!track || src.active_music != track || track.end_timer_id != timer_id)
			return
		var/remaining = track.completion_delay()
		if (!isnull(remaining) && remaining <= 0)
			// Do not cut off clients whose downloads delayed playback.
			src.stop_music(stop_playback = FALSE)

#undef DJ_MAX_FREQUENCY

/// Playback position and duration are seconds at the original sample rate.
/datum/dj_music_track
	var/file
	var/channel
	var/paused = FALSE
	var/looping = FALSE
	var/frequency = 1
	var/position = 0
	var/duration = 0
	var/updated_at = 0
	/// Invalidates callbacks after playback timing changes.
	var/end_timer_id = 0

/datum/dj_music_track/New(file, duration = 0)
	..()
	src.file = file
	src.duration = max(0, duration)

/datum/dj_music_track/proc/get_position(at_time = TIME)
	var/elapsed = src.position
	if (!src.paused && src.frequency)
		elapsed += ((at_time - src.updated_at + 24 HOURS) % (24 HOURS)) / (1 SECOND) * src.frequency
	if (src.duration > 0)
		if (src.looping)
			var/wrapped = elapsed %% src.duration
			if (wrapped < 0)
				wrapped += src.duration
			return !wrapped && src.frequency < 0 ? src.duration : wrapped
		return clamp(elapsed, 0, src.duration)
	return elapsed

/datum/dj_music_track/proc/sync_position(at_time = TIME)
	src.position = src.get_position(at_time)
	src.updated_at = at_time

/// Elapsed seconds in the current direction, scaled to the playback speed
/datum/dj_music_track/proc/get_elapsed(at_time = TIME)
	var/source_position = src.get_position(at_time)
	var/elapsed = src.frequency < 0 ? src.duration - source_position : source_position
	return max(0, elapsed) / (abs(src.frequency) || 1)

/// Remaining wall-clock time in deciseconds
/datum/dj_music_track/proc/completion_delay(at_time = TIME)
	if (src.paused || src.looping || src.duration <= 0 || !src.frequency)
		return null
	var/remaining = src.frequency < 0 ? src.get_position(at_time) : src.duration - src.get_position(at_time)
	return max(0, remaining / abs(src.frequency) * (1 SECOND))

/datum/dj_library_sound
	var/file
	var/size_bytes
	var/duration = 0
	var/preloaded = FALSE

/datum/dj_library_sound/New(file)
	..()
	src.file = file
	src.size_bytes = length(file)
	// rust-g requires a filesystem path even for runtime uploads; its result is in deciseconds.
	var/static/metadata_counter = 0
	var/temp_path = "data/dj_uploads/[world.realtime]-[++metadata_counter].tmp"
	if (!fcopy(file, temp_path))
		return
	var/list/results
	try
		results = rustg_sound_length_list(list(temp_path))
	catch
		// Unreadable metadata must not prevent playback.
		results = null
	fdel(temp_path)
	var/list/durations = results?[RUSTG_SOUNDLEN_SUCCESSES]
	src.duration = max(0, text2num_safe(durations?[temp_path])) / (1 SECOND)
