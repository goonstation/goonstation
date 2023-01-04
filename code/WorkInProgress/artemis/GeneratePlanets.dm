/area/map_gen/planet
	name = "planet generation area"
	var/list/turf/biome_turfs = list()
	var/list/datum/loadedProperties/prefabs = list()
	var/allow_prefab = TRUE
	var/generated = FALSE

	no_prefab
		allow_prefab = FALSE


/datum/planetManager
	var/list/datum/allocated_region/regions = list()

var/global/datum/planetManager/PLANET_LOCATIONS = new /datum/planetManager()

/proc/GeneratePlanetChunk(width=null, height=null, prefabs_to_place=1, datum/map_generator/generator=/datum/map_generator/desert_generator, color=null, name=null, use_lrt=TRUE, mapgen_flags=null)
	var/turf/T

	if(ispath(generator)) generator = new generator()
	if(!width)	width = rand(80,130)
	if(!height)	height = rand(80,130)
	if(!name)
		name = ""
		if (prob(50))
			name += pick_string("station_name.txt", "greek")
		else
			name += pick_string("station_name.txt", "militaryLetters")
		name += " "

		if (prob(30))
			name += pick_string("station_name.txt", "romanNum")
		else
			name += "[rand(2, 99)]"

	//Generate and cleanup region
	var/datum/allocated_region/region = global.region_allocator.allocate(width, height)
	region.clean_up(main_area=/area/map_gen/planet)

	//Populate with Biome!
	var/turfs = block(locate(region.bottom_left.x+1, region.bottom_left.y+1, region.bottom_left.z), locate(region.bottom_left.x+region.width-2, region.bottom_left.y+region.height-2, region.bottom_left.z) )
	generator.generate_terrain(turfs, reuse_seed=TRUE, flags=mapgen_flags)

	//Force Outer Edge to be Cordon Area
	var/area/border_area = new /area/cordon(null)
	for(var/x in 1 to region.width)
		for(var/y in 1 to region.height)
			if(x == 1 || y == 1 || x == region.width || y == region.height)
				T = region.turf_at(x, y)
				border_area.contents += T

			if (current_state >= GAME_STATE_PLAYING)
				LAGCHECK(LAG_LOW)
			else
				LAGCHECK(LAG_HIGH)

	//Lighten' Up the Place
	var/image/ambient_light = new /image/ambient
	if(!color)
		ambient_light.color = "#888888"
	else
		ambient_light.color = color

	for(T in turfs)
		T.UpdateOverlays(ambient_light, "ambient")
		LAGCHECK(LAG_LOW)

	PLANET_LOCATIONS.regions.Add(region)

	//Make it interesting, slap some prefabs on that thing
	for (var/n = 1, n <= prefabs_to_place, n++)
		var/datum/mapPrefab/planet/P = pick_map_prefab(/datum/mapPrefab/planet)
		if (P)
			var/maxX = (region.bottom_left.x + region.width - P.prefabSizeX - AST_MAPBORDER)
			var/maxY = (region.bottom_left.y + region.height - P.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (P.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(region.bottom_left.x+AST_MAPBORDER, maxX), rand(region.bottom_left.y+AST_MAPBORDER,maxY), region.bottom_left.z)
				if(!P.check_biome_requirements(target))
					count = INFINITY
					break

				var/datum/loadedProperties/ret = P.applyTo(target)
				if (ret)
					var/space_turfs = block(locate(ret.sourceX, ret.sourceY, ret.sourceZ), locate(ret.maxX, ret.maxY, ret.maxZ))
					for(T in space_turfs)
						if(!istype(T, /turf/space))
							space_turfs -= T
					generator.generate_terrain(space_turfs, reuse_seed=TRUE)
					for(T in space_turfs)
						T.UpdateOverlays(ambient_light, "ambient")
						LAGCHECK(LAG_LOW)

					logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type][P.required?" (REQUIRED)":""] succeeded. [target] @ [log_loc(target)]")
					stop = 1
				else
					logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type] failed due to blocked area. [target] @ [log_loc(target)]")
				count++
			if (count == maxTries)
				logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type] failed due to maximum tries [maxTries][P.required?" WARNING: REQUIRED FAILED":""].")
		else break

	//Allow folks to like uh, get here?
	if(use_lrt)
		var/lrt_placed = FALSE
		var/maxTries = 80
		while(!lrt_placed)
			if(!maxTries)
				message_admins("Planet region failed to place LRT coordinates!!!")
				break

			T = pick(turfs)
			if(T.density)
				maxTries--
				continue

			new /obj/landmark/lrt/planet(T, name)
			new /obj/decal/teleport_mark(T)
			lrt_placed = TRUE
			special_places.Add(name)

	logTheThing(LOG_ADMIN, usr, "Planet region generated at [log_loc(region.bottom_left)] with [generator].")
	logTheThing(LOG_DIARY, usr, "Planet region generated at [log_loc(region.bottom_left)] with [generator].", "admin")
	message_admins("Planet region generated at [log_loc(region.bottom_left)] with [generator].")

	return turfs

/obj/landmark/lrt/planet //for use with long range teleporter locations, please add new subtypes of this for new locations and use those
	name_override = LANDMARK_LRT

	New(newLoc, name)
		src.name = name // store name
		..()

obj/decal/teleport_mark
	icon = 'icons/misc/artemis/temps.dmi'
	icon_state = "decal_tele"
	name = "teleport mark"
	anchored = 1
	layer = FLOOR_EQUIP_LAYER1
	alpha = 180

	New(var/atom/location)
		..()
		for(var/obj/O in location)
			if(O == src) continue
			if(istype(O, /obj/decal/teleport_mark) || istype(O,/obj/machinery/lrteleporter) || istype(O,/obj/decal/fakeobjects/teleport_pad) )
				qdel(src)
				return
