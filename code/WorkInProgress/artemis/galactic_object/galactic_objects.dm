#ifdef ENABLE_ARTEMIS
/datum/galactic_object/random
	name = "Randomized Planet"
	body_path_map = /obj/background_star/galactic_object/random
	body_path_ship = /obj/background_star/galactic_object/large/random
	sector = "A"
	navigable = 1
	var/color = null
	var/scale = 1
	var/destination_name = null
	var/icon_state = null

	New(datum/galaxy/G)
		galactic_x = rand()*2+1 //19?
		galactic_y = rand()*2+1 //19?
		scale = rand()*0.5+ 0.75
		color = pick("#fffb00", "#FF5D06", "#009ae7", "#03c53d", "#9b59b6", "#272e30", "#FF69B4", "#633221", "#ffffff")
		icon_state = weighted_pick(list("planet_1"=10,"planet_2"=3,"planet_3"=2))

		if(G)
			destination_name = pick(G.available_planets)
			G.available_planets -= destination_name
		generate_name()
		..()

	proc/generate_name()
		if (prob(50))
			name = pick_string("station_name.txt", "greek")
		else
			name = pick_string("station_name.txt", "militaryLetters")
		name += " "

		if (prob(30))
			name += pick_string("station_name.txt", "romanNum")
		else name += "[rand(2, 99)]"

/obj/background_star/galactic_object/random
	name = "F1X-M3"
	icon = 'icons/misc/artemis/galactic_object_map.dmi'
	icon_state = "planet_1"

	New()
		..()
		flags |= HAS_ARTEMIS_SCAN

	proc/artemis_scan(var/mob/pilot, var/obj/artemis/ship)
		var/dat = {"<span class='alert'><b>DON'T <i>FUCKING</i> TOUCH ME.</b></span>"}

		pilot << browse("<HEAD><TITLE>[name]</TITLE></HEAD><TT>[dat]</TT>", "window=artemis_scan")

		return

	on_load()
		var/datum/galactic_object/random/R = master
		color = R.color
		name = R.name
		transform = src.transform.Scale(R.scale)
		icon_state = R.icon_state


/obj/background_star/galactic_object/large/random
	name = "F1X-M3"
	icon = 'icons/misc/galactic_objects_large.dmi'
	icon_state = "generic"
	destination_name = "3rr0r"

	on_load()
		var/datum/galactic_object/random/R = master
		destination_name = R.destination_name
		name = R.name

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

#endif
