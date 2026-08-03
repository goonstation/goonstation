/* ================================================================== */
/* ------------------------- Implant Parent ------------------------- */
/* ================================================================== */

/obj/item/implant
	name = "implant"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "implant-g"
	w_class = W_CLASS_TINY
	var/implanted = null
	var/impcolor = "g"
	var/mob/owner = null
	var/mob/former_implantee = null
	var/image/implant_overlay = null
	var/life_tick_energy = 0
	var/crit_triggered = 0
	var/death_triggered = 0
	var/online = 0
	var/instant = 1
	var/scan_category = IMPLANT_SCAN_CATEGORY_OTHER

	//For PDA/signal alert stuff on implants
	var/uses_radio = 0
	var/list/mailgroups = null
	var/net_id = null
	var/alert_frequency = FREQ_PDA
	can_arcplate = FALSE

	New()
		..()
		if (uses_radio)
			if (!src.net_id)
				src.net_id = generate_net_id(src)
			MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, null, src.alert_frequency)
		if (ismob(src.loc))
			src.implanted(src.loc)

	disposing()
		if (owner)
			on_remove(owner)
		owner = null
		former_implantee = null
		if (uses_radio)
			mailgroups?.Cut()
		. = ..()

	proc/can_implant(mob/target, mob/user)
		return !istype(target, /mob/living/critter/robotic)

	// called when an implant is implanted into M by I
	proc/implanted(mob/M, mob/I)
		SHOULD_CALL_PARENT(TRUE)
		if(!istype(get_area(M), /area/sim/gunsim))
			logTheThing(LOG_COMBAT, I, "has implanted [constructTarget(M,"combat")] with a [src] implant ([src.type]) at [log_loc(M)].")
		src.set_loc(M)
		implanted = TRUE
		SEND_SIGNAL(src, COMSIG_ITEM_IMPLANT_IMPLANTED, M)
		owner = M
		if (isliving(M))
			var/mob/living/living = M
			LAZYLISTADD(living.implant, src)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (src.scan_category == IMPLANT_SCAN_CATEGORY_OTHER || src.scan_category == IMPLANT_SCAN_CATEGORY_UNKNOWN)
				var/image/img = H.prodoc_icons["other"]
				img.icon_state = "implant-other"
		if (implant_overlay)
			M.update_clothing()

		// signals
		RegisterSignal(M, COMSIG_LIVING_LIFE_TICK, PROC_REF(on_life))
		RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(on_death))

		activate()

	// called when an implant is removed from M
	proc/on_remove(var/mob/M)
		SHOULD_CALL_PARENT(TRUE)
		deactivate()
		SEND_SIGNAL(src, COMSIG_ITEM_IMPLANT_REMOVED, M)
		if (isliving(M))
			var/mob/living/living = M
			living.implant -= src
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			var/has_other_imp = FALSE
			for (var/obj/item/implant/I as anything in H.implant)
				if (I.scan_category == IMPLANT_SCAN_CATEGORY_OTHER || I.scan_category == IMPLANT_SCAN_CATEGORY_UNKNOWN)
					has_other_imp = TRUE
					break
			if (!has_other_imp)
				var/image/I = H.prodoc_icons["other"]
				I.icon_state = null
		if (implant_overlay)
			M.update_clothing()
		src.owner = null
		src.implanted = 0
		UnregisterSignal(M, COMSIG_LIVING_LIFE_TICK)
		UnregisterSignal(M, COMSIG_MOB_DEATH)

	proc/activate()
		online = TRUE

	proc/deactivate()
		online = FALSE

	proc/on_life(mob/M, mult = 1)
		if(ishuman(src.owner))
			var/mob/living/carbon/human/H = owner
			if(online)
				H.nutrition -= life_tick_energy
				do_process(mult)
			if(H.health < 0 && !crit_triggered && online)
				on_crit()
			else if(H.health >= 0 && crit_triggered)
				crit_triggered = 0
			if(death_triggered && isalive(H))
				death_triggered = 0
		else if (ismobcritter(src.owner))
			var/mob/living/critter/C = owner
			if (C.health < 0 && !crit_triggered && online)
				on_crit()
			else if (C.health >= 0 && crit_triggered)
				crit_triggered = 0
			if (death_triggered && isalive(C))
				death_triggered = 0

	proc/do_process(mult = 1)
		return

	proc/on_crit()
		SHOULD_CALL_PARENT(TRUE)
		crit_triggered = TRUE

	proc/on_death()
		SHOULD_CALL_PARENT(TRUE)
		death_triggered = TRUE
		deactivate()

	proc/get_coords()
		if (!isliving(src.owner))
			return
		var/mob/living/living_owner = src.owner
		if (locate(src) in living_owner.implant)
			var/turf/T = get_turf(src.owner)
			if (istype(T))
				return " at [T.x],[T.y],[T.z]"

	proc/send_message(var/message, var/alertgroup, var/sender_name)
		DEBUG_MESSAGE("sending message: [message]")
		var/datum/signal/newsignal = get_free_signal()
		newsignal.source = src
		newsignal.data["command"] = "text_message"
		newsignal.data["sender_name"] = sender_name
		newsignal.data["message"] = "[message]"

		newsignal.data["address_1"] = "00000000"
		newsignal.data["group"] = mailgroups + alertgroup
		newsignal.data["sender"] = src.net_id

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal)

	attackby(obj/item/I, mob/user)
		if (!istype(src, /obj/item/implant/projectile))
			if (istype(I, /obj/item/pen))
				var/t = input(user, "What would you like the label to be?", null, "[src.name]") as null|text
				if (!t)
					return
				if (user.equipped() != I)
					return
				if ((!in_interact_range(src, user) && src.loc != user))
					return
				t = copytext(adminscrub(t),1,128)
				if (t)
					src.name = "implant - '[t]'"
				return
			else if (istype(I, /obj/item/implanter))
				var/obj/item/implanter/Imp = I
				if (Imp.imp)
					user.show_text("[Imp] already has an implant loaded.")
					return
				else
					src.set_loc(Imp)
					Imp.imp = src
					Imp.update()
					user.u_equip(src)
					user.show_text("You insert [src] into [Imp].")
				return
			else if (istype(I, /obj/item/implantcase))
				var/obj/item/implantcase/Imp = I
				if (Imp.imp)
					user.show_text("[Imp] already has an implant loaded.")
					return
				else
					user.u_equip(src)
					src.set_loc(Imp)
					Imp.imp = src
					Imp.update()
					user.show_text("You insert [src] into [Imp].")
				return
			else
				return ..()
		else
			return ..()


/* ============================================================ */
/* ------------------------- Implants ------------------------- */
/* ============================================================ */

/obj/item/implant/cloner
	name = "cloner record implant"
	icon_state = "implant-b"
	impcolor = "b"
	scan_category = IMPLANT_SCAN_CATEGORY_CLONER
	alert_frequency = FREQ_CLONER_IMPLANT
	uses_radio = TRUE
	var/area/scanned_here

	New()
		..()
		src.scanned_here = get_area(src)

	implanted(mob/M, mob/I)
		..()
		global.processing_items |= src
		if (!istype(M, /mob/living/carbon/human))
			return
		var/mob/living/carbon/human/H = M
		if (!H.prodoc_icons)
			return
		var/image/img = H.prodoc_icons["cloner"]
		img.icon_state = "implant-cloner"

	process()
		if (!src.implanted || isdead(src.owner)) //dead silence
			return
		var/datum/signal/signal = get_free_signal()
		signal.data = list(
			"address_1"="00000000",
			"command"="heartbeat",
			"bio_id"= src.owner.bioHolder.Uid,
			"sender" = src.net_id,
		)
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	on_remove(mob/M)
		..()
		if (!istype(M, /mob/living/carbon/human))
			return
		var/mob/living/carbon/human/H = M
		if (!H.prodoc_icons)
			return
		for (var/obj/item/implant/I as anything in H.implant)
			if (istype(I, /obj/item/implant/cloner))
				return
		var/image/I = H.prodoc_icons["cloner"]
		I.icon_state = null

	proc/getHealthList()
		var/healthlist = list()
		if (!src.implanted)
			healthlist["OXY"] = 0
			healthlist["TOX"] = 0
			healthlist["BURN"] = 0
			healthlist["BRUTE"] = 0
			healthlist["HealthImplant"] = 0
		else
			var/mob/living/L
			if (isliving(src.owner))
				L = src.owner
				healthlist["HealthImplant"] = 0
				for (var/implant in L.implant)
					if (istype(implant, /obj/item/implant/health))
						healthlist["HealthImplant"] = 1
						break
				healthlist["OXY"] = round(L.get_oxygen_deprivation())
				healthlist["TOX"] = round(L.get_toxin_damage())
				healthlist["BURN"] = round(L.get_burn_damage())
				healthlist["BRUTE"] = round(L.get_brute_damage())
		return healthlist


/obj/item/implant/health
	name = "health implant"
	icon_state = "implant-b"
	impcolor = "b"
	scan_category = IMPLANT_SCAN_CATEGORY_HEALTH
	uses_radio = 1
	mailgroups = list(MGD_MEDICAL, MGT_SPIRITUALAFFAIRS)

	var/healthstring = ""
	var/affected = "CREW"

	implanted(mob/M, mob/I)
		..()
		if (!isdead(M) && M.client)
			JOB_XP(I, "Medical Doctor", 5)
		if (istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if (!H.prodoc_icons)
				return
			var/image/img = H.prodoc_icons["health"]
			img.icon_state = "implant-health"

	on_remove(mob/M)
		..()
		if (!istype(M, /mob/living/carbon/human))
			return
		var/mob/living/carbon/human/H = M
		if (!H.prodoc_icons)
			return
		for (var/obj/item/implant/I as anything in H.implant)
			if (istype(I, /obj/item/implant/health))
				return
		var/image/img = H.prodoc_icons["health"]
		img.icon_state = null

	proc/sensehealth()
		if (!src.implanted)
			return "ERROR"
		else
			var/mob/living/L
			if (isliving(src.owner))
				L = src.owner
				src.healthstring = "[round(L.get_oxygen_deprivation())] - [round(L.get_toxin_damage())] - [round(L.get_burn_damage())] - [round(L.get_brute_damage())] | OXY-TOX-BURN-BRUTE"
			if (!src.healthstring)
				src.healthstring = "ERROR"
			return src.healthstring

	activate()
		..()
		if (!ishuman(src.owner))
			return
		var/mob/living/carbon/human/H = src.owner
		H.mini_health_hud = 1
		H.show_text("You feel more in-tune with your body.", "blue")

	deactivate()
		..()
		if (!ishuman(src.owner))
			return
		var/mob/living/carbon/human/H = src.owner
		H.mini_health_hud = 0
		H.show_text("You feel less in-tune with your body.", "red")

	on_life(var/mob/M, var/mult = 1)
		if (!ishuman(src.owner))
			return
		if (!src.online)
			return
		var/mob/living/carbon/human/H = src.owner
		if (!H.mini_health_hud)
			H.mini_health_hud = 1

		var/datum/db_record/probably_my_record = data_core.medical.find_record("id", H.datacore_id)
		if (probably_my_record)
			probably_my_record["h_imp"] = "[src.sensehealth()]"
		..()

	on_crit()
		if(inafterlife(src.owner))
			return
		DEBUG_MESSAGE("[src] calling to report crit")
		SPAWN(rand(15, 20) SECONDS)
			health_alert()
		..()

	on_death()
		if(inafterlife(src.owner))
			return
		DEBUG_MESSAGE("[src] calling to report death")
		SPAWN(rand(15, 25) SECONDS)
			death_alert()
		..()

	proc/health_alert()
		if (!src.owner)
			return
		src.send_message("HEALTH ALERT: [src.owner] in [get_area(src)]: [src.sensehealth()]", MGA_MEDCRIT, "HEALTH-MAILBOT")

	proc/death_alert()
		if (!src.owner)
			return
		var/myarea = get_area(src)
		var/list/cloner_areas = list()
		for(var/obj/item/implant/cloner/cl_implant in src.owner)
			if(cl_implant.owner != src.owner || !cl_implant.scanned_here)
				continue
			cloner_areas += "[cl_implant.scanned_here]"
		var/message = "[affected] DEATH ALERT: [src.owner] in [myarea]. [length(cloner_areas) ? "Clone implant detected." : "No cloning implant detected."]"
		src.send_message(message, MGA_DEATH, "HEALTH-MAILBOT")

/obj/item/implant/health/security
	name = "health implant - security issue"
	affected = "SECURITY"

/obj/item/implant/health/security/anti_mindhack
	name = "mind protection health implant"
	icon_state = "implant-b"
	impcolor = "b"

	death_alert()
		. = ..()
		src.on_remove(src.owner)
		qdel(src)

/obj/item/implant/health/security/anti_mindhack/command
	name = "health implant - command issue"
	affected = "COMMAND"


/obj/item/implant/tracking
	name = "tracking implant"
	//life_tick_energy = 0.1
	uses_radio = 1
	mailgroups = list(MGD_SECURITY)
	var/id = 1
	var/frequency = FREQ_TRACKING_IMPLANT		//This is the nonsense frequency that the implant uses. I guess it was never finished. -kyle

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	on_remove(var/mob/M)
		if (!src.owner)
			return
		var/message = "TRACKING IMPLANT LOST: [src.owner][src.get_coords()] in [get_area(src)], "
		src.send_message(message, MGA_TRACKING, "TRACKER-MAILBOT")
		..()

/obj/item/implant/pod_wars
	name = "pilot tracking implant"

	deactivate()
		. = ..()
		var/datum/component/C = src.owner.GetComponent(/datum/component/minimap_marker/minimap)
		C?.RemoveComponent(/datum/component/minimap_marker/minimap)

/obj/item/implant/pod_wars/nanotrasen

	activate()
		. = ..()
		src.owner.AddComponent(/datum/component/minimap_marker/minimap, MAP_POD_WARS_NANOTRASEN, "blue_dot", 'icons/obj/minimap/minimap_markers.dmi', "Pilot Tracker", FALSE)

/obj/item/implant/pod_wars/syndicate

	activate()
		. = ..()
		src.owner.AddComponent(/datum/component/minimap_marker/minimap, MAP_POD_WARS_SYNDICATE, "red_dot", 'icons/obj/minimap/minimap_markers.dmi', "Pilot Tracker", FALSE)


/** Deprecated **/
/obj/item/implant/syn
	name = "syndicate implant"
	icon_state = "implant-r"
	impcolor = "r"

/obj/item/implant/robust
	name = "\improper Robusttec implant"
	icon_state = "implant-r"
	impcolor = "r"
	//life_tick_energy = 0.25
	var/inactive = 0

	on_crit()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = owner
			src.inactive = 1
			H.reagents.add_reagent("salbutamol", 20) // changed this from dexP // cogwerks
			H.reagents.add_reagent("epinephrine", 15) //inaprovaline no longer exists
			H.reagents.add_reagent("omnizine", 25)
			H.reagents.add_reagent("teporone", 20)
			if (H.mind) boutput(src, SPAN_NOTICE("Your Robusttec-Implant uses all of its remaining energy to save you and deactivates."))
			src.deactivate()
		..()


	do_process(var/mult = 1)
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = owner
			if (H.health < 40 && !src.inactive)
				if (!H.reagents.has_reagent("omnizine", 10))
					H.reagents.add_reagent("omnizine", 10)
				src.inactive = 1
				SPAWN(30 SECONDS) src.inactive = 0
		..()

/obj/item/implant/counterrev
	name = "counter-revolutionary implant"
	icon_state = "implant-b"
	impcolor = "b"

	activate()
		..()
		if (!ishuman(src.owner))
			return
		var/mob/living/carbon/human/H = src.owner

		if (H.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY))
			H.visible_message(SPAN_ALERT("<b>[H] resists the counter-revolutionary implant!</b>"))
			H.changeStatus("knockdown", 1 SECOND)
			H.force_laydown_standup()
			playsound(H.loc, 'sound/effects/electric_shock.ogg', 60, 0,0,pitch = 2.4)
			H.update_arrest_icon()

		else if (H.mind?.get_antagonist(ROLE_REVOLUTIONARY))
			H.TakeDamage("chest", 1, 1, 0)
			H.changeStatus("knockdown", 1 SECOND)
			H.setStatus("derevving")
			H.force_laydown_standup()
			H.emote("scream")
			playsound(H.loc, 'sound/effects/electric_shock.ogg', 60, 0,0,pitch = 1.6)
			H.update_arrest_icon()

	do_process(var/mult = 1)
		if (!ishuman(src.owner))
			return
		var/mob/living/carbon/human/H = src.owner
		if (H.mind?.get_antagonist(ROLE_REVOLUTIONARY))
			H.TakeDamage("chest", 1.5*mult, 1.5*mult, 0)
			if (H.health < 0)
				H.changeStatus("unconscious", 5 SECONDS)
				H.changeStatus("newcause", 5 SECONDS)
				H.delStatus("derevving")
				H.force_laydown_standup()
				H.show_text("<B>The [src] has successfuly deprogrammed your revolutionary spirit!</B>", "blue")

				//heal a small amount for the trouble of bein critted via this thing
				H.HealDamage("All", max(30 - H.health,0), 0)
				H.HealDamage("All", 0, max(30 - H.health,0))

				H.mind?.remove_antagonist(ROLE_REVOLUTIONARY)
			else
				if (prob(30))
					H.show_text("<B>The [src] burns and rattles inside your chest! It's attempting to force your loyalty to the Heads of Staff!</B>", "blue")
					playsound(H.loc, 'sound/effects/electric_shock_short.ogg', 60, 0,0,pitch = 0.8)
					H.emote("twitch_v")

		..()

	on_remove(var/mob/M)
		M.delStatus("derevving")
		. = ..()
		if (istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			H.update_arrest_icon()


// dumb joke
/obj/item/implant/antirot
	name = "\improper Rotbusttec implant"
	icon_state = "implant-r"
	impcolor = "r"

	on_death()
		. = ..()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = owner
			H.reagents.add_reagent("formaldehyde", 30)


/* Deprecated old turds shit */
/obj/item/implant/sec
	name = "security implant"
	icon_state = "implant-b"
	impcolor = "b"


/obj/item/implant/robotalk
	name = "machine translator implant"
	icon_state = "implant-b"
	var/active = 0

	implanted(mob/M, mob/I)
		. = ..()

		if (!istype(M))
			return

		M.ensure_speech_tree().AddSpeechOutput(SPEECH_OUTPUT_SILICONCHAT)
		M.ensure_listen_tree().AddListenInput(LISTEN_INPUT_SILICONCHAT)
		M.listen_tree.AddKnownLanguage(LANGUAGE_SILICON)
		M.listen_tree.AddKnownLanguage(LANGUAGE_BINARY)

	on_remove(mob/M)
		. = ..()

		if (!istype(M))
			return

		M.ensure_speech_tree().RemoveSpeechOutput(SPEECH_OUTPUT_SILICONCHAT)
		M.ensure_listen_tree().RemoveListenInput(LISTEN_INPUT_SILICONCHAT)
		M.listen_tree.RemoveKnownLanguage(LANGUAGE_SILICON)
		M.listen_tree.RemoveKnownLanguage(LANGUAGE_BINARY)

/obj/item/implant/bloodmonitor
	name = "blood monitor implant"
	icon_state = "implant-b"
	impcolor = "b"

/obj/item/implant/mindhack
	name = "mindhack implant"
	icon_state = "implant-mh"
	impcolor = "r"
	instant = 1
	scan_category = IMPLANT_SCAN_CATEGORY_SYNDICATE
	var/uses = 1
	var/expire = TRUE
	var/inactive = FALSE //Has this implant been overriden on the current implantee
	var/mob/implant_hacker = null // who is the person mindhacking the implanted person
	var/custom_orders = null // ex: kill the captain, dance constantly, don't speak, etc

	can_implant(var/mob/living/carbon/human/target, var/mob/user)
		if (!..() || !istype(target))
			return FALSE
		if (!implant_hacker)
			if (ismob(user))
				implant_hacker = user
			else
				return FALSE
		// all the stuff in here was added by Convair880, I just adjusted it to work with this can_implant() proc thing - haine
		var/mob/living/carbon/human/H = target
		if (!H.mind || !H.client)
			if (ismob(user)) user.show_text("[H] is braindead!", "red")
			return FALSE
		if (src.uses <= 0)
			if (ismob(user)) user.show_text("[src] has been used up!", "red")
			return FALSE
		for(var/obj/item/implant/health/security/anti_mindhack/AM in H.implant)
			if (AM.online)
				boutput(user, SPAN_ALERT("[H] is protected from mindhacking by \an [AM.name]!"))
				return FALSE
		// It might happen, okay. I don't want to have to adapt the override code to take every possible scenario (no matter how unlikely) into considertion.
		if (H.mind && ((H.mind.special_role == ROLE_VAMPTHRALL) || (H.mind.special_role == "spyminion")))
			if (ismob(user)) user.show_text("<b>[H] seems to be immune to being mindhacked!</b>", "red")
			H.show_text("<b>You resist [implant_hacker]'s attempt to mindhack you!</b>", "red")
			logTheThing(LOG_COMBAT, H, "resists [constructTarget(implant_hacker,"combat")]'s attempt to mindhack them at [log_loc(H)].")
			return FALSE
		return TRUE

	implanted(var/mob/M, var/mob/I)
		..()
		if (!ishuman(M) || (src.uses <= 0))
			return

		boutput(M, SPAN_ALERT("A stunning pain shoots through your brain!"))
		M.changeStatus("stunned", 10 SECONDS)
		M.changeStatus("knockdown", 10 SECONDS)

		//Remove any existing mindhack statuses and override existing implants
		var/mob/living/carbon/human/H = M
		H.mind?.remove_antagonist(ROLE_MINDHACK, ANTAGONIST_REMOVAL_SOURCE_OVERRIDE)
		for (var/obj/item/implant/mindhack/MS in H.implant)
			if(MS != src)
				MS.inactive = TRUE
		src.inactive = FALSE

		if(M == I)
			boutput(M, SPAN_ALERT("You feel utterly strengthened in your resolve! You are the most important person in the universe!"))
			tgui_alert(M, "You feel utterly strengthened in your resolve! You are the most important person in the universe!", "YOU ARE REALY GREAT!!")
			return
		logTheThing(LOG_COMBAT, M, "is mindhacked ([src.expire ? "regular" : "deluxe"]) by [constructTarget(I,"combat")] at [log_loc(I)].")
		M.setStatus("mindhack", expire ? (25 + rand(-5,5)) MINUTES : null, I, custom_orders)
		src.uses -= 1

	on_remove(var/mob/M)
		..()
		src.former_implantee = M
		if(!src.inactive) //If this isn't the implant currently mindhacking the owner don't remove antag status
			M.delStatus("mindhack")
			M.mind?.remove_antagonist(ROLE_MINDHACK, ANTAGONIST_REMOVAL_SOURCE_SURGERY)
		src.inactive = FALSE //Set back to normal incase its used again
		return

	proc/add_orders(var/orders)
		if (!orders || !istext(orders))
			return
		src.custom_orders = copytext(sanitize(html_encode(orders)), 1, MAX_MESSAGE_LEN)
		if (!(copytext(src.custom_orders, -1) in list(".", "?", "!")))
			src.custom_orders += "!"

/obj/item/implant/mindhack/super
	name = "mindhack DELUXE implant"
	expire = FALSE
	uses = 2

/obj/item/implant/access
	name = "electronic access implant"
	desc = "This implant works like an ID card, opening doors for the implantee."
	icon_state = "implant-g"
	impcolor = "g"
	var/uses = 8
	var/obj/item/card/id/access = new /obj/item/card/id
	tooltip_flags = REBUILD_DIST

	get_desc(dist)
		if (dist <= 1)
			. += "This one has [uses] charges remaining."

	proc/used()
		if (uses < 0) //infinite
			return 1

		if (uses == 0)
			return 0
		else
			uses -= 1
			tooltip_rebuild = TRUE
		return 1

	infinite
		desc = "This implant works like an ID card, opening doors for the implantee."
		uses = -1

		get_desc(dist)
			if (dist <= 1)
				. += "This one has unlimited charges."

		assistant
			New()
				..()
				access.access = get_access("Staff Assistant")

		shittybill //give im some access

			New()
				..()
				access.access = get_access("Medical Doctor") + get_access("Janitor") + get_access("Botanist") + get_access("Chef") + get_access("Scientist")

		captain
			New()
				..()
				access.access = get_access("Captain")

		chef
			New()
				..()
				access.access = get_access("Chef")

		admin_mouse
			New()
				..()
				access.access = get_access("Admin")

/obj/item/implant/confetti
	var/datum/component/my_comp = null

	implanted(mob/M, mob/I)
		. = ..()
		src.my_comp = M.AddComponent(/datum/component/death_confetti)

	on_remove(mob/M)
		. = ..()
		src.my_comp?.RemoveComponent()
		src.my_comp = null
