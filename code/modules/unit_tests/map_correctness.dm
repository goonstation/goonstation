/// Not quite a unit test but achieves the same goal. Ran for each map unlike actual unit tests.

#ifdef RUNTIME_CHECKING

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
	check_xmas_tree()

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
		if(istype(T.loc, /turf/space) || T.density)
			log_lines += "[door] [door.type] on [T.x], [T.y], [T.z] in [T.loc]"
	if(length(log_lines))
		CRASH("Doors on invalid turfs:\n" + jointext(log_lines, "\n"))

proc/check_window_turfs()
	var/list/log_lines = list()
	for(var/obj/window/window in world)
		if (QDELETED(window)) return
		var/turf/T = window.loc
		if(istype(T.loc, /turf/space) || T.density)
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
	var/list/blinds_without_switches = list()
	for_by_tcl(blinds, /obj/window_blinds)
		if(isnull(blinds.mySwitch))
			blinds_without_switches += "Blind at [blinds.x], [blinds.y], [blinds.z] in [get_area(blinds)]"
	if(length(blinds_without_switches))
		CRASH("Blinds without switches:\n" + jointext(blinds_without_switches, "\n"))

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

proc/check_missing_material()
	var/list/missing = list()
	for_by_tcl(grille, /obj/grille)
		if (isnull(grille.material))
			missing += "[grille] [grille.type] on [grille.x], [grille.y], [grille.z] in [get_area(grille)]"
	if(length(missing))
		var/missing_text = jointext(missing, "\n")
		CRASH("Missing materials:\n" + missing_text)

proc/check_xmas_tree()
	if(length(by_type[/obj/xmastree]) != 1)
		CRASH("There should be exactly one xmas tree, but there are [length(by_type[/obj/xmastree])]")

#endif
