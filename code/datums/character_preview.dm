/**
 * # Movable Preview
 *
 * Essentially, it creates a movable on a 1x1 map and gives you access to the it for modification.
 *
 * This parent type is for use for mainly objects. For humans, see [/datum/movable_preview/character]
 *
 * Use winset() to position the control within the window.
 *
 * See the default code for an example - places it at 0,0 and makes it 128x128 pixels.
 */
/datum/movable_preview
	/// Global ID for this preview datum
	var/global/max_preview_id = 0 // Could be replaced with \ref ?
	/// The map ID for use with winset().
	var/preview_id
	var/window_id
	var/client/viewer
	var/atom/movable/screen/handler
	var/obj/overlay/background = null
	/// The atom/movable to show in the preview
	/// May be useful to access directly if you want to mess with it
	var/atom/movable/preview_thing = null
	/// Set to true if you want to handle the creation of the `preview_thing`
	var/custom_setup = FALSE

/// Pass the viewer client, the name of the window, the control to bind it to, and the size you want
/datum/movable_preview/New(client/viewer, window_id, control_id = null, size = 128)
	. = ..()
	START_TRACKING

	src.viewer = viewer
	if (isnull(control_id))
		control_id = "map_preview_[max_preview_id++]"
	src.preview_id = "[control_id]"
	src.window_id = window_id

	if (viewer)
		winset(viewer, src.preview_id, list2params(list(
			"parent" = src.window_id,
			"type" = "map",
			"pos" = "0,0",
			"size" = "[size],[size]",
		)))

	src.handler = new
	src.handler.plane = 0
	src.handler.mouse_opacity = 0
	src.handler.screen_loc = "[src.preview_id]:1,1"
	src.viewer?.screen += src.handler

	if (custom_setup)
		custom_setup(viewer, window_id, control_id)
	else
		src.preview_thing = new(null)

	src.preview_thing.screen_loc = "[src.preview_id];1,1"
	src.handler.vis_contents += src.preview_thing
	src.viewer?.screen += src.preview_thing

/datum/movable_preview/disposing()
	STOP_TRACKING
	SPAWN(0)
		if (src.viewer)
			winset(src.viewer, "[src.window_id].[src.preview_id]", "parent=")
	if (src.handler)
		if (src.viewer)
			src.viewer.screen -= src.handler
		qdel(src.handler)
	if (src.preview_thing)
		if (src.viewer)
			src.viewer.screen -= src.preview_thing
		qdel(src.preview_thing)
	if (src.background)
		if (src.viewer)
			src.viewer.screen -= src.background
		qdel(src.background)
	. = ..()

/// See: [/datum/movable_preview/var/custom_setup]
/datum/movable_preview/proc/custom_setup(client/viewer, window_id, control_id)
	return

/**
 * Adds a background to the preview - default is floor tiles, two tiles high.
 *
 * You can specify a `color` to render a flat color as a background instead.
 * Additionally, if `height_mult` is specified also, it'll multiply the height of that color.
 */
/datum/movable_preview/proc/add_background(color = null, height_mult = 1)
	if(isnull(src.background))
		src.background = new()
	if (color)
		src.background.icon = 'icons/effects/white.dmi'
		src.background.color = color
		src.background.transform = matrix(1, 0, 0, 0, 1*height_mult, 16*(height_mult-1))
	else
		src.background.icon = 'icons/misc/32x64.dmi'
		src.background.icon_state = "floor"
	src.background.screen_loc = "[src.preview_id]:1,1"
	src.background.mouse_opacity = 0
	src.handler.vis_contents |= src.background
	src.viewer?.screen |= src.background

/**
 * # Character Preview
 *
 * This is intended only for use with humans.
 *
 * This parent type is for use in single-client windows.
 * See [/datum/movable_preview/character/window] for a detatched window and and [/datum/movable_preview/character/multiclient] for a multi-client variant.
 */
/datum/movable_preview/character
	custom_setup = TRUE

	custom_setup(client/viewer, window_id, control_id)
		var/mob/living/carbon/human/H = new(global.get_centcom_mob_cloner_spawn_loc())
		mobs -= H
		src.preview_thing = H
		qdel(H.name_tag)
		H.name_tag = null

		if(isturf(H.loc))
			put_mob_in_centcom_cloner(H)

	/// Sets the appearance, mutant race, and facing direction of the human mob.
	/// Assumes the `preview_thing` is a mob
	proc/update_appearance(datum/appearanceHolder/AH, datum/mutantrace/MR = null, direction = SOUTH, name = "human")
		var/mob/living/carbon/human/preview_mob = src.preview_thing
		preview_mob.dir = direction
		preview_mob.set_mutantrace(null)
		preview_mob.bioHolder.mobAppearance.CopyOther(AH)
		preview_mob.set_mutantrace(MR)
		preview_mob.organHolder.head.donor = preview_mob
		preview_mob.organHolder.head.donor_appearance.CopyOther(preview_mob.bioHolder.mobAppearance)
		preview_mob.update_colorful_parts()
		preview_mob.set_body_icon_dirty()
		preview_mob.set_face_icon_dirty()
		preview_mob.real_name = "clone of " + name
		preview_mob.name = "clone of " + name

/// Manages its own window.
/// Basically a simplified version for when you don't need to put other stuff in the preview window.
/datum/movable_preview/character/window
	New(client/viewer, window_id, control_id, size)
		var/winid = "preview_[max_preview_id]"

		winclone(viewer, "blank-map", winid)

		winset(viewer, winid, list2params(list(
			"size" = "[size],[size]",
			"title" = "Character Preview",
			"can-close" = FALSE,
			"can-resize" = FALSE,
		)))

		. = ..(viewer, winid)

	disposing()
		. = ..()
		SPAWN(0)
			if (src.viewer)
				winset(src.viewer, "[src.window_id]", "parent=")

	/// Shows (or hides if the argument is false) the window.
	proc/show(shown = TRUE)
		winshow(src.viewer, src.window_id, shown)


/**
 * A shared character preview between multiple clients.
 * Again, use winset() to position the control.
 *
 * You need to call the special client procs to manage subscribers in addition to the winset.
 */
/datum/movable_preview/character/multiclient
	var/list/viewers = list()

	New(control_id = null)
		. = ..(null, "unused", control_id)

	disposing()
		for (var/client/viewer in src.viewers)
			if (viewer)
				viewer.screen -= src.handler
				viewer.screen -= src.preview_thing
				if(src.background)
					viewer.screen -= src.background
		. = ..()

	add_background(color, height_mult)
		. = ..()
		for(var/client/viewer in src.viewers)
			viewer.screen |= src.background

	/// Adds a subscribed client
	proc/add_client(client/viewer)
		if (viewer && !(viewer in src.viewers))
			src.viewers += viewer
			viewer.screen += src.handler
			viewer.screen += src.preview_thing
			if(src.background)
				viewer.screen |= src.background

	/// Removes a subscribed client
	proc/remove_client(client/viewer)
		if (viewer && (viewer in src.viewers))
			src.viewers -= viewer
			viewer.screen -= src.handler
			viewer.screen -= src.preview_thing
			if(src.background)
				viewer.screen -= src.background

	/// Removes all subscribers
	proc/remove_all_clients()
		for (var/client/viewer in src.viewers)
			if (viewer)
				viewer.screen -= src.handler
				viewer.screen -= src.preview_thing
				if(src.background)
					viewer.screen -= src.background
		src.viewers.len = 0
