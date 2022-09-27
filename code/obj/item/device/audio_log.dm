/obj/item/audio_tape
	name = "compact tape"
	desc = "A small audio tape.  You could make some rad mix-tapes with this!"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "recordertape"
	w_class = W_CLASS_TINY
	mats = 3

	var/log_line = 1 //Which line of the log it's on.
	var/max_lines = 100
	var/list/messages = list()
	var/list/speakers = list()

	proc
		add_message(speaker="Unknown",message, continuous)
			if (!speaker || !message)
				return 0

			if (!continuous && (log_line >= max_lines))
				return 0

			log_line++
			messages += "[message]"
			speakers += "[speaker]"
			if (continuous && (log_line > max_lines))
				messages.Cut(1,2)
				speakers.Cut(1,2)
				log_line = length(messages)

			return 1

		get_message(continuous)
			if (log_line > messages.len)
				if (continuous && length(messages))
					log_line = 1
				else
					return null

			return "[speakers.len < log_line ? "Unknown" : speakers[log_line]]|[messages[log_line]]"

		next(continuous)
			if (log_line >= messages.len)
				if (continuous && length(messages))
					log_line = 1
				else
					return 0

			log_line++
			return 1

		reset()
			if (messages)
				messages.len = 0
			else
				messages = list()

			if (speakers)
				speakers.len = 0
			else
				speakers = list()

			src.log_line = 1
			return

		use_percentage()
			if (!messages)
				return 0

			return round((messages.len /  max_lines) * 100)


/obj/item/device/audio_log
	name = "audio log"
	desc = "A fairly spartan recording device."
	icon_state = "recorder"
	uses_multiple_icon_states = 1
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	var/obj/item/audio_tape/tape = null
	var/mode = 0 //1 recording, 2 playing back
	var/max_lines = 60
	var/continuous = 1
	var/list/audiolog_messages = list()
	var/list/audiolog_speakers = list()
	var/self_destruct = 0 //This message will self-destruct in five seconds...
	mats = 4

	//nuclear mode briefing log
	nuke_briefing
		name = "Mission Briefing"
		desc = "The standard for covert mission briefing."
		continuous = 0
		//self_destruct = 1

		New(newloc, var/nuke_area)
			..()
			if(!nuke_area)
				nuke_area = "an unknown area. I think mission control fucked up somewhere."
			src.audiolog_messages += "Your mission this time is simple, team."
			src.audiolog_messages += "NanoTrasen has been causing us significant trouble recently."
			src.audiolog_messages += "You are to detonate their station with a nuclear device."
			src.audiolog_messages += "You must arm the bomb in [nuke_area]. Good luck and god speed."
			src.audiolog_speakers.len = length(src.audiolog_messages)

			if (!src.tape)
				src.tape = new /obj/item/audio_tape(src)

			src.tape.messages = src.audiolog_messages
			src.audiolog_messages = null

			src.tape.speakers = src.audiolog_speakers
			src.audiolog_speakers = null

			return

	//researchstat log #1
	researchstat_log
		name = "Bloody log"
		desc = "There's blood on it."
		continuous = 0

		New(newloc)
			..()
			audiolog_speakers += "Scientist #1"
			src.audiolog_messages += "Earlier today we began research on the Artifact recovered by our exploration team."
			audiolog_speakers += "Scientist #1"
			src.audiolog_messages += "It looks pretty unremarkable by all standards, but we've been getting some very strange readings."
			audiolog_speakers += "Scientist #1"
			src.audiolog_messages += "There seems to be some sort of energy source in it but our scans show nothing."
			audiolog_speakers += "Scientist #1"
			src.audiolog_messages += "When I say nothing, I mean literally nothing. There seems to be nothing AT ALL in it."
			audiolog_speakers += "Scientist #1"
			src.audiolog_messages += "Some crew members have reported strange noises on the station ever since we recovered the artifact, but I'm su---"
			audiolog_speakers += "*static*"
			src.audiolog_messages += "ZZZZZZZZZZZZZZZZZZZZZZZ"
			src.audiolog_speakers.len = length(src.audiolog_messages)
			return

	wjam_office_log
		continuous = 0
		audiolog_messages = list("Must I remind you, Dr. Garriott, that you are under contract?",
								"You weren't there! You didn't see what I-",
								"Your tone is not appreciated.  If you are unable to control yourself I suggest you leave.",
								"In fact, I insist.  Our business is concluded-",
								"Speak with me face to face you son of a gun!",
								"So you can murder me with whatever plague you have engineered in my labs? Using MY funds?",
								"If you are not willing to leave I will have security escort you out, with neither suit nor shuttle to shield you.",
								"Think carefully, Bruce.")
		audiolog_speakers = list("Willard Jam",
								"Dr. Garriott",
								"Willard Jam",
								"Willard Jam",
								"Dr. Garriott",
								"Willard Jam",
								"Willard Jam",
								"Willard Jam")

	wall_mounted
		name = "Mounted Logger"
		desc = "A wall-mounted audio log device."
		max_lines = 30

		attack_hand(mob/user)
			return attack_self(user)

		updateSelfDialog()
			return updateUsrDialog()

	attack_self(mob/user as mob)
		..()
		if (user.stat || user.restrained() || user.lying)
			return
		if ((user.contents.Find(src) || user.contents.Find(src.master) || BOUNDS_DIST(src, user) == 0 && istype(src.loc, /turf)))
			src.add_dialog(user)

			var/dat = "<TT><b>Audio Logger</b><br>"
			if (src.tape)
				dat += "Memory [src.tape.use_percentage()]% Full -- <a href='byond://?src=\ref[src];command=eject'>Eject</a><br>"
			else
				dat += "No Tape Loaded<br>"

			dat += "<table cellspacing=5><tr>"
			dat += "<td><a href='byond://?src=\ref[src];command=rec'>[src.mode == 1 ? "Recording" : "Not Recording"]</a></td>"
			dat += "<td><a href='byond://?src=\ref[src];command=play'>[src.mode == 2 ? "Playing" : "Not Playing"]</a></td>"
			dat += "<td><a href='byond://?src=\ref[src];command=stop'>Stop</a></td>"
			dat += "<td><a href='byond://?src=\ref[src];command=clear'>Clear Log</a></td>"
			dat += "<td><a href='byond://?src=\ref[src];command=continuous_mode'>[continuous ? "Looping" : "No Loop"]</a></td></table></tt>"

			user.Browse(dat, "window=audiolog;size=400x140")
			onclose(user, "audiolog")
		else
			user.Browse(null, "window=audiolog")
			src.remove_dialog(user)

		return

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/audio_tape))
			if (src.tape)
				boutput(user, "There is already a tape loaded.")
				return

			user.drop_item(I)
			I.set_loc(src)
			src.tape = I
			src.tape.log_line = 1
			src.icon_state = initial(src.icon_state)
			src.updateSelfDialog()

			user.visible_message("[user] loads a tape into [src].", "You load a tape into [src].")

		else
			..()

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/audio_tape) && in_interact_range(src, user) && in_interact_range(W, user))
			return src.Attackby(W, user)
		return ..()

	New()
		..()
		SPAWN(1 SECOND)
			if (!src.tape)
				src.tape = new /obj/item/audio_tape(src)
			if (src.audiolog_messages && length(src.audiolog_messages))
				src.tape.messages = src.audiolog_messages
				src.audiolog_messages = null
			if (src.audiolog_speakers && length(src.audiolog_speakers))
				src.tape.speakers = src.audiolog_speakers
				src.audiolog_speakers = null

	Topic(href, href_list)
		..()
		if (usr.stat || usr.restrained() || usr.lying)
			return
		if ((usr.contents.Find(src) || usr.contents.Find(src.master) || in_interact_range(src, usr) && istype(src.loc, /turf)))
			src.add_dialog(usr)
			switch(href_list["command"])
				if("rec")
					src.mode = 1
					processing_items.Remove(src)
				if("play")
					src.mode = 2
					processing_items |= src
				if("stop")
					src.mode = 0
					processing_items.Remove(src)
					if (src.tape)
						src.tape.log_line = 1
				if("clear")
					src.mode = 0
					processing_items.Remove(src)
					if (src.tape)
						src.tape.reset()
					//src.audiolog_messages = list()
					//src.audiolog_speakers = list()

				if ("continuous_mode")
					continuous = !continuous

				if("eject")
					src.mode = 0
					processing_items.Remove(src)
					src.icon_state = "[initial(src.icon_state)]-empty"

					src.tape.set_loc(get_turf(src))
					usr.put_in_hand_or_eject(src.tape) // try to eject it into the users hand, if we can

					src.tape.log_line = 1
					src.tape = null

			src.add_fingerprint(usr)
			src.updateSelfDialog()
		else
			usr.Browse(null, "window=audiolog")
			return
		return

	hear_talk(var/mob/living/carbon/speaker, messages, real_name, lang_id)
		if ((src.mode != 1) || !src.tape)
			return

		if (speaker.mind && speaker.mind.assigned_role == "Captain")
			speaker.unlock_medal("Captain's Log", 1)

		var/speaker_name = speaker.real_name
		if (real_name)
			speaker_name = real_name

		if (speaker.vdisfigured)
			speaker_name = "Unknown"

		if(ishuman(speaker) && speaker.wear_mask && speaker.wear_mask.vchange)//istype(speaker.wear_mask, /obj/item/clothing/mask/gas/voice))
			if(speaker:wear_id)
				speaker_name = speaker:wear_id:registered
			else
				speaker_name = "Unknown"

		var/message = (lang_id == "english" || lang_id == "") ? messages[1] : messages[2]
		if (src.tape.add_message(speaker_name, message, continuous) == 0)
			src.speak(src.name, "Memory full. Have a nice day.")
			src.mode = 0
			processing_items.Remove(src)
			src.updateSelfDialog()

		return

	process()
		if((mode != 2) || !src.tape)
			src.mode = 0
			processing_items.Remove(src)
			src.updateSelfDialog()
			if(src.self_destruct)
				SPAWN(2 SECONDS)
					src.explode()
			return

		var/speak_message = tape.get_message(continuous)
		if (!speak_message)
			src.mode = 0
			processing_items.Remove(src)
			src.updateSelfDialog()
			if(src.self_destruct)
				SPAWN(2 SECONDS)
					src.explode()
			return
		var/separator = findtext(speak_message,"|")
		if (!separator)
			src.mode = 0
			processing_items.Remove(src)
			src.updateSelfDialog()
			if(src.self_destruct)
				SPAWN(2 SECONDS)
					src.explode()
			return

		var/speaker = copytext(speak_message, 1, separator)
		speak_message = copytext(speak_message, separator+1)

		src.speak(speaker, speak_message)
		if (!src.tape.next(continuous))
			src.mode = 0
			processing_items.Remove(src)
			src.updateSelfDialog()
		return


	proc
		speak(speaker, message)
			if(!message)
				return
			if(!speaker)
				speaker = "Unknown"

			for(var/mob/O in all_hearers(5, src.loc))
				O.show_message("<span class='game radio'><span class='name'>[speaker]</span><b> [bicon(src)]\[Log\]</b> <span class='message'>\"[message]\"</span></span>",2)
			return

		explode()

			var/turf/T = get_turf(src.loc)

			if (ismob(src.loc))
				var/mob/M = src.loc
				M.show_message("<span class='alert'>Your [src] explodes!</span>", 1)

			if(T)
				T.hotspot_expose(700,125)

				explosion(src, T, -1, -1, 2, 3)

			qdel(src)
			return

// ########################
// # z5 prefab audio logs #
// ########################

// sleepership.dmm
// Lore Notez: some kinda lost colonyship

/obj/item/device/audio_log/radioship/small/sleepership
		continuous = 0
		audiolog_messages = list("*buzzing static*",
								"Maintenance log, uh, number 43.",
								"Still having issues with the mainframe.",
								"Damned thing blinked off as soon as it woke me this time.",
								"*clanging metal*",
								"Honestly, uh, I've not got much left to work with here.",
								"If another one of these boards blows, I'm not gonna have anything to replace it with.",
								"God knows what'll happen to us then. Here's hoping we last the rest of the trip.",
								"*loud mechanical click*")
		audiolog_speakers = list("???",
								"Male Voice",
								"Male Voice",
								"Male Voice",
								"???",
								"Male Voice",
								"Male Voice",
								"Male Voice",
								"???*")

/obj/item/device/audio_log/radioship/large/sleepership
		continuous = 0
		audiolog_messages = list("*harsh beep*",
								"This is an automated computer recording.",
								"Log #261 - NCS #### - En-route to *loud hissing tone* colony.",
								"System r-r-resources nearing de- ple- tionnnn.",
								"*falling beeps*",
								"Re-routing remaaaaaainiiiiiing power to top-deck cyro-sleepers.",
								"*humming electronics*",
								"Autopilot disengaged.",
								"Delopying emergency beacon.",
								"Central c-c-cOmpUtEr shut- d-dow-ow-ow-ownnnnn in 5,",
								"4,",
								"3-",
								"*crackling and popping*")
		audiolog_speakers = list("???",
								"Electronic Voice",
								"Electronic Voice",
								"Stuttering Electronic Voice",
								"???",
								"Warbly Electronic Voice",
								"???",
								"Electronic Voice",
								"Electronic Voice",
								"Faltering Electronic Voice",
								"Electronic Voice",
								"Electronic Voice",
								"???")

