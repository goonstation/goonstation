/*TODO: Refactor code so we can just change the head/chest sprite.. frown.
/datum/mutantrace/kudzu
	name = "kudzu"
	override_eyes = 0
	override_hair = 0
	override_beard = 0
	override_detail = 0
	override_attack = 0
	icon = 'icons/mob/human.dmi'
	icon_state = "chest_plant"
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/left/synth
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/right/synth

/datum/bioEffect/mutantrace/kudzu
	name = "Bioplant Assimilation"
	desc = "Turns you into a plant."
	id = "kudzu"
	mutantrace_option = "kudzu"
	mutantrace_path = /datum/mutantrace/kudzu
	msgGain = "You feel like you're developing a green thumb!"
	msgLose = "You've lost all urge to be a vine. Weird."
	probability = 0
	occur_in_genepools = 0
	scanner_visibility = 0
	curable_by_mutadone = 0
	can_reclaim = 0
	can_copy = 0
	can_scramble = 0
	can_research = 0
	can_make_injector = 0
	reclaim_fail = 100*/
/*
/obj/item/wheel
	name = "wheel"
	desc = "The wheels on the bus used to go round and round until the syndicate caught wind of the bus."

	afterattack(var/atom/what, var/mob/user )
		if(istype( what, /obj/machinery/bathtub ))
			var/obj/machinery/bathtub/B = what
			B.wheels = src
			boutput( user, "<span class='notice'>You attach the [CLEAN(src)] to the [CLEAN(what)].</span>" )
		*/

/// Define: GPS_MAP_TESTING
/// Enable definition to provide the following information for MAP review when the GPS verb is used:
/// * Sorted List of GPS Waypoints
/// * Duplicate GPS waypoints with the same name (provides X,Y)
/// * List of AREAs that would NOT be listed in GPS list due to distance and what criteria would allow them to be (up to 1000 iterations)
//#define GPS_MAP_TESTING


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
	var/turf/OT = get_turf(src)
	var/list/paths = get_path_to(OT, landmarks[LANDMARK_GPS_WAYPOINT], max_distance=120, id=ID, skip_first=FALSE, cardinal_only=FALSE)

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
				path = get_path_to(OT, get_turf(wp), max_distance=max_trav, id=ID, skip_first=FALSE)
				if(path)
					boutput( usr, "Area ([area.name]) found in [length(path)] with maxtraverse of [max_trav]" )
					break

	var/list/sorted_names = list()
	for(var/turf/wp in landmarks[LANDMARK_GPS_WAYPOINT])
		sorted_names += landmarks[LANDMARK_GPS_WAYPOINT][wp]
	sorted_names = sortList(sorted_names)
	boutput( usr, "::Sorted GPS Waypoints::" )
	for(var/N in sorted_names)
		boutput( usr, "[N]" )
#endif

	if(!targets.len)
		boutput( usr, "No targets found! Try again later!" )
		return

	var/target = input("Choose a destination!") in wtfbyond|null
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
	SPAWN_DBG(0)
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
/*
/client
	show_popup_menus = 0
	Click( obj, loc, control, params )
		world << params
		params=params2list(params)//WHY DO WE HAVE TO DO THIS ITS 2016
		if( params["right"] )
			world << isloc(loc)
			if(isloc(loc))
				//proc/show(atom/movable/thing, params = null, title = null, content = null,
				loc = get_turf(loc)
				var/body = "Tobtext Menu<br/>"
				body += "[bicon(loc)] [html_encode(loc:name)]<br/>"
				for(var/vurb in loc:verbs)
					body += "--[vurb:name]<br/>"
				for(var/atom/thing in loc:contents)
					body += "[bicon(thing)] [html_encode(thing:name)]<br/>"
					for(var/vurb in thing:verbs)
						body += "--[vurb:name]<br/>"
				boutput(world, body)
				tooltip.show( loc, params, null, body )
			else
				return ..()
		else
			return ..()
*/
//*
/*
var/aiDirty = 2
/turf/var/image/aiImage
/turf/var/cameraTotal = 0

world/proc/updateCameraVisibility()
	if(!aiDirty) return
	if(aiDirty == 2)
		for(var/turf/t in world)//ugh
			if( t.z != 1 ) continue
			t.aiImage = image('icons/misc/static.dmi', t, "static", 100)
			t.aiImage.color = "#777777"
			t.aiImage.override = 1
			t.aiImage.name = " "
		aiDirty = 1
	for_by_tcl(C, /obj/machinery/camera)
		for(var/turf/t in view(7, C))
			//var/dist = get_dist(t, C)
			t.aiImage.alpha = 0
			t.aiImage.override = 0
			t.aiImage.icon_state = "blank"
	aiDirty = 0

/obj/machinery/camera/disposing()
	//world << "Camera deleted! @ [src.loc]"
	for(var/turf/t in view(7,get_turf(src)))
		t.cameraTotal=max(t.cameraTotal-1,0)
		if(!t.cameraTotal && t.aiImage)
			t.aiImage.override = 1
			t.aiImage.alpha = 255
			t.aiImage.icon_state = "static"
	..()
/obj/machinery/camera/New()
	..()
	for(var/turf/t in view(7,get_turf(src)))
		if(!t.cameraTotal && t.aiImage)
			t.aiImage.override = 0
			t.aiImage.alpha = 0
			t.aiImage.icon_state = "blank"
		t.cameraTotal++

/turf/MouseEntered()
	if(istype(usr,/mob/dead/aieye))//todo, make this a var for cheapernesseress?
		if(aiImage)
			usr.client.show_popup_menus = !!cameraTotal

/client/Click(thing)
	if(isturf(thing) && istype(src.mob,/mob/dead/aieye) && !thing:cameraTotal)
		return
	return ..()
/mob/dead/aieye
	name = "AI Eyeball"
	icon = 'icons/mob/ai.dmi'
	icon_state = "a-eye"
	invisibility = INVIS_AI_EYE
	see_invisible = INVIS_AI_EYE
	layer = 101
	see_in_dark = SEE_DARK_FULL

	New()
		..()
		world.updateCameraVisibility()
		sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	Login()
		.=..()
	Logout()
		for( var/turf/t in world )
			if( t.aiImage )
				last_client.images -= t.aiImage
		.=..()
	Move(NewLoc, direct)//Ewww!
		if (!isturf(src.loc))
			src.set_loc(get_turf(src))
		if (NewLoc)
			set_dir(get_dir(loc, NewLoc))
			src.set_loc(NewLoc)
		else

			set_dir(direct)
			if((direct & NORTH) && src.y < world.maxy)
				src.y++
			if((direct & SOUTH) && src.y > 1)
				src.y--
			if((direct & EAST) && src.x < world.maxx)
				src.x++
			if((direct & WEST) && src.x > 1)
				src.x--
		for(var/turf/t in range(client.view,src))
			if(istype(t.aiImage))
				client.images += t.aiImage

	is_spacefaring()
		return 1
	movement_delay()
		if (src.client && src.client.check_key(KEY_RUN))
			return 0.4
		else
			return 0.75

	say(var/message)
		visible_message("[CLEAN(src)] says, <b>[CLEAN(message)]</b>")

/atom/RL_SetOpacity(newopacity)
	if( opacity == newopacity ) return
	.=..()
	for(var/turf/t in range(7, src))
		t.cameraTotal = 0
	for_by_tcl(C, /obj/machinery/camera)
		if( get_dist(C.loc, src) <= 7 )
			var/list/inview = view(7,C)
			for(var/turf/t in range(7, C))
				if( !t.aiImage ) continue
				//var/dist = get_dist(t, C)
				if( t in inview )
					t.cameraTotal++
				else
					t.cameraTotal = max(t.cameraTotal-1,0)

				if( t.cameraTotal == 1 )
					t.aiImage.alpha = 0
					t.aiImage.override = 0
					t.aiImage.icon_state = "blank"
				else if( t.cameraTotal == 0 )
					t.aiImage.alpha = 255
					t.aiImage.override = 1
					t.aiImage.icon_state = "static"
*/
//*/

/obj/somepotato/lathe
	name = "Lathe"
	desc = "A 1969 LeBlond Lathe. Huh."
/obj/somepotato/vfd
	name = "Variable Frequency Drive"
	desc = "To avoid arousing too much suspicion, this fella converts single-phase power to three-phase. Sure, that power is passed down via a 24 AWG USB cable, but it's probably fine."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "vfd"
/obj/somepotato/billiards
	name = "Billiards Table"
	desc = "Who in God's name would get enjoyment at beating polyester spheres with wooden sticks???"
	//icon = 'icons/obj/pooltable.dmi'


/turf/unsimulated/floor/wood/two/trap
	desc = "It looks strangely clean compared to the rest of the floor."

	proc/open()
		animate(src, easing=BACK_EASING, time=10, pixel_x=-32)
		visible_message( "The [src] opens up to reveal a ladder!" )
		var/obj/ladder/ladder = new(src)
		ladder.id = "kremlin"
		ladder.layer = src.layer - 1
		ladder.plane = src.plane
		ladder.tag = "ladder_kremlin0"
	Click()
		if(!(locate(/obj/ladder) in src) && !isdead(usr))
			open()
