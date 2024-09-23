TYPEINFO(/datum/mapPrefab/planet)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/planet)
/datum/mapPrefab/planet
	tags = PREFAB_PLANET
	var/list/datum/biome/required_biomes // ensure area has these biomes somewhere...

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
				if(L?.loc && !istype(P, /area/space) && !(istype(P) && P.allow_prefab))
					return
				if(L.density)
					return

		var/area_type = get_area(T)
		var/loaded = file2text(prefabPath)
		if(T && loaded)
			var/dmm_suite/D = new/dmm_suite("planet prefab [prefabPath]")
			var/datum/loadedProperties/props = D.read_map(loaded, T.x, T.y, T.z, prefabPath, DMM_OVERWRITE_MOBS | DMM_OVERWRITE_OBJS)
			if(prefabSizeX != props.maxX - props.sourceX + 1 || prefabSizeY != props.maxY - props.sourceY + 1)
				CRASH("size of prefab [prefabPath] is incorrect ([prefabSizeX]x[prefabSizeY] != [props.maxX - props.sourceX + 1]x[props.maxY - props.sourceY + 1])")
			convertSpace(T, prefabSizeX, prefabSizeY, area_type)
			src.nPlaced++
			return props
		else return

	proc/check_biome_requirements(turf/T)
		. = isnull(src.required_biomes)
		for(var/biome_type in src.required_biomes)
			var/datum/biome/B = biome_type
			var/turf_type = initial(B.turf_type)
			if(T.type == turf_type)
				. = TRUE
				break

	proc/convertSpace(turf/start, prefabSizeX, prefabSizeY, area/prev_area)
		//var/list/areas_to_revert = list(/area/noGenerate, /area/allowGenerate)
		var/child_path = "[prev_area.type]/no_prefab"
		if(istype(prev_area, /area/space))
			child_path = prev_area.type

		var/list/turf/turfs = block(locate(start.x, start.y, start.z), locate(start.x+prefabSizeX-1, start.y+prefabSizeY-1, start.z))
		for(var/turf/T in turfs)
			//if( T.loc.type in areas_to_revert)
			if(istype(T.loc, /area/noGenerate))
				var/area/map_gen/planet/planet_area = prev_area
				if(istype(planet_area) && planet_area.no_prefab_ref)
					planet_area.no_prefab_ref.contents += T
				else
					new child_path(T)
			else if(istype(T.loc, /area/allowGenerate))
				prev_area.contents += T
				//new prev_area.type(T)
			else if(prev_area.area_parallax_render_source_group)
				var/area/our_area = T.loc
				if(!our_area.area_parallax_render_source_group)
					our_area.area_parallax_render_source_group = prev_area.area_parallax_render_source_group
					our_area.occlude_foreground_parallax_layers = TRUE
				if (our_area.occlude_foreground_parallax_layers)
					T.update_parallax_occlusion_overlay()

	bear_trap
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_bear_den.dmm"
		prefabSizeX = 15
		prefabSizeY = 15
		required_biomes = list(/datum/biome/jungle)

	tomato_den
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_tomato_den.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	art_research
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_art_analysis.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	corn_n_weed
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_corn_and_weed.dmm"
		prefabSizeX = 15
		prefabSizeY = 16
		required_biomes = list(/datum/biome/mudlands)

	organic_organs
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_organic_organs.dmm"
		prefabSizeX = 15
		prefabSizeY = 15
		required_biomes = list(/datum/biome/mudlands)

	artifact
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_artifact_small.dmm"
		prefabSizeX = 3
		prefabSizeY = 3

	cargo_crate
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_lost_cargo.dmm"
		prefabSizeX = 3
		prefabSizeY = 3

	dead_nt
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_dead_nt.dmm"
		prefabSizeX = 4
		prefabSizeY = 3

	dead_crew
		maxNum = 4
		probability = 20
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_dead_crew.dmm"
		prefabSizeX = 4
		prefabSizeY = 3

	dead_syndicate
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_dead_synd.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	dead_syndicate2
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_dead_synd2.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	dead_martian
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_dead_martian.dmm"
		prefabSizeX = 3
		prefabSizeY = 3
		required_biomes = list(/datum/biome/mars, /datum/biome/desert)

	factory_syndicate_taken
		prefabPath = "assets/maps/prefabs/planet/prefab_syndicate_taken_factory.dmm"
		prefabSizeX = 20
		prefabSizeY = 20
		maxNum = 1
		probability = 15

	rogue_syndicate
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_rogue_synd.dmm"
		prefabSizeX = 4
		prefabSizeY = 3

	monkeys
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_monkeys.dmm"
		prefabSizeX = 5
		prefabSizeY = 4

	beer_cave
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_beer_cave.dmm"
		prefabSizeX = 6
		prefabSizeY = 6

	birds
		maxNum = 2
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_birds.dmm"
		prefabSizeX = 5
		prefabSizeY = 3

	angry_birds
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_angry_birds.dmm"
		prefabSizeX = 8
		prefabSizeY = 6

	martian_cave
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_martian_cave.dmm"
		prefabSizeX = 10
		prefabSizeY = 9

	martian_cave2
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_martian_cave2.dmm"
		prefabSizeX = 10
		prefabSizeY = 9
		required_biomes = list(/datum/biome/mars, /datum/biome/desert)

	illegal_still
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_illegal_still.dmm"
		prefabSizeX = 23
		prefabSizeY = 18

	random_ship1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_random_ship1.dmm"
		prefabSizeX = 6
		prefabSizeY = 6

	random_ship2
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_random_ship2.dmm"
		prefabSizeX = 8
		prefabSizeY = 8

	random_ship3
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_random_ship3.dmm"
		prefabSizeX = 7
		prefabSizeY = 7

	random_crap1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_random_crap1.dmm"
		prefabSizeX = 6
		prefabSizeY = 3

	random_crap2
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_random_crap2.dmm"
		prefabSizeX = 11
		prefabSizeY = 7

	random_crap3
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_random_crap3.dmm"
		prefabSizeX = 6
		prefabSizeY = 3

	crashedpod_gunbot
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_lostpod_gunbot.dmm"
		prefabSizeX = 3
		prefabSizeY = 3

	gold_cache_defended
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_gold_cache_defended.dmm"
		prefabSizeX = 9
		prefabSizeY = 9

	random_turret_south
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_random_turret_south.dmm"
		prefabSizeX = 7
		prefabSizeY = 6

	reliant_wreck
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_reliant_wreck.dmm"
		prefabSizeX = 33
		prefabSizeY = 26

	shack_trap
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_shack_trap.dmm"
		prefabSizeX = 7
		prefabSizeY = 10

	shack_junk
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_shack_junk.dmm"
		prefabSizeX = 7
		prefabSizeY = 10

	shack_gold
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_shack_gold.dmm"
		prefabSizeX = 7
		prefabSizeY = 10

	shack_gold_trap
		maxNum = 1
		probability = 5
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_shack_gold_trap.dmm"
		prefabSizeX = 7
		prefabSizeY = 10

	supply_outpost_defended
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_supply_outpost_defended.dmm"
		prefabSizeX = 16
		prefabSizeY = 15

	old_shack
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_old_shack.dmm"
		prefabSizeX = 10
		prefabSizeY = 11

	shipwreck_survivor1
		maxNum = 1
		probability = 15
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_shipwreck_survivor1.dmm"
		prefabSizeX = 19
		prefabSizeY = 18

	hidden_research_facility
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/planet/prefab_planet_hidden_research_facility.dmm"
		prefabSizeX = 23
		prefabSizeY = 32
