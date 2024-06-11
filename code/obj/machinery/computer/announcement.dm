/////////////////////////////////////// General Announcement Computer

/obj/machinery/computer/announcement
	name = "announcement computer"
	icon_state = "announcement"
	machine_registry_idx = MACHINES_ANNOUNCEMENTS
	circuit_type = /obj/item/circuitboard/announcement
	var/theme = "ntos"
	var/announcement_delay = 1200
	var/obj/item/card/id/ID = null
	var/unlocked = 0
	var/announce_status = "Insert Card"
	var/max_length = 400
	var/announces_arrivals = 0
	var/say_language = "english"
	var/arrivalalert = "$NAME has signed up as $JOB."
	var/departurealert = "$NAME the $JOB has entered cryogenic storage."
	var/obj/item/device/radio/intercom/announcement_radio = null
	var/voice_message = "broadcasts"
	var/voice_name = "Announcement Computer"
	var/sound_to_play = 'sound/misc/announcement_1.ogg'
	var/override_font = null
	req_access = list(access_heads)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	light_r =0.6
	light_g = 1
	light_b = 0.1

	New()
		..()
		if (src.announces_arrivals)
			src.announcement_radio = new(src)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/card/id))
			if (src.ID)
				src.ID.set_loc(src.loc)
				boutput(user, SPAN_NOTICE("[src.ID] is ejected from the ID scanner."))
			user.drop_item()
			W.set_loc(src)
			src.ID = W
			src.unlocked = check_access(ID, 1)
			boutput(user, SPAN_NOTICE("You insert [W]."))
			update_status()
			tgui_process.update_uis(src)
			return
		..()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "AnnouncementComputer", src.name)
			ui.open()

	ui_data(mob/user)
		. = list(
			"theme" = src.theme,
			"card_name" = src.ID ? src.ID.name : null,
			"status_message" = src.announce_status,
			"time" = get_time(user) SECONDS,
			"announces_arrivals" = 	src.announces_arrivals,
			"arrivalalert" = src.arrivalalert,
			"max_length" = src.max_length
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
				update_status()
			if ("transmit")
				src.send_message(usr, params["value"])
				. = TRUE
			if ("arrival_message")
				src.set_arrival_alert(usr, params["value"])
				. = TRUE
			if ("log")
				logTheThing(LOG_STATION, usr, "Sets an announcement message to \"[params["value"]]\" from \"[params["old"]]\".")

	proc/update_status()
		if(!src.ID)
			announce_status = "Insert Card"
		else if(!src.unlocked)
			announce_status = "Insufficient Access"
		else
			announce_status = ""

	proc/send_message(var/mob/user, message)
		if(!message || length_char(message) > max_length || !unlocked || get_time(user) > 0) return
		var/area/A = get_area(src)

		if(user.bioHolder.HasEffect("mute"))
			boutput(user, "You try to speak into \the [src] but you can't since you are mute.")
			return
		if(url_regex?.Find(message))
			boutput(src, SPAN_NOTICE("<b>Web/BYOND links are not allowed in ingame chat.</b>"))
			boutput(src, SPAN_ALERT("&emsp;<b>\"[message]</b>\""))
			return
		message = sanitize(adminscrub(message, src.max_length))

		logTheThing(LOG_SAY, user, "as [ID.registered] ([ID.assignment]) created a command report: [message]")
		logTheThing(LOG_DIARY, user, "as [ID.registered] ([ID.assignment]) created a command report: [message]", "say")

		var/msg_sound = src.sound_to_play
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			message = process_accents(H, message) //Slurred announcements? YES!
		if (isflockmob(user))
			message = radioGarbleText(message, FLOCK_RADIO_GARBLE_CHANCE)
			msg_sound = 'sound/misc/flockmind/flockmind_caw.ogg'


		var/header = "[A.name] Announcement by [ID.registered] ([ID.assignment])"
		if (override_font )
			message = "<font face = '[override_font]'> [message] </font>"
			header = "<font face = '[override_font]'> [header] </font>"

		command_announcement(message, header, msg_sound)
		ON_COOLDOWN(user,"announcement_computer",announcement_delay)
		return TRUE

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
		var/background_trait = person.traitHolder.getTraitWithCategory("background")
		if (!src.announces_arrivals)
			return 1
		if (!src.arrivalalert)
			return 1
		if (background_trait)
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

/obj/machinery/computer/announcement/clown
	req_access = null
	name = "Illegal Announcement Computer"
	icon_state = "announcementclown"
	circuit_type = /obj/item/circuitboard/clown_announcement
	var/emagged = FALSE
	sound_to_play = 'sound/machines/announcement_clown.ogg'
	override_font = "Comic Sans MS"

	send_message(mob/user, message)
		. = ..()
		if(.)
			sleep(5)
			new /obj/effects/explosion (src.loc)
			playsound(src.loc, "explosion", 50, 1)
			src.visible_message("<b>[src] is obliterated! Was it worth it?</b>")
			user.shock(user, 2501, stun_multiplier = 1,  ignore_gloves = 1)

			var/mob/living/carbon/clown = user
			if(istype(clown))
				var/datum/db_record/S = data_core.security.find_record("id", clown.datacore_id)
				S?["criminal"] = "*Arrest*"
				S?["mi_crim"] = "Making a very irritating announcement."

				clown.update_burning(15) // placed here since update_burning is only for mob/living
			if(ID)
				user.put_in_hand_or_eject(ID)

			if (emagged)
				var/turf/T = get_turf(src.loc)
				if(T)
					src.visible_message("<b>The clown on the screen laughs as the [src] explodes!</b>")
					explosion_new(src, T, 5) // On par with a pod explosion. From testing, may or may not cause a breach depending on map
			qdel(src)


	attackby(obj/item/W, mob/user)
		..()
		if (istype(W, /obj/item/card/id))
			if (!istype (W, /obj/item/card/id/clown))
				src.unlocked = 0
				update_status()

	ui_act(action, parmas)
		..()
		switch(action)
			if ("id")
				if(  !istype (src.ID, /obj/item/card/id/clown))
					src.unlocked = 0 // clowns ONLY
					update_status()


	emag_act(mob/user, obj/item/card/emag/E)
		if (!emagged)
			src.visible_message(SPAN_ALERT("<B>The clown on the screen grins in horrid delight!</B>"))
		emagged = TRUE

