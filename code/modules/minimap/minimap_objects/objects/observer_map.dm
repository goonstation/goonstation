/obj/minimap/observer_minimap
	name = "Station Map"
	map_path = /datum/minimap/area_map
	map_type = MAP_OBSERVER

/obj/minimap/observer_minimap/New()
	RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CLIENT_NEW, PROC_REF(register_minimap_signals))
	for (var/client/C as anything in clients)
		register_minimap_signals(C = C)
		register_minimap_target(target = C.mob)
	. = ..()

// source is passed by the signal, but is otherwise unused
/obj/minimap/observer_minimap/proc/register_minimap_signals(source, client/C)
	RegisterSignal(C, COMSIG_CLIENT_LOGIN, PROC_REF(register_minimap_target))

// client is passed by the signal, but is otherwise unused
/obj/minimap/observer_minimap/proc/register_minimap_target(client/C, mob/target)
	if (!isliving(target))
		return
	SPAWN(0)
		if (QDELETED(target)) return
		var/datum/job/J = find_job_in_controller_by_string(target.job)
		var/job_dot

		if (istype(J, /datum/job/civilian))
			job_dot = "civilian_dot"
		else if (istype(J, /datum/job/research))
			job_dot = "research_dot"
		else if (istype(J, /datum/job/engineering))
			job_dot = "engineering_dot"
		else if (istype(J, /datum/job/security))
			job_dot = "security_dot"
		else if (istype(J, /datum/job/command))
			job_dot = "command_dot"
		else if (istype(J, /datum/job/special))
			job_dot = "special_dot"
		else
			job_dot = "civilian_dot"
		target.AddComponent(/datum/component/minimap_marker/minimap, MAP_OBSERVER, job_dot, 'icons/obj/minimap/minimap_markers.dmi', null, FALSE)

/obj/minimap/observer_minimap/Click(location, control, params)
	if (!(isobserver(usr) || isadmin(usr)))
		return
	var/list/param_list = params2list(params)
	if ("left" in param_list)
		// Convert from screen (x, y) to map (x, y) coordinates.
		var/turf/clicked = src.get_turf_at_screen_coords(text2num(param_list["icon-x"]), text2num(param_list["icon-y"]))
		usr.set_loc(clicked)
		return
