/atom/movable/minimap_ui_handler
	///The shared maximum minimap id number, used for creating unique minimap IDs.
	var/static/max_minimap_id = 0
	///The current unique ID of the minimap, used for rendering it in a ByondUI component.
	var/minimap_id
	///All clients who currently have the minimap ui open.
	var/list/client/viewers = list()
	///The screen handler which the minimap object is placed into.
	var/atom/movable/screen/handler
	///The "minimap" object which will be displayed onto the client's screen. Not explicitly defined, as it may also be of type `obj/minimap_controller`.
	var/obj/minimap

	///The title that the tgui window should display.
	var/tgui_title
	///The theme that the tgui window should use. For a list of all themes, see `tgui/packages/tgui/styles/themes`.
	var/tgui_theme

	New(parent, control_id = null, obj/minimap, tgui_title, tgui_theme)
		. = ..()
		START_TRACKING
		src.loc = parent
		src.tgui_title = tgui_title
		src.tgui_theme = tgui_theme

		if (isnull(control_id))
			control_id = "minimap_ui_[max_minimap_id++]"
		src.minimap_id = "[control_id]"

		src.handler = new
		src.handler.plane = 0
		src.handler.mouse_opacity = 0
		src.handler.screen_loc = "[src.minimap_id]:1,1"

		src.minimap = minimap
		src.minimap.screen_loc = "[src.minimap_id]:1,1"
		src.handler.vis_contents += src.minimap

	disposing()
		STOP_TRACKING
		for (var/client/viewer in src.viewers)
			if (viewer)
				viewer.screen -= src.handler
				viewer.screen -= src.minimap
		. = ..()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Minimap")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"title" = src.tgui_title,
			"theme" = src.tgui_theme,
			"minimap_id"= src.minimap_id
		)

	ui_data(mob/user)
		src.add_client(user?.client)

	ui_close(mob/user)
		src.remove_client(user?.client)
		. = ..()

	///Adds a subscribed client.
	proc/add_client(client/viewer)
		if (viewer && !(viewer in src.viewers))
			src.viewers += viewer
			viewer.screen += src.handler
			viewer.screen += src.minimap

	///Removes a subscribed client.
	proc/remove_client(client/viewer)
		if (viewer && (viewer in src.viewers))
			src.viewers -= viewer
			viewer.screen -= src.handler
			viewer.screen -= src.minimap


/atom/movable/minimap_ui_handler/minimap_controller
	///The minimap controller object, containing data on selected coordinates and the controlled minimap.
	var/obj/minimap_controller/minimap_controller
	///The minimap datum, containing data on the appearance and scale of the minimap, handling resizes, and managing markers.
	var/datum/minimap/minimap_datum
	///An associative list of data for each minimap marker, so that the UI may read it.
	var/list/minimap_markers_list
	///Whether the next call of `"toggle_visibility_all"` will turn all markers opaque or transparent. Does not reflect whether the markers are opaque or transparent.
	var/markers_visible = TRUE

	New(parent, control_id = null, obj/minimap_controller/minimap_controller, tgui_title, tgui_theme)
		..(parent, control_id, minimap_controller, tgui_title, tgui_theme)
		src.minimap_controller = minimap_controller
		src.minimap_datum = minimap_controller.controlled_minimap.map

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "MinimapController")
			ui.open()

	ui_static_data(mob/user)
		. = ..()
		var/list/placable_marker_states = list()
		var/list/placable_marker_images = list()
		for(var/icon_state in icon_states('icons/obj/minimap/minimap_markers.dmi'))
			placable_marker_states.Add(icon_state)
			var/icon/marker_icon = icon('icons/obj/minimap/minimap_markers.dmi', icon_state)
			placable_marker_images[icon_state] = icon2base64(marker_icon)

		. += list(
			"placable_marker_states" = placable_marker_states,
			"placable_marker_images" = placable_marker_images,
			"x" = 1,
			"y" = 1,
			"icon" = "pin",
			"image" = placable_marker_images["pin"]
		)

	ui_data(mob/user)
		..()
		minimap_markers_list = list()
		for (var/atom/target in src.minimap_datum.minimap_markers)
			var/datum/minimap_marker/marker = src.minimap_datum.minimap_markers[target]
			if (!marker.on_minimap_z_level)
				continue

			minimap_markers_list.Add(list(list(
				"name" = marker.name,
				"pos" = "[target.x], [target.y]",
				"visible" = marker.visible,
				"can_be_deleted" = marker.can_be_deleted_by_player,
				"marker" = marker,
				"index" = length(minimap_markers_list) + 1
			)))

		. = list(
			"markers_visible" = markers_visible,
			"selecting_coordinates" = src.minimap_controller.selecting_coordinates,
			"minimap_markers" = minimap_markers_list
		)

		if (src.minimap_controller.selected_x && src.minimap_controller.selected_y)
			. += list(
				"x" = src.minimap_controller.selected_x,
				"y" = src.minimap_controller.selected_y
			)
			src.minimap_controller.selected_x = null
			src.minimap_controller.selected_y = null

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		var/mob/user = ui.user

		if(is_incapacitated(user) || !(src.loc in user.equipped_list()))
			return

		switch (action)
			if ("reset_scale")
				if (istype(src.minimap_datum, /datum/minimap/z_level))
					var/datum/minimap/z_level/minimap = src.minimap_datum
					minimap.find_focal_point()

			if ("toggle_visibility_all")
				for (var/atom/target in src.minimap_datum.minimap_markers)
					if (target.z != minimap_datum.z_level)
						continue

					var/datum/minimap_marker/marker = src.minimap_datum.minimap_markers[target]
					if (markers_visible == TRUE)
						marker.marker.alpha = 0
						marker.visible = FALSE
					else
						marker.marker.alpha = 255
						marker.visible = TRUE

				if (markers_visible == TRUE)
					markers_visible = FALSE
				else
					markers_visible = TRUE

			if ("toggle_visibility")
				var/list/list_entry = src.minimap_markers_list[params["index"]]
				var/datum/minimap_marker/marker = list_entry["marker"]
				if (marker.marker.alpha == 255)
					marker.marker.alpha = 0
					marker.visible = FALSE
				else
					marker.marker.alpha = 255
					marker.visible = TRUE

			if ("location_from_minimap")
				minimap_controller.selecting_coordinates = TRUE

			if ("new_marker")
				var/name = params["name"]
				var/icon_state = params["icon"]
				var/x = params["pos_x"]
				var/y = params["pos_y"]

				var/turf/location = locate(x, y, src.minimap_datum.z_level)
				src.minimap_datum.create_minimap_marker(location, 'icons/obj/minimap/minimap_markers.dmi', icon_state, name, TRUE)

			if ("delete_marker")
				var/list/list_entry = src.minimap_markers_list[params["index"]]
				var/datum/minimap_marker/marker = list_entry["marker"]
				src.minimap_datum.remove_minimap_marker(marker.target)

		return TRUE
