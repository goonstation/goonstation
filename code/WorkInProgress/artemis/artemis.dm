#define ARTEMIS_ANIMATION_SPEED 2 // 2/10ths of a second. used to calculate various displacements
#define ARTEMIS_MAX_R 951
#define ARTEMIS_MAX_R_SQUARED 904401 //951^2 - sqrt(2)*672; radius of circle with the boundary box inscribed in it
#define ARTEMIS_MAX_R_SQUARED_GALACTIC 35.328 //(951*2/320)**2
#define ARTEMIS_MAP_SHIP_PIXEL_RATIO 29.7 //3804 pixel diameter circle for rendering ship object, compared to a 128 pixel circle for map object movement; scale diff is 29.7
#define ARTEIMS_MAP_VIEW_SIZE 31 // 31x31 tiles

/obj/artemis
	name = "Artemis-"
	desc = "Artemis"
	icon = 'icons/misc/artemis.dmi'
	icon_state = "artemis"
	var/icon_base = "artemis"
	var/stars_id = "artemis"
	var/list/obj/background_star/my_stars = list()
	var/list/obj/background_star/galactic_object/my_galactic_objects = list() // stores nearby galactic objects and references to their tracking images
	var/obj/landmark/ship_marker/ship_marker

	var/mob/my_pilot = null

	var/vel_angle = 0 // degrees from north
	var/vel_mag = 0 //pixels/sec

	var/accel = 0.5 // pixels/sec/sec

	var/rotating = 0 // are we accelerating our angle?
	var/accelerating = 0 // are we accelerating our velocity?

	var/max_speed = 40

	var/rot_loop_on = 0 //is the rotation loop on?
	var/rot_speed = 5 //degrees per half second

	var/rot_mag = 0
	var/rot_accel = 0.75
	var/rot_deccel = 0.75
	var/rot_max_speed = 4.5

	var/ship_angle = 0 //degrees from north

	var/galactic_x = 0
	var/galactic_y = 0

	var/old_vel = null
	var/old_time = null
	var/old_ang = null
	var/old_x = null
	var/old_y = null

	var/animation_speed = ARTEMIS_ANIMATION_SPEED

	var/datum/galaxy/my_galaxy = null

	var/tracking = 0 // is tracking loop on?
	var/show_tracking = 1 // do we show tracking arrows?

	var/image/nav_arrow = null
	var/navigating = 0
	var/datum/galactic_object/navigation_target = null

	var/do_process = 0

	var/image/back_left = null
	var/image/back_right = null
	var/image/front_left = null
	var/image/front_right = null
	var/image/back = null
	var/has_back = 1

	var/num_stars = 200
	var/map_size = ARTEIMS_MAP_VIEW_SIZE

	var/datum/galactic_object/ship/background_ship_datum

	var/control_lock = 0

	var/buoy_count = 3

	var/datum/movement_controller/artemis/controller
	var/controller_type = null

	New()
		..()
		if(controller_type)
			var/path = text2path("/datum/movement_controller/artemis/[controller_type]")
			controller = new path(src)
		else
			controller = new(src)
		SubscribeToProcess()
		src.background_ship_datum = new/datum/galactic_object/ship()
		background_ship_datum.body_icon = src.icon
		background_ship_datum.body_icon_state = src.icon_state
		background_ship_datum.body_icon_base = src.icon_base
		background_ship_datum.my_ship = src
		background_ship_datum.galactic_x = src.galactic_x
		background_ship_datum.galactic_y = src.galactic_y
		background_ship_datum.rotation = src.ship_angle

		back_left = image('icons/misc/artemis.dmi')
		back_right = image('icons/misc/artemis.dmi')
		front_left = image('icons/misc/artemis.dmi')
		front_right = image('icons/misc/artemis.dmi')

		back_left.loc = src
		back_right.loc = src
		front_left.loc = src
		front_right.loc = src

		if(has_back)
			back = image('icons/misc/artemis.dmi')
			back.loc = src

		gen_stars()

		spawn(0)
			do_process = 1
			src.fast_process()

	disposing()
		UnsubscribeProcess()
		..()

	proc/SubscribeToProcess()
		if (!(src in processing_items))
			processing_items.Add(src)

	proc/UnsubscribeProcess()
		if (src in processing_items)
			processing_items.Remove(src)

	get_movement_controller()
		return controller

	proc/link_landmark()
		for(var/obj/landmark/ship_marker/L in world)
			if(L.ship_id == src.stars_id)
				src.ship_marker = L

	proc/engine_check()
		return 1

	proc/gen_stars()
		var/map_max_r = map_size*16*sqrt(2) // circle than inscribes the map view square
		var/map_max_r_squared = map_max_r**2
		var/obj/background_star/S = null
		for(var/i=0,i<num_stars,i++)
			S = new/obj/background_star()
			S.loc = get_turf(src)
			S.ships_id =  src.stars_id
			S.max_r = map_max_r
			S.max_r_squared = map_max_r_squared

	proc/link_stars()
		for(var/obj/background_star/S in world)
			if(S.ships_id == src.stars_id)
				src.my_stars += S
				S.my_ship = src

	proc/rotate_ship()
		if(src.rot_loop_on)
			return
		src.rot_loop_on = 1
		var/keep_rotating = 1
		while(keep_rotating)
			keep_rotating = src.handle_rotate()
			sleep(animation_speed)

		src.update_my_stuff()

		src.rot_loop_on = 0

	proc/handle_rotate()
		if(!src.rot_loop_on)
			src.rot_mag = 0
			src.update_my_stuff()
			return 0

		src.ship_angle += rot_mag
		src.ship_angle = ship_angle >= 0 ? ship_angle%360 : -((-ship_angle)%360)+360 // sets angle to value in [0,360)

		src.update_my_stuff()

		if(!src.rotating)
			if(src.rot_mag > 0)
				src.rot_mag = src.rot_mag - src.rot_deccel
				src.rot_mag = max(src.rot_mag,0)
			else if (src.rot_mag < 0)
				src.rot_mag = src.rot_mag + src.rot_deccel
				src.rot_mag = min(src.rot_mag,0)
		if(src.rot_mag)
			return 1
		return 0

	proc/fast_process()
		while(do_process)
			if(vel_mag)
				calc_new_coords()
			if(tracking)
				do_tracking()
			if(navigating)
				update_nav_arrow()
			sleep(animation_speed)


	proc/process() //slow processing
		if(!old_x)
			old_x = galactic_x
		if(!old_y)
			old_y = galactic_y

		calc_new_coords()

		if(old_x == galactic_x && old_y == galactic_y)
			return

		old_x = galactic_x
		old_y = galactic_y

		for(var/datum/galactic_object/G in (my_galaxy.bodies - background_ship_datum))
			var/check_val = G.check_distance(galactic_x, galactic_y)
			if(check_val)
				src.load_body(G)
			else
				src.unload_body(G)

		if(my_galactic_objects.len > 0 && !src.tracking)
			spawn(0)
				src.begin_tracking()
		else if (my_galactic_objects.len == 0 && src.tracking)
			spawn(0)
				src.end_tracking()

	proc/load_body(var/datum/galactic_object/G, var/force_tracking_update = 0)
		if(!(src in G.nearby_ships))
			var/obj/background_star/galactic_object/map_body = G.load_map_body(src)
			my_galactic_objects += map_body

			if(navigating && (G == src.navigation_target))
				src.navigating = 0
				if(my_pilot && src.nav_arrow in my_pilot.client.images)
					my_pilot.show_message("<span class='notice'>Navigation target reached.</span>")
					my_pilot.client.images -= src.nav_arrow

			my_galactic_objects[map_body] = src.track_object(map_body) // feeds it the tracking arrow icon nom nom

			if(my_pilot && show_tracking)
				if(my_pilot.client)
					if(!(my_galactic_objects[map_body] in my_pilot.client.images))
						my_pilot.client.images += my_galactic_objects[map_body]

			map_body.stars_update(src.vel_mag,src.rot_mag,src.vel_angle,src.ship_angle)

			if(force_tracking_update)
				if(my_galactic_objects.len > 0 && !src.tracking)
					spawn(0)
						src.begin_tracking()

	proc/unload_body(var/datum/galactic_object/G, var/force_tracking_update = 0)
		if(src in G.nearby_ships)
			var/obj/background_star/galactic_object/map_body = G.nearby_ships[src]
			var/temp = my_galactic_objects[map_body]
			boutput(my_pilot,"Local Object Lost: [map_body]")
			if(my_pilot)
				if(my_pilot.client)
					if((my_galactic_objects[map_body] in my_pilot.client.images))
						my_pilot.client.images -= my_galactic_objects[map_body]
			my_galactic_objects[map_body] = null
			qdel(temp)
			temp = null
			my_galactic_objects -= map_body
			G.unload(map_body,src)

			if(force_tracking_update)
				if (my_galactic_objects.len == 0 && src.tracking)
					spawn(0)
						src.end_tracking()

	proc/update_my_stuff(var/vel, var/rot, var/vang, var/sang)
		if(!vel)
			vel = vel_mag
		if(!rot)
			rot = rot_mag
		if(!vang)
			vang = vel_angle
		if(!sang)
			sang = ship_angle
		for(var/obj/background_star/S in src.my_stars)
			S.stars_update(vel,rot,vang,sang)

		for(var/obj/background_star/galactic_object/G in src.my_galactic_objects)
			G.stars_update(vel,rot,vang,sang)

		background_ship_datum.relay_update(galactic_x,galactic_y,vel_mag,vel_angle,ship_angle)

	proc/calc_new_coords()
		var/new_time = world.timeofday // in 1/10ths of seconds
		var/delta = (new_time - src.old_time)/animation_speed/320 // converting to clean chunks based on animation speed, then to 10x tiles instead of pixels? not sure what resolution i want for this yet

		var/new_galactic_x = (vel_mag*sin(vel_angle))*delta + galactic_x
		var/new_galactic_y = (vel_mag*cos(vel_angle))*delta + galactic_y

		if(abs(new_galactic_x - galactic_x) > 0.0000001) //f u floats
			src.galactic_x = new_galactic_x
		if(abs(new_galactic_y - galactic_y) > 0.0000001)
			src.galactic_y = new_galactic_y

		src.old_time = new_time

	proc/track_object(var/obj/background_star/galactic_object/G)
		var/image/tracking_arrow = image('icons/misc/artemis.dmi',icon_state = "tracking_arrow")
		var/ang = arctan(G.actual_x,G.actual_y)
		var/matrix/M = GLOBAL_ANIMATION_MATRIX.Reset()
		M = M.Turn(ang)
		M = M.Translate(32*sin(ang),32*cos(ang))
		tracking_arrow.transform = M
		tracking_arrow.loc = src
		boutput(my_pilot,"New local object detected: [G]")
		return tracking_arrow

	proc/begin_tracking()
		tracking = 1
		//any later setup code can go here
		return

	proc/do_tracking()
		var/image/tracking_arrow = null
		var/ang = null
		var/matrix/M = null
		for(var/obj/background_star/galactic_object/G in src.my_galactic_objects)
			tracking_arrow = my_galactic_objects[G]
			ang = arctan(G.actual_y,G.actual_x)
			M = GLOBAL_ANIMATION_MATRIX.Reset()
			M = M.Turn(ang)
			M = M.Translate(32*sin(ang),32*cos(ang))
			animate(tracking_arrow, transform = M, time = animation_speed, loop = 0)
		return

	proc/end_tracking()
		tracking = 0
		//any later cleanup code can go here
		return

	proc/apply_arrows(var/mob/M)
		for(var/obj/background_star/galactic_object/G in src.my_galactic_objects)
			if(!(my_galactic_objects[G] in M.client.images))
				M.client.images += my_galactic_objects[G]
		return

	proc/remove_arrows(var/mob/M)
		for(var/obj/background_star/galactic_object/G in src.my_galactic_objects)
			if((my_galactic_objects[G] in my_pilot.client.images))
				M.client.images -= my_galactic_objects[G]
		return

	proc/create_nav_arrow(var/datum/galactic_object/G)
		src.navigation_target = G
		var/image/new_nav_arrow = null
		if(!src.nav_arrow)
			new_nav_arrow = image('icons/misc/artemis.dmi',icon_state = "nav_arrow")
		else
			new_nav_arrow = src.nav_arrow
		var/x_offset = navigation_target.galactic_x - src.galactic_x
		var/y_offset = navigation_target.galactic_y - src.galactic_y
		var/ang = arctan(y_offset,x_offset)
		ang = ang - ship_angle
		var/matrix/M = GLOBAL_ANIMATION_MATRIX.Reset()
		M = M.Turn(ang)
		M = M.Translate(32*sin(ang),32*cos(ang))
		new_nav_arrow.transform = M
		new_nav_arrow.loc = src
		return new_nav_arrow

	proc/update_nav_arrow()
		var/matrix/M = null
		var/x_offset = src.navigation_target.galactic_x - src.galactic_x
		var/y_offset = src.navigation_target.galactic_y - src.galactic_y
		var/ang = arctan(y_offset,x_offset)
		ang = ang - ship_angle
		M = GLOBAL_ANIMATION_MATRIX.Reset()
		M = M.Turn(ang)
		M = M.Translate(32*sin(ang),32*cos(ang))
		animate(src.nav_arrow, transform = M, time = animation_speed, loop = 0)
		return

	proc/apply_nav_arrow(var/mob/M)
		if(!(src.nav_arrow in my_pilot.client.images))
			M.client.images += src.nav_arrow
		return

	proc/remove_nav_arrow(var/mob/M)
		if((src.nav_arrow in my_pilot.client.images))
			M.client.images -= src.nav_arrow
		return

	proc/apply_thrusters(var/mob/M)
		if(front_right && !(front_right in M.client.images))
			M.client.images += front_right
		if(front_left && !(front_left in M.client.images))
			M.client.images += front_left
		if(back_right && !(back_right in M.client.images))
			M.client.images += back_right
		if(back_left && !(back_left in M.client.images))
			M.client.images += back_left
		if(back && !(back in M.client.images))
			M.client.images += back

	proc/remove_thrusters(var/mob/M)
		if(front_right in M.client.images)
			M.client.images -= front_right
		if(front_left in M.client.images)
			M.client.images -= front_left
		if(back_right in M.client.images)
			M.client.images -= back_right
		if(back_left in M.client.images)
			M.client.images -= back_left
		if(back in M.client.images)
			M.client.images -= back


/obj/artemis/arjuna
	name = "Arjuna-"
	desc = "Arjuna"
	icon = 'icons/misc/artemis.dmi'
	icon_state = "arjuna"
	icon_base = "arjuna"
	stars_id = "arjuna"
	ship_angle = 180 //degrees from north
	galactic_x = 0
	galactic_y = 30
	vel_angle = 180
	has_back = 0

/obj/artemis/manta
	name = "Manta-"
	desc = "Manta"
	icon = 'icons/misc/artemis.dmi'
	icon_state = "manta"
	icon_base = "manta"
	stars_id = "manta"
	ship_angle = 0 //degrees from north
	galactic_x = 20
	galactic_y = 20
	vel_angle = 0
	has_back = 1
	rot_mag = 0
	rot_accel = 0.5
	rot_deccel = 0.25
	rot_max_speed = 1
	var/drag_coefficient = 0.01
	var/engine_working_temp = 1
	var/r_curvature = 50

	controller_type = "manta"


	fast_process()
		while(do_process)
			if(vel_mag)
				calc_new_coords()
				if(engine_check()) // ENGINE CHECK HERE LATER
					if(!back.icon_state)
						back.icon_state = "[icon_base]_thruster_back"
				else
					do_drag()
					if(back.icon_state)
						back.icon_state = null
			else
				if(back.icon_state)
					back.icon_state = null
			if(tracking)
				do_tracking()
			if(navigating)
				update_nav_arrow()
			sleep(animation_speed)


	proc/do_drag()
		src.vel_mag = max(vel_mag - drag_coefficient*vel_mag**2,0)
		if(vel_mag < 1)
			vel_mag = 0
		src.update_my_stuff()


	gen_stars()
		var/map_max_r = map_size*16*sqrt(2) // circle than inscribes the map view square
		var/map_max_r_squared = map_max_r**2
		var/obj/background_star/manta/S = null
		for(var/i=0,i<num_stars,i++)
			S = new/obj/background_star/manta()
			S.loc = get_turf(src)
			S.ships_id =  src.stars_id
			S.max_r = map_max_r
			S.max_r_squared = map_max_r_squared

	handle_rotate()
		if(!src.rot_loop_on)
			src.rot_mag = 0
			src.update_my_stuff()
			return 0

		var/angular_velocity = 0// angular displacement about turning point
		if(vel_mag)
			angular_velocity = 360/(r_curvature)/(3.14159) // degrees per second

		var/rot_mag_out = rot_mag*angular_velocity/2 // degrees per half second

		src.ship_angle += rot_mag_out
		src.ship_angle = ship_angle >= 0 ? ship_angle%360 : -((-ship_angle)%360)+360 // sets angle to value in [0,360)
		src.vel_angle += rot_mag_out
		src.vel_angle = vel_angle >= 0 ? vel_angle%360 : -((-vel_angle)%360)+360 // sets angle to value in [0,360)

		src.update_my_stuff(rot = rot_mag_out)

		if(!src.rotating)
			if(src.rot_mag > 0)
				src.rot_mag = src.rot_mag - src.rot_deccel
				src.rot_mag = max(src.rot_mag,0)
			else if (src.rot_mag < 0)
				src.rot_mag = src.rot_mag + src.rot_deccel
				src.rot_mag = min(src.rot_mag,0)
		if(src.rot_mag)
			return 1
		return 0
