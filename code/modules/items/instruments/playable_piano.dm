/obj/item/piano_key //for resetting the piano in case of issues / annoying music
	name = "piano key"
	desc = "Designed to interface the player piano."
	icon = 'icons/obj/instruments.dmi'
	icon_state = "piano_key"
	w_class = W_CLASS_TINY

#define MIN_TIMING 0.1
#define MAX_TIMING 0.5

#define MAX_NOTE_INPUT 1920
#define MAX_CONCURRENT_NOTES 8

#define DELAY_NOTE_MIN 0
#define DELAY_NOTE_MAX 100
#define DELAY_REST_MIN 1
#define DELAY_REST_MAX 1000

TYPEINFO(/obj/player_piano)
	mats = 20

/obj/player_piano //this is the big boy im pretty sure all this code is garbage
	name = "player piano"
	desc = "A piano that can take raw text and turn it into music! The future is now!"
	icon = 'icons/obj/instruments.dmi'
	icon_state = "player_piano"
	density = 1
	anchored = ANCHORED
	var/timing = 0.5 //values from 0.25 to 0.5 please
	var/items_claimed = 0 //set to 1 when items are claimed
	var/is_looping = 0 //is the piano looping? 0 is no, 1 is yes, 2 is never more looping
	var/panel_exposed = 0 //0 by default
	var/is_busy = 0 //stops people from messing about with it when its working
	var/is_stored = FALSE //same as is_busy, but for automatic linking
	var/song_length = 0 //the number of notes in the song
	var/curr_note = 0 //what note is the song on?
	var/list/note_input = "" //where input is stored
	var/list/piano_notes = list() //after we break it up into chunks
	var/list/note_volumes = list() //list of volumes as nums (20,30,40,50,60)
	var/list/note_octaves = list() //list of octaves as nums (3-5)
	var/list/note_names = list() //a,b,c,d,e,f,g,r
	var/list/note_accidentals = list() //(s)harp,b(flat),N(none)
	var/list/note_delays = list() // delay is measured as a multiple of timing
	var/list/compiled_notes = list() //holds our compiled filenames for the note
	var/list/linked_pianos = list() //list that stores our linked pianos, including the main one

	New()
		..()
		if (!items_claimed)
			src.desc += " The free user essentials box is untouched!" //jank
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "play", PROC_REF(mechcompPlay))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set notes", PROC_REF(mechcompNotes))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set timing", PROC_REF(mechcompTiming))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "reset", PROC_REF(reset_piano))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Start Storing Pianos", PROC_REF(start_storing_pianos))

	// requires it's own proc because else the mechcomp input will be taken as first argument of ready_piano()
	proc/mechcompPlay(var/datum/mechanicsMessage/input)
		ready_piano()

	proc/mechcompNotes(var/datum/mechanicsMessage/input)
		if (input.signal)
			set_notes(input.signal)

	proc/mechcompTiming(var/datum/mechanicsMessage/input)
		var/new_timing = text2num(input.signal)
		if (new_timing)
			set_timing(new_timing)

	attackby(obj/item/W, mob/user) //this one is big and sucks, where all of our key and construction stuff is
		if (istype(W, /obj/item/piano_key)) //piano key controls
			var/mode_sel = input("Which do you want to do?", "Piano Control") as null|anything in list("Reset Piano", "Toggle Looping", "Adjust Timing")

			switch(mode_sel)
				if ("Reset Piano") //reset piano B)
					reset_piano()
					src.visible_message(SPAN_ALERT("[user] sticks \the [W] into a slot on \the [src] and twists it!"))
					return

				if ("Toggle Looping") //self explanatory, sets whether or not the piano should be looping
					if (is_looping == 0)
						is_looping = 1
					else if (is_looping == 1)
						is_looping = 0
					else
						src.visible_message(SPAN_ALERT("[user] tries to stick \the [W] into a slot on \the [src], but it doesn't seem to want to fit."))
						return
					src.visible_message(SPAN_ALERT("[user] sticks \the [W] into a slot on \the [src] and twists it! \The [src] seems different now."))

				if ("Adjust Timing") //adjusts tempo
					var/time_sel = input("Input a custom tempo from 0.25 to 0.5 BPS", "Tempo Control") as num
					if (!src.set_timing(time_sel))
						src.visible_message(SPAN_ALERT(">The mechanical workings of [src] emit a horrible din for several seconds before \the [src] shuts down."))
						return
					src.visible_message(SPAN_ALERT("[user] sticks \the [W] into a slot on \the [src] and twists it! \The [src] rumbles indifferently."))

		else if (isscrewingtool(W)) //unanchoring piano
			playsound(user, 'sound/items/Screwdriver2.ogg', 65, TRUE)
			user.show_text("You begin to [src.anchored ? "loosen" : "tighten"] the piano's castors.", "blue")
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(toggle_castors), list(user), W.icon, W.icon_state, null, INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
			return

		else if (ispryingtool(W)) //prying off panel
			if (is_busy)
				boutput(user, "You can't do that while the piano is running!")
				return
			if (panel_exposed == 0)
				user.visible_message("[user] starts prying off the piano's maintenance panel...", "You begin to pry off the maintenance panel...")
				if (!do_after(user, 3 SECONDS) || panel_exposed != 0)
					return
				playsound(user, 'sound/items/Crowbar.ogg', 65, TRUE)
				user.visible_message("[user] prys off the piano's maintenance panel.","You pry off the maintenance panel.")
				var/obj/item/sheet/wood/panel = new(get_turf(user))
				panel.amount = 1
				panel_exposed = 1
				UpdateIcon()
			else
				boutput(user, "There's nothing to pry off of \the [src].")

		else if (istype(W, /obj/item/sheet/wood) && W.amount > 0) //replacing panel
			var/obj/item/sheet/wood/wood = W
			if (panel_exposed == 1 && !is_busy && !is_stored)
				user.visible_message("[user] starts replacing the piano's maintenance panel...", "You start replacing the piano's maintenance panel...")
				if (!do_after(user, 3 SECONDS) || panel_exposed != 1)
					return
				playsound(user, 'sound/items/Deconstruct.ogg', 65, TRUE)
				user.visible_message("[user] replaces the maintenance panel!", "You replace the maintenance panel!")
				panel_exposed = 0
				UpdateIcon(0)
				wood.change_stack_amount(-1)

		else if (issnippingtool(W)) //turning off looping... forever!
			if (is_looping == 2)
				boutput(user, "There's no wires to snip!")
				return
			user.visible_message(SPAN_ALERT("[user] looks for the looping control wire..."), "You look for the looping control wire...")
			if (!do_after(user, 7 SECONDS) || is_looping == 2)
				return
			is_looping = 2
			playsound(user, 'sound/items/Wirecutter.ogg', 65, TRUE)
			user.visible_message(SPAN_ALERT("[user] snips the looping control wire!"), "You snip the looping control wire!")

		else if (ispulsingtool(W)) //resetting piano the hard way
			if (panel_exposed == 0)
				..()
				return
			user.visible_message(SPAN_ALERT("[user] starts pulsing random wires in the piano."), "You start pulsing random wires in the piano.")
			if (!do_after(user, 3 SECONDS))
				return
			user.visible_message(SPAN_ALERT("[user] pulsed a bunch of wires in the piano!"), "You pulsed some wires in the piano!")
			reset_piano()
		else
			..()

	proc/toggle_castors(mob/user)
		user.show_text("You [src.anchored ? "loosen" : "secure"] the piano's castors.", "blue")
		if (src.anchored)
			SEND_SIGNAL(src, COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
		src.anchored = !src.anchored

	attack_hand(var/mob/user)
		if (is_busy || is_stored)
			src.visible_message(SPAN_ALERT("\The [src] emits an angry beep!"))
			return
		var/mode_sel = input("Which mode would you like?", "Mode Select") as null|anything in list("Choose Notes", "Play Song")
		if (mode_sel == "Choose Notes")
			var/given_notes = input("Write out the notes you want to be played.", "Composition Menu", note_input)
			if (!set_notes(given_notes))//still room to get long piano songs in, but not too crazy
				src.visible_message(SPAN_ALERT("\The [src] makes an angry whirring noise and shuts down."))
			return
		else if (mode_sel == "Play Song")
			ready_piano()
			return
		else //just in case
			return

	mouse_drop(obj/player_piano/piano)
		if (!istype(usr, /mob/living))
			return
		if (usr.stat)
			return
		if (!allowChange(usr))
			boutput(usr, SPAN_ALERT("You can't link pianos without a multitool!"))
			return
		ENSURE_TYPE(piano)
		if (!piano)
			return
		if (is_pulser_auto_linking(usr))
			boutput(usr, SPAN_ALERT("You can't link pianos manually while auto-linking!"))
			return
		if (piano == src)
			boutput(usr, SPAN_ALERT("You can't link a piano with itself!"))
			return
		if (piano.is_busy || src.is_busy)
			boutput(usr, SPAN_ALERT("You can't link a busy piano!"))
			return
		if (piano.panel_exposed && panel_exposed)
			usr.visible_message("[usr] links the pianos.", "You link the pianos!")
			src.add_piano(piano)
			piano.add_piano(src)

	disposing() //just to clear up ANY funkiness
		reset_piano(1)
		..()

	proc/allowChange(var/mob/M) //copypasted from mechanics code because why do something someone else already did better
		if(hasvar(M, "l_hand") && ispulsingtool(M:l_hand)) return 1
		if(hasvar(M, "r_hand") && ispulsingtool(M:r_hand)) return 1
		if(hasvar(M, "module_states"))
			for(var/atom/A in M:module_states)
				if(ispulsingtool(A))
					return 1
		return 0

	proc/is_pulser_auto_linking(var/mob/M)
		if(ispulsingtool(M.l_hand) && SEND_SIGNAL(M.l_hand, COMSIG_IS_PLAYER_PIANO_AUTO_LINKER_ACTIVE)) return TRUE
		if(ispulsingtool(M.r_hand) && SEND_SIGNAL(M.r_hand, COMSIG_IS_PLAYER_PIANO_AUTO_LINKER_ACTIVE)) return TRUE
		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/silicon_user = M
			for(var/atom/A in silicon_user.module_states)
				if(ispulsingtool(A) && SEND_SIGNAL(A, COMSIG_IS_PLAYER_PIANO_AUTO_LINKER_ACTIVE))
					return TRUE
		if(istype(M, /mob/living/silicon/hivebot))
			var/mob/living/silicon/hivebot/silicon_user = M
			for(var/atom/A in silicon_user.module_states)
				if(ispulsingtool(A) && SEND_SIGNAL(A, COMSIG_IS_PLAYER_PIANO_AUTO_LINKER_ACTIVE))
					return TRUE
		return FALSE

	proc/clean_input() //breaks our big input string into chunks
		src.is_busy = 1
		src.piano_notes = list()
//		src.visible_message(SPAN_NOTICE("\The [src] starts humming and rattling as it processes!"))
		var/list/split_input = splittext("[note_input]", "|")
		if (length(split_input) > MAX_NOTE_INPUT)
			return FALSE
		for (var/string in split_input)
			if (string)
				piano_notes += string
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
				src.visible_message(SPAN_ALERT("\The [src] makes a loud grinding noise, followed by a boop and a beep!"))
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

	proc/ready_piano(var/is_linked) //final checks to make sure stuff is right, gets notes into a compiled form for easy playsounding
		if (is_busy || is_stored)
			return
		is_busy = 1
		if (note_volumes.len + note_octaves.len - note_names.len - note_accidentals.len)
			src.visible_message(SPAN_ALERT("\The [src] makes a grumpy ratchetting noise and shuts down!"))
			is_busy = 0
			UpdateIcon(0)
		song_length = length(note_names)
		compiled_notes = list()
		for (var/i = 1, i <= note_names.len, i++)
			var/string = lowertext("[note_names[i]][note_accidentals[i]][note_octaves[i]]")
			compiled_notes += string
		for (var/i = 1, i <= compiled_notes.len, i++)
			var/string = "sound/musical_instruments/piano/notes/"
			string += "[compiled_notes[i]].ogg"
			if (!(string in soundCache))
				src.visible_message(SPAN_ALERT("\The [src] makes an atrocious racket and beeps [i] times."))
				is_busy = 0
				UpdateIcon(0)
				return
		src.visible_message(SPAN_NOTICE("\The [src] starts playing music!"))
		UpdateIcon(1)
		if (is_linked)
			play_notes(0)
			return
		play_notes(1)

	proc/play_notes(var/is_master) //how notes are handled, using while and spawn to set a very strict interval, solo piano process loop was too variable to work for music
		var/concurrent_notes_played = 0
		if (length(linked_pianos) > 0 && is_master)
			for (var/obj/player_piano/p in linked_pianos)
				SPAWN(0)
					p.ready_piano(1)
		while (curr_note <= song_length)
			curr_note++
			if (curr_note > song_length)
				if (is_looping == 1)
					curr_note = 0
					play_notes()
					return
				is_busy = 0
				curr_note = 0
				src.visible_message(SPAN_NOTICE("\The [src] stops playing music."))
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "musicStopped")
				UpdateIcon(0)
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

	proc/set_notes(var/given_notes)
		if (src.is_busy || src.is_stored)
			return FALSE

		src.note_input = given_notes

		if (!src.clean_input())
			src.note_input = ""
			src.is_busy = FALSE
			return FALSE

		src.build_notes(src.piano_notes)

		return TRUE

	proc/set_timing(var/time_sel)
		if (is_busy || is_stored)
			return FALSE
		if (time_sel < MIN_TIMING || time_sel > MAX_TIMING)
			return FALSE
		src.timing = time_sel
		return TRUE

	proc/reset_piano(var/disposing) //so i dont have to have duplicate code for multiool pulsing and piano key
		src.visible_message(SPAN_NOTICE("\The [src] grumbles and shuts down completely."))
		if (is_looping != 2 || disposing)
			is_looping = 0
		if (disposing)
			is_stored = FALSE
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
		linked_pianos = list()
		note_delays = list()
		UpdateIcon(0)

	update_icon(var/active) //1: active, 0: inactive
		if (panel_exposed)
			icon_state = "player_piano_open"
			return
		if (active)
			icon_state = "player_piano_playing"
			return
		icon_state = "player_piano"
		return

	proc/add_piano(var/obj/player_piano/p)
		var/piano_id = "\ref[p]"
		for (var/obj/player_piano in linked_pianos)
			var/other_piano_id = "\ref[player_piano]"
			if (other_piano_id == piano_id)
				linked_pianos -= p
		linked_pianos += p

	verb/item_claim()
		set name = "Claim Items"
		set src in oview(1)
		set category = "Local"
		if (items_claimed)
			src.visible_message("\The [src] has nothing in its item box to take! Drat!")
			return
		new /obj/item/piano_key(get_turf(src))
		new /obj/item/paper/book/from_file/player_piano(get_turf(src))
		items_claimed = 1
		src.visible_message("\The [src] spills out a key and a booklet! Nifty!")
		src.desc = "A piano that can take raw text and turn it into music! The future is now! The free user essentials box has been raided!" //jaaaaaaaank

	proc/start_storing_pianos(obj/item/I, mob/user)
		if (src.is_busy)
			boutput(user, SPAN_ALERT("Can't link a busy piano!"))
			return
		if (!src.panel_exposed)
			boutput(user, SPAN_ALERT("Can't link without an exposed panel!"))
			return
		if (length(src.linked_pianos))
			boutput(user, SPAN_ALERT("Can't link an already linked piano!"))
			return
		if (src.is_stored)
			boutput(user, SPAN_ALERT("Another device has already stored that piano!"))
			return
		I.AddComponent(/datum/component/player_piano_auto_linker, src, user)

	was_deconstructed_to_frame(mob/user)
		. = ..()
		src.reset_piano()

#undef MIN_TIMING
#undef MAX_TIMING

#undef MAX_NOTE_INPUT
#undef MAX_CONCURRENT_NOTES

#undef DELAY_NOTE_MIN
#undef DELAY_NOTE_MAX
#undef DELAY_REST_MIN
#undef DELAY_REST_MAX
