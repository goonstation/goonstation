#define TERRAINIFY_VEHICLE_FABS (1 << 0)
#define TERRAINIFY_VEHICLE_CARS (1 << 1)
#define TERRAINIFY_ALLOW_VEHCILES (1 << 2)

/client/proc/cmd_terrainify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Terrainify"
	set desc = "Turns space into a terrain type"
	ADMIN_ONLY

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

	New()
		..()
		default_air = new
		default_air.oxygen = MOLES_O2STANDARD
		default_air.nitrogen = MOLES_N2STANDARD
		default_air.temperature = T20C

	proc/repair_turfs(turf/turfs, clear=FALSE)
		if(src.station_generator)
			var/gen_flags = MAPGEN_IGNORE_FLORA|MAPGEN_IGNORE_FAUNA
			gen_flags |= MAPGEN_ALLOW_VEHICLES * src.allows_vehicles
			src.station_generator.generate_terrain(turfs, reuse_seed=TRUE, flags=gen_flags)

			if(clear)
				clear_out_turfs(turfs, ignore_contents=TRUE)

		SPAWN(overlay_delay)
			for(var/turf/T as anything in turfs)
				if(src.ambient_light)
					T.UpdateOverlays(src.ambient_light, "ambient")
				if(src.ambient_obj)
					T.vis_contents |= src.ambient_obj
				if(src.weather_img)
					T.UpdateOverlays(src.weather_img, "weather")
				if(src.weather_effect)
					var/obj/effects/E = locate(src.weather_effect) in T
					if(!E)
						new src.weather_effect(T)

	proc/clean_up_station_level(replace_with_cars, add_sub)
		mass_driver_fixup()
		shipping_market_fixup()
		land_vehicle_fixup(replace_with_cars, add_sub)
		copy_gas_to_airless()
		clear_around_beacons()

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
					man.add_schematic(/datum/manufacture/sub/engine)
					man.add_schematic(/datum/manufacture/sub/boards)
					man.add_schematic(/datum/manufacture/sub/control)
					man.add_schematic(/datum/manufacture/sub/parts)
					man.add_schematic(/datum/manufacture/sub/wheels)

	proc/mass_driver_fixup()
		var/list/turfs_to_fix = get_mass_driver_turfs()
		clear_out_turfs(turfs_to_fix)

	proc/clear_around_beacons()
		var/list/turfs_to_fix = list()
		for(var/obj/warp_beacon/W in by_type[/obj/warp_beacon])
			for(var/turf/T in range(3,W))
				turfs_to_fix |= T
		clear_out_turfs(turfs_to_fix, by_type[/obj/warp_beacon])

	proc/get_mass_driver_turfs()
		var/list/turfs_to_fix = list()
		for(var/obj/machinery/mass_driver/M as anything in machine_registry[MACHINES_MASSDRIVERS])
			if(M.z == Z_LEVEL_STATION)
				var/atom/start = get_turf(M)
				var/atom/end = get_ranged_target_turf(M, M.dir, M.drive_range)

				turfs_to_fix |= block(start, end)

		return turfs_to_fix

	proc/shipping_market_fixup()
		var/list/turfs_to_fix = shippingmarket.get_path_to_market()
		clear_out_turfs(turfs_to_fix)

	proc/clear_out_turfs(list/turf/to_clear, list/ignore_list, ignore_contents=FALSE)
		for(var/turf/T as anything in to_clear)
			//Wacks asteroids and skip normal turfs that belong
			if(istype(T, /turf/simulated/wall/auto/asteroid))
				var/turf/simulated/wall/auto/asteroid/AST = T
				AST.destroy_asteroid(dropOre=FALSE)
				continue
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

ABSTRACT_TYPE(/datum/terrainify)
/datum/terrainify
	var/name
	var/desc
	var/additional_options
	var/additional_toggles
	var/static/datum/terrainify/terrainify_lock
	var/allow_underwater = FALSE

	proc/special_repair(list/turf/TS)
		return FALSE

	proc/convert_station_level(params, datum/tgui/ui)
		USR_ADMIN_ONLY
#ifdef UNDERWATER_MAP
		if(!allow_underwater)
			//to prevent tremendous lag from the entire map flooding from a single ocean tile.
			boutput(usr, "You cannot use this command on underwater maps. Sorry!")
			return FALSE
#endif
		if(terrainify_lock)
			boutput(ui.user, "Terrainify has already begone!")
		else if(ui.user.client?.holder.level >= LEVEL_ADMIN)
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
						boutput(ui.user, "[params[option]] is not a valid option for [option] for [name]! Call 1-800-CODER!")
						return

			station_repair.allows_vehicles = (params["vehicle"] & TERRAINIFY_ALLOW_VEHCILES) == TERRAINIFY_ALLOW_VEHCILES

			message_admins("[key_name(ui.user)] started Terrainify: [name].")
			terrainify_lock = src
			tgui_process.close_uis(ui.src_object)
			. = TRUE
		else
			boutput(ui.user, "You must be at least an Administrator to use this command.")

	proc/check_param(params, key)
		if(isnull(params[key]))
			boutput(usr, "Key [key] not provided to [name] terrainify! Call 1-800-CODER!")
		else
			. = TRUE

	proc/convert_turfs(list/turfs)
		station_repair.station_generator.generate_terrain(turfs, flags=MAPGEN_ALLOW_VEHICLES * station_repair.allows_vehicles)

/datum/terrainify/desertify
	name = "Desert Station"
	desc = "Turn space into into a nice desert full of sand and stones."
	additional_toggles = list("Ambient Light Obj")

	convert_station_level(params, datum/tgui/ui)
		if(..())
			var/const/ambient_light = "#cfcfcf"
			station_repair.station_generator = new/datum/map_generator/desert_generator
			if(params["Ambient Light Obj"])
				station_repair.ambient_obj = new /obj/ambient
				station_repair.ambient_obj.color = ambient_light
			else
				station_repair.ambient_light = new /image/ambient
				station_repair.ambient_light.color = ambient_light
			station_repair.default_air.temperature = 330

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space)
			for (var/turf/S in space)
				if(params["Ambient Light Obj"])
					S.vis_contents |= station_repair.ambient_obj
				else
					S.UpdateOverlays(station_repair.ambient_light, "ambient")

			station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			logTheThing(LOG_ADMIN, ui.user, "turned space into a desert.")
			logTheThing(LOG_DIARY, ui.user, "turned space into a desert.", "admin")
			message_admins("[key_name(ui.user)] turned space into a desert.")


/datum/terrainify/void
	name = "Void Station"
	desc = "Turn space into the unknowable void? Space if filled with the void, inhibited by those departed, and chunks of scaffolding."

	convert_station_level(params, datum/tgui/ui)
		if(..())
			station_repair.ambient_light = new /image/ambient
			station_repair.ambient_light.color = rgb(6.9, 4.20, 6.9)

			station_repair.station_generator = new/datum/map_generator/void_generator

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space)
			for (var/turf/S in space)
				S.UpdateOverlays(station_repair.ambient_light, "ambient")

			station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			logTheThing(LOG_ADMIN, ui.user, "turned space into an THE VOID.")
			logTheThing(LOG_DIARY, ui.user, "turned space into an THE VOID.", "admin")
			message_admins("[key_name(ui.user)] turned space into THE VOID.")


/datum/terrainify/ice_moon
	name = "Ice Moon Station"
	desc = "Turns space into the Outpost Theta... CO2 + Ice. Ice Spiders, Seal Pups, Brullbar, and the occasional Yeti."
	additional_options = list("Snowing"=list("Yes","No","Particles"))
	additional_toggles = list("Pitch Black")

	convert_station_level(params, datum/tgui/ui)
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

			if(!params["Pitch Black"])
				station_repair.ambient_light = new /image/ambient

			station_repair.station_generator = new/datum/map_generator/icemoon_generator

			var/list/turf/traveling_crate_turfs = station_repair.get_mass_driver_turfs()
			var/list/turf/shipping_path = shippingmarket.get_path_to_market()
			traveling_crate_turfs |= shipping_path
			for(var/turf/space/T in traveling_crate_turfs)
				T.ReplaceWith(/turf/unsimulated/floor/arctic/snow/ice)
				if(station_repair.ambient_light)
					ambient_value = lerp(10,50,min(1-T.x/300,0.8))
					station_repair.ambient_light.color = rgb(ambient_value,ambient_value+((rand()*1)),ambient_value+((rand()*1))) //randomly shift green&blue to reduce vertical banding
					T.UpdateOverlays(station_repair.ambient_light, "ambient")
			station_repair.land_vehicle_fixup(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space)
			for (var/turf/S in space)
				if(snow)
					if(snow == "Yes")
						S.UpdateOverlays(station_repair.weather_img, "rain")
					else
						new station_repair.weather_effect(S)
				if(station_repair.ambient_light)
					ambient_value = lerp(10,50,min(1-S.x/300,0.8))
					station_repair.ambient_light.color = rgb(ambient_value,ambient_value+((rand()*1)),ambient_value+((rand()*1))) //randomly shift green&blue to reduce vertical banding
					S.UpdateOverlays(station_repair.ambient_light, "ambient")
			// Path to market does not need to be cleared because it was converted to ice.  Abyss will screw up everything!

			logTheThing(LOG_ADMIN, ui.user, "turned space into an another outpost on Theta.")
			logTheThing(LOG_DIARY, ui.user, "turned space into an another outpost on Theta.", "admin")
			message_admins("[key_name(ui.user)] turned space into an another outpost on Theta.")


/datum/terrainify/swampify
	name = "Swamp Station"
	desc = "Turns space into a swamp"
	additional_options = list("Rain"=list("Yes","No", "Particles"))
	additional_toggles = list("Ambient Light Obj")

	convert_station_level(params, datum/tgui/ui)
		if(..())
			var/const/ambient_light = "#222222"
			var/rain = params["Rain"]
			rain = (rain == "No") ? null : rain

			station_repair.station_generator = new/datum/map_generator/jungle_generator

			if(rain == "Yes")
				station_repair.weather_img = image('icons/turf/water.dmi',"fast_rain", layer = EFFECTS_LAYER_BASE)
				station_repair.weather_img.alpha = 200
				station_repair.weather_img.plane = PLANE_NOSHADOW_ABOVE
			else if(rain)
				station_repair.weather_effect = /obj/effects/precipitation/rain/sideways/tile


			if(params["Ambient Light Obj"])
				station_repair.ambient_obj = new /obj/ambient
				station_repair.ambient_obj.color = ambient_light
			else
				station_repair.ambient_light = new /image/ambient
				station_repair.ambient_light.color = ambient_light


			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space)
			for (var/turf/S in space)
				if(rain)
					if(istype(S,/turf/unsimulated/floor/auto/swamp))
						S.ReplaceWith(/turf/unsimulated/floor/auto/swamp/rain, force=TRUE)
					if(rain == "Yes")
						S.UpdateOverlays(station_repair.weather_img, "rain")
					else
						new station_repair.weather_effect(S)
				if(params["Ambient Light Obj"])
					S.vis_contents |= station_repair.ambient_obj
				else
					S.UpdateOverlays(station_repair.ambient_light, "ambient")

			station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			logTheThing(LOG_ADMIN, ui.user, "turned space into a swamp.")
			logTheThing(LOG_DIARY, ui.user, "turned space into a swamp.", "admin")
			message_admins("[key_name(ui.user)] turned space into a swamp.")


/datum/terrainify/mars
	name = "Mars Station"
	desc = "Turns space into Mars.  A sprawl of stand, stone, and an unyielding wind."

	convert_station_level(params, datum/tgui/ui)
		if(..())
			var/ambient_value
			station_repair.station_generator = new/datum/map_generator/mars_generator
			station_repair.overlay_delay = 3.5 SECONDS // Delay to let rocks cull
			station_repair.weather_img = image(icon = 'icons/turf/areas.dmi', icon_state = "dustverlay", layer = EFFECTS_LAYER_BASE)
			station_repair.ambient_light = new /image/ambient

			station_repair.default_air.carbon_dioxide = 500
			station_repair.default_air.nitrogen = 0
			station_repair.default_air.oxygen = 0
			station_repair.default_air.temperature = 100

			var/list/space = list()
			for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
				space += S
			convert_turfs(space)
			sleep(3 SECONDS) // Let turfs initialize and re-orient before applying overlays
			for (var/turf/S in space)
				S.UpdateOverlays(station_repair.weather_img, "weather")
				ambient_value = lerp(20,80,S.x/300)
				station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value) //randomly shift red to reduce vertical banding
				S.UpdateOverlays(station_repair.ambient_light, "ambient")

			for(var/turf/S in get_area_turfs(/area/mining/magnet))
				if(S.z != Z_LEVEL_STATION) continue
				for(var/obj/machinery/M in S)
					qdel(M)

			station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			var/list/turf/shipping_path = shippingmarket.get_path_to_market()
			for(var/turf/unsimulated/wall/setpieces/martian/auto/T in shipping_path)
				T.ReplaceWith(/turf/unsimulated/floor/setpieces/martian/station_duststorm, force=TRUE)
				T.UpdateOverlays(station_repair.weather_img, "weather")
				ambient_value = lerp(20,80,T.x/300)
				station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value) //randomly shift red to reduce vertical banding
				T.UpdateOverlays(station_repair.ambient_light, "ambient")

			ambient_value = lerp(20,80,0.5)
			station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value)
			logTheThing(LOG_ADMIN, ui.user, "turned space into Mars.")
			logTheThing(LOG_DIARY, ui.user, "turned space into Mars.", "admin")
			message_admins("[key_name(ui.user)] turned space into Mars.")

	special_repair(list/turf/TS)
		var/ambient_value
		for(var/turf/T in TS)
			ambient_value = lerp(20,80,T.x/300)
			station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value) //randomly shift red to reduce vertical banding
			T.UpdateOverlays(station_repair.ambient_light, "ambient")


/datum/terrainify/trenchify
	name = "Trench Station"
	desc = "Generates trench caves on the station Z"
	additional_toggles = list("Hostile Mobs")
	allow_underwater = TRUE

	convert_station_level(params, datum/tgui/ui)
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
						new /mob/living/critter/small_animal/hallucigenia/ai_controlled(space_turf)
					else if (prob(1) && prob(18))
						new /obj/overlay/tile_effect/cracks/spawner/pikaia(space_turf)

				if (prob(1) && prob(9))
					var/obj/storage/crate/trench_loot/C = pick(childrentypesof(/obj/storage/crate/trench_loot))
					var/obj/storage/crate/trench_loot/created_loot = new C(space_turf)
					created_loot.initialize()

				LAGCHECK(LAG_MED)
			station_repair.clean_up_station_level(add_sub=params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			logTheThing(LOG_ADMIN, ui.user, "generated a trench on station Z[hostile_mob_toggle ? " with hostile mobs" : ""].")
			logTheThing(LOG_DIARY, ui.user, "generated a trench on station Z[hostile_mob_toggle ? " with hostile mobs" : ""].", "admin")
			message_admins("[key_name(ui.user)] generated a trench on station Z[hostile_mob_toggle ? " with hostile mobs" : ""].")


/datum/terrainify/winterify
	name = "Winter Station"
	desc = "Turns space into a colder snowy place"
	additional_options = list("Weather"=list("Snow", "Light Snow", "None"))
	additional_toggles = list("Ambient Light Obj")

	convert_station_level(params, datum/tgui/ui)
		if(..())
			var/const/ambient_light = "#222"
			station_repair.station_generator = new/datum/map_generator/snow_generator

			if(params["Ambient Light Obj"])
				station_repair.ambient_obj = new /obj/ambient
				station_repair.ambient_obj.color = ambient_light
			else
				station_repair.ambient_light = new /image/ambient
				station_repair.ambient_light.color = ambient_light

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
			convert_turfs(space)
			for (var/turf/S as anything in space)
				if(params["Ambient Light Obj"])
					S.vis_contents |= station_repair.ambient_obj
				else
					S.UpdateOverlays(station_repair.ambient_light, "ambient")
				if(snow)
					new station_repair.weather_effect(S)

			station_repair.clean_up_station_level(params["vehicle"] & TERRAINIFY_VEHICLE_CARS, params["vehicle"] & TERRAINIFY_VEHICLE_FABS)

			logTheThing(LOG_ADMIN, ui.user, "turned space into a snowscape.")
			logTheThing(LOG_DIARY, ui.user, "turned space into a snowscape.", "admin")
			message_admins("[key_name(ui.user)] turned space into a snowscape.")


/datum/terrainify_editor
	var/static/list/datum/terrainify/terrains
	var/datum/terrainify/active_terrain
	var/list/active_toggles
	var/list/active_options
	var/atom/movable/target
	var/terrain
	var/fabricator
	var/cars
	var/allowVehicles
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
						active_toggles[toggle] = FALSE
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
				T.convert_station_level(convert_params, ui)
				T.terrainify_lock = null
				. = TRUE


#undef TERRAINIFY_VEHICLE_FABS
#undef TERRAINIFY_VEHICLE_CARS
