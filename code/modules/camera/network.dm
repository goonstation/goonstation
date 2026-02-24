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
	. = (T.camera_coverage_emitters && length(T.camera_coverage_emitters))
	#endif
