/datum/parallax_controller
	/// The client that this parallax controller belongs to.
	var/client/owner
	/// The various parallax layers displayed on the client's screen.
	var/list/atom/movable/screen/parallax_layer/parallax_layers
	/// The turf that the client's eye was centred upon when `update_parallax_layers()` was last called.
	var/turf/previous_turf

	/// A list of each z-level define and it's associated parallax layers.
	var/list/z_level_parallax_layers

	New(turf/newLoc, new_owner)
		. = ..()
		src.owner = new_owner
		src.setup_z_level_parallax_layers()
		src.update_parallax_z()

	/// Updates the position of the parallax layer relative to the client's eye, taking into account the distance moved and the parallax value.
	proc/update_parallax_layers()
		var/turf/current_turf = get_turf(src.owner.eye)

		if (!current_turf)
			return

		if (!src.previous_turf)
			src.previous_turf = current_turf
			return

		// Calculate the number of tiles the parallax layers are to move, in pixels.
		var/x_pixel_change = round((src.previous_turf.x - current_turf.x) * world.icon_size, 1)
		var/y_pixel_change = round((src.previous_turf.y - current_turf.y) * world.icon_size, 1)

		if (!x_pixel_change && !y_pixel_change)
			return

		src.previous_turf = current_turf

		var/animation_time = 0
		if (src.owner?.mob?.glide_size)
			// The time it takes for a mob to move one tile.
			animation_time = (world.icon_size / src.owner.mob.glide_size) * world.tick_lag

		for (var/atom/movable/screen/parallax_layer/parallax_layer as anything in src.parallax_layers)
			if (!parallax_layer.parallax_value)
				continue

			// Multiply the pixel change by the parallax value to determine the number of pixels the layer should move by.
			var/layer_x_pixel_change = x_pixel_change * parallax_layer.parallax_value
			var/layer_y_pixel_change = y_pixel_change * parallax_layer.parallax_value

			// Update the position of the parallax layer on the client's screen, and animate the movement, using a time value derived from the client's mob's speed.
			animate(parallax_layer, animation_time, transform = matrix(1, 0, layer_x_pixel_change, 0, 1, layer_y_pixel_change), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)

			// Update the stored layer offset values and check whether the layer should be realigned on the client's screen.
			parallax_layer.pixel_x_offset += layer_x_pixel_change
			parallax_layer.pixel_y_offset += layer_y_pixel_change
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

			src.update_parallax_layers()

		src.owner.screen |= src.parallax_layers

	/// Populates `z_level_parallax_layers` with a list of parallax layers corresponding to each z-level.
	proc/setup_z_level_parallax_layers()
		src.z_level_parallax_layers = list()

		for (var/z_level in Z_LEVEL_NULL to Z_LEVEL_MINING)
			if (z_level == Z_LEVEL_STATION)
				var/list/atom/movable/screen/parallax_layer/station_parallax_layers = list()
				for (var/parallax_layer_type as anything in map_settings.parallax_layers)
					station_parallax_layers += new parallax_layer_type(null, src.owner)

				src.z_level_parallax_layers["[Z_LEVEL_STATION]"] = station_parallax_layers

			else
				var/list/atom/movable/screen/parallax_layer/z_parallax_layers = list()
				for (var/parallax_layer_type as anything in z_level_parallax_settings["[z_level]"])
					z_parallax_layers += new parallax_layer_type(null, src.owner)

				src.z_level_parallax_layers["[z_level]"] = z_parallax_layers

	/// Creates a new parallax layer of the specified type on the specified z-level.
	proc/add_parallax_layer(parallax_layer_type, animation_time = 0, z_level = Z_LEVEL_STATION, list/layer_params)
		var/atom/movable/screen/parallax_layer/parallax_layer = new parallax_layer_type(null, src.owner, layer_params)
		var/list/parallax_layer_list = src.z_level_parallax_layers["[z_level]"]
		parallax_layer_list += parallax_layer

		parallax_layer.alpha = 0
		animate(parallax_layer, animation_time, alpha = 255, flags = ANIMATION_PARALLEL)

		if (src.previous_turf.z == z_level)
			src.owner.screen -= src.parallax_layers
			src.parallax_layers = parallax_layer_list
			src.owner.screen |= src.parallax_layers

	/// Removes all parallax layers of a specified type, including children types, from a specified z-level.
	proc/remove_parallax_layer(parallax_layer_type, animation_time = 0, z_level = Z_LEVEL_STATION)
		var/list/parallax_layer_list = src.z_level_parallax_layers["[z_level]"]
		for (var/atom/movable/screen/parallax_layer/parallax_layer as anything in parallax_layer_list)
			if (istype(parallax_layer, parallax_layer_type))
				animate(parallax_layer, animation_time, alpha = 0, flags = ANIMATION_PARALLEL)

				SPAWN(animation_time)
					parallax_layer_list -= parallax_layer
					qdel(parallax_layer)

		SPAWN(animation_time + 1)
			if (src.previous_turf.z == z_level)
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

			/* BYOND v514.1589 Bug Notice:
			    An animation using a colour matrix as the colour value will not correctly animate should another animation be
				running in parallel. However, using non-matrix colour values will result in less-than-acceptable qualities of
				parallax layer recolouring, so I have opted to keep the matrix system and accept that it will occasionally
				skip the animation.
			*/
			animate(parallax_layer, animation_time, color = colour, flags = ANIMATION_PARALLEL)





/client
	var/datum/parallax_controller/parallax_controller

	New()
	 . = ..()
	 src.parallax_controller = new(null, src)


/mob/New()
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/update_parallax)
	RegisterSignal(src, COMSIG_MOB_MOVE_VEHICLE, .proc/update_parallax)
	RegisterSignal(src, COMSIG_MOVABLE_SET_LOC, .proc/update_parallax)

	RegisterSignal(src, XSIG_MOVABLE_Z_CHANGED, .proc/update_parallax_z)

/mob/disposing()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src, COMSIG_MOB_MOVE_VEHICLE)
	UnregisterSignal(src, COMSIG_MOVABLE_SET_LOC)

	UnregisterSignal(src, XSIG_MOVABLE_Z_CHANGED)
	. = ..()

/mob/proc/update_parallax()
	src.client?.parallax_controller?.update_parallax_layers()

	for (var/mob/dead/target_observer/observer in observers)
		observer.client?.parallax_controller?.update_parallax_layers()

/mob/proc/update_parallax_z()
	src.client?.parallax_controller?.update_parallax_z()
