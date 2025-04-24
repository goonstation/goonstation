/atom/movable/screen/parallax_layer
	plane = PLANE_PARALLAX
	appearance_flags = KEEP_TOGETHER | TILE_BOUND
	screen_loc = "CENTER,CENTER"
	mouse_opacity = 0

	/// The client that this parallax layer belongs to.
	var/client/owner

	/// The parallax render source that this layer should use, containing data on appearance, parallax value, scroll speed, and so forth.
	var/atom/movable/screen/parallax_render_source/parallax_render_source

	/// The initial x pixel offset required to centre the layer on the client's screen.
	var/initial_pixel_x_offset = 0
	/// The initial y pixel offset required to centre the layer on the client's screen.
	var/initial_pixel_y_offset = 0

	/// The x pixel offset required for a scrolling layer to remain within the boundaries of a client's screen.
	var/animation_pixel_x_offset = 0
	/// The y pixel offset required for a scrolling layer to remain within the boundaries of a client's screen.
	var/animation_pixel_y_offset = 0

/atom/movable/screen/parallax_layer/New(turf/newLoc, new_owner, parallax_render_source)
	. = ..()

	src.parallax_render_source = parallax_render_source
	src.render_source = src.parallax_render_source.render_target

	src.plane = src.parallax_render_source.plane
	src.blend_mode = src.parallax_render_source.blend_mode

	src.owner = new_owner
	src.layer += (src.parallax_render_source.parallax_value / 10)
	src.offset_layer()
	src.scroll_layer()

/// Offsets the parallax layer using a transformation to either appear in the centre of the client's screen, or appear centred when the client is at the initial x and y coordinates.
/atom/movable/screen/parallax_layer/proc/offset_layer()
	src.initial_pixel_x_offset = round((src.parallax_render_source.icon_width / 2) * -1, 1)
	src.initial_pixel_y_offset = round((src.parallax_render_source.icon_height / 2) * -1, 1)

	var/turf/current_turf = get_turf(src.owner.eye)
	if (!src.parallax_render_source.tessellate)
		// Offset the parallax layer so that it will be centred on the client's screen when they are at the initial x and y coordinates.
		src.initial_pixel_x_offset += round((src.parallax_render_source.initial_x_coordinate - current_turf.x) * world.icon_size * src.parallax_render_source.parallax_value, 1)
		src.initial_pixel_y_offset += round((src.parallax_render_source.initial_y_coordinate - current_turf.y) * world.icon_size * src.parallax_render_source.parallax_value, 1)

		src.transform = matrix(1, 0, src.initial_pixel_x_offset, 0, 1, src.initial_pixel_y_offset)

	else
		// Offset the parallax layer as to maintain a consistant offset between `offset_layer()` calls, as opposed to resetting the layer to the middle of the client's screen.
		var/pixel_x_offset = round((src.parallax_render_source.initial_x_coordinate - current_turf.x) * world.icon_size * src.parallax_render_source.parallax_value, 1) % src.parallax_render_source.icon_width
		var/pixel_y_offset = round((src.parallax_render_source.initial_y_coordinate - current_turf.y) * world.icon_size * src.parallax_render_source.parallax_value, 1) % src.parallax_render_source.icon_height

		src.transform = matrix(1, 0, src.initial_pixel_x_offset + pixel_x_offset, 0, 1, src.initial_pixel_y_offset + pixel_y_offset)

	UPDATE_TESSELLATION_ALIGNMENT(src)

/// Animates the parallax layer so that it appears to be infinitely moving in one direction, using the `scroll_speed`, `parallax_value`, and `scroll_angle` variables.
/atom/movable/screen/parallax_layer/proc/scroll_layer()
	if (!src.parallax_render_source.tessellate || (!src.parallax_render_source.scroll_speed && !src.parallax_render_source.scroll_angle))
		return
	animate(src)
	var/x = src.parallax_render_source.scroll_speed * src.parallax_render_source.parallax_value * sin(src.parallax_render_source.scroll_angle)
	if (x)
		var/x_direction = x / abs(x)
		var/animation_time_x = (abs(src.parallax_render_source.icon_width / x) / 2) SECONDS
		src.animation_pixel_x_offset = src.parallax_render_source.icon_width * x_direction / -2
		animate(src, 0, -1, transform = matrix(1, 0, src.animation_pixel_x_offset, 0, 1, 0), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(time = animation_time_x, transform = matrix(1, 0, src.parallax_render_source.icon_width * x_direction, 0, 1, 0), flags = ANIMATION_RELATIVE)

	var/y = src.parallax_render_source.scroll_speed * src.parallax_render_source.parallax_value * cos(src.parallax_render_source.scroll_angle)
	if (y)
		var/y_direction = y / abs(y)
		var/animation_time_y = (abs(src.parallax_render_source.icon_height / y) / 2) SECONDS
		src.animation_pixel_y_offset = src.parallax_render_source.icon_height * y_direction / -2
		animate(src, 0, -1, transform = matrix(1, 0, 0, 0, 1, src.animation_pixel_y_offset), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(time = animation_time_y, transform = matrix(1, 0, 0, 0, 1, src.parallax_render_source.icon_height * y_direction), flags = ANIMATION_RELATIVE)
