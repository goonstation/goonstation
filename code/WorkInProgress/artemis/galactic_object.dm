#ifdef ENABLE_ARTEMIS

var/global/datum/galaxy/GALAXY = new

/datum/galaxy
	var/list/bodies = list()
	var/list/available_planets = list("planet1", "planet2", "planet3", "planet4", "planet5", "planet6", "planet7")
	var/list/available_asteroids = list("asteroid1", "asteroid2", "asteroid3", "asteroid4")

	var/datum/asteroid_controller/asteroids = new

	New()
		..()
		src.bodies += new/datum/galactic_object/test()
		src.bodies += new/datum/galactic_object/eyesenhower()
		src.bodies += new/datum/galactic_object/station()

		src.bodies += new/datum/galactic_object/bhole
		src.bodies += new/datum/galactic_object/star
		src.bodies += new/datum/galactic_object/asteroid

		for(var/i in 1 to 3)
			src.bodies += new/datum/galactic_object/star/random

		for(var/i in 1 to 10)
			src.bodies += new/datum/galactic_object/planet/random(src)

	// TODO
	proc/generate_solar_system()
		//var/sector_x = rand() * 10
		//var/sector_y = rand() * 10

		if(prob(50))
			src.bodies += new/datum/galactic_object/star/random()
		else
		//Binary System
			src.bodies += new/datum/galactic_object/star/random()
			src.bodies += new/datum/galactic_object/star/random()

			//Trinary System!!!
			if(prob(5))
				src.bodies += new/datum/galactic_object/star/random()

		//GENERATE N PLANETS
		// at range and bearing from sector center

			// Add moon(s) based on size of planet


/datum/asteroid_controller
	var/list/available_asteroids = list("asteroid1", "asteroid2", "asteroid3", "asteroid4")
	var/list/used_asteroids = list()
	var/list/obj/magnet_target_marker/asteroid/asteroid_markers = list()

	proc/get_available_marker()
		var/asteroid
		var/obj/magnet_target_marker/asteroid/marker
		var/list/possible_ast = list()
		possible_ast += available_asteroids
		for(var/i in 1 to length(possible_ast))
			asteroid = pick(possible_ast)
			possible_ast -= asteroid
			marker = GALAXY.asteroids.asteroid_markers[asteroid]
			if(istype(marker))
				if(marker.check_for_unacceptable_content())
					continue
				marker.erase_area()
				available_asteroids -= asteroid
				used_asteroids |= asteroid
				return marker

	proc/return_marker(obj/magnet_target_marker/asteroid/marker)
		if(marker.name in used_asteroids)
			used_asteroids -= marker.name
			available_asteroids |= marker.name

/obj/magnet_target_marker/asteroid
	New()
		..()
		GALAXY.asteroids.asteroid_markers[src.name] = src
		SPAWN_DBG(1 SECOND)
			construct()

/datum/galactic_object
	var/name
	var/galactic_x
	var/galactic_y
	var/max_r = ARTEMIS_MAX_R
	var/max_r_squared = ARTEMIS_MAX_R_SQUARED //951^2 // sqrt(2)*672; radius of circle with the boundary box inscribed in it
	var/max_r_squared_galactic = ARTEMIS_MAX_R_SQUARED_GALACTIC //(951*2/320)**2
	var/body_path_map
	var/body_path_ship
	var/sector
	var/list/obj/artemis/nearby_ships = list() // holds references to generated map bodies
	var/loud = 0
	var/navigable = 0 // Can be detected on long distance nav
	var/scale

	proc/check_distance(var/ship_x,var/ship_y)
		var/squared_distance = (ship_x-galactic_x)**2 + (ship_y-galactic_y)**2
		if(src.loud)
			boutput(world,"[name]: x distance is [(ship_x-galactic_x)], y offset is [(ship_y-galactic_y)], squared distance is [squared_distance], canvas squared check radius is [(max_r_squared_galactic)]")
		if(squared_distance <= max_r_squared_galactic)
			return 1
		return 0

	proc/load_map_body(var/obj/artemis/ship)

		if(!body_path_map)
			return

		var/ship_x = ship.galactic_x
		var/ship_y = ship.galactic_y
		var/ship_angle = ship.ship_angle
		var/ships_id = ship.stars_id

		if(nearby_ships[ship])
			return

		var/rel_x = galactic_x - ship_x
		var/rel_y = galactic_y - ship_y

		var/dist = sqrt(rel_x**2 + rel_y**2)

		var/theta = arctan(rel_y,rel_x)

		var/apparent_theta = theta-ship_angle

		var/obj/background_star/galactic_object/map_body = new body_path_map()
		map_body.ships_id = ships_id

		if(src.body_path_ship)
			map_body.has_ship_body = 1

		map_body.master = src
		map_body.my_ship = ship
		map_body.scale = scale
		map_body.set_vars(apparent_theta, dist)
		map_body.loc = get_turf(ship)
		nearby_ships += ship
		nearby_ships[ship] = map_body

		map_body.on_load()

		map_body.galaxy_icon = image(map_body.icon, map_body, map_body.icon_state, map_body.layer)
		get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_MAP_ICONS).add_image(map_body.galaxy_icon)
		map_body.icon_state = null

		return map_body

	proc/load_ship_body(var/obj/artemis/ship, var/obj/background_star/galactic_object/G)

		if(!body_path_ship)
			return

		var/ships_id = ship.stars_id
		var/ship_mark = ship.ship_marker

		if(G.my_ship_body)
			return

		var/obj/background_star/galactic_object/ship_body = new body_path_ship()

		G.my_ship_body = ship_body
		ship_body.my_map_body = G
		ship_body.ships_id = ships_id
		ship_body.my_ship = ship
		ship_body.master = src
		ship_body.actual_x = G.actual_x*ARTEMIS_MAP_SHIP_PIXEL_RATIO
		ship_body.actual_y = G.actual_y*ARTEMIS_MAP_SHIP_PIXEL_RATIO
		var/matrix/M = GLOBAL_ANIMATION_MATRIX.Reset()
		if(scale)
			M = M.Scale(scale)
			ship_body.scale = scale
		M = M.Translate(ship_body.actual_x,ship_body.actual_y)
		ship_body.transform = M

		ship_body.parallax_multi = 1/20
		ship_body.loc = get_turf(ship_mark)

		ship_body.on_load()

		ship_body.galaxy_icon = image(ship_body.icon, ship_body, ship_body.icon_state, ship_body.layer)
		get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).add_image(ship_body.galaxy_icon)
		ship_body.icon_state = null

	proc/unload(var/obj/background_star/galactic_object/G,var/obj/artemis/ship)
		if(G.my_map_body)
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).remove_image(G.galaxy_icon)
		else
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_MAP_ICONS).remove_image(G.galaxy_icon)

		if(G.my_ship_body)
			G.my_ship_body.on_unload()
			qdel(G.my_ship_body)
		if(ship)
			src.nearby_ships[ship] = null
			src.nearby_ships -= ship
		G.on_unload()
		qdel(G)
		return


/obj/background_star/galactic_object
	name = "TEST OBJECT"
	icon = 'icons/misc/galactic_objects.dmi'
	icon_state = "generic"
	var/turf/landing_zone = null
	var/destination_name = null
	var/has_ship_body = 0
	var/obj/background_star/galactic_object/my_ship_body = null
	var/obj/background_star/galactic_object/my_map_body = null
	var/datum/galactic_object/master = null
	var/x_old = null
	var/y_old = null
	var/scale
	plane = -1

	New()
		..()
		if(src.destination_name)
			SPAWN_DBG(1 SECOND)
				for(var/turf/T in landmarks[LANDMARK_PLANETS])
					if(landmarks[LANDMARK_PLANETS][T] == src.destination_name)
						src.landing_zone = T
						return

	proc/check_distance(max_distance)
		var/squared_pixel_distance = ((src.actual_x)**2 + (src.actual_y)**2)
		if(squared_pixel_distance <= max_distance)
			.= TRUE

	set_vars(var/theta, var/dist)

		var/load_r = max_r*dist/sqrt(ARTEMIS_MAX_R_SQUARED_GALACTIC) // 35.328 = max_r_squared galactic

		src.actual_x = 2*load_r*sin(theta)
		src.actual_y = 2*load_r*cos(theta)

		var/matrix/M = GLOBAL_ANIMATION_MATRIX.Reset()
		if(scale)
			M = M.Scale(scale)
		M = M.Translate(actual_x,actual_y)
		src.transform = M

	animate_stars()
		if(!src)
			return

		if(!x_old)
			x_old = src.actual_x

		if(!y_old)
			y_old = src.actual_y

		var/matrix/M = GLOBAL_ANIMATION_MATRIX.Reset()
		if(scale)
			M = M.Scale(scale)
		M = M.Translate(actual_x,actual_y)
		animate(src, transform = M, time = animation_speed, loop = 0, flags = ANIMATION_PARALLEL)

		var/x_diff = src.actual_x - x_old
		var/y_diff = src.actual_y  - y_old

		var/datum/galactic_object/G = master
		if(src.has_ship_body && G)
			var/squared_pixel_distance = ((src.actual_x)**2 + (src.actual_y)**2)

			if(squared_pixel_distance <= 4096) //2 tiles * 32, squared
				if(!src.my_ship_body)
					G.load_ship_body(my_ship,src)
			else
				if(src.my_ship_body)
					var/temp = my_ship_body
					src.my_ship_body = null
					G.unload(temp)
					temp = null

			if(src.my_ship_body)
				src.my_ship_body.actual_x += ARTEMIS_MAP_SHIP_PIXEL_RATIO*x_diff
				src.my_ship_body.actual_y += ARTEMIS_MAP_SHIP_PIXEL_RATIO*y_diff
				src.my_ship_body.animate_stars()
				if(squared_pixel_distance <= (1024)) //1 tiles * 32, squared... plus slush
					src.my_ship_body.alpha = 255
				else
					src.my_ship_body.alpha = 0

		x_old = src.actual_x
		y_old = src.actual_y

	proc/on_load()
		return

	proc/on_unload()
		return

	proc/artemis_scan(var/mob/pilot, var/obj/artemis/ship)
		return

	disposing()
		..()
		landing_zone = null
		my_ship_body = null
		my_map_body = null
		master = null
		my_ship = null
		galaxy_icon = null

/obj/background_star/galactic_object/large
	name = "TEST OBJECT LARGE"
	icon = 'icons/misc/galactic_objects_large.dmi'
	icon_state = "generic"

	//re-center 528x528 icons
	pixel_x = -248
	pixel_y = -248

/obj/landmark/destination_landmark
	var/destination_name = null
	name_override = LANDMARK_PLANETS

	New()
		src.data = src.destination_name
		..()

#endif
