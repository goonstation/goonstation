/**
 *	Parallax render sources are screens that hold the appearance data for a specific type of parallax layer; this appearance
 *	is then drawn to client parallax layers using render targets and sources. This permits the appearance of a specific parallax
 *	layer to be edited at runtime and efficiently distributed across all applicable clients.
 */
/atom/movable/screen/parallax_render_source
	plane = PLANE_PARALLAX
	appearance_flags = KEEP_TOGETHER | TILE_BOUND
	screen_loc = "CENTER,CENTER"

	name = null
	desc = null

	///Is this a celestial feature that shows up on PDA space GPS programs
	var/visible_to_gps = FALSE

	/// The icon file that the icon for each tile of the parallax layer will draw from.
	var/parallax_icon = 'icons/misc/parallax.dmi'
	/// The icon state that the icon for each tile of the parallax layer will use.
	var/parallax_icon_state

	/// The width of the icon to be used for each tile of the parallax layer, stored as to save processing time.
	var/icon_width
	/// The height of the icon to be used for each tile of the parallax layer, stored as to save processing time.
	var/icon_height

	/// If set to TRUE, the parallax layer render source will retain its original colour when `/proc/recolour_parallax_render_sources()` is called.
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

/atom/movable/screen/parallax_render_source/New()
	. = ..()

	src.render_target = "*\ref[src]"

	src.layer += (src.parallax_value / 10)

	var/icon/icon = icon(src.parallax_icon, src.parallax_icon_state)
	src.icon_width = icon.Width()
	src.icon_height = icon.Height()

	src.tessellate()

/// If the parallax render source is set to tessellate, duplicates and offsets the selected icon for the parallax render source, so that the render source appears as a seamless image.
/atom/movable/screen/parallax_render_source/proc/tessellate()
	if (!src.tessellate)
		src.overlays = list()
		src.overlays += mutable_appearance(src.parallax_icon, src.parallax_icon_state, src.layer, src.plane)
		return

	var/x_tessellations = round((WIDE_TILE_WIDTH / (src.icon_height / world.icon_size)) / 2) + 1
	var/y_tessellations = round((SQUARE_TILE_WIDTH / (src.icon_width / world.icon_size)) / 2) + 1

	var/list/new_overlays = list()
	for(var/x in -x_tessellations to x_tessellations)
		for(var/y in -y_tessellations to y_tessellations)
			var/mutable_appearance/texture_overlay = mutable_appearance(src.parallax_icon, src.parallax_icon_state, src.layer, src.plane)
			texture_overlay.transform = matrix(1, 0, (x * src.icon_height), 0, 1, (y * src.icon_width))
			new_overlays += texture_overlay

	src.overlays = new_overlays
