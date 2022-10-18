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
	if(last_airflow_movement > world.time - global.spacewind_control.movement_delay)
		return FALSE

	if(anchored)
		return FALSE

	if(airflow_speed)
		return FALSE

	if(pressure_difference > pressure_resistance)
		/*
		SPAWN(0) //This callstack size tho
			step(src, direction) // ZEWAKA-ATMOS: HIGH PRESSURE DIFFERENTIAL HERE
		*/
		SPAWN(0)
			global.spacewind_control?.Enqueue(src, pressure_difference, origin)

	return TRUE

/atom/movable/proc/PrepareAirflow(delta as num, turf/origin)
	. = TRUE

	if(src.anchored)
		return FALSE

	if (!origin || src.airflow_speed < 0 || src.last_airflow_movement > world.time - global.spacewind_control.movement_delay)
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
	src.set_density(TRUE)
	src.airflow_origin = origin
	src.airflow_direction = origin.pressure_direction
