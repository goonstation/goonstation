//Really just moving this to a better location than mob/living/silicon/ai since I'm told that the original is unused. Will do after a bit

#define SHARED_TYPES_WEIGHT 0
//How important it is to us to stay in the same general area
#define CAMERA_PROXIMITY_PREFERENCE 0.5
// the smaller this is, the more a straight line will be preferred over a closer camera when changing cameras
// if you set this to 0 the game will crash. don't do that.
// if you set it to be negative the algorithm will do completely nonsensical things (like choosing the camera that's
// the farthest away). don't do that.
#define EXISTING_LINK_WEIGHT 10
//If there is an existing link to this camera


/proc/getCameraMove(obj/machinery/camera/oldcam, direct, skip_disabled = 0)
	if(!istype(oldcam))
		return
	var/min_dist = 1e8
	var/obj/machinery/camera/closest = null

	var/dx = 0
	var/dy = 0
	switch(direct)
		if(NORTH)
			dy = 1
		if(SOUTH)
			dy = -1
		if(EAST)
			dx = 1
		if(WEST)
			dx = -1
#if SHARED_TYPES_WEIGHT != 0
	var/area/A = get_area(oldcam)
	if (!A)
		return

	var/list/old_types = splittext("[A.type]", "/")
#endif
	for_by_tcl(current, /obj/machinery/camera)
		if(oldcam.z != current.z)
			continue
		//make sure it's the right direction
		if(dx && (current.x * dx <= oldcam.x * dx))
			continue
		if(dy && (current.y * dy <= oldcam.y * dy))
			continue

		if(skip_disabled && !current.status)
			continue	//	ignore disabled cameras

		if(oldcam.network != current.network)
			continue

	#if SHARED_TYPES_WEIGHT != 0
		var/shared_types = 0 //how many levels deep the old camera and the closest camera's areas share
		//for instance, /area/A and /area/B would have shared_types = 2 (because of how dd_text2list works)
		//whereas area/A/B and /area/A/C would have it as 3

		var/area/cur_area = get_area(current)
		if (!cur_area)
			continue

		var/list/new_types = splittext("[cur_area.type]", "/")
		for(var/i in 1 to min(length(old_types), length(new_types)))
			if(old_types[i] == new_types[i])
				shared_types++
			else
				break
	#endif
		//don't let it be too far from the current one in the axis perpindicular to the direction of travel,
		//but let it be farther from that if it's in the same area
		//something in the same hallway but farther away beats something in the same hallway

		var/distance = abs((current.y - oldcam.y)/(CAMERA_PROXIMITY_PREFERENCE + abs(dy))) + abs((current.x - oldcam.x)/(CAMERA_PROXIMITY_PREFERENCE + abs(dx)))
	#if SHARED_TYPES_WEIGHT != 0
		distance -= SHARED_TYPES_WEIGHT * shared_types
	#endif
		//weight things in the same area as this so they count as being closer - makes you stay in the same area
		//when possible
		distance += EXISTING_LINK_WEIGHT * oldcam.hasNode(current)
		if(distance < min_dist)
			//closer, or this is in the same area and the current closest isn't
			min_dist = distance
			closest = current

	return closest


#undef SHARED_TYPES_WEIGHT
#undef CAMERA_PROXIMITY_PREFERENCE
#undef EXISTING_LINK_WEIGHT
