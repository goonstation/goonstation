/obj/machinery/camera
	name = "security camera"
	desc = "A small, high quality camera equipped with face and ID recognition. It is tied into a computer system, allowing AI and those with access to watch what occurs through it."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	text = ""

	var/network = "SS13"
	layer = EFFECTS_LAYER_UNDER_1
	var/c_tag = null
	var/c_tag_order = 999
	var/camera_status = TRUE
	anchored = ANCHORED
	var/invuln = null
	var/last_paper = 0
	///Cameras only the AI can see through
	var/ai_only = FALSE
	///Cant be snipped by wirecutters
	var/reinforced = FALSE

	//This camera is a node pointing to the other bunch of cameras nearby for AI movement purposes
	var/obj/machinery/camera/c_north = null
	var/obj/machinery/camera/c_east = null
	var/obj/machinery/camera/c_west = null
	var/obj/machinery/camera/c_south = null

	//Here's a list of cameras pointing to this camera for reprocessing purposes
	var/list/obj/machinery/camera/referrers = list()

	/// Robust light
	var/datum/light/point/light

	ranch
		name = "autoname"
		network = "ranch"
		color = "#AAFF99"
		c_tag = "autotag"

/obj/machinery/camera/television
	name = "television camera"
	desc = "A bulky stationary camera for wireless broadcasting of live feeds."
	network = "Zeta" // why not.
	icon_state = "television"
	anchored = ANCHORED
	density = 1
	reinforced = TRUE
	var/securedstate = 2

/obj/machinery/camera/television/attackby(obj/item/W, mob/user)
	..()
	if (isscrewingtool(W)) //to move them
		if (securedstate && src.securedstate >= 1)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 30, 1, -2)
			actions.start(new/datum/action/bar/icon/cameraSecure(src, securedstate), user)
		else if (securedstate)
			boutput(user, "<span class='alert'>You need to secure the floor bolts!</span>")
	else if (iswrenchingtool(W))
		if (src.securedstate <= 1)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 30, 1, -2)
			boutput(user, "<span class='alert'>You [securedstate == 1 ? "un" : ""]secure the floor bolts on the [src].</span>")
			src.securedstate = (securedstate == 1) ? 0 : 1

			if (securedstate == 0)
				src.anchored = UNANCHORED
			else
				src.anchored = ANCHORED

/datum/action/bar/icon/cameraSecure //This is used when you are securing a non-mobile television camera
	duration = 150
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "cameraSecure"
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	icon_state = "screwdriver"
	var/obj/machinery/camera/television/cam
	var/secstate

	New(Camera, Secstate)
		cam = Camera
		secstate = Secstate
		..()

	onStart()
		..()
		for(var/mob/O in AIviewers(owner))
			O.show_message(text("<span class='notice'>[] begins [secstate == 2 ? "un" : ""]securing the camera hookups on the [cam].</span>", owner), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, "<span class='alert'>You were interrupted!</span>")

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner.name] [secstate == 2 ? "un" : ""]secures the camera hookups on the [cam].</span>")
		cam.securedstate = (secstate == 2) ? 1 : 2
		if (cam.securedstate != 2)
			cam.UnsubscribeProcess()
		else
			cam.SubscribeToProcess()

/obj/machinery/camera/television/mobile
	name = "mobile television camera"
	desc = "A bulky mobile camera for wireless broadcasting of live feeds."
	anchored = UNANCHORED
	icon_state = "mobilevision"
	securedstate = null //No bugginess thank you

/obj/machinery/camera/New()
	..()
	var/area/area = get_area(src)
	//if only these had a common parent...
	var/list/aiareas = list(/area/station/turret_protected/ai,
							/area/station/turret_protected/ai_upload,
							/area/station/turret_protected/AIsat,
							/area/station/turret_protected/AIbasecore1)
	if (locate(area) in aiareas)
		src.ai_only = TRUE

	AddComponent(/datum/component/camera_coverage_emitter)

	src.light = new /datum/light/point
	src.light.set_brightness(0.3)
	src.light.set_color(209/255, 27/255, 6/255)
	src.light.attach(src)
	src.light.enable()

	START_TRACKING
	SPAWN(1 SECOND)
		addToNetwork()

/obj/machinery/camera/proc/set_camera_status(status)
	src.camera_status = status
	var/datum/component/camera_coverage_emitter/emitter = GetComponent(/datum/component/camera_coverage_emitter)
	emitter.set_active(src.camera_status)

/obj/machinery/camera/proc/update_coverage()
	PRIVATE_PROC(TRUE)
	var/datum/component/camera_coverage_emitter/emitter = GetComponent(/datum/component/camera_coverage_emitter)
	camera_coverage_controller.update_emitter(emitter)

/obj/machinery/camera/proc/addToNetwork()

	if(camnets[network])
		var/list/net = camnets[network]
		net.Add(src)
	else
		var/list/net = list()
		net.Add(src)
		camnets[network] = net

/obj/machinery/camera/proc/addToReferrers(var/obj/machinery/camera/C) //Safe addition
	referrers |= C

/obj/machinery/camera/proc/removeNode(var/obj/machinery/camera/node) //Completely remove a node from this camera
	for(var/N in list("c_north", "c_east", "c_south", "c_west"))
		if(node == vars[N])
			vars[N] = null
	node.referrers -= src

/obj/machinery/camera/proc/hasNode(var/obj/machinery/camera/node)
	if(!istype(node)) return 0
	. = 0
	. = (node == c_north) + (node == c_east) + (node == c_south) + (node == c_west)


/obj/machinery/camera/disposing()
	STOP_TRACKING
	if(src.camera_status)
		src.set_camera_status(FALSE)

	if(camnets && camnets[network])
		camnets[network].Remove(src)

	if (c_north)
		c_north.referrers -= src
	if (c_east)
		c_east.referrers -= src
	if (c_south)
		c_south.referrers -= src
	if (c_west)
		c_west.referrers -= src

	for(var/obj/machinery/camera/C as anything in referrers)
		if (C.c_north == src)
			C.c_north = null
		if (C.c_east == src)
			C.c_east = null
		if (C.c_south == src)
			C.c_south = null
		if (C.c_west == src)
			C.c_west = null
		//C.removeNode(src)

	src.referrers = null

	..()

	dirty_cameras |= referrers
	camnet_needs_rebuild = 1

	//logTheThing(LOG_DEBUG, null, "<B>SpyGuy/Camnet:</B> Camera destroyed. Camera network needs a rebuild! Number of dirty cameras: [dirty_cameras.len]")
	//connect_camera_list(referrers)


/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		update_coverage() // explosion happened, probably destroyed nearby turfs, better rebuild
		..(severity)
	return

/obj/machinery/camera/emp_act()
	..()
	if(!src.network) return //avoid stacking emp
	if(!istype(src, /obj/machinery/camera/television)) //tv cams were getting messed up
		src.icon_state = "cameraemp"
	src.network = null                   //Not the best way but it will do. I think.
	camera_status--

	SPAWN(90 SECONDS)
		camera_status++
		src.network = initial(src.network)
		if(!istype(src, /obj/machinery/camera/television))
			src.icon_state = initial(src.icon_state)

		update_coverage()

	src.disconnect_viewers()
	return

/obj/machinery/camera/blob_act(var/power)
	return

/obj/machinery/camera/attack_ai(var/mob/living/silicon/ai/user as mob)
	if (!istype(user)) //Other silicon mobs shouldn't try to encroach on the AI's "view through all cameras" schtick.  Mostly because it generates runtime errors.
		return
	if (src.network != user.network || !(src.camera_status))
		return
	//if (istype(user, /mob/living/silicon/ai/hologram))
	//	return
	user.current = src
	user.set_eye(src)

// here there was an antisemitic joke, commented out, that persisted until february 27 2020. Why the fuck it lasted so many years really puts ones morals into question.

/obj/machinery/camera/proc/disconnect_viewers()
	for(var/mob/O in mobs)
		/* Not needed with new AI cam system
		if (isAI(O))
			var/mob/living/silicon/ai/OAI = O
			if (OAI && OAI.current == src)
				if( OAI.camera_overlay_check(src) )
					boutput(OAI, "Your regain your connection to the camera.")
				else
					boutput(OAI, "Your connection to the camera has been lost.")
		*/
		var/obj/machinery/computer/security/S = O.using_dialog_of_type(/obj/machinery/computer/security)
		if (S)
			if (S.current == src)
				S.remove_dialog(O)
				S.current = null
				O.set_eye(null)
				boutput(O, "The screen bursts into static.")

/obj/machinery/camera/proc/break_camera(mob/user)
	src.set_camera_status(FALSE)
	playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
	src.icon_state = "camera1"
	src.light.disable()
	if (user)
		user.visible_message("<span class='alert'>[user] has deactivated [src]!</span>", "<span class='alert'>You have deactivated [src].</span>")
		logTheThing(LOG_STATION, null, "[key_name(user)] deactivated a security camera ([log_loc(src.loc)])")
		add_fingerprint(user)

/obj/machinery/camera/proc/repair_camera(mob/user)
	src.set_camera_status(TRUE)
	playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
	src.icon_state = "camera"
	src.light.enable()
	if (user)
		user.visible_message("<span class='alert'>[user] has reactivated [src]!</span>", "<span class='alert'>You have reactivated [src].</span>")
		add_fingerprint(user)

/obj/machinery/camera/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/parts/human_parts)) //dumb easter egg incoming
		user.visible_message("<span class='alert'>[user] wipes [src] with the bloody end of [W.name]. What the fuck?</span>", "<span class='alert'>You wipe [src] with the bloody end of [W.name]. What the fuck?</span>")
		return

	if (issnippingtool(W) && !src.reinforced)
		if (src.camera_status)
			src.break_camera(user)
		else
			src.repair_camera(user)
		// now disconnect anyone using the camera
		src.disconnect_viewers()
		return

	if (!src.camera_status)
		return

	if (istype(W, /obj/item/paper))
		if (last_paper && ( (last_paper + 80) >= world.time))
			return
		last_paper = world.time
		var/obj/item/paper/X = W
		boutput(user, "You hold a paper up to the camera ...")
		for(var/mob/O in mobs)
			if (isAI(O))
				boutput(O, "[user] holds a paper up to one of your cameras ...")
				O.Browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", X.name, X.info), text("window=[]", X.name))
				logTheThing(LOG_STATION, user, "holds up a paper to a camera at [log_loc(src)], forcing [constructTarget(O,"station")] to read it. <b>Title:</b> [X.name]. <b>Text:</b> [adminscrub(X.info)]")
			else
				var/obj/machinery/computer/security/S = O.using_dialog_of_type(/obj/machinery/computer/security)
				if (S)
					if (S.current == src)
						boutput(O, "[user] holds a paper up to one of the cameras ...")
						O.Browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", X.name, X.info), text("window=[]", X.name))
						logTheThing(LOG_STATION, user, "holds up a paper to a camera at [log_loc(src)], forcing [constructTarget(O,"station")] to read it. <b>Title:</b> [X.name]. <b>Text:</b> [adminscrub(X.info)]")

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(var/mob/M)
	.= 0
	if (isturf(M.loc))
		var/turf/T = M.loc
		. = (T.camera_coverage_emitters && length(T.camera_coverage_emitters))

/obj/machinery/camera/motion
	name = "Motion Security Camera"
	var/list/motionTargets = list()
	var/detectTime = 0
	var/locked = 1

/obj/machinery/camera/motion/process()
	// motion camera event loop
	. = ..()
	if (detectTime > 0)
		var/elapsed = world.time - detectTime
		if (elapsed > 300)
			triggerAlarm()
	else if (detectTime == -1)
		for (var/mob/target in motionTargets)
			if (isdead(target)) lostTarget(target)

/obj/machinery/camera/motion/proc/newTarget(var/mob/target)
	if (isAI(target)) return 0
	if (detectTime == 0)
		detectTime = world.time // start the clock
	if (!(target in motionTargets))
		motionTargets += target
	return 1

/obj/machinery/camera/motion/proc/lostTarget(var/mob/target)
	if (target in motionTargets)
		motionTargets -= target
	if (motionTargets.len == 0)
		cancelAlarm()

/obj/machinery/camera/motion/proc/cancelAlarm()
	if (detectTime == -1)
		for (var/mob/living/silicon/aiPlayer in mobs)
			if (camera_status) aiPlayer.cancelAlarm("Motion", src.loc.loc)
	detectTime = 0
	return 1

/obj/machinery/camera/motion/proc/triggerAlarm()
	if (!detectTime) return 0
	for (var/mob/living/silicon/aiPlayer in mobs)
		if (camera_status) aiPlayer.triggerAlarm("Motion", src.loc.loc, src)
	detectTime = -1
	return 1

/obj/machinery/camera/motion/attackby(obj/item/W, mob/user)
	if (issnippingtool(W) && locked == 1) return
	if (isscrewingtool(W))
		var/turf/T = user.loc
		boutput(user, text("<span class='notice'>[]ing the access hatch... (this is a long process)</span>", (locked) ? "Open" : "Clos"))
		sleep(10 SECONDS)
		if ((user.loc == T && user.equipped() == W && !( user.stat )))
			src.locked ^= 1
			boutput(user, text("<span class='notice'>The access hatch is now [].</span>", (locked) ? "closed" : "open"))

	..() // call the parent to (de|re)activate

	if (issnippingtool(W)) // now handle alarm on/off...
		if (camera_status) // ok we've just been reconnected... send an alarm!
			detectTime = world.time - 301
			triggerAlarm()
		else
			for (var/mob/living/silicon/aiPlayer in mobs) // manually cancel, to not disturb internal state
				aiPlayer.cancelAlarm("Motion", src.loc.loc)




/*------------------------------------
		CAMERA NETWORK STUFF
------------------------------------*/

/proc/name_autoname_cameras()
	var/list/counts_by_area = list()
	var/list/obj/machinery/camera/first_cam_by_area = list()
	for(var/obj/machinery/camera/C as anything in by_type[/obj/machinery/camera])
		if(!istype(C)) continue
		if (dd_hasprefix(C.name, "autoname"))
			var/area/where = get_area(C)
			if (isarea(where))
				C.name = "security camera"
				if(!dd_hasprefix(C.c_tag, "autotag"))
					continue
				if(!counts_by_area[where])
					counts_by_area[where] = 1
					C.c_tag = "[where.name]"
					first_cam_by_area[where] = C
				else
					if(counts_by_area[where] == 1)
						first_cam_by_area[where].c_tag = "[where.name] 1"
					counts_by_area[where]++
					C.c_tag = "[where.name] [counts_by_area[where]]"

/proc/build_camera_network()
	name_autoname_cameras()
	var/list/cameras = by_type[/obj/machinery/camera]
	if (!isnull(cameras))
		connect_camera_list(cameras)

/proc/rebuild_camera_network()
	if(defer_camnet_rebuild || !camnet_needs_rebuild) return

	connect_camera_list(dirty_cameras)
	dirty_cameras.Cut()
	camnet_needs_rebuild = 0

/proc/disconnect_camera_network()
	for_by_tcl(C, /obj/machinery/camera)
		C.c_north = null
		C.c_east = null
		C.c_south = null
		C.c_west = null
		C.referrers.Cut()

/proc/connect_camera_list(var/list/obj/machinery/camera/camlist, var/force_connection=0)
	if(!length(camlist))  return 1

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
	var/dir_var = "" //The direction we're trying to fill
	var/rec_var = "" //The reciprocal of this direction

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
		/*
		if(!candidate)
			logTheThing(LOG_DEBUG, null, "<B>SpyGuy/Camnet:</B> Camera at [log_loc(C)] didn't get a candidate when heading [dir2text(direction)].")
			return
		*/
		if(candidate && C.z == candidate.z && C.network == candidate.network) // && (!camera_network_reciprocity || !candidate.vars[rec_var]))
			C.vars[dir_var] = candidate
			candidate.addToReferrers(C)

			if(camera_network_reciprocity && (!candidate.vars[rec_var]))
				candidate.vars[rec_var] = C
				C.addToReferrers(candidate)
/*
		else
			logTheThing(LOG_DEBUG, null, "<B>SpyGuy/Camnet:</B> Camera at [log_loc(C)] rejected. cand z = [candidate.z], C z = [C.z]; cand net = [candidate.network], C net = [C.network]; reciprocity = [camera_network_reciprocity], rec_var:[rec_var] ( [isnull(candidate.vars[rec_var]) ? "null" : "not null"] )")
	else
		logTheThing(LOG_DEBUG, null, "<B>SpyGuy/Camnet:</B> Camera at [log_loc(C)] rejected because [dir_var] was already set.")
		*/
