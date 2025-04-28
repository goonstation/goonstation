/datum/antagonist/mob/space_phoenix
	id = ROLE_PHOENIX
	display_name = "space phoenix"
	mob_path = /mob/living/critter/space_phoenix
	mutually_exclusive = TRUE
	assigned_by = ANTAGONIST_SOURCE_RANDOM_EVENT
	success_medal = "Territorial Defender"
	/// How far from the map edge does our nest need to be
	var/map_edge_margin = 35
	/// The ability holder of this space phoenix
	var/datum/abilityHolder/space_phoenix/ability_holder

	give_equipment()
		. = ..()
		var/datum/abilityHolder/space_phoenix/abil_holder = src.owner.current.get_ability_holder(/datum/abilityHolder/space_phoenix)
		src.ability_holder = abil_holder || src.owner.current.add_ability_holder(/datum/abilityHolder/space_phoenix)

		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/sail)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/thermal_shock)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/ice_barrier)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/glacier)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/wind_chill)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/touch_of_death)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/permafrost)

		src.owner.current.setStatus("phoenix_mobs_collected", INFINITE_STATUS)

		get_image_group(CLIENT_IMAGE_GROUP_TEMPERATURE_OVERLAYS).add_mob(src.owner.current)

	remove_equipment()
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/sail)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/thermal_shock)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/ice_barrier)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/glacier)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/wind_chill)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/touch_of_death)
		src.ability_holder.addAbility(/datum/targetable/critter/space_phoenix/permafrost)

		src.owner.current.delStatus("phoenix_mobs_collected")

		get_image_group(CLIENT_IMAGE_GROUP_TEMPERATURE_OVERLAYS).remove_mob(src.owner.current)

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
		for (var/objective_type as anything in list(/datum/objective/specialist/phoenix_collect_humans, /datum/objective/specialist/phoenix_collect_critters, /datum/objective/specialist/phoenix_permafrost_areas))
			new objective_type(null, src.owner, src)
