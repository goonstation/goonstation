proc/explosion(atom/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	var/power = max(devastation_range+heavy_impact_range+0.25, 0.75)
	//boutput(world, "<span class='notice'>[devastation_range] [heavy_impact_range] [power]</span>")
	explosion_new(source, epicenter, (power*1.5)**2, max(light_impact_range/(power*1.5), 1))
	//boutput(world, "<span class='alert'>[power]</span>")

proc/explosion_new(atom/source, turf/epicenter, power, brisance=1, angle = 0, width = 360, turf_safe=FALSE)
	explosions.explode_at(source, epicenter, power, brisance, angle, width, turf_safe=turf_safe)
