#define TERRAINIFY_VEHICLE_FABS (1 << 0)
#define TERRAINIFY_VEHICLE_CARS (1 << 1)
#define TERRAINIFY_ALLOW_VEHCILES (1 << 2)

var/global/is_map_on_ground_terrain = FALSE

/client/proc/cmd_terrainify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Terrainify"
	set desc = "Turns space into a terrain type"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if(holder)
		var/datum/terrainify_editor/E = new /datum/terrainify_editor(src.mob)
		E.ui_interact(mob)


var/datum/station_zlevel_repair/station_repair = new
/datum/station_zlevel_repair
	var/datum/map_generator/station_generator
	var/image/ambient_light
	var/obj/ambient/ambient_obj
	var/image/weather_img
	var/obj/effects/weather_effect
	var/overlay_delay
	var/datum/gas_mixture/default_air
	var/allows_vehicles = FALSE
	var/list/turf/preconvert_turfs = list()

	New()
		..()
		default_air = new
		default_air.oxygen = MOLES_O2STANDARD
		default_air.nitrogen = MOLES_N2STANDARD
		default_air.temperature = T20C

	proc/repair_turfs(turf/turfs, clear=FALSE, force_floor=FALSE)
		if(src.station_generator)
			var/gen_flags = MAPGEN_IGNORE_FLORA | MAPGEN_IGNORE_FAUNA
			gen_flags |= MAPGEN_ALLOW_VEHICLES * src.allows_vehicles
			gen_flags |= MAPGEN_FLOOR_ONLY * force_floor
			src.station_generator.generate_terrain(turfs, reuse_seed=TRUE, flags=gen_flags)

			if(clear)
				clear_out_turfs(turfs, ignore_contents=TRUE)

		SPAWN(overlay_delay)
			for(var/turf/T as anything in turfs)
				if(src.ambient_light)
					T.AddOverlays(src.ambient_light, "ambient")
				if(src.ambient_obj)
					T.vis_contents |= src.ambient_obj
				if(src.weather_img)
					if(islist(src.weather_img))
						T.AddOverlays(pick(src.weather_img), "weather")
					else
						T.AddOverlays(src.weather_img, "weather")
				if(src.weather_effect)
					var/obj/effects/E = locate(src.weather_effect) in T
					if(!E)
						new src.weather_effect(T)
				T.ClearSpecificOverlays("foreground_parallax_occlusion_overlay")

	proc/fix_atmos_dependence()
		for(var/turf/chamber_turf in get_area_turfs(/area/station/engine/combustion_chamber))
			if(locate(/obj/machinery/door/poddoor) in chamber_turf)
				chamber_turf.ReplaceWith(/turf/unsimulated/floor/engine/vacuum)

		for(var/turf/toxins_turf in get_area_turfs(/area/station/science/lab))
			if(locate(/obj/machinery/door/poddoor) in toxins_turf)
				toxins_turf.ReplaceWith(/turf/unsimulated/floor/engine/vacuum)

		var/turf/turf
		for(var/obj/machinery/atmospherics/unary/vent/V in by_cat[TR_CAT_ATMOS_MACHINES])
			if(V.z == Z_LEVEL_STATION && istype(get_area(V), /area/space))
				turf = get_turf(V)
				turf.ReplaceWith(/turf/unsimulated/floor/engine/vacuum)

		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/HE in by_cat[TR_CAT_ATMOS_MACHINES])
			if(HE.z == Z_LEVEL_STATION && istype(get_area(HE), /area/space))
				turf = get_turf(HE)
				turf.ReplaceWith(/turf/unsimulated/floor/engine/vacuum)



	proc/clean_up_station_level(replace_with_cars, add_sub, remove_parallax = TRUE, season=null)
		var/list/turfs_to_fix = get_turfs_to_fix()
		clear_out_turfs(turfs_to_fix)
		clear_out_turfs(get_beacon_turfs(), by_type[/obj/warp_beacon])

		land_vehicle_fixup(replace_with_cars, add_sub)
		copy_gas_to_airless()
		fix_atmos_dependence()

		set_station_season(season)

		if (remove_parallax)
			REMOVE_ALL_PARALLAX_RENDER_SOURCES_FROM_GROUP(Z_LEVEL_STATION)


	proc/set_station_season(season)
		switch(season)
			if("Winter")
#ifndef SEASON_WINTER
				for(var/turf/simulated/floor/grass/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
					T.ReplaceWith(/turf/simulated/floor/snow/snowball, keep_old_material=FALSE, handle_air = FALSE)

				for_by_tcl(V, /obj/machinery/vending)
					if(V.z != Z_LEVEL_STATION)
						continue

					if(istype(V,/obj/machinery/vending/jobclothing/research))
						V.product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/sci, 2)
					else if(istype(V,/obj/machinery/vending/jobclothing/engineering))
						V.product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hi_vis/puffer, 2)
						V.product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/engi, 2)
					else if(istype(V,/obj/machinery/vending/jobclothing/medical))
						V.product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/med, 2)
						V.product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/genetics, 2)
						V.product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/nurse, 2)
					else if(istype(V,/obj/machinery/vending/jobclothing/security))
						V.product_list += new/datum/data/vending_product(/obj/item/clothing/suit/puffer/sec, 2)
#endif
			if("Autumn")
#ifndef SEASON_AUTUMN
				for(var/turf/simulated/floor/grass/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
					T.try_set_icon_state(T.icon_state + "_autumn", T.icon)
					if(istype(T, /turf/simulated/floor/auto/grass/leafy))
						var/turf/simulated/floor/auto/grass/leafy/edgy_turf = T
						edgy_turf.icon_state_edge = "leafy_edge_autumn"

				for(var/turf/simulated/floor/grasstodirt/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
					T.try_set_icon_state("autumntodirt", T.icon)

				for_by_tcl(S, /obj/shrub)
					if(S.z != Z_LEVEL_STATION)
						continue
					S.try_set_icon_state(S.icon_state + "_autumn", S.icon)
#endif

	proc/get_turfs_to_fix()
		. = list()
		. += get_mass_driver_turfs()
		. += shippingmarket.get_path_to_market()
		. += get_ptl_beams()

	proc/land_vehicle_fixup(replace_with_cars, add_sub)
		if(replace_with_cars)
			for_by_tcl(V, /obj/machinery/vehicle)
				if(V.z == Z_LEVEL_STATION)
					if(istype(V, /obj/machinery/vehicle/pod_smooth/light) || istype(V, /obj/machinery/vehicle/miniputt))
						if(prob(50))
							new /obj/machinery/vehicle/tank/car(get_turf(V))
							qdel(V)

		if(add_sub)
			for_by_tcl(man, /obj/machinery/manufacturer)
				if(istype(man, /obj/machinery/manufacturer/hangar) && (man.z == Z_LEVEL_STATION))
					man.add_schematic(/datum/manufacture/sub/wheels)

	proc/get_beacon_turfs()
		var/list/turfs_to_fix = list()
		for(var/obj/warp_beacon/W in by_type[/obj/warp_beacon])
			for(var/turf/T in range(5, W))
				turfs_to_fix |= T
		return turfs_to_fix

	proc/get_ptl_beams()
		. = list()
		for(var/obj/machinery/power/pt_laser/P in machine_registry[MACHINES_POWER])
			if(P.z == Z_LEVEL_STATION)
				var/atom/start = P.get_barrel_turf()
				var/atom/end = get_edge_target_turf(start, P.dir)

				for(var/turf/T in block(start, end))
					if(istype(get_area(T), /area/space))
						. |= T

	proc/get_mass_driver_turfs()
		. = list()
		for(var/obj/machinery/mass_driver/M as anything in machine_registry[MACHINES_MASSDRIVERS])
			if(M.z == Z_LEVEL_STATION)
				var/atom/start = get_turf(M)
				var/atom/end = get_ranged_target_turf(M, M.dir, M.drive_range)
				. |= block(start, end)

	proc/clear_out_turfs(list/turf/to_clear, list/ignore_list, ignore_contents=FALSE)
		for(var/turf/T as anything in to_clear)
			//Wacks asteroids and skip normal turfs that belong
			if(istype(T, /turf/simulated/wall/auto/asteroid))
				var/turf/simulated/wall/auto/asteroid/AST = T
				AST.destroy_asteroid(dropOre=FALSE)
			else if(!istype(T, /turf/unsimulated))
				continue

			//Uh, make sure we don't block the shipping lanes!
			if(!ignore_contents)
				for(var/atom/A in T)
					if(ismob(A) || iscritter(A)) // Lets not just KILL people... ha hahah HA
						continue
					if(A.density)
						if(A in ignore_list)
							continue
						qdel(A)

			if(station_repair.allows_vehicles)
				T.allows_vehicles = station_repair.allows_vehicles

			LAGCHECK(LAG_MED)

	proc/copy_gas_to_airless()
		var/list/zlevel_station_turfs = block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION))
		. = list()
		for(var/turf/T in zlevel_station_turfs)
			if(istype(T, /turf/simulated/floor/airless) || istype(T, /turf/simulated/floor/plating/airless))
				. |= T
		for(var/turf/simulated/ST in .)
			var/datum/gas_mixture/TG = ST.return_air()
			TG.copy_from(src.default_air)
			ST.update_nearby_tiles(need_rebuild=TRUE)
			LAGCHECK(LAG_MED)

/atom/movable/screen/parallax_render_source/foreground/embers/atmosphere_entry
	color = list(
		1, 0, 0, -0.1,
		0, 1, 0, -0.1,
		0, 0, 1, -0.1,
		0, 0, 0, 1,
		0, 0, 0, 0)

/atom/movable/screen/parallax_render_source/foreground/snow/atmosphere_entry

ABSTRACT_TYPE(/datum/terrainify)
/datum/terrainify
	var/name
	var/desc
	var/additional_options = list()
	var/additional_toggles = list()
	var/static/datum/terrainify/terrainify_lock
	var/parallax_render_source_group = null
	var/road_turf_type = /turf/unsimulated/floor/auto/dirt
	var/allow_underwater = FALSE
	var/syndi_camo_color = null
	var/ambient_color
	var/startTime
	var/generates_solid_ground = TRUE

	New()
		..()
		if(length(syndi_camo_color))
			additional_toggles["Syndi Camo"] = FALSE
		if(parallax_render_source_group)
			additional_toggles["Parallax"] = FALSE

	proc/special_repair(list/turf/TS)
		return FALSE

	proc/log_terrainify(mob/user, text)
		if(src.startTime)
			text += "Took [(world.timeofday - src.startTime)/10] seconds."
		logTheThing(LOG_ADMIN, user, "[text]")
		logTheThing(LOG_DIARY, user, "[text]", "admin")
		message_admins("[key_name(user)] [text]")

	proc/get_default_params()
		. = list()
		for(var/toggle in src.additional_toggles)
			.[toggle] = src.additional_toggles[toggle] | FALSE
		for(var/option in src.additional_options)
			.[option] = src.additional_options[option][1]
		.["vehicle"] = TERRAINIFY_ALLOW_VEHCILES

	proc/perform_terrainify(params, mob/user)
		USR_ADMIN_ONLY

#ifdef UNDERWATER_MAP
		if(!allow_underwater)
			//to prevent tremendous lag from the entire map flooding from a single ocean tile.
			boutput(usr, "You cannot use this command on underwater maps. Sorry!")
			return FALSE
#endif
		if(terrainify_lock)
			boutput(user, "Terrainify has already begone!")
		else
			terrainify_lock = src
			pre_convert(params, user)
			convert_station_level(params, user)
			post_convert(params, user)
			src.terrainify_lock = null

	proc/pre_convert(params, mob/user)
		log_terrainify(user, "started Terrainify: [name]")
		src.startTime = world.timeofday

		if(src.ambient_color)
			if(params["Ambient Light Obj"])
				station_repair.ambient_obj = station_repair.ambient_obj || new /obj/ambient
				station_repair.ambient_obj.color = src.ambient_color
			else
				station_repair.ambient_light = new /image/ambient
				station_repair.ambient_light.color = src.ambient_color

		for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
			station_repair.preconvert_turfs += S

		if(current_state >= GAME_STATE_PLAYING && params["Re-Entry"])
			REMOVE_ALL_PARALLAX_RENDER_SOURCES_FROM_GROUP(Z_LEVEL_STATION)
			var/list/parallax_layers = list(/atom/movable/screen/parallax_render_source/foreground/embers/atmosphere_entry, /atom/movable/screen/parallax_render_source/foreground/snow/atmosphere_entry)
			ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, parallax_layers, 2 SECONDS)

			for (var/client/C in clients)
				var/mob/player_mob = C.mob
				if(istype(player_mob) && player_mob.z == Z_LEVEL_STATION)
					SPAWN(0)
						shake_camera(player_mob, 35 SECONDS, rand(20,40))
					player_mob.changeStatus("knockdown", 2 SECONDS)

	proc/post_convert(params, mob/user)
		if(current_state >= GAME_STATE_PREGAME)
			initialize_worldgen()

		if(current_state >= GAME_STATE_PLAYING && params["Re-Entry"])
			for (var/client/C in clients)
				var/mob/player_mob = C.mob
				if(istype(player_mob) && player_mob.z == Z_LEVEL_STATION)
					SPAWN(0)
						shake_camera(player_mob, 4 SECONDS, rand(55,85))
					player_mob.changeStatus("knockdown", 5 SECONDS)

			REMOVE_PARALLAX_RENDER_SOURCE_FROM_GROUP(Z_LEVEL_STATION, list(/atom/movable/screen/parallax_render_source/foreground/embers/atmosphere_entry, /atom/movable/screen/parallax_render_source/foreground/snow/atmosphere_entry), 10 SECONDS)

		if(params["Parallax"])
			var/datum/parallax_render_source_group/render_group = new parallax_render_source_group()
			ADD_PARALLAX_RENDER_SOURCES_FROM_GROUP(Z_LEVEL_STATION, render_group, 5 SECONDS)

		if (src.generates_solid_ground)
			global.is_map_on_ground_terrain = TRUE

		log_terrainify(user, "has turned space and the station into [src.name].")


	proc/convert_station_level(params, mob/user)
		USR_ADMIN_ONLY
		if(!check_param(params, "vehicle"))
			return

		// Validate options
		for(var/toggle in additional_toggles)
			if(!check_param(params, toggle))
				return

		for(var/option in additional_options)
			if(!check_param(params, option))
				return
			else
				if(!(params[option] in additional_options[option]))
					boutput(user, "[params[option]] is not a valid option for [option] for [name]! Call 1-800-CODER!")
					return

		station_repair.allows_vehicles = (params["vehicle"] & TERRAINIFY_ALLOW_VEHCILES) == TERRAINIFY_ALLOW_VEHCILES

		if(params["Syndi Camo"] && length(syndi_camo_color))
			nuke_op_camo_matrix = syndi_camo_color

			var/color_matrix = color_mapping_matrix(nuke_op_color_matrix, nuke_op_camo_matrix)
			for (var/atom/A as anything in by_cat[TR_CAT_NUKE_OP_STYLE])
				A.color = color_matrix
		. = TRUE

	proc/check_param(params, key)
		if(isnull(params[key]))
			boutput(usr, "Key [key] not provided to [name] terrainify! Call 1-800-CODER!")
		else
			. = TRUE

	proc/handle_mining(params, list/turfs)
		var/mining = params["Mining"]
		mining = (mining == "None") ? null : mining
		if(mining)
			var/list/turf/valid_spots = list()
			for(var/turf/simulated/wall/auto/asteroid/AST in turfs)
				valid_spots |= AST
			if(length(valid_spots))
				if(mining == "Rich")
					var/ore_seeds = clamp( length(turfs)/80/4, 30, 50)
					generate_mining(valid_spots, ore=ore_seeds, veins=rand(2,8), rarity=rand(5,80))
				else
					generate_mining(valid_spots)

	proc/generate_mining(list/turfs, ore=30, veins, rarity)
		if(isnull(veins))
			veins = rand(1,3)
		if(isnull(rarity))
			rarity = rand(0,40)

		for(var/i in 1 to ore)
			var/turf/target_center = pick(turfs)
			var/list/turf/ast_list = list()
			for(var/turf/simulated/wall/auto/asteroid/AST in range(target_center, "[rand(3,9)]x[rand(3,9)]"))
				ast_list |= AST
			Turfspawn_Asteroid_SeedOre(ast_list, veins=rand(1,3), rarity_mod=rand(5,25), fullbright=FALSE)

		for(var/i=0, i<ore, i++)
			Turfspawn_Asteroid_SeedOre(turfs, veins=veins, rarity_mod=rarity, fullbright=FALSE)

		for(var/i in 1 to ore/2)
			Turfspawn_Asteroid_SeedEvents(turfs)

	proc/place_prefabs(prefabs_to_place, flags, params)
		var/failsafe = 800
		for (var/n = 1, n <= prefabs_to_place && failsafe-- > 0)
			var/datum/mapPrefab/planet/P = pick_map_prefab(/datum/mapPrefab/planet, wanted_tags_any=PREFAB_PLANET)
			if (P)
				var/maxX = (world.maxx - AST_MAPBORDER)
				var/maxY = (world.maxy - AST_MAPBORDER)
				var/stop = 0
				var/count= 0
				var/maxTries = (P.required ? 200 : 80)
				while (!stop && count < maxTries && failsafe-- > 0) //Kinda brute forcing it. Dumb but whatever.
					var/turf/target = locate(rand(AST_MAPBORDER, maxX), rand(AST_MAPBORDER, maxY), Z_LEVEL_STATION)
					if(!P.check_biome_requirements(target))
						count++
						continue
					if(istype(target.loc, /area/station))
						count++
						continue

					var/datum/loadedProperties/ret = P.applyTo(target)
					if (ret)
						var/space_turfs = block(locate(ret.sourceX, ret.sourceY, ret.sourceZ), locate(ret.maxX, ret.maxY, ret.maxZ))
						for(var/turf/T in space_turfs)
							if(!istype(T, /turf/space))
								space_turfs -= T
						station_repair.repair_turfs(space_turfs, force_floor=TRUE)
						LAZYLISTADD(params["prefabs_loaded"], ret)
						logTheThing(LOG_DEBUG, null, "Prefab Z1 placement #[n] [P.type][P.required?" (REQUIRED)":""] succeeded. [target] @ [log_loc(target)]")
						n++
						stop = 1
					else
						logTheThing(LOG_DEBUG, null, "Prefab Z1 placement #[n] [P.type] failed due to blocked area. [target] @ [log_loc(target)]")
					count++
				if (count == maxTries)
					logTheThing(LOG_DEBUG, null, "Prefab Z1 placement #[n] [P.type] failed due to maximum tries [maxTries][P.required?" WARNING: REQUIRED FAILED":""].")
			else break

	proc/convert_turfs(list/turfs, params)
		station_repair.station_generator.generate_terrain(turfs, flags=MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles)

		for(var/turf/T as anything in turfs)
			if(station_repair.ambient_light)
				T.AddOverlays(station_repair.ambient_light, "ambient")
			if(station_repair.ambient_obj)
				T.vis_contents |= station_repair.ambient_obj
			if(station_repair.weather_img)
				if(islist(station_repair.weather_img))
					T.AddOverlays(pick(station_repair.weather_img), "weather")
				else
					T.AddOverlays(station_repair.weather_img, "weather")
			if(station_repair.weather_effect)
				var/obj/effects/E = locate(station_repair.weather_effect) in T
				if(!E)
					new station_repair.weather_effect(T)
			T.ClearSpecificOverlays("foreground_parallax_occlusion_overlay")

		LAZYLISTINIT(params["prefabs_loaded"])
		if(params["Prefabs"])
			place_prefabs(10, params=params)

		if(params["Roads"])
			build_roads(turfs, params)

		station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS, season=params["Season"])

		handle_mining(params, turfs)

	proc/build_roads(list/turfs, params)
		var/datum/cell_grid/cell_grid = new(world.maxx,world.maxy)
		var/road_noise = rustg_cnoise_generate("60", "10", "5", "2", "[world.maxx]", "[world.maxy]")

		var/last_x = rand(5,250)
		var/last_y = rand(5,250)
		for(var/i in 1 to 12-length(params["prefabs_loaded"]))
			var/next_x = rand(5,250)
			var/next_y = rand(5,250)
			if(prob(50))
				cell_grid.drawLShape(last_x, last_y, next_x, next_y, TRUE, TRUE, TRUE)
			else
				cell_grid.draw_line(last_x, last_y, next_x, next_y, TRUE, TRUE, TRUE)
			last_x = next_x
			last_y = next_y

		for(var/datum/loadedProperties/prefab in params["prefabs_loaded"])
			if(prob((prefab.maxX-prefab.sourceX)*(prefab.maxY-prefab.sourceY))*5)
				if(prob(20))
					var/next_x = rand(5,250)
					var/next_y = rand(5,250)
					if(prob(50))
						cell_grid.drawLShape(last_x, last_y, next_x, next_y, TRUE, TRUE, TRUE)
					else
						cell_grid.draw_line(last_x, last_y, next_x, next_y, TRUE, TRUE, TRUE)
					last_x = next_x
					last_y = next_y

				if(prob(80))
					cell_grid.drawLShape(last_x, last_y, prefab.sourceX, prefab.sourceY, TRUE, TRUE)
				else
					cell_grid.draw_line(last_x, last_y, prefab.sourceX, prefab.sourceY, TRUE, TRUE)
				last_x = prefab.maxX
				last_y = prefab.maxY

		for(var/datum/loadedProperties/prefab in params["prefabs_loaded"])
			cell_grid.draw_box(prefab.sourceX, prefab.sourceY,   prefab.maxX, prefab.maxY, null, null, TRUE)

		for(var/x in 1 to world.maxx)
			for(var/y in 1 to world.maxy)
				if(cell_grid.grid[x][y])
					var/road_value
					var/index = x * world.maxx + y
					if(index <= length(road_noise))
						road_value = text2num(road_noise[index])
					if(road_value)
						var/turf/new_road = locate(x, y, Z_LEVEL_STATION)
						if(!istype(new_road, /turf/simulated/wall/auto/asteroid) && (new_road in turfs))
							new_road.ReplaceWith(road_turf_type, keep_old_material=FALSE, handle_dir=FALSE)
							new_road.can_build = TRUE


/datum/terrainify/desertify
	name = "Desert Station"
	desc = "Turn space into into a nice desert full of sand and stones."
	additional_options = list("Mining"=list("None","Normal","Rich"))
	additional_toggles = list("Ambient Light Obj"=TRUE, "Prefabs"=FALSE, "Roads"=FALSE, "Re-Entry"=FALSE)
	ambient_color = "#cfcfcf"
	parallax_render_source_group = /datum/parallax_render_source_group/planet/desert

	New()
		syndi_camo_color = list(nuke_op_color_matrix[1], "#efc998", nuke_op_color_matrix[3])
		..()

	convert_station_level(params, mob/user)
		if(..())
			station_repair.station_generator = new/datum/map_generator/desert_generator
			station_repair.default_air.temperature = 330

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space, params)

			log_terrainify(user, "turned space into a desert.")

/datum/terrainify/caveify
	name = "Underground Station"
	desc = "Turns space into a cave system"
	additional_options = list("Mining"=list("None","Normal","Rich"), "Bioluminescent Algae Coverage"=list("None", "Normal", "Heavy", "Extreme", "All"))
	additional_toggles = list("Ambient Light Obj"=TRUE, "Prefabs"=FALSE, "Asteroid"=FALSE, "Re-Entry"=FALSE)
	ambient_color = "#222222"

	New()
		..()

	convert_station_level(params, mob/user)
		if(..())

			if(params["Asteroid"])
				station_repair.station_generator = new/datum/map_generator/cave_generator/asteroid
			else
				station_repair.station_generator = new/datum/map_generator/cave_generator

			var/algae_coverage = 0
			switch(params["Bioluminescent Algae Coverage"])
				if ("Normal")
					algae_coverage = 0.25
				if ("Heavy")
					algae_coverage = 0.5
				if ("Extreme")
					algae_coverage = 0.75
				if ("All")
					algae_coverage = 1
			if (algae_coverage)
				SPAWN(1 MINUTE) // bad hack
					for (var/turf/simulated/wall/auto/asteroid/wall in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
						if (wall.icon_state == "asteroid-255")
							continue
						if (wall.ore)
							continue // Skip if there's ore here already
						algae_controller().algae_wall(wall)
						LAGCHECK(LAG_LOW)

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space, params)

			log_terrainify(user, "turned space into a caves.")

/datum/terrainify/asteroid_field
	name = "Asteroid Field"
	desc = "Turns space into region filled with asteroids and debris."
	additional_options = list()
	additional_toggles = list()
	ambient_color = "#222222"
	generates_solid_ground = FALSE

	New()
		..()

	convert_station_level(params, mob/user)
		if(..())
			var/area_restriction = /area/space
			//var/regions = rustg_worley_generate("32", "10", "50", "300", "1", "8")
			var/regions = rustg_cnoise_generate("33", "15", "3", "4", "300", "300")
			var/datum/cell_grid/cell_grid = new(world.maxx,world.maxy)
			cell_grid.draw_from_string(regions, TRUE, FALSE, override=TRUE)
			var/groups = cell_grid.find_contigious_cells()
			for(var/group_id in groups)
				var/group = groups[group_id]
				if(length(group) > 5)
					var/list/turf/generated_turfs
					var/node = pick(group)
					var/turf/center = locate(node[1], node[2], Z_LEVEL_STATION)
					if(prob(3))
						Turfspawn_Wreckage(center, area_restriction=area_restriction)
					else
						var/size = max(2, round(sqrt(length(group))) + rand(-1+2))
						var/rand_num = rand(1,3)
						switch(rand_num)
							if (1)
								generated_turfs = Turfspawn_Asteroid_DegradeFromCenter(center, /turf/simulated/wall/auto/asteroid, size, 10, area_restriction)
							if (2)
								var/list/turfs_near_center = list()
								for(var/turf/space/S in orange(4,center))
									turfs_near_center += S

								if (length(turfs_near_center) > 0) //Wire note: Fix for pick() from empty list
									var/chunks = rand(2,6)
									while(chunks > 0)
										chunks--
										generated_turfs = generated_turfs + Turfspawn_Asteroid_Round(pick(turfs_near_center), /turf/simulated/wall/auto/asteroid, rand(2,4), 0, area_restriction)
							else
								generated_turfs = Turfspawn_Asteroid_Round(center, /turf/simulated/wall/auto/asteroid, size, 0, area_restriction)

						for (var/turf/simulated/wall/auto/asteroid/AST in generated_turfs)
							AST.space_overlays()

						for (var/turf/simulated/floor/plating/airless/asteroid/AST in generated_turfs)
							AST.UpdateIcon()
						Turfspawn_Asteroid_SeedOre(generated_turfs, rand(1,3), rand(0,5))
						Turfspawn_Asteroid_SeedEvents(Turfspawn_Asteroid_CheckForModifiableTurfs(generated_turfs), rand(0,9))
					LAGCHECK(LAG_MED)

			station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS, remove_parallax=FALSE, season=params["Season"])

			log_terrainify(user, "turned space into a debris field.")

/datum/terrainify/void
	name = "Void Station"
	desc = "Turn space into the unknowable void? Space if filled with the void, inhibited by those departed, and chunks of scaffolding."
	additional_toggles = list("Void Bubbles"=FALSE, "Void Worley"=FALSE)
	generates_solid_ground = FALSE

	New()
		syndi_camo_color = list(nuke_op_color_matrix[1], "#a223d2", nuke_op_color_matrix[3])
		..()

	convert_station_level(params, mob/user)
		if(..())
			generate_void(params=params)

			station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS, FALSE)

			log_terrainify(user, "turned space into an THE VOID.")

/proc/generate_void(all_z_levels = FALSE, params = null)
	station_repair.ambient_light = new /image/ambient
	station_repair.ambient_light.color = rgb(6.9, 4.20, 6.9)
	station_repair.station_generator = new/datum/map_generator/void_generator

	var/blacklist_generators = list(/datum/map_generator/icemoon_generator,
									/datum/map_generator/mars_generator,
									/datum/map_generator/void_generator,
									/datum/map_generator/asteroids,
									/datum/map_generator/sea_caves,
									/datum/map_generator/storehouse_generator,
									/datum/map_generator/room_maze_generator,
									/datum/map_generator/room_maze_generator/random,
									/datum/map_generator/room_maze_generator/spatial)

	var/list/space = list()
	for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		space += S
	if (all_z_levels)
		for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_DEBRIS), locate(world.maxx, world.maxy, Z_LEVEL_DEBRIS)))
			space += S
		for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_MINING), locate(world.maxx, world.maxy, Z_LEVEL_MINING)))
			space += S

	station_repair.station_generator.generate_terrain(space, flags = MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles)
	for (var/turf/S in space)
		S.AddOverlays(station_repair.ambient_light, "ambient")

	var/list/turf/turfs_to_clear = station_repair.get_turfs_to_fix()
	turfs_to_clear += station_repair.get_beacon_turfs()

	if(params && params["Void Worley"])
		var/worley_bubbles = rustg_worley_generate("32", "10", "50", "300", "1", "8")
		var/datum/cell_grid/cell_grid = new(world.maxx,world.maxy)
		cell_grid.draw_from_string(worley_bubbles, TRUE, FALSE, override=TRUE)
		for(var/turf/T in turfs_to_clear)
			cell_grid.grid[T.x][T.y] = null

		var/groups = cell_grid.find_contigious_cells()

		for(var/group_id in groups)
			var/group = groups[group_id]
			if(length(group) > 20)
				var/list/turfs_to_convert = list()
				var/list/edges_to_convert = list()
				for(var/node in group)
					var/turf/T = locate(node[1], node[2], Z_LEVEL_STATION)
					var/edge = cell_grid.has_empty_neighbor(node[1],node[2],diagonals=TRUE)
					if(istype(T, /turf/unsimulated/floor/void))
						if(edge)
							edges_to_convert += T
						else
							turfs_to_convert += T

				if(length(turfs_to_convert) > 50)
					var/datum/map_generator/generator = pick(childrentypesof(/datum/map_generator)-blacklist_generators)
					generator = new generator()
					generator.generate_terrain(turfs_to_convert, reuse_seed=TRUE, flags=MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles)

					//Place Prefab or just Terrain
					if((length(turfs_to_convert) > 100) && prob(85))
						if(length(turfs_to_clear & turfs_to_convert) == 0)
							var/count= 0
							var/datum/mapPrefab/planet/P = pick_map_prefab(/datum/mapPrefab/planet, wanted_tags_any=PREFAB_PLANET)
							var/maxTries = (P.required ? 35 : 20)
							while (count < maxTries) //Kinda brute forcing it. Dumb but whatever.
								var/turf/target = pick(turfs_to_convert)
								if(istype(target.loc, /area/station))
									count = maxTries
									continue

								var/datum/loadedProperties/ret = P.applyTo(target)
								if (ret)
									var/space_turfs = block(locate(ret.sourceX, ret.sourceY, ret.sourceZ), locate(ret.maxX, ret.maxY, ret.maxZ))
									for(var/turf/T in space_turfs)
										if(!istype(T, /turf/space))
											space_turfs -= T
									generator.generate_terrain(space_turfs, reuse_seed=TRUE, flags=MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles)
									logTheThing(LOG_DEBUG, null, "Void Worley placement [P.type][P.required?" (REQUIRED)":""] succeeded. [target] @ [log_loc(target)]")
									break
								else
									count++

					for(var/turf/edge_turf in edges_to_convert )
						edge_turf.ReplaceWith(/turf/unsimulated/floor/auto/void, keep_old_material=FALSE, handle_dir=FALSE)
						edge_turf.allows_vehicles = MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles
						edge_turf.can_build = TRUE
						var/turf/unsimulated/floor/auto/AT = edge_turf
						if(istype(AT))
							AT.edge_overlays()

					logTheThing(LOG_DEBUG, null, "Void Worley Bubble: [generator] [log_loc(pick(turfs_to_convert), Z_LEVEL_STATION)]")



	if(params && params["Void Bubbles"])
		var/datum/bsp_tree/tree = new(width=world.maxx, height=world.maxy, min_width=30, min_height=25)
		var/edge_noise = rustg_cnoise_generate("60", "5", "6", "3", "[world.maxx]", "[world.maxy]")
		var/bubble_count = rand(8, 15)
		var/list/bubble_nodes = list()
		var/datum/bsp_node/room
		var/list/bubble_edges = list()
		for(var/x in 1 to bubble_count)
			var/list/bubble_turfs = list()
			if(length(tree.leaves))
				room = pick(tree.leaves)
			else
				break

			tree.leaves -= room
			for(var/datum/bsp_node/leaf in bubble_nodes)
				if(tree.are_nodes_adjacent(room, leaf))
					room = null
					break
			if(!room)
				continue

			var/list/branch = tree.get_leaves(room.parent.parent)
			tree.leaves -= branch

			var/datum/map_generator/generator = pick(childrentypesof(/datum/map_generator)-blacklist_generators)
			generator = new generator()

			//Place Prefab or just Terrain
			if(prob(85))
				var/count= 0
				var/datum/mapPrefab/planet/P = pick_map_prefab(/datum/mapPrefab/planet, wanted_tags_any=PREFAB_PLANET)
				var/maxTries = (P.required ? 5 : 2)

				if(length(turfs_to_clear & block(locate(room.x, room.y, Z_LEVEL_STATION), locate(room.x + room.width-1, room.y + room.height-1, Z_LEVEL_STATION))) == 0)
					while (count < maxTries) //Kinda brute forcing it. Dumb but whatever.
						var/turf/target = locate(rand(room.x+room.width/3, room.x+room.width-room.width/3), rand(room.y+room.height/3, room.y+room.height-room.height/3), Z_LEVEL_STATION)
						if(istype(target.loc, /area/station))
							count = maxTries
							continue

						var/datum/loadedProperties/ret = P.applyTo(target)
						if (ret)
							var/space_turfs = block(locate(ret.sourceX, ret.sourceY, ret.sourceZ), locate(ret.maxX, ret.maxY, ret.maxZ))
							for(var/turf/T in space_turfs)
								if(!istype(T, /turf/space))
									space_turfs -= T
							generator.generate_terrain(space_turfs, reuse_seed=TRUE, flags=MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles)
							logTheThing(LOG_DEBUG, null, "Void Bubble placement [P.type][P.required?" (REQUIRED)":""] succeeded. [target] @ [log_loc(target)]")
							break
						else
							count++


			for(var/turf/unsimulated/floor/void/V in block(locate(room.x, room.y, Z_LEVEL_STATION), locate(room.x + room.width-1, room.y + room.height-1, Z_LEVEL_STATION)))
				bubble_turfs += V

			bubble_turfs -= turfs_to_clear

			if(length(bubble_turfs) > 50)
				// Rough up the edges so it is less blocky
				var/edge_turfs = list()
				var/edge_size = 4
				edge_turfs += block(locate(room.x,                          room.y, 						  Z_LEVEL_STATION), locate(room.x + edge_size, 				room.y + room.height-1, Z_LEVEL_STATION))
				edge_turfs += block(locate(room.x + edge_size,              room.y,                           Z_LEVEL_STATION), locate(room.x + room.width-edge_size, 	room.y + edge_size,     Z_LEVEL_STATION))
				edge_turfs += block(locate(room.x + room.width - edge_size, room.y,                           Z_LEVEL_STATION), locate(room.x + room.width-1, 			room.y + room.height-1, Z_LEVEL_STATION))
				edge_turfs += block(locate(room.x + edge_size,              room.y + room.height - edge_size, Z_LEVEL_STATION), locate(room.x + room.width-edge_size, 	room.y + room.height-1, Z_LEVEL_STATION))

				for(var/turf/BT in edge_turfs)
					if(istype(BT, /turf/unsimulated/floor/void))
						var/bubble_value
						var/index = BT.x * world.maxx + BT.y
						if(index <= length(edge_noise))
							bubble_value = text2num(edge_noise[index])
						var/on_edge = (BT.x == room.x)  			    \
								   || (BT.x == (room.x + room.width-1)) \
								   || (BT.y == room.y)                  \
								   || (BT.y == (room.y + room.height-1))
						if(!bubble_value || on_edge)
							bubble_turfs -= BT
							bubble_edges += BT
							BT.ReplaceWith(/turf/unsimulated/floor/auto/void, keep_old_material=FALSE, handle_dir=FALSE)
							BT.can_build = TRUE
							BT.allows_vehicles = MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles

				generator.generate_terrain(bubble_turfs, reuse_seed=TRUE, flags=MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles)
				bubble_nodes += room

			logTheThing(LOG_DEBUG, null, "Void Bubble: [generator] [log_loc(locate(room.x, room.y, Z_LEVEL_STATION))]")

		SPAWN(10 SECONDS)
			for(var/turf/unsimulated/floor/auto/void/BE in bubble_edges)
				BE.edge_overlays()



	station_repair.clean_up_station_level()

	var/list/void_parallax_layers = list(
		/atom/movable/screen/parallax_render_source/void,
		/atom/movable/screen/parallax_render_source/void/clouds_1,
		/atom/movable/screen/parallax_render_source/void/clouds_2,
		)


	ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, void_parallax_layers, 0 SECONDS)
	if (all_z_levels)
		ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_DEBRIS, void_parallax_layers, 0 SECONDS)
		ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_MINING, void_parallax_layers, 0 SECONDS)

/datum/terrainify/ice_moon
	name = "Ice Moon Station"
	desc = "Turns space into the Outpost Theta... CO2 + Ice. Ice Spiders, Seal Pups, Brullbar, and the occasional Yeti."
	additional_options = list("Snowing"=list("Yes","No","Particles"), "Mining"=list("None","Normal","Rich"))
	additional_toggles = list("Pitch Black"=FALSE)
	ambient_color = "#222222"

	convert_station_level(params, mob/user)
		if(..())
			var/ambient_value
			var/snow = params["Snowing"]
			snow = (snow == "No") ? null : snow
			if(snow)
				if(snow == "Yes")
					station_repair.weather_img = image(icon = 'icons/turf/areas.dmi', icon_state = "snowverlay", layer = EFFECTS_LAYER_BASE)
					station_repair.weather_img.alpha = 200
					station_repair.weather_img.plane = PLANE_NOSHADOW_ABOVE
				else
					station_repair.weather_effect = /obj/effects/precipitation/snow/grey/tile

			station_repair.default_air.carbon_dioxide = 100
			station_repair.default_air.nitrogen = 0
			station_repair.default_air.oxygen = 0
			station_repair.default_air.temperature = 100

			if(params["Pitch Black"])
				station_repair.ambient_light = null

			station_repair.station_generator = new/datum/map_generator/icemoon_generator

			// Path to market does not need to be cleared because it was converted to ice.  Abyss will screw up everything!
			var/list/turf/traveling_crate_turfs = station_repair.get_turfs_to_fix()
			traveling_crate_turfs += station_repair.get_beacon_turfs()
			for(var/turf/space/T in traveling_crate_turfs)
				T.ReplaceWith(/turf/unsimulated/floor/arctic/snow/ice)
				if(station_repair.allows_vehicles)
					T.allows_vehicles = station_repair.allows_vehicles
				if(station_repair.ambient_light)
					ambient_value = lerp(10,50,min(1-T.x/300,0.8))
					station_repair.ambient_light.color = rgb(ambient_value,ambient_value+((rand()*1)),ambient_value+((rand()*1))) //randomly shift green&blue to reduce vertical banding
					T.AddOverlays(station_repair.ambient_light, "ambient")
			station_repair.land_vehicle_fixup(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space, params)
			for (var/turf/S in space)
				if(station_repair.ambient_light)
					ambient_value = lerp(10,50,min(1-S.x/300,0.8))
					station_repair.ambient_light.color = rgb(ambient_value,ambient_value+((rand()*1)),ambient_value+((rand()*1))) //randomly shift green&blue to reduce vertical banding
					S.AddOverlays(station_repair.ambient_light, "ambient")

			REMOVE_ALL_PARALLAX_RENDER_SOURCES_FROM_GROUP(Z_LEVEL_STATION)

			log_terrainify(user, "turned space into an another outpost on Theta.")

/datum/terrainify/lava_moon
	name = "Lava Moon Station"
	desc = "Turns space into... CO2 + Lava."
	additional_options = list("Mining"=list("None","Normal","Rich"), "Lava"=list("Normal","Extra","Less"))
	parallax_render_source_group = /datum/parallax_render_source_group/planet/lava_moon

	convert_station_level(params, mob/user)
		if(..())
			station_repair.default_air.carbon_dioxide = 20
			station_repair.default_air.nitrogen = 0
			station_repair.default_air.oxygen = 0
			station_repair.default_air.temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1

			station_repair.station_generator = new/datum/map_generator/lavamoon_generator
			var/datum/map_generator/lavamoon_generator/LG = station_repair.station_generator
			switch(params["Lava"])
				if("Extra")
					LG.lava_percent = 45
				if("Less")
					LG.lava_percent = 25

			var/list/turf/traveling_crate_turfs = station_repair.get_turfs_to_fix()
			traveling_crate_turfs += station_repair.get_beacon_turfs()
			for(var/turf/space/T in traveling_crate_turfs)
				T.ReplaceWith(/turf/unsimulated/floor/auto/iomoon)
				if(station_repair.allows_vehicles)
					T.allows_vehicles = station_repair.allows_vehicles

			station_repair.land_vehicle_fixup(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space, params)

			REMOVE_ALL_PARALLAX_RENDER_SOURCES_FROM_GROUP(Z_LEVEL_STATION)
			var/list/parallax_layers = list(/atom/movable/screen/parallax_render_source/foreground/embers)
			ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, parallax_layers, 0 SECONDS)

			log_terrainify(user, "turned space into an another outpost on Io.")


/datum/terrainify/swampify
	name = "Swamp Station"
	desc = "Turns space into a swamp"
	additional_options = list("Rain"=list("No", "Yes", "Particles"), "Mining"=list("None","Normal","Rich"))
	additional_toggles = list("Ambient Light Obj"=TRUE, "Prefabs"=FALSE, "Roads"=FALSE, "Re-Entry"=FALSE)
	ambient_color = "#222222"

	New()
		syndi_camo_color = list(nuke_op_color_matrix[1], "#6f7026", nuke_op_color_matrix[3])
		..()

	convert_station_level(params, mob/user)
		if(..())
			var/rain = params["Rain"]
			rain = (rain == "No") ? null : rain

			station_repair.station_generator = new/datum/map_generator/jungle_generator

			if(rain == "Yes")
				//station_repair.weather_img = image('icons/turf/water.dmi',"fast_rain", layer = EFFECTS_LAYER_BASE)
				station_repair.weather_img = list()
				for(var/idx in 1 to 4)
					station_repair.weather_img += image('icons/effects/64x64.dmi',"rain_[idx]", layer = EFFECTS_LAYER_BASE)
					station_repair.weather_img[idx].alpha
					station_repair.weather_img[idx].alpha = 200
					station_repair.weather_img[idx].plane = PLANE_NOSHADOW_ABOVE
			else if(rain)
				station_repair.weather_effect = /obj/effects/precipitation/rain/sideways/tile

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space, params)
			if(rain)
				for (var/turf/S in space)
					if(istype(S,/turf/unsimulated/floor/auto/swamp))
						S.ReplaceWith(/turf/unsimulated/floor/auto/swamp/rain, force=TRUE)
						if(rain == "Yes")
							S.AddOverlays(pick(station_repair.weather_img), "weather")
						else
							new station_repair.weather_effect(S)
						if(params["Ambient Light Obj"])
							S.vis_contents |= station_repair.ambient_obj
						else
							S.AddOverlays(station_repair.ambient_light, "ambient")

			log_terrainify(user, "turned space into a swamp.")


/datum/terrainify/mars
	name = "Mars Station"
	desc = "Turns space into Mars.  A sprawl of stand, stone, and an unyielding wind."
	additional_options = list("Mining"=list("None","Normal","Rich"))
	additional_toggles = list("Ambient Light Obj"=FALSE, "Duststorm"=TRUE, "Prefabs"=FALSE)
	ambient_color = "#222222"

	convert_station_level(params, mob/user)
		if(..())
			if(params["Duststorm"])
				station_repair.station_generator = new/datum/map_generator/mars_generator/duststorm
				station_repair.weather_img = image(icon = 'icons/turf/areas.dmi', icon_state = "dustverlay", layer = EFFECTS_LAYER_BASE)
			else
				station_repair.station_generator = new/datum/map_generator/mars_generator
			station_repair.overlay_delay = 3.5 SECONDS // Delay to let rocks cull

			station_repair.default_air.carbon_dioxide = 500
			station_repair.default_air.nitrogen = 0
			station_repair.default_air.oxygen = 0
			station_repair.default_air.temperature = 100

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space, params)
			sleep(3 SECONDS) // Let turfs initialize and re-orient before applying overlays

			var/ambient_value
			for (var/turf/S in space)
				S.UpdateOverlays(station_repair.weather_img, "weather")

				if(params["Ambient Light Obj"])
					S.vis_contents |= station_repair.ambient_obj
				else
					ambient_value = lerp(20,80,S.x/300)
					station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value) //randomly shift red to reduce vertical banding
					S.AddOverlays(station_repair.ambient_light, "ambient")

			for(var/turf/S in get_area_turfs(/area/mining/magnet))
				if(S.z != Z_LEVEL_STATION) continue
				for(var/obj/machinery/M in S)
					qdel(M)

			station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			var/list/turf/traveling_crate_turfs = station_repair.get_turfs_to_fix()
			traveling_crate_turfs += station_repair.get_beacon_turfs()
			for(var/turf/unsimulated/wall/setpieces/martian/auto/T in traveling_crate_turfs)
				T.ReplaceWith(/turf/unsimulated/floor/setpieces/martian/station_duststorm, force=TRUE)
				if(station_repair.allows_vehicles)
					T.allows_vehicles = station_repair.allows_vehicles
				T.UpdateOverlays(station_repair.weather_img, "weather")

				if(params["Ambient Light Obj"])
					T.vis_contents |= station_repair.ambient_obj
				else
					ambient_value = lerp(20,80,T.x/300)
					station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value) //randomly shift red to reduce vertical banding
					T.AddOverlays(station_repair.ambient_light, "ambient")

			if(station_repair.ambient_light)
				ambient_value = lerp(20,80,0.5)
				station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value)

			log_terrainify(user, "turned space into Mars.")

	special_repair(list/turf/TS)
		var/ambient_value
		for(var/turf/T in TS)
			ambient_value = lerp(20,80,T.x/300)
			station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value) //randomly shift red to reduce vertical banding
			T.AddOverlays(station_repair.ambient_light, "ambient")


/datum/terrainify/trenchify
	name = "Trench Station"
	desc = "Generates trench caves on the station Z"
	additional_toggles = list("Hostile Mobs"=TRUE, "Re-Entry"=FALSE)
	allow_underwater = TRUE

	convert_station_level(params, mob/user)
		if(..())
			var/hostile_mob_toggle = params["Hostile Mobs"]

			var/turf/T1 = locate(1 + AST_MAPBORDER, 1 + AST_MAPBORDER, Z_LEVEL_STATION)
			var/turf/T2 = locate(world.maxx - AST_MAPBORDER, world.maxy - AST_MAPBORDER, Z_LEVEL_STATION)

			var/datum/mapGenerator/seaCaverns/seaCaverns = new()
			seaCaverns.generate(block(T1, T2), Z_LEVEL_STATION, FALSE)

			for(var/turf/space/space_turf in block(T1, T2))
				if (istype(space_turf.loc, /area/shuttle)) continue
				space_turf.ReplaceWith(/turf/space/fluid/trench)

				if (prob(1))
					new /obj/item/seashell(space_turf)

				if (prob(8))
					var/obj/plant = pick(childrentypesof(/obj/sea_plant))
					var/obj/sea_plant/P = new plant(space_turf)
					P.initialize()

				if(hostile_mob_toggle)
					if (prob(1) && prob(2))
						new /obj/critter/gunbot/drone/buzzdrone/fish(space_turf)
					else if (prob(1) && prob(4))
						new /obj/critter/gunbot/drone/gunshark(space_turf)
					else if (prob(1) && prob(20))
						var/mob/fish = pick(childrentypesof(/mob/living/critter/aquatic/fish))
						new fish(space_turf)
					else if (prob(1) && prob(9) && prob(90))
						var/obj/naval_mine/O = 0
						if (prob(20))
							if (prob(70))
								O = new /obj/naval_mine/standard(space_turf)
							else
								O = new /obj/naval_mine/vandalized(space_turf)
						else
							O = new /obj/naval_mine/rusted(space_turf)
						if (O)
							O.initialize()

					if (prob(2) && prob(25))
						new /obj/overlay/tile_effect/cracks/spawner/trilobite(space_turf)
					if (prob(2) && prob(25))
						new /obj/overlay/tile_effect/cracks/spawner/pikaia(space_turf)

					if (prob(1) && prob(16))
						new /mob/living/critter/small_animal/hallucigenia(space_turf)
					else if (prob(1) && prob(18))
						new /obj/overlay/tile_effect/cracks/spawner/pikaia(space_turf)

				if (prob(1) && prob(9))
					var/obj/storage/crate/trench_loot/C = pick(childrentypesof(/obj/storage/crate/trench_loot))
					var/obj/storage/crate/trench_loot/created_loot = new C(space_turf)
					created_loot.initialize()

				LAGCHECK(LAG_MED)
			station_repair.clean_up_station_level(add_sub=params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			log_terrainify(user, "generated a trench on station Z[hostile_mob_toggle ? " with hostile mobs" : ""].")

/datum/terrainify/winterify
	name = "Winter Station"
	desc = "Turns space into a colder snowy place"
	additional_options = list("Weather"=list("Snow", "Light Snow", "None"), "Mining"=list("None","Normal","Rich"), "Season"=list("None", "Winter"))
	additional_toggles = list("Ambient Light Obj"=TRUE, "Prefabs"=FALSE, "Roads"=FALSE, "Re-Entry"=FALSE)
	ambient_color = "#222222"
	parallax_render_source_group = /datum/parallax_render_source_group/planet/snow

	New()
		syndi_camo_color = list("#50587a", "#bbdbdd", nuke_op_color_matrix[3])
		..()

	convert_station_level(params, mob/user)
		if(..())
			station_repair.station_generator = new/datum/map_generator/snow_generator
			station_repair.default_air.temperature = 235

			var/snow = params["Weather"]
			snow = (snow == "None") ? null : snow
			if(snow == "Light Snow")
				station_repair.weather_effect = /obj/effects/precipitation/snow/grey/tile/light
			else if(snow == "Snow")
				station_repair.weather_effect = /obj/effects/precipitation/snow/grey/tile

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space, params)

			log_terrainify(user, "turned space into a snowscape.")

/datum/terrainify/forestify
	name = "Forest Station"
	desc = "Turns space into a lush and wooden place"
	additional_options = list("Mining"=list("None", "Normal", "Rich"), "Season"=list("None", "Autumn"))
	additional_toggles = list("Ambient Light Obj"=TRUE, "Prefabs"=FALSE, "Roads"=FALSE, "Spooky"=FALSE, "Re-Entry"=FALSE)
	ambient_color = "#211"
	parallax_render_source_group = /datum/parallax_render_source_group/planet/forest

	New()
		syndi_camo_color = list(nuke_op_color_matrix[1], "#3d8f29", nuke_op_color_matrix[3])
		..()

	convert_station_level(params, mob/user)
		if(..())
			if(params["Spooky"])
				station_repair.station_generator = new/datum/map_generator/forest_generator/dark
			else
				station_repair.station_generator = new/datum/map_generator/forest_generator

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space, params)

			if(params["Spooky"])
				// The following should be removed iff Caustics Parallax #16477 is merged
				var/list/station_areas = get_accessible_station_areas()
				for(var/area_name in station_areas)
					var/area/A = station_areas[area_name]
					if(!A.occlude_foreground_parallax_layers)
						A.occlude_foreground_parallax_layers = TRUE
						for(var/turf/T in get_area_turfs(A))
							if(T.z == Z_LEVEL_STATION)
								T.update_parallax_occlusion_overlay()
								LAGCHECK(LAG_MED)

				ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/foreground/fog, 20 SECONDS)

			log_terrainify(user, "turned space into a forest.")

/datum/terrainify/plasma
	name = "Plasma Station"
	desc = "Fill space with plasma gas? Warning: this is as bad as it sounds."
	generates_solid_ground = FALSE

	convert_turfs(list/turfs)
		for (var/turf/T in turfs)
			T.ReplaceWith(/turf/space/plasma, keep_old_material=FALSE, handle_dir=FALSE, force=TRUE)

	convert_station_level(params, mob/user)
		if (!..())
			return
		var/list/turf/space = list()
		for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
			space += S
		convert_turfs(space, params)

		log_terrainify(user, "turned space into a plasma space.")

/datum/terrainify/storehouse
	name = "Storehouse"
	desc = "Load some nearby storehouse (Run before other Generators!)"
	additional_toggles = list("Fill Z-Level"=FALSE, "Meaty"=FALSE)

	convert_station_level(params, mob/user)
		if (!..())
			return
		var/list/turf/space = list()
		for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
			space += S
		var/datum/map_generator/storehouse_generator/generator
		if(params["Meaty"])
			generator = new/datum/map_generator/storehouse_generator/meaty
		else
			generator = new/datum/map_generator/storehouse_generator
		station_repair.station_generator = generator

		if(params["Fill Z-Level"])
			if(!(params["Meaty"]))
				generator.wall_path = /turf/unsimulated/wall/auto/lead/gray
				generator.floor_path = /turf/unsimulated/floor/industrial
			generator.fill_map_bsp()
		else
			generator.generate_map()

		var/list/turf/turfs_to_clear = station_repair.get_turfs_to_fix()
		turfs_to_clear += station_repair.get_beacon_turfs()
		generator.clear_walls(turfs_to_clear)

		generator.generate_terrain(space, reuse_seed=TRUE, flags=MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles)

		log_terrainify(user, "added some storehouses to space.")


/datum/terrainify_editor
	var/static/list/datum/terrainify/terrains
	var/datum/terrainify/active_terrain
	var/list/active_toggles
	var/list/active_options
	var/atom/movable/target
	var/terrain
	var/fabricator
	var/cars
	var/allowVehicles=TRUE
	var/terrain_toggles
	var/terrain_options

/datum/terrainify_editor/New(atom/target)
	..()
	if(!length(terrains))
		var/list/L = concrete_typesof(/datum/terrainify)
		for(var/T in L)
			LAZYLISTADD(terrains, new T())
	src.target = target

/datum/terrainify_editor/disposing()
	src.target = null
	..()

/datum/terrainify_editor/ui_state(mob/user)
	return tgui_admin_state

/datum/terrainify_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Terrainify")
		ui.open()

/datum/terrainify_editor/ui_static_data(mob/user)
	. = list()

	.["typeData"] = list()
	for(var/datum/terrainify/T as anything in terrains)
		.["typeData"][T.type] += list(
			"name" = T.name,
			"description" = T.desc,
			"options"=T.additional_options,
			"toggles"=T.additional_toggles )

/datum/terrainify_editor/ui_data()
	var/list/data = list()
	data["locked"] = !isnull(terrains[1].terrainify_lock)
	data["terrain"] = terrain
	data["activeOptions"] = active_options
	data["activeToggles"] = active_toggles
	data["fabricator"] = fabricator
	data["cars"] = cars
	data["allowVehicles"] = allowVehicles
	return data

/datum/terrainify_editor/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("terrain")
			var/datum/terrainify/path = text2path(params[action])
			terrain = path
			for(var/datum/terrainify/T as anything in terrains)
				if(T.type == path)
					active_terrain = T
					active_toggles = list()
					for(var/toggle in active_terrain.additional_toggles)
						src.active_toggles[toggle] = active_terrain.additional_toggles[toggle] | FALSE
					active_options = list()
					for(var/option in active_terrain.additional_options)
						active_options[option] = active_terrain.additional_options[option][1]
					. = TRUE

		if("fabricator")
			fabricator = !fabricator
			. = TRUE

		if("cars")
			cars = !cars
			. = TRUE

		if("allowVehicles")
			allowVehicles = !allowVehicles
			. = TRUE

		if("toggle")
			if(params["toggle"] in active_terrain.additional_toggles)
				src.active_toggles[params["toggle"]] = !src.active_toggles[params["toggle"]]
				. = TRUE

		if("option")
			if(params["key"] in active_terrain.additional_options)
				if(params["value"] in active_terrain.additional_options[params["key"]])
					active_options[params["key"]] = params["value"]
					. = TRUE

		if("activate")
			var/convert_params = list()
			convert_params += active_toggles
			convert_params += active_options
			convert_params["vehicle"] = (TERRAINIFY_VEHICLE_CARS * cars) + (TERRAINIFY_VEHICLE_FABS * fabricator) + (TERRAINIFY_ALLOW_VEHCILES * allowVehicles)
			var/datum/terrainify/T = locate(terrain) in terrains
			if(T)
				T.perform_terrainify(convert_params, ui.user)
				tgui_process.close_uis(src)
				. = TRUE


#undef TERRAINIFY_VEHICLE_FABS
#undef TERRAINIFY_VEHICLE_CARS


client/proc/unterrainify()
	set name = "Unterrainify"
	set desc = "Get off the planet"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	ADMIN_ONLY
	SHOW_VERB_DESC

	logTheThing(LOG_ADMIN, src, "began to convert all terrain tiles into space.")
	message_admins("[key_name(src)] began to convert all terrain tiles into space.")

	var/list/types_to_remove = list(/obj/stone, /obj/fakeobject/smallrocks, /obj/shrub, /obj/tree, /obj/machinery/plantpot/bareplant, /obj/decal/cleanable, /mob/living/critter)

	var/response = tgui_alert(src, "Do you want to shake and cover the ground?", "Enter Atmosphere?", list("Yes","No"))

	SPAWN(0)
		station_repair.station_generator = null

		if(response == "Yes")
			REMOVE_ALL_PARALLAX_RENDER_SOURCES_FROM_GROUP(Z_LEVEL_STATION)
			var/list/parallax_layers = list(/atom/movable/screen/parallax_render_source/foreground/embers/atmosphere_entry, /atom/movable/screen/parallax_render_source/foreground/snow/atmosphere_entry)
			ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, parallax_layers, 2 SECONDS)

			for (var/client/C in clients)
				var/mob/player_mob = C.mob
				if(istype(player_mob) && player_mob.z == Z_LEVEL_STATION)
					SPAWN(0)
						shake_camera(player_mob, 20 SECONDS, rand(20,40))
					player_mob.changeStatus("knockdown", 2 SECONDS)

		for(var/turf/T in station_repair.preconvert_turfs)
			var/turf/orig = locate(T.x, T.y, T.z)
			orig.ReplaceWith(/turf/space, FALSE, TRUE, FALSE, TRUE)

			if(station_repair.weather_effect)
				var/obj/effects/E = locate(station_repair.weather_effect) in T
				qdel(E)

			for(var/type in types_to_remove)
				var/atom/movable/AM = locate(type) in T
				if(ismob(AM))
					var/mob/M = AM
					if(M.client)
						continue
					else
						qdel(AM)
				else
					qdel(AM)

			LAGCHECK(LAG_REALTIME)

		var/list/turf/preconvert_turfs = station_repair.preconvert_turfs
		station_repair = new
		station_repair.preconvert_turfs = preconvert_turfs

		RESTORE_PARALLAX_RENDER_SOURCE_GROUP_TO_DEFAULT(Z_LEVEL_STATION)
		global.is_map_on_ground_terrain = FALSE

		message_admins("Finished returning the station to space!")

