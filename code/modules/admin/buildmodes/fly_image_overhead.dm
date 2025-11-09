/datum/buildmode/fly_image_overhead
	name = "Throw"
	desc = {"***********************************************************<br>
Ctrl + RMB on buildmode button         = Set image and ending effect<br>
Ctrl + LMB on buildmode button         = Set audio<br>
Alt + LMB on buildmode button          = Save settings<br>
Alt + RMB on buildmode button          = Swap between current and saved settings<br>
Left Mouse Button                      = Spawn flying object<br>
Right Mouse Button                     = Target turf to fly toward<br>
***********************************************************"}
	// settings
	var/move_delay = 1
	var/icon/image_overlay
	var/turf/target_loc
	var/dir_input
	var/end_effect = "Leave zlevel"

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (ctrl)
			var/icon/I = input("Pick an icon:","Icon") as null|icon
			if (I)
				src.image_overlay = I
				for (var/client/C in clients)
					fun_image.add_client(C)
				logTheThing(LOG_ADMIN, src, "has uploaded icon [I] to all players")
				logTheThing(LOG_DIARY, src, "has uploaded icon [I] to all players", "admin")
				message_admins("[key_name(src)] has uploaded icon [I] to all players")
			src.end_effect = tgui_input_list(usr, "Pick ending effect", "End Effect", list("Leave zlevel", "Explode", "Fade away"))

	click_right(atom/object)
		src.target_loc = get_turf(object)
		src.dir_input = tgui_input_list(usr, "Pick starting direction", "Direction", list(NORTH, SOUTH, EAST, WEST, "Random"))

	click_left(atom/object)
		create_pilot()

	proc/create_pilot()
		var/turf/start
		var/random_dir = pick(NORTH, SOUTH, EAST, WEST)
		var/times_to_travel
		if (dir_input == "Random")
			start = get_edge_target_turf(src.target_loc, random_dir)
		else
			start = get_edge_target_turf(src.target_loc, src.dir_input)

		var/obj/pilot = new /obj/image_pilot
		var/new_dir
		var/overlay = image(src.image, overlay_state)
		UpdateOverlays(overlay, "image")
		pilot.set_loc(start)
		switch (start)
			if (EAST)
				new_dir = WEST
			if (WEST)
				new_dir = EAST
			if (NORTH)
				new_dir = SOUTH
			if (SOUTH)
				new_dir = NORTH

		while (pilot.loc <= src.target_loc)
			glide = (32 / src.move_delay) * world.tick_lag
			pilot.glide_size = glide
			pilot.animate_movement = SLIDE_STEPS
			var/old_loc = src.loc
			src.set_loc(get_step(src, src.move_dir))
			SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, new_dir)
			if (!src.loc)
				qdel(src)
			pilot.glide_size = glide
			pilot.animate_movement = SLIDE_STEPS
			sleep(src.move_delay)

		switch (src.end_effect)
			if ("Explode")
				var/turf/T = get_turf(src)
				playsound(T, "sound/effects/explode[pick(1, 2)]", 30, 1)
				new /obj/effects/explosion(T)
				qdel(src)
				robogibs(T)
			if ("Fade away")
				animate(pilot, transform = matrix(), alpha  = 0, time = 3)
				SPAWN(3 SECONDS)
					qdel(src)

/obj/image_pilot
	name = ""
	desc = ""
	anchored = ANCHORED
	density = 0
	layer = 30
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
