/**
 * # Character Preview
 *
 * Essentially, it creates a human on a 1x1 map and lets you set the appearance of that human.
 *
 * This parent type is for use in single-client windows.
 * See [datum/character_preview/window] for a detatched window and and [datum/character_preview/multiclient] for a multi-client variant.
 *
 * Use winset() to position the control within the window.
 *
 * See the default code for an example - places it at 0,0 and makes it 128x128 pixels.
 */
datum/character_preview
	var/global/max_preview_id = 0
	/// The map ID for use with winset().
	var/preview_id
	var/window_id
	var/client/viewer
	var/atom/movable/screen/handler
	/// The human mob shown in the preview.
	/// May be useful to access directly if you want to put clothes on it or whatever.
	var/mob/living/carbon/human/preview_mob

	New(client/viewer, window_id, control_id = null)
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
				"size" = "128,128",
			)))

		src.handler = new
		src.handler.plane = 0
		src.handler.mouse_opacity = 0
		src.handler.screen_loc = "[src.preview_id]:1,1"
		src.viewer?.screen += src.handler

		var/turf/loc = null
		if(length(landmarks[LANDMARK_CHARACTER_PREVIEW_SPAWN]))
			shuffle_list(landmarks[LANDMARK_CHARACTER_PREVIEW_SPAWN])
			for(var/turf/T in landmarks[LANDMARK_CHARACTER_PREVIEW_SPAWN])
				if(isnull(locate(/mob/living) in T))
					loc = T
					break
		var/mob/living/carbon/human/H = new(loc)
		mobs -= H
		src.preview_mob = H
		H.screen_loc = "[src.preview_id];1,1"
		src.handler.vis_contents += H
		src.viewer?.screen += H

	disposing()
		STOP_TRACKING
		SPAWN_DBG(0)
			if (src.viewer)
				winset(src.viewer, "[src.window_id].[src.preview_id]", "parent=")
		if (src.handler)
			if (src.viewer)
				src.viewer.screen -= src.handler
			qdel(src.handler)
		if (src.preview_mob)
			if (src.viewer)
				src.viewer.screen -= src.preview_mob
			qdel(src.preview_mob)
		. = ..()

	/// Sets the appearance, mutant race, and facing direction of the human mob.
	proc/update_appearance(datum/appearanceHolder/AH, datum/mutantrace/MR = null, direction = SOUTH)
		src.preview_mob.dir = direction
		src.preview_mob.set_mutantrace(null)
		src.preview_mob.bioHolder.mobAppearance.CopyOther(AH)
		src.preview_mob.set_mutantrace(MR)
		src.preview_mob.organHolder.head.donor = src.preview_mob
		src.preview_mob.organHolder.head.donor_appearance.CopyOther(src.preview_mob.bioHolder.mobAppearance)
		src.preview_mob.update_colorful_parts()
		src.preview_mob.set_body_icon_dirty()
		src.preview_mob.set_face_icon_dirty()

/// Manages its own window.
/// Basically a simplified version for when you don't need to put other stuff in the preview window.
datum/character_preview/window
	New(client/viewer)
		var/winid = "preview_[max_preview_id]"

		winclone(viewer, "blank-map", winid)

		winset(viewer, winid, list2params(list(
			"size" = "128,128",
			"title" = "Character Preview",
			"can-close" = FALSE,
			"can-resize" = FALSE,
		)))

		. = ..(viewer, winid)

	disposing()
		. = ..()
		SPAWN_DBG(0)
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
datum/character_preview/multiclient
	var/list/viewers = list()

	New(control_id = null)
		. = ..(null, "unused", control_id)

	disposing()
		for (var/client/viewer in src.viewers)
			if (viewer)
				viewer.screen -= src.handler
				viewer.screen -= src.preview_mob
		. = ..()

	/// Adds a subscribed client
	proc/add_client(client/viewer)
		if (viewer && !(viewer in src.viewers))
			src.viewers += viewer
			viewer.screen += src.handler
			viewer.screen += src.preview_mob

	/// Removes a subscribed client
	proc/remove_client(client/viewer)
		if (viewer && (viewer in src.viewers))
			src.viewers -= viewer
			viewer.screen -= src.handler
			viewer.screen -= src.preview_mob

	/// Removes all subscribers
	proc/remove_all_clients()
		for (var/client/viewer in src.viewers)
			if (viewer)
				viewer.screen -= src.handler
				viewer.screen -= src.preview_mob
		src.viewers.len = 0
