/obj/landmark/boxing_ring
	name = LANDMARK_BOXING_RING


	//disabling this for now bcause somepotato says its costly on client fps stuff
///turf
	//appearance_flags = KEEP_TOGETHER
	//vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_PLANE|VIS_INHERIT_ID

/obj/machinery/security_monitor
	name = "Security Monitor"
	icon = 'icons/obj/sec_tv.dmi'
	icon_state = "wall-monitor"
	anchored = 1
	pixel_y = 30
	layer = OBJ_LAYER+1
	appearance_flags = KEEP_TOGETHER
	var/list/cameras = list()							//all camera's detected by this device which it can link to
	var/obj/current_camera = null
	var/obj/video_screen/video_screen
	var/fov = 2						//value to provide for view(). 1 = 3x3 tiles, 2 = 5x5, etc.
	var/active = 0

	var/monitor_id = "MONITOR-1"				//set in map maker
	var/network = "SS13"			//used in camera computer

	New()
		..()
		SPAWN(0)
			video_screen = new(src.loc, owner = src)
			video_screen.fov = fov

	disposing()
		// if (current_camera)
		// 	current_camera.connected_monitor = null
		current_camera = null
		cameras = null
		qdel(video_screen)
		..()

	process()
		if (active)
			power_usage = 500
		else
			power_usage = 50

		// if (status & NOPOWER || !active)
		// 	turn_off()
		// 	return
		// //Shouldn't happen, but I guess singularities can break it. This should be fine though
		// if (video_screen.loc != src.loc || blank_screen.loc != src.loc)
		// 	turn_off()
		// 	return

		use_power(power_usage)
		return

	attack_hand(mob/user)
		if (!active)
			detect_cameras()
			current_camera = cameras["HUD1"]
			turn_on()
		else
			turn_off()
		boutput(user, "You press the Power Button.")

	//remove vis_contents display, set active off, changes monitor sprite
	proc/turn_off()
		video_screen.deactivate()

		current_camera = null
		src.icon_state = "wall-monitor"
		active = 0

	//sets active on, changes monitor sprite
	proc/turn_on()
		active = 1
		video_screen.activate()
		src.icon_state = "wall-monitor-on"

	//loops through world looking for appropriate cameras. currently using sunglasses/camera, should make upgradable HUD but I don't have access to that
	proc/detect_cameras()
		var/count = 1
		for(var/turf/BR in landmarks[LANDMARK_BOXING_RING])
			cameras["HUD[count]"] = BR
			count++
			break

/obj/video_screen
	name = "video screen"
	appearance_flags = KEEP_TOGETHER
	mouse_opacity = 0
	// layer = MOB_LAYER+1
	plane = PLANE_ABOVE_LIGHTING
	var/fov = 2
	var/obj/machinery/security_monitor/owner
	var/image/blank

	New(var/obj/machinery/security_monitor/owner)
		..()
		src.owner = owner
		pixel_x = owner.pixel_x
		pixel_y = owner.pixel_y
		layer = owner.layer
		blank = image('icons/obj/sec_tv.dmi',"wall-screen")
		underlays += blank

	disposing()
		blank = null
		..()

	proc/activate()
		get_picture()
		var/matrix/scaled = matrix()
		scaled.Scale(0.3375, 0.3375)
		// scaled.Translate(-6,24)
		transform = scaled
		underlays -= blank

	proc/deactivate()
		transform = null
		vis_contents = null
		underlays += blank
	//adds the turfs surrounding the current camera to the screen's vis_contents.
	proc/get_picture()
		vis_contents = null
		for (var/turf/i in view(fov, owner.current_camera.loc))
			vis_contents += i
