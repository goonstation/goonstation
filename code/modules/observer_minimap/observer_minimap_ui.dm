var/global/atom/movable/minimap_ui_handler/observer_minimap/observer_minimap_ui
/atom/movable/minimap_ui_handler/observer_minimap/ui_state(mob/user)
	return max(tgui_admin_state.can_use_topic(src, user), tgui_observer_state.can_use_topic(src, user))
/atom/movable/minimap_ui_handler/observer_minimap/ui_status(mob/user)
	return max(tgui_admin_state.can_use_topic(src, user), tgui_observer_state.can_use_topic(src, user))

//
// Admin Minimap
//

/datum/admins/var/atom/movable/minimap_ui_handler/admin_minimap/admin_minimap_ui

/atom/movable/minimap_ui_handler/admin_minimap
	var/obj/minimap/admin_minimap/admin_map
	var/obj/minimap_controller/admin_minimap/admin_controller
	var/show_players = TRUE
	var/show_observers = TRUE

/atom/movable/minimap_ui_handler/admin_minimap/New(parent, control_id = "minimap_ui_\ref[src]", obj/minimap/minimap, tgui_title, tgui_theme)
	src.admin_map = minimap
	src.admin_controller = new(src.admin_map)
	. = ..(parent, control_id, src.admin_controller, tgui_title, tgui_theme)
	src.loc = null
	src.get_admin_area_map()

/atom/movable/minimap_ui_handler/admin_minimap/proc/get_admin_area_map()
	RETURN_TYPE(/datum/minimap/area_map/admin)
	if (src.admin_map && !src.admin_map.map && global.minimap_renderer)
		src.admin_map.initialise_minimap()
	var/datum/minimap/area_map/admin/admin_area_map = src.admin_map?.map
	return admin_area_map

/atom/movable/minimap_ui_handler/admin_minimap/proc/update_marker_visibility()
	var/datum/minimap/area_map/admin/admin_area_map = src.get_admin_area_map()
	var/datum/minimap/area_map/admin/displayed_area_map = src.admin_controller?.displayed_minimap
	if (!admin_area_map)
		return

	for (var/atom/target as anything in admin_area_map.minimap_markers)
		if (!(isobserver(target) || isliving(target)))
			continue

		var/datum/minimap_marker/minimap/marker = admin_area_map.minimap_markers[target]
		if (!marker)
			continue

		marker.visible = isobserver(target) ? src.show_observers : src.show_players
		if (!marker.visible)
			marker.marker.alpha = 0
		admin_area_map.set_marker_position(marker, target.x, target.y, target.z)

		var/datum/minimap_marker/minimap/displayed_marker = displayed_area_map?.minimap_markers[target]
		if (!displayed_marker)
			continue
		displayed_marker.visible = marker.visible
		if (!displayed_marker.visible)
			displayed_marker.marker.alpha = 0
		displayed_area_map.set_marker_position(displayed_marker, target.x, target.y, target.z)

/atom/movable/minimap_ui_handler/admin_minimap/disposing()
	. = ..()
	QDEL_NULL(src.admin_controller)
	QDEL_NULL(src.admin_map)

/atom/movable/minimap_ui_handler/admin_minimap/ui_state(mob/user)
	return tgui_admin_state

/atom/movable/minimap_ui_handler/admin_minimap/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/atom/movable/minimap_ui_handler/admin_minimap/ui_data(mob/user)
	. = ..()

	var/list/z_level_options = list()
	for (var/z_level in 1 to world.maxz)
		var/display_name = "Unknown"
		if (global.zlevels && length(global.zlevels) >= z_level)
			var/datum/zlevel/z_level_datum = global.zlevels[z_level]
			if (z_level_datum?.display_name && z_level_datum.display_name != "Unknown")
				display_name = z_level_datum.display_name
			else if (z_level_datum?.name)
				display_name = z_level_datum.name

		z_level_options["Z[z_level] - [display_name]"] = z_level

	var/datum/minimap/area_map/admin/admin_area_map = src.get_admin_area_map()
	src.update_marker_visibility()
	. += list(
		"z_level_options" = z_level_options,
		"z_level" = admin_area_map?.z_level || Z_LEVEL_STATION,
		"show_players" = src.show_players,
		"show_observers" = src.show_observers,
	)

/atom/movable/minimap_ui_handler/admin_minimap/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	USR_ADMIN_ONLY
	if (.)
		return

	var/datum/minimap/area_map/admin/admin_area_map = src.get_admin_area_map()
	if (!admin_area_map)
		return

	switch (action)
		if ("refresh_map")
			if (ON_COOLDOWN(src, "admin_minimap_refresh", 1 SECOND))
				boutput(ui.user, SPAN_NOTICE("Please wait a moment before refreshing the minimap again."))
				return
			global.minimap_renderer?.refresh_admin_minimap(admin_area_map.z_level)
			admin_area_map.refresh_render()
			var/datum/minimap/area_map/admin/refreshed_displayed_map = src.admin_controller?.displayed_minimap
			refreshed_displayed_map?.refresh_render()

		if ("select_z_level")
			var/z_level = params["z_level"]
			if (!isnum(z_level))
				z_level = text2num(z_level)
			if (!global.minimap_renderer?.valid_admin_z_level(z_level))
				return
			admin_area_map.update_z_level(z_level)
			src.admin_controller?.displayed_minimap?.update_z_level(z_level)
			src.update_marker_visibility()

		if ("reset_scale")
			admin_area_map.find_focal_point()
			var/datum/minimap/area_map/admin/displayed_area_map = src.admin_controller?.displayed_minimap
			displayed_area_map?.find_focal_point()

		if ("toggle_players")
			src.show_players = !src.show_players
			src.update_marker_visibility()

		if ("toggle_observers")
			src.show_observers = !src.show_observers
			src.update_marker_visibility()

	return TRUE
