/client/proc/cmd_terrainify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Terrainify"
	set desc = "Turns space into a terrain type"
	admin_only

	var/options = list(
		"Ice Moon Station"=/client/proc/cmd_ice_moon_station,
		"Mars Station"=/client/proc/cmd_marsify_station,
		"Swamp Station"=/client/proc/cmd_swampify_station,
		"Trench Station"=/client/proc/cmd_trenchify_station,
		"Void Station"=/client/proc/cmd_voidify_station,
		"Winter Station"=/client/proc/cmd_winterify_station,
		)

	var/param = tgui_input_list(src,"Transform space around the station...","Terraform Space",options)
	if(param)
		call(src, options[param])()

var/datum/station_zlevel_repair/station_repair = new
/datum/station_zlevel_repair
	var/datum/map_generator/station_generator
	var/image/ambient_light
	var/image/weather_img
	var/obj/effects/weather_effect
	var/overlay_delay

	proc/repair_turfs(turf/turfs)
		if(src.station_generator)
			src.station_generator.generate_terrain(turfs,reuse_seed=TRUE)

		SPAWN_DBG(overlay_delay)
			for(var/turf/T as anything in turfs)
				if(src.ambient_light)
					T.UpdateOverlays(src.ambient_light, "ambient")
				if(src.weather_img)
					T.UpdateOverlays(src.weather_img, "weather")
				if(src.weather_effect)
					new src.weather_effect(T)


/client/proc/cmd_voidify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Void Station"
	set desc = "Turns space into the THE VOID..."
	admin_only
#ifdef UNDERWATER_MAP
	//to prevent tremendous lag from the entire map flooding from a single ocean tile.
	boutput(src, "You cannot use this command on underwater maps. Sorry!")
	return
#else
	if(src.holder.level >= LEVEL_ADMIN)
		switch(alert("Turn space into the unknowable void? This is probably going to lag a bunch when it happens and there's no easy undo!",,"Yes","No"))
			if("Yes")
				station_repair.ambient_light = new /image/ambient
				station_repair.ambient_light.color = rgb(6.9, 4.20, 6.9)

				station_repair.station_generator = new/datum/map_generator/void_generator

				var/list/space = list()
				for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
					space += S
				station_repair.station_generator.generate_terrain(space)
				for (var/turf/S in space)
					S.UpdateOverlays(station_repair.ambient_light, "ambient")

				shippingmarket.clear_path_to_market()

				logTheThing("admin", src, null, "turned space into an THE VOID.")
				logTheThing("diary", src, null, "turned space into an THE VOID.", "admin")
				message_admins("[key_name(src)] turned space into THE VOID.")
	else
		boutput(src, "You must be at least an Administrator to use this command.")
#endif



/client/proc/cmd_ice_moon_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Ice Station"
	set desc = "Turns space into the Outpost Theta..."
	admin_only
#ifdef UNDERWATER_MAP
	//to prevent tremendous lag from the entire map flooding from a single ocean tile.
	boutput(src, "You cannot use this command on underwater maps. Sorry!")
	return
#else
	if(src.holder.level >= LEVEL_ADMIN)
		switch(alert("Turn space into a CO2 + Ice? This is probably going to lag a bunch when it happens and there's no easy undo!",,"Yes","No"))
			if("Yes")
				var/ambient_value
				var/snow = alert("Should it be snowing?",,"Yes", "No", "Particles!")
				snow = (snow == "No") ? null : snow
				if(snow)
					if(snow == "Yes")
						station_repair.weather_img = image(icon = 'icons/turf/areas.dmi', icon_state = "snowverlay", layer = EFFECTS_LAYER_BASE)
						station_repair.weather_img.alpha = 200
						station_repair.weather_img.plane = PLANE_NOSHADOW_ABOVE
					else
						station_repair.weather_effect = /obj/effects/snow/grey/tile

				if(alert("Should it be pitch black?",,"Yes", "No")=="No")
					station_repair.ambient_light = new /image/ambient

				station_repair.station_generator = new/datum/map_generator/icemoon_generator

				var/list/turf/shipping_path = shippingmarket.get_path_to_market()
				for(var/turf/space/T in shipping_path)
					T.ReplaceWith(/turf/unsimulated/floor/arctic/snow/ice)
					if(station_repair.ambient_light)
						ambient_value = lerp(10,50,min(1-T.x/300,0.8))
						station_repair.ambient_light.color = rgb(ambient_value,ambient_value+((rand()*1)),ambient_value+((rand()*1))) //randomly shift green&blue to reduce vertical banding
						T.UpdateOverlays(station_repair.ambient_light, "ambient")

				var/list/space = list()
				for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
					space += S
				station_repair.station_generator.generate_terrain(space)
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

				logTheThing("admin", src, null, "turned space into an another outpost on Theta.")
				logTheThing("diary", src, null, "turned space into an another outpost on Theta.", "admin")
				message_admins("[key_name(src)] turned space into an another outpost on Theta.")
	else
		boutput(src, "You must be at least an Administrator to use this command.")
#endif

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


/client/proc/cmd_marsify_station()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Marsify"
	set desc = "Turns space into a Mars"
	admin_only
#ifdef UNDERWATER_MAP
	//to prevent tremendous lag from the entire map flooding from a single ocean tile.
	boutput(src, "You cannot use this command on underwater maps. Sorry!")
	return
#else
	if(src.holder.level >= LEVEL_ADMIN)
		switch(alert("Turn space into the sands of Mars? This is probably going to lag a bunch when it happens and there's no easy undo!",,"Yes","No"))
			if("Yes")
				var/ambient_value

				station_repair.station_generator = new/datum/map_generator/mars_generator
				station_repair.overlay_delay = 3.5 SECONDS // Delay to let rocks cull
				station_repair.weather_img = image(icon = 'icons/turf/areas.dmi', icon_state = "dustverlay", layer = EFFECTS_LAYER_BASE)
				station_repair.ambient_light = new /image/ambient

				var/list/space = list()
				for(var/turf/space/S in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
					space += S
				station_repair.station_generator.generate_terrain(space)
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

				shippingmarket.clear_path_to_market()

				var/list/turf/shipping_path = shippingmarket.get_path_to_market()
				for(var/turf/unsimulated/wall/setpieces/martian/auto/T in shipping_path)
					T.ReplaceWith(/turf/unsimulated/floor/setpieces/martian/station_duststorm, force=TRUE)
					T.UpdateOverlays(station_repair.weather_img, "weather")
					ambient_value = lerp(20,80,T.x/300)
					station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value) //randomly shift red to reduce vertical banding
					T.UpdateOverlays(station_repair.ambient_light, "ambient")

				//Adjust lighting to midway for  ambient light
				ambient_value = lerp(20,80,0.5)
				station_repair.ambient_light.color = rgb(ambient_value+((rand()*3)),ambient_value,ambient_value)

				logTheThing("admin", src, null, "turned space into a Mars.")
				logTheThing("diary", src, null, "turned space into a Mars.", "admin")
				message_admins("[key_name(src)] turned space into a Mars.")
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

				shippingmarket.clear_path_to_market()

				logTheThing("admin", src, null, "turned space into a snowscape.")
				logTheThing("diary", src, null, "turned space into a snowscape.", "admin")
				message_admins("[key_name(src)] turned space into a snowscape.")
	else
		boutput(src, "You must be at least an Administrator to use this command.")
#endif
