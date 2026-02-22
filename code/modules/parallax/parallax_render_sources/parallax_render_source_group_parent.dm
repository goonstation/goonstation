ABSTRACT_TYPE(/datum/parallax_render_source_group)
/**
 *	The parent type for parallax render source groups, which govern which parallax render sources should be shown to a client
 *	in a given area or z-level. They also allow for the efficient manipulation of parallax render sources and layers within a
 *	specified z-level or area, permitting more granular control over the appearance of parallax render sources.
 */
/datum/parallax_render_source_group
	/// An associative list of parallax render source types and the instance of that type belonging to this render source group.
	var/list/atom/movable/screen/parallax_render_source/parallax_render_source_types_and_sources
	/// A list of default parallax layer render source types that should be instantiated on New().
	var/list/parallax_render_source_types = list()
	/// A list of parallax layer render sources to render to layers on a client's screen.
	var/list/atom/movable/screen/parallax_render_source/parallax_render_sources
	/// All clients that currently have render sources from this groups displayed to their screen.
	var/list/client/members

/datum/parallax_render_source_group/New()
	. = ..()

	src.parallax_render_source_types_and_sources = list()
	src.parallax_render_sources = list()
	src.members = list()

	for (var/render_source_type in src.parallax_render_source_types)
		var/atom/movable/screen/parallax_render_source/parallax_render_source = new render_source_type()
		src.parallax_render_source_types_and_sources[render_source_type] = parallax_render_source
		src.parallax_render_sources += parallax_render_source

/// Creates a new parallax layer render source of the specified type or types in the group, and for each client assigns a parallax layer to it.
/datum/parallax_render_source_group/proc/add_parallax_render_source(parallax_render_source_type_or_types, animation_time = 0)
	// Format the render source types into a list to be interated through.
	var/list/new_parallax_render_source_types
	if (islist(parallax_render_source_type_or_types))
		new_parallax_render_source_types = parallax_render_source_type_or_types
	else if (ispath(parallax_render_source_type_or_types))
		new_parallax_render_source_types = list(parallax_render_source_type_or_types)

	// Iterate through the render source types, continuing if an instance of that type already exists on the render source group.
	var/list/atom/movable/screen/parallax_render_source/new_parallax_render_sources = list()
	for (var/render_source_type in new_parallax_render_source_types)
		if (!isnull(src.parallax_render_source_types_and_sources[render_source_type]))
			continue

		var/atom/movable/screen/parallax_render_source/parallax_render_source = new render_source_type()
		src.parallax_render_source_types_and_sources[render_source_type] = parallax_render_source
		src.parallax_render_sources += parallax_render_source
		new_parallax_render_sources += parallax_render_source

		if (animation_time)
			parallax_render_source.alpha = 0

	// Assign parallax layers corresponding to the parallax layer render sources to the client.
	for (var/client/client as anything in src.members)
		client?.parallax_controller?.add_parallax_layer(new_parallax_render_sources)

	// Begin a fade-in animation.
	if (animation_time)
		for (var/atom/movable/screen/parallax_render_source/parallax_render_source as anything in new_parallax_render_sources)
			animate(parallax_render_source, animation_time, alpha = 255, flags = ANIMATION_PARALLEL)

/datum/parallax_render_source_group/proc/copy_parallax_render_sources_from_group(datum/parallax_render_source_group/donor_group, animation_time = 0)
	var/list/atom/movable/screen/parallax_render_source/new_parallax_render_sources = list()
	var/atom/movable/screen/parallax_render_source/parallax_render_source
	for(parallax_render_source in donor_group.parallax_render_sources)
		src.parallax_render_source_types_and_sources[parallax_render_source.type] = parallax_render_source
		src.parallax_render_sources += parallax_render_source
		new_parallax_render_sources += parallax_render_source

		if (animation_time)
			parallax_render_source.alpha = 0

	// Assign parallax layers corresponding to the parallax layer render sources to the client.
	for (var/client/client as anything in src.members)
		client?.parallax_controller?.add_parallax_layer(new_parallax_render_sources)

	if (animation_time)
		for (parallax_render_source as anything in new_parallax_render_sources)
			animate(parallax_render_source, animation_time, alpha = 255, flags = ANIMATION_PARALLEL)

/datum/parallax_render_source_group/proc/update_parallax_render_source(parallax_render_source_type)
	var/atom/movable/screen/parallax_render_source/parallax_render_source = src.parallax_render_source_types_and_sources[parallax_render_source_type]
	if(istype(parallax_render_source))
		parallax_render_source.tessellate()
		for (var/client/client as anything in src.members)
			client?.parallax_controller.recalculate_parallax_layer(parallax_render_source)


/// Removes the specifed parallax layer render source type or types from the group, and their associated parallax layers.
/datum/parallax_render_source_group/proc/remove_parallax_render_source(parallax_render_source_type_or_types, animation_time = 0)
	// Format the render source types into a list to be interated through.
	var/list/parallax_render_source_types_to_remove
	if (islist(parallax_render_source_type_or_types))
		parallax_render_source_types_to_remove = parallax_render_source_type_or_types
	else if (ispath(parallax_render_source_type_or_types))
		parallax_render_source_types_to_remove = list(parallax_render_source_type_or_types)

	// Iterate through the render source types, removing them from the `parallax_render_source_types_and_sources` list.
	var/list/atom/movable/screen/parallax_render_source/parallax_render_sources_to_remove = list()
	for (var/render_source_type in parallax_render_source_types_to_remove)
		var/atom/movable/screen/parallax_render_source/parallax_render_source = src.parallax_render_source_types_and_sources[render_source_type]
		if (!parallax_render_source)
			continue

		src.parallax_render_source_types_and_sources -= render_source_type
		src.parallax_render_sources -= parallax_render_source
		parallax_render_sources_to_remove += parallax_render_source

		// Begin a fade out animation.
		animate(parallax_render_source, animation_time, alpha = 0, flags = ANIMATION_PARALLEL)

	// After the animation concludes, remove the corresponding parallax layers from all clients' screens, and delete the render source.
	SPAWN(animation_time)
		for (var/client/client in src.members)
			client.parallax_controller?.remove_parallax_layer(parallax_render_sources_to_remove, animation_time)

		for (var/atom/movable/screen/parallax_render_source/parallax_render_source as anything in parallax_render_sources_to_remove)
			qdel(parallax_render_source)

/// Applies the provided colour matrix to all eligible parallax layer render sources in the group, and animates the transition.
/datum/parallax_render_source_group/proc/recolour_parallax_render_sources(list/colour, animation_time = 0)
	for (var/atom/movable/screen/parallax_render_source/parallax_render_source as anything in src.parallax_render_sources)
		if (parallax_render_source.static_colour)
			continue

		animate(parallax_render_source, animation_time, color = colour, flags = ANIMATION_PARALLEL)

/// Restores the group's parallax render sources to their default state.
/datum/parallax_render_source_group/proc/restore_parallax_render_sources_to_default()
	src.remove_parallax_render_source(src.parallax_render_source_types_and_sources)
	src.add_parallax_render_source(src.parallax_render_source_types)



ABSTRACT_TYPE(/datum/parallax_render_source_group/area)
/**
 *	Area render source groups are singleton datums stored in a lookup table by type. They permit areas of differing type paths
 *	to share parallax render source instances and therefore permit parallax render source changes to take effect across several
 *	areas consistantly.
 */
/datum/parallax_render_source_group/area


ABSTRACT_TYPE(/datum/parallax_render_source_group/z_level)
/**
 *	Z-level render source groups are singleton datums stored in a lookup table by z-level. Their default parallax render source
 *	types are defined by the current map settings, with each z-level render source group using the list on the map settings datum
 *	corresponding to its z-level. See `map.dm` and the `Z_LEVEL_PARALLAX_RENDER_SOURCES()` macro.
 */
/datum/parallax_render_source_group/z_level
	var/z_level


ABSTRACT_TYPE(/datum/parallax_render_source_group/planet)
/**
 *	Planet render source groups are non-singleton datums, with each instance of each type varying in parallax render source
 *	settings. They are assigned to planet areas during the procedural generation of planets, and permit variety in parallax
 *	layers amongst planets.
 */
/datum/parallax_render_source_group/planet

/datum/parallax_render_source_group/planet/New()
	. = ..()

	src.setup_render_sources()
	planet_parallax_render_source_groups += src

/datum/parallax_render_source_group/planet/disposing()
	planet_parallax_render_source_groups -= src

	. = ..()

/// Randomly varies the parallax render sources within this group, or randomly adds additional layers.
/datum/parallax_render_source_group/planet/proc/setup_render_sources()
	return
