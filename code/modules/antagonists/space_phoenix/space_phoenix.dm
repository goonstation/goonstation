/datum/antagonist/mob/ice_phoenix
	id = ROLE_PHOENIX
	display_name = "space phoenix"
	mob_path = /mob/living/critter/ice_phoenix
	mutually_exclusive = TRUE
	assigned_by = ANTAGONIST_SOURCE_RANDOM_EVENT
	objectives = list(/datum/objective/specialist/phoenix_collect_humans, /datum/objective/specialist/phoenix_collect_critters, /datum/objective/specialist/phoenix_permafrost_areas)
	success_medal = "Territorial Defender"
	var/map_edge_margin = 35

	relocate()
		..()
		var/list/turf/spawn_region
		var/region = rand(1, 4)
		switch(region)
			if (1)
				spawn_region = block(map_edge_margin, map_edge_margin, Z_LEVEL_STATION, world.maxx, map_edge_margin, Z_LEVEL_STATION)
			if (2)
				spawn_region = block(world.maxx - map_edge_margin, map_edge_margin, Z_LEVEL_STATION, world.maxx - map_edge_margin, 300, Z_LEVEL_STATION)
			if (3)
				spawn_region = block(map_edge_margin, world.maxy - map_edge_margin, Z_LEVEL_STATION, world.maxx, world.maxy, Z_LEVEL_STATION)
			if (4)
				spawn_region = block(map_edge_margin, map_edge_margin, Z_LEVEL_STATION, map_edge_margin, world.maxy, Z_LEVEL_STATION)

		var/turf/T
		var/turf_found
		for (var/i = 1 to 50)
			T = pick(spawn_region)
			turf_found = TRUE
			for (var/turf/nearby in block(T.x - 4, T.y - 4, T.z, T.x + 4, T.y + 4, T.z))
				if (!istype(nearby, /turf/space))
					turf_found = FALSE
					break
			if (turf_found)
				break
		src.owner.current.set_loc(null) // while map load loads nest
		var/dmm_suite/map_loader = new
		map_loader.read_map(file2text("assets/maps/allocated/phoenix_nest.dmm"), T.x - 4, T.y - 4, T.z)
		src.owner.current.set_loc(T)

	assign_objectives()
		for (var/datum/objective/specialist/objective as anything in src.objectives)
			new objective(null, src.owner, src)
