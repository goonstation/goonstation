var/global/parallax_enabled = TRUE
/datum/parallax_controller
	/// The client that this parallax controller belongs to.
	var/client/owner
	/// The various parallax layers displayed on the client's screen.
	var/list/atom/movable/screen/parallax_layer/parallax_layers
	/// The turf that the client's eye was centred upon when `update_parallax_layers()` was last called.
	var/turf/previous_turf
	/// The outermost atom/movable in the client's mob's .loc chain.
	var/atom/movable/outermost_movable

	/// A list of each z-level define and it's associated parallax layers.
	var/list/z_level_parallax_layers

	New(turf/newLoc, new_owner)
		. = ..()
		src.owner = new_owner
		src.parallax_layers = list()
		src.outermost_movable = src.owner.mob
		src.setup_z_level_parallax_layers()

	/// Updates the position of the parallax layer relative to the client's eye, taking into account the distance moved and the parallax value.
	proc/update_parallax_layers(turf/previous_turf, turf/current_turf)
		if (!isturf(previous_turf) || !isturf(current_turf))
			return

		// Calculate the number of tiles the client's eye has moved, in pixels.
		var/x_pixel_change = round((previous_turf.x - current_turf.x) * world.icon_size, 1)
		var/y_pixel_change = round((previous_turf.y - current_turf.y) * world.icon_size, 1)

		src.previous_turf = current_turf

		var/animation_time = 0
		if (src.outermost_movable?.glide_size)
			// The time it takes for an atom/movable to move one tile.
			animation_time = (world.icon_size / src.outermost_movable.glide_size) * world.tick_lag

		for (var/atom/movable/screen/parallax_layer/parallax_layer as anything in src.parallax_layers)
			if (!parallax_layer.parallax_value)
				continue

			// Multiply the pixel change by the parallax value to determine the number of pixels the layer should move by.
			// Update the position of the parallax layer on the client's screen, and animate the movement, using a time value derived from the client's mob's speed.
			animate(parallax_layer, animation_time, transform = matrix(1, 0, x_pixel_change * parallax_layer.parallax_value, 0, 1, y_pixel_change * parallax_layer.parallax_value), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)

			// Check whether the layer should be realigned on the client's screen.
			parallax_layer.update_tessellation_alignment()

	/// Populates `parallax_layers` with a list of parallax layers to be displayed to the client, depending on the client's mob's current z-level.
	proc/update_parallax_z()
		src.owner.screen -= src.parallax_layers

		src.previous_turf = get_turf(src.owner.eye)
		if (!src.previous_turf || !("[src.previous_turf.z]" in src.z_level_parallax_layers))
			src.parallax_layers = list()

		else
			src.parallax_layers = src.z_level_parallax_layers["[src.previous_turf.z]"]

			for (var/atom/movable/screen/parallax_layer/parallax_layer in src.parallax_layers)
				parallax_layer.offset_layer()

		src.owner.screen |= src.parallax_layers

	/// Populates `z_level_parallax_layers` with a list of parallax layers corresponding to each z-level.
	proc/setup_z_level_parallax_layers()
		src.z_level_parallax_layers = list()

		for (var/z_level in Z_LEVEL_NULL to Z_LEVEL_MINING)
			var/list/atom/movable/screen/parallax_layer/z_parallax_layers = list()
			for (var/parallax_layer_type as anything in z_level_parallax_settings["[z_level]"])
				z_parallax_layers += new parallax_layer_type(null, src.owner)

			src.z_level_parallax_layers["[z_level]"] = z_parallax_layers

	/// Updates the parallax layers displayed to a client by an area.
	proc/update_area_parallax_layers(area/old_area, area/new_area)
		if (old_area && new_area && (old_area.area_parallax_layers ~= new_area.area_parallax_layers))
			return

		if (old_area)
			src.remove_parallax_layer(old_area.area_parallax_layers, z_level = old_area.z)

		if (new_area)
			src.add_parallax_layer(new_area.area_parallax_layers, z_level = new_area.z)

	/// Creates a new parallax layer of the specified type, or various layers should `parallax_layer_type_or_types` be a list, on the specified z-level.
	proc/add_parallax_layer(parallax_layer_type_or_types, animation_time = 0, z_level = Z_LEVEL_STATION, list/layer_params)
		var/list/parallax_layer_types
		if (islist(parallax_layer_type_or_types))
			parallax_layer_types = parallax_layer_type_or_types
		else if (ispath(parallax_layer_type_or_types))
			parallax_layer_types = list(parallax_layer_type_or_types)

		if(isnull(src.z_level_parallax_layers["[z_level]"]))
			src.z_level_parallax_layers["[z_level]"] = list()

		var/list/parallax_layer_list = src.z_level_parallax_layers["[z_level]"]
		for (var/parallax_layer_type in parallax_layer_types)
			if(parallax_layer_types[parallax_layer_type])
				layer_params = parallax_layer_types[parallax_layer_type]
			var/atom/movable/screen/parallax_layer/parallax_layer = new parallax_layer_type(null, src.owner, layer_params)
			parallax_layer_list += parallax_layer

			parallax_layer.alpha = 0
			animate(parallax_layer, animation_time, alpha = 255, flags = ANIMATION_PARALLEL)

		if (src.previous_turf && (src.previous_turf.z == z_level))
			src.owner.screen -= src.parallax_layers
			src.parallax_layers = parallax_layer_list
			src.owner.screen |= src.parallax_layers

	/// Removes all parallax layers of a specified type, or various types should `parallax_layer_type_or_types` be a list, not including children types, from a specified z-level.
	proc/remove_parallax_layer(parallax_layer_type_or_types, animation_time = 0, z_level = Z_LEVEL_STATION)
		var/list/parallax_layer_types
		if (islist(parallax_layer_type_or_types))
			parallax_layer_types = parallax_layer_type_or_types
		else if (ispath(parallax_layer_type_or_types))
			parallax_layer_types = list(parallax_layer_type_or_types)


		var/list/parallax_layer_list = src.z_level_parallax_layers["[z_level]"]
		for (var/atom/movable/screen/parallax_layer/parallax_layer as anything in parallax_layer_list)
			if (parallax_layer.type in parallax_layer_types)
				animate(parallax_layer, animation_time, alpha = 0, flags = ANIMATION_PARALLEL)

				SPAWN(animation_time)
					parallax_layer_list -= parallax_layer
					qdel(parallax_layer)

		SPAWN(animation_time + 1)
			if (src.previous_turf && (src.previous_turf.z == z_level))
				src.owner.screen -= src.parallax_layers
				src.parallax_layers = parallax_layer_list
				src.owner.screen |= src.parallax_layers

	/// Applies the provided colour matrix to all eligible parallax layers on the specified z-level, and animates the transition.
	proc/recolour_parallax_layers(list/colour, animation_time = 0, z_level = Z_LEVEL_STATION)
		if (!colour)
			return

		for (var/atom/movable/screen/parallax_layer/parallax_layer in src.z_level_parallax_layers["[z_level]"])
			if (parallax_layer.static_colour)
				continue

			animate(parallax_layer, animation_time, color = colour, flags = ANIMATION_PARALLEL)





/client
	var/datum/parallax_controller/parallax_controller

	New()
		. = ..()
		src.toggle_parallax()


/mob/Login()
	. = ..()
	src.register_parallax_signals()

/mob/Logout()
	src.unregister_parallax_signals()
	. = ..()

/mob/proc/register_parallax_signals()
	if (src.client?.parallax_controller)
		RegisterSignal(src, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(update_parallax))
		RegisterSignal(src, XSIG_MOVABLE_AREA_CHANGED, PROC_REF(update_area_parallax))
		RegisterSignal(src, XSIG_MOVABLE_Z_CHANGED, PROC_REF(update_parallax_z))
		RegisterSignal(src, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(update_outermost_movable))

		var/datum/component/complexsignal/outermost_movable/C = src.GetComponent(/datum/component/complexsignal/outermost_movable)
		src.client.parallax_controller.outermost_movable = C.get_outermost_movable()
		src.update_area_parallax(null, get_area(src.client.parallax_controller.previous_turf), get_area(src))
		src.update_parallax_z()

/mob/proc/unregister_parallax_signals()
	if (src.GetComponent(/datum/component/complexsignal/outermost_movable))
		UnregisterSignal(src, XSIG_MOVABLE_TURF_CHANGED)
		UnregisterSignal(src, XSIG_MOVABLE_AREA_CHANGED)
		UnregisterSignal(src, XSIG_MOVABLE_Z_CHANGED)
		UnregisterSignal(src, XSIG_OUTERMOST_MOVABLE_CHANGED)

/mob/proc/update_parallax(datum/component/component, turf/old_turf, turf/new_turf)
	src.client?.parallax_controller?.update_parallax_layers(old_turf, new_turf)

/mob/proc/update_parallax_z()
	src.client?.parallax_controller?.update_parallax_z()

/mob/proc/update_area_parallax(datum/component/component, area/old_area, area/new_area)
	src.client?.parallax_controller?.update_area_parallax_layers(old_area, new_area)

/mob/proc/update_outermost_movable(datum/component/component, atom/movable/old_outermost, atom/movable/new_outermost)
	src.client?.parallax_controller?.outermost_movable = new_outermost
