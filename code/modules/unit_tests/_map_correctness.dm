// Not quite a unit test but achieves the same goal. Ran for each map unlike actual unit tests.

#ifdef CI_RUNTIME_CHECKING

proc/check_map_correctness()
	check_missing_navbeacons()
	check_apcs_wired()
	check_objects_in_walls()
	check_window_turfs()
	check_door_turfs()
	check_networked_data_terminals()
	check_blinds_switches()
	check_apcless_station_areas()
	check_lightswitchless_station_areas()
	check_unsimulated_station_turfs()
	check_duplicate_area_names()
	check_missing_material()
	#if !(defined(PREFAB_CHECKING) || defined(RANDOM_ROOM_CHECKING))
	check_xmas_tree()
	#endif
	check_turf_underlays()
	check_mass_drivers()

proc/check_missing_navbeacons()
	var/list/all_beacons = list()
	for_by_tcl(beacon, /obj/machinery/navbeacon)
		all_beacons[beacon.location] = TRUE
	var/list/missing = list()
	for_by_tcl(beacon, /obj/machinery/navbeacon)
		for(var/key in list("next_patrol", "next_tour"))
			var/value = beacon.codes[key]
			if(isnull(value))
				continue
			if(!all_beacons[value])
				missing[value] = TRUE
	if(length(missing))
		var/missing_text = jointext(missing, ", ")
		CRASH("Missing navbeacons: " + missing_text)

proc/check_apcs_wired()
	var/list/problematic_areas = list()
	for_by_tcl(apc, /obj/machinery/power/apc)
		var/apc_ok = FALSE
		for(var/obj/cable/cable in apc.loc)
			if(cable.d1 == 0)
				apc_ok = TRUE
				break
		if(!apc_ok)
			problematic_areas += apc.area.name
	if(length(problematic_areas))
		var/problematic_areas_text = jointext(problematic_areas, ", ")
		CRASH("APCs without cables: " + problematic_areas_text)

proc/check_objects_in_walls(z_level=Z_LEVEL_STATION)
	var/list/log_lines = list()
	for(var/turf/simulated/wall/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		for(var/obj/O in T)
			if(!O.anchored)
				log_lines += "[O] [O.type] on [T.x], [T.y], [T.z] in [T.loc]"
	for(var/turf/unsimulated/wall/T in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		for(var/obj/O in T)
			if(!O.anchored)
				log_lines += "[O] [O.type] on [T.x], [T.y], [T.z] in [T.loc]"
	if(length(log_lines))
		CRASH("Unanchored objects in walls:\n" + jointext(log_lines, "\n"))

proc/check_door_turfs()
	var/list/log_lines = list()
	for_by_tcl(door, /obj/machinery/door)
		var/turf/T = door.loc
		if(istype(T, /turf/space) && !istype(door, /obj/machinery/door/poddoor) || T.density)
			log_lines += "[door] [door.type] on [T.x], [T.y], [T.z] in [T.loc]"
	if(length(log_lines))
		CRASH("Doors on invalid turfs:\n" + jointext(log_lines, "\n"))

proc/check_window_turfs()
	var/list/log_lines = list()
	for(var/obj/window/window in world)
		if (QDELETED(window)) return
		var/turf/T = window.loc
		if(istype(T, /turf/space) || T.density)
			log_lines += "[window] [window.type] on [T.x], [T.y], [T.z] in [T.loc]"
	if(length(log_lines))
		CRASH("Windows on invalid turfs:\n" + jointext(log_lines, "\n"))

proc/check_networked_data_terminals()
	var/list/log_lines = list()
	for(var/obj/machinery/networked/networked in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		if(!(locate(/obj/machinery/power/data_terminal) in networked.loc))
			var/turf/T = networked.loc
			log_lines += "[networked] [networked.type] on [T.x], [T.y], [T.z] in [T.loc]"
	for(var/turf/T in job_start_locations["AI"])
		if(!(locate(/obj/machinery/power/data_terminal) in T))
			log_lines += "AI start landmark on [T.x], [T.y], [T.z] in [T.loc]"
	if(length(log_lines))
		CRASH("Terminal-less machinery:\n" + jointext(log_lines, "\n"))

proc/check_blinds_switches()
	var/list/blind_switch_IDs = list()
	var/list/IDs_without_switches = list()
	for_by_tcl(blinds, /obj/window_blinds) //get all the blinds
		var/area/area_of_thing = get_area(blinds)
		var/new_id = blinds.id ? blinds.id : "[area_of_thing.name]"
		blind_switch_IDs["[new_id]"] = FALSE //have an entry for each ID that's marked as false
	for_by_tcl(blind_switch, /obj/blind_switch) //then check for blinds match
		var/area/area_of_thing = get_area(blind_switch)
		var/new_id = blind_switch.id ? blind_switch.id : "[area_of_thing.name]"
		for(var/seek_ID in blind_switch_IDs)
			if(new_id == seek_ID)
				blind_switch_IDs[seek_ID] = TRUE //and update ID entries to TRUE if a switch satisfies them
	for(var/seek_ID in blind_switch_IDs) //once all switches and blinds are iterated over, check for any absences
		if(blind_switch_IDs[seek_ID] == FALSE)
			IDs_without_switches += "[seek_ID]"
	if(length(IDs_without_switches))
		CRASH("Blinds IDs without switches:\n" + jointext(IDs_without_switches, "\n"))

proc/check_apcless_station_areas()
	var/list/log_lines = list()
	for(var/area/station/AR in get_accessible_station_areas())
		if(isnull(AR.area_apc))
			log_lines += "[AR]"
	if(length(log_lines))
		CRASH("Station areas without APCs:\n" + jointext(log_lines, "\n"))

proc/check_lightswitchless_station_areas()
	var/list/log_lines = list()
	for(var/area/station/AR in get_accessible_station_areas())
		if(istype(AR, /area/station/maintenance))
			continue
		var/has_lights = locate(/obj/machinery/light) in AR.machines
		if(!has_lights)
			continue
		var/has_lightswitches = locate(/obj/machinery/light_switch) in AR.machines
		if(!has_lightswitches)
			log_lines += "[AR]"
	if(length(log_lines))
		CRASH("Station areas without light switches:\n" + jointext(log_lines, "\n"))

proc/check_unsimulated_station_turfs()
	var/list/log_lines = list()
	for(var/turf/unsimulated/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		if(!istype(T.loc, /area/station) || istype(T.loc, /area/station/hallway/secondary/oshan_arrivals) || \
				istype(T.loc, /area/station/hangar/arrivals) || istype(T.loc, /area/station/crewquarters/cryotron))
			continue
		log_lines += "[T] [T.type] on [T.x], [T.y], [T.z] in [T.loc]"
	if(length(log_lines))
		CRASH("Unsimulated station turfs:\n" + jointext(log_lines, "\n"))

proc/check_duplicate_area_names()
	var/list/names = list()
	for (var/area/A in world)
		if (!istype(A, /area/shuttle/merchant_shuttle)) // i quite frankly do not have the fucking energy to defuck merchant shuttle paths
			LAZYLISTINIT(names[A.name])
			names[A.name] |= A.type

	var/list/dupes = list()
	for (var/name in names)
		if (length(names[name]) > 1)
			dupes += name

	if (length(dupes))
		// Build descriptive failure message
		var/log_msg
		for (var/dupe in dupes)
			log_msg += "The following areas have duplicate name \"[dupe || "***EMPTY STRING***"]\": [english_list(names[dupe])]\n"

		CRASH(log_msg)

proc/check_mass_drivers()
	var/list/log_lines = list()
	for(var/obj/machinery/mass_driver/M as anything in machine_registry[MACHINES_MASSDRIVERS])
		if(M.z == Z_LEVEL_STATION)
			var/atom/end = get_ranged_target_turf(M, M.dir, M.drive_range)

			if(!istype(end, /turf/space))
				continue
			else if(istype(end, /turf/space/fluid/warp_z5))
				continue
			else if((end.x == 1 || end.x == world.maxx || end.y == 1 || end.y == world.maxy))
				continue

			var/distance = 0
			var/turf/new_end = end
			while(TRUE)
				new_end = get_step(new_end, M.dir)
				if(!istype(new_end, /turf/space) || istype(new_end, /turf/space/fluid/warp_z5) || (new_end.x == 1 || new_end.x == world.maxx || new_end.y == 1 || new_end.y == world.maxy) )
					distance = GET_DIST(M, new_end)
					break

			log_lines += "([M.x], [M.y]) only reaches [end] ([end.x],[end.y]) consider range of [distance] to reach [new_end] ([new_end?.x],[new_end?.y]) "
	if(length(log_lines))
		CRASH("Insufficient Mass Driver Range:\n" + jointext(log_lines, "\n"))

proc/check_missing_material()
	var/list/missing = list()
	for_by_tcl(grille, /obj/mesh/grille)
		if (isnull(grille.material))
			missing += "[grille] [grille.type] on [grille.x], [grille.y], [grille.z] in [get_area(grille)]"
	if(length(missing))
		var/missing_text = jointext(missing, "\n")
		CRASH("Missing materials:\n" + missing_text)

proc/check_xmas_tree()
	if(length(by_type[/obj/xmastree]) != 1)
		CRASH("There should be exactly one xmas tree, but there are [length(by_type[/obj/xmastree])]")

proc/check_turf_underlays()
	var/log_msg
	var/list/whitelist_types = list(
		/turf/simulated/floor/airless/plating/catwalk,
		/turf/simulated/floor/airbridge,
		/turf/simulated/wall/airbridge,
		)
	for(var/turf/T in block(locate(1, 1, Z_LEVEL_STATION), locate(world.maxx, world.maxy, Z_LEVEL_STATION)))
		if(T.underlays.len && !istypes(T, whitelist_types))
			log_msg += "Turf [T] [T.type] on [T.x], [T.y], [T.z] in [T.loc] has underlays, likely due to duplicate turfs in the map.\n"
	if(log_msg)
		CRASH(log_msg)

#endif
