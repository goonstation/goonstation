/obj/mapping_helper/disable_camera
	name = "disable camera helper"
	icon_state = "cam_off"

/obj/mapping_helper/disable_camera/setup()
	var/camera_found = FALSE
	for (var/obj/machinery/camera/C in get_turf(src))
		C.set_camera_status(FALSE)
		camera_found = TRUE

	if (!camera_found)
		return "[CI.format_position(src)] could not locate any objects of type (/obj/machinery/camera)."
