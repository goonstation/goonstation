/atom/movable/screen/parallax_layer
	plane = PLANE_PARALLAX
	appearance_flags = TILE_BOUND
	mouse_opacity = 0

	/// The client that this parallax layer belongs to.
	var/client/owner = null
	/// The parallax render source that this layer should use, containing data on appearance, parallax value, scroll speed, and so forth.
	var/atom/movable/screen/parallax_render_source/parallax_render_source = null

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

/// Offsets the parallax layer to appear centred when the client is at the initial x and y coordinates.
/atom/movable/screen/parallax_layer/proc/offset_layer()
	var/turf/T = get_turf(src.owner.eye)
	var/x_offset = round((src.parallax_render_source.initial_x_coordinate - T.x) * world.icon_size * src.parallax_render_source.parallax_value, 1)
	var/y_offset = round((src.parallax_render_source.initial_y_coordinate - T.y) * world.icon_size * src.parallax_render_source.parallax_value, 1)

	// Offset the parallax layer so that it will be centred on the client's screen when they are at the initial x and y coordinates.
	if (!src.parallax_render_source.tessellate)
		src.pixel_x = x_offset - round(src.parallax_render_source.icon_width / 2, 1)
		src.pixel_y = y_offset - round(src.parallax_render_source.icon_height / 2, 1)

	// Offset the parallax layer as to maintain a consistant offset between `offset_layer()` calls, as opposed to resetting the layer to the middle of the client's screen.
	else
		src.pixel_x = world.icon_size - src.parallax_render_source.icon_width
		src.pixel_y = world.icon_size - src.parallax_render_source.icon_height

		src.pixel_w = x_offset
		src.pixel_z = y_offset
		UPDATE_TESSELLATION_ALIGNMENT(src)

/// Animates the parallax layer so that it appears to be infinitely moving in one direction, using the `scroll_speed`, `parallax_value`, and `scroll_angle` variables.
/atom/movable/screen/parallax_layer/proc/scroll_layer()
	if (!src.parallax_render_source.tessellate || (!src.parallax_render_source.scroll_speed && !src.parallax_render_source.scroll_angle))
		return

	animate(src)

	var/x = src.parallax_render_source.scroll_speed * src.parallax_render_source.parallax_value * sin(src.parallax_render_source.scroll_angle)
	if (x)
		var/x_direction = sign(x)
		var/x_offset = src.parallax_render_source.icon_width / 2
		var/x_time = (x_offset / abs(x)) SECONDS

		animate(src, 0, -1, transform = matrix(1, 0, x_offset * -x_direction, 0, 1, 0), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(time = x_time, transform = matrix(1, 0, src.parallax_render_source.icon_width * x_direction, 0, 1, 0), flags = ANIMATION_RELATIVE)

	var/y = src.parallax_render_source.scroll_speed * src.parallax_render_source.parallax_value * cos(src.parallax_render_source.scroll_angle)
	if (y)
		var/y_direction = sign(y)
		var/y_offset = src.parallax_render_source.icon_height / 2
		var/y_time = (y_offset / abs(y)) SECONDS

		animate(src, 0, -1, transform = matrix(1, 0, 0, 0, 1, y_offset * -y_direction), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(time = y_time, transform = matrix(1, 0, 0, 0, 1, src.parallax_render_source.icon_height * y_direction), flags = ANIMATION_RELATIVE)
