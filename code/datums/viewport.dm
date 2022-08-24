/datum/viewport
	var/global/max_viewport_id = 0
	var/viewport_id = 0
	var/clickToMove = 0
	var/client/viewer
	var/atom/movable/screen/handler

	var/list/planes = list()
	var/kind

	New(var/client/viewer, var/kind)
		..()
		src.kind = kind

		src.viewer = viewer
		viewport_id = "viewport_[max_viewport_id++]"
		winclone( viewer, "blank-map", viewport_id )
		winset( viewer, "[viewport_id]", list2params(list("on-close" = ".viewport-close \"\ref[src]\"", "size" = "256,256")))
		var/list/params = list( "parent" = viewport_id, "type" = "map", "pos" = "0,0", "size" = "256,256", "anchor1" = "0,0", "anchor2" = "100,100" )
		winset(viewer, "map_[viewport_id]", list2params(params))
		handler = new
		handler.plane = 0
		handler.mouse_opacity = 0
		handler.screen_loc = "map_[viewport_id]:1,1"
		winshow( viewer, viewport_id, 1 )
		viewer.screen += handler
		for(var/plane_key in viewer.plane_parents)
			var/atom/movable/screen/plane_parent/p = viewer.plane_parents[plane_key]
			var/atom/movable/screen/plane_parent/dupe = new
			dupe.plane = p.plane
			dupe.appearance = p.appearance
			dupe.appearance_flags = p.appearance_flags
			dupe.mouse_opacity = p.mouse_opacity//0
			dupe.blend_mode = p.blend_mode
			dupe.screen_loc = "map_[viewport_id]:1,1"
			dupe.name = p.name

			viewer.screen += dupe
			planes += dupe

		viewer.viewports += src

	proc/getID()
		return "[viewport_id].map_[viewport_id]"

	disposing()
		if(viewer)
			SPAWN(0)
				if(viewer)
					winset( viewer, "[viewport_id].map_[viewport_id]", "parent=none" )
					winset( viewer, "[viewport_id]", "parent=none" )
			if(viewer)
				viewer.viewports -= src
		if(handler)
			if(viewer) viewer.screen -= handler
			qdel(handler)
		for(var/obj/thing in planes)
			if(viewer) viewer.screen -= thing
			qdel(thing)
		..()

	proc/Close()
		qdel(src)

	proc/SetViewport( var/turf/startLoc, var/width, var/height )
		var/turf/endLoc = locate(min(world.maxx, startLoc.x + width), max(startLoc.y - height, 1), startLoc.z)
		var/list/contentBlock = list()

		var/obj/badcode = pick(planes)
		handler.screen_loc = "map_[viewport_id]:1,1"
		badcode.screen_loc = "map_[viewport_id]:1,1 TO [endLoc.x - startLoc.x],[startLoc.y - endLoc.y]"//a lazy way to expand the viewport
		for(var/y = endLoc.y, y <= startLoc.y, y++)
			for(var/x = startLoc.x, x <= endLoc.x, x++)
				contentBlock += locate(x,y,startLoc.z)
		handler.vis_contents = contentBlock

/client/var/list/viewports = list()

/client/proc/getViewportsByType(var/kind)
	.=list()
	for(var/datum/viewport/vp in viewports)
		if(vp.kind == kind)
			. += vp

/client/proc/getViewportById(var/id)
	for(var/datum/viewport/vp in viewports)
		if(vp.getID() == id) return vp

/client/proc/clearViewportsByType(var/kind)
	for(var/datum/viewport/vp in getViewportsByType(kind))
		if(vp.kind == kind)
			qdel(vp)

/client/Del()
	for(var/datum/viewport/vp in viewports)
		qdel(vp)//circular reference, gotta trash it manually
	return ..()

/client/verb/viewport_close(var/id as text)
	set hidden = 1
	set name = ".viewport-close"

	var/datum/viewport/vp = locate(id)
	if(istype(vp) && vp.viewer == src)
		qdel(vp)

///client/verb/dupeVP()
//	var/datum/viewport/vp = new(src)
//	vp.SetViewport( get_turf(src.mob), 8, 8 )
/mob/living/intangible/aieye/verb/create_viewport()
	set category = "AI Commands"
	set name = "EXPERIMENTAL: Create Viewport"
	set desc = "Expand your powers with Nanotransen's Viewportifier!"


	var/list/viewports = client.getViewportsByType("AI: Viewport")
	if(viewports.len >= 5)
		boutput( src, "<b>You can only have up to 5 active viewports. Close an existing viewport to create another.</b>" )
		return

	var/datum/viewport/vp = new(src.client, "AI: Viewport")
	var/turf/ourPos = get_turf(src)
	var/turf/startPos = null
	for(var/i = 4, i >= 0 || !startPos, i--)
		startPos = locate(ourPos.x - i, ourPos.y + i, ourPos.z)
		if(startPos) break
	vp.clickToMove = 1
	vp.SetViewport(startPos, 8, 8)

/mob/living/intangible/blob_overmind/verb/create_viewport()
	set category = "Blob Commands"
	set name = "EXPERIMENTAL: Create Viewport"
	set desc = "Expand your powers with BlobCorp's Viewportifier!"


	var/list/viewports = client.getViewportsByType("Blob: Viewport")
	if(viewports.len >= 5)
		boutput( src, "<b>You can only have up to 5 active viewports. Close an existing viewport to create another.</b>" )
		return

	var/datum/viewport/vp = new(src.client, "Blob: Viewport")
	var/turf/ourPos = get_turf(src)
	var/turf/startPos = null
	for(var/i = 4, i >= 0 || !startPos, i--)
		startPos = locate(ourPos.x - i, ourPos.y + i, ourPos.z)
		if(startPos) break
	vp.clickToMove = 1
	vp.SetViewport(startPos, 8, 8)
/mob/living/intangible/blob_overmind/death()
	src.client?.clearViewportsByType("Blob: Viewport")
	.=..()

/mob/living/silicon/ai/death(gibbed)
	src.client?.clearViewportsByType("AI: Viewport")
	.=..()
