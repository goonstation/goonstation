/datum/admins/var/atom/movable/minimap_ui_handler/admin/admin_minimap_ui = null
/datum/admins/var/obj/minimap/admin/admin_station_map

/client/proc/admin_minimap()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Admin Minimap"
	set desc = "An admin view of the station map with player locations"
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!holder.admin_station_map)
		holder.admin_station_map = new
	holder.admin_station_map.initialise_minimap()
	if (!holder.admin_minimap_ui)
		holder.admin_minimap_ui = new(src.holder, "admin_map", holder.admin_station_map, "Admin Station Map", "hackerman")

	holder.admin_minimap_ui.ui_interact(src.mob)

/atom/movable/minimap_ui_handler/admin/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)
/atom/movable/minimap_ui_handler/admin/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/mob/living/Login()
	. = ..()
	SPAWN(5 SECONDS) // race condition with job assignment at round start
		var/datum/job/J = find_job_in_controller_by_string(src.job)
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
		AddComponent(/datum/component/minimap_marker/minimap, MAP_ADMINISTRATOR, job_dot, 'icons/obj/minimap/minimap_markers.dmi', null, FALSE)
