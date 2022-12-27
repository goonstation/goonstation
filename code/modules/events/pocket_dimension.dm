/datum/random_event/major/pocket_dimension
	name = "Pocket Dimensions"
	centcom_headline = "Spatial Instability"
	centcom_message = "Multiple dimensional anomalies detected on the station. Personnel are advised to avoid any spatial perturbations."
	centcom_origin = ALERT_ANOMALY
	required_elapsed_round_time = 20 MINUTES
	var/static/room_size = 9
	var/static/list/datum/pocket_dimension_theme/pocket_themes = list()
	var/static/list/themed_mobs = list()

	event_effect(source)
		..()
		if (!length(pocket_themes))
			for (var/X in childrentypesof(/datum/pocket_dimension_theme))
				var/datum/pocket_dimension_theme/theme = new X
				pocket_themes += theme
				themed_mobs += theme.spawnable_mobs

		var/list/obj/portal/station_portals = list()
		var/list/datum/allocated_region/regions = list()

		for (var/i in 1 to rand(4,6))
			var/datum/pocket_dimension_theme/room_theme = pick(pocket_themes)
			var/datum/allocated_region/region = global.region_allocator.allocate(room_size, room_size)
			region.clean_up(
				main_turf=room_theme.ground_turf,
				main_area=/area/dimensonal_pocket
			)

			for(var/x in 2 to region.width - 1)
				var/turf/T = region.turf_at(x, 2)
				new room_theme.lighting(T)

				T = region.turf_at(x, region.height - 1)
				new room_theme.lighting(T)

			for(var/y in 2 to region.height - 1)
				var/turf/T = region.turf_at(2, y)
				new room_theme.lighting(T)

				T = region.turf_at(region.width - 1, y)
				new room_theme.lighting(T)

			// portals at cardinal points
			var/turf/portal_turfs = list()
			portal_turfs += region.turf_at(round(region.width/2) + 1, region.height - 1) // north
			portal_turfs += region.turf_at(round(region.width/2) + 1, 2) // south
			portal_turfs += region.turf_at(region.width - 1, round(region.height/2) + 1 ) // east
			portal_turfs += region.turf_at(2, round(region.height/2) + 1 ) // west

			var/turf/pocket_destination = region.turf_at(round(region.width/2)+1, round(region.height/2)+1)
			new room_theme.lighting(pocket_destination)

			for (var/turf/current_turf in portal_turfs)
				var/turf/pocket_turf = current_turf
				var/turf/station_turf = pick(random_floor_turfs)

				var/obj/portal/pocket_portal = new /obj/portal/wormhole
				pocket_portal.set_loc(pocket_turf)
				pocket_portal.target = station_turf
				pocket_portal.failchance = 20 // it's unstable

				var/obj/portal/station_portal = new /obj/portal/wormhole
				station_portal.set_loc(station_turf)
				station_portal.target = pocket_destination
				station_portal.failchance = 0 // make sure they arrive inside
				station_portal.use_teleblocks = FALSE // because we are going to allocated space

				station_portals += station_portal

			if (length(room_theme.spawnable_mobs))
				var/region_tiles = REGION_TILES(region)
				for (var/j in 1 to room_theme.spawnable_count)
					var/new_mob = pick(room_theme.spawnable_mobs)
					var/atom/movable/AM = new new_mob
					AM.set_loc(pick(region_tiles))

			regions += region
			sleep(rand(10 SECONDS, 20 SECONDS))

		// SPAWN(rand(2 MINUTES, 3 MINUTES))
		SPAWN(60 SECONDS)
			// kill the station portals so no one can warp in during cleanup
			for (var/obj/portal/portal in station_portals)
				portal.dispose()
			for(var/datum/allocated_region/region in regions)
				// don't shit the mobs all over the station
				for (var/obj/critter/C in REGION_TILES(region))
					for(var/type in themed_mobs)
						if (istype(C, type))
							C.dispose()
				for (var/mob/living/critter/C in REGION_TILES(region))
					for(var/type in themed_mobs)
						if (istype(C, type))
							C.dispose()
				// now we can clean up
				var/list/turf/exits = list()
				for (var/obj/portal/portal in REGION_TILES(region))
					exits += get_turf(portal.target)
				region.move_movables_to(pick(exits)) // yeet
				region.clean_up(/turf/space, /turf/space)
				region.dispose()

/area/dimensonal_pocket
	name = "Dimensional Pocket"
	may_eat_here_in_restricted_z = TRUE
	allowed_restricted_z = TRUE
	requires_power = FALSE
	expandable = FALSE

/datum/pocket_dimension_theme
	var/list/spawnable_mobs
	var/spawnable_count = 2
	var/turf/unsimulated/ground_turf
	var/obj/map/light/lighting

/datum/pocket_dimension_theme/martian
	spawnable_mobs = list(
		/obj/critter/martian,
		/obj/critter/martian/soldier,
		/obj/critter/martian/warrior,
	)
	ground_turf = /turf/unsimulated/martian/floor
	lighting = /obj/map/light/pink

/datum/pocket_dimension_theme/desert
	spawnable_mobs = list(
		/obj/critter/spacescorpion,
		/mob/living/critter/small_animal/armadillo/ai_controlled,
	)
	ground_turf = /turf/unsimulated/floor/auto/sand/rough
	lighting = /obj/map/light/yellow

/datum/pocket_dimension_theme/void
	spawnable_mobs = list(
		/obj/critter/floateye,
	)
	ground_turf = /turf/unsimulated/floor/void/crunch
	lighting = /obj/map/light/void

/datum/pocket_dimension_theme/crunch
	spawnable_mobs = list(
		/obj/critter/crunched,
		/obj/critter/spirit,
	)
	ground_turf = /turf/unsimulated/floor/void/crunch
	lighting = /obj/map/light/void

/datum/pocket_dimension_theme/swamp
	spawnable_mobs = list(
		/obj/critter/frog,
		/obj/critter/turtle,
	)
	ground_turf = /turf/unsimulated/floor/auto/swamp/rain
	lighting = /obj/map/light/graveyard

/datum/pocket_dimension_theme/forest
	spawnable_mobs = list(
		/mob/living/critter/small_animal/iguana/ai_controlled,
		/obj/critter/bear,
	)
	ground_turf = /turf/unsimulated/floor/setpieces/rootfloor/random
	lighting = /obj/map/light/green

/datum/pocket_dimension_theme/asteroid
	spawnable_mobs = list(
		/obj/critter/fermid,
		/obj/critter/rockworm,
	)
	ground_turf = /turf/unsimulated/floor/asteroid
	lighting = /obj/map/light/white

/datum/pocket_dimension_theme/nerd
	spawnable_mobs = list(
		/obj/critter/mimic,
		/obj/critter/townguard,
	)
	ground_turf = /turf/unsimulated/floor/wood/two
	lighting = /obj/map/light/dimreddish

/datum/pocket_dimension_theme/tundra
	spawnable_mobs = list(
		/mob/living/critter/spider/ice,
		/mob/living/critter/spider/ice/baby, // stop, collabtorate and listen
		/mob/living/critter/small_animal/seal,
	)
	ground_turf = /turf/unsimulated/floor/arctic/snow
	lighting = /obj/map/light/brightwhite

/datum/pocket_dimension_theme/wrassle
	spawnable_mobs = list(
		/obj/critter/zombie/hogan,
		/obj/critter/microman,
	)
	ground_turf = /turf/unsimulated/floor/specialroom/gym
	lighting = /obj/map/light/brighterwhite

/datum/pocket_dimension_theme/graveyard
	spawnable_mobs = list(
		/obj/critter/magiczombie,
		/mob/living/critter/small_animal/bird/crow,
		/mob/living/critter/small_animal/bat/angry,
	)
	ground_turf = /turf/unsimulated/dirt
	lighting = /obj/map/light/graveyard

/datum/pocket_dimension_theme/grassland
	spawnable_mobs = list(
		/obj/critter/wasp/angry,
		/obj/critter/spacerattlesnake,
	)
	ground_turf = /turf/unsimulated/floor/grass/random
	lighting = /obj/map/light/green

/datum/pocket_dimension_theme/ocean
	spawnable_mobs = list(
		/obj/critter/crab,
		/mob/living/critter/small_animal/hallucigenia/ai_controlled,
		// these (reasonably) use an overlay for their bury action, but allocated regions don't clean overlays
		// /mob/living/critter/small_animal/trilobite/ai_controlled,
		// /mob/living/critter/small_animal/pikaia/ai_controlled,
	)
	ground_turf = /turf/unsimulated/floor/seabed
	lighting = /obj/map/light/cyan

/datum/pocket_dimension_theme/hive
	spawnable_mobs = list(
		/obj/critter/domestic_bee,
		/obj/critter/domestic_bee/buddy,
		/obj/critter/domestic_bee/trauma,
	)
	ground_turf = /turf/unsimulated/floor/setpieces/hivefloor
	lighting = /obj/map/light/yellow

/datum/pocket_dimension_theme/blood
	spawnable_mobs = list(
		/obj/critter/zombie,
		/obj/critter/blobman
	)
	ground_turf = /turf/unsimulated/floor/setpieces/bloodfloor
	lighting = /obj/map/light/meatland

/datum/pocket_dimension_theme/cave
	ground_turf = /turf/unsimulated/floor/cave
	lighting = /obj/map/light/dimred

/datum/pocket_dimension_theme/time
	ground_turf = /turf/unsimulated/floor/void/channel
	lighting = /obj/map/light/white

/datum/pocket_dimension_theme/maints
	ground_turf = /turf/unsimulated/floor/plating/random
	lighting = /obj/map/light/graveyard
