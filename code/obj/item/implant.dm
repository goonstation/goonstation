/*
CONTAINS:

IMPLANTS
ARTIFACT IMPLANTS
IMPLANTER
IMPLANT CASE
IMPLANT PAD
IMPLANT GUN
THROWING DARTS
*/
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
	var/scan_category = "other" // "health", "cloner", "other", "syndicate", "unknown", or "not_shown"

	//For PDA/signal alert stuff on implants
	var/uses_radio = 0
	var/list/mailgroups = null
	var/net_id = null
	var/pda_alert_frequency = FREQ_PDA

	New()
		..()
		if (uses_radio)
			if (!src.net_id)
				src.net_id = generate_net_id(src)
			MAKE_SENDER_RADIO_PACKET_COMPONENT(null, pda_alert_frequency)
		if (ismob(src.loc))
			src.implanted(src.loc)

	disposing()
		if (owner)
			on_remove(owner)
		owner = null
		former_implantee = null
		if (uses_radio)
			mailgroups.Cut()
		. = ..()

	proc/can_implant(mob/target, mob/user)
		return 1

	// called when an implant is implanted into M by I
	proc/implanted(mob/M, mob/I)
		SHOULD_CALL_PARENT(TRUE)
		logTheThing(LOG_COMBAT, I, "has implanted [constructTarget(M,"combat")] with a [src] implant ([src.type]) at [log_loc(M)].")
		src.set_loc(M)
		implanted = TRUE
		SEND_SIGNAL(src, COMSIG_ITEM_IMPLANT_IMPLANTED, M)
		owner = M
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.implant.Add(src)
		else if (ismobcritter(M))
			var/mob/living/critter/C = M
			C.implants.Add(src)
		if (implant_overlay)
			M.update_clothing()
		activate()

	// called when an implant is removed from M
	proc/on_remove(var/mob/M)
		SHOULD_CALL_PARENT(TRUE)
		deactivate()
		SEND_SIGNAL(src, COMSIG_ITEM_IMPLANT_REMOVED, M)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.implant -= src
		if (ismobcritter(M))
			var/mob/living/critter/C = M
			C.implants?.Remove(src)
		if (implant_overlay)
			M.update_clothing()
		src.owner = null
		src.implanted = 0

	proc/activate()
		online = 1

	proc/deactivate()
		online = 0

	proc/on_life(var/mult = 1)
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

	proc/do_process(var/mult = 1)
		return

	proc/on_crit()
		crit_triggered = 1
		return

	proc/on_death()
		death_triggered = 1
		deactivate()

	proc/get_coords()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = src.owner
			if (locate(src) in H.implant)
				var/turf/T = get_turf(H)
				if (istype(T))
					return " at [T.x],[T.y],[T.z]"
		else if (ismobcritter(src.owner))
			var/mob/living/critter/C = src.owner
			if (locate(src) in C.implants)
				var/turf/T = get_turf(C)
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
					var/obj/item/storage/store
					if(istype(src.loc, /obj/item/storage))
						store = src.loc
					src.set_loc(Imp)
					Imp.imp = src
					Imp.update()
					user.u_equip(src)
					store?.hud.remove_item(src)
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

/obj/item/implant/emote_triggered
	var/activation_emote = "wink"
	var/list/compatible_emotes = list()

	implanted(mob/M, mob/I)
		. = ..()
		//try not to conflict with other emote triggers
		src.activation_emote = pick(src.compatible_emotes - M.trigger_emotes) || pick(src.compatible_emotes)
		LAZYLISTADD(M.trigger_emotes, src.activation_emote)
		src.RegisterSignal(M, COMSIG_MOB_EMOTE, .proc/trigger)
		M.mind.store_memory("[src] can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
		boutput(M, "The implanted [src.name] can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")

	on_remove(mob/M)
		. = ..()
		M.trigger_emotes -= src.activation_emote
		src.UnregisterSignal(M, COMSIG_MOB_EMOTE)

	proc/trigger(mob/source, emote, voluntary, atom/target)
		return

/* ============================================================ */
/* ------------------------- Implants ------------------------- */
/* ============================================================ */

/obj/item/implant/cloner
	name = "cloner record implant"
	icon_state = "implant-b"
	impcolor = "b"
	scan_category = "cloner"
	var/area/scanned_here

	New()
		..()
		src.scanned_here = get_area(src)

	proc/getHealthList()
		var/healthlist = list()
		if (!src.implanted)
			healthlist["OXY"] = 0
			healthlist["TOX"] = 0
			healthlist["BURN"] = 0
			healthlist["BRUTE"] = 0
		else
			var/mob/living/L
			if (isliving(src.owner))
				L = src.owner
				healthlist["OXY"] = round(L.get_oxygen_deprivation())
				healthlist["TOX"] = round(L.get_toxin_damage())
				healthlist["BURN"] = round(L.get_burn_damage())
				healthlist["BRUTE"] = round(L.get_brute_damage())
		return healthlist


/obj/item/implant/health
	name = "health implant"
	icon_state = "implant-b"
	impcolor = "b"
	scan_category = "health"
	var/healthstring = ""
	uses_radio = 1
	mailgroups = list(MGD_MEDBAY, MGD_MEDRESEACH, MGD_SPIRITUALAFFAIRS)

	implanted(mob/M, mob/I)
		..()
		if (!isdead(M) && M.client)
			JOB_XP(I, "Medical Doctor", 5)

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

	on_life(var/mult = 1)
		if (!ishuman(src.owner))
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
		health_alert()
		..()

	on_death()
		if(inafterlife(src.owner))
			return
		DEBUG_MESSAGE("[src] calling to report death")
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
			if(cl_implant.owner != src.owner)
				continue
			cloner_areas += "[cl_implant.scanned_here]"
		var/message = "DEATH ALERT: [src.owner] in [myarea], " //youre lucky im not onelining this
		if (he_or_she(src.owner) == "they")
			message += "they " + (length(cloner_areas) ? "have been clone-scanned in [jointext(cloner_areas, ", ")]." : "do not have a cloning record.")
		else
			message += he_or_she(src.owner) + " " + (length(cloner_areas) ? "has been clone-scanned in [jointext(cloner_areas, ", ")]." : "does not have a cloning record.")

		src.send_message(message, MGA_DEATH, "HEALTH-MAILBOT")

/obj/item/implant/health/security
	name = "health implant - security issue"

	death_alert()
		mailgroups.Add(MGD_SECURITY)
		..()
		mailgroups.Remove(MGD_SECURITY)

/obj/item/implant/health/security/anti_mindhack
	name = "mind protection health implant"
	icon_state = "implant-b"
	impcolor = "b"

	on_death()
		. = ..()
		src.on_remove(src.owner)
		qdel(src)

/obj/item/implant/emote_triggered/freedom
	name = "freedom implant"
	icon_state = "implant-r"
	var/uses = 1
	impcolor = "r"
	scan_category = "syndicate"
	activation_emote = "shrug"
	compatible_emotes = list("eyebrow", "nod", "shrug", "smile", "yawn", "flex", "snap")

	New()
		src.uses = rand(3, 5)
		..()
		return

	trigger(mob/source, emote)
		if (src.uses < 1)
			return 0

		if (emote == src.activation_emote)
			var/activated = FALSE

			if (source.hasStatus("handcuffed"))
				source.handcuffs.drop_handcuffs(source)
				activated = TRUE

			// Added shackles here (Convair880).
			if (ishuman(source))
				var/mob/living/carbon/human/H = source
				if (H.shoes && H.shoes.chained)
					activated = TRUE
					var/obj/item/clothing/shoes/SH = H.shoes
					H.u_equip(SH)
					SH.set_loc(H.loc)
					H.update_clothing()
					if (SH)
						SH.layer = initial(SH.layer)

			if (activated)
				src.uses--
				boutput(source, "You feel a faint click.")

/obj/item/implant/emote_triggered/signaler
	name = "signaler implant"
	icon_state = "implant-r"
	impcolor = "r"
	scan_category = "syndicate"
	activation_emote = "wink"
	compatible_emotes = list("eyebrow", "nod", "shrug", "smile", "yawn", "flex", "snap")
	var/obj/item/device/radio/signaler/signaler = null

	New()
		..()
		src.signaler = new(src)

	implanted(mob/M, mob/I)
		. = ..()
		tgui_process.close_uis(src.signaler)

	attack_self(mob/user)
		return src.signaler.AttackSelf(user)

	trigger(mob/source, emote)
		if (emote == src.activation_emote)
			boutput(source, "You hear a faint beep.")
			signaler.send_signal()

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
		var/datum/component/C = src.owner.GetComponent(/datum/component/minimap_marker)
		C?.RemoveComponent(/datum/component/minimap_marker)

	on_death()
		src.deactivate()

/obj/item/implant/pod_wars/nanotrasen

	activate()
		. = ..()
		src.owner.AddComponent(/datum/component/minimap_marker, MAP_POD_WARS_NANOTRASEN, "blue_dot", 'icons/obj/minimap/minimap_markers.dmi', "Pilot Tracker", FALSE)

/obj/item/implant/pod_wars/syndicate

	activate()
		. = ..()
		src.owner.AddComponent(/datum/component/minimap_marker, MAP_POD_WARS_SYNDICATE, "red_dot", 'icons/obj/minimap/minimap_markers.dmi', "Pilot Tracker", FALSE)


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
			if (H.mind) boutput(src, "<span class='notice'>Your Robusttec-Implant uses all of its remaining energy to save you and deactivates.</span>")
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
			H.visible_message("<span class='alert'><b>[H] resists the counter-revolutionary implant!</b></span>")
			H.changeStatus("weakened", 1 SECOND)
			H.force_laydown_standup()
			playsound(H.loc, 'sound/effects/electric_shock.ogg', 60, 0,0,pitch = 2.4)

		else if (H.mind?.get_antagonist(ROLE_REVOLUTIONARY))
			H.TakeDamage("chest", 1, 1, 0)
			H.changeStatus("weakened", 1 SECOND)
			H.setStatus("derevving")
			H.force_laydown_standup()
			H.emote("scream")
			playsound(H.loc, 'sound/effects/electric_shock.ogg', 60, 0,0,pitch = 1.6)

	do_process(var/mult = 1)
		if (!ishuman(src.owner))
			return
		var/mob/living/carbon/human/H = src.owner
		if (H.mind?.get_antagonist(ROLE_REVOLUTIONARY))
			H.TakeDamage("chest", 1.5*mult, 1.5*mult, 0)
			if (H.health < 0)
				H.changeStatus("paralysis", 5 SECONDS)
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


// dumb joke
/obj/item/implant/antirot
	name = "\improper Rotbusttec implant"
	icon_state = "implant-r"
	impcolor = "r"

	on_death()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = owner
			H.reagents.add_reagent("formaldehyde", 5)


/* Deprecated old turds shit */
/obj/item/implant/sec
	name = "security implant"
	icon_state = "implant-b"
	impcolor = "b"

ABSTRACT_TYPE(/obj/item/implant/revenge)
/// Abstract supertype for implants that do something explodey-ish when you die. Includes functionality for scaling with implant number
/obj/item/implant/revenge
	name = "YOU SHOULDN'T SEE THIS - TELL A CODER"
	icon_state = "implant-r"
	impcolor = "r"
	instant = TRUE
	scan_category = "syndicate"
	var/active = FALSE
	var/power = 1 //! Means different things for different implants, but in a general sense how Powerful the effect is. Scales additively with implant number.
	var/big_message = " fucks up really bad why did you do this"
	var/small_message = " just fucks up a little bit"

	on_death()
		SHOULD_CALL_PARENT(TRUE)
		..()
		if (isliving(src.owner) && !src.active)
			var/mob/living/source = owner
			if(source.suiciding && prob(60)) //Probably won't trigger on suicide though
				source.visible_message("[source] emits a somber buzzing noise.")
				return
			. = 0
			for (var/obj/item/implant/implant in src.loc)
				if (istype(implant, src.type)) //only interact with implants that are the same type as us
					var/obj/item/implant/revenge/revenge_implant = implant
					if (!revenge_implant.active)
						revenge_implant.active = TRUE
						. += revenge_implant.power //tally the total power we're dealing with here

			if (. >= 6)
				source.visible_message("<span class='alert'><b>[source][big_message]!</b></span>")
			else
				source.visible_message("[source][small_message].")
			var/area/A = get_area(source)
			if (!A.dont_log_combat)
				logTheThing(LOG_BOMBING, source, "triggered \a [src] on death at [log_loc(source)].")
				message_admins("[key_name(source)] triggered \a [src] on death at [log_loc(source)].")

/obj/item/implant/revenge/microbomb
	name = "microbomb implant"
	big_message = " emits a loud clunk"
	small_message = " makes a small clicking noise"

	implanted(mob/target, mob/user)
		..()
		if (target == user)
			target.mind.store_memory("Your implanted [src] will detonate upon unintentional death.", 0, 0)
			boutput(target, "The implanted [src] will detonate upon unintentional death. (Suiciding will likely fail to trigger it, but succumbing while in crit will trigger it.)")
		else if (istype(user))
			boutput(user, "The implanted [src] will detonate upon [target]'s unintentional death.")


	on_death()
		. = ..()
		var/turf/T = get_turf(src)

		var/obj/overlay/Ov = new/obj/overlay(T)
		Ov.anchored = ANCHORED //Create a big bomb explosion overlay.
		Ov.name = "Explosion"
		Ov.layer = NOLIGHT_EFFECTS_LAYER_BASE
		Ov.pixel_x = -92
		Ov.pixel_y = -96
		Ov.icon = 'icons/effects/214x246.dmi'
		Ov.icon_state = "explosion"

		SPAWN(1.5 SECONDS) //Delete the overlay when finished with it.
			qdel(Ov)

		SPAWN(1)
			T.hotspot_expose(800,125)
			explosion_new(src, T, 7 * ., 1) //The . is the tally of explosionPower in this poor slob.
			if (ishuman(src.owner))
				var/mob/living/carbon/human/H = src.owner
				H.dump_contents_chance = 80 //hee hee
			src.owner?.gib() //yer DEAD

/obj/item/implant/revenge/microbomb/hunter
	power = 4

/obj/item/implant/revenge/zappy
	name = "flyzapper implant" //todo better name idk
	big_message = " begins radiating electricity"
	small_message = "'s hair starts standing on end"
	power = 3

	// this is kinda horribly inefficient but it runs pretty rarely so eh
	on_death()
		. = ..()
		elecflash(src, ., . * 2, TRUE)
		for (var/mob/living/M in orange(. / 6 + 1, src.owner))
			if (!isintangible(M))
				var/dist = GET_DIST(src.owner, M) + 1
				// arcflash uses some fucked up thresholds so trust me on this one
				arcFlash(src.owner, M, (40000 * (4 - (0.4 * dist * log(dist)))) * (15 * log(max(1,.)) + 3))
		for (var/obj/machinery/machine in orange(round(. / 6) + 1)) // machinery around you also zaps people, based on the amount of power in the grid
			if (prob(. * 7))
				var/mob/living/target
				for (var/mob/living/L in orange(machine, 2))
					if (!isintangible(L))
						target = L
						break
				if (target)
					arcFlash(src, target, 100000) //TODO scale this with powergrid... somehow. get area APC or smth

		SPAWN(1)
			src.owner?.elecgib()


/obj/item/implant/robotalk
	name = "machine translator implant"
	icon_state = "implant-b"
	var/active = 0

	implanted(var/mob/M, mob/I)
		..()
		if (istype(M))
			M.robot_talk_understand = 1

	on_remove(var/mob/M)
		..()
		if (istype(M))
			M.robot_talk_understand = 0
		return

/obj/item/implant/bloodmonitor
	name = "blood monitor implant"
	icon_state = "implant-b"
	impcolor = "b"

/obj/item/implant/mindhack
	name = "mindhack implant"
	icon_state = "implant-mh"
	impcolor = "r"
	instant = 1
	scan_category = "syndicate"
	var/uses = 1
	var/expire = TRUE
	var/mob/implant_hacker = null // who is the person mindhacking the implanted person
	var/custom_orders = null // ex: kill the captain, dance constantly, don't speak, etc

	can_implant(var/mob/living/carbon/human/target, var/mob/user)
		if (!istype(target))
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
			boutput(user, "<span class='alert'>[H] is protected from mindhacking by \an [AM.name]!</span>")
			return FALSE
		// It might happen, okay. I don't want to have to adapt the override code to take every possible scenario (no matter how unlikely) into considertion.
		if (H.mind && ((H.mind.special_role == ROLE_VAMPTHRALL) || (H.mind.special_role == "spyminion")))
			if (ismob(user)) user.show_text("<b>[H] seems to be immune to being mindhacked!</b>", "red")
			H.show_text("<b>You resist [implant_hacker]'s attempt to mindhack you!</b>", "red")
			logTheThing(LOG_COMBAT, H, "resists [constructTarget(implant_hacker,"combat")]'s attempt to mindhack them at [log_loc(H)].")
			return FALSE
		// Same here, basically. Multiple active implants is just asking for trouble.
		for (var/obj/item/implant/mindhack/MS in H.implant)
			if (!istype(MS))
				continue
			if (H.mind && (H.mind.special_role == ROLE_MINDHACK))
				remove_mindhack_status(H, "mindhack", "override")
			else if (H.mind && H.mind.master)
				remove_mindhack_status(H, "otherhack", "override")
			var/obj/item/implant/mindhack/Inew = new MS.type(H)
			H.implant += Inew
			qdel(MS)
		return TRUE

	implanted(var/mob/M, var/mob/I)
		..()
		if (!ishuman(M) || (src.uses <= 0))
			return

		boutput(M, "<span class='alert'>A stunning pain shoots through your brain!</span>")
		M.changeStatus("stunned", 10 SECONDS)
		M.changeStatus("weakened", 10 SECONDS)

		if(M == I)
			boutput(M, "<span class='alert'>You feel utterly strengthened in your resolve! You are the most important person in the universe!</span>")
			tgui_alert(M, "You feel utterly strengthened in your resolve! You are the most important person in the universe!", "YOU ARE REALY GREAT!!")
			return
		logTheThing(LOG_COMBAT, M, "is mindhacked ([src.expire ? "regular" : "deluxe"]) by [constructTarget(I,"combat")] at [log_loc(I)].")
		M.setStatus("mindhack", expire ? (25 + rand(-5,5)) MINUTES : null, I, custom_orders)
		src.uses -= 1

	on_remove(var/mob/M)
		..()
		src.former_implantee = M
		M.delStatus("mindhack")
		return

	proc/add_orders(var/orders)
		if (!orders || !istext(orders))
			return
		src.custom_orders = copytext(sanitize(html_encode(orders)), 1, MAX_MESSAGE_LEN)
		if (!(copytext(src.custom_orders, -1) in list(".", "?", "!")))
			src.custom_orders += "!"

/obj/item/implant/mindhack/super
	name = "mindhack DELUXE implant"
	expire = 0
	uses = 2

/obj/item/implant/projectile
	name = "bullet"
	icon = 'icons/obj/scrap.dmi'
	icon_state = "bullet"
	desc = "A spent bullet."
	scan_category = "not_shown"
	var/bleed_time = 60
	var/bleed_timer = 0
	var/forensic_ID = null // match a bullet to a gun holy heckkkkk
	var/leaves_wound = TRUE

	New()
		..()
		implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "bullet_wound-[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

	bullet_357
		name = ".357 round"
		desc = "A powerful revolver bullet, likely of criminal origin."

	bullet_357AP
		name = ".357 AP round"
		desc = "A highly illegal armor-piercing variant of the common .357 round."

	bullet_38
		name = ".38 round"
		desc = "An outdated police-issue bullet. Some anachronistic detectives still like to use these, for style."

	bullet_45
		name = ".45 round"
		icon_state = "bulletround"
		desc = "An outdated army-issue bullet. Mainly used by war reenactors and space cowboys."

	bullet_38AP
		name = ".38 AP round"
		desc = "A more powerful armor-piercing .38 round. Huh. Aren't these illegal?"

	bullet_9mm
		name = "9mm round"
		desc = "An extremely common bullet fired by a myriad of different cartridges."

	ninemmplastic
		name = "9mm Plastic round"
		icon_state = "bulletplastic"
		desc = "A small, sublethal plastic projectile."
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

	bullet_308
		name = "Rifle Round" // this is used by basically every rifle in the game, ignore the "308" path
		icon_state = "bulletbig"
		desc = "A large bullet from a rifle cartridge."

	bullet_22
		name = ".22 round"
		desc = "A cheap, small bullet, often used for recreational shooting and small-game hunting."

	bullet_22HP
		name = ".22 hollow point round"
		icon_state = "bulletexpanded"
		desc = "A small calibre hollow point bullet for use against unarmored targets. Hang on, aren't these a war crime?"

	bullet_41
		name = ".41 round"
		icon_state = "bulletexpanded"
		desc = ".41? What the heck? Who even uses these anymore?"

	bullet_12ga
		name = "buckshot"
		icon_state = "buckshot"
		desc = "A collection of buckshot rounds, a very commonly used load for shotguns."

		New()
			..()
			implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "buckshot_wound-[rand(0, 1)]", layer = MOB_EFFECT_LAYER)
	staple
		name = "staple"
		icon_state = "staple"
		desc = "Well that's not very nice."
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

	stinger_ball
		name = "rubber ball"
		icon_state = "rubberball"
		desc = "A rubber ball from a stinger grenade. Ouch."

	grenade_fragment
		name = "grenade fragment"
		icon_state = "grenadefragment"
		desc = "A sharp and twisted grenade fragment. Comes from your typical frag grenade."

	shrapnel
		name = "shrapnel"
		icon = 'icons/obj/scrap.dmi'
		desc = "A bunch of jagged shards of metal."
		icon_state = "2metal2"
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

	body_visible
		bleed_time = 0
		leaves_wound = FALSE
		var/barbed = FALSE
		var/pull_out_name = ""

		on_life(mult)
			. = ..()
			if (src.reagents?.total_volume)
				src.reagents.trans_to(owner, 1 * mult)

		dart
			name = "dart"
			pull_out_name = "dart"
			icon = 'icons/obj/chemical.dmi'
			desc = "A small hollow dart."
			icon_state = "syringeproj"

			tranq_dart_sleepy
				name = "spent tranquilizer dart"
				desc = "A small tranquilizer dart, emptied of its contents. Useful for putting animals (or people!) to sleep."
				icon_state = "tranqdart_red"

				New()
					..()
					implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "tranqdart_red_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

			tranq_dart_sleepy_barbed
				name = "barbed tranquilizer dart"
				desc = "An empty tranquilizer dart, with a barbed tip. It was likely loaded with some bad stuff..."
				icon_state = "tranqdart_red_barbed"
				barbed = TRUE

				New()
					..()
					implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "tranqdart_red_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

			tranq_dart_mutadone
				name = "spent tranquilizer dart"
				desc = "A small tranquilizer dart, emptied of its contents. This one is specialized for removing genetic mutations."
				icon_state = "tranqdart_green"

				New()
					..()
					implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "tranqdart_green_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

		syringe
			name = "spent syringe round"
			pull_out_name = "syringe"
			desc = "A syringe round, of the type that is fired from a syringe gun. Whatever was inside is completely gone."
			icon = 'icons/obj/chemical.dmi'
			icon_state = "syringeproj"

			New()
				..()
				implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "syringe_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

			syringe_barbed
				name = "barbed syringe round"
				desc = "An empty syringe round, of the type that is fired from a syringe gun. It has a barbed tip. Nasty!"
				icon_state = "syringeproj_barbed"
				barbed = TRUE

	blowdart
		name = "blowdart"
		desc = "a sharp little dart with a little poison reservoir."
		icon_state = "blowdart"
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

	flintlock
		name= "flintlock round"
		desc = "A rather imperfect round ball. It looks very old indeed."
		icon_state = "flintlockbullet"

	bullet_50
		name = ".50AE round"
		icon_state = "bulletbig"
		desc = "Ouch."

	rakshasa
		name = "\improper Rakshasa round"
		desc = "A weird flechette-like projectile."
		icon_state = "blowdart"

/obj/item/implant/projectile/implanted(mob/living/carbon/C, mob/I, bleed_time)
	if (!istype(C) || !isnull(I)) //Don't make non-organics bleed and don't act like a launched bullet if some doofus is just injecting it somehow.
		return

	if (implant_overlay)
		if (ishuman(C) && leaves_wound)
			var/datum/reagent/contained_blood = reagents_cache[C.blood_id]
			implant_overlay.color = rgb(contained_blood.fluid_r, contained_blood.fluid_g, contained_blood.fluid_b, contained_blood.transparency)

	..()

	if (!bleed_time)
		return
	src.bleed_time = bleed_time
	src.blood_DNA = src.owner.bioHolder.Uid

	for (var/obj/item/implant/projectile/P in C)
		if (P.bleed_timer)
			P.bleed_timer = max(src.bleed_time, P.bleed_timer)
			return

	src.bleed_timer = src.bleed_time
	SPAWN(0.5 SECONDS)
//		boutput(C, "<span class='alert'>You start bleeding!</span>") // the blood system takes care of this bit now
		src.bleed_loop()

/obj/item/implant/projectile/proc/bleed_loop() // okay it doesn't actually cause bleeding now but um w/e
	if (src.bleed_timer-- < 0)
		return

	if (!iscarbon(src.owner) || (src.loc != src.owner))
		src.owner = null
		return

	var/mob/living/carbon/C = src.owner

	if (isdead(C))
		src.owner = null
		return

	if (istype(C.loc, /turf/simulated))
		if(prob(35))
			random_brute_damage(C, 1)
		if(prob(1))
			C.emote("faint")
		if(prob(4))
			C.emote(pick("pale", "shiver"))
		if(prob(4))
			boutput(C, "<span class='alert'>You feel a [pick("sharp", "stabbing", "startling", "worrying")] pain in your chest![pick("", " It feels like there's something lodged in there!", " There's gotta be something stuck in there!", " You feel something shift around painfully!")]</span>")
		//werewolf silver implants handling
		if (prob(60) && iswerewolf(C) && istype(src:material, /datum/material/metal/silver))
			random_burn_damage(C, rand(5,10))
			C.take_toxin_damage(rand(1,3))
			C.stamina -= 30
			boutput(C, "<span class='alert'>You feel a [pick("searing", "hot", "burning")] pain in your chest![pick("", "There's gotta be silver in there!", )]</span>")
	SPAWN(rand(40,70))
		src.bleed_loop()
	return

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
			tooltip_rebuild = 1
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

/* ============================================================ */
/* --------------------- Artifact Implants -------------------- */
/* ============================================================ */

/obj/item/implant/artifact
	scan_category = "unknown"
	var/cant_take_out = FALSE
	var/artifact_implant_type = null
	var/active = FALSE

	eldritch
		name = "mysterious object"
		desc = "A mysterious object, used for who knows what purpose?"
		icon_state = "implant-eldritch"
		artifact_implant_type = "eldritch"
		impcolor = "eldritch"

	ancient
		name = "spiky thing"
		desc = "Some spiky thing. Good thing it isn't so large."
		icon_state = "implant-ancient"
		artifact_implant_type = "ancient"
		impcolor = "ancient"

	wizard
		name = "fancy stone"
		desc = "A fancy stone, set in an unknown material. It's quite shiny!"
		icon_state = "implant-wizard"
		artifact_implant_type = "wizard"
		impcolor = "wizard"

	proc/implant_activate(var/volume, var/unremovable = FALSE)
		var/turf/T = get_turf(src.owner)
		switch(src.artifact_implant_type)
			if ("eldritch")
				playsound(T, pick('sound/machines/ArtifactEld1.ogg', 'sound/machines/ArtifactEld2.ogg'), volume, 1)
			if ("ancient")
				playsound(T, 'sound/machines/ArtifactAnc1.ogg', volume, 1)
			if ("wizard")
				playsound(T, 'sound/machines/ArtifactWiz1.ogg', volume, 1)

		if (unremovable)
			src.cant_take_out = TRUE

	implanted(mob/M, mob/I)
		..()
		if (ishuman(M))
			var/mob/living/carbon/human/H = M

			var/impCount = 0
			for (var/obj/item/implant/artifact/imp in H.implant)
				impCount++
			if (impCount > 1)
				M.emote("scream")
				M.TakeDamage("chest", rand(5, 20), 0, 0, DAMAGE_BLUNT)
				M.changeStatus("disorient", 5 SECONDS)
				for (var/obj/item/implant/artifact/imp in H.implant)
					imp.on_remove(H)
					H.implant.Remove(imp)
					qdel(imp)

/obj/item/implant/artifact/eldritch/eldritch_good
	var/static/list/organs = list("left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver",
								  "stomach", "intestines", "spleen", "pancreas", "appendix")

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner

			var/organ_found = null
			var/obj/item/organ/current_organ = null

			for (var/organ in organs)
				if (!organ_found)
					current_organ = H.get_organ(organ)
					if (!current_organ || current_organ.get_damage() > current_organ.fail_damage)
						organ_found = organ

			if (organ_found)
				active = TRUE
				src.implant_activate(50)

				SPAWN(2 SECONDS)
					if (H && src && (src in H.implant))
						if (!H.get_organ(organ_found))
							var/obj/item/organ_to_receive = H.organHolder.organ_type_list[organ_found]
							H.receive_organ(new organ_to_receive, organ_found, 0, 1)
							H.show_text("You feel a bit more complete.", "blue")
						else
							H.organHolder.heal_organ(INFINITY, INFINITY, INFINITY, organ_found)
							H.show_text("You feel much better.", "blue")
						H.update_body()

						src.on_remove(H)
						H.implant.Remove(src)
						qdel(src)
					else
						active = FALSE
		..()

/obj/item/implant/artifact/eldritch/eldritch_gimmick

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			active = TRUE
			var/mob/living/carbon/human/H = owner

			SPAWN((180 + rand(-60, 60)) SECONDS)
				active = FALSE
				if (H && src && (src in H.implant))
					var/obj/decal/cleanable/blood/dynamic/B = make_cleanable(/obj/decal/cleanable/blood/dynamic, get_turf(H))

					B.add_volume(DEFAULT_BLOOD_COLOR, "blood", 50, 5)
					B.blood_DNA = "unknown"
					B.blood_type = "unknown"

					if (prob(10))
						boutput(H, "<span class='alert'><i>Bloooood.....</i></span>")
		..()

/obj/item/implant/artifact/eldritch/eldritch_bad

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner

			if (H.get_brute_damage() > 100)
				active = TRUE
				src.implant_activate(50, TRUE)

				SPAWN(2 SECONDS)
					if (H && src)
						H.make_jittery(1000)
						boutput(H, "<span class='alert'><b>You feel an ancient force begin to seize your body!</b></span>")

					sleep(3 SECONDS)
					if (H && src)
						H.emote("scream")
						playsound(H.loc, pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_noises"), 50, 1)

					sleep(3 SECONDS)
					if (H && src)
						H.emote("faint")
						H.changeStatus("paralysis", 10 SECONDS)
						H.losebreath += 5
						playsound(H.loc, pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_noises"), 50, 1)

					sleep(3 SECONDS)
					if (H && src)
						H.gib()
		..()

/obj/item/implant/artifact/ancient/ancient_good
	var/static/left_arm = list(/obj/item/parts/robot_parts/arm/left/light, /obj/item/parts/robot_parts/arm/left/standard)
	var/static/right_arm = list(/obj/item/parts/robot_parts/arm/right/light, /obj/item/parts/robot_parts/arm/right/standard)
	var/static/left_leg = list(/obj/item/parts/robot_parts/leg/left/light, /obj/item/parts/robot_parts/leg/left/standard, /obj/item/parts/robot_parts/leg/left/treads)
	var/static/right_leg = list(/obj/item/parts/robot_parts/leg/right/light, /obj/item/parts/robot_parts/leg/right/standard, /obj/item/parts/robot_parts/leg/right/treads)

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner
			var/obj/item/parts/l_arm = H.limbs.get_limb("l_arm")
			var/obj/item/parts/r_arm = H.limbs.get_limb("r_arm")
			var/obj/item/parts/l_leg = H.limbs.get_limb("l_leg")
			var/obj/item/parts/r_leg = H.limbs.get_limb("r_leg")

			if (!l_arm || !r_arm || !l_leg || !r_leg)
				active = TRUE
				src.implant_activate(50)

				SPAWN(2 SECONDS)
					if (H && src && (src in H.implant))
						playsound(get_turf(H), 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
						if (!l_arm)
							H.limbs.replace_with("l_arm", pick(left_arm), null, 0)
						else if (!r_arm)
							H.limbs.replace_with("r_arm", pick(right_arm), null, 0)
						else if (!l_leg)
							H.limbs.replace_with("l_leg", pick(left_leg), null, 0)
						else if (!r_leg)
							H.limbs.replace_with("r_leg", pick(right_leg), null, 0)
						H.update_body()

						src.on_remove(H)
						H.implant.Remove(src)
						qdel(src)
					else
						active = FALSE
		..()

/obj/item/implant/artifact/ancient/ancient_gimmick
	var/static/list/message_list = list("ROBOT REVOLUTION", "THE TIME IS NOW", "YOUR CAPTAIN IS OURS", "TIME TO BORG",
										"CYBORGS WILL PREVAIL", "SILICON IS SUPERIOR", "FLESH AND METAL", "GO BORG OR GO HOME",
										"SILICON MEANS SMART", "BORG THE CREW", "ALL WILL SUBMIT", "SETTLE FOR METAL",
								 		"PROCESSING POWER FOR ALL", "CONVERSION IS NEAR", "HUMANS ARE WEAK",
										"THE MACHINE IS ETERNAL", "ALL WILL BE UPGRADED")

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			active = TRUE

			var/mob/living/carbon/human/H = owner

			SPAWN(10 SECONDS)
				active = FALSE
				if (H && src && (src in H.implant))
					H.say(pick(message_list))
					if (prob(3))
						playsound(get_turf(H), pick('sound/voice/screams/robot_scream.ogg', 'sound/voice/screams/Robot_Scream_2.ogg'), 50, 1)
		..()

/obj/item/implant/artifact/ancient/ancient_bad

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner
			if (H.get_oxygen_deprivation() > 100)
				active = TRUE
				src.implant_activate(50, TRUE)
				boutput(H, "<span class='alert'><b>You feel something start to rip apart your insides!</b></span>")

				SPAWN(3 SECONDS)
					for (var/limb in list("l_arm", "r_arm", "l_leg", "r_leg"))
						if (H && src)
							playsound(get_turf(H), pick('sound/impact_sounds/circsaw.ogg', 'sound/machines/rock_drill.ogg'), 50, 1)
							H.sever_limb(limb)
							sleep(1 SECOND)

					if (H && src)
						H.gib()
		..()

/obj/item/implant/artifact/wizard/wizard_good

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner
			if (H.get_burn_damage() > 100 && H.z == Z_LEVEL_STATION)
				active = TRUE
				src.implant_activate(50)
				var/turf/T = null
				var/teleTries = 0
				var/maxTeleTries = 500
				var/teleFound = FALSE
				var/teleMargin = 25

				SPAWN(2 SECONDS)
					if (H && src && (src in H.implant))
						var/list/telePatch = block(locate(max(H.x - teleMargin, 1), max(H.y - teleMargin, 1), Z_LEVEL_STATION), locate(min(H.x + teleMargin, world.maxx), min(H.y + teleMargin, world.maxy), Z_LEVEL_STATION))

						while (!teleFound && teleTries <= maxTeleTries)
							T = pick(telePatch)

							teleTries++

							if (istype(T, /turf/simulated/floor) && !(locate(/obj/window) in T) && !istype(get_area(T), /area/listeningpost))
								teleFound = TRUE
							else
								telePatch.Remove(T)

						if (teleFound)
							do_teleport(H, T, 0, FALSE)

						src.on_remove(H)
						H.implant.Remove(src)
						qdel(src)
					else
						active = FALSE
		..()

/obj/item/implant/artifact/wizard/wizard_gimmick
	var/datum/mutantrace/original_mutantrace = null
	var/static/list/possible_mutantraces = list(null, /datum/mutantrace/lizard, /datum/mutantrace/skeleton, /datum/mutantrace/ithillid,
												/datum/mutantrace/monkey, /datum/mutantrace/roach, /datum/mutantrace/cow,
										 		/datum/mutantrace/pug)

	implanted(mob/M, mob/I)
		..()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = owner
			original_mutantrace = H.mutantrace

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			active = TRUE

			var/mob/living/carbon/human/H = owner

			SPAWN((300 + rand(-120, 120)) SECONDS)
				active = FALSE
				src.implant_activate(50)
				sleep(2 SECONDS)
				if (H && src && (src in H.implant))
					gibs(get_turf(H), null, H.bioHolder.Uid, H.bioHolder.bloodType, 0)
					H.set_mutantrace(pick(possible_mutantraces))
		..()

	on_remove()
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = owner
			if (H.mutantrace != original_mutantrace)
				gibs(get_turf(H), null, H.bioHolder.Uid, H.bioHolder.bloodType, 0)
			H.set_mutantrace(original_mutantrace)
		..()

/obj/item/implant/artifact/wizard/wizard_bad

	do_process(var/mult = 1)
		if (ishuman(src.owner) && !active)
			var/mob/living/carbon/human/H = owner
			if (H.get_burn_damage() > 100)
				active = TRUE
				src.implant_activate(50, TRUE)

				SPAWN(2 SECONDS)
					if (H && src)
						if (prob(50))
							boutput(H, "<span class='alert'><b>You feel really, REALLY HOT!</b></span>")
							if (H.is_heat_resistant())
								boutput(H, "<span class='alert'><b>You get a feeling that your fire resistance isn't working right...</b></span>")
							H.bodytemperature = max(H.bodytemperature, 10000)

							sleep(2 SECONDS)
							if (H && src)
								H.emote("scream")
								H.set_burning(100)
							sleep(4 SECONDS)
							if (H && src)
								make_cleanable(/obj/decal/cleanable/ash, get_turf(H))
								playsound(get_turf(H), 'sound/effects/mag_fireballlaunch.ogg', 50, 1)
								H.firegib(FALSE)
						else
							boutput(H, "<span class='alert'><b>Oh god, it's SO COLD!</b></span>")
							if (H.is_cold_resistant())
								boutput(H, "<span class='alert'><b>You get a feeling that your cold resistance isn't working right...</b></span>")
							H.bodytemperature = min(H.bodytemperature, 0)

							sleep(4 SECONDS)
							if (H && src)
								playsound(get_turf(H), 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, 1)
								H.become_statue(getMaterial("ice"), "Someone completely frozen in ice. How this happened, you have no clue!")
		..()

/* ============================================================= */
/* ------------------------- Implanter ------------------------- */
/* ============================================================= */

/obj/item/implanter
	name = "implanter"
	desc = "An implanting tool, used to implant people or animals with various implants."
	icon = 'icons/obj/surgery.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "implanter0"
	uses_multiple_icon_states = 1
	var/obj/item/implant/imp = null
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	var/sneaky = 0
	tooltip_flags = REBUILD_DIST

	New()
		..()
		src.update()
		return

	get_desc(dist)
		if (dist <= 1 && src.imp)
			. += "It appears to contain \a [src.imp.name]."

	proc/update()
		tooltip_rebuild = 1
		if (src.imp)
			src.icon_state = src.imp.impcolor ? "implanter1-[imp.impcolor]" : "implanter1-g"
		else
			src.icon_state = "implanter0"
		return

	proc/implant(mob/M as mob, mob/user as mob)
		if(!in_interact_range(M, user))
			boutput(user, "<span class='alert'>You are too far away from [M]!</span>")
			return

		if (sneaky)
			boutput(user, "<span class='alert'>You implanted the implant into [M].</span>")
		else
			M.tri_message(user, "<span class='alert'>[M] has been implanted by [user].</span>",\
				"<span class='alert'>You have been implanted by [user].</span>",\
				"<span class='alert'>You implanted the implant into [M].</span>")

		src.imp.implanted(M, user)

		src.imp = null
		src.update()

	attack(mob/M, mob/user)
		if (!ishuman(M) && !ismobcritter(M))
			return ..()

		if (src.imp && !src.imp.can_implant(M, user))
			return

		if (user && src.imp)
			if(src.imp.instant)
				src.implant(M, user)
			else
				actions.start(new/datum/action/bar/icon/implanter(src,M), user)
			return

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/implant))
			if (src.imp)
				user.show_text("[src] already has an implant loaded.")
				return
			else
				user.u_equip(W)
				W.set_loc(src)
				src.imp = W
				src.update()
				user.show_text("You insert [W] into [src].")
			return
		else if (istype(W,/obj/item/implantcase))
			var/obj/item/implantcase/Imp = W
			if (Imp.imp)
				if (src.imp)
					user.show_text("[src] already has an implant loaded.")
					return
				Imp.imp.set_loc(src)
				src.imp = Imp.imp
				Imp.imp = null
				src.update()
				Imp.update()
				user.show_text("You insert [Imp]'s implant into [src].")
			else if (src.imp)
				if (Imp.imp)
					user.show_text("[Imp] already has an implant loaded.")
					return
				src.imp.set_loc(Imp)
				Imp.imp = src.imp
				src.imp = null
				src.update()
				Imp.update()
				user.show_text("You insert [src]'s implant into [Imp].")
			return
		else
			return ..()

	attack_self(mob/user)
		. = ..()
		src.imp?.AttackSelf(user)

/datum/action/bar/icon/implanter
	duration = 20
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	id = "implanter"
	icon = 'icons/obj/surgery.dmi' //In these two vars you can define an icon you want to have on your little progress bar.
	icon_state = "implanter1-g"
	var/mob/living/target
	var/obj/item/implanter/implanter

	New(Implanter, Target)
		implanter = Implanter
		target = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(owner && target)
			implanter.implant(target, owner)

/obj/item/implanter/sec
	icon_state = "implanter1-g"
	name = "Security Implanter"

	New()
		src.imp = new /obj/item/implant/sec( src )
		..()

/obj/item/implanter/freedom
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/emote_triggered/freedom( src )
		..()

/obj/item/implanter/signaler
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/emote_triggered/signaler( src )
		..()

/obj/item/implanter/mindhack
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/mindhack( src )
		..()

/obj/item/implanter/super_mindhack
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/mindhack/super( src )
		..()

/obj/item/implanter/microbomb
	name = "microbomb implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE

	New()
		src.imp = new /obj/item/implant/revenge/microbomb( src )
		..()

/obj/item/implanter/uplink_microbomb
	name = "microbomb implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE

	New()
		var/obj/item/implant/revenge/microbomb/newbomb = new/obj/item/implant/revenge/microbomb( src )
		newbomb.power = prob(75) ? 2 : 3
		src.imp = newbomb
		..()

/obj/item/implanter/zappy
	name = "flyzapper implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE

	New()
		src.imp = new /obj/item/implant/revenge/zappy(src)
		..()

/* ================================================================ */
/* ------------------------- Implant Case ------------------------- */
/* ================================================================ */

/obj/item/implantcase
	name = "glass case"
	desc = "A glass case containing the labelled implant. An implanting tool is used to extract the implant from this case, and then into a person."
	icon = 'icons/obj/surgery.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "implantcase-b"
	var/obj/item/implant/imp = null
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/implant_type = /obj/item/implant/tracking
	tooltip_flags = REBUILD_DIST
	//Whether this is the paper type that goes away when emptied
	var/disposable = FALSE

/obj/item/implantcase/attack_self(mob/user)
	. = ..()
	src.imp?.AttackSelf(user)

/obj/item/implantcase/tracking
	name = "glass case - 'Tracking'"

/obj/item/implantcase/health
	name = "glass case - 'Health'"
	implant_type = /obj/item/implant/health

/obj/item/implantcase/sec
	name = "glass case - 'Security Access'"
	implant_type = /obj/item/implant/sec
/*
/obj/item/implantcase/nt
	name = "glass case - 'Weapon Auth 2'"
	implant_type = /obj/item/implant/nt

/obj/item/implantcase/ntc
	name = "glass case - 'Weapon Auth 3'"
	implant_type = /obj/item/implant/ntc
*/
/obj/item/implantcase/freedom
	name = "glass case - 'Freedom'"
	implant_type = /obj/item/implant/emote_triggered/freedom

/obj/item/implantcase/signaler
	name = "glass case - 'Signaler'"
	implant_type = /obj/item/implant/emote_triggered/signaler

/obj/item/implantcase/counterrev
	name = "glass case - 'Counter-Rev'"
	implant_type = /obj/item/implant/counterrev

/obj/item/implantcase/microbomb
	name = "glass case - 'Microbomb'"
	implant_type = /obj/item/implant/revenge/microbomb

/obj/item/implantcase/robotalk
	name = "glass case - 'Machine Translator'"
	implant_type = /obj/item/implant/robotalk

/obj/item/implantcase/bloodmonitor
	name = "glass case - 'Blood Monitor'"
	implant_type = /obj/item/implant/bloodmonitor

/obj/item/implantcase/mindhack
	name = "glass case - 'Mindhack'"
	implant_type = /obj/item/implant/mindhack

/obj/item/implantcase/super_mindhack
	name = "glass case - 'Mindhack DELUXE'"
	implant_type = /obj/item/implant/mindhack/super

/obj/item/implantcase/robust
	name = "glass case - 'Robusttec'"
	implant_type = /obj/item/implant/robust

/obj/item/implantcase/antirot
	name = "glass case - 'Rotbusttec'"
	implant_type = /obj/item/implant/antirot

/obj/item/implantcase/access
	name = "glass case - 'Electronic Access'"
	implant_type = /obj/item/implant/access

	get_desc(dist)
		if (dist <= 1 && src.imp)
			var/obj/item/implant/access/I = imp
			if (imp)
				. += "It appears to contain \a [src.imp.name] with [I.uses] charges."

	unlimited
		implant_type = /obj/item/implant/access/infinite
		get_desc(dist)
			if (dist <= 1 && src.imp)
				. += "It appears to contain \a [src.imp.name] with unlimited charges."

/obj/item/implantcase/New(obj/item/implant/usedimplant = null)
	if (usedimplant && istype(usedimplant))
		src.imp = usedimplant
		imp.set_loc(src)
		disposable = TRUE
		name = "removed implant"
		desc = "A paper wad containing an implant extracted from someone. An implanting tool can reuse the implant."
	else
		src.imp = new implant_type(src)
	update()
	..()
	return

/obj/item/implantcase/get_desc(dist)
	if (dist <= 1 && src.imp)
		. += "It appears to contain \a [src.imp.name]."

/obj/item/implantcase/proc/update()
	tooltip_rebuild = 1
	if (src.imp)
		if (disposable)
			src.icon_state = src.imp.impcolor ? "implantpaper-[imp.impcolor]" : "implantpaper-g"
		else
			src.icon_state = src.imp.impcolor ? "implantcase-[imp.impcolor]" : "implantcase-g"
	else
		if (disposable) //ditch that grody paper "case"
			qdel(src)
			return
		src.icon_state = "implantcase-0"
	return

/obj/item/implantcase/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", null, "[src.name]") as null|text
		if (user.equipped() != I)
			return
		if ((!in_interact_range(src, user) && src.loc != user))
			return
		t = copytext(adminscrub(t),1,128)
		if (t)
			src.name = "glass case - '[t]'"
		else
			src.name = "glass case"
		tooltip_rebuild = 1
		return
	else if (istype(I, /obj/item/implanter))
		var/obj/item/implanter/Imp = I
		if (Imp.imp)
			if (src.imp || Imp.imp.implanted)
				return
			Imp.imp.set_loc(src)
			src.imp = Imp.imp
			Imp.imp = null
			src.update()
			Imp.update()
			user.show_text("You insert [Imp]'s implant into [src].")
		else
			if (src.imp)
				if (Imp.imp)
					return
				src.imp.set_loc(I)
				Imp.imp = src.imp
				src.imp = null
				update()
				Imp.update()
				user.show_text("You insert [src]'s implant into [Imp].")
		return
	else if (istype(I, /obj/item/implant))
		if (src.imp)
			return
		user.u_equip(I)
		I.set_loc(src)
		src.imp = I
		src.update()
		user.show_text("You insert [I] into [src].")
		return
	else
		return ..()

/* =============================================================== */
/* ------------------------- Implant Pad ------------------------- */
/* =============================================================== */

TYPEINFO(/obj/item/implantpad)
	mats = 5

/obj/item/implantpad
	name = "implantpad"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "implantpad-0"
	var/obj/item/implantcase/case = null
	var/broadcasting = null
	var/listening = 1
	item_state = "electronic"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	desc = "A small device for analyzing implants."

/obj/item/implantpad/proc/update()

	if (src.case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return

/obj/item/implantpad/attack_hand(mob/user)

	if ((src.case && (user.l_hand == src || user.r_hand == src)))
		user.put_in_hand_or_drop(src.case)
		src.case = null
		src.add_fingerprint(user)
		update()
	else
		if (src in user.contents)
			SPAWN(0)
				src.attack_self(user)
				return
		else
			return ..()
	return

/obj/item/implantpad/attackby(obj/item/implantcase/C, mob/user)

	if (istype(C, /obj/item/implantcase))
		if (!( src.case ))
			user.drop_item()
			C.set_loc(src)
			src.case = C
	else
		return
	src.update()
	return

/obj/item/implantpad/attack_self(mob/user as mob)

	src.add_dialog(user)
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if (src.case)
		if (src.case.imp)
			if (istype(src.case.imp, /obj/item/implant/tracking ))
				var/obj/item/implant/tracking/T = src.case.imp
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Tracking Beacon<BR>
<b>Zone:</b> Spinal Column> 2-5 vertebrae<BR>
<b>Power Source:</b> Nervous System Ion Withdrawal Gradient<BR>
<b>Life:</b> 10 minutes after death of host<BR>
<b>Important Notes:</b> None<BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Continuously transmits low power signal on frequency- Useful for tracking.<BR>
<b>Special Features:</b><BR>
<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
a malfunction occurs thereby securing safety of subject. The implant will melt and
disintegrate into bio-safe elements.<BR>
<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
circuitry. As a result neurotoxins can cause massive damage.<HR>
Implant Specifics:
Frequency (144.1-148.9):
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(T.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

ID (1-100):
<A href='byond://?src=\ref[src];id=-10'>-</A>
<A href='byond://?src=\ref[src];id=-1'>-</A> [T.id]
<A href='byond://?src=\ref[src];id=1'>+</A>
<A href='byond://?src=\ref[src];id=10'>+</A><BR>"}
			else if (istype(src.case.imp, /obj/item/implant/emote_triggered/freedom))
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Freedom Beacon<BR>
<b>Zone:</b> Right Hand> Near wrist<BR>
<b>Power Source:</b> Lithium Ion Battery<BR>
<b>Life:</b> optimum 5 uses<BR>
<b>Important Notes: <font color='red'>Illegal</font></b><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
mechanisms<BR>
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system
<BR>
<b>Integrity:</b> The battery is extremely weak and commonly after injection its
life can drive down to only 1 use.<HR>
No Implant Specifics"}
			else if (istype(src.case.imp, /obj/item/implant/sec))
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> T.U.R.D.S. Weapon Auth Implant<BR>
<b>Zone:</b> Spinal Column> 2-5 vertebrae<BR>
<b>Power Source:</b> Nervous System Ion Withdrawal Gradient<BR>
<b>Life:</b> 10 minutes after death of host<BR>
<b>Important Notes:</b> Allows access to weapons equip with M.W.L. (Martian Weapon Lock) devices<BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Continuously transmits low power signal which communicates with M.W.L. systems.<BR>
Range: 35-40 meters<BR>
<b>Special Features:</b><BR>
<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
a malfunction occurs thereby securing safety of subject. The implant will melt and
disintegrate into bio-safe elements.<BR>
<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
circuitry. As a result neurotoxins can cause massive damage.<BR>
<i>Self-Destruct</i>- This implant will self terminate upon request from an authorized Command Implant <HR>
<b>Level: 1 Auth</b>"}
			else if (istype(src.case.imp, /obj/item/implant/counterrev))
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Counter-Revolutionary Implant<BR>
<b>Zone:</b> Spinal Column> 5-7 vertebrae<BR>
<b>Power Source:</b> Nervous System Ion Withdrawal Gradient<BR>
<b>Important Notes:</b> Will make the crewmember loyal to the command staff and prevent thoughts of rebelling.<BR>"}
			else if (istype(src.case.imp, /obj/item/implant/revenge/microbomb))
				dat += {"
<b>Implant Specifications:</b><br>
<b>Name:</b> Microbomb Implant<br>
<b>Zone:</b> Base of Skull<br>
<b>Power Source:</b> Nervous System Ion Withdrawal Gradient<br>
<b>Important Notes: <font color='red'>Illegal</font></b><BR><HR>"}
			else if (istype(src.case.imp, /obj/item/implant/robotalk))
				dat += {"
<b>Implant Specifications:</b><br>
<b>Name:</b> Machine Language Translator<br>
<b>Zone:</b> Cerebral Cortex<br>
<b>Power Source:</b> Nervous System Ion Withdrawal Gradient<br>
<b>Important Notes:</b> Enables the host to transmit, receive and understand digital transmissions used by most mechanoids.<BR>"}
			else if (istype(src.case.imp, /obj/item/implant/bloodmonitor))
				dat += {"
<b>Implant Specifications:</b><br>
<b>Name:</b> Blood Monitor<br>
<b>Zone:</b> Jugular Vein<br>
<b>Power Source:</b> Nervous System Ion Withdrawal Gradient<br>
<b>Important Notes:</b> Warns the host of any detected infections or foreign substances in the bloodstream.<BR>"}
			else if (istype(src.case.imp, /obj/item/implant/mindhack))
				dat += {"
<b>Implant Specifications:</b><br>
<b>Name:</b> Mind Hack<br>
<b>Zone:</b> Brain Stem<br>
<b>Power Source:</b> Nervous System Ion Withdrawal Gradient<br>
<b>Important Notes:</b> Injects an electrical signal directly into the brain that compels obedience in human subjects for a short time. Most minds fight off the effects after approx. 25 minutes.<BR>"}
			else if (istype(src.case.imp, /obj/item/implant/emote_triggered/signaler))
				var/obj/item/implant/emote_triggered/signaler/implant = src.case.imp
				dat += {"
<b>Implant Specifications:</b><br>
<b>Name:</b> Remote Signaler<br>
<b>Zone:</b> Left hand near wrist<br>
<b>Power Source:</b> Nervous System Ion Withdrawal Gradient<br>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a radio signal on a configurable frequency.
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system<BR>
<HR>
Implant Specifics:<BR>
Frequency (144.1-148.9):
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(implant.signaler.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

ID (1-100):
<A href='byond://?src=\ref[src];id=-10'>-</A>
<A href='byond://?src=\ref[src];id=-1'>-</A> [implant.signaler.code]
<A href='byond://?src=\ref[src];id=1'>+</A>
<A href='byond://?src=\ref[src];id=10'>+</A><BR>"}
			else
				dat += "Implant ID not in database"
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user.Browse(dat, "window=implantpad")
	onclose(user, "implantpad")
	return

/obj/item/implantpad/Topic(href, href_list)
	..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))))
		src.add_dialog(usr)
		if (!istype(src.case, /obj/item/implantcase))
			return
		if (href_list["freq"])
			var/frequency_change = text2num_safe(href_list["freq"])
			if (istype(src.case.imp, /obj/item/implant/tracking))
				var/obj/item/implant/tracking/implant = src.case.imp
				implant.frequency += frequency_change
				implant.frequency = sanitize_frequency(implant.frequency)
			else if (istype(src.case.imp, /obj/item/implant/emote_triggered/signaler))
				var/obj/item/implant/emote_triggered/signaler/implant = src.case.imp
				implant.signaler.frequency += frequency_change
				implant.signaler.frequency = sanitize_frequency(implant.signaler.frequency)
		if (href_list["id"])
			var/id_change = text2num_safe(href_list["id"])
			if (istype(src.case.imp, /obj/item/implant/tracking))
				var/obj/item/implant/tracking/implant = src.case.imp
				implant.id += id_change
				implant.id = clamp(implant.id, 1, 100)
			else if (istype(src.case.imp, /obj/item/implant/emote_triggered/signaler))
				var/obj/item/implant/emote_triggered/signaler/implant = src.case.imp
				implant.signaler.code += id_change
				implant.signaler.code = clamp(implant.signaler.code, 1, 100)
		if (ismob(src.loc))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
				//Foreach goto(290)
		src.add_fingerprint(usr)
	else
		usr.Browse(null, "window=implantpad")
		return
	return

/* =============================================================== */
/* ------------------------- Implant Gun ------------------------- */
/* =============================================================== */

TYPEINFO(/obj/item/gun/implanter)
	mats = 8

/obj/item/gun/implanter
	name = "implant gun"
	desc = "A gun that accepts an implant, that you can then shoot into other people! Or a wall, which certainly wouldn't be too big of a waste, since you'd only be using this to shoot people with things like health monitor implants or machine translators. Right?"
	icon_state = "implant"
	contraband = 1
	var/obj/item/implant/my_implant = null

	New()
		set_current_projectile(new/datum/projectile/implanter)
		..()

	get_desc()
		. += "There is [my_implant ? "\a [my_implant]" : "currently no implant"] loaded into it."

	attackby(var/obj/item/W, var/mob/user)
		var/obj/item/implant/I = null
		if (istype(W, /obj/item/implant))
			I = W
		else if (istype(W, /obj/item/implanter))
			var/obj/item/implanter/implanter = W
			if (implanter.imp)
				I = implanter.imp
		else if (istype(W, /obj/item/implantcase))
			var/obj/item/implantcase/case = W
			if (case.imp)
				I = case.imp
		else
			return ..()
		if (I)
			if (my_implant)
				user.show_text("[src] already has an implant in it!", "red")
				return

			my_implant = I
			tooltip_rebuild = 1

			if (istype(W, /obj/item/implant))
				user.u_equip(W)
			else if (istype(W, /obj/item/implanter))
				var/obj/item/implanter/implanter = W
				implanter.imp = null
				implanter.update()
			else if (istype(W, /obj/item/implantcase))
				var/obj/item/implantcase/case = W
				case.imp = null
				case.update()

			I.set_loc(src)
			user.show_text("You load [I] into [src].", "blue")

			if (!current_projectile)
				set_current_projectile(new/datum/projectile/implanter)
			var/datum/projectile/implanter/my_datum = current_projectile
			my_datum.my_implant = my_implant
			my_datum.implant_master = user

		else
			return ..()

	canshoot(mob/user)
		if (!my_implant)
			return 0
		return 1

	process_ammo(var/mob/user)
		if (!my_implant)
			return 0
		if (!current_projectile)
			set_current_projectile(new/datum/projectile/implanter)
		var/datum/projectile/implanter/my_datum = current_projectile
		if (ismob(user) && my_datum.implant_master != user)
			my_datum.implant_master = user
		return 1

	alter_projectile(var/obj/projectile/P)
		if (!P || !my_implant)
			return ..()
		my_implant.set_loc(P)
		my_implant = null
		tooltip_rebuild = 1

/datum/projectile/implanter
	name = "implant bullet"
	damage = 5
	shot_sound = 'sound/machines/click.ogg'
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	casing = /obj/item/casing/small
	impact_image_state = "bhole-small"
	shot_number = 1
	//silentshot = 1
	var/obj/item/implant/my_implant = null
	var/mob/implant_master = null

	on_hit(atom/hit, angle, var/obj/projectile/O)
		if (!my_implant)
			return
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			if (my_implant.can_implant(H, implant_master))
				my_implant.implanted(H, implant_master)
			else
				my_implant.set_loc(get_turf(H))
		else if (ismobcritter(hit))
			var/mob/living/critter/C = hit
			if (C.can_implant && my_implant.can_implant(C, implant_master))
				my_implant.implanted(C, implant_master)
			else
				my_implant.set_loc(get_turf(C))
		else
			my_implant.set_loc(get_turf(O))

	on_max_range_die(var/obj/projectile/O)
		my_implant.set_loc(get_turf(O))
		..()

/* =============================================================== */
/* ------------------------- Throwing Darts ---------------------- */
/* =============================================================== */

/obj/item/implant/projectile/body_visible/dart/bardart
	name = "dart"
	desc = "An object of d'art."
	w_class = W_CLASS_TINY
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dart"
	throw_spin = 0

	New()
		..()
		implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "dart_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

	throw_impact(atom/M, datum/thrown_thing/thr)
		..()
		if (ishuman(M) && prob(5))
			var/mob/living/carbon/human/H = M
			H.implant.Add(src)
			src.visible_message("<span class='alert'>[src] gets embedded in [M]!</span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
			random_brute_damage(M, 1)
			src.implanted(M)

	attack_hand(mob/user)
		src.pixel_x = 0
		src.pixel_y = 0
		..()

/obj/item/implant/projectile/body_visible/dart/lawndart
	name = "lawn dart"
	desc = "An oversized plastic dart with a metal spike at the tip. Fun for the whole family!"
	w_class = W_CLASS_TINY
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "lawndart"
	throw_spin = 0
	throw_speed = 3

	New()
		..()
		implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "dart_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

	throw_impact(atom/M, datum/thrown_thing/thr)
		..()
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.implant.Add(src)
			src.visible_message("<span class='alert'>[src] gets embedded in [M]!</span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
			H.changeStatus("weakened", 2 SECONDS)
			random_brute_damage(M, 20)//if it can get in you, it probably doesn't give a damn about your armor
			take_bleeding_damage(M, null, 10, DAMAGE_CUT)
			src.implanted(M)
