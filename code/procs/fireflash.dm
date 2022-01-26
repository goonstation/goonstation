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
		//SPAWN_DBG(1.5 SECONDS) T.hotspot_expose(2000, 400)

		if(istype(T, /turf/simulated/floor)) T:burn_tile()
		SPAWN_DBG(0)
			for(var/mob/living/L in T)
				L.set_burning(33-radius)
				L.bodytemperature = max(temp/3, L.bodytemperature)
				LAGCHECK(LAG_REALTIME)
			for(var/obj/critter/C in T)
				if(istype(C, /obj/critter/zombie)) C.health -= 15
				C.health -= (30 * C.firevuln)
				C.check_health()
				SPAWN_DBG(0.5 SECONDS)
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

	SPAWN_DBG(3 SECONDS)
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
		SPAWN_DBG(0)
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

	SPAWN_DBG(1 DECI SECOND) // dumb lighting hotfix
		for(var/obj/hotspot/A in hotspots)
			A.set_real_color() // enable light

	SPAWN_DBG(3 SECONDS)
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
			if (T.material && T.material.hasProperty("flammable") && ((T.material.material_flags & MATERIAL_METAL) || (T.material.material_flags & MATERIAL_CRYSTAL) || (T.material.material_flags & MATERIAL_RUBBER)))
				melt = melt + (((T.material.getProperty("flammable") - 50) * 15)*(-1)) //+- 750° ?
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

/* DYNAMIC FIREFLASH TODO:
add a sound like this is a real fireball
make this hurt stuff better
add blob logic to this
anything mbc suggest i steal from their fluidcode
perhaps reduce temperature as the fireball expands?
make expansion vary based on "pressure" - either real, or just based on how much its expanded recently
make it disappear slower initially, then faster as more disappears?
make it damage walls / windows / grilles / basically anything solid it cant expand into - scale with heat?
make it heat the air??? (idk tho :flooshed:)
maybe make the hotspot pool_after_delay proc less stinky?
maybe loop thru everything on the turf, and save significant things, instead of multiple locate calls?? (thz mbc)

ok so idea to fix some issues: add fireflash checking FIRST, before any other neighbor checking. THEN:
dont remove successfully hotspotted turfs from the candidates list (so now the list holds every affected hotspot turf). NOW:
this should mean that now itll update the fireflashes when someone opens a door, since thats still a potential spread candidate
*/

/proc/fireflash_dynamic(atom/center, volume, temp = rand(1500,2500))
	if (center)
		var/turf/origin = get_turf(center) //get the starting turf
		var/list/tiles_to_process = list(origin) //add the starting turf to our list
		volume--
		var/obj/hotspot/origin_hotspot = unpool(/obj/hotspot)
		origin_hotspot.temperature = temp
		origin_hotspot.volume = 400 //do some testing as to Why is this number???? ?????
		origin_hotspot.set_real_color()
		origin_hotspot.set_loc(origin)
		origin_hotspot.pool_after_delay(3.0 SECONDS)
		origin.active_hotspot = origin_hotspot
		origin.hotspot_expose(origin_hotspot.temperature, origin_hotspot.volume)

		for (var/atom/A in origin)
			A.temperature_expose(null, origin_hotspot.temperature, origin_hotspot.volume)
			if (isliving(A))
				var/mob/living/L = A
				L.update_burning(min(55, max(0, origin_hotspot.temperature - 100 / 550)))

		sleep(0.1 SECONDS) //we need to do this once originally
		while (volume)
			//var/new_hotspots_made = 0 //will probably be used later, for temp variation or speed/pressure calculations. idk
			var/list/found_neighbors = list() //populated with valid tiles for the next iteration of the loop
			for (var/turf/current_tile in tiles_to_process)
				for (var/check_dir in cardinal) //check all neighbors of the tile
					var/turf/candidate_tile = get_step(current_tile, check_dir)
					// if you want to have something here not allow fireflashes to go through it, add it below
					if (candidate_tile.density) //if its a wall, exclude it
						continue
					if (locate(/obj/hotspot) in candidate_tile) //if theres a fireflash already there, stop
						continue

					//check for a windoor on the current tile
					var/obj/machinery/door/door_1 = locate(/obj/machinery/door) in current_tile
					if (istype(door_1, /obj/machinery/door/airlock/pyro/glass/windoor) || istype(door_1, /obj/machinery/door/window))
						var/dir_between_tiles = get_dir(current_tile, candidate_tile) //get the dir relating the 2 tiles. if its the same as the windoor direction, itll block the spread of the fireflash
						if (door_1.dir == dir_between_tiles && door_1.density)
							continue

					//check for a window on the current tile
					var/obj/window/window_1 = locate(/obj/window) in candidate_tile //find if theres a window on the current tile
					if (window_1)
						var/dir_between_tiles = get_dir(current_tile, candidate_tile)
						if (window_1.dir == dir_between_tiles)
							continue

					//check for a door on the next tile
					var/obj/machinery/door/door_2 = locate(/obj/machinery/door) in candidate_tile //find if theres a door on the candidate tile
					if (door_2)
						if (istype(door_2, /obj/machinery/door/airlock/pyro/glass/windoor) || istype(door_2, /obj/machinery/door/window)) //we need special logic for windoors
							var/dir_between_tiles = dir2angle(get_dir(current_tile, candidate_tile)) //get the angle between the 2 tiles
							var/dir_windoor_blocks = angle2dir(dir_between_tiles + 180) //if the angle between 2 tiles is 90, then the windoor facing the opposite direction of that will block the firespread
							if (door_2.dir == dir_windoor_blocks && door_2.density)
								continue
						if (door_2.density) //if the door is closed, dont move onto it
							continue

					//check for a window on the next tile
					var/obj/window/window_2 = locate(/obj/window) in candidate_tile //find if theres a window on the candidate tile
					if (window_2)
						if (window_2.dir == 5) //dir 5 means fulltile window
							continue
						var/dir_between_tiles = dir2angle(get_dir(current_tile, candidate_tile)) //get the angle between the 2 tiles
						var/dir_window_blocks = angle2dir(dir_between_tiles + 180) //if the angle between 2 tiles is 90, then the window facing the opposite direction of that will block the firespread
						if (window_2.dir == dir_window_blocks)
							continue

					else
						if (volume > 0) //check if have enough volume to make a new fireflash
							volume--
							//new_hotspots_made++
							var/obj/hotspot/new_hotspot = unpool(/obj/hotspot)
							new_hotspot.temperature = temp
							new_hotspot.volume = 400 //do some testing as to Why is this number???? ?????
							new_hotspot.set_real_color()
							new_hotspot.set_loc(candidate_tile)
							new_hotspot.pool_after_delay(3.0 SECONDS) //how long the hotspot sits around before dissipating
							candidate_tile.active_hotspot = new_hotspot
							candidate_tile.hotspot_expose(new_hotspot.temperature, new_hotspot.volume)
							found_neighbors.Add(candidate_tile) // add it to the found neighbors list

							for (var/atom/affected in candidate_tile)
								LAGCHECK(LAG_REALTIME)
								affected.temperature_expose(null, new_hotspot.temperature, new_hotspot.volume)
								if (isliving(affected))
									var/mob/living/affected_mob = affected
									affected_mob.update_burning(min(55, max(0, new_hotspot.temperature - 100 / 550)))

						else
							break

			tiles_to_process = found_neighbors // reset tiles_to_process, and repeat this whole thing over again
			var/delay = 0.1 SECONDS
			sleep(delay) //delay between this wave and the next wave - gives it a sense of fluidity

//debug testing purposes only
/obj/item/space_thing/fire_thing
	name = "fire thing"

	attack_self(var/mob/M)
		var/size = input(M, "total tiles this should cover?", "bigness menu", 0) as num
		fireflash_dynamic(M, size)
