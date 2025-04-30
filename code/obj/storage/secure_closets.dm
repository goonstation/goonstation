ADMIN_INTERACT_PROCS(/obj/storage/secure/closet, proc/break_open)
/obj/storage/secure/closet
	name = "secure locker"
	desc = "A card-locked storage locker."
	object_flags = NO_GHOSTCRITTER
	soundproofing = 5
	can_flip_bust = 1
	p_class = 3
	open_sound = 'sound/misc/locker_open.ogg'
	close_sound = 'sound/misc/locker_close.ogg'
	volume = 70
	_max_health = LOCKER_HEALTH_AVERAGE
	_health = LOCKER_HEALTH_AVERAGE
	/// Anchored if TRUE
	var/bolted = TRUE
	/// Can't be broken open with melee
	var/reinforced = FALSE
	var/obj/particle/attack/attack_particle

	New()
		..()
		src.AddComponent(/datum/component/bullet_holes, 10, src.reinforced ? 25 : 5) // reinforced lockers need 25 power to damage; reflects that
		if (bolted)
			anchored = ANCHORED
		src.attack_particle = new /obj/particle/attack
		src.attack_particle.icon = 'icons/mob/mob.dmi'

	get_desc(dist)
		. += "[reinforced ? "It's reinforced, only stronger firearms and explosives could break into this. " : ""] [bolted ? "It's bolted to the floor." : ""]"

	attackby(obj/item/I, mob/user)
		if (iswrenchingtool(I) && !src.open)
			if (istype(get_turf(src), /turf/space))
				if (user)
					user.show_text("What exactly are you gunna secure [src] to?", "red")
				return
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message("<b>[user]</b> begins to [src.bolted ? "unbolt the [src.name] from" : "bolt the [src.name] to"] [get_turf(src)].")
			SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, /obj/storage/secure/closet/proc/toggle_bolts, list(user), I.icon, I.icon_state,"", null)
			return
		else if (istype(I, /obj/item/cargotele))
			return // don't change state on cargo teleport
		else if (src.open || !src.locked)
			..()
		else if (!I)
			..()
		else if (istype(I, /obj/item/satchel/))
			..()
		else if (isweldingtool(I))
			..()
		else if (istype(I, /obj/item/card/))
			..()
		else if (user.a_intent == INTENT_HELP)
			..()
		else if (I.force > 0)
			user.lastattacked = get_weakref(src)
			if (src.reinforced)
				boutput(user, SPAN_ALERT("[src] is too reinforced to bash into!"))
				attack_particle(user,src)
				playsound(src.loc, 'sound/impact_sounds/locker_hit.ogg', 40, 1) //quiet, no hit twitch
			else
				var/damage
				var/damage_text
				if (I.force < 10)
					damage = round(I.force * 0.6)
					damage_text = " It's not very effective."
				else
					damage = I.force
				user.visible_message(SPAN_ALERT("<b>[user]</b> hits [src] with [I]! [damage_text]"))
				attack_particle(user,src)
				hit_twitch(src)
				take_damage(clamp(damage, 1, 20), user, I, null)
				playsound(src.loc, 'sound/impact_sounds/locker_hit.ogg', 90, 1)
		else
			..()

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		if (!P || !istype(P.proj_data,/datum/projectile/))
			return
		if (reinforced)
			// Prevent weakness to weak guns, shrapnel and NARCS
			if (P.power <= 25)
				hit_particle(TRUE)
				return
		var/reduced_power
		if (P.proj_data.damage_type != D_ENERGY)
			reduced_power = round(P.power * 0.8)
		else
			reduced_power = round(P.power * 0.4)
		damage = round((reduced_power*P.proj_data.ks_ratio), 1.0)
		if (damage < 1)
			return

		switch(P.proj_data.damage_type)
			if (D_KINETIC)
				take_damage(damage, null, null, P)
			if (D_PIERCING)
				take_damage(damage, null, null, P)
			if (D_ENERGY)
				if (reinforced)
					hit_particle(TRUE)
					return
				take_damage(damage, null, null, P)

		hit_particle(FALSE)
		return

	proc/hit_particle(var/block = FALSE)
		if (ON_COOLDOWN(src, "locker_projectile_hit", 0.3 SECONDS))
			return
		if (block)
			FLICK("block_spark_armor",src.attack_particle)
		else
			FLICK("block_spark",src.attack_particle)
		src.attack_particle.alpha = 255
		src.attack_particle.loc = src.loc
		src.attack_particle.pixel_x = 0
		src.attack_particle.pixel_y = 0
		src.attack_particle.transform.Turn(rand(0,360))
		SPAWN(0.2 SECONDS)
			src.attack_particle.alpha = 0

	proc/toggle_bolts(var/mob/user)
		user.visible_message("<b>[user]</b> [src.bolted ? "loosens" : "tightens"] the floor bolts of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		src.bolted = !src.bolted
		src.anchored = !src.anchored
		logTheThing(LOG_STATION, user, "[src.anchored ? "unanchored" : "anchored"] [log_object(src)] at [log_loc(src)]")

	proc/take_damage(var/amount, var/mob/M = null, obj/item/I = null, var/obj/projectile/P = null)
		if (!isnum(amount) || amount <= 0)
			return
		src._health -= amount
		if(_health <= 0)
			_health = 0
			if (P)
				var/shooter_data = null
				var/vehicle
				if (P.mob_shooter)
					shooter_data = P.mob_shooter
				else if (ismob(P.shooter))
					var/mob/PS = P.shooter
					shooter_data = PS
				var/obj/machinery/vehicle/V
				if (istype(P.shooter,/obj/machinery/vehicle/))
					V = P.shooter
					if (!shooter_data)
						shooter_data = V.pilot
					vehicle = 1
				if(shooter_data)
					logTheThing(LOG_COMBAT, shooter_data, "[vehicle ? "driving [V.name] " : ""]shoots and breaks open [src] at [log_loc(src)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
				else
					logTheThing(LOG_COMBAT, src, "is hit and broken open by a projectile at [log_loc(src)]. <b>Projectile:</b> <I>[P.name]</I>[P.proj_data && P.proj_data.type ? ", <b>Type:</b> [P.proj_data.type]" :""]")
			else if (M)
				logTheThing(LOG_COMBAT, M, "broke open [log_object(src)] with [log_object(I)] at [log_loc(src)]")
			else
				logTheThing(LOG_COMBAT, src, "was broken open by an unknown cause at [log_loc(src)]")
			break_open()

	proc/break_open(var/obj/projectile/P)
		src.welded = 0
		src.unlock()
		src.open()
		playsound(src.loc, 'sound/impact_sounds/locker_break.ogg', 70, 1)

	Crossed(atom/movable/AM) //copy pasted from closet because inheritence is a lie
		. = ..()
		if (src.open && ismob(AM) && AM.throwing)
			var/datum/thrown_thing/thr = global.throwing_controller.throws_of_atom(AM)[1]
			AM.throw_impact(src, thr)
			AM.throwing = FALSE
			AM.changeStatus("knockdown", 1 SECOND)
			AM.set_loc(src.loc)
			src.close()

/obj/storage/secure/closet/personal
	name = "personal locker"
	desc = "The first card swiped gains control."
	personal = 1
	spawn_contents = list(/obj/item/device/radio/signaler,
	/obj/item/pen,
	/obj/item/device/radio/headset)

	make_my_stuff() //Let's spawn the backpack/satchel in random colours!
		. = ..()
		if (. == 1 && length(spawn_contents)) //if we've not spawned stuff before (also empty lockers get no backpack)
			var/backwear = pick(/obj/item/storage/backpack/withO2,/obj/item/storage/backpack/withO2/blue,/obj/item/storage/backpack/withO2/red,/obj/item/storage/backpack/withO2/green)
			new backwear(src)
			backwear = pick(/obj/item/storage/backpack/satchel/withO2,/obj/item/storage/backpack/satchel/withO2/blue,/obj/item/storage/backpack/satchel/withO2/red,/obj/item/storage/backpack/satchel/withO2/green)
			new backwear(src)

/obj/storage/secure/closet/personal/empty
	spawn_contents = list()

/* =================== */
/* ----- Command ----- */
/* =================== */

/obj/storage/secure/closet/command
	name = "command locker"
	_max_health = LOCKER_HEALTH_STRONG
	_health = LOCKER_HEALTH_STRONG
	req_access = list(access_heads)
	icon_state = "command"
	icon_closed = "command"
	icon_opened = "secure_blue-open"
	bolted = TRUE

/obj/storage/secure/closet/command/captain
	name = "\improper Captain's locker"
	req_access = list(access_captain)
	spawn_contents = list(/obj/item/gun/energy/egun/captain,
	/obj/item/storage/box/id_kit,
	/obj/item/storage/box/clothing/captain,
	/obj/item/clothing/suit/armor/capcoat,
	/obj/item/clothing/shoes/brown,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/head/helmet/captain,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/stamp/cap,
	/obj/item/device/radio/headset/command/captain,
	/obj/item/megaphone,
	/obj/item/pet_carrier,
	/obj/item/device/pda2/captain,
	/obj/item/circuitboard/announcement/bridge) //This one makes the arrivals announcement and this is the ONLY spare for it

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(20))
				new /obj/item/clothing/head/bigcaphat(src)
			return 1

/obj/storage/secure/closet/command/captain/fake
	req_access = null
	spawn_contents = list(/obj/item/clothing/shoes/brown,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/head/helmet/swat,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/device/radio/headset/command/captain)


/obj/storage/secure/closet/command/hos
	name = "\improper Head of Security's locker"
	reinforced = TRUE
	req_access = list(access_maxsec)
	spawn_contents = list(/obj/item/storage/box/id_kit,
	/obj/item/handcuffs,
	/obj/item/device/flash,
	/obj/item/storage/box/clothing/hos,
	/obj/item/clothing/suit/det_suit/hos,
	/obj/item/clothing/suit/armor/hoscape,
	/obj/item/clothing/shoes/brown,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/head/helmet/hardhat/security/hos,
	/obj/item/clothing/glasses/sunglasses/sechud,
	/obj/item/gun/energy/egun/head_of_security,
	/obj/item/device/radio/headset/security,
	/obj/item/clothing/glasses/thermal,
	/obj/item/stamp/hos,
	/obj/item/device/radio/headset/command/hos,
	/obj/item/clothing/shoes/swat/heavy,
	/obj/item/barrier,
	/obj/item/device/pda2/hos,
	/obj/item/circuitboard/card/security,
	/obj/item/circuitboard/announcement/security)

/obj/storage/secure/closet/command/hop
	name = "\improper Head of Personnel's locker"
	req_access = list(access_head_of_personnel)
	spawn_contents = list(/obj/item/device/flash,
	/obj/item/storage/box/id_kit,
	/obj/item/cash_briefcase,
	/obj/item/storage/box/clothing/hop,
	/obj/item/clothing/shoes/brown,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/stamp/hop,
	/obj/item/device/radio/headset/command/hop,
	/obj/item/device/accessgun,
	/obj/item/clipboard,
	/obj/item/clothing/suit/hopjacket,
	/obj/item/pet_carrier,
	/obj/item/device/pda2/hop,
	/obj/item/device/panicbutton/medicalalert/hop,
	/obj/item/circuitboard/card)

/obj/storage/secure/closet/command/research_director
	name = "\improper Research Director's locker"
	req_access = list(access_research_director)
	spawn_contents = list(/obj/item/plant/herb/cannabis/spawnable,
	/obj/item/disk/data/floppy/manudrive/aiLaws,
	/obj/item/device/light/zippo,
	/obj/item/storage/box/clothing/research_director,
	/obj/item/clothing/shoes/brown,
	/obj/item/hand_tele,
	/obj/item/clothing/glasses/packetvision,
	/obj/item/storage/box/zeta_boot_kit,
	/obj/item/device/radio/electropack,
	/obj/item/clothing/mask/gas,
	/obj/item/device/flash,
	/obj/item/stamp/rd,
	/obj/item/clothing/suit/labcoat,
	/obj/item/device/radio/headset/command/rd,
	/obj/item/pet_carrier,
	/obj/item/device/pda2/research_director,
	/obj/item/places_pipes/research,
	/obj/item/rcd_ammo/big,
	/obj/item/circuitboard/card/research,
	/obj/item/circuitboard/announcement/research)

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(10))
				new /obj/item/photo/heisenbee(src)
			return 1

/obj/storage/secure/closet/command/medical_director
	name = "\improper Medical Director's locker"
	req_access = list(access_medical_director)
	spawn_contents = list(/obj/item/disk/data/floppy/manudrive/ai,
	/obj/item/storage/box/clothing/medical_director,
	/obj/item/clothing/shoes/brown,
	/obj/item/gun/implanter,
	/obj/item/gun/reagent/syringe/NT,
	/obj/item/reagent_containers/mender/both,
	/obj/item/gun/kinetic/dart_rifle,
	/obj/item/ammo/bullets/tranq_darts,
	/obj/item/ammo/bullets/tranq_darts/anti_mutant,
	/obj/item/robodefibrillator,
	/obj/item/storage/firstaid/docbag,
	/obj/item/reagent_containers/hypospray,
	/obj/item/device/flash,
	/obj/item/stamp/md,
	/obj/item/device/radio/headset/command/md,
	/obj/item/pet_carrier,
	/obj/item/device/pda2/medical_director,
	/obj/item/circuitboard/card/medical,
	/obj/item/circuitboard/announcement/medical)

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(10)) // heh
				new /obj/item/reagent_containers/glass/bottle/eyedrops(src)
				new /obj/item/reagent_containers/dropper(src)
			return 1

/obj/storage/secure/closet/command/chief_engineer
	name = "\improper Chief Engineer's locker"
	req_access = list(access_engineering_chief)
	spawn_contents = list(
		/obj/item/disk/data/floppy/manudrive/law_rack,
		/obj/item/storage/box/clothing/chief_engineer,
		/obj/item/device/radio/headset/command/ce,
		/obj/item/stamp/ce,
		/obj/item/device/flash,
		/obj/item/clothing/shoes/magnetic,
		/obj/item/clothing/gloves/yellow,
		/obj/item/clothing/suit/hazard/fire/heavy, //now theres at least one on every map
		/obj/item/clothing/head/helmet/firefighter,
		/obj/item/clothing/suit/hazard/rad, //mostly relevant for singulo and nuke maps
		/obj/item/clothing/head/rad_hood,
		/obj/item/storage/toolbox/mechanical/yellow_tools,
		/obj/item/storage/box/misctools,
		/obj/item/extinguisher,
		/obj/item/pet_carrier,
		/obj/item/device/pda2/chiefengineer,
		/obj/item/circuitboard/card/engineering,
		/obj/item/circuitboard/announcement/engineering,
	#ifdef MAP_OVERRIDE_OSHAN
		/obj/item/clothing/shoes/stomp_boots,
	#endif
	#ifdef UNDERWATER_MAP
		/obj/item/clothing/suit/space/diving/engineering,
		/obj/item/clothing/head/helmet/space/engineer/diving,
		/obj/item/clothing/shoes/flippers
	#else
		/obj/item/clothing/suit/space/light/engineer,
		/obj/item/clothing/head/helmet/space/light/engineer,
	#endif
	)

/obj/storage/secure/closet/command/chief_engineer/puzzle
	locked = FALSE
	spawn_contents = list(
		/obj/item/storage/belt/utility/prepared/ceshielded, //instead of the law rack disk
		/obj/item/storage/box/clothing/chief_engineer,
		/obj/item/device/radio/headset/command/ce,
		/obj/item/stamp/ce,
		/obj/item/device/flash,
		/obj/item/clothing/shoes/magnetic,
		/obj/item/clothing/gloves/yellow,
		/obj/item/clothing/suit/hazard/fire/heavy,
		/obj/item/clothing/head/helmet/firefighter,
		/obj/item/clothing/suit/hazard/rad,
		/obj/item/clothing/head/rad_hood,
		/obj/item/storage/toolbox/mechanical/yellow_tools,
		/obj/item/storage/box/misctools,
		/obj/item/extinguisher,
		/obj/item/clothing/suit/space/light/engineer,
		/obj/item/clothing/head/helmet/space/light/engineer,
		/obj/item/device/pda2/chiefengineer
	)

/* ==================== */
/* ----- Security ----- */
/* ==================== */

/obj/storage/secure/closet/security
	name = "\improper Security locker"
	req_access = list(access_securitylockers)
	icon_state = "sec"
	icon_closed = "sec"
	icon_opened = "secure_red-open"
	_max_health = LOCKER_HEALTH_STRONG
	_health = LOCKER_HEALTH_STRONG
	bolted = TRUE

/obj/storage/secure/closet/security/equipment
	name = "\improper Security equipment locker"
	spawn_contents = list(/obj/item/clothing/under/rank/security,
	/obj/item/device/radio/headset/security,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/head/helmet/hardhat/security,
	/obj/item/clothing/shoes/swat,
	/obj/item/clothing/glasses/sunglasses/sechud,
	/obj/item/handcuffs,
	/obj/item/handcuffs,
	/obj/item/device/flash,
	/obj/item/barrier)

	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(15))
				new /obj/item/gun/kinetic/riot40mm(src)
			else
				new /obj/item/chem_grenade/flashbang(src)
			return 1

/obj/storage/secure/closet/security/equipment/derelict
	name = "derelict Security equipment locker"
	spawn_contents = list(/obj/item/clothing/head/helmet/hardhat/security,
	/obj/item/clothing/glasses/sunglasses/sechud,
	/obj/item/handcuffs,
	/obj/item/handcuffs,
	/obj/item/device/flash,
	/obj/item/barrier)

	make_my_stuff()
		..()

/obj/storage/secure/closet/security/forensics
	name = "Forensics equipment locker"
	req_access = list(access_forensics_lockers)
	spawn_contents = list(/obj/item/storage/box/clothing/detective,
	/obj/item/clothing/suit/wintercoat/detective,
	/obj/item/clothing/head/deerstalker,
	/obj/item/clothing/glasses/thermal,
	/obj/item/clothing/glasses/spectro,
	/obj/item/storage/box/spy_sticker_kit/radio_only/detective,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/clothing/head/det_hat/gadget,
	/obj/item/device/detective_scanner/detective,
	/obj/item/pinpointer/bloodtracker,
	/obj/item/device/flash,
	/obj/item/camera_film/large,
	/obj/item/camera_film,
	/obj/item/storage/box/luminol_grenade_kit,
	/obj/item/clipboard)

/obj/storage/secure/closet/brig
	name = "\improper Confiscated Items safe"
	desc = "A card-locked safe for storage of contraband. Unfortunately it was made by the lowest bidder."
	req_access = list(access_brig)
	icon_state = "safe_locker"
	icon_closed = "safe_locker"
	icon_opened = "safe_locker-open"
	icon_greenlight = "safe-greenlight"
	icon_redlight = "safe-redlight"
	open_sound = 'sound/misc/safe_open.ogg'
	close_sound = 'sound/misc/safe_close.ogg'
	_max_health = LOCKER_HEALTH_STRONG
	_health = LOCKER_HEALTH_STRONG
	reinforced = TRUE
	bolted = TRUE
	spawn_contents = list(/obj/item/item_box/contraband)

// Old Mushroom-era feature I fixed up (Convair880).
/obj/storage/secure/closet/brig_automatic
	name = "\improper Automatic Locker"
	req_access = list(access_brig)
	desc = "Card-locked closet linked to a brig timer. Will unlock automatically when timer reaches zero."
	anchored = ANCHORED
	_max_health = LOCKER_HEALTH_STRONG
	_health = LOCKER_HEALTH_STRONG
	reinforced = TRUE
	var/obj/machinery/door_timer/our_timer = null
	var/id = null

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/floorflusher (floorflusher.dm)
	// /obj/machinery/door_timer (door_timer.dm)
	// /obj/machinery/door/window/brigdoor (window.dm)
	// /obj/machinery/flasher (flasher.dm)
	solitary
		name = "\improper Automatic Locker (Cell #1)"
		id = "solitary"

	solitary2
		name = "\improper Automatic Locker (Cell #2)"
		id = "solitary2"

	solitary3
		name = "\improper Automatic Locker (Cell #3)"
		id = "solitary3"

	solitary4
		name = "\improper Automatic Locker (Cell #4)"
		id = "solitary4"

	minibrig
		name = "\improper Automatic Locker (Mini-Brig)"
		id = "minibrig"

	minibrig2
		name = "\improper Automatic Locker (Mini-Brig #2)"
		id = "minibrig2"

	minibrig3
		name = "\improper Automatic Locker (Mini-Brig #3)"
		id = "minibrig3"

	genpop
		name = "\improper Automatic Locker (Genpop)"
		id = "genpop"

	genpop_n
		name = "\improper Automatic Locker (Genpop North)"
		id = "genpop_n"

	genpop_s
		name = "\improper Automatic Locker (Genpop South)"
		id = "genpop_s"

	New()
		..()
		START_TRACKING
		SPAWN(0.5 SECONDS)
			if (src)
				// Why range 30? COG2 places linked fixtures much further away from the timer than originally envisioned.
				for_by_tcl(DT, /obj/machinery/door_timer)
					if (!IN_RANGE(DT, src, 30))
						continue
					if (DT && DT.id == src.id)
						src.our_timer = DT
						if (src.name == "\improper Automatic Locker")
							src.name = "\improper Automatic Locker ([src.id])"
						break
				if (!src.our_timer)
					message_admins("Automatic locker: couldn't find brig timer with ID [isnull(src.id) ? "*null*" : "[src.id]"] in [get_area(src)].")
					logTheThing(LOG_DEBUG, null, "<b>Convair880:</b> couldn't find brig timer with ID [isnull(src.id) ? "*null*" : "[src.id]"] for automatic locker at [log_loc(src)].")
		return

	disposing()
		..()
		STOP_TRACKING

	mouse_drop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if (!isturf(usr.loc))
			return
		if (usr.stat || usr.getStatusDuration("stunned") || usr.getStatusDuration("knockdown"))
			return
		if (BOUNDS_DIST(src, usr) > 0)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (GET_DIST(over_object, src) > 5)
			usr.show_text("The [src.name] is too far away from the target!", "red")
			return
		if (!istype(over_object, /obj/machinery/door_timer))
			usr.show_text("Automatic lockers can only be linked to a brig timer.", "red")
			return

		if (tgui_alert(usr, "Link locker to this brig timer?", "Link locker", list("Yes", "No")) == "Yes")
			var/obj/machinery/door_timer/DT = over_object
			if (!DT.id)
				usr.show_text("This brig timer doesn't have an ID assigned to it.", "red")
				return
			src.id = DT.id
			src.our_timer = DT
			src.name = "\improper Automatic Locker ([src.id])"
			usr.visible_message(SPAN_NOTICE("<b>[usr.name]</b> links [src.name] to a brig timer."), SPAN_NOTICE("Brig timer linked: [src.id]."))
		return

/* =================== */
/* ----- Medical ----- */
/* =================== */

/obj/storage/secure/closet/medical
	name = "medical locker"
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "secure_white-open"
	req_access = list(access_medical_lockers)

/obj/storage/secure/closet/medical/cloning
	name = "cloning storage locker"
	bolted = FALSE

/obj/storage/secure/closet/medical/medicine
	name = "medicine storage locker"
	spawn_contents = list(/obj/item/clothing/glasses/visor,
	/obj/item/device/radio/headset/deaf,
	/obj/item/clothing/glasses/eyepatch,
	/obj/item/reagent_containers/glass/bottle/antitoxin = 3,
	/obj/item/reagent_containers/glass/bottle/epinephrine = 3,
	/obj/item/storage/box/syringes,
	/obj/item/storage/box/stma_kit,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/reagent_containers/dropper = 2,
	/obj/item/reagent_containers/glass/beaker = 2)

/obj/storage/secure/closet/medical/medkit
	name = "medkit storage locker"
	icon_closed = "medical_medkit"
	icon_state = "medical_medkit"
	spawn_contents = list()
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			var/obj/item/storage/firstaid/regular/B1 = new(src)
			B1.pixel_y = 6
			B1.pixel_x = -6

			var/obj/item/storage/firstaid/brute/B2 = new(src)
			B2.pixel_y = 6
			B2.pixel_x = 6

			var/obj/item/storage/firstaid/fire/B3 = new(src)
			B3.pixel_y = 0
			B3.pixel_x = -6

			var/obj/item/storage/firstaid/toxin/B4 = new(src)
			B4.pixel_y = 0
			B4.pixel_x = 6

			var/obj/item/storage/firstaid/oxygen/B5 = new(src)
			B5.pixel_y = -6
			B5.pixel_x = -6

			var/obj/item/storage/firstaid/brain/B6 = new(src)
			B6.pixel_y = -6
			B6.pixel_x = 6
			return 1

/obj/storage/secure/closet/medical/anesthetic
	name = "anesthetic storage locker"
	icon_closed = "medical_anesthetic"
	icon_state = "medical_anesthetic"
	spawn_contents = list(/obj/item/reagent_containers/glass/bottle/morphine = 2,
	/obj/item/storage/box/syringes,
	/obj/item/tank/anesthetic = 5,
	/obj/item/clothing/mask/medical = 4)

/obj/storage/secure/closet/medical/uniforms
	name = "medical uniform locker"
	icon_closed = "medical_clothes"
	icon_state = "medical_clothes"
	spawn_contents = list(/obj/item/storage/backpack/medic,
	/obj/item/storage/backpack/satchel/medic,
	/obj/item/storage/backpack/robotics,
	/obj/item/storage/backpack/genetics,
	/obj/item/storage/backpack/satchel/robotics,
	/obj/item/storage/backpack/satchel/genetics,
	/obj/item/storage/box/clothing/medical,
	/obj/item/storage/box/clothing/geneticist,
	/obj/item/storage/box/clothing/roboticist,
	/obj/item/clothing/suit/wintercoat/medical,
	/obj/item/storage/belt/medical,
	/obj/item/storage/box/stma_kit,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/clothing/glasses/healthgoggles)

/obj/storage/secure/closet/medical/chemical
	name = "restricted medical locker"
	icon_closed = "medical_restricted"
	icon_state = "medical_restricted"
	spawn_contents = list()
	req_access = list(access_medical_director)
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			// let's organize the SHIT outta this closet too! hot damn
			var/obj/item/reagent_containers/glass/bottle/pfd/B1 = new(src)
			B1.pixel_y = 6
			B1.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/pentetic/B2 = new(src)
			B2.pixel_y = 6
			B2.pixel_x = 4

			var/obj/item/reagent_containers/glass/bottle/omnizine/B3 = new(src)
			B3.pixel_y = 0
			B3.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/pfd/B4 = new(src)
			B4.pixel_y = 0
			B4.pixel_x = 4

			var/obj/item/reagent_containers/glass/bottle/ether/B5 = new(src)
			B5.pixel_y = -5
			B5.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/haloperidol/B6 = new(src)
			B6.pixel_y = -5
			B6.pixel_x = 4
			return 1

/obj/storage/secure/closet/animal
	name = "\improper Animal Control locker"
	req_access = list(access_medical)
	spawn_contents = list(/obj/item/device/radio/signaler,
	/obj/item/device/radio/electropack = 5,
	/obj/item/clothing/glasses/blindfold = 2,
	/obj/item/clothing/mask/monkey_translator = 2,
	/obj/item/pet_carrier)

/* ==================== */
/* ----- Research ----- */
/* ==================== */

/obj/storage/secure/closet/research
	name = "\improper Research locker"
	icon_state = "science"
	icon_closed = "science"
	icon_opened = "secure_white-open"
	req_access = list(access_research)

/obj/storage/secure/closet/research/uniform
	name = "science uniform locker"
	spawn_contents = list(/obj/item/tank/air,
	/obj/item/crowbar/purple,
	/obj/item/storage/backpack/research,
	/obj/item/storage/box/clothing/research,
	/obj/item/clothing/suit/wintercoat/research,
	/obj/item/clothing/gloves/latex,
	/obj/item/clothing/mask/gas,
	/obj/item/device/reagentscanner,
	/obj/item/device/radio/headset/research)

/obj/storage/secure/closet/research/chemical
	name = "chemical storage locker"
	spawn_contents = list()
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			// let's organize the SHIT outta this closet hot damn
			var/obj/item/reagent_containers/glass/bottle/oil/B1 = new(src)
			B1.pixel_y = 6
			B1.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/phenol/B2 = new(src)
			B2.pixel_y = 6
			B2.pixel_x = 4

			var/obj/item/reagent_containers/glass/bottle/acetone/B3 = new(src)
			B3.pixel_y = 0
			B3.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/ammonia/B4 = new(src)
			B4.pixel_y = 0
			B4.pixel_x = 4

			var/obj/item/reagent_containers/glass/bottle/diethylamine/B5 = new(src)
			B5.pixel_y = -5
			B5.pixel_x = -4

			var/obj/item/reagent_containers/glass/bottle/acid/B6 = new(src)
			B6.pixel_y = -5
			B6.pixel_x = 4

			var/obj/item/reagent_containers/food/drinks/fueltank/B7 = new(src)
			B7.pixel_y = 0
			B7.pixel_x = 0
			return 1

/obj/storage/secure/closet/research/chemical/pharmacy
	name = "pharmacy chemical locker"
	icon_closed = "medical_chemical"
	icon_state = "medical_chemical"
	req_access = list(access_medical_lockers)

/* ======================= */
/* ----- Engineering ----- */
/* ======================= */

/obj/storage/secure/closet/engineering
	name = "\improper Engineering locker"
	icon_state = "eng"
	icon_closed = "eng"
	icon_opened = "secure_yellow-open"
	req_access = list(access_engineering)

/obj/storage/secure/closet/engineering/electrical
	name = "electrical supplies locker"
	req_access = list(access_engineering_power)
	spawn_contents = list(/obj/item/clothing/gloves/yellow = 3,
	/obj/item/storage/toolbox/electrical = 3,
	/obj/item/device/multitool = 3)

/obj/storage/secure/closet/engineering/welding
	name = "welding supplies locker"
	spawn_contents = list(/obj/item/clothing/head/helmet/welding = 3,
	/obj/item/weldingtool = 3)

/obj/storage/secure/closet/engineering/mechanic
	name = "\improper Mechanic's locker"
	req_access = list(access_engineering_mechanic)
	spawn_contents = list(/obj/item/storage/toolbox/electrical,
	/obj/item/device/accessgun/lite,
	/obj/item/clothing/gloves/yellow,
	/obj/item/electronics/scanner,
	/obj/item/clothing/glasses/toggleable/meson,
	/obj/item/electronics/soldering,
	/obj/item/deconstructor,
	/obj/item/electronics/frame/mech_cabinet=2,
	/obj/item/storage/mechanics/housing_handheld=1,
	/obj/item/paper/manufacturer_blueprint/ai_status_display)

/obj/storage/secure/closet/engineering/atmos
	name = "\improper Atmospheric Technician's locker"
	req_access = list(access_engineering_atmos)
	spawn_contents = list(/obj/item/clothing/suit/hazard/fire,
	/obj/item/clothing/head/helmet/firefighter,
	/obj/item/device/analyzer/atmospheric/upgraded,
	/obj/item/clothing/glasses/toggleable/atmos,
	/obj/item/clothing/glasses/toggleable/meson,
	/obj/item/storage/toolbox/mechanical,
	/obj/item/extinguisher,
	/obj/item/chem_grenade/firefighting,
	/obj/item/chem_grenade/firefighting)

/obj/storage/secure/closet/engineering/engineer
	name = "\improper Engineer's locker"
	req_access = list(access_engineering_engine)
	spawn_contents = list(/obj/item/storage/toolbox/mechanical,
#ifdef HOTSPOTS_ENABLED
	/obj/item/clothing/shoes/stomp_boots,
#endif
	/obj/item/engivac/complete,
	/obj/item/old_grenade/oxygen,
	/obj/item/clothing/glasses/toggleable/meson,
	/obj/item/clothing/glasses/toggleable/atmos,
	/obj/item/pen/infrared,
	/obj/item/pen/crayon/infrared,
	/obj/item/lamp_manufacturer/organic,
	/obj/item/device/light/floodlight/with_cell,
	/obj/item/pinpointer/category/apcs/station)

/obj/storage/secure/closet/engineering/mining
	name = "\improper Miner's locker"
	req_access = list(access_mining)
	spawn_contents = list(/obj/item/storage/box/clothing/miner,
	/obj/item/clothing/suit/wintercoat/engineering,
	/obj/item/storage/backpack/engineering,
	/obj/item/breaching_charge/mining/light = 3,
	/obj/item/satchel/mining = 2,
	/obj/item/oreprospector,
	/obj/item/ore_scoop,
	/obj/item/mining_tool/powered/pickaxe,
	/obj/item/clothing/glasses/toggleable/meson,
	/obj/item/storage/belt/mining,
	/obj/item/device/geiger,
	/obj/item/device/appraisal)

/obj/storage/secure/closet/engineering/cargo
	name = "\improper Quartermaster's locker"
	req_access = list(access_cargo)
	spawn_contents = list(/obj/item/storage/box/clothing/qm,
	/obj/item/storage/box/clothing/mail,
	/obj/item/pen/fancy,
	/obj/item/paper_bin,
	/obj/item/clipboard,
	/obj/item/hand_labeler,
	/obj/item/cargotele,
	/obj/item/device/appraisal)

/* ==================== */
/* ----- Civilian ----- */
/* ==================== */

/obj/storage/secure/closet/civilian
	name = "civilian locker"

/obj/storage/secure/closet/civilian/janitor
	name = "\improper Custodial supplies locker"
	req_access = list(access_janitor)
	spawn_contents = list(/obj/item/storage/box/clothing/janitor,\
	/obj/item/reagent_containers/glass/bottle/cleaner = 2,\
	/obj/item/reagent_containers/glass/bottle/acetone/janitors = 1,\
	/obj/item/reagent_containers/glass/bottle/ammonia/janitors = 1,\
	/obj/item/device/light/flashlight,\
	/obj/item/caution = 4,\
	/obj/item/disk/data/floppy/manudrive/cleaner_grenade = 1)

/obj/storage/secure/closet/civilian/hydro
	name = "\improper Botanical supplies locker"
	req_access = list(access_hydro)
	icon_state = "secure_green"
	icon_closed = "secure_green"
	icon_opened = "secure_green-open"
	spawn_contents = list(/obj/item/storage/box/clothing/botanist,
	/obj/item/plantanalyzer,
	/obj/item/device/reagentscanner,
	/obj/item/reagent_containers/glass/wateringcan,
	/obj/item/paper/book/from_file/hydroponicsguide,
	/obj/item/device/appraisal)

/obj/storage/secure/closet/civilian/ranch
	name = "\improper Rancher supplies locker"
	req_access = list(access_ranch)
	icon_state = "secure_green"
	icon_closed = "secure_green"
	icon_opened = "secure_green-open"
	spawn_contents = list(/obj/item/paper/ranch_guide,\
	/obj/item/fishing_rod/basic,\
	/obj/item/storage/box/clothing/rancher,\
	/obj/item/device/camera_viewer/ranch,\
	/obj/item/clothing/mask/chicken,\
	/obj/item/chicken_carrier,\
	/obj/item/storage/box/syringes,\
	/obj/item/satchel/hydro,\
	/obj/item/reagent_containers/glass/wateringcan,\
	/obj/item/sponge,\
	/obj/item/kitchen/food_box/egg_box/rancher,
	/obj/item/storage/box/knitting,
	/obj/item/storage/box/nametags)

/obj/storage/secure/closet/civilian/kitchen
	name = "\improper Catering supplies locker"
	req_access = list(access_kitchen)
	spawn_contents = list(/obj/item/storage/box/cutlery,\
	/obj/item/kitchen/rollingpin,\
	/obj/item/paper/book/from_file/cookbook,\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 5)

/obj/storage/secure/closet/civilian/bartender
	name = "\improper Mixology supplies locker"
	req_access = list(access_bar)
	spawn_contents = list(/obj/item/gun/russianrevolver,\
	/obj/item/reagent_containers/food/drinks/bottle/vintage,\
	/obj/item/storage/box/glassbox)

/obj/storage/secure/closet/civilian/chaplain
	name = "\improper Religious supplies locker"
	req_access = list(access_chapel_office)
	spawn_contents = list(/obj/item/storage/box/clothing/witchfinder,\
	/obj/item/storage/box/clothing/chaplain,\
	/obj/item/clothing/under/misc/chaplain/atheist,\
	/obj/item/clothing/under/misc/chaplain,\
	/obj/item/clothing/under/misc/chaplain/rabbi,\
	/obj/item/clothing/under/misc/chaplain/siropa_robe,\
	/obj/item/clothing/under/misc/chaplain/buddhist,\
	/obj/item/clothing/under/misc/chaplain/muslim,\
	/obj/item/clothing/suit/adeptus,\
	/obj/item/clothing/head/rabbihat,\
	/obj/item/clothing/head/formal_turban,\
	/obj/item/clothing/head/turban,\
	/obj/item/clothing/shoes/sandal/magic,\
	/obj/item/clothing/under/misc/chaplain/nun,\
	/obj/item/clothing/head/nunhood,\
	/obj/item/clothing/suit/flockcultist,\
	/obj/item/storage/box/holywaterkit,
	/obj/item/swingsignfolded)

/* =================== */
/* ----- Fridges ----- */
/* =================== */

/obj/storage/secure/closet/fridge
	name = "refrigerator"
	icon_state = "fridge"
	icon_closed = "fridge"
	icon_opened = "fridge-open"
	icon_greenlight = "fridge-greenlight"
	icon_redlight = "fridge-redlight"
	icon_sparks = "fridge-sparks"
	intact_frame = 1
	weld_image_offset_X = 3
	open_sound = 'sound/misc/fridge_open.ogg'
	close_sound = 'sound/misc/fridge_close.ogg'
	volume = 80

/obj/storage/secure/closet/fridge/opened
	New()
		..()
		name = "busted refrigerator"
		desc = "The newest cooling technology...now with - oh god! What happened to the poor door?!"
		intact_frame = 0
		unlock()
		toggle()

/obj/storage/secure/closet/fridge/kitchen
	spawn_contents = list(/obj/item/reagent_containers/food/drinks/milk = 2,/obj/item/reagent_containers/food/snacks/condiment/syrup = 3,/obj/item/storage/box/cookie_tin,/obj/item/storage/box/stroopwafel_tin)
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			var/obj/item/storage/box/donkpocket_kit/dp = new(src)
			var/obj/item/storage/box/bacon_kit/bc1 = new(src)
			var/obj/item/storage/box/bacon_kit/bc2 = new(src)
			var/obj/item/storage/box/popsicles/p = new(src)
			var/obj/item/storage/box/sushi_box/s = new(src)
			s.pixel_x = 3
			dp.pixel_x = 3
			bc1.pixel_x = 3
			bc2.pixel_x = 3
			p.pixel_x = 3

			var/obj/item/kitchen/food_box/egg_box/e1 = new(src)
			var/obj/item/kitchen/food_box/egg_box/e2 = new(src)
			e1.pixel_y = -4
			e2.pixel_y = -4

			var/obj/item/reagent_containers/food/drinks/cola/c1 = new(src)
			var/obj/item/reagent_containers/food/drinks/cola/c2 = new(src)
			c1.pixel_x = -8
			c2.pixel_x = -8

			var/obj/item/storage/box/cheese/cheese = new(src)
			cheese.pixel_x = 3

			var/obj/item/storage/box/butter/butter = new(src)
			butter.pixel_x = 2
			butter.pixel_y = 4

			if (prob(25))
				for (var/i = rand(2,10), i > 0, i--)
					new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget(src)
			return 1

/obj/item/paper/blood_fridge_note
	name = "paper- 'angry note'"
	info = "This fridge is for BLOOD PACKS <u>ONLY</u>! If I ever catch the idiot who keeps leaving their lunch in here, you're taking a one-way trip to the goddamn solarium!<br><br><i>L. Alliman</i><br>"

/obj/storage/secure/closet/fridge/blood
	name = "blood supply refrigerator"
	req_access = list(access_medical_lockers)
	spawn_contents = list(/obj/item/storage/box/iv_box,
	/obj/item/reagent_containers/iv_drip/saline,
	/obj/item/reagent_containers/iv_drip/blood = 5,
	/obj/item/paper/blood_fridge_note)
	make_my_stuff()
		if (..()) // make_my_stuff is called multiple times due to lazy init, so the parent returns 1 if it actually fired and 0 if it already has
			if (prob(11))
				new /obj/item/plate(src)
				var/obj/item/a_sandwich = pick(typesof(/obj/item/reagent_containers/food/snacks/sandwich))
				//a_sandwich.pixel_y = 0
				//a_sandwich.pixel_x = 0
				new a_sandwich(src)
			return 1

/obj/storage/secure/closet/fridge/pathology
	name = "pathology lab fridge"
	desc = "Looks like it's been raided before the shift started."
	req_access = list(access_medical_lockers)
	spawn_contents = list(/obj/item/reagent_containers/syringe/antiviral = 3)

/* ================ */
/* ----- Misc ----- */
/* ================ */

/obj/storage/secure/closet/immersion
	name = "Immersion Suit Vault"
	_max_health = LOCKER_HEALTH_STRONG
	_health = LOCKER_HEALTH_STRONG
	req_access = list(access_eva)
	icon_state = "safe_immers"
	icon_closed = "safe_immers"
	icon_opened = "safe_locker-open"
	bolted = TRUE

	command
		name = "Command Immersion Suit Vault"
		icon_state = "safe_immers_com"
		icon_closed = "safe_immers_com"
		req_access = list(access_heads)

	engineering
		name = "Engineering Immersion Suit Vault"
		icon_state = "safe_immers_eng"
		icon_closed = "safe_immers_eng"
		req_access = list(access_engineering)

	quartermasters
		name = "Quartermasters' Immersion Suit Vault"
		icon_state = "safe_immers_qm"
		icon_closed = "safe_immers_qm"
		req_access = list(access_cargo)

	research
		name = "Research Immersion Suit Vault"
		icon_state = "safe_immers_res"
		icon_closed = "safe_immers_res"
		req_access = list(access_research)

	security
		name = "Security Immersion Suit Vault"
		icon_state = "safe_immers_sec"
		icon_closed = "safe_immers_sec"
		req_access = list(access_security)

/obj/storage/secure/closet/courtroom
	name = "\improper Courtroom locker"
	req_access = list(access_heads)
	spawn_contents = list(/obj/item/clothing/shoes/brown,
	/obj/item/paper/Court = 3,
	/obj/item/pen,
	/obj/item/clothing/suit/judgerobe,
	/obj/item/clothing/head/powdered_wig,
	/obj/item/clothing/under/misc/lawyer/red,
	/obj/item/clothing/under/misc/lawyer,
	/obj/item/clothing/under/misc/lawyer/black,
	/obj/item/storage/briefcase)

/obj/storage/secure/closet/kitchen
	name = "kitchen cabinet"
	req_access = list(access_kitchen)
	spawn_contents = list(/obj/item/clothing/head/chefhat = 2,
	/obj/item/clothing/under/rank/chef = 2,
	/obj/item/kitchen/utensil/fork,
	/obj/item/kitchen/utensil/knife,
	/obj/item/kitchen/utensil/spoon,
	/obj/item/kitchen/rollingpin,
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 5)

/obj/storage/secure/closet/barber
	spawn_contents = list(/obj/item/clothing/under/misc/barber = 3,
	/obj/item/clothing/head/wig = 2,
	/obj/item/scissors,
	/obj/item/razor_blade)
