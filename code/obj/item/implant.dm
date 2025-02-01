#define MARIONETTE_IMPLANT_STATUS_IDLE "IDLE"
#define MARIONETTE_IMPLANT_STATUS_ACTIVE "ACTIVE"
#define MARIONETTE_IMPLANT_STATUS_DANGER "DANGER"
#define MARIONETTE_IMPLANT_STATUS_WAITING "WAITING..."
#define MARIONETTE_IMPLANT_STATUS_NO_RESPONSE "NO RESPONSE"
#define MARIONETTE_IMPLANT_STATUS_BURNED_OUT "BURNED OUT"
#define MARIONETTE_IMPLANT_ERROR_NO_TARGET "TARG_NULL"
#define MARIONETTE_IMPLANT_ERROR_DEAD_TARGET "TARG_DEAD"
#define MARIONETTE_IMPLANT_ERROR_BAD_PASSKEY "BADPASS"
#define MARIONETTE_IMPLANT_ERROR_INVALID "INVALID"

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
			MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, null, pda_alert_frequency)
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
		logTheThing(LOG_COMBAT, I, "has implanted [constructTarget(M,"combat")] with a [src] implant ([src.type]) at [log_loc(M)].")
		src.set_loc(M)
		implanted = TRUE
		SEND_SIGNAL(src, COMSIG_ITEM_IMPLANT_IMPLANTED, M)
		owner = M
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.implant?.Add(src)
			if (src.scan_category == "other" || src.scan_category == "unknown")
				var/image/img = H.prodoc_icons["other"]
				img.icon_state = "implant-other"
		else if (ismobcritter(M))
			var/mob/living/critter/C = M
			C.implants?.Add(src)
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
			var/has_other_imp = FALSE
			for (var/obj/item/implant/I as anything in H.implant)
				if (I.scan_category == "other" || I.scan_category == "unknown")
					has_other_imp = TRUE
					break
			if (!has_other_imp)
				var/image/I = H.prodoc_icons["other"]
				I.icon_state = null
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

/obj/item/implant/emote_triggered
	var/activation_emote = "wink"
	var/list/compatible_emotes = list()

	implanted(mob/M, mob/I)
		. = ..()
		//try not to conflict with other emote triggers
		src.activation_emote = pick(src.compatible_emotes - M.trigger_emotes) || pick(src.compatible_emotes)
		LAZYLISTADD(M.trigger_emotes, src.activation_emote)
		src.RegisterSignal(M, COMSIG_MOB_EMOTE, PROC_REF(trigger))
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

	implanted(mob/M, mob/I)
		..()
		if (!istype(M, /mob/living/carbon/human))
			return
		var/mob/living/carbon/human/H = M
		if (!H.prodoc_icons)
			return
		var/image/img = H.prodoc_icons["cloner"]
		img.icon_state = "implant-cloner"

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
	scan_category = "health"
	var/healthstring = ""
	uses_radio = 1
	mailgroups = list(MGD_MEDBAY, MGD_MEDRESEACH, MGD_SPIRITUALAFFAIRS)

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

	death_alert()
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
		var/datum/component/C = src.owner.GetComponent(/datum/component/minimap_marker/minimap)
		C?.RemoveComponent(/datum/component/minimap_marker/minimap)

	on_death()
		src.deactivate()

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
		// The way this works sorta sucks. We have N implants, but we only want a single effect, scaled by the value of N.
		// So we just run this on_death code for every implant, but the first implant to run it marks all the others as 'active',
		// and if an implant is already 'active' then it does nothing on death.
		if (!src.active)
			var/power = 0
			for (var/obj/item/implant/implant in src.loc)
				if (istype(implant, src.type)) //only interact with implants that are the same type as us
					var/obj/item/implant/revenge/revenge_implant = implant
					if (!revenge_implant.active)
						revenge_implant.active = TRUE
						power += revenge_implant.power //tally the total power we're dealing with here

			// If you're suiciding and unlucky, all the power just goes out the window and we don't trigger
			var/mob/living/source = owner
			if(source.suiciding && prob(60)) //Probably won't trigger on suicide though
				source.visible_message("[source] emits a somber buzzing noise.")
				return
			src.do_effect(power)

			var/area/A = get_area(source)
			if (!A.dont_log_combat)
				logTheThing(LOG_BOMBING, source, "triggered \a [src] on death at [log_loc(source)].")
				message_admins("[key_name(source)] triggered \a [src] on death at [log_loc(source)].")

	/// This is where you put the actual effect the implant has on death (some kind of an explosion probably)
	/// You probably want to call this parent after exploding or whatever
	proc/do_effect(power)
		SHOULD_CALL_PARENT(TRUE)
		if (power >= 6)
			src.owner.visible_message(SPAN_ALERT("<b>[src.owner][big_message]!</b>"))
		else
			src.owner.visible_message("[src.owner][small_message].")

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


	do_effect(power)
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
			explosion_new(src, T, 7 * power, 1) //power is the tally of explosionPower in this poor slob.
			if (ishuman(src.owner))
				var/mob/living/carbon/human/H = src.owner
				H.dump_contents_chance = 80 //hee hee
			src.owner?.gib() //yer DEAD
		. = ..()

/obj/item/implant/revenge/microbomb/hunter
	power = 4

/obj/item/implant/revenge/zappy
	name = "flyzapper implant" //todo better name idk
	big_message = " begins radiating electricity"
	small_message = "'s hair starts standing on end"
	power = 3

	// this is kinda horribly inefficient but it runs pretty rarely so eh
	do_effect(power)
		elecflash(src, power, power * 2, TRUE)
		for (var/mob/living/M in orange(power / 6 + 1, src.owner))
			if (!isintangible(M))
				var/dist = GET_DIST(src.owner, M) + 1
				// arcflash uses some fucked up thresholds so trust me on this one
				arcFlash(src.owner, M, (40000 * (4 - (0.4 * dist * log(dist)))) * (15 * log(max(1, power)) + 3))
		for (var/obj/machinery/machine in orange(round(power / 6) + 1)) // machinery around you also zaps people, based on the amount of power in the grid
			if (prob(power * 7))
				var/mob/living/target
				for (var/mob/living/L in orange(machine, 2))
					if (!isintangible(L))
						target = L
						break
				if (target)
					arcFlash(src, target, 100000) //TODO scale this with powergrid... somehow. get area APC or smth

		SPAWN(1)
			src.owner?.elecgib()
		. = ..()

/obj/item/implant/revenge/wasp
	name = "wasp implant"
	big_message = " buzzes, what?"
	small_message = "buzzes loudly, uh oh!"
	power = 8

	implanted(mob/M, mob/I)
		..()
		if (istype(M))
			LAZYLISTADDUNIQUE(M.faction, FACTION_BOTANY)

	on_remove(mob/M)
		..()
		if (istype(M))
			LAZYLISTREMOVE(M.faction, FACTION_BOTANY)

	do_effect(power)
		// enjoy your wasps
		for (var/i in 1 to power)
			var/mob/living/critter/small_animal/wasp/W = new /mob/living/critter/small_animal/wasp/angry(get_turf(src))
			W.lying = TRUE // So wasps dont hit other wasps when being flung
			W.throw_at(get_edge_target_turf(get_turf(src), pick(alldirs)), rand(1,3 + round(power / 16)), 2)
			SPAWN(1 SECOND)
				W.lying = FALSE

		SPAWN(1)
			src.owner?.gib()
		. = ..()


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
	scan_category = "syndicate"
	var/uses = 1
	var/expire = TRUE
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
			boutput(user, SPAN_ALERT("[H] is protected from mindhacking by \an [AM.name]!"))
			return FALSE
		// It might happen, okay. I don't want to have to adapt the override code to take every possible scenario (no matter how unlikely) into considertion.
		if (H.mind && ((H.mind.special_role == ROLE_VAMPTHRALL) || (H.mind.special_role == "spyminion")))
			if (ismob(user)) user.show_text("<b>[H] seems to be immune to being mindhacked!</b>", "red")
			H.show_text("<b>You resist [implant_hacker]'s attempt to mindhack you!</b>", "red")
			logTheThing(LOG_COMBAT, H, "resists [constructTarget(implant_hacker,"combat")]'s attempt to mindhack them at [log_loc(H)].")
			return FALSE
		// Same here, basically. Multiple active implants is just asking for trouble.
		H.mind?.remove_antagonist(ROLE_MINDHACK, ANTAGONIST_REMOVAL_SOURCE_OVERRIDE)
		for (var/obj/item/implant/mindhack/MS in H.implant)
			var/obj/item/implant/mindhack/Inew = new MS.type(H)
			H.implant += Inew
			qdel(MS)
		return TRUE

	implanted(var/mob/M, var/mob/I)
		..()
		if (!ishuman(M) || (src.uses <= 0))
			return

		boutput(M, SPAN_ALERT("A stunning pain shoots through your brain!"))
		M.changeStatus("stunned", 10 SECONDS)
		M.changeStatus("knockdown", 10 SECONDS)

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
		M.delStatus("mindhack")
		M.mind?.remove_antagonist(ROLE_MINDHACK, ANTAGONIST_REMOVAL_SOURCE_SURGERY)
		return

	proc/add_orders(var/orders)
		if (!orders || !istext(orders))
			return
		src.custom_orders = copytext(sanitize(html_encode(orders)), 1, MAX_MESSAGE_LEN)
		if (!(copytext(src.custom_orders, -1) in list(".", "?", "!")))
			src.custom_orders += "!"

/obj/item/implant/marionette
	name = "marionette implant"
	desc = "This thing looks really complicated."
	icon_state = "implant-mh"
	impcolor = "r"
	scan_category = "syndicate"
	pda_alert_frequency = FREQ_MARIONETTE_IMPLANT

	/// A network address that this implant is linked to. Can be null.
	/// Packets sent by this address skip the passkey requirement, and if the implant burns out,
	/// it will send a signal to this address to alert it.
	var/linked_address = null
	/// A string that's (usually) unique to each implant. Signals must provide the correct passkey to issue commands to the implant.
	var/passkey = null
	/// If TRUE, this implant is burned out and permanently unusable.
	var/burned_out = FALSE
	/// The implant's heat level, increased by various actions. Slowly reduces over time.
	var/heat = 0
	/// The implant's previous heat level, set after it's adjusted.
	/// This is used so that the implant can send an alert signal when it enters the danger zone for the first time.
	var/prev_heat = 0
	/// The implant's heat dissipation. `heat` is reduced by this value every processing tick.
	/// The value slowly ramps up over time, but is reset upon being activated. This makes short-term overuse very punishing,
	/// but allows it to recover decently quickly if given time to rest.
	var/heat_dissipation = 1
	/// If `heat` is above this value, each activation has a chance to break the implant permanently.
	var/const/heat_danger_zone = 100
	/// This is some messy code, but emotes are like that. Anything in this list will not be triggered by the force-emote function.
	var/list/emote_blacklist = list(
		"custom", "customv", "customh", "me", "give", "help", "listbasic", "listtarget", "list", "suicide", "uguu", "juggle", "airquote", "airquotes",
		"faint", "deathgasp", "collapse", "trip", "monologue", "miranda", "birdwell"
	)

	New()
		. = ..()
		var/datum/reagent/R = pick(concrete_typesof(/datum/reagent/fooddrink/alcoholic))
		src.passkey = lowertext(replacetext(replacetext(R.name, " ", "_"), "'", ""))
		if (!src.passkey)
			src.passkey = "IMP-[rand(111, 999)]"
		// The `uses_radio` variable only adds a sender component, not a two-way one. So we have to do that manually!
		if (!src.net_id)
			src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, src.pda_alert_frequency)
		processing_items.Add(src)

	disposing()
		processing_items.Remove(src)
		..()

	deactivate()
		..()
		processing_items.Remove(src)

	process()
		src.adjust_heat(-src.heat_dissipation)
		src.heat_dissipation = min(3, src.heat_dissipation + 0.05)

	can_implant(mob/target, mob/user)
		if (istype(target, /mob/living/critter/wraith/trickster_puppet))
			boutput(user, SPAN_ALERT("The implanter shows an error: \"TARGET IS SECRETLY A GHOST\". Huh. You didn't know it even checked for that!"))
			return
		return ..()

	implanted(mob/M, mob/I)
		. = ..()
		if (!src.burned_out)
			// this is an anti-frustration feature with the goal of both making it easier to reference chat logs to know who is implanted with what,
			// as well as to make sure players can still use packets if they forget to scan it onto their remote and didn't write down the network data
			boutput(I, SPAN_NOTICE("You make a mental note that this implant's network ID is <b>[src.net_id]</b> and its passkey is <b>[src.passkey]</b>."))

	receive_signal(datum/signal/signal)
		// Note the lack of a src.burned_out check here -- this is because burning out removes the implant's radio component,
		// meaning that it can't send or receive signals to begin with
		if (ON_COOLDOWN(src, "activate", 1 SECOND))
			return
		if (!signal || signal.encryption)
			return
		if (signal.data["address_1"] != src.net_id)
			return
		if (signal.data["sender"] == src.net_id)
			return

		var/command = signal.data["command"]
		if (command == "ping")
			src.send_ping(signal.data["sender"])
			return

		if (command == "unlink")
			if (signal.data["sender"] == src.linked_address)
				src.linked_address = null
			return

		if (src.passkey && src.passkey != signal.data["passkey"])
			if (signal.data["sender"] != src.linked_address)
				src.send_activation_reply(signal.data["sender"], MARIONETTE_IMPLANT_ERROR_BAD_PASSKEY)
				return

		src.heat_dissipation = initial(src.heat_dissipation)

		var/fail_reason
		if (!ismob(src.owner))
			fail_reason = MARIONETTE_IMPLANT_ERROR_NO_TARGET
			src.send_activation_reply(signal.data["sender"], fail_reason)
			return

		var/mob/living/carbon/human/H = src.owner
		if (istype(H) && H.decomp_stage != DECOMP_STAGE_NO_ROT)
			fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
			src.send_activation_reply(signal.data["sender"], fail_reason)
			return

		var/data = signal.data["data"]
		switch (command)
			if ("say", "speak")
				if (!isdead(src.owner))
					logTheThing(LOG_COMBAT, src.owner, "was forced by \a [src] to say \"[data]\" at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
					data = copytext(strip_prefix(data, "*"), 1, 46) // Trim starting asterisks to prevent force-emoting
					src.owner.being_controlled = TRUE
					try
						src.owner.say(data)
					catch (var/exception/e)
						logTheThing(LOG_DEBUG, src, "Exception [e] occurred while processing marionette implant say stack for mob [src.owner]")
					src.owner.being_controlled = FALSE
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
				src.adjust_heat(15)
			if ("emote")
				data = lowertext(data)
				if (!isdead(src.owner))
					if (data in src.emote_blacklist)
						fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
					else
						logTheThing(LOG_COMBAT, src.owner, "was forced by \a [src] to emote \"[data]\" at [log_loc(src.owner)] by (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
						src.owner.emote(data)
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
				src.adjust_heat(15)
			if ("move", "step", "bump")
				logTheThing(LOG_COMBAT, src.owner, "was forced by \a [src] to step to the [lowertext(data)] at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
				var/step_dir = text2dir(uppertext(data))
				if (step_dir && (step_dir in cardinal))
					step(src.owner, step_dir)
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
				src.adjust_heat(5)
			if ("shock", "zap")
				// Note the lack of immunity from the elec_resist mutation here here
				// This is intentional; in this case, it's moreso overstimulating the nervous system than actually causing electrical shocks!
				logTheThing(LOG_COMBAT, src.owner, "was shocked by \a [src] at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
				boutput(src.owner, SPAN_ALERT("You feel a shock from inside your body!"))
				src.owner.do_disorient(90, knockdown = 7 SECONDS, disorient = 3 SECONDS)
				src.owner.changeStatus("defibbed", 3 SECONDS)
				playsound(src.owner, 'sound/impact_sounds/Energy_Hit_3.ogg', 20, TRUE, -1)
				src.adjust_heat(50)
			if ("drop", "release")
				if (!isdead(src.owner))
					var/obj/item/I = src.owner.equipped()
					if (istype(I))
						logTheThing(LOG_COMBAT, src.owner, "was forced to drop \the [I] by \a [src] at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
						boutput(src.owner, SPAN_ALERT("Your grip on \the [I] suddenly relaxes!"))
						H.drop_item()
					else
						fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
					src.adjust_heat(60)
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
			if ("use", "activate")
				if (!isdead(src.owner))
					var/obj/item/I = src.owner.equipped()
					if (istype(I))
						logTheThing(LOG_COMBAT, src.owner, "was forced to activate \the [I] by \a [src] at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
						boutput(src.owner, SPAN_ALERT("Your hand involuntarily jerks."))
						src.owner.click(I, list())
					else
						fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
					src.adjust_heat(35)
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
			else
				fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
		src.send_activation_reply(signal.data["sender"], fail_reason)

	/// Sends a ping packet to the provided address, containing information about the implant's status.
	/// If `special` is non-null, it will be provided in the `special` parameter;
	/// this is currently used to indicate when an implant goes above the danger zone when it was previously safe.
	proc/send_ping(sender_address, special = null)
		var/datum/signal/ping_reply = get_free_signal()
		ping_reply.source = src
		ping_reply.data["device"] = "IMP_MARIONETTE"
		ping_reply.data["sender"] = src.net_id
		ping_reply.data["address_1"] = sender_address
		ping_reply.data["command"] = "ping_reply"
		ping_reply.data["status"] = src.burned_out ? MARIONETTE_IMPLANT_STATUS_BURNED_OUT : \
			src.heat > src.heat_danger_zone ? MARIONETTE_IMPLANT_STATUS_DANGER : \
			ismob(src.owner) ? MARIONETTE_IMPLANT_STATUS_ACTIVE : MARIONETTE_IMPLANT_STATUS_IDLE
		if (special)
			ping_reply.data["special"] = special
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, ping_reply)

	/// Sends an activation reply to the provided address. Any activation with a non-null `fail_reason` is considered a fail.
	proc/send_activation_reply(sender_address, fail_reason)
		var/datum/signal/activation_signal = get_free_signal()
		activation_signal.source = src
		activation_signal.data["device"] = "IMP_MARIONETTE"
		activation_signal.data["sender"] = src.net_id
		activation_signal.data["address_1"] = sender_address
		activation_signal.data["command"] = "activate"
		if (fail_reason)
			activation_signal.data["stack"] = fail_reason
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, activation_signal)

	/// Adjusts `heat` by `to_heat`. Also handles potentially burning out when overheating, and alerting a linked address if we enter the danger zone.
	proc/adjust_heat(to_heat)
		if (src.heat > src.heat_danger_zone && prob(20) && to_heat > 0)
			SPAWN (0.25 SECONDS) // Give the implant time to send the activation reply
				src.burn_out()
		src.heat = max(0, src.heat + to_heat)
		if (src.heat > src.heat_danger_zone && src.prev_heat <= src.heat_danger_zone && src.linked_address)
			src.send_ping(src.linked_address, TRUE)
		src.prev_heat = src.heat

	/// Burns out the implant and makes it permanently unusable.
	proc/burn_out()
		if (ismob(src.owner))
			logTheThing(LOG_COMBAT, src.owner, "had their [src.name] burn out and become useless.")
			boutput(src.owner, SPAN_ALERT("You feel a painful burning, like there's a something hot inside your body."))
			src.owner.TakeDamage("All", burn = 7, damage_type = DAMAGE_BURN)
		src.name = "melted [src.name]" // Specifically change the name here instead of using prefix, so that it appears in the removed implant item
		src.desc = "Charred and most definitely broken. This thing must have been pushed really hard."
		src.burned_out = TRUE
		src.deactivate()
		if (src.linked_address)
			src.send_ping(src.linked_address)
		// goodbye my sweet son
		src.RemoveComponentsOfType(/datum/component/packet_connected/radio)


/obj/item/remote/marionette_implant
	name = "marionette implant remote"
	desc = "A remote control that allows the sending and receiving of data from linked marionette implants."
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"

	flags = TABLEPASS | TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER
	w_class = W_CLASS_SMALL

	HELP_MESSAGE_OVERRIDE({"Can track and control any number of marionette implants. To link an implant, simply use the remote on an implanter, implant case, \
	or implant. Vice-versa also works."})

	/// The network ID of the remote. Communicated to tracked implants when pinging.
	var/net_id
	/// Data entered by the user. Its contents will be provided as the `data` field in packets sent to implants.
	var/entered_data
	/// The current selected command that implants will be sent.
	var/selected_command = "say"
	/// An associative list of tracked implants, where keys are network IDs of implants and values are the last ping result from those addresses.
	var/list/implant_status = list()

	New()
		. = ..()
		if (!src.net_id)
			src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, FREQ_MARIONETTE_IMPLANT)

	get_desc()
		. = ..()
		. += SPAN_NOTICE("<br>Its network address is [net_id].")

	attack_self(mob/user)
		src.ui_interact(user)

	attackby(obj/item/W, mob/user, params)
		if (src.link_with(W, user))
			return
		return ..()

	afterattack(atom/target, mob/user, reach, params)
		if (istype(target, /obj/item/implanter) || istype(target, /obj/item/implantcase) || istype(target, /obj/item/implant))
			src.link_with(target, user)
		else
			return ..()

	receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
		if (!signal || signal.encryption)
			return

		if (lowertext(signal.data["address_1"]) != src.net_id)
			return

		var/sender_address = lowertext(signal.data["sender"])
		if (sender_address == src.net_id)
			return

		if (sender_address in src.implant_status)
			if (signal.data["command"] == "ping_reply")
				if (signal.data["status"] == MARIONETTE_IMPLANT_STATUS_BURNED_OUT && src.implant_status[sender_address] != MARIONETTE_IMPLANT_STATUS_BURNED_OUT)
					for (var/mob/M in get_turf(src))
						boutput(M, SPAN_ALERT("Your [src.name] alerts you that a tracked implant has burned out and is no longer usable."))
						M.playsound_local(src, "sound/machines/twobeep.ogg", 50)
				else if (signal.data["status"] == MARIONETTE_IMPLANT_STATUS_DANGER && signal.data["special"])
					for (var/mob/M in get_turf(src))
						boutput(M, SPAN_ALERT("Your [src.name] alerts you that a tracked implant is dangerously hot."))
						M.playsound_local(src, "sound/machines/twobeep.ogg", 50)
				src.implant_status[sender_address] = signal.data["status"]
			if (signal.data["command"] == "activate")
				for (var/mob/M in get_turf(src))
					M.playsound_local(src, !signal.data["stack"] ? "sound/machines/claw_machine_success.ogg" : "sound/machines/claw_machine_fail.ogg", 10, TRUE)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "MarionetteRemote", name)
			ui.open()

	ui_data(mob/user)
		. = ..()
		var/list/implant_entries = list()
		for (var/address in src.implant_status)
			implant_entries += list(list(
				"address" = address,
				"status" = src.implant_status[address]
			))
		.["entered_data"] = src.entered_data
		.["selected_command"] = src.selected_command
		.["implants"] = implant_entries

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		if (action == "set_data")
			var/new_data = params["new_data"]
			if (!istext(new_data))
				return
			new_data = copytext(new_data, 1, 46)
			src.entered_data = new_data
			playsound(src.loc, "keyboard", 25, TRUE, -(MAX_SOUND_RANGE - 5))
			. = TRUE
		else if (action == "set_command")
			src.selected_command = params["new_command"]
			playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
			. = TRUE
		else if (action == "remove_from_list")
			src.implant_status.Remove(params["address"])
			boutput(usr, SPAN_NOTICE("Implant removed from tracking list."))
			playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
			var/datum/signal/unlink_packet = get_free_signal()
			unlink_packet.source = src
			unlink_packet.data["device"] = "IMP_MARIONETTE_REMOTE"
			unlink_packet.data["sender"] = src.net_id
			unlink_packet.data["address_1"] = params["address"]
			unlink_packet.data["command"] = "unlink"
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, unlink_packet)
			. = TRUE
		else
			var/address = params["address"]
			var/command = params["packet_command"]
			var/data = params["packet_data"]
			if (action == "activate")
				var/datum/signal/activation_packet = get_free_signal()
				activation_packet.source = src
				activation_packet.data["device"] = "IMP_MARIONETTE_REMOTE"
				activation_packet.data["sender"] = src.net_id
				activation_packet.data["address_1"] = address
				activation_packet.data["command"] = command
				activation_packet.data["data"] = data
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, activation_packet)
				playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
				. = TRUE
			else if ((action == "ping" || action == "ping_all") && !ON_COOLDOWN(src, "do_ping", 2 SECONDS))
				var/list/to_ping = action == "ping" ? list(address) : src.implant_status
				for (var/implant_to_ping in to_ping)
					if (src.implant_status[implant_to_ping] == MARIONETTE_IMPLANT_STATUS_BURNED_OUT)
						continue
					var/datum/signal/ping = get_free_signal()
					ping.source = src
					ping.data["device"] = "IMP_MARIONETTE_REMOTE"
					ping.data["sender"] = src.net_id
					ping.data["address_1"] = implant_to_ping
					ping.data["command"] = "ping"
					src.implant_status[implant_to_ping] = MARIONETTE_IMPLANT_STATUS_WAITING
					// Slightly delay the actual ping, as otherwise the text could be immediately overwritten with unlucky timing
					// This way it's clear to the player that the ping did actually happen!
					SPAWN (0.4 SECONDS)
						SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, ping)
						SPAWN (2 SECONDS)
							if (src.implant_status[implant_to_ping] == MARIONETTE_IMPLANT_STATUS_WAITING)
								src.implant_status[implant_to_ping] = MARIONETTE_IMPLANT_STATUS_NO_RESPONSE
				playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
				. = TRUE

	proc/link_with(obj/item/W, mob/living/user)
		var/obj/item/implant/marionette/M
		if (istype(W, /obj/item/implanter))
			var/obj/item/implanter/I = W
			if (!istype(I.imp, /obj/item/implant/marionette))
				boutput(user, SPAN_ALERT("\The [W] doesn't have a compatible implant."))
				return TRUE
			M = I.imp
		else if (istype(W, /obj/item/implantcase))
			var/obj/item/implantcase/IC = W
			if (!istype(IC.imp, /obj/item/implant/marionette))
				boutput(user, SPAN_ALERT("\The [W] doesn't have a compatible implant."))
				return TRUE
			M = IC.imp
		else if (istype(W, /obj/item/implant))
			M = W
		if (istype(M))
			if (M.burned_out)
				boutput(user, SPAN_ALERT("The implant is burned out and permanently unusable."))
			else if (M.net_id in src.implant_status)
				boutput(user, SPAN_NOTICE("This implant is already in the remote's tracking list."))
			else
				boutput(user, SPAN_NOTICE("You scan the implant into \the [src]'s database."))
				src.implant_status[M.net_id] = "UNKNOWN"
				M.linked_address = src.net_id
				user.playsound_local(user, "sound/machines/tone_beep.ogg", 30)
			return TRUE

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
	bullet_455
		name = ".455 round"
		desc = "A powerful, old-timey revolver bullet, likely of criminal origin."
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
		bird
			name = "birdshot"
			desc = "A large collection of birdshot rounds, a less-lethal load for shotguns."

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

		radioactive
			name = "radioactive shrapnel"

			New()
				..()
				src.AddComponent(/datum/component/radioactive, 50, FALSE, FALSE, 0)

	glass_shard
		name = "shrapnel"
		icon = 'icons/obj/scrap.dmi'
		desc = "A shattered piece of glass shrapnel. Ow."
		icon_state = "glass_shrapnel"
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

	body_visible
		bleed_time = 0
		leaves_wound = FALSE
		var/barbed = FALSE
		var/pull_out_name = ""

		proc/on_pull_out(mob/living/puller)
			return

		on_life(mult)
			. = ..()
			if (src.reagents?.total_volume)
				src.reagents.trans_to(owner, 1 * mult)

		blowdart
			name = "blowdart"
			desc = "a sharp little dart with a little poison reservoir."
			icon_state = "blowdart"
			leaves_wound = FALSE
			barbed = TRUE

			New()
				..()
				implant_overlay = null

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

			implanted(var/mob/receiving_mob, var/mob/implanting_mob)
				..()
				RegisterSignal(receiving_mob, COMSIG_MOB_EX_ACT, PROC_REF(on_explosion_reaction))

			on_remove(var/mob/losing_mob)
				..()
				UnregisterSignal(losing_mob, COMSIG_MOB_EX_ACT)

			proc/on_explosion_reaction(var/mob/exploding_mob, var/severity)
				if (ishuman(exploding_mob))
					var/mob/living/carbon/human/human_owner = exploding_mob
					SPAWN(0.1 SECONDS)
						src.on_remove(human_owner)
						human_owner.implant.Remove(src)
						qdel(src)

			syringe_barbed
				name = "barbed syringe round"
				desc = "An empty syringe round, of the type that is fired from a syringe gun. It has a barbed tip. Nasty!"
				icon_state = "syringeproj_barbed"
				barbed = TRUE

		janktanktwo
			name = "spent JankTank II"
			pull_out_name = "syringe"
			desc = "A large syringe ripped straight out of some poor, presumably dead gang member!"
			icon = 'icons/obj/syringe.dmi'
			icon_state = "dna_scrambler_2"
			var/obj/item/tool/janktanktwo/syringe
			var/full = TRUE

			New()
				..()
				implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "syringe_stick_1", layer = MOB_EFFECT_LAYER)
			implanted(mob/M, mob/I)
				..()
				if (!full)
					return
				SPAWN(JANKTANK2_PAUSE_TIME - 0.5 SECONDS)
					playsound(M.loc, 'sound/items/hypo.ogg', 50, 0)

				SPAWN(JANKTANK2_PAUSE_TIME)
					if (!ishuman(M))
						return
					full = FALSE
					icon_state = "dna_scrambler_3"
					desc = "A large, empty syringe. Whatever awfulness it contained is probably in somebody's heart. Eugh."
					if (!src.owner)
						src.visible_message("<span class='alert'>[src] sprays its' volatile contents everywhere, [prob(10) ? "it smells like bacon? <b><i>WHY?!?</i></b>" : "gross!"]</span>")
						return

					syringe.do_heal(src.owner)
			proc/set_owner(obj/item/tool/janktanktwo/injector)
				src.syringe = injector

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
//		boutput(C, SPAN_ALERT("You start bleeding!")) // the blood system takes care of this bit now
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
			boutput(C, SPAN_ALERT("You feel a [pick("sharp", "stabbing", "startling", "worrying")] pain in your chest![pick("", " It feels like there's something lodged in there!", " There's gotta be something stuck in there!", " You feel something shift around painfully!")]"))
		//werewolf silver implants handling
		if (prob(60) && iswerewolf(C) && istype(src:material, /datum/material/metal/silver))
			random_burn_damage(C, rand(5,10))
			C.take_toxin_damage(rand(1,3))
			C.stamina -= 30
			boutput(C, SPAN_ALERT("You feel a [pick("searing", "hot", "burning")] pain in your chest![pick("", "There's gotta be silver in there!", )]"))
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

		chef
			New()
				..()
				access.access = get_access("Chef")

		admin_mouse
			New()
				..()
				access.access = get_access("Admin")


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

	proc/implant_activate(var/volume)
		var/turf/T = get_turf(src.owner)
		switch(src.artifact_implant_type)
			if ("eldritch")
				playsound(T, pick('sound/machines/ArtifactEld1.ogg', 'sound/machines/ArtifactEld2.ogg'), volume, 1)
			if ("ancient")
				playsound(T, 'sound/machines/ArtifactAnc1.ogg', volume, 1)
			if ("wizard")
				playsound(T, 'sound/machines/ArtifactWiz1.ogg', volume, 1)

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
				current_organ = H.get_organ(organ)
				if (!current_organ || current_organ.get_damage() > current_organ.fail_damage)
					organ_found = organ
					break
				current_organ?.heal_damage(0.1667 * mult, 0.1667 * mult, 0.1667 * mult) // 5 minutes to heal a 100 hp organ with 2 second process ticks

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

			SPAWN((20 + rand(-10, 10)) SECONDS)
				active = FALSE
				if (H && src && (src in H.implant))
					var/obj/decal/cleanable/blood/dynamic/B = make_cleanable(/obj/decal/cleanable/blood/dynamic, get_turf(H))

					B.add_volume(DEFAULT_BLOOD_COLOR, "blood", 50, 5)
					B.blood_DNA = "unknown"
					B.blood_type = "unknown"

					if (prob(10))
						boutput(H, SPAN_ALERT("<i>Bloooood.....</i>"))
		..()

/obj/item/implant/artifact/eldritch/eldritch_bad
	var/list/organs
	var/activated = FALSE

	New()
		..()
		src.organs = list("left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
		shuffle_list(src.organs)

	do_process(var/mult = 1)
		if (!ishuman(src.owner) || src.active)
			return ..()

		var/mob/living/carbon/human/H = owner
		var/failed_organs = 0

		if (H.get_brute_damage() > 75)
			if (!src.activated)
				src.activated = TRUE
				src.implant_activate(50)
				boutput(H, SPAN_ALERT("<b>Your insides doesn't feel so good... Wait... what?</b>"))

			H.TakeDamage("All", 2, damage_type = DAMAGE_STAB)

			var/obj/item/organ/current_organ = null

			for (var/organ in organs)
				current_organ = H.get_organ(organ)
				current_organ?.take_damage(4, 0, 0, DAMAGE_STAB)
				if (!current_organ || current_organ.get_damage() > current_organ.fail_damage)
					failed_organs += 1

		if (H.get_brute_damage() > 175 || failed_organs > 5)
			src.active = TRUE
			src.cant_take_out = TRUE
			SPAWN(2 SECONDS)
				if (H && src)
					H.make_jittery(1000)
					boutput(H, SPAN_ALERT("<b>You feel an ancient force begin to seize your body!</b>"))

				sleep(3 SECONDS)
				if (H && src)
					H.emote("scream")
					playsound(H.loc, pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_noises"), 50, 1)

				sleep(3 SECONDS)
				if (H && src)
					H.emote("faint")
					H.changeStatus("unconscious", 10 SECONDS)
					H.losebreath += 5
					playsound(H.loc, pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_noises"), 50, 1)

				sleep(3 SECONDS)
				if (H && src)
					H.gib()

		..()

	on_remove()
		src.activated = FALSE
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
	var/activated = FALSE

	do_process(var/mult = 1)
		if (!ishuman(src.owner) || src.active)
			return ..()
		var/mob/living/carbon/human/H = owner
		if (H.get_oxygen_deprivation() > 75)
			if (!src.activated)
				src.activated = TRUE
				src.implant_activate(50)
				boutput(H, SPAN_ALERT("<b>You feel its harder to breath. Oh GOD YOUR LUNGS. WHAT THE HELL?</b>"))
				H.losebreath += 75
			H.take_oxygen_deprivation(3 * mult)

		if (H.get_oxygen_deprivation() > 175)
			active = TRUE
			src.cant_take_out = TRUE
			boutput(H, SPAN_ALERT("<b>You feel something start to rip apart your insides!</b>"))

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
	var/static/list/possible_mutantraces = list(null, /datum/mutantrace/lizard, /datum/mutantrace/skeleton, /datum/mutantrace/ithillid,
												/datum/mutantrace/monkey, /datum/mutantrace/roach, /datum/mutantrace/cow,
										 		/datum/mutantrace/pug, /datum/mutantrace/cat/bingus)

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
			if (H.mutantrace != H.default_mutantrace)
				gibs(get_turf(H), null, H.bioHolder.Uid, H.bioHolder.bloodType, 0)
			H.set_mutantrace(null)
		..()

/obj/item/implant/artifact/wizard/wizard_bad
	var/effect_type
	var/activated = FALSE

	New()
		..()
		src.effect_type = pick("fire", "ice")

	do_process(var/mult = 1)
		if (!ishuman(src.owner))
			return ..()

		var/mob/living/carbon/human/H = owner
		if (H.get_burn_damage() <= 75)
			return ..()

		if (!src.activated)
			src.activated = TRUE
			src.implant_activate(50)
			if (src.effect_type == "fire")
				boutput(H, SPAN_ALERT("<b>You feel really, REALLY HOT!</b>"))
				if (H.is_heat_resistant())
					boutput(H, SPAN_ALERT("<b>You get a feeling that your fire resistance isn't working right...</b>"))
			else
				boutput(H, SPAN_ALERT("<b>Oh god, it's SO COLD!</b>"))
				if (H.is_cold_resistant())
					boutput(H, SPAN_ALERT("<b>You get a feeling that your cold resistance isn't working right...</b>"))

		if (src.effect_type == "fire")
			H.bodytemperature = max(H.bodytemperature, 10000)
			H.set_burning(100)
		else
			H.bodytemperature = min(H.bodytemperature, 0)
			H.TakeDamage("All", 0, 3, 0, DAMAGE_BURN)

		if (H.get_burn_damage() > 175)
			if (src.effect_type == "fire")
				make_cleanable(/obj/decal/cleanable/ash, get_turf(H))
				playsound(get_turf(H), 'sound/effects/mag_fireballlaunch.ogg', 50, TRUE)
				H.firegib(FALSE)
			else
				playsound(get_turf(H), 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, TRUE)
				H.become_statue("ice", "Someone completely frozen in ice. How this happened, you have no clue!")

		..()

	on_remove()
		src.effect_type = pick("fire", "ice")
		src.activated = FALSE
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
			boutput(user, SPAN_ALERT("You are too far away from [M]!"))
			return

		if (M == user)
			if (sneaky)
				boutput(user, SPAN_ALERT("You implanted yourself."))
			else
				user.visible_message(SPAN_ALERT("[user] has implanted [him_or_her(user)]self."),\
					SPAN_ALERT("You implanted yourself."))
		else
			if (sneaky)
				boutput(user, SPAN_ALERT("You implanted the implant into [M]."))
			else
				M.tri_message(user, SPAN_ALERT("[M] has been implanted by [user]."),\
					SPAN_ALERT("You have been implanted by [user]."),\
					SPAN_ALERT("You implanted the implant into [M]."))

		src.imp.implanted(M, user)

		src.imp = null
		src.update()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (!ishuman(target) && !ismobcritter(target))
			return ..()

		if (src.imp && !src.imp.can_implant(target, user))
			return

		if (user && src.imp)
			if(src.imp.instant)
				src.implant(target, user)
			else
				actions.start(new/datum/action/bar/icon/implanter(src,target), user)
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
	HELP_MESSAGE_OVERRIDE({"When someone dies while implanted with this, an explosion relative to the amount of microbombs in them will occur. Suiciding will cause no explosion."})

	New()
		var/obj/item/implant/revenge/microbomb/newbomb = new/obj/item/implant/revenge/microbomb( src )
		newbomb.power = prob(75) ? 2 : 3
		src.imp = newbomb
		..()

/obj/item/implanter/zappy
	name = "flyzapper implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE
	HELP_MESSAGE_OVERRIDE({"When someone dies while implanted with this, a ball of lightning relative to the amount of flyzapper implants in them will occur. Suiciding will cause no lightning."})

	New()
		src.imp = new /obj/item/implant/revenge/zappy(src)
		..()

/obj/item/implanter/wasp
	name = "wasp implanter"
	icon_state = "implanter1-g"
	sneaky = TRUE
	HELP_MESSAGE_OVERRIDE({"When someone dies while implanted with this, they will explode into a cloud of angry wasps. Suiciding will cause no cloud of wasps to appear. This implant will also make wasps friendly to the user."})

	New()
		src.imp = new /obj/item/implant/revenge/wasp(src)
		..()

/obj/item/implanter/marionette
	icon_state = "implanter1-g"
	sneaky = TRUE
	HELP_MESSAGE_OVERRIDE({"Allows remote signals to exert limited control over the implanted target. Compatible with packets. \
	You can hit this implanter with a marionette implant remote to scan it, causing the contained implant to send status updates to it."})

	New()
		src.imp = new /obj/item/implant/marionette(src)
		..()

	get_desc(dist)
		. = ..()
		var/obj/item/implant/marionette/P = src.imp
		if (istype(P))
			if (P.burned_out)
				. += "<br>[SPAN_ALERT("The implant is completely melted and will not function.")]"
			else
				if (P.linked_address)
					. += "<br>[SPAN_NOTICE("This implant is linked to a remote of network address [P.linked_address].")]"
				. += "<br>[SPAN_NOTICE("Frequency: [P.pda_alert_frequency]")]"
				. += "<br>[SPAN_NOTICE("Network address: [P.net_id]")]"
				. += "<br>[SPAN_NOTICE("Passkey: [P.passkey]")]"

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
/* ------------------------- Implant Gun ------------------------- */
/* =============================================================== */

TYPEINFO(/obj/item/gun/implanter)
	mats = 8

/obj/item/gun/implanter
	name = "implant gun"
	desc = "A gun that accepts an implant, that you can then shoot into other people! Or a wall, which certainly wouldn't be too big of a waste, since you'd only be using this to shoot people with things like health monitor implants or machine translators. Right?"
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "implant"
	contraband = 1
	var/obj/item/implant/my_implant = null
	recoil_strength = 1

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
	impact_image_state = "bullethole-small"
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

	throw_impact(atom/hit_thing, datum/thrown_thing/thr)
		..()
		if (istype(hit_thing, /obj/item/reagent_containers/balloon))
			var/obj/item/reagent_containers/balloon/balloon = hit_thing
			balloon.smash()

		else if (ishuman(hit_thing) && prob(5))
			var/mob/living/carbon/human/H = hit_thing
			H.implant.Add(src)
			src.visible_message(SPAN_ALERT("[src] gets embedded in [H]!"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
			random_brute_damage(H, 1)
			src.implanted(H)

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

	throw_impact(atom/hit_thing, datum/thrown_thing/thr)
		..()
		if (ishuman(hit_thing))
			var/mob/living/carbon/human/H = hit_thing
			H.implant.Add(src)
			src.visible_message(SPAN_ALERT("[src] gets embedded in [H]!"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
			H.changeStatus("knockdown", 2 SECONDS)
			random_brute_damage(H, 20)//if it can get in you, it probably doesn't give a damn about your armor
			take_bleeding_damage(H, null, 10, DAMAGE_CUT)
			src.implanted(H)

#undef MARIONETTE_IMPLANT_STATUS_IDLE
#undef MARIONETTE_IMPLANT_STATUS_ACTIVE
#undef MARIONETTE_IMPLANT_STATUS_DANGER
#undef MARIONETTE_IMPLANT_STATUS_WAITING
#undef MARIONETTE_IMPLANT_STATUS_NO_RESPONSE
#undef MARIONETTE_IMPLANT_STATUS_BURNED_OUT
#undef MARIONETTE_IMPLANT_ERROR_NO_TARGET
#undef MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
#undef MARIONETTE_IMPLANT_ERROR_BAD_PASSKEY
#undef MARIONETTE_IMPLANT_ERROR_INVALID
