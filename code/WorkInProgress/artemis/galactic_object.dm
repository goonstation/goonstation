#ifdef ENABLE_ARTEMIS

var/global/datum/galaxy/GALAXY = new

/datum/galaxy
	var/list/bodies = list()
	var/list/available_planets = list("planet1", "planet2", "planet3", "planet4", "planet5", "planet6", "planet7")
	var/datum/asteroid_controller/asteroids = new
	var/seed
	var/mangled_rand
	var/datum/xor_rand_generator/Rand

#if !defined(GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW)
	New()
		..()
#if defined(DEBUG_ARTEMIS)
		Rand = new(513)
#else
		Rand = new(rand(3, 50000))
#endif

		src.bodies += new/datum/galactic_object/eyesenhower()
		src.bodies += new/datum/galactic_object/station()

#if defined(DEBUG_ARTEMIS)
		src.bodies += new/datum/galactic_object/test()
		src.bodies += new/datum/galactic_object/bhole
		src.bodies += new/datum/galactic_object/star
		src.bodies += new/datum/galactic_object/asteroid
#endif

		for(var/i in 1 to 5)
			src.bodies += new/datum/galactic_object/asteroid/random(src)

		SPAWN(20 SECONDS)
			populate_galaxy()
#endif

	/// Random Integer from (L,H) otherwise 0-1

/*
	 Make me a Galaxy!

	 Sector -> Generate Star(s)
	    |
	   Planetary Bodies (Origin is Primary Star of Sector)
	         |           |           |
	       Planets      Stars     Asteroids
	          |
	          Moons (Origin is Planet)
*/
	proc/populate_galaxy()
		var/i
		var/j
		for(i in 1 to 10)
			for(j in 1 to 10)
				if(Rand.xor_prob(80))
					generate_solar_system(i,j)
				else
					generate_empty_sector(i,j)

	proc/generate_solar_system(x,y)
		var/datum/galactic_object/star/primary
		var/datum/galactic_object/O
		var/datum/galactic_object/centeroid/C = new
		var/star_count

		var/sector_x = Rand.xor_rand() * 10 + (x * 10)
		var/sector_y = Rand.xor_rand() * 10 + (y * 10)

		primary = new/datum/galactic_object/star/random(src)
		primary.galactic_x = sector_x
		primary.galactic_y = sector_y
		src.bodies += primary
		C.galactic_x += primary.galactic_x
		C.galactic_y += primary.galactic_y
		star_count++

		if(Rand.xor_prob(50))
		//Binary System
			O = new/datum/galactic_object/star/random{random_range = list(0.1,0.3)}(src, primary)
			src.bodies += O
			C.galactic_x += O.galactic_x
			C.galactic_y += O.galactic_y
			star_count++

			//Trinary System!!!
			if(prob(5))
				O = new/datum/galactic_object/star/random{random_range = list(0.3,0.6)}(src, primary)
				src.bodies += O
				C.galactic_x += O.galactic_x
				C.galactic_y += O.galactic_y
				star_count++

		C.galactic_x /= star_count
		C.galactic_y /= star_count
		C.name = "Sector [x]:[y]"
		src.bodies += C

		var/planet_count = Rand.xor_rand(0,8)
		//GENERATE N PLANETS
		for(var/i in 1 to planet_count)
			O = new/datum/galactic_object/planet/random(src, C)
			src.bodies += O

			// Moooons
			var/moon_count = Rand.xor_prob(66) ? Rand.xor_rand(1,4) : 0
			for(var/j in 1 to moon_count)
				src.bodies +=new/datum/galactic_object/moon/random(src, O)

	proc/generate_empty_sector(x, y)
		var/asteroid_count = Rand.xor_rand(0,6)
		var/datum/galactic_object/asteroid/A

		for(var/i in 1 to asteroid_count)
			var/sector_x = Rand.xor_rand() * 10 + (x * 10)
			var/sector_y = Rand.xor_rand() * 10 + (y * 10)
			A = new/datum/galactic_object/asteroid/random(src)
			A.galactic_x = sector_x
			A.galactic_y = sector_y
			src.bodies += A


/datum/asteroid_controller
	var/list/available_asteroids = list()
	var/list/used_asteroids = list()
	var/list/obj/magnet_target_marker/asteroid/asteroid_markers = list()

	New()
		..()
		for(var/i in 1 to ASTEROID_BASIC_COUNT)
			available_asteroids += "asteroid[i]"

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
		SPAWN(1 SECOND)
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
	var/navigable = FALSE // Can be detected on long distance nav
	var/scale
	var/list/random_range = null


	New(datum/galaxy/G, datum/galactic_object/ref_obj)
		..()
		if(ref_obj)
			src.galactic_x = ref_obj.galactic_x
			src.galactic_y = ref_obj.galactic_y
		if(random_range)
			if(length(random_range))
				src.random_range_and_bearing(G, random_range[1], random_range[2])
			else
				CRASH("[src] random range incorrectly assigned.")

	proc/check_distance(ship_x, ship_y)
		var/squared_distance = (ship_x-galactic_x)**2 + (ship_y-galactic_y)**2
		if(src.loud)
			boutput(world,"[name]: x distance is [(ship_x-galactic_x)], y offset is [(ship_y-galactic_y)], squared distance is [squared_distance], canvas squared check radius is [(max_r_squared_galactic)]")
		if(squared_distance <= max_r_squared_galactic)
			return 1
		return 0

	proc/random_range_and_bearing(datum/galaxy/G, min_range=0, max_range=10)
		var/theta = G.Rand.xor_rand(360)
		var/r = G.Rand.xor_randf(min_range,max_range)

		src.galactic_x += r*sin(theta)
		src.galactic_y += r*cos(theta)

	proc/load_map_body(obj/artemis/ship)

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

	proc/load_ship_body(obj/artemis/ship, obj/background_star/galactic_object/G)

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
		ship_body.plane = PLANE_SPACE

		ship_body.parallax_multi = 1/20
		ship_body.loc = get_turf(ship_mark)

		ship_body.on_load()

		ship_body.galaxy_icon = image(ship_body.icon, ship_body, ship_body.icon_state, ship_body.layer)
		get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).add_image(ship_body.galaxy_icon)
		if(ship.bottom_x_offset)
			ship_body.duplicate_galaxy_icon = image(ship_body.icon, ship_body, ship_body.icon_state, ship_body.layer)
			ship_body.duplicate_galaxy_icon.pixel_x += (ship.bottom_x_offset * 32)
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).add_image(ship_body.duplicate_galaxy_icon)
		ship_body.icon_state = null

	proc/unload(var/obj/background_star/galactic_object/G,var/obj/artemis/ship)
		if(G.my_map_body)
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).remove_image(G.galaxy_icon)
			if(G.duplicate_galaxy_icon)
				get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).remove_image(G.duplicate_galaxy_icon)
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
	var/list/turf/landing_zones = null
	var/destination_name = null
	var/has_ship_body = 0
	var/obj/background_star/galactic_object/my_ship_body = null
	var/obj/background_star/galactic_object/my_map_body = null
	var/datum/galactic_object/master = null
	var/x_old = null
	var/y_old = null
	var/scale
	plane = PLANE_SPACE
	max_visibility = (750 * 700)

	New()
		..()
		if(src.destination_name)
			SPAWN(1 SECOND)
				for(var/turf/T in landmarks[LANDMARK_PLANETS])
					if(landmarks[LANDMARK_PLANETS][T] == src.destination_name)
						if(!src.landing_zones) src.landing_zones = list()
						src.landing_zones[name] = T
						return

	proc/check_distance(max_distance)
		var/squared_pixel_distance = ((src.actual_x)**2 + (src.actual_y)**2)
		if(squared_pixel_distance <= max_distance)
			.= TRUE

	set_vars(theta, dist)

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
			M = M.Scale(src.scale)
		M = M.Translate(actual_x, actual_y)
		animate(src, transform = M, time = animation_speed, loop = 0, flags = ANIMATION_PARALLEL)

		var/x_diff = src.actual_x - x_old
		var/y_diff = src.actual_y  - y_old

		var/datum/galactic_object/G = master
		if(src.has_ship_body && G)
			var/squared_pixel_distance = ((src.actual_x)**2 + (src.actual_y)**2)

			if(squared_pixel_distance <= 4096) //2 tiles * 32, squared
				if(!src.my_ship_body)
					G.load_ship_body(my_ship, src)
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
		landing_zones = null
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
	name = "Planet Drop"
	var/destination_name = null
	name_override = LANDMARK_PLANETS

	New()
		src.data = src.destination_name
		..()

#endif
