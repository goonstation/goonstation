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

TYPEINFO(/obj/item/mechanics/text_to_music)
	mats = list("metal"      = 20,
				"conductive" = 10,
				"crystal"    = 10)

/obj/item/mechanics/text_to_music // modified from playable_piano.dm and PR #21051 (Player Piano Notes Rework V2)
	name = "Text to Music Component"
	desc = "Converts text to music."
	icon_state = "comp_text_to_music"
	cabinet_banned = TRUE // no walking music machines
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
	var/list/error_messages = list()
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

		src.instrument_sound_path = STANDARD_INSTRUMENT_PATH(src.instrument_name)

		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "play", PROC_REF(mechcompPlay))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set notes", PROC_REF(mechcompNotes))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set timing", PROC_REF(mechcompTiming))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set instrument", PROC_REF(mechcompInstrument))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "stop", PROC_REF(mechcompStop))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "reset", PROC_REF(mechcompReset))

		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "play", PROC_REF(mechcompConfigPlay))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set notes", PROC_REF(mechcompConfigNotes))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set timing", PROC_REF(mechcompConfigTiming))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set instrument", PROC_REF(mechcompConfigInstrument))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "stop", PROC_REF(mechcompConfigStop))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "reset", PROC_REF(mechcompConfigReset))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "view errors", PROC_REF(mechcompConfigViewErrors))

	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += "<br>[SPAN_NOTICE("Instrument: [src.instrument_name] | Timing: [src.timing] | Has Notes: [length(src.note_input) ? "Yes" : "No"]")]"

	// requires it's own proc because else the mechcomp input will be taken as first argument of ready_piano()
	proc/mechcompPlay(var/datum/mechanicsMessage/input)
		if (src.anchored)
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

	proc/mechcompStop(var/datum/mechanicsMessage/input)
		if (src.is_busy)
			src.is_stop_requested = TRUE

	proc/mechcompReset(var/datum/mechanicsMessage/input)
		src.reset_piano(0)

	// ------------------------------------------------

	proc/mechcompConfigPlay(obj/item/W as obj, mob/user as mob)
		if (src.anchored)
			src.ready_piano()

	proc/mechcompConfigNotes(obj/item/W as obj, mob/user as mob)
		var/given_notes = tgui_input_text(user, "Input notes to play.", "Set Notes", src.note_input)
		src.set_notes(given_notes)

	proc/mechcompConfigTiming(obj/item/W as obj, mob/user as mob)
		// `tgui_input_number` behaves oddly when dealing with floats
		// so I'm using the text input instead, unless timing is counted is centiseconds
		var/new_timing = tgui_input_text(user, "Input a new timing between [MIN_TIMING] and [MAX_TIMING] seconds.", "Set Timing", src.timing)
		new_timing = text2num(new_timing)
		if (new_timing)
			src.set_timing(new_timing)

	proc/mechcompConfigInstrument(obj/item/W as obj, mob/user as mob)
		var/new_instrument = tgui_input_list(user, "Input new instrument.", "Set Instrument", src.allow_list, src.instrument_sound_path)
		src.set_instrument(new_instrument)

	proc/mechcompConfigStop(obj/item/W as obj, mob/user as mob)
		if (src.is_busy)
			src.is_stop_requested = TRUE

	proc/mechcompConfigReset(obj/item/W as obj, mob/user as mob)
		src.reset_piano(0)

	proc/mechcompConfigViewErrors(obj/item/W as obj, mob/user as mob)
		if (length(src.error_messages) > 0)
			var/message = jointext(src.error_messages, "<br><hr>")
			tgui_message(user, message, "T2M Error Messages")

	disposing() //just to clear up ANY funkiness
		reset_piano(1)
		..()

	attackby(obj/item/W, mob/user)
		if(iswrenchingtool(W) && src.anchored && src.is_busy)
			src.is_stop_requested = TRUE

		return ..()

	proc/log_error_message(var/error_message)
		src.error_messages.Insert(1, error_message)

		if (length(src.error_messages) > MAX_ERROR_MESSAGES)
			src.error_messages.Cut(MAX_ERROR_MESSAGES + 1, 0)

		animate_flash_color_fill(src,"#ff0000",2, 2)

	proc/clean_input() //breaks our big input string into chunks
		src.is_busy = 1
		src.piano_notes = list()
		var/list/split_input = splittext("[note_input]", "|")
		if (split_input > MAX_NOTE_INPUT)
			return FALSE
		for (var/string in split_input)
			if (string)
				src.piano_notes += string
		src.is_busy = 0
		return TRUE

	proc/build_notes(var/list/piano_notes) //breaks our chunks apart and puts them into lists on the object
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
		src.UpdateIcon(TRUE)
		var/concurrent_notes_played = 0
		while (src.curr_note <= song_length)
			src.curr_note++
			if (src.curr_note > song_length || src.is_stop_requested)
				if (src.is_looping == 1 && !(src.is_stop_requested))
					src.curr_note = 0
					src.play_notes()
					return
				src.is_busy = 0
				src.curr_note = 0
				if (!(src.is_stop_requested))
					SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "musicStopped")
				src.is_stop_requested = FALSE
				src.UpdateIcon(FALSE)
				return
			if (!src.curr_note) // else we get runtimes when the piano is reset while playing
				return

			if (concurrent_notes_played < MAX_CONCURRENT_NOTES && compiled_notes[curr_note] != "rrr")
				var/sound_name = "[src.instrument_sound_path]/[compiled_notes[curr_note]].ogg"
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

		src.note_input = given_notes

		if (!src.clean_input())
			src.note_input = ""
			return FALSE

		src.build_notes(src.piano_notes)

		return TRUE

	proc/set_timing(var/time_sel)
		if (src.is_busy)
			return FALSE
		if (time_sel < MIN_TIMING || time_sel > MAX_TIMING)
			return FALSE
		src.timing = time_sel
		src.tooltip_rebuild = 1
		return TRUE

	proc/set_instrument(var/instrument)
		if (src.is_busy)
			return
		if (instrument in src.allow_list)
			src.instrument_name = instrument
			src.instrument_sound_path = STANDARD_INSTRUMENT_PATH(instrument)
			src.tooltip_rebuild = 1

	proc/reset_piano(var/disposing) //so i dont have to have duplicate code for multiool pulsing and piano key
		src.UpdateIcon(FALSE)
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
		src.is_stop_requested = FALSE
		src.note_delays = list()
		src.tooltip_rebuild = 1

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

#undef DELAY_NOTE_MIN
#undef DELAY_NOTE_MAX
#undef DELAY_REST_MIN
#undef DELAY_REST_MAX

#undef STANDARD_INSTRUMENT_PATH
#undef MAX_ERROR_MESSAGES
