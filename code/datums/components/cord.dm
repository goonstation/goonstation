/datum/component/cord
	var/obj/dummy/cord = null
	var/atom/movable/handset = null
	var/atom/movable/parent_atom = null
	///name of the line icon state used in drawLineImg
	var/cord_line
	///name of the end cap icon state used in drawLineImg
	var/cord_cap
	///pixel offset of the connection to the base
	var/base_offset_x = 0
	///pixel offset of the connection to the base
	var/base_offset_y = 0
	///maximum allowable range (in pixels, thanks bounds_dist) that the handset can be from the base
	var/range = 0
	///Draw behind the parent atom
	var/behind_parent = FALSE

/datum/component/cord/Initialize(atom/movable/handset, cord_line = "cord", cord_cap = "cord_end", base_offset_x, base_offset_y, range = 0, behind_parent = FALSE)
	. = ..()
	src.parent_atom = src.parent
	src.handset = handset
	src.cord_line = cord_line
	src.cord_cap = cord_cap
	src.base_offset_x = base_offset_x
	src.base_offset_y = base_offset_y
	src.range = range
	src.behind_parent = behind_parent
	RegisterSignal(src.handset, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(draw_cord), TRUE)

/datum/component/cord/proc/draw_cord(datum/component/complexsignal/outermost_movable/component)
	if (QDELETED(src.handset))
		SEND_SIGNAL(src.parent, COMSIG_CORD_RETRACT)
		return

	// get the turf of the heandset if it's not on a turf otherwise BOUNDS_DIST is infinity
	if(BOUNDS_DIST(isturf(src.handset.loc) ? src.handset : get_turf(src.handset), src.parent) > range)
		SEND_SIGNAL(src.parent, COMSIG_CORD_RETRACT)
		return
	var/list/handset_offsets = src.get_handset_offset()

	var/datum/lineResult/result = drawLineImg(src.parent, get_turf(src.handset), src.cord_line, src.cord_cap, src.parent_atom.pixel_x + src.base_offset_x, src.parent_atom.pixel_y + src.base_offset_y, handset_offsets[1], handset_offsets[2], LINEMODE_STRETCH_NO_CLIP, applyTransform = FALSE)
	result.lineImage.layer = src.parent_atom.layer+0.01 * (behind_parent ? -1 : 1)
	if (src.cord)
		var/animate_time = 0.2 SECONDS //just default to something sane if we don't know the glide size
		if (istype(component?.get_outermost_movable(), /atom/movable))
			var/atom/movable/mover = component.get_outermost_movable()
			if (mover.glide_size)
				animate_time = 32/(mover.glide_size / world.tick_lag)
		animate(src.cord, transform = result.transform, time = animate_time)
	else
		src.cord = new /obj/dummy(src.parent)
		src.cord.mouse_opacity = 0
		src.cord.pixel_x = -src.parent_atom.pixel_x
		src.cord.pixel_y = -src.parent_atom.pixel_y
		src.cord.UpdateOverlays(result.lineImage, "cord_image")
		src.cord.transform = result.transform
		src.parent_atom.vis_contents += src.cord

/datum/component/cord/proc/get_handset_offset()
	if (istype(src.handset, /obj/projectile))
		var/obj/projectile/P = src.handset
		return list(P.next_wx, P.next_wy)

	var/handset_offset_x = -7
	var/handset_offset_y = -7
	if(ismob(src.handset.loc))
		var/mob/living/M = src.handset.loc
		switch (M.dir)
			if (NORTH)
				handset_offset_y = -1
				if (M.hand == LEFT_HAND)
					handset_offset_x = -6
				else
					handset_offset_x = 6
			if (SOUTH)
				handset_offset_y = -1
				if (M.hand == LEFT_HAND)
					handset_offset_x = 6
				else
					handset_offset_x = -6
			if (EAST)
				if(M.hand == LEFT_HAND)
					handset_offset_x = 4
					handset_offset_y = -4
				else
					handset_offset_x = -4
					handset_offset_y = -2
			if(WEST)
				if(M.hand == LEFT_HAND)
					handset_offset_x = 4
					handset_offset_y = -2
				else
					handset_offset_x = -4
					handset_offset_y = -4
					handset_offset_x = -4

	return list(src.handset.pixel_x + handset_offset_x, src.handset.pixel_y + handset_offset_y)

/datum/component/cord/UnregisterFromParent()
	src.parent_atom.vis_contents -= src.cord
	qdel(src.cord)
	src.cord = null
	if (!QDELETED(src.handset))
		UnregisterSignal(src.handset, XSIG_MOVABLE_TURF_CHANGED)
