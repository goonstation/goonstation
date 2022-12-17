/atom/movable/minimap_ui_handler
	var/static/max_minimap_id = 0
	var/minimap_id
	var/list/viewers = list()
	var/atom/movable/screen/handler
	var/obj/minimap

	var/datum/minimap/minimap_datum
	var/list/minimap_markers_list
	var/markers_visible = TRUE

	New(parent, control_id = null, obj/minimap)
		. = ..()
		START_TRACKING
		src.loc = parent

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

		if (istype(src.minimap, /obj/minimap))
			var/obj/minimap/map = minimap
			src.minimap_datum = map.map
		else if (istype(src.minimap, /obj/minimap_controller))
			var/obj/minimap_controller/map = minimap
			src.minimap_datum = map.controlled_minimap.map

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
			ui = new(user, src, "NukeOpMap")
			ui.open()

	ui_data(mob/user)
		src.add_client(user?.client)
		minimap_markers_list = list()
		for (var/atom/target in src.minimap_datum.minimap_markers)
			var/datum/minimap_marker/marker = src.minimap_datum.minimap_markers[target]
			minimap_markers_list.Add(list(list(
				"name" = marker.name,
				"pos" = "[target.x], [target.y], [target.z]",
				"visible" = marker.visible,
				"on_z_level" = marker.on_minimap_z_level,
				"can_be_deleted" = marker.can_be_deleted_by_player,
				"marker" = marker,
				"index" = length(minimap_markers_list) + 1
			)))

		. = list(
			"markers_visible" = markers_visible,
			"minimap_markers" = minimap_markers_list
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		var/mob/user
		if(ismob(usr))
			user = usr

		if(is_incapacitated(user) || !(src.loc in user.equipped_list()))
			return

		switch (action)
			if ("reset_scale")
				if (istype(src.minimap_datum, /datum/minimap/z_level))
					var/datum/minimap/z_level/minimap = src.minimap_datum
					minimap.find_focal_point()

			// if ("new_marker")

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

			if ("delete_marker")
				var/list/list_entry = src.minimap_markers_list[params["index"]]
				var/datum/minimap_marker/marker = list_entry["marker"]
				src.minimap_datum.remove_minimap_marker(marker.target)

		return TRUE

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
