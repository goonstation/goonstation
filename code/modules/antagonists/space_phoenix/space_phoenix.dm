/datum/antagonist/mob/ice_phoenix
	id = ROLE_PHOENIX
	display_name = "space phoenix"
	mob_path = /mob/living/critter/ice_phoenix
	mutually_exclusive = TRUE
	assigned_by = ANTAGONIST_SOURCE_RANDOM_EVENT
	has_info_popup = FALSE
	var/map_edge_margin = 35

	relocate()
		..()
		var/list/turf/spawn_region
		var/region = pick(1, 4)
		switch(region)
			if (1)
				spawn_region = block(1, 1, Z_LEVEL_STATION, world.maxx, map_edge_margin, Z_LEVEL_STATION)
			if (2)
				spawn_region = block(world.maxx - map_edge_margin, 1, Z_LEVEL_STATION, world.maxx - map_edge_margin, 300, Z_LEVEL_STATION)
			if (3)
				spawn_region = block(1, world.maxy - map_edge_margin, Z_LEVEL_STATION, world.maxx, world.maxy, Z_LEVEL_STATION)
			if (4)
				spawn_region = block(1, 1, Z_LEVEL_STATION, map_edge_margin, world.maxy, Z_LEVEL_STATION)

		var/turf/T
		for (var/i = 1 to 50)
			T = pick(spawn_region)
			for (var/turf/nearby in block(T.x - 2, T.y - 2, T.z, T.x + 2, T.y + 2, T.z))
				if (!istype(nearby, /turf/space))
					continue
			break
		src.owner.current.set_loc(T)
