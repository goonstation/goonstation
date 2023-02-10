/atom/movable
	var/pressure_resistance = 20
	var/last_forced_movement = 0

/atom/movable/proc/experience_pressure_difference(pressure_difference, direction)
	if(last_forced_movement >= air_master.current_cycle)
		return FALSE

	if(anchored)
		return FALSE

	if(pressure_difference > pressure_resistance)
		last_forced_movement = air_master.current_cycle
		SPAWN(0) //This callstack size tho
			step(src, direction) // ZEWAKA-ATMOS: HIGH PRESSURE DIFFERENTIAL HERE
	return TRUE
