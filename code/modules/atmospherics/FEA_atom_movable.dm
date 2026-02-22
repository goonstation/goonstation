/atom/movable
	var/pressure_resistance = 20
	var/last_forced_movement = 0

/// If the pressure delta is higher than our pressure resistance, move in the direction of the pressure differential as long as we are not anchored.
/// Returns: TRUE on successful movement. FALSE if aborted.
/atom/movable/proc/experience_pressure_difference(pressure_difference, direction)
	if(anchored || (last_forced_movement >= air_master.current_cycle))
		return FALSE

	if(pressure_difference > pressure_resistance)
		last_forced_movement = air_master.current_cycle
		SPAWN(0) //This callstack size tho
			step(src, direction) // ZEWAKA-ATMOS: HIGH PRESSURE DIFFERENTIAL HERE
	return TRUE
