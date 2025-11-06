#ifdef ENABLE_ARTEMIS

var/global/matrix/GLOBAL_ANIMATION_MATRIX = matrix()

/obj/background_star
	var/ships_id = "artemis"
	var/obj/artemis/my_ship = null
	var/parallax_multi = 1
	icon = 'icons/misc/background_stars.dmi'
	icon_state = "1"
	mouse_opacity = 0

	var/image/galaxy_icon
	var/image/duplicate_galaxy_icon
	var/actual_x = 0
	var/actual_y = 0

	var/vel_mag = 0 // pixels/sec
	var/vel_angle = 0 //degrees clockwise from north
	var/ship_angle = 0

	var/animation_speed = ARTEMIS_ANIMATION_SPEED // 1/10 seconds

	var/rotate = 0 //rotation queued

	var/rot_mag = 0 // degrees per half second

	var/start = 0

	var/max_r = ARTEMIS_MAX_R

	var/max_r_squared = ARTEMIS_MAX_R_SQUARED //951^2 - sqrt(2)*672; radius of circle with the boundary box inscribed in it

	var/max_visibility = ARTEMIS_MAX_R_SQUARED_VIS

	New()
		..()
#if defined(DEBUG_ARTEMIS)
		mouse_opacity = 1
#endif
		appearance_flags |= PIXEL_SCALE
		if(istype(src,/obj/background_star/galactic_object))
			return
		set_vars()

	proc/set_vars()

		src.set_state()
		var/theta
		var/r

		do
			theta = rand(360)
			r = rand(max_r)

			src.actual_x = r*sin(theta)
			src.actual_y = r*cos(theta)
		while((actual_y**2 + actual_x**2) > max_r_squared)

		if(r > ARTEMIS_MAX_R_VIS)
			src.alpha = 0

		var/matrix/M = GLOBAL_ANIMATION_MATRIX.Reset()
		M = M.Translate(actual_x,actual_y)
		src.transform = M

	proc/set_state()
		var/state = rand(1,9)
		icon_state = "[state]"
		if(galaxy_icon)
			galaxy_icon.icon_state = icon_state
		if(duplicate_galaxy_icon)
			duplicate_galaxy_icon.icon_state = icon_state

		if(state<7)
			parallax_multi = 5 + (2*((rand()*2)-1))
		else
			parallax_multi = 8  + (1*((rand()*2)-1))

	proc/process()
		SHOULD_NOT_SLEEP(TRUE) // Check that this isn't being slept
		var/animate = 0
		//while(start)
		if(!rot_mag && !vel_mag)
			src.start = 0
		if(rot_mag)
			animate = 1
			src.stars_rotate(rot_mag)
		if(vel_mag)
			animate = 1
			src.stars_pan(vel_mag,vel_angle)
		if(animate)
			animate_stars()
			animate = 0
			//sleep(animation_speed)
		return

	proc/stars_start()
		src.start = 1
		// spawn(0)
		// 	src.process()
		return

	proc/stars_update(mag_pan,mag_rot,angle,ship_ang)
		if((mag_pan || mag_rot) && !start)
			src.stars_start()
		if(mag_pan != null && angle != null)
			src.vel_mag = -mag_pan
			src.vel_angle = angle
		if(mag_rot != null)
			src.rot_mag = mag_rot
		if(ship_ang != null)
			src.ship_angle = ship_ang

	proc/actual_rot_speed(rot_speed)
		. = rot_speed
		return

	proc/actual_pan_speed(pan_speed)
		. = pan_speed/parallax_multi
		return

	proc/stars_rotate(rot_speed) // 1 is clockwise, -1 is counterclockwise
		var/angle = actual_rot_speed(rot_speed)

		var/new_x = src.actual_x * cos(angle) - src.actual_y * sin(angle)
		var/new_y = src.actual_y * cos(angle) + src.actual_x * sin(angle)

		src.actual_x = new_x
		src.actual_y = new_y

		return

	proc/stars_pan(magnitude,angle) // pan
		var/speed = actual_pan_speed(magnitude)
		var/apparent_angle = angle - ship_angle

		src.actual_x = speed*sin(apparent_angle) + actual_x
		src.actual_y = speed*cos(apparent_angle) + actual_y

		return

	proc/animate_stars()
		if(!src)
			return

		var/r_sqrd = (actual_y**2 + actual_x**2)
		if(r_sqrd > max_r_squared)
			SPAWN(animation_speed-1)
				var/apparent_angle = vel_angle - ship_angle
				var/theta = apparent_angle + (90*((rand()*2)-1))

				actual_x = max_r*sin(theta)
				actual_y = max_r*cos(theta)

				animate(src,flags=ANIMATION_END_NOW)
				var/matrix/N = GLOBAL_ANIMATION_MATRIX.Reset()
				N = N.Translate(actual_x, actual_y)
				src.transform = N
				src.set_state()
		else
			if(r_sqrd > src.max_visibility)
				if( src.alpha )
					src.alpha = 0
			else if(!src.alpha)
				animate(src, time = animation_speed, alpha = 255)
			var/matrix/M = GLOBAL_ANIMATION_MATRIX.Reset()
			M = M.Translate(actual_x, actual_y)
			animate(src, transform = M, time = animation_speed, loop = 0, flags = ANIMATION_PARALLEL)

/area/background_canvas
	name = "background_canvas"
	icon_state = "yellow"
	teleport_blocked = AREA_TELEPORT_AND_PORTER_BLOCKED
	expandable = 0
	requires_power = FALSE

/turf/background_canvas
	icon = 'icons/misc/background_stars.dmi'
	icon_state = "canvas"
	plane = PLANE_SPACE
	fullbright = 1
	mouse_opacity = 0

	New()
		..()

/obj/landmark/ship_marker
	name = "ship marker"
	var/ship_id = "artemis"
	var/num_stars = 200
	name_override = LANDMARK_SHIPS

	New()
		name = ship_id
		src.data = src.ship_id
		var/obj/background_star/S = null
		for(var/i=0,i<num_stars,i++)
			S = new/obj/background_star()
			S.plane = PLANE_SPACE
			S.loc = get_turf(src)
			S.ships_id =  src.ship_id
			S.galaxy_icon = image(S.icon, S, S.icon_state, S.layer)
			get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).add_image(S.galaxy_icon)
			if(ship_id=="artemis")
				S.duplicate_galaxy_icon = image(S.icon, S, S.icon_state, S.layer)
				S.duplicate_galaxy_icon.pixel_x += (57 * 32)
				get_image_group(CLIENT_IMAGE_GROUP_ARTEMIS_SHIP_ICONS).add_image(S.duplicate_galaxy_icon)
			S.icon = null
		..()

/obj/background_star/manta
	icon_state = "M-1"

	set_state()
		var/state = rand(1,4)
		icon_state = "M-[state]"
		if(galaxy_icon)
			galaxy_icon.icon_state = icon_state
		if(duplicate_galaxy_icon)
			duplicate_galaxy_icon.icon_state = icon_state

		if(state<7)
			parallax_multi = 2 + (0.5*((rand()*2)-1))

#endif
