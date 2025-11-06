/datum/parallax_controller
	/// The client that this parallax controller belongs to.
	var/client/owner
	/// An associative list of the parallax render sources and their corresponding layers displayed on the client's screen.
	var/list/atom/movable/screen/parallax_render_source/parallax_render_sources
	/// The various parallax layers displayed on the client's screen that will require to be updated when the client's mob moves.
	var/list/atom/movable/screen/parallax_layer/parallax_layers
	/// A list of all the render source groups that the client is currently a member of.
	var/list/datum/parallax_render_source_group/render_source_groups
	/// The z-level that the outermost movable was in when `update_z_level_parallax_layers()` was last called.
	var/previous_z_level
	/// The area that the outermost movable was in when `update_area_parallax_layers()` was last called.
	var/area/previous_area
	/// The turf that the client's eye was centred upon when `update_parallax_layers()` was last called.
	var/turf/previous_turf
	/// The outermost atom/movable in the client's mob's .loc chain.
	var/atom/movable/outermost_movable

/datum/parallax_controller/New(client/new_owner)
	. = ..()

	src.owner = new_owner
	src.parallax_render_sources = list()
	src.parallax_layers = list()
	src.render_source_groups = list()

	src.RegisterSignal(src.owner, COMSIG_CLIENT_LOGIN, PROC_REF(register_signals))
	src.RegisterSignal(src.owner, COMSIG_CLIENT_LOGOUT, PROC_REF(unregister_signals))
	src.register_signals(src.owner, src.owner.mob)

/datum/parallax_controller/disposing()
	src.unregister_signals(src.owner, src.owner.mob)
	src.UnregisterSignal(src.owner, COMSIG_CLIENT_LOGIN)
	src.UnregisterSignal(src.owner, COMSIG_CLIENT_LOGOUT)

	src.remove_parallax_layer(src.parallax_render_sources)

	for (var/datum/parallax_render_source_group/render_source_group as anything in src.render_source_groups)
		render_source_group.members -= src.owner

	src.owner.parallax_controller = null
	src.owner = null

	. = ..()

/// Updates the position of the parallax layer relative to the client's eye, taking into account the distance moved and the parallax value.
/datum/parallax_controller/proc/update_parallax_layers(datum/component/component, turf/previous_turf, turf/current_turf)
	if (!isturf(previous_turf) || !isturf(current_turf))
		return

	// Calculate the number of tiles the client's eye has moved, in pixels.
	var/x_pixel_change = round((previous_turf.x - current_turf.x) * world.icon_size, 1)
	var/y_pixel_change = round((previous_turf.y - current_turf.y) * world.icon_size, 1)

	src.previous_turf = current_turf

	var/animation_time = 0
	if (src.outermost_movable.glide_size)
		// The time it takes for an atom/movable to move one tile.
		animation_time = (world.icon_size / src.outermost_movable.glide_size) * world.tick_lag

	for (var/atom/movable/screen/parallax_layer/parallax_layer as anything in src.parallax_layers)
		// Multiply the pixel change by the parallax value to determine the number of pixels the layer should move by.
		// Update the position of the parallax layer on the client's screen, and animate the movement, using a time value derived from the client's mob's speed.
		// Round to 1s to not blur sprites
		animate( \
			parallax_layer, \
			animation_time, \
			transform = matrix(	1, 0, round(x_pixel_change * parallax_layer.parallax_render_source.parallax_value, 1), \
								0, 1, round(y_pixel_change * parallax_layer.parallax_render_source.parallax_value, 1)), \
			flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE \
		)

		// Check whether the layer should be realigned on the client's screen.
		UPDATE_TESSELLATION_ALIGNMENT(parallax_layer)

/// Updates the parallax render sources and layers displayed to a client by a z-level.
/datum/parallax_controller/proc/update_z_level_parallax_layers(datum/component/component, old_z_level, new_z_level)
	var/datum/parallax_render_source_group/old_render_source_group = get_parallax_render_source_group(src.previous_z_level)
	var/datum/parallax_render_source_group/new_render_source_group = get_parallax_render_source_group(new_z_level)
	src.previous_z_level = new_z_level

	if (old_render_source_group == new_render_source_group)
		return

	if (old_render_source_group)
		src.remove_parallax_layer(old_render_source_group.parallax_render_sources)
		src.render_source_groups -= old_render_source_group
		old_render_source_group.members -= src.owner

	if (new_render_source_group)
		src.add_parallax_layer(new_render_source_group.parallax_render_sources)
		src.render_source_groups += new_render_source_group
		new_render_source_group.members += src.owner

/// Updates the parallax render sources and layers displayed to a client by an area.
/datum/parallax_controller/proc/update_area_parallax_layers(datum/component/component, area/old_area, area/new_area)
	var/datum/parallax_render_source_group/old_render_source_group = get_parallax_render_source_group(src.previous_area)
	var/datum/parallax_render_source_group/new_render_source_group = get_parallax_render_source_group(new_area)
	src.previous_area = new_area

	if (old_render_source_group == new_render_source_group)
		return

	if (old_render_source_group)
		src.remove_parallax_layer(old_render_source_group.parallax_render_sources)
		src.render_source_groups -= old_render_source_group
		old_render_source_group.members -= src.owner

	if (new_render_source_group)
		src.add_parallax_layer(new_render_source_group.parallax_render_sources)
		src.render_source_groups += new_render_source_group
		new_render_source_group.members += src.owner

/// Creates a new parallax layer for every provided parallax layer render source.
/datum/parallax_controller/proc/add_parallax_layer(list/parallax_layer_render_sources)
	for (var/atom/movable/screen/parallax_render_source/render_source as anything in parallax_layer_render_sources)
		if (!isnull(src.parallax_render_sources[render_source]))
			continue

		var/atom/movable/screen/parallax_layer/parallax_layer = new /atom/movable/screen/parallax_layer(null, src.owner, render_source)
		src.parallax_render_sources[render_source] = parallax_layer
		if (parallax_layer.parallax_render_source.parallax_value)
			src.parallax_layers += parallax_layer

		src.owner.screen += render_source
		src.owner.screen += parallax_layer

/// Creates a new parallax layer for every provided parallax layer render source.
/datum/parallax_controller/proc/recalculate_parallax_layer(atom/movable/screen/parallax_render_source/render_source)
	if(render_source in src.parallax_render_sources)
		var/atom/movable/screen/parallax_layer/parallax_layer = src.parallax_render_sources[render_source]

		parallax_layer.offset_layer()
		parallax_layer.scroll_layer()
		UPDATE_TESSELLATION_ALIGNMENT(parallax_layer)

/// Removes the parallax layers corresponding to the provided parallax layer render sources.
/datum/parallax_controller/proc/remove_parallax_layer(list/parallax_layer_render_sources)
	for (var/atom/movable/screen/parallax_render_source/render_source as anything in parallax_layer_render_sources)
		if (isnull(src.parallax_render_sources[render_source]))
			continue

		var/atom/movable/screen/parallax_layer/parallax_layer = src.parallax_render_sources[render_source]
		src.parallax_render_sources -= render_source
		src.parallax_layers -= parallax_layer

		src.owner.screen -= render_source
		src.owner.screen -= parallax_layer

/datum/parallax_controller/proc/update_outermost_movable(datum/component/component, atom/movable/old_outermost, atom/movable/new_outermost)
	src.outermost_movable = new_outermost

/datum/parallax_controller/proc/register_signals(client/C, mob/M)
	src.RegisterSignal(M, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(update_parallax_layers))
	src.RegisterSignal(M, XSIG_MOVABLE_AREA_CHANGED, PROC_REF(update_area_parallax_layers))
	src.RegisterSignal(M, XSIG_MOVABLE_Z_CHANGED, PROC_REF(update_z_level_parallax_layers))
	src.RegisterSignal(M, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(update_outermost_movable))

	src.outermost_movable = global.outermost_movable(M)
	src.update_area_parallax_layers(null, null, get_area(src.outermost_movable))
	src.update_z_level_parallax_layers(null, null, src.outermost_movable.z)

/datum/parallax_controller/proc/unregister_signals(client/C, mob/M)
	if (!M?.GetComponent(/datum/component/complexsignal/outermost_movable))
		return

	src.UnregisterSignal(M, XSIG_MOVABLE_TURF_CHANGED)
	src.UnregisterSignal(M, XSIG_MOVABLE_AREA_CHANGED)
	src.UnregisterSignal(M, XSIG_MOVABLE_Z_CHANGED)
	src.UnregisterSignal(M, XSIG_OUTERMOST_MOVABLE_CHANGED)

/client/var/datum/parallax_controller/parallax_controller

/client/New()
	. = ..()
	src.toggle_parallax()

/client/Del()
	qdel(src.parallax_controller)
	. = ..()
