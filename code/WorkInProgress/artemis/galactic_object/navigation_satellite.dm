#if ENABLE_ARTEMIS

/datum/galactic_object/nav_sat
	name = "Navigation Satellite"
	body_path_map = /obj/background_star/galactic_object/nav_sat
	body_path_ship = null
	galactic_x = null
	galactic_y = null
	sector = null
	navigable = 1
	var/my_satellite_name = null

	load_map_body(var/obj/artemis/ship)
		var/obj/background_star/galactic_object/map_body = ..()
		map_body.name = "Navigation Satellite ([my_satellite_name])"
		return map_body


/obj/background_star/galactic_object/nav_sat
	name = "Navigation Satellite"
	icon = 'icons/misc/artemis/galactic_object_map.dmi'
	icon_state = "nav_sat"

	New()
		..()
		flick("nav_sat_extend",src)

	/*
		flags |= HAS_ARTEMIS_SCAN

	proc/artemis_scan(var/mob/pilot, var/obj/artemis/ship)
		var/dat = {"<span class='alert'><b>DON'T <i>FUCKING</i> TOUCH ME.</b></span>"}

		pilot << browse("<HEAD><TITLE>HEY FUCKWAD!</TITLE></HEAD><TT>[dat]</TT>", "window=fixme_planet")

		animate(src, transform = matrix()*2, alpha = 0, time = 5)
		animate(src, transform = matrix(), alpha = 255, time = 5)
		return
	*/

/obj/nav_sat
	name = "Navigation Satellite"
	icon = 'icons/misc/artemis/temps.dmi'
	icon_state = "nav_sat"

/obj/machinery/equipment_chute
	name = "Equipment Chute"
	desc = "Loading site for ship equipment."
	icon = 'icons/obj/large/96x32.dmi'
	anchored = 1
	icon_state = "loader"
	pixel_x = -32


	var/obj/artemis/ship = null
	var/stars_id = "artemis"

	New()
		..()
		SPAWN(1 SECOND)
			for(var/obj/artemis/S in world)
				if(S.stars_id == src.stars_id)
					src.ship = S
					break

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if((!in_interact_range(src,user)) || (!in_interact_range(O,user)))
			boutput(user, "<span class='alert'>You are too far away to do that.</span>")
			return

		if(!IN_RANGE(O, src, 1) && !O.anchored )
			step_towards(O,get_turf(src))
			return

		if(istype(O, /obj/nav_sat))
			step_towards(O,src)
			if(ship)
				if(ship.buoy_count < initial(ship.buoy_count))
					sleep(0.5 SECONDS)
					icon_state = "loader_load"
					sleep(0.7 SECONDS)
					src.visible_message("<span class='alert'>The [O] slowly slides down \the [src].</span>")
					O.set_loc(src)
					sleep(1.5 SECONDS)
					ship.buoy_count++
					qdel(O)
					icon_state = "loader"
					flick("loader_open", src)
				else
					boutput(user, "<span class='alert'>The ship seems to refuse the [O].</span>")
			else
				boutput(user, "<span class='alert'>[src] leads to nowhere. Errors have been made.</span>")
		else
			boutput(user, "<span class='alert'>Hmmm that doesn't seem right.</span>")


#endif
