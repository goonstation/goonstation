/*------------------------------------
		CAMERA NETWORK STUFF
------------------------------------*/

/proc/setup_cameras(var/cameras)
	var/list/counts_by_tag = list()
	var/list/obj/machinery/camera/first_cam_by_tag = list()
	for (var/obj/machinery/camera/C as anything in cameras)
		var/tag_we_use = null

		if (isnull(C.c_tag) || dd_hasprefix(C.c_tag, "autotag"))
			var/area/A = get_area(C)
			tag_we_use = A.name
		else
			tag_we_use = C.c_tag

		if (!counts_by_tag[tag_we_use])
			counts_by_tag[tag_we_use] = 1
			C.c_tag = "[tag_we_use]"
			first_cam_by_tag[tag_we_use] = C
		else
			if (counts_by_tag[tag_we_use] == 1)
				first_cam_by_tag[tag_we_use].c_tag = "[tag_we_use] 1"
			counts_by_tag[tag_we_use]++
			C.c_tag = "[tag_we_use] [counts_by_tag[tag_we_use]]"
		C.add_to_minimap()

/proc/build_camera_network()
	var/list/obj/machinery/camera/cameras = by_type[/obj/machinery/camera]
	if (!isnull(cameras))
		setup_cameras(cameras)

/// Return true if atom is a turf or on a turf with camera coverage
/proc/seen_by_camera(var/atom/atom)
	if(isarea(atom) || !atom)
		return FALSE
	if(!isturf(atom) && !isturf(atom.loc)) //Not on a turf, probably in a locker or something
		return FALSE
	#ifdef SKIP_CAMERA_COVERAGE
	return TRUE
	#else
	var/turf/T = atom
	if(!istype(T))
		T = get_turf(atom)
	if (!T.camera_coverage_emitters)
		return FALSE
	for (var/datum/component/camera_coverage_emitter/emitter as anything in T.camera_coverage_emitters)
		var/obj/machinery/camera/camera = emitter.parent
		if (ismob(atom) && camera && (atom:ckey in camera.emagged_by_ckeys))
			continue
		return TRUE
	return FALSE
	#endif

/// Updates the AI-only static mask for a mob covered exclusively by cameras that have been emagged by them.
/proc/update_camera_emag_visibility(mob/user)
	if (!user)
		return

	var/list/client/new_mask_viewers = list()
	var/has_camera_coverage = FALSE
	var/has_uncompromised_camera = FALSE
	if (user.ckey && isturf(user.loc))
		var/turf/user_turf = user.loc
		for (var/datum/component/camera_coverage_emitter/emitter as anything in user_turf.camera_coverage_emitters)
			if (!emitter || QDELETED(emitter) || !emitter.active)
				continue
			has_camera_coverage = TRUE
			var/obj/machinery/camera/camera = emitter.parent
			if (!camera || !(user.ckey in camera.emagged_by_ckeys))
				has_uncompromised_camera = TRUE
			else
				for (var/mob/viewer as anything in camera.viewers)
					if (viewer?.client)
						new_mask_viewers |= viewer.client

	var/should_mask = has_camera_coverage && !has_uncompromised_camera
	for (var/mob/living/silicon/ai/AI in mobs)
		var/client/ai_client = AI.client
		if (!ai_client)
			ai_client = AI.eyecam?.client
		if (!ai_client)
			ai_client = AI.deployed_shell?.client
		if (ai_client && (should_mask || is_camera_emagger_in_view(AI, user)))
			new_mask_viewers |= ai_client

	if (length(new_mask_viewers) && !user.camera_emag_mask)
		user.camera_emag_mask = image('icons/misc/static.dmi', user, "static")
		user.camera_emag_mask.plane = PLANE_HUD
		user.camera_emag_mask.layer = 102
		user.camera_emag_mask.color = "#777777"
		user.camera_emag_mask.appearance_flags = TILE_BOUND | KEEP_APART | RESET_TRANSFORM | RESET_ALPHA | RESET_COLOR | PIXEL_SCALE
		user.camera_emag_mask.override = TRUE

	if (user.camera_emag_mask)
		for (var/client/viewer as anything in user.camera_emag_mask_viewers)
			if (viewer && !(viewer in new_mask_viewers))
				viewer.images -= user.camera_emag_mask
		for (var/client/viewer as anything in new_mask_viewers)
			viewer.images |= user.camera_emag_mask
		user.camera_emag_mask_viewers = new_mask_viewers
		if (!length(new_mask_viewers))
			qdel(user.camera_emag_mask)
			user.camera_emag_mask = null
			user.camera_emag_mask_viewers = null

/// Returns whether the viewer is using a camera that is emagged by the target.
/proc/is_camera_emagger_in_view(mob/viewer, mob/target)
	if (!istype(target, /mob) || !target.ckey || !isturf(target.loc))
		return FALSE
	var/client/viewer_client = viewer?.client
	if (!viewer_client && isAI(viewer))
		var/mob/living/silicon/ai/AI = viewer
		viewer_client = AI.eyecam?.client
		if (!viewer_client)
			viewer_client = AI.deployed_shell?.client
	if (!viewer_client)
		return FALSE

	var/list/datum/component/camera_coverage_emitter/emitters = list()
	if (isAIeye(viewer))
		var/mob/living/intangible/aieye/eye = viewer
		if (!eye.mainframe)
			return FALSE
		emitters = eye.mainframe.currently_using_cameras()
	else if (istype(viewer, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = viewer
		emitters = AI.currently_using_cameras()
	else
		var/obj/machinery/camera/camera = viewer.client.eye
		if (istype(camera))
			emitters += camera.GetComponent(/datum/component/camera_coverage_emitter)

	var/turf/target_turf = get_turf(target)
	for (var/datum/component/camera_coverage_emitter/emitter as anything in emitters)
		if (!emitter || QDELETED(emitter) || !emitter.active || !(target_turf in emitter.coverage))
			continue
		var/obj/machinery/camera/camera = emitter.parent
		if (camera && (target.ckey in camera.emagged_by_ckeys))
			return TRUE
	return FALSE

/// Refresh static masks after an AI switches camera views.
/proc/update_camera_emag_visibility_for_all()
	var/list/mob/emagged_users = list()
	for (var/obj/machinery/camera/camera as anything in by_type[/obj/machinery/camera])
		emagged_users |= camera.emagged_users
	for (var/mob/user as anything in emagged_users)
		update_camera_emag_visibility(user)
