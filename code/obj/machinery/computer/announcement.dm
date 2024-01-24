/////////////////////////////////////// General Announcement Computer

/obj/machinery/computer/announcement
	name = "Announcement Computer"
	icon_state = "announcement"
	machine_registry_idx = MACHINES_ANNOUNCEMENTS
	circuit_type = /obj/item/circuitboard/announcement
	var/theme = "ntos"
	var/announcement_delay = 1200
	var/obj/item/card/id/ID = null
	var/unlocked = 0
	var/announce_status = "average"
	var/announce_status_message = "Insert Card"
	var/message = ""
	var/max_length = 400
	var/announces_arrivals = 0
	var/say_language = "english"
	var/arrivalalert = "$NAME has signed up as $JOB."
	var/departurealert = "$NAME the $JOB has entered cryogenic storage."
	var/obj/item/device/radio/intercom/announcement_radio = null
	var/voice_message = "broadcasts"
	var/voice_name = "Announcement Computer"
	var/sound_to_play = 'sound/misc/announcement_1.ogg'
	req_access = list(access_heads)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	light_r =0.6
	light_g = 1
	light_b = 0.1

	New()
		..()
		if (src.announces_arrivals)
			src.announcement_radio = new(src)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "AnnouncementComputer", src.name)
			ui.open()

	ui_data(mob/user)
		. = list(
			"message" = src.message,
			"theme" = src.theme,
			"card_name" = src.ID ? src.ID.name : null,
			"status" = src.announce_status,
			"status_message" = src.announce_status_message,
			"time" = get_time(user) SECONDS,
			"announces_arrivals" = 	src.announces_arrivals,
			"arrivalalert" = src.arrivalalert
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if ("id")
				if(src.ID)
					src.ID.set_loc(src.loc)
					usr.put_in_hand_or_eject(src.ID) // try to eject it into the users hand, if we can
					src.ID = null
					src.unlocked = 0
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/card/id))
						usr.drop_item()
						I.set_loc(src)
						src.ID = I
						src.unlocked = check_access(ID, 1)
					else if (istype(I, /obj/item/magtractor))
						var/obj/item/magtractor/mag = I
						if (istype(mag.holding, /obj/item/card/id))
							I = mag.holding
							mag.dropItem(0)
							I.set_loc(src)
							src.ID = I
							src.unlocked = check_access(ID, 1)
				. = TRUE
			if ("transmit")
				src.send_message(usr)
				. = TRUE
			if ("message")
				src.message = params["value"]
				if(url_regex?.Find(message)) message = ""
				. = TRUE
				logTheThing(LOG_STATION, usr, "sets an announcement message to \"[message]\".")
			if ("arrival_message")
				src.set_arrival_alert(usr, params["value"])
				. = TRUE
		update_status()

	proc/update_status()
		if(!src.ID)
			announce_status_message = "Insert Card"
			announce_status = "average"
		else if(!src.unlocked)
			announce_status_message = "Insufficient Access"
			announce_status = "bad"
		else if(!message)
			announce_status_message = "Input message."
			announce_status = "average"
		else if(length_char(message) > max_length)
			announce_status_message = "Message too long, maximium is [max_length] characters."
			announce_status = "average"
		else if(get_time(usr) > 0)
			announce_status_message = "Broadcast delay in effect."
			announce_status = "bad"
		else
			announce_status_message = "Ready to transmit!"
			announce_status = "good"

	proc/send_message(var/mob/user)
		if(!message || length_char(message) > max_length || !unlocked || get_time(user) > 0) return
		var/area/A = get_area(src)

		if(user.bioHolder.HasEffect("mute"))
			boutput(user, "You try to speak into \the [src] but you can't since you are mute.")
			return

		logTheThing(LOG_SAY, user, "as [ID.registered] ([ID.assignment]) created a command report: [message]")
		logTheThing(LOG_DIARY, user, "as [ID.registered] ([ID.assignment]) created a command report: [message]", "say")

		var/msg_sound = src.sound_to_play
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			message = process_accents(H, message) //Slurred announcements? YES!
		if (isflockmob(user))
			message = radioGarbleText(message, FLOCK_RADIO_GARBLE_CHANCE)
			msg_sound = 'sound/misc/flockmind/flockmind_caw.ogg'

		command_announcement(message, "[A.name] Announcement by [ID.registered] ([ID.assignment])", msg_sound)
		ON_COOLDOWN(user,"announcement_computer",announcement_delay)
		message = ""

	proc/nice_timer(mob/user)
		var/time = get_time(user)
		if(time < 0)
			return "--:--"
		else
			var/seconds = text2num(time) % 60 //ZeWaka: Should fix type mismatches.
			var/flick_seperator = (seconds % 2 == 0) // why was this being calculated after converting BACK into a string?!!! - cirr
			// VARIABLES SHOULDN'T CHANGE TYPE FROM STRING TO NUMBER TO STRING LIKE THIS IN LIKE SIX LINES AAGGHHHHH FUCK YOU DYNAMIC TYPING
			var/minutes = round(text2num((time - seconds) / 60))
			minutes = minutes < 10 ? "0[minutes]" : "[minutes]"
			seconds = seconds < 10 ? "0[seconds]" : "[seconds]"

			return "[minutes][flick_seperator ? ":" : " "][seconds]"

	proc/get_time(mob/user)
		return round(GET_COOLDOWN(user,"announcement_computer") / 10)

	proc/set_arrival_alert(var/mob/user, newalert)
		if (!newalert)
			src.arrivalalert = ""
			return
		if (!findtext(newalert, "$NAME"))
			user.show_text("The alert needs at least one $NAME token.", "red")
			return
		if (!findtext(newalert, "$JOB"))
			user.show_text("The alert needs at least one $JOB token.", "red")
			return
		src.arrivalalert = sanitize(adminscrub(newalert, 200))
		logTheThing(LOG_STATION, user, "sets the arrival announcement on [constructTarget(src,"station")] to \"[src.arrivalalert]\"")
		playsound(src.loc, "keyboard", 50, 1, -15)
		return

	proc/say_quote(var/text)
		return "[src.voice_message], \"[text]\""

	proc/process_language(var/message)
		var/datum/language/L = languages.language_cache[src.say_language]
		if (!L)
			L = languages.language_cache["english"]
		return L.get_messages(message)

	proc/announce_arrival(var/mob/living/person)
		if (!src.announces_arrivals)
			return 1
		if (!src.arrivalalert)
			return 1
		if ((person.traitHolder.hasTrait("stowaway")) || (person.traitHolder.hasTrait("pilot")) || (person.traitHolder.hasTrait("sleepy")))
			return 1 //people who have been on the ship the whole time, or who aren't on the ship, won't be announced
		if (!src.announcement_radio)
			src.announcement_radio = new(src)

		var/message = replacetext(replacetext(replacetext(src.arrivalalert, "$STATION", "[station_name()]"), "$JOB", person.mind.assigned_role), "$NAME", person.real_name)
		message = replacetext(replacetext(replacetext(message, "$THEY", "[he_or_she(person)]"), "$THEM", "[him_or_her(person)]"), "$THEIR", "[his_or_her(person)]")

		var/list/messages = process_language(message)
		src.announcement_radio.talk_into(src, messages, 0, src.name, src.say_language)
		logTheThing(LOG_STATION, src, "ANNOUNCES: [message]")
		return 1

	proc/announce_departure(var/mob/living/person)
		if (!src.announcement_radio)
			src.announcement_radio = new(src)

		var/job = person.mind.assigned_role
		if(!job || job == "MODE")
			job = "Staff Assistant"
		if(issilicon(person))
			job = "Cyborg"
		var/message = replacetext(replacetext(replacetext(src.departurealert, "$STATION", "[station_name()]"), "$JOB", job), "$NAME", person.real_name)
		message = replacetext(replacetext(replacetext(message, "$THEY", "[he_or_she(person)]"), "$THEM", "[him_or_her(person)]"), "$THEIR", "[his_or_her(person)]")


		var/list/messages = process_language(message)
		src.announcement_radio.talk_into(src, messages, 0, src.name, src.say_language)
		logTheThing(LOG_STATION, src, "ANNOUNCES: [message]")
		return 1

/obj/machinery/computer/announcement/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "announcement1"
/obj/machinery/computer/announcement/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "announcement2"

/obj/machinery/computer/announcement/syndie
		icon_state = "syndiepc14"
		icon = 'icons/obj/decoration.dmi'
		req_access = null
		name = "Syndicate Announcement computer"
		voice_name = "Syndicate Announcement Computer"
		theme = "syndicate"
