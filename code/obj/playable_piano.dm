/obj/item/piano_key //for resetting the piano in case of issues / annoying music
	name = "piano key"
	desc = "Designed to interface the player piano."
	icon = 'icons/obj/instruments.dmi'
	icon_state = "piano_key"
	w_class = W_CLASS_TINY

#define MIN_TIMING 0.25
#define MAX_TIMING 0.5
#define MAX_NOTE_INPUT 15360

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
	var/song_length = 0 //the number of notes in the song
	var/curr_note = 0 //what note is the song on?
	var/list/note_input = "" //where input is stored
	var/list/piano_notes = list() //after we break it up into chunks
	var/list/note_volumes = list() //list of volumes as nums (20,30,40,50,60)
	var/list/note_octaves = list() //list of octaves as nums (3-5)
	var/list/note_names = list() //a,b,c,d,e,f,g,r
	var/list/note_accidentals = list() //(s)harp,b(flat),N(none)
	var/list/compiled_notes = list() //holds our compiled filenames for the note
	var/list/linked_pianos = list() //list that stores our linked pianos, including the main one

	New()
		..()
		if (!items_claimed)
			src.desc += " The free user essentials box is untouched!" //jank
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "play", .proc/mechcompPlay)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set notes", .proc/mechcompNotes)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set timing", .proc/mechcompTiming)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "reset", .proc/reset_piano)

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
					src.visible_message("<span class='alert'>[user] sticks \the [W] into a slot on \the [src] and twists it!</span>")
					return

				if ("Toggle Looping") //self explanatory, sets whether or not the piano should be looping
					if (is_looping == 0)
						is_looping = 1
					else if (is_looping == 1)
						is_looping = 0
					else
						src.visible_message("<span class='alert'>[user] tries to stick \the [W] into a slot on \the [src], but it doesn't seem to want to fit.")
						return
					src.visible_message("<span class='alert'>[user] sticks \the [W] into a slot on \the [src] and twists it! \The [src] seems different now.")

				if ("Adjust Timing") //adjusts tempo
					var/time_sel = input("Input a custom tempo from 0.25 to 0.5 BPS", "Tempo Control") as num
					if (!src.set_timing(time_sel))
						src.visible_message("<span class='alert'>The mechanical workings of [src] emit a horrible din for several seconds before \the [src] shuts down.")
						return
					src.visible_message("<span class='alert'>[user] sticks \the [W] into a slot on \the [src] and twists it! \The [src] rumbles indifferently.")

		else if (isscrewingtool(W)) //unanchoring piano
			if (anchored)
				user.visible_message("[user] starts loosening the piano's castors...", "You start loosening the piano's castors...")
				if (!do_after(user, 3 SECONDS) || anchored != 1)
					return
				playsound(user, 'sound/items/Screwdriver2.ogg', 65, 1)
				src.anchored = UNANCHORED
				SEND_SIGNAL(src, COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
				user.visible_message("[user] loosens the piano's castors!", "You loosen the piano's castors!")
				return
			else
				user.visible_message("[user] starts tightening the piano's castors...", "You start tightening the piano's castors...")
				if (!do_after(user, 3 SECONDS) || anchored != 0)
					return
				playsound(user, 'sound/items/Screwdriver2.ogg', 65, 1)
				src.anchored = ANCHORED
				user.visible_message("[user] tightens the piano's castors!", "You tighten the piano's castors!")
				return

		else if (ispryingtool(W)) //prying off panel
			if (is_busy)
				boutput(user, "You can't do that while the piano is running!")
				return
			if (panel_exposed == 0)
				user.visible_message("[user] starts prying off the piano's maintenance panel...", "You begin to pry off the maintenance panel...")
				if (!do_after(user, 3 SECONDS) || panel_exposed != 0)
					return
				playsound(user, 'sound/items/Crowbar.ogg', 65, 1)
				user.visible_message("[user] prys off the piano's maintenance panel.","You pry off the maintenance panel.")
				var/obj/item/plank/P = new(get_turf(user))
				P.name = "Piano Maintenance Panel"
				P.desc = "A cover for the internal workings of a piano. Better not lose it."
				panel_exposed = 1
				UpdateIcon()
			else
				boutput(user, "There's nothing to pry off of \the [src].")

		else if (istype(W, /obj/item/plank)) //replacing panel
			if (panel_exposed == 1 && W.name != "wooden plank" && !is_busy)
				user.visible_message("[user] starts replacing the piano's maintenance panel...", "You start replacing the piano's maintenance panel...")
				if (!do_after(user, 3 SECONDS) || panel_exposed != 1)
					return
				playsound(user, 'sound/items/Deconstruct.ogg', 65, 1)
				user.visible_message("[user] replaces the maintenance panel!", "You replace the maintenance panel!")
				panel_exposed = 0
				UpdateIcon(0)
				qdel(W)

		else if (issnippingtool(W)) //turning off looping... forever!
			if (is_looping == 2)
				boutput(user, "There's no wires to snip!")
				return
			user.visible_message("<span class='alert'>[user] looks for the looping control wire...</span>", "You look for the looping control wire...")
			if (!do_after(user, 7 SECONDS) || is_looping == 2)
				return
			is_looping = 2
			playsound(user, 'sound/items/Wirecutter.ogg', 65, 1)
			user.visible_message("<span class='alert'>[user] snips the looping control wire!</span>", "You snip the looping control wire!")

		else if (ispulsingtool(W)) //resetting piano the hard way
			if (panel_exposed == 0)
				..()
				return
			user.visible_message("<span class='alert'>[user] starts pulsing random wires in the piano.</span>", "You start pulsing random wires in the piano.")
			if (!do_after(user, 3 SECONDS))
				return
			user.visible_message("<span class='alert'>[user] pulsed a bunch of wires in the piano!</span>", "You pulsed some wires in the piano!")
			reset_piano()
		else
			..()

	attack_hand(var/mob/user)
		if (is_busy)
			src.visible_message("<span class='alert'>\The [src] emits an angry beep!</span>")
			return
		var/mode_sel = input("Which mode would you like?", "Mode Select") as null|anything in list("Choose Notes", "Play Song")
		if (mode_sel == "Choose Notes")
			var/given_notes = input("Write out the notes you want to be played.", "Composition Menu", note_input)
			if (!set_notes(given_notes))//still room to get long piano songs in, but not too crazy
				src.visible_message("<span class='alert'>\The [src] makes an angry whirring noise and shuts down.</span>")
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
			boutput(usr, "<span class='alert'>You can't link pianos without a multitool!</span>")
			return
		ENSURE_TYPE(piano)
		if (!piano)
			return
		if (piano == src)
			boutput(usr, "<span class='alert'>You can't link a piano with itself!</span>")
			return
		if (piano.is_busy || src.is_busy)
			boutput(usr, "<span class='alert'>You can't link a busy piano!</span>")
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

	proc/clean_input() //breaks our big input string into chunks
		is_busy = 1
		piano_notes = list()
//		src.visible_message("<span class='notice'>\The [src] starts humming and rattling as it processes!</span>")
		var/list/split_input = splittext("[note_input]", "|")
		for (var/string in split_input)
			if (string)
				piano_notes += string
		is_busy = 0

	proc/build_notes(var/list/piano_notes) //breaks our chunks apart and puts them into lists on the object
		is_busy = 1
		note_volumes = list()
		note_octaves = list()
		note_names = list()
		note_accidentals = list()

		for (var/string in piano_notes)
			var/list/curr_notes = splittext("[string]", ",")
			if (length(curr_notes) < 4) // Music syntax not followed
				break
			if (lowertext(curr_notes[2]) == "b") // Correct enharmonic pitches to conform to music syntax; transforming flats to sharps
				if (lowertext(curr_notes[1]) == "a")
					curr_notes[1] = "g"
				else
					curr_notes[1] = ascii2text(text2ascii(curr_notes[1]) - 1)
			note_names += curr_notes[1]
			switch(lowertext(curr_notes[4]))
				if ("r")
					curr_notes[4] = "r"
			note_octaves += curr_notes[4]
			switch(lowertext(curr_notes[2]))
				if ("s", "b")
					curr_notes[2] = "-"
				if ("n")
					curr_notes[2] = ""
				if ("r")
					curr_notes[2] = "r"
			note_accidentals += curr_notes[2]
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
			note_volumes += curr_notes[3]
		is_busy = 0

	proc/ready_piano(var/is_linked) //final checks to make sure stuff is right, gets notes into a compiled form for easy playsounding
		if (is_busy)
			return
		is_busy = 1
		if (note_volumes.len + note_octaves.len - note_names.len - note_accidentals.len)
			src.visible_message("<span class='alert'>\The [src] makes a grumpy ratchetting noise and shuts down!</span>")
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
				src.visible_message("<span class='alert'>\The [src] makes an atrocious racket and beeps [i] times.</span>")
				is_busy = 0
				UpdateIcon(0)
				return
		src.visible_message("<span class='notice'>\The [src] starts playing music!</span>")
		UpdateIcon(1)
		if (is_linked)
			play_notes(0)
			return
		play_notes(1)

	proc/play_notes(var/is_master) //how notes are handled, using while and spawn to set a very strict interval, solo piano process loop was too variable to work for music
		if (linked_pianos.len > 0 && is_master)
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
				src.visible_message("<span class='notice'>\The [src] stops playing music.</span>")
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "musicStopped")
				UpdateIcon(0)
				return
			sleep((timing * 10)) //to get delay into 10ths of a second
			if (!curr_note) // else we get runtimes when the piano is reset while playing
				return
			var/sound_name = "sound/musical_instruments/piano/notes/[compiled_notes[curr_note]].ogg"
			playsound(src, sound_name, note_volumes[curr_note],0,10,0)

	proc/set_notes(var/given_notes)
		if (is_busy)
			return FALSE
		if (length(note_input) > MAX_NOTE_INPUT)
			return FALSE
		src.note_input = given_notes
		clean_input()
		build_notes(piano_notes)
		return TRUE

	proc/set_timing(var/time_sel)
		if (is_busy)
			return FALSE
		if (time_sel < MIN_TIMING || time_sel > MAX_TIMING)
			return FALSE
		src.timing = time_sel
		return TRUE

	proc/reset_piano(var/disposing) //so i dont have to have duplicate code for multiool pulsing and piano key
		src.visible_message("<span class='notice'>\The [src] grumbles and shuts down completely.</span>")
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
		linked_pianos = list()
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

#undef MIN_TIMING
#undef MAX_TIMING
#undef MAX_NOTE_INPUT
