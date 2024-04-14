/atom/movable/screen/viewport_handler
	name = "Viewport Handler"
	plane = PLANE_BLACKNESS
	mouse_opacity = 0
	var/viewport_kind
	var/client/viewer
	var/listens = FALSE

	New(client/viewer, kind)
		..()
		src.viewport_kind = kind
		src.viewer = viewer

	disposing()
		viewer = null
		..()


/datum/viewport
	var/global/max_viewport_id = 0
	var/viewport_id = 0
	var/clickToMove = 0
	var/client/viewer
	var/atom/movable/screen/viewport_handler/handler
	var/atom/followed_atom = null
	var/width = 9
	var/height = 9

	var/list/planes = list()
	var/kind

	New(var/client/viewer, var/kind, title=null, shares_plane_parents=FALSE)
		..()
		src.kind = kind
		src.viewer = viewer
		viewport_id = "viewport_[max_viewport_id++]"
		if(isnull(title))
			title = kind
		winclone( viewer, "blank-map", viewport_id )
		winset( viewer, "[viewport_id]", list2params(list("on-close" = ".viewport-close \"\ref[src]\"", "size" = "256,256", "title" = "[title]")))
		var/style = winget(viewer, "mapwindow.map", "style")
		var/list/params = list( "parent" = viewport_id, "type" = "map", "pos" = "0,0", "size" = "256,256", "anchor1" = "0,0", "anchor2" = "100,100" )
		params["style"] = style
		winset(viewer, "map_[viewport_id]", list2params(params))
		handler = new(viewer, kind)
		handler.screen_loc = "map_[viewport_id]:1,1"
		winshow( viewer, viewport_id, 1 )
		viewer.screen += handler
		for(var/plane_key in viewer.plane_parents)
			var/atom/movable/screen/plane_parent/p = viewer.plane_parents[plane_key]
			if(!shares_plane_parents)
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
			else
				var/atom/movable/screen/plane_parent_proxy = new
				plane_parent_proxy.vis_contents += p
				plane_parent_proxy.screen_loc = "map_[viewport_id]:1,1"
				viewer.screen += plane_parent_proxy
				planes += plane_parent_proxy

		viewer.viewports += src

	proc/getID()
		return "[viewport_id].map_[viewport_id]"

	disposing()
		if(src.followed_atom)
			src.stop_following()
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
		if(width)
			src.width = width
		if(height)
			src.height = height
		var/turf/endLoc = locate(min(world.maxx, startLoc.x + src.width), max(startLoc.y - src.height, 1), startLoc.z)
		var/list/contentBlock = list()

		var/obj/badcode = pick(planes)
		handler.screen_loc = "map_[viewport_id]:1,1"
		badcode.screen_loc = "map_[viewport_id]:1,1 TO [endLoc.x - startLoc.x],[startLoc.y - endLoc.y]"//a lazy way to expand the viewport
		for(var/y = endLoc.y, y <= startLoc.y, y++)
			for(var/x = startLoc.x, x <= endLoc.x, x++)
				contentBlock += locate(x,y,startLoc.z)
		handler.vis_contents = contentBlock

	proc/stop_following()
		if(!QDELETED(src.followed_atom))
			UnregisterSignal(src.followed_atom, XSIG_MOVABLE_TURF_CHANGED)
		src.followed_atom = null

	proc/start_following(atom/target_atom)
		if(src.followed_atom)
			src.stop_following()
		src.followed_atom = target_atom
		RegisterSignal(src.followed_atom, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(followed_turf_changed))
		followed_turf_changed(target_atom, null, get_turf(target_atom))

	proc/followed_turf_changed(atom/thing, turf/old_turf, turf/new_turf)
		if(isnull(new_turf))
			handler.vis_contents = null
			return
		var/turf/T = null
		for(var/i = round(max(width, height) / 2), i >= 0 || !new_turf, i--)
			T = locate(new_turf.x - i, new_turf.y + i + 1, new_turf.z)
			if(T) break
		if(!T)
			T = old_turf
		src.SetViewport(T)


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

/mob/proc/create_viewport(kind, title=null, size=8, share_planes=FALSE)
	RETURN_TYPE(/datum/viewport)
	var/list/viewports = client.getViewportsByType(kind)
	if(length(viewports) >= 5)
		boutput( src, "<b>You can only have up to 5 active viewports. Close an existing viewport to create another.</b>" )
		return

	var/datum/viewport/vp = new(src.client, kind, title, share_planes)
	var/turf/ourPos = get_turf(src)
	var/turf/startPos = null
	for(var/i = round(size / 2), i >= 0 || !startPos, i--)
		startPos = locate(ourPos.x - i, ourPos.y + i, ourPos.z)
		if(startPos) break
	vp.clickToMove = 1
	vp.SetViewport(startPos, size, size)
	return vp

/mob/living/intangible/aieye/verb/ai_eye_create_viewport()
	set category = "AI Commands"
	set name = "Create Viewport"
	set desc = "Expand your powers with Nanotrasen's Viewportifier!"

	src.create_viewport(VIEWPORT_ID_AI)

/mob/living/intangible/blob_overmind/verb/blob_create_viewport()
	set category = "Blob Commands"
	set name = "Create Viewport"
	set desc = "Expand your powers with BlobCorp's Viewportifier!"

	src.create_viewport(VIEWPORT_ID_BLOB)

/mob/living/intangible/blob_overmind/death()
	src.client?.clearViewportsByType(VIEWPORT_ID_BLOB)
	.=..()

/mob/living/silicon/ai/death(gibbed)
	src.client?.clearViewportsByType(VIEWPORT_ID_AI)
	.=..()


/client/proc/cmd_create_viewport()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Create Viewport"
	set desc = "Creates a cute little popout window to let you monitor an area, just like how AIs can."
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/datum/viewport/viewport = src.mob.create_viewport(VIEWPORT_ID_ADMIN, share_planes=TRUE)
	viewport.handler.listens = TRUE


/client/proc/cmd_create_viewport_following()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Create Viewport Following"
	set desc = "Creates a viewport that follows a selected atom."
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/atom/target_atom = pick_ref(src.mob)
	if(!target_atom || isturf(target_atom))
		boutput(src, SPAN_ALERT("No viewport target selected."))
		return

	var/datum/viewport/viewport = src.mob.create_viewport(VIEWPORT_ID_ADMIN, title = "Following: [target_atom.name]", size=9, share_planes=TRUE)
	viewport.handler.listens = TRUE
	viewport.start_following(target_atom)
