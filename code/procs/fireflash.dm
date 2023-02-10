/proc/fireflash(atom/center, radius, ignoreUnreachable)
	tfireflash(center, radius, rand(2800,3200), ignoreUnreachable)

/proc/tfireflash(atom/center, radius, temp, ignoreUnreachable)
	if (locate(/obj/blob/firewall) in center)
		return
	var/list/hotspots = new/list()
	for(var/turf/T in range(radius,get_turf(center)))
		if(istype(T, /turf/space) || T.loc:sanctuary) continue
		if(locate(/obj/hotspot) in T) continue
		if(!ignoreUnreachable && !can_line(get_turf(center), T, radius+1)) continue
		for(var/obj/spacevine/V in T) qdel(V)
		for(var/obj/kudzu_marker/M in T) qdel(M)
//		for(var/obj/alien/weeds/V in T) qdel(V)

		var/obj/hotspot/h = new /obj/hotspot
		h.temperature = temp
		h.volume = 400
		h.set_real_color()
		h.set_loc(T)
		T.active_hotspot = h
		hotspots += h

		T.hotspot_expose(h.temperature, h.volume)
/*// experimental thing to let temporary hotspots affect atmos
		h.perform_exposure()
*/
		//SPAWN(1.5 SECONDS) T.hotspot_expose(2000, 400)

		if(istype(T, /turf/simulated/floor)) T:burn_tile()
		SPAWN(0)
			for(var/mob/living/L in T)
				L.set_burning(33-radius)
				L.bodytemperature = max(temp/3, L.bodytemperature)
				LAGCHECK(LAG_REALTIME)
			for(var/obj/critter/C in T)
				if(istype(C, /obj/critter/zombie)) C.health -= 15
				C.health -= (30 * C.firevuln)
				C.check_health()
				SPAWN(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
					sleep(0.5 SECONDS)
					if(C)
						C.health -= (2 * C.firevuln)
						C.check_health()
				LAGCHECK(LAG_REALTIME)

	SPAWN(3 SECONDS)
		for (var/obj/hotspot/A as anything in hotspots)
			if (!A.disposed)
				qdel(A)
			//LAGCHECK(LAG_REALTIME)  //MBC : maybe caused lighting bug?
		hotspots.len = 0

/proc/fireflash_s(atom/center, radius, temp, falloff)
	if (locate(/obj/blob/firewall) in center)
		return list()
	if (temp < T0C + 60)
		return list()
	var/list/open = list()
	var/list/affected = list()
	var/list/closed = list()
	var/list/hotspots = list()
	var/turf/Ce = get_turf(center)
	var/max_dist = radius
	if (falloff)
		max_dist = min((temp - (T0C + 60)) / falloff, radius)
	open[Ce] = 0
	while (open.len)
		var/turf/T = open[1]
		var/dist = open[T]
		open -= T
		closed += T

		if (!T || istype(T, /turf/space) || T.loc:sanctuary)
			continue
		if (dist > max_dist)
			continue
		if (!ff_cansee(Ce, T))
			continue

		var/obj/hotspot/existing_hotspot = locate(/obj/hotspot) in T
		var/prev_temp = 0
		var/need_expose = 0
		var/expose_temp = 0
		if (!existing_hotspot)
			var/obj/hotspot/h = new /obj/hotspot
			need_expose = 1
			h.temperature = temp - dist * falloff
			expose_temp = h.temperature
			h.volume = 400
			h.set_loc(T)
			T.active_hotspot = h
			hotspots += h
			existing_hotspot = h
		else if (existing_hotspot.temperature < temp - dist * falloff)
			expose_temp = (temp - dist * falloff) - existing_hotspot.temperature
			prev_temp = existing_hotspot.temperature
			if (expose_temp > prev_temp * 3)
				need_expose = 1
			existing_hotspot.temperature = temp - dist * falloff

		affected[T] = existing_hotspot.temperature
		if (need_expose && expose_temp)
			T.hotspot_expose(expose_temp, existing_hotspot.volume)
/* // experimental thing to let temporary hotspots affect atmos
			existing_hotspot.perform_exposure()
*/
		if(istype(T, /turf/simulated/floor)) T:burn_tile()
		for (var/mob/living/L in T)
			L.update_burning(clamp(expose_temp - 100 / 550, 0, 55))
			L.bodytemperature = (2 * L.bodytemperature + temp) / 3
		SPAWN(0)
			for (var/obj/critter/C in T)
				if(C.z != T.z)
					continue
				C.health -= (30 * C.firevuln)
				C.check_health()
				LAGCHECK(LAG_REALTIME)

		if (T.density)
			continue
		for (var/obj/O in T)
			if (O.density)
				continue
		if (dist == max_dist)
			continue

		for (var/dir in cardinal)
			var/turf/link = get_step(T, dir)
			if (!link)
				continue
			var/dx = link.x - Ce.x
			var/dy = link.y - Ce.y
			var/target_dist = max((dist + 1 + sqrt(dx * dx + dy * dy)) / 2, dist)
			if (!(link in closed))
				if (link in open)
					if (open[link] > target_dist)
						open[link] = target_dist
				else
					open[link] = target_dist

		LAGCHECK(LAG_REALTIME)

	SPAWN(1 DECI SECOND) // dumb lighting hotfix
		for(var/obj/hotspot/A in hotspots)
			A.set_real_color() // enable light

	SPAWN(3 SECONDS)
		for(var/obj/hotspot/A in hotspots)
			if (!A.disposed)
				qdel(A)
			//LAGCHECK(LAG_REALTIME)  //MBC : maybe caused lighting bug?
		hotspots.len = 0

	return affected


/proc/fireflash_sm(atom/center, radius, temp, falloff, capped = 1, bypass_RNG = 0)
	var/list/affected = fireflash_s(center, radius, temp, falloff)
	for (var/turf/T in affected)
		if (istype(T, /turf/simulated) && !T.loc:sanctuary)
			var/mytemp = affected[T]
			var/melt = 1643.15 // default steel melting point
			if (T.material && T.material.getProperty("flammable") > 4) //wood walls?
				melt = 505.93 / 2 //451F (divided by 2 b/c it's multiplied by 2 below)
				bypass_RNG = 1
			var/divisor = melt
			if (mytemp >= melt * 2)
				var/chance = mytemp / divisor
				if (capped)
					chance = min(chance, T:default_melt_cap)
				if (prob(chance) || bypass_RNG) // The bypass is for thermite (Convair880).
					//T.visible_message("<span class='alert'>[T] melts!</span>")
					T.burn_down()
		LAGCHECK(LAG_REALTIME)

	return affected
