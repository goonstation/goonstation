/// generic proc for creating flashes of hotspot fire
/// falloff is in units of degrees per tile
/proc/fireflash(atom/center, radius, temp = rand(2800, 3200), falloff = 0, checkLos = TRUE, chemfire = null)
	. = list()
	if (locate(/obj/blob/firewall) in center)
		return

	// calculate new radius if there's a falloff
	if (falloff > 0)
		if (temp < T0C + 60)
			return
		radius = min((temp - (T0C + 60)) / falloff, radius) // code note - someone comment this math if they know why the numbers are this way

	var/list/created_hotspots = list()
	var/list/affected_turfs = list()
	var/turf/center_turf = get_turf(center)
	var/area/current_area

	for (var/turf/T in range(radius, center_turf))
		if (!T || istype(T, /turf/space))
			continue
		current_area = get_area(T)
		if (current_area.sanctuary)
			continue

		// if check line of sight, ignore blocking turfs (in other words, fire spreads directionally from the source)
		// source turf always ignited though
		if (checkLos && T != center_turf)
			var/turf_burnable = TRUE
			for (var/turf/t_step in getline(center_turf, T))
				if (!t_step.gas_cross(t_step))
					turf_burnable = FALSE
					break
				var/obj/blob/blob = locate() in t_step
				if (istype(blob, /obj/blob/wall) || istype(blob, /obj/blob/firewall) || istype(blob, /obj/blob/reflective))
					turf_burnable = FALSE
					break
			if (!turf_burnable)
				continue

		// create hotspots
		var/obj/hotspot/hotspot = T.add_hotspot(temp - GET_DIST(center_turf, T) * falloff, 400, chemfire)
		T.hotspot_expose(temp - GET_DIST(center_turf, T) * falloff, 400)

		if (!QDELETED(hotspot))
			created_hotspots += hotspot
			affected_turfs += T

			T.burn_tile()

			// burn turf contents
			for (var/atom/A as anything in T)
				if (istype(A, /mob/living))
					var/mob/living/L = A
					L.update_burning(clamp((hotspot.temperature - 100) / 550, 0, 55))
					L.bodytemperature = max(L.bodytemperature, hotspot.temperature / 3)
				else if (istype(A, /obj/spacevine) || istype(A, /obj/kudzu_marker))
					qdel(A)

		LAGCHECK(LAG_REALTIME)

	// lighting fix (coder note - not sure what the problem is from before, just left it in)
	SPAWN(1 DECI SECOND)
		for (var/obj/hotspot/hotspot in created_hotspots)
			hotspot.set_real_color()

	// timed life on hotspots
	SPAWN(3 SECONDS)
		for (var/obj/hotspot/hotspot as anything in created_hotspots)
			if (!QDELETED(hotspot))
				qdel(hotspot)

		created_hotspots = null

	return affected_turfs

/// generic proc for hotspot fire flashes that also melt turf
/proc/fireflash_melting(atom/center, radius, temp, falloff = 0, checkLos = TRUE, chemfire = null, use_turf_melt_chance = TRUE, bypass_melt_RNG = FALSE)
	var/list/affected = fireflash(center, radius, temp, falloff, checkLos, chemfire)
	var/area/current_area
	var/hotspot_temp
	var/melting_point

	for (var/turf/simulated/T in affected)
		current_area = get_area(T)
		if (current_area.sanctuary)
			continue

		// determine melting temp of turf
		melting_point = 1643.15 // default for steel
		if (T?.material?.getProperty("flammable") > 4)
			melting_point = 505.93 / 2 // 451F (temp paper burns at, / 2 to undo the * 2 below)
			bypass_melt_RNG = TRUE

		if(length(T.active_hotspots))
			// chance to melt turf if hotspot is twice the turf melting point
			hotspot_temp = T.active_hotspots[1].temperature
			if (length(T.active_hotspots) > 1)
				hotspot_temp = max(hotspot_temp, T.active_hotspots[2].temperature)
			if (hotspot_temp >= melting_point * 2)
				var/melt_chance = hotspot_temp / melting_point
				if (use_turf_melt_chance)
					melt_chance = min(melt_chance, T.default_melt_chance)
				if (prob(melt_chance) || bypass_melt_RNG)
					T.burn_down()

		LAGCHECK(LAG_REALTIME)

	return affected
