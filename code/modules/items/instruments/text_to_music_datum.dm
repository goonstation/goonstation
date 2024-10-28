#define MIN_TIMING 0.1
#define MAX_TIMING 0.5

#define MAX_NOTE_INPUT 1920
#define MAX_CONCURRENT_NOTES 8

#define DELAY_NOTE_MIN 0
#define DELAY_NOTE_MAX 100
#define DELAY_REST_MIN 1
#define DELAY_REST_MAX 1000

#define STANDARD_INSTRUMENT_PATH(instrument_name) "sound/musical_instruments/[instrument_name]/notes"
#define MAX_ERROR_MESSAGES 5 // the most error messages allowed before older messages are deleted

/datum/text_to_music
	var/timing = 0.5 //values from 0.25 to 0.5 please
	var/is_looping = 0 //is the piano looping? 0 is no, 1 is yes, 2 is never more looping
	var/is_busy = 0 //stops people from messing about with it when its working
	var/is_stop_requested = FALSE
	var/song_length = 0 //the number of notes in the song
	var/curr_note = 0 //what note is the song on?
	var/instrument_name = "piano"
	var/instrument_sound_path = null // where are the note sounds located?
	var/list/note_input = "" //where input is stored
	var/list/piano_notes = list() //after we break it up into chunks
	var/list/note_volumes = list() //list of volumes as nums (20,30,40,50,60)
	var/list/note_octaves = list() //list of octaves as nums (3-5)
	var/list/note_names = list() //a,b,c,d,e,f,g,r
	var/list/note_accidentals = list() //(s)harp,b(flat),N(none)
	var/list/note_delays = list() // delay is measured as a multiple of timing
	var/list/compiled_notes = list() //holds our compiled filenames for the note

/datum/text_to_music/proc/clean_input() //breaks our big input string into chunks
	src.is_busy = 1
	src.piano_notes = list()
//		src.log_error_message(SPAN_NOTICE("\The [src] starts humming and rattling as it processes!"))
	var/list/split_input = splittext("[note_input]", "|")
	if (length(split_input) > MAX_NOTE_INPUT)
		return FALSE
	for (var/string in split_input)
		if (string)
			piano_notes += string
	src.is_busy = 0
	return TRUE

/datum/text_to_music/proc/build_notes(var/list/piano_notes) //breaks our chunks apart and puts them into lists on the object
	src.is_busy = TRUE
	src.note_volumes     = list()
	src.note_octaves     = list()
	src.note_names       = list()
	src.note_accidentals = list()
	src.note_delays      = list()

	// e.g. timing,20
	if (lowertext(copytext(piano_notes[1], 1, 8)) == "timing,")
		var/timing = splittext(piano_notes[1], ",")[2]
		// convert from centiseconds to seconds
		timing = text2num(timing) / 100
		if (timing < MIN_TIMING || timing > MAX_TIMING)
			src.log_error_message(SPAN_ALERT("\The [src] makes a loud grinding noise, followed by a boop and a beep!"))
			src.is_busy = FALSE
			return
		src.timing = timing

		piano_notes.Remove(piano_notes[1])

	for (var/string in piano_notes)
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

/datum/text_to_music/proc/ready_piano() //final checks to make sure stuff is right, gets notes into a compiled form for easy playsounding
	if (is_busy)
		return
	is_busy = 1
	if (note_volumes.len + note_octaves.len - note_names.len - note_accidentals.len)
		src.log_error_message(SPAN_ALERT("\The [src] makes a grumpy ratchetting noise and shuts down!"))
		is_busy = 0
		src.update_icon(TRUE)
	song_length = length(note_names)
	compiled_notes = list()
	for (var/i = 1, i <= note_names.len, i++)
		var/string = lowertext("[note_names[i]][note_accidentals[i]][note_octaves[i]]")
		compiled_notes += string
	for (var/i = 1, i <= compiled_notes.len, i++)
		var/string = "sound/musical_instruments/piano/notes/"
		string += "[compiled_notes[i]].ogg"
		if (!(string in soundCache))
			src.log_error_message(SPAN_ALERT("\The [src] makes an atrocious racket and beeps [i] times."))
			is_busy = 0
			src.update_icon(TRUE)
			return
	src.log_error_message(SPAN_NOTICE("\The [src] starts playing music!"))
	src.update_icon(0)

/datum/text_to_music/proc/play_notes() //how notes are handled, using while and spawn to set a very strict interval, solo piano process loop was too variable to work for music
	var/concurrent_notes_played = 0
	while (curr_note <= song_length)
		curr_note++
		if (curr_note > song_length)
			if (is_looping == 1)
				curr_note = 0
				play_notes()
				return
			is_busy = 0
			curr_note = 0
			src.log_error_message(SPAN_NOTICE("\The [src] stops playing music."))
			SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "musicStopped")
			src.update_icon(TRUE)
			return
		if (!curr_note) // else we get runtimes when the piano is reset while playing
			return

		if (concurrent_notes_played < MAX_CONCURRENT_NOTES)
			var/sound_name = "sound/musical_instruments/piano/notes/[compiled_notes[curr_note]].ogg"
			playsound(src, sound_name, note_volumes[curr_note],0,10,0)

		var/delays_left = src.note_delays[curr_note]

		if (delays_left == 0)
			concurrent_notes_played++
			continue

		concurrent_notes_played = 0

		while (delays_left > 0)
			delays_left--
			sleep((timing * 10)) //to get delay into 10ths of a second

/datum/text_to_music/proc/set_notes(var/given_notes)
	if (src.is_busy)
		return FALSE

	src.note_input = given_notes

	if (!src.clean_input())
		src.note_input = ""
		src.is_busy = FALSE
		return FALSE

	src.build_notes(src.piano_notes)

	return TRUE

/datum/text_to_music/proc/set_timing(var/time_sel)
	if (is_busy)
		return FALSE
	if (time_sel < MIN_TIMING || time_sel > MAX_TIMING)
		return FALSE
	src.timing = time_sel
	return TRUE

/datum/text_to_music/proc/reset_piano(var/disposing) //so i dont have to have duplicate code for multiool pulsing and piano key
	src.log_error_message(SPAN_NOTICE("\The [src] grumbles and shuts down completely."))
	if (is_looping != 2 || disposing)
		is_looping = 0
	song_length = 0
	curr_note = 0
	timing = 0.5
	is_busy = 0
	note_input = ""
	piano_notes = list()
	note_volumes = list()
	note_octaves = list()
	note_names = list()
	note_accidentals = list()
	compiled_notes = list()
	note_delays = list()
	src.update_icon(TRUE)

/datum/text_to_music/proc/log_error_message(var/error_message)
	return

/datum/text_to_music/proc/update_icon(var/is_active)
	return

// ---------------------------------------------------------------------

/datum/text_to_music/player_piano
	var/obj/player_piano/holder = null

/datum/text_to_music/player_piano/New(obj/player_piano/holder)
	. = ..()

	src.holder = holder

/datum/text_to_music/player_piano/ready_piano(var/is_linked)
	if (src.holder.is_stored)
		return

	. =  ..(is_linked)

	if (is_linked)
		src.play_notes(TRUE)
		return

	src.play_notes(FALSE)

/datum/text_to_music/player_piano/play_notes(var/is_master)
	if (length(src.holder.linked_pianos) > 0 && is_master)
		for (var/obj/player_piano/p in src.holder.linked_pianos)
			SPAWN(0)
				p.music_player.ready_piano(1)

	return ..()

/datum/text_to_music/player_piano/set_notes(var/given_notes)
	if (src.holder.is_stored)
		return

	return ..(given_notes)

/datum/text_to_music/player_piano/set_timing(var/time_sel)
	if (src.holder.is_stored)
		return

	return ..(time_sel)

/datum/text_to_music/player_piano/log_error_message(var/error_message)
	src.holder.visible_message(error_message)

// ---------------------------------------------------------------------

/datum/text_to_music/mech_comp
	var/obj/item/mechanics/text_to_music/holder = null

/datum/text_to_music/mech_comp/New(obj/player_piano/holder)
	. = ..()

	src.holder = holder

/datum/text_to_music/mech_comp/log_error_message(var/error_message)
	src.holder.error_messages.Insert(1, error_message)

	if (length(src.holder.error_messages) > MAX_ERROR_MESSAGES)
		src.holder.error_messages.Cut(MAX_ERROR_MESSAGES + 1, 0)

	animate_flash_color_fill(src.holder, "#ff0000", 2, 2)

#undef MIN_TIMING
#undef MAX_TIMING

#undef MAX_NOTE_INPUT
#undef MAX_CONCURRENT_NOTES

#undef DELAY_NOTE_MIN
#undef DELAY_NOTE_MAX
#undef DELAY_REST_MIN
#undef DELAY_REST_MAX

#undef STANDARD_INSTRUMENT_PATH
#undef MAX_ERROR_MESSAGES
