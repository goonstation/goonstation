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

/obj/minimap/proc/get_minimap_job_dot(mob/target)
	var/datum/job/J = find_job_in_controller_by_string(target.mind.assigned_role)
	if (istype(J, /datum/job/civilian))
		return "civilian_dot"
	if (istype(J, /datum/job/research))
		return "research_dot"
	if (istype(J, /datum/job/medical))
		return "medical_dot"
	if (istype(J, /datum/job/engineering))
		return "engineering_dot"
	if (istype(J, /datum/job/security))
		return "security_dot"
	if (istype(J, /datum/job/command))
		return "command_dot"
	if (istype(J, /datum/job/special))
		return "special_dot"
	return "civilian_dot"

// source is passed by the signal, but is otherwise unused
/obj/minimap/observer_minimap/proc/register_minimap_signals(source, client/C)
	RegisterSignal(C, COMSIG_CLIENT_LOGIN, PROC_REF(register_minimap_target))

// client is passed by the signal, but is otherwise unused
/obj/minimap/observer_minimap/proc/register_minimap_target(client/C, mob/target)
	if (!isliving(target))
		return
	if (!target.mind)
		return
	target.AddComponent(/datum/component/minimap_marker/minimap, MAP_OBSERVER, src.get_minimap_job_dot(target), 'icons/obj/minimap/minimap_markers.dmi', null, FALSE)

/obj/minimap/observer_minimap/Click(location, control, params)
	if (!(isobserver(usr) || isadmin(usr)))
		return
	src.teleport_to_map_click(usr, params)

/obj/minimap/admin_minimap
	name = "Admin Minimap"
	map_path = /datum/minimap/area_map/admin
	map_type = MAP_OBSERVER | MAP_ADMIN

/obj/minimap/admin_minimap/New()
	. = ..()
	RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CLIENT_NEW, PROC_REF(register_minimap_signals))
	for (var/client/C as anything in clients)
		src.register_minimap_signals(C = C)
		src.register_minimap_target(C = C, target = C.mob)

/obj/minimap/admin_minimap/proc/register_minimap_signals(source, client/C)
	RegisterSignal(C, COMSIG_CLIENT_LOGIN, PROC_REF(register_minimap_target))

/obj/minimap/admin_minimap/proc/register_minimap_target(client/C, mob/target)
	if (isobserver(target))
		target.AddComponent(/datum/component/minimap_marker/minimap, MAP_ADMIN, "observer_dot", 'icons/obj/minimap/minimap_markers.dmi', "Observer", FALSE)
	else if (isliving(target) && target.mind)
		target.AddComponent(/datum/component/minimap_marker/minimap, MAP_ADMIN, src.get_minimap_job_dot(target), 'icons/obj/minimap/minimap_markers.dmi', null, FALSE)

/obj/minimap_controller/admin_minimap
	var/pan_occurred = FALSE

/obj/minimap_controller/admin_minimap/MouseDown(location, control, params)
	src.pan_occurred = FALSE
	. = ..()

/obj/minimap_controller/admin_minimap/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	src.pan_occurred = TRUE
	. = ..()

/obj/minimap_controller/admin_minimap/Click(location, control, params)
	var/was_pan = src.pan_occurred
	src.pan_occurred = FALSE
	if (was_pan || !isadmin(usr))
		return
	src.teleport_to_map_click(usr, params)

/obj/minimap_controller/admin_minimap/proc/teleport_to_map_click(mob/user, params)
	var/list/param_list = params2list(params)
	if (!("left" in param_list) || !src.displayed_minimap?.minimap_render)
		return

	// Convert from screen (x, y) to map (x, y) coordinates
	var/screen_scale = src.displayed_minimap.zoom_coefficient * src.displayed_minimap.map_scale
	if (!screen_scale)
		return
	var/x = round((text2num(param_list["icon-x"]) - src.displayed_minimap.minimap_render.pixel_x) / screen_scale) + 1
	var/y = round((text2num(param_list["icon-y"]) - src.displayed_minimap.minimap_render.pixel_y) / screen_scale) + 1
	var/turf/clicked = locate(x, y, src.displayed_minimap.z_level)
	if (clicked)
		user.set_loc(clicked)

/obj/minimap/proc/teleport_to_map_click(mob/user, params)
	var/list/param_list = params2list(params)
	if ("left" in param_list)
		// Convert from screen (x, y) to map (x, y) coordinates.
		var/turf/clicked = src.get_turf_at_screen_coords(text2num(param_list["icon-x"]), text2num(param_list["icon-y"]))
		if (clicked)
			user.set_loc(clicked)
