/datum/galactic_object/ship
	var/rotation = 0
	var/body_icon = null
	var/body_icon_state = null
	var/body_icon_base = null
	body_path_map = /obj/background_star/galactic_object/ship
	var/vel_mag = 0
	var/vel_angle = 0
	var/obj/artemis/my_ship = null

	load_map_body(var/obj/artemis/ship)

		var/obj/background_star/galactic_object/ship/map_body = ..(ship)

		map_body.icon = body_icon
		map_body.icon_state = body_icon_state
		map_body.icon_base = body_icon_base

		return map_body

	proc/relay_flick()
		return

	proc/relay_update(var/gal_x,var/gal_y,var/mag_pan,var/vel_ang,var/ship_ang)
		src.galactic_x = gal_x
		src.galactic_y = gal_y
		src.rotation = ship_ang
		src.vel_mag = mag_pan
		src.vel_angle = vel_ang
		for(var/x in src.nearby_ships)
			var/obj/background_star/galactic_object/ship/map_body = nearby_ships[x]
			if(istype(map_body))
				map_body.stars_update()
				if(!map_body.start)
					map_body.animate_stars()
		return

/obj/background_star/galactic_object/ship
	name = null
	icon = null
	icon_state = null
	var/icon_base = null

	on_load()
		var/datum/galactic_object/ship/G = master
		G.my_ship.load_body(src.my_ship.background_ship_datum,1)
	on_unload()
		var/datum/galactic_object/ship/G = master
		G.my_ship.unload_body(src.my_ship.background_ship_datum,1)

	process()
		var/animate = 0
		var/datum/galactic_object/ship/G = master
		while(start)
			if(!rot_mag && !vel_mag && !G.vel_mag)
				src.start = 0
			if(rot_mag)
				animate = 1
				src.stars_rotate(rot_mag)
			if(vel_mag)
				animate = 1
				src.stars_pan(vel_mag,vel_angle)
			if(G.vel_mag)
				animate = 1
				src.stars_pan(G.vel_mag,G.vel_angle)
			if(animate)
				animate_stars()
				animate = 0
			sleep(animation_speed)
		return

	stars_update(mag_pan,mag_rot,angle,ship_ang)
		..(mag_pan,mag_rot,angle,ship_ang)
		var/datum/galactic_object/ship/G = master
		if((mag_pan || mag_rot || G.vel_mag) && !start)
			src.stars_start()

	animate_stars()
		if(!src)
			return

		if(!x_old)
			x_old = src.actual_x

		if(!y_old)
			y_old = src.actual_y

		var/datum/galactic_object/ship/G = master

		var/matrix/M = GLOBAL_ANIMATION_MATRIX.Reset()
		M = M.Turn(-my_ship.ship_angle)
		M = M.Turn(G.rotation)
		M = M.Translate(actual_x,actual_y)
		animate(src, transform = M, time = animation_speed, loop = 0, flags = ANIMATION_PARALLEL)

		var/x_diff = src.actual_x - x_old
		var/y_diff = src.actual_y  - y_old


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

		x_old = src.actual_x
		y_old = src.actual_y