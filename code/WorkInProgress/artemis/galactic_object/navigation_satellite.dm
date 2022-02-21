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
