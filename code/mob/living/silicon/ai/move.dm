
/mob/living/silicon/ai/process_move()
	if(has_feet)
		return ..()
	return

/mob/living/silicon/ai/keys_changed(keys, changed)
	if(has_feet)
		return ..()

	if (changed & (KEY_EXAMINE|KEY_BOLT|KEY_OPEN|KEY_SHOCK))
		src.update_cursor()

	if (keys & changed & (KEY_FORWARD|KEY_BACKWARD|KEY_LEFT|KEY_RIGHT))
		/*
		var/direct = NORTH
		if (keys & changed & KEY_FORWARD)
			direct = NORTH
		else if (keys & changed & KEY_BACKWARD)
			direct = SOUTH
		else if (keys & changed & KEY_RIGHT)
			direct = EAST
		else if (keys & changed & KEY_LEFT)
			direct = WEST


		var/obj/machinery/camera/closest = src.current
		if(closest)
			//do
			if(direct & NORTH)
				closest = closest.c_north
			else if(direct & SOUTH)
				closest = closest.c_south
			if(direct & EAST)
				closest = closest.c_east
			else if(direct & WEST)
				closest = closest.c_west
			//while(closest && !closest.camera_status) //Skip disabled cameras - THIS NEEDS TO BE BETTER (static overlay imo)
		else
			closest = getCameraMove(src, direct) //Ok, let's do this then.



		if(!closest)
			return
		*/

		src.tracker.cease_track()
		src.eye_view()
		//src.switchCamera(closest)


