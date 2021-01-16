datum/character_preview
	var/global/max_preview_id = 0
	var/preview_id = 0
	var/client/viewer
	var/obj/screen/handler
	var/mob/living/carbon/human/preview_mob

	New(client/viewer)
		. = ..()
		src.viewer = viewer
		src.preview_id = "preview_[max_preview_id++]"
		winclone(src.viewer, "blank-map", src.preview_id)

		winset(viewer, "[src.preview_id]", list2params(list(
			"size" = "128,128",
			"title" = "Character Preview",
			"can-close" = FALSE,
			"can-resize" = FALSE,
		)))

		winset(viewer, "map_[src.preview_id]", list2params(list(
			"parent" = src.preview_id,
			"type" = "map",
			"pos" = "0,0",
			"size" = "128,128",
			"anchor1" = "0,0",
			"anchor2" = "100,100",
		)))

		src.handler = new
		src.handler.plane = 0
		src.handler.mouse_opacity = 0
		src.handler.screen_loc = "map_[src.preview_id]:1,1"
		src.viewer.screen += src.handler

		var/mob/living/carbon/human/H = new()
		src.preview_mob = H
		H.screen_loc = "map_[src.preview_id];1,1"
		src.handler.vis_contents += H
		src.viewer.screen += H

	disposing()
		SPAWN_DBG(0)
			if (src.viewer)
				winset(src.viewer, "[src.preview_id].map_[src.preview_id]", "parent=none")
				winset(src.viewer, "[src.preview_id]", "parent=none")
		if (src.handler)
			if (src.viewer)
				src.viewer.screen -= src.handler
			qdel(src.handler)
		if (src.preview_mob)
			if (src.viewer)
				src.viewer.screen -= src.preview_mob
			qdel(src.preview_mob)
		. = ..()

	proc/GetID()
		. = "[src.preview_id].map_[src.preview_id]"

	proc/Show(shown = TRUE)
		winshow(src.viewer, src.preview_id, shown)

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
