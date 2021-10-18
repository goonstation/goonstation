/datum/galactic_object/test
	name = "F1X-M3"
	body_path_map = /obj/background_star/galactic_object/test
	body_path_ship = /obj/background_star/galactic_object/large/test
	galactic_x = 10
	galactic_y = 20
	sector = "A"
	navigable = 1

/obj/background_star/galactic_object/test
	name = "F1X-M3"
	icon = 'icons/misc/galactic_objects.dmi'
	icon_state = "generic"

	New()
		..()
		flags |= HAS_ARTEMIS_SCAN

	proc/artemis_scan(var/mob/pilot, var/obj/artemis/ship)
		var/dat = {"<span class='alert'><b>DON'T <i>FUCKING</i> TOUCH ME.</b></span>"}

		pilot << browse("<HEAD><TITLE>HEY FUCKWAD!</TITLE></HEAD><TT>[dat]</TT>", "window=fixme_planet")

		animate(src, transform = matrix()*2, alpha = 0, time = 5)
		animate(src, transform = matrix(), alpha = 255, time = 5)
		return

/obj/background_star/galactic_object/large/test
	name = "F1X-M3"
	icon = 'icons/misc/galactic_objects_large.dmi'
	icon_state = "generic"
	destination_name = "F1X-M3"

/datum/galactic_object/eyesenhower
	name = "eyesenhower"
	//loud = 1
	body_path_map = /obj/background_star/galactic_object/eyesenhower_map
	body_path_ship = /obj/background_star/galactic_object/large/eyesenhower_ship
	galactic_x = 0
	galactic_y = 20
	sector = "A"
	navigable = 1
	var/intro_played = 0

/obj/background_star/galactic_object/eyesenhower_map
	name = "Eyesenhower"
	icon = 'icons/misc/artemis/galactic_object_map.dmi'
	icon_state = "eh_idle_closed"

	New()
		..()
		flags |= HAS_ARTEMIS_SCAN

	on_load()
		//src.icon_state = "eh_moon_idle"
		//src.overlays += src
		src.overlays += icon('icons/misc/artemis/galactic_object_map.dmi',"eh_moon_idle")
		var/datum/galactic_object/eyesenhower/E = master
		if(!istype(E))
			return
		if(E.intro_played)
			src.icon_state = "eh_idle_open"
		else
			src.icon_state = "eh_idle_closed"

	proc/artemis_scan(var/mob/pilot, var/obj/artemis/ship)
		boutput(pilot,"fuck")
		flick("arjuna_thruster_back_l",ship)
		return

/obj/background_star/galactic_object/large/eyesenhower_ship
	name = "Eyesenhower"
	icon = 'icons/misc/artemis/galactic_object_ship.dmi'
	icon_state = "eyesenhower"

	on_load()
		var/datum/galactic_object/eyesenhower/E = master
		if(!istype(E))
			return
		if(!E.intro_played)
			flick("eh_intro",src.my_map_body)
			E.intro_played = 1
			src.my_map_body.icon_state = "eh_idle_open"
