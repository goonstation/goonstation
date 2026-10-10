/*------------------------------------
		CAMERA NETWORK STUFF
------------------------------------*/

/proc/assign_camera_tag(obj/machinery/camera/camera)
	var/area/camera_area = get_area(camera)
	if (!camera_area)
		return

	var/highest_number = 0
	for (var/obj/machinery/camera/other_camera as anything in by_type[/obj/machinery/camera])
		if (other_camera == camera || get_area(other_camera) != camera_area || !other_camera.c_tag)
			continue
		if (other_camera.c_tag == camera_area.name)
			highest_number = max(highest_number, 1)
		else if (copytext(other_camera.c_tag, 1, length(camera_area.name) + 2) == "[camera_area.name] ")
			highest_number = max(highest_number, text2num(copytext(other_camera.c_tag, length(camera_area.name) + 2)))

	camera.c_tag = "[camera_area.name] [highest_number + 1]"

/proc/setup_cameras(var/cameras)
	var/list/counts_by_tag = list()
	var/list/obj/machinery/camera/first_cam_by_tag = list()
	for (var/obj/machinery/camera/C as anything in cameras)
		var/tag_we_use = null

		if (isnull(C.c_tag) || dd_hasprefix(C.c_tag, "autotag"))
			assign_camera_tag(C)
			tag_we_use = C.c_tag
		else
			tag_we_use = C.c_tag

		if (!counts_by_tag[tag_we_use])
			counts_by_tag[tag_we_use] = 1
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
