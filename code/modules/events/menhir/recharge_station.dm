//it appears you may need a top up! let's help with that
/datum/random_event/menhir/supercharge
	name = "One Flame Begets Another"
	description = "Summons several spheres to supercharge APCs, preferring depleted ones in actively used spaces."
	message_delay = 1 MINUTE
	weight = 150

	event_effect()
		var/list/station_areas = get_accessible_station_areas()
		var/list/candidate_apcs = list()
		for (var/area_name in station_areas)
			var/area/A = station_areas[area_name]
			if (!istype(A,/area/station/maintenance) && istype(A.area_apc))
				var/obj/machinery/power/apc/our_apc = A.area_apc
				if(!our_apc.cell) continue
				var/powerfraction = ((1 - (our_apc.cell.charge / our_apc.cell.maxcharge)) * 20)
				var/apc_weight = max(1,round(powerfraction ** 2)) //lower power is dramatically higher odds
				if(A.workplace) //weight a little higher towards workplaces as well
					apc_weight *= 2
				candidate_apcs[our_apc] = apc_weight

		var/zones_to_electrify = rand(6,8)
		if(length(candidate_apcs) < zones_to_electrify)
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't find enough APCs to electrify! This shouldn't happen.")
			message_admins("Menhir event [src.name] couldn't find enough APCs to electrify! This shouldn't happen. Aborting event")
			return

		SPAWN(1) //don't hold up other operations
			var/report_string = ""
			for(var/i = 1 to zones_to_electrify)
				var/obj/machinery/power/apc/our_target = weighted_pick(candidate_apcs)
				candidate_apcs[our_target] = 0
				var/area/apc_loc_area = get_area(our_target) //align to the physical position of the APC, not where it powers
				var/orb_spawns = list()
				for(var/turf/T in orange(6,our_target))
					if(!is_blocked_turf(T) && get_area(T) == apc_loc_area) orb_spawns += T
				var/turf/orb_spawn_here = pick(orb_spawns)
				if(orb_spawn_here)
					new /obj/machinery/menhir_energy_sphere(orb_spawn_here,our_target)
					report_string += "[log_loc(orb_spawn_here)]"
					if(i != zones_to_electrify) report_string += ", "
				sleep(2)

			logTheThing(LOG_STATION, null, "Menhir event [src.name] triggered at: [report_string]")
			message_admins("Menhir event [src.name] triggered at: [report_string]")

		message_delay = rand(6 SECONDS,9 SECONDS)
		..()
