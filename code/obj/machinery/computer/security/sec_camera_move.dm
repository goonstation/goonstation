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


/proc/getCameraMove(var/atom/old, var/direct, var/skip_disabled = 0)
	var/min_dist = 1e8
	var/obj/machinery/camera/closest = null

	if(!old) return

	var/dx = 0
	var/dy = 0
	if(direct & NORTH)
		dy = 1
	else if(direct & SOUTH)
		dy = -1
	if(direct & EAST)
		dx = 1
	else if(direct & WEST)
		dx = -1

	var/obj/machinery/camera/oldcam = old

	var/area/A = get_area(old)
	if (!A)
		return

	var/list/old_types = splittext("[A.type]", "/")

	for_by_tcl(current, /obj/machinery/camera)
		if(old.z != current.z)
			continue
		//make sure it's the right direction
		if(dx && (current.x * dx <= old.x * dx))
			continue
		if(dy && (current.y * dy <= old.y * dy))
			continue

		if(skip_disabled && !current.status)
			continue	//	ignore disabled cameras

		if(istype(oldcam) && oldcam.network != current.network)
			continue

		var/shared_types = 0 //how many levels deep the old camera and the closest camera's areas share
		//for instance, /area/A and /area/B would have shared_types = 2 (because of how dd_text2list works)
		//whereas area/A/B and /area/A/C would have it as 3

		var/area/cur_area = get_area(current)
		if (!cur_area)
			continue

		var/list/new_types = splittext("[cur_area.type]", "/")
		for(var/i = 1; i <= old_types.len && i <= new_types.len; i++)
			if(old_types[i] == new_types[i])
				shared_types++
			else
				break

		//don't let it be too far from the current one in the axis perpindicular to the direction of travel,
		//but let it be farther from that if it's in the same area
		//something in the same hallway but farther away beats something in the same hallway

		var/distance = abs((current.y - old.y)/(CAMERA_PROXIMITY_PREFERENCE + abs(dy))) + abs((current.x - old.x)/(CAMERA_PROXIMITY_PREFERENCE + abs(dx)))
		distance -= SHARED_TYPES_WEIGHT * shared_types
		//weight things in the same area as this so they count as being closer - makes you stay in the same area
		//when possible
		if(istype(old, /obj/machinery/camera))
			distance += EXISTING_LINK_WEIGHT * old:hasNode(current)
		if(distance < min_dist)
			//closer, or this is in the same area and the current closest isn't
			min_dist = distance
			closest = current

	return closest


#undef SHARED_TYPES_WEIGHT
#undef CAMERA_PROXIMITY_PREFERENCE
#undef EXISTING_LINK_WEIGHT
