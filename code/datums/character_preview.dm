datum/character_preview
	var/global/max_preview_id = 0
	var/preview_id
	var/window_id
	var/client/viewer
	var/obj/screen/handler
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

		var/mob/living/carbon/human/H = new()
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

	proc/Show(shown = TRUE)
		winshow(src.viewer, src.window_id, shown)

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

	proc/AddClient(client/viewer)
		if (viewer && !(viewer in src.viewers))
			src.viewers += viewer
			viewer.screen += src.handler
			viewer.screen += src.preview_mob

	proc/RemoveClient(client/viewer)
		if (viewer && (viewer in src.viewers))
			src.viewers -= viewer
			viewer.screen -= src.handler
			viewer.screen -= src.preview_mob

	proc/RemoveAllClients()
		for (var/client/viewer in src.viewers)
			if (viewer)
				viewer.screen -= src.handler
				viewer.screen -= src.preview_mob
		src.viewers.len = 0
