/atom/movable
	var/pressure_resistance = 20

	///The most recent cycle of spacewind this movable was moved at.
	VAR_FINAL/last_airflow_movement = 0
	///The density of the object prior to airflow beginning its process
	VAR_FINAL/pre_airflow_density = null
	///The "speed" this object is travelling during airflow
	VAR_FINAL/airflow_speed = 0
	///The delay between each airflow process, typically based on speed.
	VAR_FINAL/airflow_process_delay = 0
	///The source turf of the pressure experience
	VAR_FINAL/turf/airflow_origin
	///The amount of ticks an object has been in airflow
	VAR_FINAL/airflow_time = 0
	///Some magic bullshit relating to spacewind movement.
	VAR_FINAL/airflow_skip_speedcheck = null
	///The direction the pressure hit us in
	VAR_FINAL/airflow_direction = 0

/atom/movable/proc/experience_pressure_difference(pressure_difference, direction, turf/origin)
	if(last_airflow_movement > world.time - AIRFLOW_MOVE_DELAY)
		return FALSE

	if(anchored)
		return FALSE

	if(airflow_speed)
		return FALSE

	if(pressure_difference > pressure_resistance)
		SPAWN(0)
			AirflowMove(pressure_difference, origin)

	return TRUE

/atom/movable/proc/AirflowMove(delta, turf/origin)
	set waitfor = FALSE

	if(!PrepareAirflow(delta, origin))
		return

	while(src.airflow_speed > 0)
		if(QDELETED(src))
			break
		if(!isturf(src.loc))
			break

		LAGCHECK(LAG_MED)

		src.airflow_speed = min(src.airflow_speed, AIRFLOW_SPEED_MIN)
		src.airflow_speed -= AIRFLOW_SPEED_DECAY

		if(src.airflow_speed > AIRFLOW_SPEED_SKIP_CHECK)
			if(src.airflow_time++ >= src.airflow_speed - AIRFLOW_SPEED_SKIP_CHECK)
				sleep(1)
		else
			sleep(max(1, 10 - (src.airflow_speed + 3)))

		if(src.pre_airflow_density == 0)
			src.set_density(TRUE)

		boutput(world, "[src.name] moving by airflow at ([src.x], [src.y], [src.z])")
		var/olddir = src.dir

		var/dirfromoriginasangle = dir2angle(get_dir(src.airflow_origin, src))
		var/airflow_angle = dir2angle(src.airflow_direction)
		var/angle = max(dirfromoriginasangle, airflow_angle) - min(dirfromoriginasangle, airflow_angle)


		if(src.loc == src.airflow_origin)
			step(src, src.airflow_direction)
		else
			switch(angle)
				if(0 to 45)
					step_away(src, src.airflow_origin)
				if(46 to 90)
					step(src, src.airflow_direction)
				if(91 to 360)
					step_towards(src, src.airflow_origin)

		src.set_dir(old_dir)
		boutput(world, "[src.name] moved by airflow at ([src.x], [src.y], [src.z])")

	src.set_density(pre_airflow_density)
	src.pre_airflow_density = null
	src.airflow_speed = 0
	src.airflow_origin = null
	src.airflow_skip_speedcheck = null
	src.airflow_time = 0
	src.airflow_direction = 0

/atom/movable/proc/PrepareAirflow(delta as num, turf/origin)
	. = TRUE

	if(src.anchored)
		return FALSE

	if (!origin || src.airflow_speed < 0 || src.last_airflow_movement > world.time - AIRFLOW_MOVE_DELAY)
		return FALSE

	if (src.airflow_speed)
		src.airflow_speed = delta / max(get_dist(src, origin), 1)
		return FALSE

	///A movement occurs here, but it doesn't mean the mob will be queued to the airflow loop.
	if (origin == loc)
		step(src, origin.pressure_direction)

	if(ismob(src))
		boutput(src, "<span class='notice'>You are pushed away by a rush of air!</span>")

	src.last_airflow_movement = world.time

	//Get the distance from the flow origin to create some feeling of natural falloff
	var/airflow_falloff = 9 - get_dist(src, origin)
	if (airflow_falloff < 1)
		return FALSE

	///At this point, we're locked into an airflow movement.
	src.airflow_speed = min(max(delta * (9 / airflow_falloff), 1), 9)
	src.pre_airflow_density = src.density
	src.airflow_origin = origin
	src.airflow_direction = origin.pressure_direction
