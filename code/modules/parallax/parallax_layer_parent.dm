/atom/movable/screen/parallax_layer
	plane = PLANE_PARALLAX
	appearance_flags = KEEP_TOGETHER | TILE_BOUND
	screen_loc = "CENTER,CENTER"

	/// The client that this parallax layer belongs to.
	var/client/owner

	/// The icon file that the icon for each tile of the parallax layer will draw from.
	var/parallax_icon = 'icons/misc/parallax.dmi'
	/// The icon state that the icon for each tile of the parallax layer will use.
	var/parallax_icon_state

	/// The width of the icon to be used for each tile of the parallax layer, stored as to save processing time.
	var/icon_width
	/// The height of the icon to be used for each tile of the parallax layer, stored as to save processing time.
	var/icon_height

	/// If set to TRUE, this parallax layer will retain its original colour when `recolour_parallax_layers()` is called.
	var/static_colour = FALSE

	/**
	 * How much the parallax layer should move in response to the player moving;
	 * - Negative values will result in the layer moving in the same direction as the player.
	 * - A value of 0 will result in the layer appearing stationary relative to the player.
	 * - A value of 0.5 will result in the layer moving half the number of pixels that the player moves.
	 * - A value of 1 will result in the layer appearing stationary relative to the station.
	 * - Values greater than 1 will result in the layer moving faster than the player.
	 */
	var/parallax_value = 0

	/// The non-parallax-adjusted speed at which the parallax layer should move. The real speed may be derived through `scroll_speed * parallax_value`.
	var/scroll_speed = 0
	/// The compass bearing, in degrees, in which the parallax layer is to move. North: 0/360, East: 90, South: 180, West: 270.
	var/scroll_angle = 0

	/// Whether the selected icon for the parallax layer should tessellate across the client's screen.
	var/tessellate = TRUE

	/// The x coordinate at which the parallax layer will be centred in the x-axis on the client's screen. Has no effect on layers set to tessellate.
	var/initial_x_coordinate = 150
	/// The y coordinate at which the parallax layer will be centred in the y-axis on the client's screen. Has no effect on layers set to tessellate.
	var/initial_y_coordinate = 150

	/// The initial x pixel offset required to centre the layer on the client's screen.
	var/initial_pixel_x_offset = 0
	/// The initial y pixel offset required to centre the layer on the client's screen.
	var/initial_pixel_y_offset = 0

	/// The x pixel offset required for a scrolling layer to remain within the boundaries of a client's screen.
	var/animation_pixel_x_offset = 0
	/// The x pixel offset required for a scrolling layer to remain within the boundaries of a client's screen.
	var/animation_pixel_y_offset = 0

	New(turf/newLoc, new_owner, list/params)
		. = ..()

		if (length(params))
			if (params["parallax_icon"])
				src.parallax_icon = params["parallax_icon"]
			if (params["parallax_icon_state"])
				src.parallax_icon_state = params["parallax_icon_state"]
			if (params["static_colour"])
				src.static_colour = params["static_colour"]
			if (params["parallax_value"])
				src.parallax_value = params["parallax_value"]
			if (params["scroll_speed"])
				src.scroll_speed = params["scroll_speed"]
			if (params["scroll_angle"])
				src.scroll_angle = params["scroll_angle"]
			if (params["tessellate"])
				src.tessellate = params["tessellate"]
			if (params["initial_x_coordinate"])
				src.initial_x_coordinate = params["initial_x_coordinate"]
			if (params["initial_y_coordinate"])
				src.initial_y_coordinate = params["initial_y_coordinate"]

		src.owner = new_owner
		src.layer += (src.parallax_value / 10)

		var/icon/icon = icon(src.parallax_icon, src.parallax_icon_state)
		src.icon_width = icon.Width()
		src.icon_height = icon.Height()

		src.tessellate()
		src.offset_layer()
		src.scroll_layer()

	/// Realigns the parallax layer so that the centremost tessellated tile occupies the position of the tessellated tile closest to the player.
	proc/update_tessellation_alignment()
		if (!src.tessellate)
			return

		var/pixel_x_offset = 0
		var/pixel_y_offset = 0

		if(src.transform.c + src.animation_pixel_x_offset > 0)
			pixel_x_offset -= src.icon_width

		else if(src.transform.c + src.animation_pixel_x_offset < -(src.icon_width))
			pixel_x_offset += src.icon_width

		if(src.transform.f + src.animation_pixel_y_offset > 0)
			pixel_y_offset -= src.icon_height

		else if(src.transform.f + src.animation_pixel_y_offset < -(src.icon_height))
			pixel_y_offset += src.icon_height

		if (pixel_x_offset || pixel_y_offset)
			src.transform = src.transform.Translate(pixel_x_offset, pixel_y_offset)

	/// If the parallax layer is set to tessellate, duplicates and offsets the selected icon for the parallax layer, so that the layer appears as a seamless image.
	proc/tessellate()
		if (!src.owner || !src.owner.view)
			return

		if (!src.tessellate)
			src.overlays = list()
			src.overlays += mutable_appearance(src.parallax_icon, src.parallax_icon_state, src.layer, src.plane)
			return

		var/x_tessellations
		var/y_tessellations

		if (istext(src.owner.view))
			var/list/viewSizes = splittext(src.owner.view, "x")
			x_tessellations = round((text2num(viewSizes[1]) / (src.icon_height / world.icon_size)) / 2) + 1
			y_tessellations = round((text2num(viewSizes[2]) / (src.icon_width / world.icon_size)) / 2) + 1

		else
			x_tessellations = round((src.owner.view / (src.icon_height / world.icon_size)) / 2) + 1
			y_tessellations = round((src.owner.view / (src.icon_width / world.icon_size)) / 2) + 1

		var/list/new_overlays = list()
		for(var/x in -x_tessellations to x_tessellations)
			for(var/y in -y_tessellations to y_tessellations)
				var/mutable_appearance/texture_overlay = mutable_appearance(src.parallax_icon, src.parallax_icon_state, src.layer, src.plane)
				texture_overlay.transform = matrix(1, 0, (x * src.icon_height), 0, 1, (y * src.icon_width))
				new_overlays += texture_overlay

		src.overlays = new_overlays

	/// Offsets the parallax layer using a transformation to either appear in the centre of the client's screen, or appear centred when the client is at the initial x and y coordinates.
	proc/offset_layer()
		src.initial_pixel_x_offset = round((src.icon_width / 2) * -1, 1)
		src.initial_pixel_y_offset = round((src.icon_height / 2) * -1, 1)

		var/turf/current_turf = get_turf(src.owner.eye)
		if (!src.tessellate)
			// Offset the parallax layer so that it will be centred on the client's screen when they are at the initial x and y coordinates.
			src.initial_pixel_x_offset += round((src.initial_x_coordinate - current_turf.x) * world.icon_size * src.parallax_value, 1)
			src.initial_pixel_y_offset += round((src.initial_y_coordinate - current_turf.y) * world.icon_size * src.parallax_value, 1)

			src.transform = matrix(1, 0, src.initial_pixel_x_offset, 0, 1, src.initial_pixel_y_offset)

		else
			// Offset the parallax layer as to maintain a consistant offset between `offset_layer()` calls, as opposed to resetting the layer to the middle of the client's screen.
			var/pixel_x_offset = round((src.initial_x_coordinate - current_turf.x) * world.icon_size * src.parallax_value, 1) % src.icon_width
			var/pixel_y_offset = round((src.initial_y_coordinate - current_turf.y) * world.icon_size * src.parallax_value, 1) % src.icon_height

			src.transform = matrix(1, 0, src.initial_pixel_x_offset + pixel_x_offset, 0, 1, src.initial_pixel_y_offset + pixel_y_offset)

		src.update_tessellation_alignment()

	/// Animates the parallax layer so that it appears to be infinitely moving in one direction, using the `scroll_speed`, `parallax_value`, and `scroll_angle` variables.
	proc/scroll_layer()
		if (!src.tessellate || (!src.scroll_speed && !src.scroll_angle))
			return

		var/x = src.scroll_speed * src.parallax_value * sin(src.scroll_angle)
		if (x)
			var/x_direction = x / abs(x)
			var/animation_time_x = (abs(src.icon_width / x) / 2) SECONDS
			src.animation_pixel_x_offset = src.icon_width * x_direction / -2
			animate(src, 0, -1, transform = matrix(1, 0, src.animation_pixel_x_offset, 0, 1, 0), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
			animate(time = animation_time_x, transform = matrix(1, 0, src.icon_width * x_direction, 0, 1, 0), flags = ANIMATION_RELATIVE)

		var/y = src.scroll_speed * src.parallax_value * cos(src.scroll_angle)
		if (y)
			var/y_direction = y / abs(y)
			var/animation_time_y = (abs(src.icon_height / y) / 2) SECONDS
			src.animation_pixel_y_offset = src.icon_height * y_direction / -2
			animate(src, 0, -1, transform = matrix(1, 0, 0, 0, 1, src.animation_pixel_y_offset), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
			animate(time = animation_time_y, transform = matrix(1, 0, 0, 0, 1, src.icon_height * y_direction), flags = ANIMATION_RELATIVE)
