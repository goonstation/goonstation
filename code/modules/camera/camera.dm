/obj/machinery/camera
	name = "security camera"
	desc = "A small, high quality camera equipped with face and ID recognition. It is tied into a computer system, allowing AI and those with access to watch what occurs through it."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	text = ""

	/// Used by things that can view cameras to display certain cameras only
	var/network = CAMERA_NETWORK_STATION
	/// Used by autoname: EX "security camera"
	var/prefix = "security"
	/// Used by autoname: EX "camera - west primary hallway"
	var/uses_area_name = FALSE
	// The two above stack: EX "security camera - west primary hallway"

	layer = EFFECTS_LAYER_UNDER_1
	/// The camera tag which identifies this camera
	var/c_tag = null
	var/c_tag_order = 999
	/// Whether the camera is on or off (bad var name)
	var/camera_status = TRUE
	anchored = ANCHORED
	/// Can't be destroyed by explosions
	var/invuln = FALSE
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

	/// Here's a list of cameras pointing to this camera for reprocessing purposes
	var/list/obj/machinery/camera/referrers = list()

	/// Robust light
	var/datum/light/point/light

	/// The viewers of the camera, for quickly disconnecting them when needed
	var/list/mob/viewers

	HELP_MESSAGE_OVERRIDE("You can use a pair of <b>wire cutters</b> to disable the camera, or a <b>cable coil</b> to fix it if it's broken.")

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
	//TODO: if only these had a common parent...
	var/list/aiareas = list(/area/station/turret_protected/ai,
							/area/station/turret_protected/ai_upload,
							/area/station/turret_protected/AIsat,
							/area/station/turret_protected/AIbasecore1,
							/area/station/turret_protected/ai_upload_foyer)
	if (locate(area) in aiareas)
		src.prefix = "AI"
		src.network = CAMERA_NETWORK_AI_ONLY
		src.color = "#9999cc"

	if (src.sticky)
		autoposition(src.alternate_sprites)

	AddComponent(/datum/component/camera_coverage_emitter)

	LAZYLISTINIT(src.viewers)

	src.light = new /datum/light/point
	src.light.set_brightness(0.3)
	src.light.set_color(209/255, 27/255, 6/255)
	src.light.attach(src)
	src.light.enable()

	SPAWN(1 SECOND)
		addToNetwork()

/obj/machinery/camera/disposing()
	STOP_TRACKING
	if (src.camera_status)
		src.set_camera_status(FALSE)

	if (src.light)
		qdel(src.light)
		src.light = null

	if (length(src.viewers))
		src.disconnect_viewers()

	if (global.camnets && global.camnets[network])
		global.camnets[network].Remove(src)

	if (c_north)
		c_north.referrers -= src
		c_north = null
	if (c_east)
		c_east.referrers -= src
		c_east = null
	if (c_south)
		c_south.referrers -= src
		c_south = null
	if (c_west)
		c_west.referrers -= src
		c_west = null

	global.dirty_cameras |= src.referrers
	global.camnet_needs_rebuild = TRUE

	for (var/obj/machinery/camera/C as anything in referrers)
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
		user.visible_message(SPAN_ALERT("[user] wipes [src] with the bloody end of [W.name]. What the fuck?"), SPAN_ALERT("You wipe [src] with the bloody end of [W.name]. What the fuck?"))
		return

	if (issnippingtool(W))
		if (src.reinforced)
			boutput(user, SPAN_ALERT("[src] is too reinforced to disable!"))
			return
		else if (!src.camera_status)
			boutput(user, SPAN_ALERT("[src] is already disabled. Use a cable coil if you want to fix it."))
			return

		SETUP_GENERIC_ACTIONBAR(user, src, 0.5 SECOND, /obj/machinery/camera/proc/break_camera, list(user), W.icon, W.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
	else if (!src.camera_status && istype(W, /obj/item/cable_coil))
		SETUP_GENERIC_ACTIONBAR(user, src, 0.5 SECOND, /obj/machinery/camera/proc/repair_camera, list(user, W), W.icon, W.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)

	if (!src.camera_status)
		return

	if (istype(W, /obj/item/paper))
		if (ON_COOLDOWN(src, "paper_camera", 8 SECONDS))
			return
		var/obj/item/paper/paper = W
		user.visible_message(SPAN_NOTICE("[user] holds \a [paper] up to [src]."), SPAN_NOTICE("you hold \a [paper] up to [src]."))
		for (var/mob/M as anything in global.mobs)
			if (isAI(M))
				boutput(M, SPAN_NOTICE("[user] holds \a [paper] up to one of your cameras."))
				paper.ui_interact(M)
				logTheThing(LOG_STATION, user, "holds up a paper to a camera at [log_loc(src)], forcing [constructTarget(M, "station")] to read it. <b>Title:</b> [paper.name]. <b>Text:</b> [adminscrub(paper.info)]")
		if (length(src.viewers))
			for (var/guy as anything in src.viewers)
				paper.ui_interact(guy)
				logTheThing(LOG_STATION, user, "holds up a paper to a camera at [log_loc(src)], forcing [constructTarget(guy, "station")] to read it. <b>Title:</b> [paper.name]. <b>Text:</b> [adminscrub(paper.info)]")

/obj/machinery/camera/ex_act(severity)
	if (src.invuln)
		return
	..(severity)
	if (!QDELETED(src))
		src.update_coverage() // explosion happened, probably destroyed nearby turfs, better rebuild

/obj/machinery/camera/emp_act()
	..()
	if(!src.network)
		return //avoid stacking emp
	src.icon_state = "[initial(src.icon_state)]emp"
	src.network = null //Not the best way but it will do. I think.
	src.set_camera_status(FALSE)

	SPAWN(90 SECONDS)
		src.set_camera_status(TRUE)
		src.network = initial(src.network)
		src.icon_state = initial(src.icon_state)

		src.update_coverage()

	src.disconnect_viewers()

/obj/machinery/camera/blob_act(var/power)
	return

/obj/machinery/camera/overload_act()
	if(!src.network)
		return FALSE
	src.emp_act()
	return TRUE

/obj/machinery/camera/was_deconstructed_to_frame(mob/user)
	. = ..()
	src.set_camera_status(FALSE)
	src.update_coverage()
	src.disconnect_viewers()

/obj/machinery/camera/was_built_from_frame(mob/user, newly_built)
	. = ..()
	src.set_camera_status(TRUE)
	src.update_coverage()

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

/// Connect a viewer to this camera
/obj/machinery/camera/proc/connect_viewer(var/mob/viewer)
	if (QDELETED(viewer) || !istype(viewer))
		return FALSE
	if (src.camera_status)
		LAZYLISTADD(src.viewers, viewer)
		viewer.set_eye(src)
		return TRUE

/// Disconnect a viewer from this camera
/obj/machinery/camera/proc/disconnect_viewer(var/mob/viewer)
	if (istype(viewer))
		LAZYLISTREMOVE(src.viewers, viewer)
	if (!QDELETED(viewer))
		viewer.set_eye(null)

/// Move viewers eyes from current camera to a new camera
/obj/machinery/camera/proc/move_viewer_to(var/mob/viewer, var/obj/machinery/camera/cam)
	if (QDELETED(viewer) || !istype(viewer))
		return FALSE
	if (QDELETED(cam) || !istype(cam))
		return FALSE
	if (cam.camera_status) // Only switch if all checks succeed
		src.disconnect_viewer(viewer)
		cam.connect_viewer(viewer)
		return TRUE

/// Disconnect all viewers from this camera
/obj/machinery/camera/proc/disconnect_viewers()
	for (var/mob/guy as anything in src.viewers)
		src.disconnect_viewer(guy)
		boutput(guy, "The screen bursts into static.")

/obj/machinery/camera/proc/break_camera(mob/user)
	src.set_camera_status(FALSE)
	playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
	src.icon_state = "[initial(src.icon_state)]1"
	src.light.disable()
	if (user)
		user.visible_message(SPAN_ALERT("[user] has deactivated [src]!"), SPAN_ALERT("You have deactivated [src]."))
		logTheThing(LOG_STATION, null, "[key_name(user)] deactivated a security camera ([log_loc(src.loc)])")
		add_fingerprint(user)
	src.disconnect_viewers()

/obj/machinery/camera/proc/repair_camera(mob/user, obj/item/cable_coil/cables)
	cables?.change_stack_amount(-1)
	src.set_camera_status(TRUE)
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 100, 1)
	src.icon_state = initial(src.icon_state)
	src.light.enable()
	if (user)
		user.visible_message(SPAN_ALERT("[user] has reactivated [src]!"), SPAN_ALERT("You have reactivated [src]."))
		add_fingerprint(user)

/obj/machinery/camera/ranch
	name = "autoname - ranch"
	c_tag = "autotag"
	network = CAMERA_NETWORK_RANCH
	prefix = "ranch"
	color = "#AAFF99"

/obj/machinery/camera/mining
	name = "autoname - mining"
	network = CAMERA_NETWORK_MINING
	prefix = "mining"
	color = "#daa85c"

/obj/machinery/camera/science
	name = "autoname - science"
	network = CAMERA_NETWORK_SCIENCE
	prefix = "outpost"
	color = "#efb4e5"

/* ====== Auto Cameras ====== */

/obj/machinery/camera/auto
	name = "autoname"
	c_tag = "autotag"
	sticky = TRUE

/obj/machinery/camera/auto/ranch
	name = "autoname - ranch"
	network = CAMERA_NETWORK_RANCH
	prefix = "ranch"
	color = "#AAFF99"

/// AI only camera
/obj/machinery/camera/auto/AI
	name = "autoname - AI"
	network = CAMERA_NETWORK_AI_ONLY
	prefix = "AI"
	color = "#9999cc"

/// Mining outpost cameras
/obj/machinery/camera/auto/mining
	name = "autoname - mining"
	network = CAMERA_NETWORK_MINING
	prefix = "mining"
	color = "#daa85c"

/// Science outpost cameras
/obj/machinery/camera/auto/science
	name = "autoname - science"
	network = CAMERA_NETWORK_SCIENCE
	prefix = "outpost"
	color = "#efb4e5"

/obj/machinery/camera/auto/cargo
	name = "autoname - cargo"
	network = CAMERA_NETWORK_CARGO
	prefix = "routing"
	color = "#daa85c"

/// Invisible cameras for V-Space
/obj/machinery/camera/auto/vspace
	name = "autoname - V-Space"
	network = CAMERA_NETWORK_VSPACE
	prefix = "v-space"
#ifdef IN_MAP_EDITOR
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildappearance"
#endif
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED_ALWAYS
	opacity = 0
	density = 0
	invuln = TRUE

	New()
		. = ..()
		START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

	disposing()
		. = ..()
		STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

/// cameras for ghost observers
/obj/machinery/camera/auto/ghost
	name = "autoname - ghost"
	network = null
	prefix = "ghost"
#ifdef IN_MAP_EDITOR
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildappearance"
#endif
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED_ALWAYS
	opacity = 0
	density = 0
	invuln = TRUE

	New()
		. = ..()
		START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

	disposing()
		. = ..()
		STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

/// "overhead" cameras
/obj/machinery/camera/auto/public
	name = "autoname - entertainment"
	network = CAMERA_NETWORK_PUBLIC
	prefix = "entertainment"
#ifdef IN_MAP_EDITOR
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildappearance"
#endif
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED_ALWAYS

	New()
		. = ..()
		START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

	disposing()
		. = ..()
		STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)


/obj/machinery/camera/auto/alt
#ifdef IN_MAP_EDITOR
	icon_state = "cameras_alt"
#endif
	alternate_sprites = TRUE

/obj/machinery/camera/proc/autoposition(var/alt)
	var/turf/T = null
	var/list/directions = null
	var/pixel_offset = 10 // this will get overridden if jen wall
	T = get_step(src, turn(src.dir, 180)) // lets first check if we can attach to a wall with our dir
	if (wall_window_check(T))
		directions = list(turn(src.dir, 180))
	else
		directions = cardinal // check each direction

	for (var/D as anything in directions)
		T = get_step(src, D)
		if (wall_window_check(T))
			if (istype(T, /turf/simulated/wall/auto/jen) || istype(T, /turf/simulated/wall/auto/reinforced/jen))
				pixel_offset = 12 // jen walls are slightly taller so the offset needs to increase
			if (alt) // this uses the alternate sprites which happen to coincide with diagonal dirs
				switch (D) // this is horrid but it works ish
					if (NORTH)
						src.set_dir(SOUTHEAST)
					if (SOUTH)
						src.set_dir(SOUTHWEST)
					if (EAST)
						src.set_dir(NORTHWEST)
					if (WEST)
						src.set_dir(NORTHEAST)
			else
				src.set_dir(turn(D, 180))
			switch (D) // north facing ones don't need to be offset ofc
				if (EAST)
					src.pixel_x = pixel_offset
				if (WEST)
					src.pixel_x = -pixel_offset
				if (NORTH)
					src.pixel_y = pixel_offset * 2
		T = null
