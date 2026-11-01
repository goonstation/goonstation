proc/explosion(atom/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, turf_safe = FALSE, range_cutoff_fraction=1, flash_radiation_multiplier = 0)
	var/power = max(devastation_range+heavy_impact_range+0.25, 0.75)
	//boutput(world, SPAN_NOTICE("[devastation_range] [heavy_impact_range] [power]"))
	explosion_new(source, epicenter, (power*1.5)**2, max(light_impact_range/(power*1.5), 1), turf_safe = turf_safe, range_cutoff_fraction=range_cutoff_fraction, flash_radiation_multiplier=flash_radiation_multiplier)
	//boutput(world, SPAN_ALERT("[power]"))

proc/explosion_new(atom/source, turf/epicenter, power, brisance=1, angle = 0, width = 360, turf_safe=FALSE, range_cutoff_fraction=1, flash_radiation_multiplier = 0)
	explosions.explode_at(source, epicenter, power, brisance, angle, width, turf_safe=turf_safe, range_cutoff_fraction=range_cutoff_fraction, flash_radiation_multiplier=flash_radiation_multiplier)
