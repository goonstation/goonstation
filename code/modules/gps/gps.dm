/obj/landmark/gps_waypoint
	icon_state = "gps"
	name = LANDMARK_GPS_WAYPOINT
	name_override = LANDMARK_GPS_WAYPOINT

	New()
		if(name != name_override)
			src.data = name
		else
			var/area/area = get_area(src)
			src.data = area.name
		..()

/client/var/list/GPS_Path
/client/var/list/GPS_Images
/mob/proc/DoGPS(var/ID)
	if(removeGpsPath())
		return
	var/list/targets = list()
	var/list/wtfbyond = list()
	var/list/paths = get_path_to(src, landmarks[LANDMARK_GPS_WAYPOINT], max_distance=120, id=ID, skip_first=FALSE, cardinal_only=FALSE)

	for(var/turf/wp in paths)
		var/path = paths[wp]
		if(path)
			var/name = landmarks[LANDMARK_GPS_WAYPOINT][wp]
			if(!name)
				var/area/area = get_area(wp)
				name = area.name
#ifdef GPS_MAP_TESTING
			if(targets[name])
				boutput( usr, "*** Duplicate waypoint in ([name]): ([targets[name].x],[targets[name].y]) and ([wp.x],[wp.y])" )
#endif

			targets[name] = wp
			wtfbyond[++wtfbyond.len] = name

#ifdef GPS_MAP_TESTING
		else
			var/area/area = get_area(wp)
			var/max_trav
			boutput( usr, "Area ([area.name]) not found in 300 or not accessable" )
			for(max_trav=300; max_trav<500;max_trav=max_trav+100)
				path = get_path_to(src, get_turf(wp), max_distance=max_trav, id=ID, skip_first=FALSE)
				if(path)
					boutput( usr, "Area ([area.name]) found in [length(path)] with maxtraverse of [max_trav]" )
					break

	var/list/sorted_names = list()
	for(var/turf/wp in landmarks[LANDMARK_GPS_WAYPOINT])
		sorted_names += landmarks[LANDMARK_GPS_WAYPOINT][wp]
	sortList(sorted_names, /proc/cmp_text_asc)
	boutput( usr, "::Sorted GPS Waypoints::" )
	for(var/N in sorted_names)
		boutput( usr, "[N]" )
#endif

	if(!targets.len)
		boutput( usr, "No targets found! Try again later!" )
		return

	var/target = tgui_input_list(src, "Choose a destination!", "GPS Destination Pick", sortList(wtfbyond, /proc/cmp_text_asc))
	if(!target || !src.client) return
	target = targets[target]
	gpsToTurf(target, param = ID)

/mob/proc/gpsToTurf(var/turf/dest, var/doText = 1, param = null, cardinal_only=FALSE)
	removeGpsPath(doText)
	var/turf/start = get_turf(src)
	if(dest.z != start.z)
		if(doText)
			boutput(usr, "You are on a different z-level!")
		return
	client.GPS_Path = get_path_to(src, dest, max_distance = 120, id=src.get_id(), skip_first=FALSE, cardinal_only=cardinal_only)
	if(length(client.GPS_Path))
		if(doText)
			boutput( usr, "Path located! Use the GPS verb again to clear the path!" )
	else
		if(doText)
			boutput( usr, "Could not locate a path! Try moving around, or if its an area you don't have access to, get more access!" )
		return
	client.GPS_Images = list()
	SPAWN(0)
		var/list/path = client.GPS_Path
		for(var/i = 2, i < path.len, i++)
			if(!client.GPS_Path) break
			var/turf/prev = path[i-1]
			var/turf/t = path[i]
			var/turf/next = path[i+1]
			var/image/img = image('icons/obj/power_cond.dmi')

			img.loc = t
			img.layer = DECAL_LAYER
			img.plane = PLANE_NOSHADOW_BELOW

			img.color = "#5555ff"
			var/D1=turn(angle2dir(get_angle(next, t)),180)
			var/D2=turn(angle2dir(get_angle(prev,t)),180)
			if(D1>D2)
				D1=D2
				D2=turn(angle2dir(get_angle(next, t)),180)
			img.icon_state = "[D1]-[D2]"
			client.images += img
			client.GPS_Images[++client.GPS_Images.len] = img

			var/image/img2 = image('icons/obj/power_cond.dmi')
			img2.loc = img.loc
			img2.layer = img.layer
			img2.plane = PLANE_SELFILLUM
			img2.color = "#55a4ff"
			img2.icon_state = img.icon_state
			client.images += img2
			client.GPS_Images[++client.GPS_Images.len] = img2

			img.alpha=0
			var/matrix/xf = matrix()
			img.transform = xf/2
			animate(img, alpha= 255, transform=xf,time=2)

			img2.alpha = 0
			animate(img2, time = 0.5 SECONDS, loop = -1 ) //noop to delay for img and maintain illuminated state
			animate(alpha = 0, time = 2 SECONDS, loop = -1, easing = CUBIC_EASING | EASE_OUT )
			animate(alpha = 80, time = 1 SECONDS, loop = -1, easing = BACK_EASING | EASE_OUT )
			sleep(0.1 SECONDS)

/mob/proc/removeGpsPath(doText = 1)
	if( client.GPS_Path )
		client.GPS_Path = null
		for( var/image/img in client.GPS_Images )
			client.images -= img
		client.GPS_Images = list()
		if(doText)
			boutput( usr, "Path removed!" )
		return 1
	return 0

/mob/living/carbon/verb/GPS()
	set name = "GPS"
	set category = "Commands"
	set desc = "Find your way around with ease!"
	if(ON_COOLDOWN(src, "gps", 10 SECONDS))
		boutput(src, "Verb on cooldown for [time_to_text(ON_COOLDOWN(src, "gps", 0))].")
		return
	DoGPS(src.get_id())
/mob/living/silicon/verb/GPS()
	set name = "GPS"
	set category = "Commands"
	set desc = "Find your way around with ease!"
	if(ON_COOLDOWN(src, "gps", 10 SECONDS))
		boutput(src, "Verb on cooldown for [time_to_text(ON_COOLDOWN(src, "gps", 0 SECONDS))].")
		return
	DoGPS(src.botcard)
