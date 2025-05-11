/*------------------------------------
		CAMERA NETWORK STUFF
------------------------------------*/

/proc/setup_cameras(var/cameras)
	var/list/counts_by_tag = list()
	var/list/obj/machinery/camera/first_cam_by_tag = list()
	for (var/obj/machinery/camera/C as anything in cameras)
		var/area/where = get_area(C)
		var/name_build_string = ""
		var/tag_we_use = null
		if (dd_hasprefix(C.name, "autoname"))
			if (C.prefix)
				name_build_string += "[C.prefix] "
			name_build_string += "camera"
			if (C.uses_area_name)
				name_build_string += " - [where.name]"
			C.name = name_build_string

		if (isnull(C.c_tag) || dd_hasprefix(C.c_tag, "autotag"))
			tag_we_use = where.name
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
		connect_camera_list(cameras)
		setup_cameras(cameras)

/proc/rebuild_camera_network()
	if(defer_camnet_rebuild || !camnet_needs_rebuild) return

	connect_camera_list(dirty_cameras)
	dirty_cameras.len = 0
	camnet_needs_rebuild = 0

/proc/disconnect_camera_network()
	for_by_tcl(C, /obj/machinery/camera)
		C.c_north = null
		C.c_east = null
		C.c_south = null
		C.c_west = null
		C.referrers.len = 0

/proc/connect_camera_list(var/list/obj/machinery/camera/camlist, var/force_connection=0)
	if(!length(camlist)) return 1

	logTheThing(LOG_DEBUG, null, "<B>SpyGuy/Camnet:</B> Starting to connect cameras")
	var/count = 0
	for(var/obj/machinery/camera/C as anything in camlist)
		if(QDELETED(C) || !isturf(C.loc)) //This is one of those weird internal cameras, or it's been deleted and hasn't had the decency to go away yet
			continue


		connect_camera_neighbours(C, NORTH, force_connection)
		connect_camera_neighbours(C, EAST, force_connection)
		connect_camera_neighbours(C, SOUTH, force_connection)
		connect_camera_neighbours(C, WEST, force_connection)
		count++

		if(!(C.c_north || C.c_east || C.c_south || C.c_west))
			logTheThing(LOG_DEBUG, null, "<B>SpyGuy/Camnet:</B> Camera at [log_loc(C)] failed to receive cardinal directions during initialization.")

	logTheThing(LOG_DEBUG, null, "<B>SpyGuy/Camnet:</B> Done. Connected [count] cameras.")

	return 0

/proc/connect_camera_neighbours(var/obj/machinery/camera/C, var/direction, var/force_connection=0)
	var/dir_var = "" //! The direction we're trying to fill
	var/rec_var = "" //! The reciprocal of this direction

	if(direction & NORTH)
		dir_var = "c_north"
		rec_var = "c_south"
	else if(direction & EAST)
		dir_var ="c_east"
		rec_var = "c_west"
	else if(direction & SOUTH)
		dir_var = "c_south"
		rec_var = "c_north"
	else if(direction & WEST)
		dir_var = "c_west"
		rec_var = "c_east"

	if(!dir_var) return


	if(!C.vars[dir_var] || force_connection)
		var/obj/machinery/camera/candidate = null
		candidate = getCameraMove(C, direction)
		if(candidate && C.z == candidate.z && C.network == candidate.network) // && (!camera_network_reciprocity || !candidate.vars[rec_var]))
			C.vars[dir_var] = candidate
			candidate.addToReferrers(C)

			if(camera_network_reciprocity && (!candidate.vars[rec_var]))
				candidate.vars[rec_var] = C
				C.addToReferrers(candidate)

/// Return true if mob is on a turf with camera coverage
/proc/seen_by_camera(var/mob/M)
	var/turf/T = get_turf(M)
	. = (T.camera_coverage_emitters && length(T.camera_coverage_emitters))
