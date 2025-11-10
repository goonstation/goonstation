/datum/buildmode/fly_image_overhead
	name = "Fly Image Overhead"
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
	var/icon/image
	var/turf/target_loc
	var/dir_input = "Random"
	var/end_effect = "Leave zlevel"

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (ctrl)
			src.image = input("Pick an icon:","Icon") as null|icon
			src.end_effect = tgui_input_list(usr, "Pick ending effect", "End Effect", list("Leave zlevel", "Explode", "Fade away"))

	click_right(atom/object)
		src.dir_input = tgui_input_list(usr, "Pick starting direction", "Direction", list(NORTH, SOUTH, EAST, WEST, "Random"))

	click_left(atom/object)
		src.target_loc = get_turf(object)
		aim_pilot()

	proc/aim_pilot()
		var/turf/start
		var/random_dir = pick(NORTH, SOUTH, EAST, WEST)
		var/new_dir
		if (!src.target_loc || !src.dir_input)
			return
		if (dir_input == "Random")
			start = get_edge_target_turf(src.target_loc, random_dir)
		else
			start = get_edge_target_turf(src.target_loc, src.dir_input)

		switch (start)
			if (EAST)
				new_dir = WEST
			if (WEST)
				new_dir = EAST
			if (NORTH)
				new_dir = SOUTH
			if (SOUTH)
				new_dir = NORTH

		send_pilot(startloc=start,direction=new_dir)

	proc/send_pilot(var/turf/startloc,var/direction=NORTH)
		var/obj/image_pilot/pilot = new /obj/image_pilot()
		pilot.image_overlay = image
		pilot.set_loc(startloc)

		var/glide = 0
		while (pilot.loc != src.target_loc)
			glide = (32 / src.move_delay) * world.tick_lag
			pilot.glide_size = glide
			pilot.animate_movement = SLIDE_STEPS
			var/old_loc = pilot.loc
			pilot.set_loc(get_step(pilot, direction))
			SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, direction)
			if (!pilot.loc)
				SPAWN(2 SECONDS)
					if (!pilot.loc)
						qdel(pilot)
						break
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
	flags = KEEP_TOGETHER
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	var/icon/image_overlay

	New()
		..()
		SPAWN(0)
			var/image/ship = image(icon=src.image_overlay, loc=src, layer = 30)
			src.overlays += ship
