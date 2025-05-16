#ifdef ENABLE_ARTEMIS

#define HAS_ARTEMIS_SCAN (1 << 19) //the object has an artemis scan

/obj/machinery/sim/vr_bed/flight_chair
	name = "VR Flight Controls"
	desc = "An advanced pod that lets the user enter the Artemis' flight control systems"
	var/stars_id = "artemis"
	var/obj/artemis/ship = null
	var/datum/hud/flight_computer/myhud = null
	var/list/datum/hud/human/stored_huds = list()
	processing_tier = PROCESSING_HALF

	New()
		..()
		src.myhud = new /datum/hud/flight_computer(src)
		SPAWN(1 SECOND)
			for_by_tcl(S, /obj/artemis)
				if(S.stars_id == src.stars_id)
					src.ship = S
					src.ship.controls = src
					break
			var/area/A = get_area(src)
			for(var/obj/machinery/shuttle/engine/propulsion/P in A)
				src.ship.engines.add_engine(P)


	attackby(obj/item/O, mob/user)
		if(istype(O,/obj/item/grab))
			var/obj/item/grab/G = O
			if (!ismob(G.affecting))
				return
			if (src.occupant)
				boutput(user, SPAN_NOTICE("<B>The VR pod is already occupied!</B>"))
				return
			if (G)
				src.log_in(G.affecting)
				qdel(G)
			src.add_fingerprint(user)
			return

	log_in(mob/M as mob)
		if (src.occupant)
			if(M == src.occupant)
				return src.go_out()
			boutput(M, SPAN_NOTICE("<B>The VR pod is already occupied!</B>"))
			return

		if (!iscarbon(M))
			boutput(M, SPAN_NOTICE("<B>You cannot possibly fit into that!</B>"))
			return
		M.set_loc(src)
		ship.my_pilot = M
		src.occupant = M
		src.con_user = M
		src.active = 1
		for(var/obj/O in src)
			O.set_loc(src.loc)
		M.client.eye = src.ship

		get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_MAP_ICONS).add_mob(M)

		M.override_movement_controller = ship.movement_controller

		if(ship.show_tracking)
			ship.apply_arrows(M)
		if(ship.navigating)
			ship.apply_nav_arrow(M)
		ship.apply_thrusters(M)

		if (M.client)
			for(var/datum/hud/hud in M.huds)
				src.stored_huds += hud
				M.detach_hud(hud)
			M.attach_hud(myhud)
		update_icon()
		return

	/*

	relaymove(mob/user as mob, dir)
		src.ship.relaymove(user,dir)
		return

	*/

	attack_hand(var/mob/user)
		return

	go_out(var/do_set_loc = 1)
		if (!src.occupant)
			return
		for(var/obj/O in src)
			O.set_loc(src.loc)

		if(do_set_loc)
			src.occupant.set_loc(src.loc)
			return

		ship.remove_arrows(src.occupant)
		ship.remove_nav_arrow(src.occupant)
		ship.remove_thrusters(src.occupant)

		get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_MAP_ICONS).remove_mob(src.occupant)

		if (occupant.client)
			src.occupant.client.eye = src.occupant
			occupant.detach_hud(myhud)
			for(var/datum/hud/hud in stored_huds)
				src.stored_huds -= hud
				occupant.attach_hud(hud)
			src.stored_huds.len = 0

		src.occupant.override_movement_controller = null
		src.occupant.changeStatus("knockdown",20)
		src.occupant = null
		src.active = 0
		src.con_user = null
		ship.my_pilot = null
		update_icon()
		return

	process()
		if(!(src.occupant in src))
			src.go_out(0)

		if(src.occupant)
			myhud.update()
		return

	done()
		return

	MouseDrop_T(mob/living/target, mob/user)
		if (!istype(target) || isAI(user))
			return

		if (get_dist(src,user) > 1 || get_dist(user, target) > 1)
			return

		if (target == user)
			src.log_in(usr)
			src.add_fingerprint(usr)
		else
			var/previous_user_intent = user.a_intent
			user.a_intent = INTENT_GRAB
			user.drop_item()
			target.attack_hand(user)
			user.a_intent = previous_user_intent
			SPAWN(user.combat_click_delay + 2)
				if (istype(user.equipped(), /obj/item/grab))
					src.log_in(target)

/datum/targetable/artemis_active_scanning
	name = "Active Scanning"
	desc = "You are scanning an object in space."
	cooldown = 0
	targeted = 1
	target_anything = 1
	check_range = FALSE // Targeting based off of mob click
	max_range = 3000
	var/obj/machinery/sim/vr_bed/flight_chair/my_chair = null
	var/obj/artemis/my_ship = null
	var/datum/hud/flight_computer/my_hud

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/target)
		var/mob/M = usr
		if (istype(M))
			if(!(M in my_chair))
				return

			FLICK("radar_ping",my_hud.radar_ping)

			if(target.flags & HAS_ARTEMIS_SCAN)
				actions.start(new/datum/action/bar/icon/artemis_scan(my_ship, target, my_chair), my_ship)
			else
				M.show_message(SPAN_ALERT("Target shows no response to active scanning."))

			return 0

/datum/action/bar/icon/artemis_scan
	duration = 5 SECOND
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "cleanbot_clean"
	icon = 'icons/mob/hud_pod.dmi'
	icon_state = "sensors-use"
	var/obj/artemis/my_ship
	var/obj/background_star/galactic_object/target
	var/obj/machinery/sim/vr_bed/flight_chair/helm
	var/tick

	New(obj/artemis/ship, obj/background_star/galactic_object/target, obj/machinery/sim/vr_bed/flight_chair/helm)
		..()
		src.my_ship = ship
		src.target = target
		src.helm = helm

	onStart()
		..()
		bar.pixel_y = 15
		border.pixel_y = 15
		if (!my_ship || !target || !istype(target,/obj/background_star/galactic_object))
			interrupt(INTERRUPT_ALWAYS)
			return

		// TODO Sensor Ping Sound?!?!?
		//playsound(master, 'sound/impact_sounds/Liquid_Slosh_2.ogg', 25, TRUE)

	onUpdate()
		..()
		if (!my_ship || !target)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!target.check_distance(my_ship.sensor_range))
			interrupt(INTERRUPT_MOVE)
			return

		tick++
		if(tick % 2 == 0)
			if(helm.myhud)
				FLICK("radar_ping",src.helm.myhud.radar_ping)

	onInterrupt(flag)
		if(HAS_FLAG(flag, INTERRUPT_MOVE))
			helm.occupant?.show_message(SPAN_ALERT("Target is too far away!"))
		. = ..()

	onEnd()
		if(target.flags & HAS_ARTEMIS_SCAN)
			target.artemis_scan(helm.occupant, my_ship)
		..()

#endif
