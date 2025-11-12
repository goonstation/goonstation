/datum/buildmode/fly_image_overhead
	name = "Fly Image Overhead"
	desc = {"***********************************************************<br>
RMB on buildmode button                = Set image and ending effect<br>
Shift + Left Mouse Button              = Spawn flying object<br>
Shift + Right Mouse Button             = Set direction and speed<br>
***********************************************************"}
	// settings
	var/move_delay = 1
	var/rand_delay_low
	var/rand_delay_high
	var/icon/image
	var/turf/target_loc
	var/sound/audio
	var/dir_input = "Random"
	var/end_effect = "Leave zlevel"

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (!ctrl || !alt || !shift)
			var/choice = tgui_input_list(usr, "Upload or clear file?", "Choose", list("Upload", "Clear"))
			if (choice == "Upload")
				src.image = input(usr, "Upload an image:","File Uploader - Downsize your images to fit on the screen, local testing helps!", null) as null|icon
			else
				src.image = null
			src.end_effect = tgui_input_list(usr, "Pick ending effect", "End Effect", list("Leave zlevel", "Explode", "Fade away", "Random"))

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			src.dir_input = tgui_input_list(usr, "Pick starting direction", "Direction", list(NORTH, SOUTH, EAST, WEST, "Random"))
			var/choice = tgui_input_list(usr, "Choose a set speed or random values", "Choose", list("Set", "Random"))
			if (choice == "Set")
				src.move_delay = tgui_input_number(usr, "Enter speed value", "Higher is slower", 1)
			else
				src.rand_delay_low = tgui_input_number(usr, "Enter lowest value", "Random", 1)
				src.rand_delay_high = tgui_input_number(usr, "Enter highest value", "Random", 5) //

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			src.target_loc = get_turf(object)
			aim_pilot()

	proc/aim_pilot()
		var/turf/start
		var/random_dir = pick(NORTH, SOUTH, EAST, WEST)
		var/new_dir
		var/endfx = src.end_effect
		if (!src.target_loc || !src.dir_input)
			return
		if (src.end_effect == "Random")
			endfx = pick("Leave zlevel", "Explode", "Fade away")
		if (src.dir_input == "Random")
			start = get_edge_target_turf(src.target_loc, random_dir)
			new_dir = random_dir
		else
			start = get_edge_target_turf(src.target_loc, src.dir_input)
			new_dir = src.dir_input

		switch (new_dir) // flip target direction once we get to the edge of the map. likely built in way to do this..?
			if (EAST)
				new_dir = WEST
			if (WEST)
				new_dir = EAST
			if (NORTH)
				new_dir = SOUTH
			if (SOUTH)
				new_dir = NORTH

		send_pilot(start,new_dir,endfx)

	proc/send_pilot(var/turf/startloc,var/direction=EAST,var/ending)
		var/mob/image_pilot/pilot = new /mob/image_pilot()
		pilot.image_overlay = image
		pilot.set_loc(startloc)

		if (direction == WEST || direction == EAST)
			while (pilot.x != src.target_loc.x)
				if(QDELETED(pilot))
					break
				move_forward(pilot, direction)
				sleep(src.move_delay)
		if (direction == NORTH || direction == SOUTH)
			while (pilot.y != src.target_loc.y)
				if(QDELETED(pilot))
					break
				move_forward(pilot, direction)
				sleep(src.move_delay)

		switch (ending)
			if ("Leave zlevel")
				while (pilot.loc) // pilot gets deleted withou a loc in move_foward
					move_forward(pilot, direction)
					sleep(src.move_delay)
			if ("Explode")
				var/turf/T = get_turf(pilot)
				playsound(T, "sound/effects/Explosion[pick(1, 2)].ogg", 15, 1)
				new /obj/effects/explosion(T)
				qdel(pilot)
				robogibs(T)
			if ("Fade away")
				animate(pilot.image_overlay, transform = matrix(), alpha  = 0, time = 3)
				SPAWN(2 SECONDS)
					qdel(pilot)

	proc/move_forward(var/mob/image_pilot/pilot, var/direction)
		var/glide = 0
		glide = (32 / src.move_delay) * world.tick_lag
		pilot.glide_size = glide
		pilot.animate_movement = SLIDE_STEPS
		var/old_loc = pilot.loc
		pilot.set_loc(get_step(pilot, direction))
		SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, direction)
		if (!pilot.loc)
			qdel(pilot)
		pilot.glide_size = glide
		pilot.animate_movement = SLIDE_STEPS

/mob/image_pilot
	name = ""
	desc = ""
	anchored = ANCHORED
	density = 0
	nodamage = 1
	flags = KEEP_TOGETHER
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	var/icon/image_overlay

	New()
		..()
		SPAWN(0)
			var/image/ship = image(icon=src.image_overlay, loc=src, layer = 35)
			src.overlays += ship







