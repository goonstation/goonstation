#ifdef ENABLE_ARTEMIS

#define ARTEMIS_ANIMATION_SPEED 2 // 2/10ths of a second. used to calculate various displacements
#define ARTEMIS_MAX_R 951
#define ARTEMIS_MAX_R_VIS 500
#define ARTEMIS_MAX_R_SQUARED_VIS (ARTEMIS_MAX_R_VIS * ARTEMIS_MAX_R_VIS)
#define ARTEMIS_MAX_R_SQUARED 904401 //951^2 - sqrt(2)*672; radius of circle with the boundary box inscribed in it
#define ARTEMIS_MAX_R_SQUARED_GALACTIC 35.328 //(951*2/320)**2
#define ARTEMIS_MAP_SHIP_PIXEL_RATIO 29.7 //3804 pixel diameter circle for rendering ship object, compared to a 128 pixel circle for map object movement; scale diff is 29.7
#define ARTEIMS_MAP_VIEW_SIZE 31 // 31x31 tiles

/datum/artemis_engine_controller
	var/malfunction = FALSE
	//Abstract Engine Health into 1:NW, 2:NE, 3:SW, 4:SE, 5-8:S
	var/list/engine_health = list(1,1,1,1,1,1,1,1)
	var/list/engine_list = list()

	proc/engine_check()
		. = !src.malfunction && TRUE //check that requipment power is on

	proc/use_power(list/banks, stress)
		for(var/bank in banks)
			for(var/obj/machinery/shuttle/engine/propulsion/P in engine_list[bank])
				P.use_power(500)

	proc/add_engine(obj/machinery/shuttle/engine/propulsion/P)
		if(!src.engine_list[P.id])
			src.engine_list[P.id] = list()
		src.engine_list[P.id] |= P

/obj/artemis
	name = "Artemis"
	desc = "Artemis"
	icon = 'icons/misc/artemis.dmi'
	icon_state = "artemis"
	var/icon_base = "artemis"
	var/stars_id = "artemis"
	var/list/obj/background_star/my_stars = list()
	var/list/obj/background_star/galactic_object/my_galactic_objects = list() // stores nearby galactic objects and references to their tracking images
	var/turf/ship_marker

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
	var/sensor_range = 4096
	var/teleporter_range = 4096

	var/do_process = 0

	var/image/back_left = null
	var/image/back_right = null
	var/image/front_left = null
	var/image/front_right = null
	var/image/back = null
	var/has_back = 1

	var/num_stars = 80 // 200
	var/map_size = ARTEIMS_MAP_VIEW_SIZE

	var/datum/galactic_object/ship/background_ship_datum

	var/control_lock = 0

	var/full_throttle = FALSE
	var/buoy_count = 3

	var/bottom_x_offset = 57 // tile offset for duplicated bottom

	var/obj/machinery/sim/vr_bed/flight_chair/controls
	var/datum/movement_controller/artemis/movement_controller
	var/datum/artemis_engine_controller/engines
	var/controller_type = null

	New()
		..()
		src.engines = new(src)
		if(controller_type)
			var/path = text2path("/datum/movement_controller/artemis/[controller_type]")
			movement_controller = new path(src)
		else
			movement_controller = new(src)
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

		SPAWN(0)
			do_process = 1
			src.fast_process()
		START_TRACKING

	disposing()
		UnsubscribeProcess()
		STOP_TRACKING
		..()

	proc/SubscribeToProcess()
		if (!(src in processing_items))
			processing_items.Add(src)

	proc/UnsubscribeProcess()
		if (src in processing_items)
			processing_items.Remove(src)

	proc/engine_check()
		. = engines.engine_check()

	proc/use_power(var/list/banks, var/stress)
		engines.use_power(banks, stress)

	proc/link_landmark()
		for(var/turf/T in landmarks[LANDMARK_SHIPS])
			if(landmarks[LANDMARK_SHIPS][T] == src.stars_id)
				src.ship_marker = T

#ifdef ARTEMIS_LINK_AT_ROUNDSTART
		if(!is_syndicate && !special_places.Find(src.name))
			special_places.Add(src.name)
#endif

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
			S.galaxy_icon = image(S.icon, S, S.icon_state, S.layer)
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_MAP_ICONS).add_image(S.galaxy_icon)
			S.icon = null

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
#ifdef DEBUG_ARTEMIS
		var/tick = TIME
		var/list/timing = list()
		timing.len = 2
		timing[1] = 0
		timing[2] = 0
#endif
		while(do_process)
			if(src.vel_mag)
				calc_new_coords()
			if(src.tracking)
				do_tracking()
			if(src.navigating)
				update_nav_arrow()

			for(var/obj/background_star/S in src.my_stars)
				if(S.start)
					S.process()

			for(var/obj/background_star/galactic_object/G in src.my_galactic_objects)
				if(G.start)
					G.process()

#ifdef DEBUG_ARTEMIS
			var/delta = TIME - tick
			if(timing[2] > 120)
				boutput(world,"[src] fast_process() running at [timing[1]/timing[2]] avg with [animation_speed] sleep delay")
				timing[1] = 0
				timing[2] = 0
			else
				timing[1] += delta
				timing[2]++
			tick = TIME
#endif
			sleep(animation_speed)

	proc/process() //slow processing
		calc_new_coords()

		if(!my_galaxy)
			my_galaxy = GALAXY
			link_stars()
			link_landmark()
			GALAXY.bodies += background_ship_datum

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
			SPAWN(0)
				src.begin_tracking()
		else if (my_galactic_objects.len == 0 && src.tracking)
			SPAWN(0)
				src.end_tracking()

	proc/load_body(var/datum/galactic_object/G, var/force_tracking_update = 0)
		if(!(src in G.nearby_ships))
			var/obj/background_star/galactic_object/map_body = G.load_map_body(src)
			src.my_galactic_objects += map_body

			if(navigating && (G == src.navigation_target))
				src.navigating = 0
				if(my_pilot && (src.nav_arrow in my_pilot.client.images))
					my_pilot.show_message(SPAN_NOTICE("Navigation target reached."))
					my_pilot.client.images -= src.nav_arrow

			my_galactic_objects[map_body] = src.track_object(map_body) // feeds it the tracking arrow icon nom nom

			if(my_pilot && show_tracking)
				if(my_pilot.client)
					if(!(my_galactic_objects[map_body] in my_pilot.client.images))
						my_pilot.client.images += my_galactic_objects[map_body]

			map_body.stars_update(src.vel_mag,src.rot_mag,src.vel_angle,src.ship_angle)

			if(force_tracking_update)
				if(my_galactic_objects.len > 0 && !src.tracking)
					SPAWN(0)
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
					SPAWN(0)
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
			if((my_galactic_objects[G] in my_pilot.client?.images))
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
		if((src.nav_arrow in my_pilot.client?.images))
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
		if(front_right in M.client?.images)
			M.client.images -= front_right
		if(front_left in M.client?.images)
			M.client.images -= front_left
		if(back_right in M.client?.images)
			M.client.images -= back_right
		if(back_left in M.client?.images)
			M.client.images -= back_left
		if(back in M.client?.images)
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
	bottom_x_offset = null
	is_syndicate = TRUE

	New()
		..()
#ifndef DEBUG_ARTEMIS
		qdel(src)
#endif

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

	New()
		..()
		qdel(src)

	fast_process()
		while(do_process)
			if(vel_mag)
				calc_new_coords()
				if(src.engine_check()) // ENGINE CHECK HERE LATER
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
			S.galaxy_icon = image(S.icon, S, S.icon_state, S.layer)
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_MAP_ICONS).add_image(S.galaxy_icon)
			S.icon = null

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

/area/ship
	teleport_blocked = AREA_TELEPORT_BLOCKED

	artemis
		name = "Artemis"
	arjuna
		name = "Arjuna"
	manta
		name = "Manta"
	space_canvas
		name = "Space Canvas"

	Entered(atom/movable/A)
		. = ..()
		if(ismob(A))
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).add_mob(A)

	Exited(atom/movable/A)
		. = ..()
		if(ismob(A))
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).remove_mob(A)


// Azrun TODO Move to Event File
/datum/random_event/minor/artemis_transponder
	name = "Artemis Transponder"
	customization_available = TRUE
	disabled = 1
	weight = 10
	var/list/event_transmissions

	var/options = list(
		"Martians"=10,
		"Zombies"=10,
		"Flock"=1,
		"Assault"=2,
		"Disappeared"=4
		)

	admin_call(var/source)
		if (..())
			return

		var/scenario = tgui_input_list(usr,"What happened to Artemis crew?", "Artemis Incident", src.options)

		src.event_effect(source, scenario)

	event_effect(source, scenario)
		..()

		if(!scenario)
			scenario = weighted_pick(src.options)

		spawn_scenario(scenario)

		var/command_report = "Transponder data has been detected from the NSS Artemis.  Encryption key uploaded to Quantum telescope to allow for asset recovery."
		tele_man.addManualEvent(eventType=/datum/telescope_event/artemis, active=TRUE)

		var/sound_to_play = "sound/misc/announcement_1.ogg"
		command_announcement(replacetext(command_report, "\n", "<br>"), "Priority Broadcast Received", sound_to_play, do_sanitize=0);
		return


	is_event_available(var/ignore_time_lock = 0)
		return 0

	proc/spawn_scenario(scenario)
		var/list/mob_types
		var/mob_count
		var/body_count
		var/artemis_turfs = get_area_turfs(/area/ship/artemis, 1)
		var/broken_lights = rand(0,5)
		switch(scenario)
			if("Martians")
				mob_types = list(/mob/living/critter/martian=50, /mob/living/critter/martian/soldier=10, /mob/living/critter/martian/mutant=1, /mob/living/critter/martian/warrior=10, null=5)
				mob_count = 10
				body_count = 8
			if("Zombies")
				mob_types = list(/mob/living/critter/zombie/scientist=5,/mob/living/critter/zombie/radiation=2, /mob/living/critter/zombie/security=2, /mob/living/critter/zombie=10, null=1)
				mob_count = 8
				body_count = 2
			if("Flock")
				mob_types = list(/mob/living/critter/flock/drone=1,/mob/living/critter/flock/bit=5)
				mob_count = 2
				body_count = 8
			if("Assault")
				mob_types = list(/obj/decoration/syndcorpse5=1,/obj/decoration/syndcorpse10=1,/obj/dialogueobj/engineerscorpse=4,/obj/dialogueobj/securitycorpse1=4,/obj/dialogueobj/securitycorpse6=4,/obj/dialogueobj/securitycorpse7=1,/obj/dialogueobj/syndiecorpse7=1)
				mob_count = 6
				body_count = 4
				broken_lights = 5
				for(var/i in 1 to rand(6,10))
					var/turf/T = pick(artemis_turfs)
					if(prob(70))
						for(var/j in 1 to rand(2,5))
							new /obj/item/casing/small(T)
					else if(prob(70))
						for(var/j in 1 to rand(2,3))
							new /obj/item/casing/shotgun/red(T)
					else
						new /obj/item/casing/rifle(T)


		var/bodies_to_gib
		if(body_count)
			bodies_to_gib = list()
			for(var/i in 1 to body_count)
				if(prob(10))
					bodies_to_gib += new /mob/living/carbon/human/npc(pick(artemis_turfs))
				else
					gibs(pick(artemis_turfs))

		if(mob_types && mob_count)
			for(var/i in 1 to mob_count)
				var/mob_path = weighted_pick(mob_types)
				if(mob_path != "null")
					new mob_path(pick(artemis_turfs))

		if(broken_lights)
			var/obj/machinery/light/L
			var/list/obj/machinery/light/lights = list()

			var/area/A = get_area_by_type(/area/ship/artemis)
			for(L in A.machines)
				lights += L
			for(var/i in 1 to broken_lights)
				L = pick(lights)
				L.broken()

		sleep(10 SECONDS)
		for(var/mob/living/carbon/human/M in bodies_to_gib)
			M.gib()

#endif
