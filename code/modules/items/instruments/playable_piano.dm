/obj/item/piano_key //for resetting the piano in case of issues / annoying music
	name = "piano key"
	desc = "Designed to interface the player piano."
	icon = 'icons/obj/instruments.dmi'
	icon_state = "piano_key"
	w_class = W_CLASS_TINY

TYPEINFO(/obj/player_piano)
	mats = 20

/obj/player_piano //this is the big boy im pretty sure all this code is garbage
	name = "player piano"
	desc = "A piano that can take raw text and turn it into music! The future is now!"
	icon = 'icons/obj/instruments.dmi'
	icon_state = "player_piano"
	density = 1
	anchored = ANCHORED
	var/items_claimed = 0 //set to 1 when items are claimed
	var/panel_exposed = 0 //0 by default
	var/datum/text_to_music/player_piano/music_player = null

	New()
		..()

		src.music_player = new(src)

		if (!items_claimed)
			src.desc += " The free user essentials box is untouched!" //jank
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "play", PROC_REF(mechcompPlay))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set notes", PROC_REF(mechcompNotes))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set timing", PROC_REF(mechcompTiming))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "stop", PROC_REF(mechcompStop))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "reset", PROC_REF(mechcompReset))

		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "start autolinking", PROC_REF(mechcompConfigStartAutolinking))

	// requires it's own proc because else the mechcomp input will be taken as first argument of make_ready()
	proc/mechcompPlay(var/datum/mechanicsMessage/input)
		src.music_player.make_ready()

	proc/mechcompNotes(var/datum/mechanicsMessage/input)
		if (input.signal)
			src.music_player.set_notes(input.signal)

	proc/mechcompTiming(var/datum/mechanicsMessage/input)
		var/new_timing = text2num(input.signal)
		if (new_timing)
			src.music_player.set_timing(new_timing)

	proc/mechcompStop(var/datum/mechanicsMessage/input)
		if (src.music_player.is_busy)
			src.music_player.is_stop_requested = TRUE

	proc/mechcompReset(var/datum/mechanicsMessage/input)
		src.music_player.reset(FALSE)

	proc/mechcompConfigStartAutolinking(obj/item/W as obj, mob/user as mob)
		src.music_player.start_autolinking(W, user)

	attackby(obj/item/W, mob/user) //this one is big and sucks, where all of our key and construction stuff is
		if (istype(W, /obj/item/piano_key)) //piano key controls
			var/mode_sel = tgui_input_list(
				user,
				"Which do you want to do?",
				"Piano Control",
				list("Reset Piano", "Toggle Looping", "Adjust Timing", "Toggle Rest on Unavailable Notes")
			)

			switch(mode_sel)
				if ("Stop Piano") // stops the piano without losing stored data
					src.music_player.is_stop_requested = TRUE

				if ("Reset Piano") //reset piano B)
					src.music_player.reset()
					src.visible_message(SPAN_ALERT("[user] sticks \the [W] into a slot on \the [src] and twists it!"))
					return

				if ("Toggle Looping") //self explanatory, sets whether or not the piano should be looping
					if (src.music_player.is_looping == 0)
						src.music_player.is_looping = 1
					else if (src.music_player.is_looping == 1)
						src.music_player.is_looping = 0
					else
						src.visible_message(SPAN_ALERT("[user] tries to stick \the [W] into a slot on \the [src], but it doesn't seem to want to fit."))
						return
					src.visible_message(SPAN_ALERT("[user] sticks \the [W] into a slot on \the [src] and twists it! \The [src] seems different now."))

				if ("Adjust Timing") //adjusts tempo
					var/time_sel = tgui_input_text(
						user,
						"Input a new timing between [src.music_player.MIN_TIMING] and [src.music_player.MAX_TIMING] seconds.",
						"Tempo Control",
						src.timing
					)
					time_sel = text2num(time_sel)
					if (!time_sel || !src.music_player.set_timing(time_sel))
						src.visible_message(SPAN_ALERT(">The mechanical workings of [src] emit a horrible din for several seconds before \the [src] shuts down."))
						return
					src.visible_message(SPAN_ALERT("[user] sticks \the [W] into a slot on \the [src] and twists it! \The [src] rumbles indifferently."))

				if ("Toggle Rest on Unavailable Notes")
					src.music_player.rest_on_notes_not_in_cache = !src.music_player.rest_on_notes_not_in_cache
					boutput(user, SPAN_NOTICE("Set to <b>[src.music_player.rest_on_notes_not_in_cache ? "" : "not"] resting</b> on unavailable notes."))

		else if (isscrewingtool(W)) //unanchoring piano
			playsound(user, 'sound/items/Screwdriver2.ogg', 65, TRUE)
			user.show_text("You begin to [src.anchored ? "loosen" : "tighten"] the piano's castors.", "blue")
			SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(toggle_castors), list(user), W.icon, W.icon_state, null, INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT)
			return

		else if (ispryingtool(W)) //prying off panel
			if (src.music_player.is_busy)
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
			if (panel_exposed == 1 && !src.music_player.is_busy && !src.music_player.is_stored)
				user.visible_message("[user] starts replacing the piano's maintenance panel...", "You start replacing the piano's maintenance panel...")
				if (!do_after(user, 3 SECONDS) || panel_exposed != 1)
					return
				playsound(user, 'sound/items/Deconstruct.ogg', 65, TRUE)
				user.visible_message("[user] replaces the maintenance panel!", "You replace the maintenance panel!")
				panel_exposed = 0
				UpdateIcon(0)
				wood.change_stack_amount(-1)

		else if (issnippingtool(W)) //turning off looping... forever!
			if (src.music_player.is_looping == 2)
				boutput(user, "There's no wires to snip!")
				return
			user.visible_message(SPAN_ALERT("[user] looks for the looping control wire..."), "You look for the looping control wire...")
			if (!do_after(user, 7 SECONDS) || src.music_player.is_looping == 2)
				return
			src.music_player.is_looping = 2
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
			src.music_player.reset()
		else
			..()

	proc/toggle_castors(mob/user)
		user.show_text("You [src.anchored ? "loosen" : "secure"] the piano's castors.", "blue")
		if (src.anchored)
			SEND_SIGNAL(src, COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
		src.anchored = !src.anchored

	attack_hand(var/mob/user)
		if (src.music_player.is_busy || src.music_player.is_stored)
			src.visible_message(SPAN_ALERT("\The [src] emits an angry beep!"))
			return
		var/mode_sel = tgui_alert(user, "Which mode would you like?", "Mode Select", list("Choose Notes", "Play Song"))
		if (mode_sel == "Choose Notes")
			var/given_notes = tgui_input_text(user, "Write out the notes you want to be played.", "Composition Menu", src.music_player.note_input)
			if (!src.music_player.set_notes(given_notes))//still room to get long piano songs in, but not too crazy
				src.visible_message(SPAN_ALERT("\The [src] makes an angry whirring noise and shuts down."))
			return
		else if (mode_sel == "Play Song")
			src.music_player.make_ready()
			return
		else //just in case
			return

	disposing() //just to clear up ANY funkiness
		src.music_player.reset(1)
		..()

	update_icon(var/active) //1: active, 0: inactive
		if (panel_exposed)
			icon_state = "player_piano_open"
			return
		if (active)
			icon_state = "player_piano_playing"
			return
		icon_state = "player_piano"
		return

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

	was_deconstructed_to_frame(mob/user)
		. = ..()
		src.music_player.reset()
