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
	var/atom/movable/abstract_say_source/radio/announcement_computer/computer_say_source
	var/computer_say_source_name = "Announcement Computer"
	var/arrivalalert = "$NAME has signed up as $JOB."
	var/departurealert = "$NAME the $JOB has entered cryogenic storage."
	var/sound_to_play = 'sound/misc/announcement_1.ogg'
	var/sound_volume = 100
	var/override_font = null
	///Override for where this says it's coming from
	var/area_name = null
	req_access = list(access_heads)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	light_r =0.6
	light_g = 1
	light_b = 0.1

	/// This is solely used to reconcile refactoring announcement computers with `.dmm` files. Remove in a followup PR.
	var/voice_name = null

	New()
		if (!isnull(src.voice_name))
			src.computer_say_source_name = src.voice_name

		. = ..()
		src.computer_say_source = new()
		src.computer_say_source.name = src.computer_say_source_name

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

	ui_act(action, params, datum/tgui/ui)
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
				logTheThing(LOG_STATION, ui.user, "Sets an announcement message to \"[params["value"]]\" from \"[params["old"]]\".")

	proc/update_status()
		if(!src.ID)
			announce_status = "Insert Card"
		else if(!src.unlocked)
			announce_status = "Insufficient Access"
		else
			announce_status = ""

	proc/send_message(var/mob/user, message)
		if(!message || length_char(message) > max_length || !unlocked || get_time(user) > 0)
			return

		message = user.say(message, flags = SAYFLAG_DO_NOT_OUTPUT)?.content
		if (!message)
			return

		logTheThing(LOG_SAY, user, "as [ID.registered] ([ID.assignment]) created a command report: [message]")
		logTheThing(LOG_DIARY, user, "as [ID.registered] ([ID.assignment]) created a command report: [message]", "say")

		var/msg_sound = src.sound_to_play

		if (isflockmob(user))
			message = radioGarbleText(message, FLOCK_RADIO_GARBLE_CHANCE)
			msg_sound = 'sound/misc/flockmind/flockmind_caw.ogg'

		var/area/A = get_area(src)
		var/header = "[src.area_name || A.name] Announcement by [ID.registered] ([ID.assignment])"
		if (override_font )
			message = "<font face = '[override_font]'> [message] </font>"
			header = "<font face = '[override_font]'> [header] </font>"

		command_announcement(message, header, msg_sound, volume = src.sound_volume)
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

	proc/announce_arrival(mob/living/person)
		if (!src.announces_arrivals || !src.arrivalalert)
			return TRUE

		// People who have been on the ship the whole time, or who aren't on the ship, shouldn't be announced.
		if (person.traitHolder.getTraitWithCategory("background"))
			return TRUE

		var/job = person.mind.assigned_role
		if (!job || (job == "MODE"))
			job = "Staff Assistant"
		if (issilicon(person) && !isAI(person))
			job = "Cyborg"

		var/message = src.arrivalalert
		message = replacetext(message, "$NAME", person.real_name)
		message = replacetext(message, "$JOB", job)
		message = replacetext(message, "$STATION", "[station_name()]")
		message = replacetext(message, "$THEY", "[he_or_she(person)]")
		message = replacetext(message, "$THEM", "[him_or_her(person)]")
		message = replacetext(message, "$THEIR", "[his_or_her(person)]")

		src.computer_say_source.say(message)
		logTheThing(LOG_STATION, src, "ANNOUNCES: [message]")
		return TRUE

	proc/announce_departure(mob/living/person)
		var/job = person.mind.assigned_role
		if(!job || (job == "MODE"))
			job = "Staff Assistant"
		if(issilicon(person) && !isAI(person))
			job = "Cyborg"

		var/message = src.departurealert
		message = replacetext(message, "$NAME", person.real_name)
		message = replacetext(message, "$JOB", job)
		message = replacetext(message, "$STATION", "[station_name()]")
		message = replacetext(message, "$THEY", "[he_or_she(person)]")
		message = replacetext(message, "$THEM", "[him_or_her(person)]")
		message = replacetext(message, "$THEIR", "[his_or_her(person)]")

		src.computer_say_source.say(message)
		logTheThing(LOG_STATION, src, "ANNOUNCES: [message]")
		return TRUE

/obj/machinery/computer/announcement/station
	req_access = null
	name = "Station Announcement Computer"
	circuit_type = /obj/item/circuitboard/announcement/station

	bridge
		req_access = list(access_heads)
		name = "Bridge Announcement Computer"
		announces_arrivals = 1
		circuit_type = /obj/item/circuitboard/announcement/bridge

	captain
		req_access = list(access_captain)
		name = "Executive Announcement Computer"
		circuit_type = /obj/item/circuitboard/announcement/captain

	security
		req_access = list(access_maxsec)
		name = "Security Announcement Computer"
		area_name = "Security"
		circuit_type = /obj/item/circuitboard/announcement/security

	research
		req_access = list(access_research_director)
		name = "Research Announcement Computer"
		area_name = "Research"
		circuit_type = /obj/item/circuitboard/announcement/research

	medical
		req_access = list(access_medical_director)
		name = "Medical Announcement Computer"
		area_name = "Medical"
		circuit_type = /obj/item/circuitboard/announcement/medical

	engineering
		req_access = list(access_engineering_chief)
		name = "Engineering Announcement Computer"
		area_name = "Engineering"
		circuit_type = /obj/item/circuitboard/announcement/engineering

	ai
		req_access = list(access_ai_upload)
		name = "AI Announcement Computer"
		circuit_type = /obj/item/circuitboard/announcement/ai

	cargo
		req_access = list(access_cargo)
		name = "QM Announcement Computer"
		area_name = "Cargo"
		sound_to_play = 'sound/misc/bingbong.ogg'
		sound_volume = 70
		circuit_type = /obj/item/circuitboard/announcement/cargo

	catering
		req_access = list(access_bar, access_kitchen)
		name = "Catering Announcement Computer"
		area_name = "Catering"
		sound_to_play = 'sound/misc/bingbong.ogg'
		sound_volume = 70 //a little less earsplitting
		circuit_type = /obj/item/circuitboard/announcement/catering

/obj/machinery/computer/announcement/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "announcement1"
/obj/machinery/computer/announcement/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "announcement2"

/obj/machinery/computer/announcement/syndicate
	name = "Syndicate Announcement computer"
	computer_say_source_name = "Syndicate Announcement computer"
	theme = "syndicate"
	icon_state = "announcementsyndie"
	area_name = "Syndicate"
	req_access = list(access_syndicate_shuttle)
	circuit_type = /obj/item/circuitboard/announcement/syndicate

	commander
		area_name = null
		req_access = list(access_syndicate_commander)

	console
		icon_state = "syndiepc14"
		icon = 'icons/obj/decoration.dmi'
		req_access = null

/obj/machinery/computer/announcement/clown
	req_access = null
	name = "Illegal Announcement Computer"
	icon_state = "announcementclown"
	circuit_type = /obj/item/circuitboard/announcement/clown
	var/emagged = FALSE
	sound_to_play = 'sound/machines/announcement_clown.ogg'
	override_font = "Comic Sans MS"
	desc = "A bootleg announcement computer. Only accepts official Chips Ahoy brand clown IDs."
	sound_volume = 50

	send_message(mob/user, message)
		. = ..()
		if(.)
			SPAWN(0.5 SECONDS)
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
				if(src.ID)
					user.put_in_hand_or_eject(src.ID)

				if (src.emagged)
					var/turf/T = get_turf(src.loc)
					if(T)
						src.visible_message("<b>The clown on the screen laughs as the [src] explodes!</b>")
						explosion_new(src, T, 5) // On par with a pod explosion. From testing, may or may not cause a breach depending on map
				qdel(src)


	attackby(obj/item/W, mob/user)
		..()
		if (istype(W, /obj/item/card/id))
			if ( W.icon_state != "id_clown")
				src.unlocked = 0
				update_status()

	ui_act(action, parmas)
		..()
		switch(action)
			if ("id")
				if (src.ID && (src.ID.icon_state != "id_clown"))
					src.unlocked = 0 // clowns ONLY
					update_status()


	emag_act(mob/user, obj/item/card/emag/E)
		if (!src.emagged)
			src.visible_message(SPAN_ALERT("<B>The clown on the screen grins in horrid delight!</B>"))
		src.emagged = TRUE

