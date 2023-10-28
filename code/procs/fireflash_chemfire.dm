/proc/chemfireflash(atom/center, radius, volume, temp, duration, color = null, ignoreUnreachable = FALSE)
	if (locate(/obj/blob/firewall) in center.loc)
		return
	for (var/turf/T in range(radius, get_turf(center)))
		if (!ignoreUnreachable)
			if (T.density)
				continue
			if (!can_line(get_turf(center), T, radius + 1))
				continue
		new /obj/chem_fire(T, volume, temp, duration, color)
