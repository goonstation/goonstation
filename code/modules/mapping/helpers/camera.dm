/obj/mapping_helper/disable_camera
	name = "disable camera helper"
	icon_state = "cam_off"

	setup()
		for (var/obj/machinery/camera/C in get_turf(src))
			C.set_camera_status(FALSE)
