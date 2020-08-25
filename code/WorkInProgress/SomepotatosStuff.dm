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


/obj/landmark/gps_waypoint
	name = LANDMARK_GPS_WAYPOINT

/client/var/list/GPS_Path
/client/var/list/GPS_Images
/mob/proc/DoGPS(var/ID)
	if( client.GPS_Path )
		client.GPS_Path = null
		for( var/image/img in client.GPS_Images )
			client.images -= img
		client.GPS_Images = list()
		boutput( usr, "Path removed!" )
		return
	var/list/targets = list()
	var/list/wtfbyond = list()
	var/turf/OT = get_turf(src)
	for(var/turf/wp in landmarks[LANDMARK_GPS_WAYPOINT])
		var/path = AStar(OT, get_turf(wp), /turf/proc/AllDirsTurfsWithAccess, /turf/proc/Distance, adjacent_param = ID, maxtraverse=175)
		if(path)
			var/area/area = get_area(wp)
			var/name = area.name
			targets[name] = wp
			wtfbyond[++wtfbyond.len] = name

	if(!targets.len)
		boutput( usr, "No targets found! Try again later!" )
		return

	var/target = input("Choose a destination!") in wtfbyond|null
	if(!target || !src.client) return
	target = targets[target]
	var/turf/dest = target
	if(dest.z != OT.z)
		boutput(usr, "You are on a different z-level!")
		return
	OT = get_turf(src)
	client.GPS_Path = AStar( OT, dest, /turf/proc/AllDirsTurfsWithAccess, /turf/proc/Distance, adjacent_param = ID, maxtraverse=175 )
	if( client.GPS_Path )
		boutput( usr, "Path located! Use the GPS verb again to clear the path!" )
	else
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
			img.layer = 101
			img.color = "#5555ff"
			var/D1=turn(angle2dir(get_angle(next, t)),180)
			var/D2=turn(angle2dir(get_angle(prev,t)),180)
			if(D1>D2)
				D1=D2
				D2=turn(angle2dir(get_angle(next, t)),180)
			img.icon_state = "[D1]-[D2]"
			client.images += img
			client.GPS_Images[++client.GPS_Images.len] = img
			img.alpha=0
			var/matrix/xf = matrix()
			img.transform = xf/2
			animate(img,alpha=255,transform=xf,time=2)
			sleep(0.1 SECONDS)

/mob/living/carbon/verb/GPS()
	set name = "GPS"
	set category = "Commands"
	set desc = "Find your way around with ease!"
	if(ON_COOLDOWN(src, /mob/living/carbon/verb/GPS, 10 SECONDS))
		boutput(src, "Verb on cooldown for [time_to_text(ON_COOLDOWN(src, /mob/living/carbon/verb/GPS, 0))].")
		return
	if(hasvar(src,"wear_id"))
		DoGPS(src:wear_id)
/mob/living/silicon/verb/GPS()
	set name = "GPS"
	set category = "Commands"
	set desc = "Find your way around with ease!"
	if(ON_COOLDOWN(src, /mob/living/silicon/verb/GPS, 10 SECONDS)) // using ..... is very wacked
		boutput(src, "Verb on cooldown for [time_to_text(ON_COOLDOWN(src, /mob/living/silicon/verb/GPS, 0))].")
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
	for(var/obj/machinery/camera/C in by_type[/obj/machinery/camera])
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
	invisibility = 9
	see_invisible = 9
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
			dir = get_dir(loc, NewLoc)
			src.set_loc(NewLoc)
		else

			dir = direct
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
	for(var/obj/machinery/camera/C in by_type[/obj/machinery/camera])
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
	New()
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
