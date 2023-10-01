/obj/machinery/camera
	name = "security camera"
	desc = "A small, high quality camera equipped with face and ID recognition. It is tied into a computer system, allowing AI and those with access to watch what occurs through it."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	text = ""

	var/network = "SS13"
	/// Used by autoname: EX "security camera"
	var/prefix = "security"
	/// Used by autoname: EX "camera - west primary hallway"
	var/uses_area_name = FALSE
	// These stack: EX "security camera - west primary hallway"
	layer = EFFECTS_LAYER_UNDER_1
	/// The camera tag which identifies this camera
	var/c_tag = null
	var/c_tag_order = 999
	var/camera_status = TRUE
	anchored = ANCHORED
	var/invuln = FALSE
	/// Cameras only the AI can see through
	var/ai_only = FALSE
	/// Cant be snipped by wirecutters
	var/reinforced = FALSE
	/// automatically offsets and snaps to perspective walls. Not for televisions or internal cameras.
	var/sticky = FALSE
	/// do auto position cameras use the alternate diagonal sprites?
	var/alternate_sprites = FALSE

	//This camera is a node pointing to the other bunch of cameras nearby for AI movement purposes
	var/obj/machinery/camera/c_north = null
	var/obj/machinery/camera/c_east = null
	var/obj/machinery/camera/c_west = null
	var/obj/machinery/camera/c_south = null

	//Here's a list of cameras pointing to this camera for reprocessing purposes
	var/list/obj/machinery/camera/referrers = list()

	/// Robust light
	var/datum/light/point/light

	/// The cameras viewer, for quickly disconnecting them when needed
	var/mob/viewer

	/*
	Autoname
	Set by having "autoname" anywhere in the name variable.
	Sets the name of the camera based on prefix and uses_area_name. Default is "camera".
 	prefix is attached as a prefix to "camera" and area name is attached as suffix seperated by -.

	Autotag
	Set by having "autotag" anywhere in the c_tag variable.
	Sets the tag of the camera to the name of the area.
	All cameras are tallied regardless of this tag to apply a number to them.
	*/

/obj/machinery/camera/New()
	..()
	START_TRACKING
	var/area/area = get_area(src)
	//if only these had a common parent...
	var/list/aiareas = list(/area/station/turret_protected/ai,
							/area/station/turret_protected/ai_upload,
							/area/station/turret_protected/AIsat,
							/area/station/turret_protected/AIbasecore1)
	if (locate(area) in aiareas)
		src.ai_only = TRUE
		src.prefix = "AI"

	if (src.sticky)
		autoposition(src.alternate_sprites)

	AddComponent(/datum/component/camera_coverage_emitter)

	src.light = new /datum/light/point
	src.light.set_brightness(0.3)
	src.light.set_color(209/255, 27/255, 6/255)
	src.light.attach(src)
	src.light.enable()

	SPAWN(1 SECOND)
		addToNetwork()

/obj/machinery/camera/disposing()
	STOP_TRACKING
	if(src.camera_status)
		src.set_camera_status(FALSE)

	if(global.camnets && global.camnets[network])
		global.camnets[network].Remove(src)

	if (c_north)
		c_north.referrers -= src
	if (c_east)
		c_east.referrers -= src
	if (c_south)
		c_south.referrers -= src
	if (c_west)
		c_west.referrers -= src

	global.dirty_cameras |= src.referrers
	global.camnet_needs_rebuild = TRUE

	for(var/obj/machinery/camera/C as anything in referrers)
		if (C.c_north == src)
			C.c_north = null
		if (C.c_east == src)
			C.c_east = null
		if (C.c_south == src)
			C.c_south = null
		if (C.c_west == src)
			C.c_west = null
	src.referrers = null
	..()

/obj/machinery/camera/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/parts/human_parts)) //dumb easter egg incoming
		user.visible_message("<span class='alert'>[user] wipes [src] with the bloody end of [W.name]. What the fuck?</span>", "<span class='alert'>You wipe [src] with the bloody end of [W.name]. What the fuck?</span>")
		return

	if (issnippingtool(W) && !src.reinforced)
		SETUP_GENERIC_ACTIONBAR(src, src, 0.5 SECOND, /obj/machinery/camera/proc/snipcamera, null, W.icon, W.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

	if (!src.camera_status)
		return

	if (istype(W, /obj/item/paper))
		if (!ON_COOLDOWN(src, "paper_camera", 8 SECONDS))
			return
		var/obj/item/paper/X = W
		boutput(user, "You hold a paper up to the camera ...")
		for(var/mob/O in mobs)
			if (isAI(O))
				boutput(O, "[user] holds a paper up to one of your cameras ...")
				X.ui_interact(O)
				logTheThing(LOG_STATION, user, "holds up a paper to a camera at [log_loc(src)], forcing [constructTarget(O,"station")] to read it. <b>Title:</b> [X.name]. <b>Text:</b> [adminscrub(X.info)]")
			else
				var/obj/machinery/computer/security/S = O.using_dialog_of_type(/obj/machinery/computer/security)
				if (S)
					if (S.current == src)
						boutput(O, "[user] holds a paper up to one of the cameras ...")
						X.ui_interact(O)
						logTheThing(LOG_STATION, user, "holds up a paper to a camera at [log_loc(src)], forcing [constructTarget(O,"station")] to read it. <b>Title:</b> [X.name]. <b>Text:</b> [adminscrub(X.info)]")

/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		update_coverage() // explosion happened, probably destroyed nearby turfs, better rebuild
		..(severity)
	return

/obj/machinery/camera/emp_act()
	..()
	if(!src.network)
		return //avoid stacking emp
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

/obj/machinery/camera/blob_act(var/power)
	return

/obj/machinery/camera/attack_ai(var/mob/living/silicon/ai/user as mob)
	if (!istype(user)) //Other silicon mobs shouldn't try to encroach on the AI's "view through all cameras" schtick.  Mostly because it generates runtime errors.
		return
	if (src.network != user.network || !(src.camera_status))
		return
	user.current = src
	user.set_eye(src)

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

// here there was an antisemitic joke, commented out, that persisted until february 27 2020. Why the fuck it lasted so many years really puts ones morals into question.

/obj/machinery/camera/proc/disconnect_viewers()
	for(var/mob/O in mobs)
		if(O.eye == src)
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


/obj/machinery/camera/proc/snipcamera(user)
	if (src.camera_status)
		src.break_camera(user)
	else
		src.repair_camera(user)
	// now disconnect anyone using the camera
	src.disconnect_viewers()
	return

/* ====== Auto Cameras ====== */

/obj/machinery/camera/auto
	name = "autoname"
	c_tag = "autotag"
	sticky = TRUE

/obj/machinery/camera/auto/ranch
	name = "autoname - ranch"
	network = "ranch"
	prefix = "ranch"
	color = "#AAFF99"

/// AI only camera
/obj/machinery/camera/auto/AI
	name = "autoname - AI"
	prefix = "AI"
	ai_only = TRUE

/// Mining outpost cameras
/obj/machinery/camera/auto/mining
	name = "autoname - mining"
	network = "Mining"
	prefix = "mining"
	color = "#daa85c"

/// Science outpost cameras
/obj/machinery/camera/auto/science
	name = "autoname - science"
	network = "Zeta"
	prefix = "outpost"
	color = "#b88ed2"

/// Invisible cameras for VR
/obj/machinery/camera/auto/virtual
	name = "autoname - VR"
	network = "VR"
	invisibility = INVIS_ALWAYS
	invuln = TRUE

/obj/machinery/camera/auto/alt
#ifdef IN_MAP_EDITOR
	icon_state = "cameras_alt"
#endif
	alternate_sprites = TRUE

/obj/machinery/camera/proc/autoposition(var/alt)
	var/turf/T = null
	var/list/directions = null
	var/pixel_offset = 10 // this will get overridden if jen wall
	if (src.dir != SOUTH) // i.e. if the dir has been varedited to east/west/north
		directions = list(turn(src.dir, 180)) // the east sprite sits on a west wall so some inversion is needed
	else
		directions = cardinal // check each direction

	for (var/D in directions)
		T = get_step(src, D)
		if (istype(T,/turf/simulated/wall) || istype(T,/turf/unsimulated/wall) || (locate(/obj/mapping_helper/wingrille_spawn) in T) || (locate(/obj/window) in T))
			if (istype(T, /turf/simulated/wall/auto/jen) || istype(T, /turf/simulated/wall/auto/reinforced/jen))
				pixel_offset = 12 // jen walls are slightly taller so the offset needs to increase
				if (!alt) // this uses the alternate sprites which happen to coincide with diagonal dirs
					src.set_dir(turn(D, 180))
				else
					switch (D) // this is horrid but it works ish
						if (NORTH)
							src.set_dir(SOUTHEAST)
						if (SOUTH)
							src.set_dir(SOUTHWEST)
						if (EAST)
							src.set_dir(NORTHWEST)
						if (WEST)
							src.set_dir(NORTHEAST)
				switch (D) // north facing ones don't need to be offset ofc
					if (EAST)
						src.pixel_x = pixel_offset
					if (WEST)
						src.pixel_x = -pixel_offset
					if (NORTH)
						src.pixel_y = pixel_offset * 2
		T = null

