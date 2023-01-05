#define PLANET_MAPBORDER 1

TYPEINFO(/datum/mapPrefab/planet)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/planet)
/datum/mapPrefab/planet
	var/std_prefab_path
	var/underwater
	var/list/required_biomes // ensure area has these biomes somewhere...

	applyTo(var/turf/target)
		var/adjustX = target.x
		var/adjustY = target.y

		 //Move prefabs backwards if they would end up outside the map.
		if((adjustX + prefabSizeX) > (world.maxx - PLANET_MAPBORDER))
			adjustX -= ((adjustX + prefabSizeX) - (world.maxx - PLANET_MAPBORDER))

		if((adjustY + prefabSizeY) > (world.maxy - PLANET_MAPBORDER))
			adjustY -= ((adjustY + prefabSizeY) - (world.maxy - PLANET_MAPBORDER))

		var/turf/T = locate(adjustX, adjustY, target.z)

		if(!check_biome_requirements(T))
			return

		for(var/x=0, x<prefabSizeX; x++)
			for(var/y=0, y<prefabSizeY; y++)
				var/turf/L = locate(T.x+x, T.y+y, T.z)

				var/area/map_gen/planet/P = get_area(L)
				if(L?.loc && !(istype(P) && P.allow_prefab))
					return
				if(T.density)
					return

		var/area_type = get_area(T)
		var/loaded = file2text(prefabPath)
		if(T && loaded)
			var/dmm_suite/D = new/dmm_suite()
			var/datum/loadedProperties/props = D.read_map(loaded, T.x, T.y, T.z, prefabPath, DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
			if(prefabSizeX != props.maxX - props.sourceX + 1 || prefabSizeY != props.maxY - props.sourceY + 1)
				CRASH("size of prefab [prefabPath] is incorrect ([prefabSizeX]x[prefabSizeY] != [props.maxX - props.sourceX + 1]x[props.maxY - props.sourceY + 1])")
			convertSpace(T, prefabSizeX, prefabSizeY, area_type)
			src.nPlaced++
			return props
		else return

	proc/check_biome_requirements(turf/T)
		. = TRUE
		var/area/map_gen/planet/A = get_area(T)
		if(length(required_biomes) && istype(A))
			for(var/biome in A.biome_turfs)
				if(!(biome in src.required_biomes))
					. = FALSE
					break

	proc/convertSpace(turf/start, prefabSizeX, prefabSizeY, area/prev_area)
		//var/list/areas_to_revert = list(/area/noGenerate, /area/allowGenerate)
		var/child_path = "[prev_area.type]/no_prefab"
		var/list/turf/turfs = block(locate(start.x, start.y, start.z), locate(start.x+prefabSizeX-1, start.y+prefabSizeY-1, start.z))
		for(var/turf/T in turfs)
			//if( T.loc.type in areas_to_revert)
			if(istype(T.loc, /area/noGenerate))
				new child_path(T)
			else if(istype(T.loc, /area/allowGenerate))
				new prev_area.type(T)


	tomb // small little tomb
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_tomb.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	vault
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_vault.dmm"
		prefabSizeX = 7
		prefabSizeY = 7

	bear_trap
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_planet_bear_den.dmm"
		prefabSizeX = 15
		prefabSizeY = 15

	tomato_den
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_planet_tomato_den.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	corn_n_weed
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/prefab_corn_and_weed.dmm"
		prefabSizeX = 15
		prefabSizeY = 16
		required_biomes = list(/datum/biome/mudlands)

	organic_organs
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/prefab_organic_organs.dmm"
		prefabSizeX = 15
		prefabSizeY = 15
		required_biomes = list(/datum/biome/mudlands)

	artifact
		prefabPath = "assets/maps/prefabs/prefab_planet_artifact_small.dmm"
		prefabSizeX = 3
		prefabSizeY = 3

	cargo_crate
		prefabPath = "assets/maps/prefabs/prefab_planet_lost_cargo.dmm"
		prefabSizeX = 3
		prefabSizeY = 3

	dead_nt
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_planet_dead_nt.dmm"
		prefabSizeX = 4
		prefabSizeY = 3

	dead_syndicate
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_planet_dead_synd.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	rogue_syndicate
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/prefab_planet_rogue_synd.dmm"
		prefabSizeX = 4
		prefabSizeY = 3

	monkeys
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/prefab_planet_monkeys.dmm"
		prefabSizeX = 5
		prefabSizeY = 4

	beer_cave
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_planet_beer_cave.dmm"
		prefabSizeX = 6
		prefabSizeY = 6

	birds
		maxNum = 2
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_planet_birds.dmm"
		prefabSizeX = 5
		prefabSizeY = 3

	angry_birds
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/prefab_planet_angry_birds.dmm"
		prefabSizeX = 8
		prefabSizeY = 6

#undef PLANET_MAPBORDER
