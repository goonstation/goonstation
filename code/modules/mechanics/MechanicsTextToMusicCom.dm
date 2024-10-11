#define MIN_TIMING 0.1
#define MAX_TIMING 0.5

#define MAX_NOTE_INPUT 1920
#define MAX_CONCURRENT_NOTES 8

#define CF_EVENT_LENGTH 8 // how long a Classic Format event is in characters

#define DELAY_NOTE_MIN 0
#define DELAY_NOTE_MAX 80
#define DELAY_REST_MIN 1
#define DELAY_REST_MAX 1000

// Defines for the Dense Format (DF)
#define DF_EVENT_LENGTH 3      // how long a DF event is in characters
#define DF_DELIMITER 32        // space character (reserved char)
#define DF_BOUND_LOWER 33      // !
#define DF_BOUND_UPPER 120     // x
#define DF_REST 121            // y
#define DF_SET_TIMING 122      // z
#define DF_OFFSET_DYNAMIC -13  // shift dynamic from 33 to 20
#define DF_OFFSET_NOTE -12     // shift note    from 33 to 21
#define DF_OFFSET_DELAY -33    // shift delay   from 33 to 0
#define DF_OFFSET_REST -33     // shift rest    from 33 to 0
#define DF_OFFSET_OCTAVE 1     //
#define DF_NOTE_TYPE_AMOUNT 12 // the amount of note types there in an octave
#define DF_DYNAMIC_MIN 20      // lowest  sound volume
#define DF_DYNAMIC_MAX 60      // highest sound volume
#define DF_FORBIDDEN_CHAR "|"  // no pipes please
#define DF_BASE88 88           // how many characters there are in base88

#define STANDARD_INSTRUMENT_PATH(instrument_name) "sound/musical_instruments/[instrument_name]/notes"
#define MAX_ERROR_MESSAGES 5 // the most error messages allowed before older messages are deleted

TYPEINFO(/obj/item/mechanics/text_to_music)
	mats = list("metal"      = 20,
				"conductive" = 10,
				"crystal"    = 10)

/obj/item/mechanics/text_to_music // modified from playable_piano.dm and PR #21051 (Player Piano Notes Rework V2)
	name = "Text to Music Component"
	desc = "Converts text to music."
	icon_state = "comp_text_to_music"
	var/timing = 0.5 //values from 0.25 to 0.5 please
	var/is_looping = 0 //is the piano looping? 0 is no, 1 is yes, 2 is never more looping
	var/is_busy = 0 //stops people from messing about with it when its working
	var/song_length = 0 //the number of notes in the song
	var/curr_note = 0 //what note is the song on?
	var/instrument_sound_path = null // where are the note sounds located?
	var/list/note_input = "" //where input is stored
	var/list/piano_notes = list() //after we break it up into chunks
	var/list/note_volumes = list() //list of volumes as nums (20,30,40,50,60)
	var/list/note_octaves = list() //list of octaves as nums (3-5)
	var/list/note_names = list() //a,b,c,d,e,f,g,r
	var/list/note_accidentals = list() //(s)harp,b(flat),N(none)
	var/list/note_delays = list() // delay is measured as a multiple of timing
	var/list/compiled_notes = list() //holds our compiled filenames for the note
	var/list/error_messages = list("Test", "foo", "bar")
	/// the instruments that can be played
	var/list/allow_list = list("banjo",
								"bass",
								"elecguitar",
								"fiddle",
								"guitar",
								"piano",
								"saxophone",
								"trumpet")

	New()
		..()

		src.instrument_sound_path = STANDARD_INSTRUMENT_PATH("piano")

		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "play", PROC_REF(mechcompPlay))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set notes", PROC_REF(mechcompNotes))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set timing", PROC_REF(mechcompTiming))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set instrument", PROC_REF(mechcompInstrument))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "reset", PROC_REF(mechcompReset))

		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "play", PROC_REF(mechcompConfigPlay))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set notes", PROC_REF(mechcompConfigNotes))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set timing", PROC_REF(mechcompConfigTiming))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set instrument", PROC_REF(mechcompConfigInstrument))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "reset", PROC_REF(mechcompConfigReset))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "view errors", PROC_REF(mechcompConfigViewErrors))

	// requires it's own proc because else the mechcomp input will be taken as first argument of ready_piano()
	proc/mechcompPlay(var/datum/mechanicsMessage/input)
		src.ready_piano()

	proc/mechcompNotes(var/datum/mechanicsMessage/input)
		if (input.signal)
			src.set_notes(input.signal)

	proc/mechcompTiming(var/datum/mechanicsMessage/input)
		var/new_timing = text2num(input.signal)
		if (new_timing)
			src.set_timing(new_timing)

	proc/mechcompInstrument(var/datum/mechanicsMessage/input)
		if (input.signal)
			src.set_instrument(input.signal)

	proc/mechcompReset(var/datum/mechanicsMessage/input)
		src.reset_piano(0)

	// ------------------------------------------------

	proc/mechcompConfigPlay(obj/item/W as obj, mob/user as mob)
		src.ready_piano()

	proc/mechcompConfigNotes(obj/item/W as obj, mob/user as mob)
		var/given_notes = tgui_input_text(user, "Input notes to play.", "Set Notes", src.note_input)
		src.set_notes(given_notes)

	proc/mechcompConfigTiming(obj/item/W as obj, mob/user as mob)
		var/new_timing = tgui_input_number(user, "Input new timing.", "Set Timing", src.timing, MAX_TIMING, MIN_TIMING)
		src.set_timing(new_timing)

	proc/mechcompConfigInstrument(obj/item/W as obj, mob/user as mob)
		var/new_instrument = tgui_input_list(user, "Input new instrument.", "Set Instrument", src.allow_list, src.instrument_sound_path)
		src.set_instrument(new_instrument)

	proc/mechcompConfigReset(obj/item/W as obj, mob/user as mob)
		src.reset_piano(0)

	proc/mechcompConfigViewErrors(obj/item/W as obj, mob/user as mob)
		var/message = jointext(src.error_messages, "<br><hr>")
		tgui_message(user, message, "T2M Error Messages")

	disposing() //just to clear up ANY funkiness
		reset_piano(1)
		..()

	proc/log_error_message(var/error_message)
		src.error_messages.Insert(1, error_message)
		if (length(src.error_messages) > MAX_ERROR_MESSAGES)
			src.error_messages.Cut(MAX_ERROR_MESSAGES + 1, 0)

	proc/clean_input() //breaks our big input string into chunks
		src.is_busy = 1
		src.piano_notes = list()
		var/list/split_input = splittext("[note_input]", "|")
		for (var/string in split_input)
			if (string)
				src.piano_notes += string
		src.is_busy = 0

	proc/build_notes_classic_format(var/list/piano_notes) //breaks our chunks apart and puts them into lists on the object
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
				src.log_error_message("Given timing ([timing]) is outside of range [MIN_TIMING]-[MAX_TIMING].")
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

	/**
	 * **Arguments**
	 *
	 * **str** piano_notes - The notes to convert.
	 * Must **not** be processed like `build_notes_classic_format` is.
	 */
	proc/build_notes_dense_format(var/piano_notes)
		src.is_busy = TRUE

		src.note_volumes     = list()
		src.note_octaves     = list()
		src.note_names       = list()
		src.note_accidentals = list()
		src.note_delays      = list()

		var/translation_list_name       = list("c", "c", "d", "d", "e", "f", "f", "g", "g", "a", "a", "b")
		var/translation_list_accidental = list( "", "-",  "", "-",  "",  "", "-",  "", "-",  "", "-",  "")

		var/note_index = 1

		if (text2ascii(piano_notes[note_index]) == DF_SET_TIMING)
			// convert centiseconds to seconds
			var/timing = (text2ascii(piano_notes[note_index + 2]) - DF_BOUND_LOWER) / 100
			if (timing < MIN_TIMING || timing > MAX_TIMING)
				src.log_error_message("Given timing ([timing]) is outside of range [MIN_TIMING]-[MAX_TIMING].")
				return
			src.timing = timing

			note_index += 3

		while (note_index <= length(piano_notes))
			var/note    = text2ascii(piano_notes[note_index++])
			var/dynamic = text2ascii(piano_notes[note_index++])
			var/delay   = text2ascii(piano_notes[note_index++])

			if (note    < DF_BOUND_LOWER || note    > DF_REST ||\
				dynamic < DF_BOUND_LOWER || dynamic > DF_BOUND_UPPER ||\
				delay   < DF_BOUND_LOWER || delay   > DF_BOUND_UPPER)
				src.log_error_message("A character in event starting at column [note_index - 3] is outside the allowed range.")
				break

			if (note == DF_REST)
				src.note_names       += "r"
				src.note_octaves     += "r"
				src.note_accidentals += "r"
				src.note_volumes     +=  0

				// base88 to base10
				delay = ((dynamic + DF_OFFSET_REST) * (DF_BASE88**1)) + ((delay + DF_OFFSET_REST) * (DF_BASE88**0))
				src.note_delays += clamp(delay, DELAY_REST_MIN, DELAY_REST_MAX)

				continue

			// ---------------------------------------------

			note = note + DF_OFFSET_NOTE

			dynamic = clamp(dynamic + DF_OFFSET_DYNAMIC, DF_DYNAMIC_MIN, DF_DYNAMIC_MAX)

			delay = clamp(delay + DF_OFFSET_DELAY, DELAY_NOTE_MIN, DELAY_NOTE_MAX)

			// ---------------------------------------------

			var/translated_index = note % DF_NOTE_TYPE_AMOUNT

			// +1 to convert from 0-indexed to 1-indexed
			src.note_names += translation_list_name[translated_index + 1]

			src.note_octaves += ((note - translated_index) / DF_NOTE_TYPE_AMOUNT) - DF_OFFSET_OCTAVE

			// +1 to convert from 0-indexed to 1-indexed
			src.note_accidentals += translation_list_accidental[translated_index + 1]

			src.note_volumes += dynamic

			src.note_delays += delay

			LAGCHECK(LAG_LOW)

		src.is_busy = FALSE

	proc/ready_piano() //final checks to make sure stuff is right, gets notes into a compiled form for easy playsounding
		if (src.is_busy)
			return
		src.is_busy = 1
		if (src.note_volumes.len + src.note_octaves.len - src.note_names.len - src.note_accidentals.len)
			src.log_error_message("A piece  of an event was missing somewhere.")
			src.is_busy = 0
		src.song_length = length(note_names)
		src.compiled_notes = list()
		for (var/i = 1, i <= src.note_names.len, i++)
			var/string = lowertext("[src.note_names[i]][src.note_accidentals[i]][src.note_octaves[i]]")
			src.compiled_notes += string
		for (var/i = 1, i <= src.compiled_notes.len, i++)
			var/string = "[instrument_sound_path]/[compiled_notes[i]].ogg"
			if (!(string in soundCache))
				src.log_error_message("The note at position [i] doesn't exist for this insturment.")
				src.is_busy = 0
				return
		src.play_notes()

	proc/play_notes() //how notes are handled, using while and spawn to set a very strict interval, solo piano process loop was too variable to work for music
		src.UpdateIcon(1)
		var/concurrent_notes_played = 0
		while (src.curr_note <= song_length)
			src.curr_note++
			if (src.curr_note > song_length)
				if (src.is_looping == 1)
					src.curr_note = 0
					src.play_notes()
					return
				src.is_busy = 0
				src.curr_note = 0
				src.UpdateIcon(0)
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "musicStopped")
				return
			if (!src.curr_note) // else we get runtimes when the piano is reset while playing
				return

			if (concurrent_notes_played < MAX_CONCURRENT_NOTES)
				var/sound_name = "sound/musical_instruments/piano/notes/[compiled_notes[curr_note]].ogg"
				playsound(src, sound_name, note_volumes[curr_note],0,10,0)

			var/delays_left = src.note_delays[src.curr_note]

			if (delays_left == 0)
				concurrent_notes_played++
				continue

			concurrent_notes_played = 0

			while (delays_left > 0)
				delays_left--
				sleep((src.timing * 10)) //to get delay into 10ths of a second

	proc/set_notes(var/given_notes)
		if (src.is_busy)
			return FALSE
		if (findtext(given_notes, DF_FORBIDDEN_CHAR))
			if ((length(given_notes) / CF_EVENT_LENGTH) > MAX_NOTE_INPUT)
				return FALSE
			src.note_input = given_notes
			src.clean_input()
			src.build_notes_classic_format(src.piano_notes)
		else
			if ((length(given_notes) / DF_EVENT_LENGTH) > MAX_NOTE_INPUT)
				return FALSE
			src.note_input = given_notes
			src.build_notes_dense_format(src.note_input)
		return TRUE

	proc/set_timing(var/time_sel)
		if (src.is_busy)
			return FALSE
		if (time_sel < MIN_TIMING || time_sel > MAX_TIMING)
			return FALSE
		src.timing = time_sel
		return TRUE

	proc/set_instrument(var/instrument)
		if (instrument in src.allow_list)
			src.instrument_sound_path = STANDARD_INSTRUMENT_PATH(instrument)

	proc/reset_piano(var/disposing) //so i dont have to have duplicate code for multiool pulsing and piano key
		src.UpdateIcon(0)
		if (src.is_looping != 2 || disposing)
			src.is_looping = 0
		src.song_length = 0
		src.curr_note = 0
		src.timing = 0.5
		src.is_busy = 0
		src.note_input = ""
		src.piano_notes = list()
		src.note_volumes = list()
		src.note_octaves = list()
		src.note_names = list()
		src.note_accidentals = list()
		src.compiled_notes = list()

	update_icon(var/active) //1: active, 0: inactive
		if (active)
			src.icon_state = "comp_text_to_music1"
			return
		src.icon_state = "comp_text_to_music"
		return

#undef MIN_TIMING
#undef MAX_TIMING

#undef MAX_NOTE_INPUT
#undef MAX_CONCURRENT_NOTES

#undef CF_EVENT_LENGTH

#undef DELAY_NOTE_MIN
#undef DELAY_NOTE_MAX
#undef DELAY_REST_MIN
#undef DELAY_REST_MAX

#undef DF_EVENT_LENGTH
#undef DF_DELIMITER
#undef DF_BOUND_LOWER
#undef DF_BOUND_UPPER
#undef DF_REST
#undef DF_SET_TIMING
#undef DF_OFFSET_DYNAMIC
#undef DF_OFFSET_NOTE
#undef DF_OFFSET_DELAY
#undef DF_OFFSET_REST
#undef DF_OFFSET_OCTAVE
#undef DF_NOTE_TYPE_AMOUNT
#undef DF_DYNAMIC_MIN
#undef DF_DYNAMIC_MAX
#undef DF_FORBIDDEN_CHAR
#undef DF_BASE88

#undef STANDARD_INSTRUMENT_PATH
#undef MAX_ERROR_MESSAGES
