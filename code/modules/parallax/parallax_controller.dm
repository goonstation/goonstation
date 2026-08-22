/datum/parallax_controller
	/// The client that this parallax controller belongs to.
	var/client/owner = null
	/// The screen object that all parallax layers are rendered on.
	var/atom/movable/screen/parallax_anchor/anchor = null
	/// An associative list of the parallax render sources and their corresponding layers displayed on the parallax anchor.
	var/list/atom/movable/screen/parallax_render_source/parallax_render_sources = null
	/// The various parallax layers displayed on the parallax anchor that will require to be updated when the client's mob moves.
	var/list/atom/movable/screen/parallax_layer/parallax_layers = null
	/// A list of all the render source groups that the client is currently a member of.
	var/list/datum/parallax_render_source_group/render_source_groups = null
	/// The outermost atom/movable in the client's mob's .loc chain.
	var/atom/movable/outermost_movable = null

/datum/parallax_controller/New(client/new_owner)
	. = ..()

	src.owner = new_owner
	src.anchor = new /atom/movable/screen/parallax_anchor()
	src.owner.screen += src.anchor

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

	src.owner.screen -= src.anchor
	QDEL_NULL(src.anchor)

	src.owner.parallax_controller = null
	src.owner = null

	. = ..()

/// Updates the parallax render sources and layers displayed to a client by a z-level.
/datum/parallax_controller/proc/update_z_level_parallax_layers(datum/component/component, old_z_level, new_z_level)
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
/datum/parallax_controller/proc/update_area_parallax_layers(datum/component/component, area/old_area, area/new_area)
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

		src.anchor.vis_contents += render_source
		src.anchor.vis_contents += parallax_layer

/// Creates a new parallax layer for every provided parallax layer render source.
/datum/parallax_controller/proc/recalculate_parallax_layer(atom/movable/screen/parallax_render_source/render_source)
	var/atom/movable/screen/parallax_layer/parallax_layer = src.parallax_render_sources[render_source]
	if (parallax_layer)
		parallax_layer.offset_layer()
		parallax_layer.scroll_layer()

/// Removes the parallax layers corresponding to the provided parallax layer render sources.
/datum/parallax_controller/proc/remove_parallax_layer(list/parallax_layer_render_sources)
	for (var/atom/movable/screen/parallax_render_source/render_source as anything in parallax_layer_render_sources)
		if (isnull(src.parallax_render_sources[render_source]))
			continue

		var/atom/movable/screen/parallax_layer/parallax_layer = src.parallax_render_sources[render_source]
		src.parallax_render_sources -= render_source
		src.parallax_layers -= parallax_layer

		src.anchor.vis_contents -= render_source
		src.anchor.vis_contents -= parallax_layer

/datum/parallax_controller/proc/register_signals(client/C, mob/M)
	src.RegisterSignal(M, XSIG_MOVABLE_AREA_CHANGED, PROC_REF(update_area_parallax_layers))
	src.RegisterSignal(M, XSIG_MOVABLE_Z_CHANGED, PROC_REF(update_z_level_parallax_layers))

	src.outermost_movable = global.outermost_movable(M)
	src.update_area_parallax_layers(null, null, get_area(src.outermost_movable))
	src.update_z_level_parallax_layers(null, null, src.outermost_movable.z)

/datum/parallax_controller/proc/unregister_signals(client/C, mob/M)
	if (!M?.GetComponent(/datum/component/complexsignal/outermost_movable))
		return

	src.UnregisterSignal(M, XSIG_MOVABLE_AREA_CHANGED)
	src.UnregisterSignal(M, XSIG_MOVABLE_Z_CHANGED)


/atom/movable/screen/parallax_anchor
	plane = PLANE_PARALLAX
	appearance_flags = KEEP_TOGETHER | TILE_BOUND
	screen_loc = "CENTER,CENTER"
	mouse_opacity = 0


/client/var/datum/parallax_controller/parallax_controller = null

/client/New()
	. = ..()
	src.toggle_parallax()

/client/Del()
	qdel(src.parallax_controller)
	. = ..()
