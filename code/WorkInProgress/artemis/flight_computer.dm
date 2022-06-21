#define HAS_ARTEMIS_SCAN (1 << 19) //the object has an artemis scan

/obj/machinery/sim/vr_bed/flight_chair
	name = "VR Flight Controls"
	desc = "An advanced pod that lets the user enter the Artemis' flight control systems"
	var/stars_id = "artemis"
	var/obj/artemis/ship = null
	var/datum/hud/flight_computer/myhud = null
	var/list/datum/hud/human/stored_huds = list()

	New()
		..()
		src.myhud = new /datum/hud/flight_computer(src)
		SPAWN(1 SECOND)
			for(var/obj/artemis/S in world)
				if(S.stars_id == src.stars_id)
					src.ship = S
					break

	attackby(obj/item/O, mob/user)
		if(istype(O,/obj/item/grab))
			var/obj/item/grab/G = O
			if (!ismob(G.affecting))
				return
			if (src.occupant)
				boutput(user, "<span class='notice'><B>The VR pod is already occupied!</B></span>")
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
			boutput(M, "<span class='notice'><B>The VR pod is already occupied!</B></span>")
			return

		if (!iscarbon(M))
			boutput(M, "<span class='notice'><B>You cannot possibly fit into that!</B></span>")
			return
		M.set_loc(src)
		ship.my_pilot = M
		src.occupant = M
		src.con_user = M
		src.active = 1
		for(var/obj/O in src)
			O.set_loc(src.loc)
		src.icon_state = "vrbed_1"
		M.client.eye = src.ship

		M.use_movement_controller = ship

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
		src.icon_state = "vrbed_0"
		for(var/obj/O in src)
			O.set_loc(src.loc)

		if(do_set_loc)
			src.occupant.set_loc(src.loc)

		ship.remove_arrows(src.occupant)
		ship.remove_nav_arrow(src.occupant)
		ship.remove_thrusters(src.occupant)

		src.occupant.client.eye = src.occupant

		if (occupant.client)
			occupant.detach_hud(myhud)
			for(var/datum/hud/hud in stored_huds)
				src.stored_huds -= hud
				occupant.attach_hud(hud)
			src.stored_huds.len = 0

		src.occupant.use_movement_controller = null
		src.occupant.changeStatus("weakened",20)
		src.occupant = null
		src.active = 0
		src.con_user = null
		ship.my_pilot = null
		return

	process()
		if(!(src.occupant in src))
			src.go_out(0)
		return

	done()
		return

/datum/targetable/artemis_active_scanning
	name = "Active Scanning"
	desc = "You are scanning an object in space."
	cooldown = 0
	targeted = 1
	target_anything = 1
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

			flick("radar_ping",my_hud.radar_ping)

			if(target.flags & HAS_ARTEMIS_SCAN)
				target:artemis_scan(M,my_ship)
			else
				M.show_message("<span class='alert'>Target shows no response to active scanning.</span>")

			return 0
