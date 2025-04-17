#define MAX_NOTE_INPUT 1920
#define MAX_CONCURRENT_NOTES 8

#define DELAY_NOTE_MIN 0
#define DELAY_NOTE_MAX 100
#define DELAY_REST_MIN 1
#define DELAY_REST_MAX 1000

#define STANDARD_INSTRUMENT_PATH(instrument_name) "sound/musical_instruments/[instrument_name]/notes"
/// The most error messages allowed before older messages are deleted.
#define MAX_ERROR_MESSAGES 5

ABSTRACT_TYPE(/datum/text_to_music)
/**
 * Datum that forms the core of Player Pianos and Text to Music components
 * Code from `playable_piano.dm`, with some unique additions
 * ----------------------------------
 * Base type `/datum/text_to_music` should not be used
 * Subtype `/datum/text_to_music/player_piano` is for Player Pianos
 * Subtype `/datum/text_to_music/mech_comp` is for Text to Music components
 */
/datum/text_to_music
	// Made into constants since both the Piano Player and Text to Music comp need to reference it
	var/const/MIN_TIMING = 0.1
	var/const/MAX_TIMING = 0.5
	/// Values from MIN_TIMING to MAX_TIMING please.
	var/timing = 0.5
	/// Is the piano looping? 0 is no, 1 is yes, 2 is never more looping.
	var/is_looping = 0
	/// Stops people from messing about with it when its working.
	var/is_busy = FALSE
	/// Set to TRUE to stop a currently playing music player
	var/is_stop_requested = FALSE
	/// The number of notes in the song.
	var/song_length = 0
	/// What note is the song on?
	var/curr_note = 0
	/// What's the name of the current instrument? Must be the same as the instrument name in `instruments.dm`.
	var/instrument_name = "piano"
	/// Where input is stored.
	var/list/note_input = ""
	/// After we break it up into chunks.
	var/list/notes = list()
	/// List of volumes as nums (20,30,40,50,60).
	var/list/note_volumes = list()
	/// List of octaves as nums (0-8).
	var/list/note_octaves = list()
	/// a, b, c, d, e, f, g, r
	var/list/note_names = list()
	/// (s)harp, b(flat), (n)atural
	var/list/note_accidentals = list()
	/// Delay is measured as a multiple of `timing`.
	var/list/note_delays = list()
	/// Holds our compiled filenames for the note.
	var/list/compiled_notes = list()
	/// Same as `is_busy`, but for automatic linking.
	var/is_stored = FALSE
	/// If the note sound file for this instrument is not in the sound cache, treat it as a rest note
	var/rest_on_notes_not_in_cache = TRUE
	/// List that stores our linked pianos, including the main one.
	var/list/linked_music_players = list()
	/// Name to use when displaying messages to the user
	var/holder_name = "piano"
	/// The object this datum is attached to
	var/obj/holder = null
	/// List of all sound instrument paths.
	var/list/sounds_instrument_associative = null

/datum/text_to_music/New(var/obj/new_holder)
	. = ..()

	src.holder = new_holder
	src.sounds_instrument_associative = global.instrument_sound_bank.bank[src.instrument_name].sounds_instrument_associative

/datum/text_to_music/proc/clean_input() //breaks our big input string into chunks
	src.is_busy = TRUE
	src.notes = list()
	var/list/split_input = splittext("[note_input]", "|")
	var/split_list_length = length(split_input)
	if (split_list_length > MAX_NOTE_INPUT)
		src.event_error_notes_over_limit(split_list_length)
		return FALSE
	for (var/string in split_input)
		if (string)
			src.notes += string
	src.is_busy = FALSE
	return TRUE

/datum/text_to_music/proc/build_notes(var/list/notes) //breaks our chunks apart and puts them into lists on the object
	. = FALSE

	src.is_busy = TRUE
	src.note_volumes     = list()
	src.note_octaves     = list()
	src.note_names       = list()
	src.note_accidentals = list()
	src.note_delays      = list()

	// e.g. timing,20
	if (lowertext(copytext(notes[1], 1, 8)) == "timing,")
		var/timing = splittext(notes[1], ",")[2]
		// convert from centiseconds to seconds
		timing = text2num(timing) / 100
		if (timing < src.MIN_TIMING || timing > src.MAX_TIMING)
			src.event_error_invalid_timing(timing)
			return FALSE
		src.timing = timing

		notes.Remove(notes[1])

	var/note_index = 0
	for (var/string in notes)
		var/list/curr_notes = splittext("[string]", ",")
		var/curr_notes_length = length(curr_notes)
		note_index++
		if (curr_notes_length != 4 && curr_notes_length != 5) // Music syntax not followed
			src.event_error_invalid_note(string, note_index)
			return FALSE
		if (lowertext(curr_notes[2]) == "b") // Correct enharmonic pitches to conform to music syntax; transforming flats to sharps
			if (lowertext(curr_notes[1]) == "a")
				curr_notes[1] = "g"
			else
				curr_notes[1] = ascii2text(text2ascii(curr_notes[1]) - 1)
		src.note_names += curr_notes[1]
		switch(lowertext(curr_notes[4]))
			if ("r")
				curr_notes[4] = "r"
		src.note_octaves += curr_notes[4]
		switch(lowertext(curr_notes[2]))
			if ("s", "b")
				curr_notes[2] = "-"
			if ("n")
				curr_notes[2] = ""
			if ("r")
				curr_notes[2] = "r"
		src.note_accidentals += curr_notes[2]
		switch(lowertext(curr_notes[3]))
			if ("p")
				curr_notes[3] = 20
			if ("mp")
				curr_notes[3] = 30
			if ("n")
				curr_notes[3] = 40
			if ("mf")
				curr_notes[3] = 50
			if ("f")
				curr_notes[3] = 60
			if ("r")
				curr_notes[3] = 0
		src.note_volumes += curr_notes[3]
		if (curr_notes_length == 5)
			var/delay = text2num_safe(curr_notes[5])
			if (delay == null)
				src.event_error_invalid_note(string, note_index)
				return FALSE
			if (curr_notes[3] > 0)
				delay = clamp(delay, DELAY_NOTE_MIN, DELAY_NOTE_MAX)
			else
				delay = clamp(delay, DELAY_REST_MIN, DELAY_REST_MAX)
			src.note_delays += delay
		else
			src.note_delays += 1
		LAGCHECK(LAG_LOW)
	src.is_busy = FALSE
	return TRUE

/// final checks to make sure stuff is right, gets notes into a compiled form for easy playsounding
/datum/text_to_music/proc/make_ready(var/is_linked)
	if (src.is_busy || src.is_stored)
		return
	src.is_busy = TRUE
	if (note_volumes.len + note_octaves.len - note_names.len - note_accidentals.len)
		src.event_error_event_missing_part()
		src.is_busy = FALSE
		src.update_icon(FALSE)
	src.song_length = length(note_names)
	compiled_notes = list()
	for (var/i = 1, i <= note_names.len, i++)
		var/string = lowertext("[note_names[i]][note_accidentals[i]][note_octaves[i]]")
		compiled_notes += string
	if (isnull(src.sounds_instrument_associative))
		CRASH("sounds_instrument_associative is null!")
	for (var/i = 1, i <= compiled_notes.len, i++)
		if (compiled_notes[i] == "rrr")
			continue
		if (isnull(src.sounds_instrument_associative[compiled_notes[i]]) && !rest_on_notes_not_in_cache)
			src.event_error_note_not_found(i, src.notes[i])
			src.is_busy = FALSE
			src.update_icon(FALSE)
			return
	src.event_play_start()
	src.update_icon(TRUE)
	if (is_linked)
		src.play_notes(FALSE)
		return
	src.play_notes(TRUE)

/datum/text_to_music/proc/play_notes(var/is_master)
	var/concurrent_notes_played = 0
	if (length(src.linked_music_players) > 0 && is_master)
		for (var/datum/text_to_music/music_player in src.linked_music_players)
			SPAWN(0)
				music_player.make_ready(1)
	while (src.curr_note <= src.song_length)
		src.curr_note++
		if (src.curr_note > src.song_length || src.is_stop_requested)
			if (is_looping == 1 && !(src.is_stop_requested))
				src.curr_note = 0
				play_notes()
				return
			src.is_busy = FALSE
			src.curr_note = 0
			src.event_play_end()
			SEND_SIGNAL(src.holder, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "musicStopped")
			src.is_stop_requested = FALSE
			src.update_icon(FALSE)
			return
		if (!src.curr_note) // else we get runtimes when the piano is reset while playing
			return

		if (concurrent_notes_played < MAX_CONCURRENT_NOTES && compiled_notes[curr_note] != "rrr")
			var/sound_path = src.sounds_instrument_associative[compiled_notes[src.curr_note]]
			if (!isnull(sound_path))
				playsound(src.holder, sound_path, note_volumes[src.curr_note],0,10,0, channel = VOLUME_CHANNEL_INSTRUMENTS)

		var/delays_left = src.note_delays[src.curr_note]

		if (delays_left == 0)
			concurrent_notes_played++
			continue

		concurrent_notes_played = 0

		while (delays_left > 0)
			delays_left--
			sleep((timing * 10)) //to get delay into 10ths of a second

/datum/text_to_music/proc/set_notes(var/given_notes)
	if (src.is_busy || src.is_stored)
		return FALSE

	src.note_input = given_notes

	if (!src.clean_input() || !src.build_notes(src.notes))
		src.note_input = ""
		src.is_busy = FALSE
		return FALSE

	return TRUE

/datum/text_to_music/proc/set_timing(var/time_sel)
	if (src.is_busy || src.is_stored)
		return FALSE

	if (time_sel < src.MIN_TIMING || time_sel > src.MAX_TIMING)
		return FALSE

	src.timing = time_sel

	return TRUE

/datum/text_to_music/proc/stop(var/is_primary = FALSE)
	if(src.is_busy)
		src.is_stop_requested = TRUE

	if (is_primary)
		for (var/datum/text_to_music/music_player as anything in src.linked_music_players)
			music_player.stop()

/datum/text_to_music/proc/unlink()
	if (src.is_busy || src.is_stored)
		return

	for (var/datum/text_to_music/other_music_player as anything in src.linked_music_players)
		if (!isnull(other_music_player))
			other_music_player.linked_music_players -= src

	src.linked_music_players = list()

/datum/text_to_music/proc/reset(var/disposing) //so i dont have to have duplicate code for multiool pulsing and piano key
	src.update_icon(FALSE)
	src.event_reset()
	if (src.is_looping != 2 || disposing)
		src.is_looping = 0
	if (disposing)
		src.is_stored = FALSE
	src.song_length = 0
	src.curr_note = 0
	src.timing = 0.5
	src.is_busy = FALSE
	src.note_input = ""
	src.notes = list()
	src.note_volumes = list()
	src.note_octaves = list()
	src.note_names = list()
	src.note_accidentals = list()
	src.compiled_notes = list()
	src.linked_music_players = list()
	src.note_delays = list()
	src.is_stop_requested = FALSE

/datum/text_to_music/proc/add_music_player(var/datum/text_to_music/music_player)
	var/music_player_id = "\ref[music_player]"
	for (var/datum/text_to_music/other_music_player in src.linked_music_players)
		var/other_music_player_id = "\ref[other_music_player]"
		if (other_music_player_id == music_player_id)
			src.linked_music_players -= music_player
	src.linked_music_players += music_player

/datum/text_to_music/proc/event_play_start()
	return

/datum/text_to_music/proc/event_play_end()
	return

/datum/text_to_music/proc/event_reset()
	return

/datum/text_to_music/proc/event_error_note_not_found(var/note_index, var/note)
	return

/datum/text_to_music/proc/event_error_invalid_timing(var/timing)
	return

/datum/text_to_music/proc/event_error_event_missing_part()
	return

/datum/text_to_music/proc/event_error_invalid_note(var/note, var/note_index)
	return

/datum/text_to_music/proc/event_error_notes_over_limit(var/song_length)
	return

/datum/text_to_music/proc/update_icon(var/is_active)
	src.holder.UpdateIcon(is_active)

/datum/text_to_music/proc/is_panel_exposed()
	return TRUE

/datum/text_to_music/proc/is_comp_anchored()
	return TRUE

/datum/text_to_music/proc/start_autolinking(obj/item/I, mob/user)
	if (src.is_busy)
		boutput(user, SPAN_ALERT("Can't link a busy music player!"))
		return FALSE
	if (!src.is_panel_exposed())
		boutput(user, SPAN_ALERT("Can't link without an exposed panel!"))
		return FALSE
	if (!src.is_comp_anchored())
		boutput(user, SPAN_ALERT("Can't link an unanchored music player!"))
		return FALSE
	if (length(src.linked_music_players))
		boutput(user, SPAN_ALERT("Can't link an already linked music player!"))
		return FALSE
	if (src.is_stored)
		boutput(user, SPAN_ALERT("Another device has already stored that music player!"))
		return FALSE

// ----------------------------------------------------------------------------------------------------

/datum/text_to_music/player_piano

/datum/text_to_music/player_piano/event_play_start()
	src.holder.visible_message(SPAN_NOTICE("\The [src.holder] starts playing music!"))

/datum/text_to_music/player_piano/event_play_end()
	src.holder.visible_message(SPAN_NOTICE("\The [src.holder] stops playing music."))

/datum/text_to_music/player_piano/event_reset()
	src.holder.visible_message(SPAN_NOTICE("\The [src.holder] grumbles and shuts down completely."))

/datum/text_to_music/player_piano/event_error_note_not_found(var/note_index, var/note)
	src.holder.visible_message(SPAN_ALERT("\The [src.holder] makes an atrocious racket and beeps [note_index] times."))

/datum/text_to_music/player_piano/event_error_invalid_timing(var/timing)
	src.holder.visible_message(SPAN_ALERT("\The [src.holder] makes a loud grinding noise, followed by a boop!"))

/datum/text_to_music/player_piano/event_error_event_missing_part()
	src.holder.visible_message(SPAN_ALERT("\The [src.holder] makes a grumpy ratchetting noise and shuts down!"))

/datum/text_to_music/player_piano/event_error_invalid_note(var/note, var/note_index)
	src.holder.visible_message(SPAN_ALERT("\The [src.holder] makes a high-pitched screeching sound and beeps [note_index] times!"))

/datum/text_to_music/player_piano/event_error_notes_over_limit(var/song_length)
	src.holder.visible_message(SPAN_ALERT("\The [src.holder] quakes violently before beeping [song_length] times!"))

/datum/text_to_music/player_piano/start_autolinking(obj/item/I, mob/user)
	. = ..()

	if (. == FALSE)
		return

	I.AddComponent(/datum/component/music_player_auto_linker/player_piano, src, user)

/datum/text_to_music/player_piano/is_panel_exposed()
	var/obj/player_piano/piano = src.holder
	return piano.panel_exposed

// ----------------------------------------------------------------------------------------------------

/datum/text_to_music/mech_comp
	/// the instruments that can be played
	var/list/allow_list = list()
	var/list/deny_list = list(
		"grand piano",
		"spooky trumpet"
	)
	var/list/error_messages = list()
	holder_name = "Text to Music component"

/datum/text_to_music/mech_comp/New(var/obj/new_holder)
	. = ..(new_holder)

	src.build_allow_list()

/datum/text_to_music/mech_comp/event_play_start()
	animate_flash_color_fill(src.holder, "#00ff00", 2, 2)

/datum/text_to_music/mech_comp/event_play_end()
	animate_flash_color_fill(src.holder, "#ff0000", 2, 2)

/datum/text_to_music/mech_comp/event_reset()
	animate_flash_color_fill(src.holder, "#0000ff", 2, 2)

/datum/text_to_music/mech_comp/event_error_note_not_found(var/note_index, var/note)
	src.log_error_message("Note <b>\[[note]\]</b> at position <b>\[[note_index]\]</b> doesn't exist for <b>\[[src.instrument_name]\]</b>.")

/datum/text_to_music/mech_comp/event_error_invalid_timing(var/timing)
	src.log_error_message("Given timing <b>\[[timing]\]</b> is outside of range [src.MIN_TIMING]-[src.MAX_TIMING].")

/datum/text_to_music/mech_comp/event_error_event_missing_part()
	src.log_error_message("A piece of an event was missing somewhere.")

/datum/text_to_music/mech_comp/event_error_invalid_note(var/note, var/note_index)
	src.log_error_message("Note <b>\[[note]\]</b> at index <b>\[[note_index]\]</b> is invalid.")

/datum/text_to_music/mech_comp/event_error_notes_over_limit(var/song_length)
	src.log_error_message("Song entered is <b>\[[song_length]\]</b> notes long, over the max notes limit of <b>\[[MAX_NOTE_INPUT]\]</b>.")

/datum/text_to_music/mech_comp/proc/log_error_message(var/error_message)
	src.error_messages.Insert(1, error_message)

	if (length(src.error_messages) > MAX_ERROR_MESSAGES)
		src.error_messages.Cut(MAX_ERROR_MESSAGES + 1, 0)

	animate_flash_color_fill(src.holder, "#ff00ff", 2, 2)

/datum/text_to_music/mech_comp/proc/build_allow_list()
	src.allow_list = list()

	for (var/key in global.instrument_sound_bank)
		if (key in src.deny_list)
			continue

		src.allow_list += key

/datum/text_to_music/mech_comp/set_notes(var/given_notes)
	if (..())
		src.rebuild_tooltip()

/datum/text_to_music/mech_comp/set_timing(var/time_sel)
	if (..())
		src.rebuild_tooltip()

/datum/text_to_music/mech_comp/reset(var/disposing) //so i dont have to have duplicate code for multiool pulsing and piano key
	. = ..(disposing)

	src.rebuild_tooltip()
	src.error_messages = list()

/datum/text_to_music/mech_comp/proc/set_instrument(var/instrument)
	if (src.is_busy || src.is_stored)
		return

	if (instrument in src.allow_list)
		src.instrument_name = instrument
		src.sounds_instrument_associative = global.instrument_sound_bank.bank[instrument_name].sounds_instrument_associative

		src.rebuild_tooltip()

/datum/text_to_music/mech_comp/proc/rebuild_tooltip()
	var/obj/item/holder_item = src.holder
	holder_item.tooltip_rebuild = TRUE

/datum/text_to_music/mech_comp/start_autolinking(obj/item/I, mob/user)
	var/obj/item/mechanics/text_to_music/holder_mech_comp = src.holder

	. = ..()

	if (. == FALSE)
		return

	I.AddComponent(/datum/component/music_player_auto_linker/mech_comp, holder_mech_comp.music_player, user)

/datum/text_to_music/is_comp_anchored()
	var/obj/item/mechanics/text_to_music/t2m_comp = src.holder
	return t2m_comp.anchored

#undef MAX_NOTE_INPUT
#undef MAX_CONCURRENT_NOTES

#undef DELAY_NOTE_MIN
#undef DELAY_NOTE_MAX
#undef DELAY_REST_MIN
#undef DELAY_REST_MAX

#undef STANDARD_INSTRUMENT_PATH
#undef MAX_ERROR_MESSAGES
