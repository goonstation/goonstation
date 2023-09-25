/datum/parallax_controller
	/// The client that this parallax controller belongs to.
	var/client/owner
	/// An associative list of the parallax render sources and their corresponding layers displayed on the client's screen.
	var/list/atom/movable/screen/parallax_render_source/parallax_render_sources
	/// The various parallax layers displayed on the client's screen that will require to be updated when the client's mob moves.
	var/list/atom/movable/screen/parallax_layer/parallax_layers
	/// A list of all the render source groups that the client is currently a member of.
	var/list/datum/parallax_render_source_group/render_source_groups
	/// The turf that the client's eye was centred upon when `update_parallax_layers()` was last called.
	var/turf/previous_turf
	/// The outermost atom/movable in the client's mob's .loc chain.
	var/atom/movable/outermost_movable

/datum/parallax_controller/New(turf/newLoc, new_owner)
	. = ..()

	src.owner = new_owner
	src.parallax_render_sources = list()
	src.parallax_layers = list()
	src.render_source_groups = list()
	src.outermost_movable = src.owner.mob

/datum/parallax_controller/disposing()
	src.owner.parallax_controller = null
	src.remove_parallax_layer(src.parallax_render_sources)

	for (var/datum/parallax_render_source_group/render_source_group as anything in src.render_source_groups)
		render_source_group.members -= src.owner

	. = ..()

/// Updates the position of the parallax layer relative to the client's eye, taking into account the distance moved and the parallax value.
/datum/parallax_controller/proc/update_parallax_layers(turf/previous_turf, turf/current_turf)
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
		// Multiply the pixel change by the parallax value to determine the number of pixels the layer should move by.
		// Update the position of the parallax layer on the client's screen, and animate the movement, using a time value derived from the client's mob's speed.
		animate(parallax_layer, animation_time, transform = matrix(1, 0, x_pixel_change * parallax_layer.parallax_render_source.parallax_value, 0, 1, y_pixel_change * parallax_layer.parallax_render_source.parallax_value), flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)

		// Check whether the layer should be realigned on the client's screen.
		UPDATE_TESSELLATION_ALIGNMENT(parallax_layer)

/// Updates the parallax render sources and layers displayed to a client by a z-level.
/datum/parallax_controller/proc/update_parallax_z(old_z_level, new_z_level)
	var/datum/parallax_render_source_group/old_render_source_group = get_parallax_render_source_group(old_z_level)
	var/datum/parallax_render_source_group/new_render_source_group = get_parallax_render_source_group(new_z_level)

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
/datum/parallax_controller/proc/update_area_parallax_layers(area/old_area, area/new_area)
	var/datum/parallax_render_source_group/old_render_source_group = get_parallax_render_source_group(old_area)
	var/datum/parallax_render_source_group/new_render_source_group = get_parallax_render_source_group(new_area)

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





/client
	var/datum/parallax_controller/parallax_controller

/client/New()
	. = ..()
	src.toggle_parallax()

/mob/Login()
	. = ..()
	src.register_parallax_signals()

/mob/Logout()
	src.unregister_parallax_signals()
	. = ..()

/mob/proc/register_parallax_signals()
	if (!src.client?.parallax_controller)
		return

	RegisterSignal(src, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(update_parallax))
	RegisterSignal(src, XSIG_MOVABLE_AREA_CHANGED, PROC_REF(update_area_parallax))
	RegisterSignal(src, XSIG_MOVABLE_Z_CHANGED, PROC_REF(update_parallax_z))
	RegisterSignal(src, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(update_outermost_movable))

	var/datum/component/complexsignal/outermost_movable/C = src.GetComponent(/datum/component/complexsignal/outermost_movable)
	var/atom/movable/outermost_movable = C.get_outermost_movable()
	src.client.parallax_controller.outermost_movable = outermost_movable
	src.update_area_parallax(null, get_area(src.client.parallax_controller.previous_turf), get_area(outermost_movable))
	src.update_parallax_z(null, src.client.parallax_controller.previous_turf?.z, outermost_movable.z)

/mob/proc/unregister_parallax_signals()
	if (!src.GetComponent(/datum/component/complexsignal/outermost_movable))
		return

	UnregisterSignal(src, XSIG_MOVABLE_TURF_CHANGED)
	UnregisterSignal(src, XSIG_MOVABLE_AREA_CHANGED)
	UnregisterSignal(src, XSIG_MOVABLE_Z_CHANGED)
	UnregisterSignal(src, XSIG_OUTERMOST_MOVABLE_CHANGED)

/mob/proc/update_parallax(datum/component/component, turf/old_turf, turf/new_turf)
	src.client?.parallax_controller?.update_parallax_layers(old_turf, new_turf)

/mob/proc/update_parallax_z(datum/component/component, old_z_level, new_z_level)
	src.client?.parallax_controller?.update_parallax_z(old_z_level, new_z_level)

/mob/proc/update_area_parallax(datum/component/component, area/old_area, area/new_area)
	src.client?.parallax_controller?.update_area_parallax_layers(old_area, new_area)

/mob/proc/update_outermost_movable(datum/component/component, atom/movable/old_outermost, atom/movable/new_outermost)
	src.client?.parallax_controller?.outermost_movable = new_outermost
