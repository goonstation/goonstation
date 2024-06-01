/mob/living/intangible/brainmob
	//Sort of like a holder mob for brain-triggered assemblies
	name = "brain thing"
	real_name = "brain thing"
	icon = 'icons/obj/items/organs/brain.dmi'
	icon_state = "cool_brain"
	canmove = 0
	nodamage = 1

	var/obj/item/device/brainjar/container = null


	say(var/message)
		message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		if (!message)
			return

		if (reverse_mode) message = reverse_text(message)

		logTheThing(LOG_DIARY, src, ": [message]", "say")

	#ifdef DATALOGGER
		// Jewel's attempted fix for: null.ScanText()
		if (game_stats)
			game_stats.ScanText(message)
	#endif

		if (src.client && src.client.ismuted())
			boutput(src, "You are currently muted and may not speak.")
			return
		var/message_mode = ""
		var/prefix = copytext(message, 1, 2)
		SEND_SIGNAL(src, COMSIG_MOB_SAY, message)
		switch(prefix)
			if("*")
				return src.emote(copytext(message, 2), 1)

			if(";")
				message_mode = "radio"
			else
				message_mode = "local"
		//boutput(world, "DEBUG: Prefix is \"[prefix]\", message mode is: \"[message_mode]\", message is \"[message]\"")
		switch(message_mode)
			if("radio")
				message = copytext(message, 2)
				if(src.container.rad)
					container.rad.talk_into(src, process_language(message), 0, real_name)
				display_message(message, 1)
			if("local")
				display_message(message,0)


	say_quote(var/text)
		var/ending = copytext(text, length(text))

		if (ending == "?") return "wonks, \"[text]\"";
		else if (ending == "!") return "screeches, \"[text]\"";

		return "warbles, \"[text]\"";

	proc/display_message(var/message, var/quiet = 0, var/emote = 0)
		//This will make sure the surroundings can hear what the brain thing has to say
		var/message_range = quiet ? 1 : 7
		var/turf/T = get_turf(src)

		var/list/listening = all_hearers(message_range, T)
		listening |= src

		if(quiet)
			message = "<I>[message]</I>"

		var/rendered = SPAN_SAY("[src.get_heard_name()] [SPAN_MESSAGE("[say_quote(message)]")]")

		for(var/mob/M in listening)
			M.heard_say(src)
			M.show_message(rendered, 2)

		if(!emote)
			var/list/messages = process_language(message)
			for (var/obj/O in (all_view(message_range, T)) | src.container.contents)
				SPAWN(0)
					if (O)
						O.hear_talk(src, messages, src.get_heard_name())

			for (var/client/C)
				if (!C.mob) continue
				if (istype(C.mob, /mob/new_player))
					continue
				var/mob/M = C.mob
				if ((istype(M, /mob/dead/observer) || (iswraith(M) && !M.density) || (istype(M, /mob/living/intangible/brainmob)) && (get_turf(M) in hearers(src))) || ((!isturf(src.loc) && src.loc == M.loc) && !(M in listening) && !istype(M, /mob/dead/target_observer)))
					var/thisR = rendered
					if ((istype(M, /mob/dead/observer)||M.client.holder) && src.mind)
						thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[rendered]</span>"

					if (isobserver(M) && M.client) //if a ghooooost (dead) (and online)
						if (M.client.preferences.local_deadchat || iswraith(M)) //only listening locally (or a wraith)? w/e man dont bold dat
							if (M in range(M.client.view, src))
								M.show_message(thisR, 2)
						else
							if (M in range(M.client.view, src)) //you're not just listening locally and the message is nearby? sweet! bold that sucka brosef
								M.show_message(SPAN_BOLD("[thisR]"), 2) //awwwww yeeeeeah lookat dat bold
							else
								M.show_message(thisR, 2)
					else
						M.show_message(thisR, 2)




	ghostize()
		var/mob/dead/observer/O = ..()
		if(O)
			O.icon = 'icons/obj/items/organs/brain.dmi'
			O.icon_state = "cool_brain"
			O.alpha = 155

		return O
