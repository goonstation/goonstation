TYPEINFO(/obj/item/audio_tape)
	mats = 3

/obj/item/audio_tape
	name = "compact tape"
	desc = "A small audio tape.  You could make some rad mix-tapes with this!"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "recordertape"
	w_class = W_CLASS_TINY

	var/log_line = 1 //Which line of the log it's on.
	var/max_lines = 100
	var/list/messages = list()
	var/list/speakers = list()

	proc
		add_message(speaker="Unknown",message, continuous)
			if (!speaker || !message)
				return FALSE

			if (!continuous && (log_line >= max_lines))
				return FALSE

			log_line++
			messages += "[message]"
			speakers += "[speaker]"
			if (continuous && (log_line > max_lines))
				messages.Cut(1,2)
				speakers.Cut(1,2)
				log_line = length(messages)

			return TRUE

		get_message(continuous)
			if (log_line > length(messages))
				if (continuous && length(messages))
					log_line = 1
				else
					return null

			return "[length(speakers) < log_line ? "Unknown" : speakers[log_line]]|[messages[log_line]]"

		next(continuous)
			if (log_line >= length(messages))
				log_line = 1
				if (!(continuous && length(messages)))
					return FALSE
				return TRUE

			log_line++
			return TRUE

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
				return FALSE

			return round((length(messages) /  max_lines))

#define MODE_OFF 0
#define MODE_RECORDING 1
#define MODE_PLAYING 2

TYPEINFO(/obj/item/device/audio_log)
	mats = 4

/obj/item/device/audio_log
	name = "audio log"
	desc = "A fairly spartan recording device."
	icon_state = "recorder"
	uses_multiple_icon_states = TRUE
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	var/obj/item/audio_tape/tape = null
	var/mode = MODE_OFF
	var/max_lines
	var/text_colour = "#3FCC3F"
	var/continuous = TRUE
	var/list/name_colours = list()
	var/list/audiolog_messages = list()
	var/list/audiolog_speakers = list()
	var/self_destruct = FALSE

	wall_mounted
		name = "Mounted Logger"
		desc = "A wall-mounted audio log device."

		attack_hand(mob/user)
			return attack_self(user)

		// updateSelfDialog()
		// 	return updateUsrDialog()

	New()
		..()
		if (!src.chat_text)
			src.chat_text = new
		src.vis_contents += src.chat_text
		SPAWN(1 SECOND)
			if (!src.tape)
				src.tape = new /obj/item/audio_tape(src)
			if (src.audiolog_messages && length(src.audiolog_messages))
				src.tape.messages = src.audiolog_messages
				src.audiolog_messages = null
			if (src.audiolog_speakers && length(src.audiolog_speakers))
				src.tape.speakers = src.audiolog_speakers
				src.audiolog_speakers = null
			src.max_lines = src.tape.max_lines

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "AudioLog")
			ui.open()

	ui_static_data()
		. = list(
			"name" = src.name,
		)

	ui_data(mob/user)
		. = list(
			"continuous" = src.continuous,
			"current_line" = src.tape?.log_line,
			"memory_capacity" = src.tape?.max_lines,
			"mode" = src.mode,
			"occupied_memory" = length(src.tape?.messages),
			"tape" = src?.tape,
			"tape_name" = src.tape?.name,
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if ("Record")
				if (src.mode != MODE_RECORDING)
					src.mode = MODE_RECORDING
			if ("Play")
				if (src.mode != MODE_PLAYING)
					play()
			if ("Stop")
				stop()
			if ("Rewind")
				if (src.tape)
					src.tape.log_line = 1
			if ("Clear")
				src.mode = MODE_OFF
				if (src.tape)
					src.tape.reset()
			if ("Loop")
				continuous = !continuous
			if ("Eject")
				src.mode = MODE_OFF
				src.icon_state = "[initial(src.icon_state)]-empty"

				src.tape.set_loc(get_turf(src))
				usr.put_in_hand_or_eject(src.tape) // try to eject it into the users hand, if we can

				playsound(src.loc, 'sound/machines/law_remove.ogg', 40, 0.5)

				src.tape.log_line = 1
				src.tape = null
		playsound(src.loc, 'sound/machines/button.ogg', 40, 0.5)
		src.add_fingerprint(usr)
		. = TRUE

	attack_self(mob/user as mob)
		..()
		if (user.stat || user.restrained() || user.lying)
			return
		if ((user.contents.Find(src) || user.contents.Find(src.master) || BOUNDS_DIST(src, user) == 0 && istype(src.loc, /turf)))
			src.ui_interact(user)
			// src.add_dialog(user)

			// var/dat = "<TT><b>Audio Logger</b><br>"
			// if (src.tape)
			// 	dat += "Memory [src.tape.use_percentage()]% Full -- <a href='byond://?src=\ref[src];command=eject'>Eject</a><br>"
			// else
			// 	dat += "No Tape Loaded<br>"

			// dat += "<table cellspacing=5><tr>"
			// dat += "<td><a href='byond://?src=\ref[src];command=rec'>[src.mode == MODE_RECORDING ? "Recording" : "Not Recording"]</a></td>"
			// dat += "<td><a href='byond://?src=\ref[src];command=play'>[src.mode == MODE_PLAYING ? "Playing" : "Not Playing"]</a></td>"
			// dat += "<td><a href='byond://?src=\ref[src];command=stop'>Stop</a></td>"
			// dat += "<td><a href='byond://?src=\ref[src];command=clear'>Clear Log</a></td>"
			// dat += "<td><a href='byond://?src=\ref[src];command=continuous_mode'>[continuous ? "Looping" : "No Loop"]</a></td></table></tt>"

			// user.Browse(dat, "window=audiolog;size=400x140")
			// onclose(user, "audiolog")
		// else
			// user.Browse(null, "window=audiolog")
			// src.remove_dialog(user)

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
			src.ui_interact(user)

			playsound(src.loc, 'sound/machines/law_insert.ogg', 40, 0.5)
			user.visible_message("[user] loads a tape into [src].", "You load a tape into [src].")

		else
			..()

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/audio_tape) && in_interact_range(src, user) && in_interact_range(W, user))
			return src.Attackby(W, user)
		return ..()

	hear_talk(var/mob/living/carbon/speaker, messages, real_name, lang_id)
		if (src.mode != MODE_RECORDING || !src.tape)
			return

		if (speaker.mind && speaker.mind.assigned_role == "Captain")
			speaker.unlock_medal("Captain's Log", 1)

		var/speaker_name = speaker.real_name
		if (real_name)
			speaker_name = real_name

		if (speaker.vdisfigured)
			speaker_name = "Unknown"

		if (ishuman(speaker) && speaker.wear_mask && speaker.wear_mask.vchange)
			if (speaker:wear_id)
				speaker_name = speaker:wear_id:registered
			else
				speaker_name = "Unknown"

		var/message = (lang_id == "english" || lang_id == "") ? messages[1] : messages[2]
		if (src.tape.add_message(speaker_name, message, continuous) == 0)
			src.speak(null, "Memory full. Have a nice day.", TRUE) // have the UI send a ui_act() thing when memory full instead of the DM code
			src.mode = MODE_OFF

		return

	proc/play()
		if (!src.tape)
			return

		mode = MODE_PLAYING
		src.create_name_colours(src.tape.speakers)
		SPAWN(2 SECONDS)
			while (mode == MODE_PLAYING && src.tape)
				var/speak_message = tape.get_message(continuous)
				if (!speak_message)
					stop()
					return

				var/separator = findtext(speak_message,"|")
				if (!separator)
					stop()
					return

				var/speaker = copytext(speak_message, 1, separator)
				speak_message = copytext(speak_message, separator+1)

				speak(speaker, speak_message)
				sleep(5 SECONDS)
				if (!tape || !tape.next(continuous))
					stop()

	proc/stop()
		src.mode = MODE_OFF
		if (src.self_destruct)
			SPAWN(2 SECONDS)
				src.explode()

	proc/speak(speaker, message, show_no_speaker, text_colour_override)
		if (!message)
			return
		var/speaker_colour
		if (!text_colour_override)
			speaker_colour = src.text_colour
			if (speaker && !show_no_speaker && name_colours[speaker])
				speaker_colour = name_colours[speaker]
		else
			speaker_colour = text_colour_override
		if (!speaker && !show_no_speaker)
			speaker = "Unknown"

		var/image/chat_maptext/audio_log_text
		if (istype(src.loc, /turf))
			audio_log_text = make_chat_maptext(src, message, "color: [speaker_colour];")
			if (audio_log_text && src.chat_text && length(src.chat_text.lines))
				audio_log_text.measure(src)
				for (var/image/chat_maptext/I in src.chat_text.lines)
					if (I != audio_log_text)
						I.bump_up(audio_log_text.measured_height)
		src.audible_message("<span class='game radio' style='color: [speaker_colour]'><span class='name'>[speaker]</span><b> [bicon(src)]\[Log\]</b> <span class='message'>\"[message]\"</span></span>", 2, assoc_maptext = audio_log_text)
		return

	proc/explode()
		speak(null, "This message will self-destruct in 5 seconds...", TRUE, "#E00000")
		sleep(1 SECOND)
		for (var/i in 1 to 4)
			speak(null, "[5 - i]", TRUE, "#E00000")
			sleep(1 SECOND)

		src.blowthefuckup(2)
		return

	proc/create_name_colours(var/list/names)
		if (!length(names))
			return

		var/list/unique_names = list()
		for (var/i in 1 to length(names))
			if (!(names[i] in unique_names))
				unique_names.Add(names[i])

		name_colours = list()
		if (length(unique_names) == 1)
			name_colours[unique_names[1]] = text_colour
			return

		var/list/text_rgb = hex_to_rgb_list(text_colour)
		var/list/text_hsl = rgb2hsl(text_rgb[1], text_rgb[2], text_rgb[3])
		var/lightness_part = 60 / (length(unique_names) + 1)

		for (var/i in 1 to length(unique_names))
			var/lightness = 20 + (lightness_part * i)
			var/colour = hsl2rgb(text_hsl[1], text_hsl[2], lightness)
			name_colours[unique_names[i]] = colour

#undef MODE_OFF
#undef MODE_RECORDING
#undef MODE_PLAYING


	nuke_briefing
		name = "Mission Briefing"
		desc = "The standard for covert mission briefing."
		continuous = 0

		New(newloc, var/nuke_area)
			..()
			if (!nuke_area)
				nuke_area = "an unknown area. I think mission control fucked up somewhere"
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

// prefab_water_miraclium_survey.dmm
// nadir: survey site where the big ol' miraclium deposit was located

/obj/item/device/audio_log/miraclium_survey

		name = "hardened audio log"
		desc = "A fairly spartan recording device. It seems to be constructed of non-standard materials, with an unfamiliar connector."
		continuous = 0
		audiolog_messages = list("Begin log. Technician Reed, survey report, site 2a.",
								"Deep-crust probe reported improved density over site 1e.",
								"Anomalous mineral yields estimated-",
								"*loud clattering noise*",
								"HARRY! GET YOUR ASS OVER HERE!",
								"What the hell, Steve? I'm in the middle of a report!",
								"Dude. We found the big one. Like, the REALLY big one.",
								"*muffled footsteps*",
								"Holy shit, you weren't kidding. Gimme one of those.",
								"*loud thump*",
								"Goddamn. That's the real deal. Rainbow rocks.",
								"Let's get the hell back home. I can already taste the burger.",
								"Shouldn't we grab the log? The tools?",
								"Nobody's gonna give a shit about those. We found it.")
		audiolog_speakers = list("gruff male voice",
								"gruff male voice",
								"gruff male voice",
								"???",
								"young male voice",
								"gruff male voice",
								"young male voice",
								"???",
								"gruff male voice",
								"???",
								"gruff male voice",
								"gruff male voice",
								"young male voice",
								"gruff male voice")
