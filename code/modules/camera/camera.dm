/obj/machinery/camera
	name = "autoname - SS13"
	desc = "A small, high quality camera equipped with face and ID recognition. It is tied into a computer system, allowing AI and those with access to watch what occurs through it."
	icon = 'icons/obj/camera.dmi'
	icon_state = "camera"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	text = ""

	/// Used by things that can view cameras to display certain cameras only
	var/network = CAMERA_NETWORK_STATION
	/// bitmask of minimaps this camera should appear on
	var/minimap_types = 0
	/// Used by autoname: EX "security camera"
	var/prefix = "security"
	/// Used by autoname: EX "camera - west primary hallway"
	var/uses_area_name = FALSE
	// The two above stack: EX "security camera - west primary hallway"

	layer = EFFECTS_LAYER_UNDER_1
	/// The camera tag which identifies this camera
	var/c_tag = "autotag"
	var/c_tag_order = 999
	/// Whether the camera is on or off (bad var name)
	var/camera_status = TRUE
	anchored = ANCHORED
	/// Can't be destroyed by explosions
	var/invuln = FALSE
	/// Cant be snipped by wirecutters
	var/reinforced = FALSE

	/// Should this camera have a light?
	var/has_light = TRUE
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

/obj/machinery/camera/New(loc)
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

	src.set_camera_status(TRUE)

	LAZYLISTINIT(src.viewers)

	if (src.has_light)
		src.light = new /datum/light/point
		src.light.set_brightness(0.3)
		src.light.set_color(209/255, 27/255, 6/255)
		src.light.attach(src)
		src.light.enable()

	if (src.network in /obj/machinery/computer/camera_viewer::camera_networks)
		src.minimap_types |= MAP_CAMERA_STATION

	if (dd_hasprefix(src.name, "autoname"))
		var/name_build_string = ""
		if (src.prefix)
			name_build_string += "[src.prefix] "

		name_build_string += "camera"
		if (src.uses_area_name)
			var/area/A = get_area(src)
			name_build_string += " - [A.name]"

		src.name = name_build_string

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

	src.network = null //Not the best way but it will do. I think.
	src.set_camera_status(FALSE)
	src.add_filter("emp_outline", 1, outline_filter(1, "#00FFFF", OUTLINE_SHARP))

	SPAWN(90 SECONDS)
		src.network = initial(src.network)
		src.set_camera_status(TRUE)
		src.remove_filter("emp_outline")

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

	if (src.camera_status)
		src.icon_state = "camera"
		var/image/on_light = image(src.icon, "camera-light")
		src.UpdateOverlays(on_light, "on_light")

		on_light.color = list(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 1,
			1, 1, 1, 0,
		)
		on_light.plane = PLANE_LIGHTING
		src.UpdateOverlays(on_light, "on_light_lighting")

	else
		src.icon_state = "camera-off"
		src.UpdateOverlays(null, "on_light")
		src.UpdateOverlays(null, "on_light_lighting")

	var/datum/component/camera_coverage_emitter/emitter = src.GetComponent(/datum/component/camera_coverage_emitter)
	if (emitter)
		emitter.set_active(src.camera_status)
	else
		src.AddComponent(/datum/component/camera_coverage_emitter)

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
	src.light.enable()
	if (user)
		user.visible_message(SPAN_ALERT("[user] has reactivated [src]!"), SPAN_ALERT("You have reactivated [src]."))
		add_fingerprint(user)

/// Adds the minimap component for the camera
/obj/machinery/camera/proc/add_to_minimap()
	src.AddComponent(/datum/component/minimap_marker/minimap, src.minimap_types, "camera", name=src.c_tag)

SET_UP_DIRECTIONALS(/obj/machinery/camera, OFFSETS_CAMERA)

/obj/machinery/camera/cargo
	name = "autoname - cargo"
	color = "#daa85c"
	network = CAMERA_NETWORK_CARGO
	prefix = "routing"

SET_UP_DIRECTIONALS(/obj/machinery/camera/cargo, OFFSETS_CAMERA)


/obj/machinery/camera/mining
	name = "autoname - mining"
	color = "#daa85c"
	network = CAMERA_NETWORK_MINING
	prefix = "mining"

SET_UP_DIRECTIONALS(/obj/machinery/camera/mining, OFFSETS_CAMERA)


/obj/machinery/camera/ranch
	name = "autoname - ranch"
	color = "#AAFF99"
	network = CAMERA_NETWORK_RANCH
	prefix = "ranch"

SET_UP_DIRECTIONALS(/obj/machinery/camera/ranch, OFFSETS_CAMERA)


/obj/machinery/camera/science
	name = "autoname - science"
	color = "#efb4e5"
	network = CAMERA_NETWORK_SCIENCE
	prefix = "outpost"

SET_UP_DIRECTIONALS(/obj/machinery/camera/science, OFFSETS_CAMERA)


/obj/machinery/camera/watchful_eye
	name = "sensor"
	desc = "A small, high quality camera, monitoring the eyes for traces of activity."
	network = "Eye"

SET_UP_DIRECTIONALS(/obj/machinery/camera/watchful_eye, OFFSETS_CAMERA)


/obj/machinery/camera/AI
	name = "autoname - AI"
	color = "#9999cc"
	network = CAMERA_NETWORK_AI_ONLY
	prefix = "AI"


/obj/machinery/camera/public
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
	invuln = TRUE

/obj/machinery/camera/public/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

/obj/machinery/camera/public/disposing()
	. = ..()
	STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)


/obj/machinery/camera/vspace
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
	invuln = TRUE

/obj/machinery/camera/vspace/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

/obj/machinery/camera/vspace/disposing()
	. = ..()
	STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)
