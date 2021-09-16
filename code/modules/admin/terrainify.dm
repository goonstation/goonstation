/client/proc/cmd_terrainify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Terrainify"
	set desc = "Turns space into a terrain type"
	admin_only

	var/options = list("Winter Station"=/client/proc/cmd_winterify_station,
		"Swamp Station"=/client/proc/cmd_swampify_station,
		"Trench Station"=/client/proc/cmd_trenchify_station)

	var/param = tgui_input_list(src,"Transform space around the station...","Terraform Space",options)
	if(param)
		call(src, options[param])()

var/datum/station_zlevel_repair/station_repair = new
/datum/station_zlevel_repair
	var/datum/map_generator/station_generator
	var/image/ambient_light
	var/image/weather_img
	var/obj/effects/weather_effect

	proc/repair_turfs(turf/turfs)
		if(src.station_generator)
			src.station_generator.generate_terrain(turfs,reuse_seed=TRUE)
		for(var/turf/T as anything in turfs)
			if(src.ambient_light)
				T.UpdateOverlays(src.ambient_light, "ambient")
			if(src.weather_img)
				T.UpdateOverlays(src.weather_img, "weather")
			if(src.weather_effect)
				new src.weather_effect(T)


/client/proc/cmd_swampify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Swampify"
	set desc = "Turns space into a swamp"
	admin_only
	var/const/ambient_light = "#222222"
#ifdef UNDERWATER_MAP
	//to prevent tremendous lag from the entire map flooding from a single ocean tile.
	boutput(src, "You cannot use this command on underwater maps. Sorry!")
	return
#else
	if(src.holder.level >= LEVEL_ADMIN)
		switch(alert("Turn space into a swamp? This is probably going to lag a bunch when it happens and there's no easy undo!",,"Yes","No"))
			if("Yes")
				var/rain = alert("Should it be raining?",,"Yes", "No", "Particles!")
				rain = (rain == "No") ? null : rain

				station_repair.station_generator = new/datum/map_generator/jungle_generator

				if(rain == "Yes")
					station_repair.weather_img = image('icons/turf/water.dmi',"fast_rain", layer = EFFECTS_LAYER_BASE)
					station_repair.weather_img.alpha = 200
					station_repair.weather_img.plane = PLANE_NOSHADOW_ABOVE
				else if(rain)
					station_repair.weather_effect = /obj/effects/rain/sideways/tile

				station_repair.ambient_light = new /image/ambient
				station_repair.ambient_light.color = ambient_light


				var/list/space = list()
				for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
					space += S
				station_repair.station_generator.generate_terrain(space)
				for (var/turf/S in space)
					if(rain)
						if(istype(S,/turf/unsimulated/floor/auto/swamp))
							S.ReplaceWith(/turf/unsimulated/floor/auto/swamp/rain, force=TRUE)
						if(rain == "Yes")
							S.UpdateOverlays(station_repair.weather_img, "rain")
						else
							new station_repair.weather_effect(S)
					S.UpdateOverlays(station_repair.ambient_light, "ambient")
				shippingmarket.clear_path_to_market()

				logTheThing("admin", src, null, "turned space into a swamp.")
				logTheThing("diary", src, null, "turned space into a swamp.", "admin")
				message_admins("[key_name(src)] turned space into a swamp.")
	else
		boutput(src, "You must be at least an Administrator to use this command.")
#endif

/client/proc/cmd_trenchify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Trenchify"
	set desc = "Generates trench caves on the station Z"
	admin_only
	if(src.holder.level >= LEVEL_ADMIN)
		switch(alert("Generate a trench on the station Z level? This is probably going to lag a bunch when it happens and there's no easy undo!",,"Yes","No"))
			if("Yes")
				var/hostile_mob_toggle = FALSE
				if(alert("Include hostile mobs?",,"Yes","No")=="Yes") hostile_mob_toggle = TRUE

				boutput(src, "Now generating trench, pleast wait.")

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
				shippingmarket.clear_path_to_market()
				logTheThing("admin", src, null, "generated a trench on station Z[hostile_mob_toggle ? " with hostile mobs" : ""].")
				logTheThing("diary", src, null, "generated a trench on station Z[hostile_mob_toggle ? " with hostile mobs" : ""].", "admin")
				message_admins("[key_name(src)] generated a trench on station Z[hostile_mob_toggle ? " with hostile mobs" : ""].")
	else
		boutput(src, "You must be at least an Administrator to use this command.")

/client/proc/cmd_winterify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Winterify"
	set desc = "Turns space into a colder snowy place"
	admin_only
	var/const/ambient_light = "#222"
#ifdef UNDERWATER_MAP
	//to prevent tremendous lag from the entire map flooding from a single ocean tile.
	boutput(src, "You cannot use this command on underwater maps. Sorry!")
	return
#else
	if(src.holder.level >= LEVEL_ADMIN)
		switch(alert("Turn space into a snowscape? This is probably going to lag a bunch when it happens and there's no easy undo!",,"Yes","No"))
			if("Yes")
				station_repair.station_generator = new/datum/map_generator/snow_generator

				station_repair.ambient_light = new /image/ambient
				station_repair.ambient_light.color = ambient_light

				var/list/space = list()
				for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
					space += S
				station_repair.station_generator.generate_terrain(space)
				for (var/turf/S as anything in space)
					S.UpdateOverlays(station_repair.ambient_light, "ambient")

				logTheThing("admin", src, null, "turned space into a snowscape.")
				logTheThing("diary", src, null, "turned space into a snowscape.", "admin")
				message_admins("[key_name(src)] turned space into a snowscape.")
	else
		boutput(src, "You must be at least an Administrator to use this command.")
#endif
