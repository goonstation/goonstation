/**
 * Datum that forms the core of Player Pianos and Text to Music components
 * Code from `playable_piano.dm`
 * Please don't use `/datum/text_to_music` as-is, use a subtype or make a new one
 */

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
 * Code from `playable_piano.dm`
 * Base type `/datum/text_to_music/player_piano` is for Player Pianos
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
	var/is_stop_requested = FALSE
	/// The number of notes in the song.
	var/song_length = 0
	/// What note is the song on?
	var/curr_note = 0
	/// What's the name of the current instrument? Must be the same as the sound folder name.
	var/instrument_name = "piano"
	/// Where are the note sounds located?
	var/instrument_sound_path = null
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
	var/rest_on_notes_not_in_cache = FALSE
	/// List that stores our linked pianos, including the main one.
	var/list/linked_music_players = list()
	var/holder_name = "piano"
	var/obj/holder = null

/datum/text_to_music/New(var/obj/new_holder)
	. = ..()

	src.holder = new_holder
	src.instrument_sound_path = STANDARD_INSTRUMENT_PATH(src.instrument_name)

/datum/text_to_music/proc/clean_input() //breaks our big input string into chunks
	src.is_busy = TRUE
	src.notes = list()
	var/list/split_input = splittext("[note_input]", "|")
	if (length(split_input) > MAX_NOTE_INPUT)
		return FALSE
	for (var/string in split_input)
		if (string)
			src.notes += string
	src.is_busy = FALSE
	return TRUE

/datum/text_to_music/proc/build_notes(var/list/notes) //breaks our chunks apart and puts them into lists on the object
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
			src.is_busy = FALSE
			return
		src.timing = timing

		notes.Remove(notes[1])

	for (var/string in notes)
		var/list/curr_notes = splittext("[string]", ",")
		var/curr_notes_length = length(curr_notes)
		if (curr_notes_length != 4 && curr_notes_length != 5) // Music syntax not followed
			break
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
			if (curr_notes[3] > 0)
				delay = clamp(delay, DELAY_NOTE_MIN, DELAY_NOTE_MAX)
			else
				delay = clamp(delay, DELAY_REST_MIN, DELAY_REST_MAX)
			src.note_delays += delay
		else
			src.note_delays += 1
		LAGCHECK(LAG_LOW)
	src.is_busy = FALSE

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
	for (var/i = 1, i <= compiled_notes.len, i++)
		if (compiled_notes[i] == "rrr")
			continue
		var/string = "[instrument_sound_path]/[compiled_notes[i]].ogg"
		if (!(string in soundCache))
			if (rest_on_notes_not_in_cache)
				continue
			src.event_error_invalid_note(i, src.notes[i])
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
			SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "musicStopped")
			src.is_stop_requested = FALSE
			src.update_icon(FALSE)
			return
		if (!src.curr_note) // else we get runtimes when the piano is reset while playing
			return

		if (concurrent_notes_played < MAX_CONCURRENT_NOTES && compiled_notes[curr_note] != "rrr")
			var/sound_name = "[instrument_sound_path]/[compiled_notes[src.curr_note]].ogg"
			if (sound_name in soundCache)
				playsound(src.holder, sound_name, note_volumes[src.curr_note],0,10,0, channel = VOLUME_CHANNEL_INSTRUMENTS)

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

	if (!src.clean_input())
		src.note_input = ""
		src.is_busy = FALSE
		return FALSE

	src.build_notes(src.notes)

	return TRUE

/datum/text_to_music/proc/set_timing(var/time_sel)
	if (src.is_busy || src.is_stored)
		return FALSE

	if (time_sel < src.MIN_TIMING || time_sel > src.MAX_TIMING)
		return FALSE

	src.timing = time_sel

	return TRUE

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

/datum/text_to_music/proc/event_error_invalid_note(var/note_index, var/note)
	return

/datum/text_to_music/proc/event_error_invalid_timing(var/timing)
	return

/datum/text_to_music/proc/event_error_event_missing_part()
	return

/datum/text_to_music/proc/update_icon(var/is_active)
	src.holder.UpdateIcon(is_active)

/datum/text_to_music/proc/mouse_drop(var/user, var/datum/text_to_music/other_music_player)
	if (!istype(user, /mob/living))
		return
	var/mob/living/living_user = user
	if (living_user.stat)
		return
	if (!src.allowChange(living_user))
		boutput(living_user, SPAN_ALERT("You can't link [src.holder_name]s without a multitool!"))
		return
	if (src.is_pulser_auto_linking(living_user))
		boutput(living_user, SPAN_ALERT("You can't link [src.holder_name]s manually while auto-linking!"))
		return
	if (other_music_player.is_busy || src.is_busy)
		boutput(living_user, SPAN_ALERT("You can't link a busy [src.holder_name]!"))
		return
	if (!(other_music_player.is_panel_exposed() && src.is_panel_exposed()))
		boutput(living_user, SPAN_ALERT("You can't link when the panels are on!"))
		return
	if (!(other_music_player.is_comp_anchored() && src.is_comp_anchored()))
		boutput(living_user, SPAN_ALERT("You can't link while it's unanchored!"))
		return
	living_user.visible_message("[living_user] links the [src.holder_name]s.", "You link the [src.holder_name]s!")
	src.add_music_player(other_music_player)
	other_music_player.add_music_player(src)

/datum/text_to_music/proc/allowChange(var/mob/M) //copypasted from mechanics code because why do something someone else already did better
	if(hasvar(M, "l_hand") && ispulsingtool(M:l_hand)) return TRUE
	if(hasvar(M, "r_hand") && ispulsingtool(M:r_hand)) return TRUE
	if(hasvar(M, "module_states"))
		for(var/atom/A in M:module_states)
			if(ispulsingtool(A))
				return TRUE
	return FALSE

/datum/text_to_music/proc/is_pulser_auto_linking(var/mob/M)
	if(ispulsingtool(M.l_hand) && SEND_SIGNAL(M.l_hand, COMSIG_IS_MUSIC_PLAYER_AUTO_LINKER_ACTIVE)) return TRUE
	if(ispulsingtool(M.r_hand) && SEND_SIGNAL(M.r_hand, COMSIG_IS_MUSIC_PLAYER_AUTO_LINKER_ACTIVE)) return TRUE
	if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/silicon_user = M
		for(var/atom/A in silicon_user.module_states)
			if(ispulsingtool(A) && SEND_SIGNAL(A, COMSIG_IS_MUSIC_PLAYER_AUTO_LINKER_ACTIVE))
				return TRUE
	if(istype(M, /mob/living/silicon/hivebot))
		var/mob/living/silicon/hivebot/silicon_user = M
		for(var/atom/A in silicon_user.module_states)
			if(ispulsingtool(A) && SEND_SIGNAL(A, COMSIG_IS_MUSIC_PLAYER_AUTO_LINKER_ACTIVE))
				return TRUE
	return FALSE

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

/datum/text_to_music/player_piano/event_error_invalid_note(var/note_index, var/note)
	src.holder.visible_message(SPAN_NOTICE("\The [src] makes an atrocious racket and beeps [note_index] times."))

/datum/text_to_music/player_piano/event_error_invalid_timing(var/timing)
	src.holder.visible_message(SPAN_NOTICE("\The [src] makes a loud grinding noise, followed by a boop!"))

/datum/text_to_music/player_piano/event_error_event_missing_part()
	src.holder.visible_message(SPAN_ALERT("\The [src] makes a grumpy ratchetting noise and shuts down!"))

/datum/text_to_music/player_piano/start_autolinking(obj/item/I, mob/user)
	. = ..()

	if (. == FALSE)
		return

	I.AddComponent(/datum/component/music_player_auto_linker/player_piano, src, user)

/datum/text_to_music/player_piano/mouse_drop(var/user, var/obj/player_piano/piano)
	ENSURE_TYPE(piano)
	if (!piano)
		return

	if (piano == src.holder)
		boutput(user, SPAN_ALERT("You can't link a [src.holder_name] with itself!"))
		return

	. = ..(user, piano.music_player)

/datum/text_to_music/player_piano/is_panel_exposed()
	var/obj/player_piano/piano = src.holder
	return piano.panel_exposed

// ----------------------------------------------------------------------------------------------------

/datum/text_to_music/mech_comp
	/// the instruments that can be played
	var/list/allow_list = list(
		"banjo",
		"bass",
		"elecguitar",
		"fiddle",
		"guitar",
		"piano",
		"saxophone",
		"trumpet"
	)
	var/list/error_messages = list()
	holder_name = "Text to Music component"

/datum/text_to_music/mech_comp/event_play_start()
	animate_flash_color_fill(src.holder, "#00ff00", 2, 2)

/datum/text_to_music/mech_comp/event_play_end()
	animate_flash_color_fill(src.holder, "#ff0000", 2, 2)

/datum/text_to_music/mech_comp/event_reset()
	animate_flash_color_fill(src.holder, "#ff0000", 2, 2)

/datum/text_to_music/mech_comp/event_error_invalid_note(var/note_index, var/note)
	src.log_error_message("Note <b>\[[note]\]</b> at position <b>\[[note_index]\]</b> doesn't exist for <b>\[[src.instrument_name]\]</b>.")

/datum/text_to_music/mech_comp/event_error_invalid_timing(var/timing)
	src.log_error_message("Given timing <b>\[[timing]\]</b> is outside of range [src.MIN_TIMING]-[src.MAX_TIMING].")

/datum/text_to_music/mech_comp/event_error_event_missing_part()
	src.log_error_message("A piece of an event was missing somewhere.")

/datum/text_to_music/mech_comp/proc/log_error_message(var/error_message)
	src.error_messages.Insert(1, error_message)

	if (length(src.error_messages) > MAX_ERROR_MESSAGES)
		src.error_messages.Cut(MAX_ERROR_MESSAGES + 1, 0)

	animate_flash_color_fill(src.holder, "#ff00ff", 2, 2)

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
		src.instrument_sound_path = STANDARD_INSTRUMENT_PATH(instrument)

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

/datum/text_to_music/mech_comp/mouse_drop(var/user, var/obj/item/mechanics/text_to_music/t2m_comp)
	ENSURE_TYPE(t2m_comp)
	if (!t2m_comp)
		return

	if (t2m_comp == src.holder)
		boutput(user, SPAN_ALERT("You can't link a [src.holder_name] with itself!"))
		return

	. = ..(user, t2m_comp.music_player)

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
