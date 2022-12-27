/datum/random_event/major/pocket_dimension
	name = "Pocket Dimensions"
	centcom_headline = "Spatial Instability"
	centcom_message = "Multiple dimensional anomalies detected on the station. Personnel are advised to avoid any spatial perturbations."
	centcom_origin = ALERT_ANOMALY
	required_elapsed_round_time = 20 MINUTES
	var/list/datum/allocated_region/regions = list()

	event_effect(source)
		..()
		var/list/obj/portal/station_portals = list()

		for (var/i in 1 to pick(3,4,5))
			var/datum/allocated_region/region = global.region_allocator.allocate(9, 9)
			region.clean_up(/turf/unsimulated/floor/void/timewarp, main_area=/area/dimensonal_pocket)

			// dim lighting
			for(var/x in 2 to region.width - 1)
				var/turf/T = region.turf_at(x, 2)
				new /obj/map/light/graveyard(T)

				T = region.turf_at(x, region.height - 1)
				new /obj/map/light/graveyard(T)

			for(var/y in 2 to region.height - 1)
				var/turf/T = region.turf_at(2, y)
				new /obj/map/light/graveyard(T)

				T = region.turf_at(region.width - 1, y)
				new /obj/map/light/graveyard(T)

			// portals at cardinal walls
			var/turf/portal_turfs = list()
			portal_turfs += region.turf_at(round(region.width/2) + 1, region.height - 1) // north
			portal_turfs += region.turf_at(round(region.width/2) + 1, 2) // south
			portal_turfs += region.turf_at(region.width - 1, round(region.height/2) + 1 ) // east
			portal_turfs += region.turf_at(2, round(region.height/2) + 1 ) // west

			var/turf/pocket_destination = region.turf_at(round(region.width/2)+1, round(region.height/2)+1)
			new /obj/map/light/graveyard(pocket_destination)

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

			src.regions += region

		SPAWN(rand(2 MINUTES, 3 MINUTES))
			// kill the station portals so no one can warp in during cleanup
			for (var/obj/portal/portal in station_portals)
				portal.dispose()
			for (var/datum/allocated_region/region in regions)
				var/list/turf/exits = list()
				for (var/obj/portal/portal in REGION_TILES(region))
					exits += get_turf(portal.target)
				region.move_movables_to(pick(exits)) // yeet
				region.clean_up(/turf/space, /turf/space)
				region.dispose()

/area/dimensonal_pocket
	name = "Dimensional Pocket"
