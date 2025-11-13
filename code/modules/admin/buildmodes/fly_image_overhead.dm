/datum/buildmode/fly_image_overhead
	name = "Fly Image Overhead"
	desc = {"***********************************************************<br>
Protip: tinker with this on a local first so you know what you're doing.
RMB on buildmode button                = Set image and ending effect<br>
Ctrl + RMB on buildmode button         = Set audio<br>
Shift + Left Mouse Button              = Spawn flying object<br>
Shift + Right Mouse Button             = Set direction and speed<br>
***********************************************************"}
	// settings
	var/move_delay = 1
	var/icon/image
	var/turf/target_loc
	var/audio
	var/audio_choice = "Once"
	var/dir_input = "Random"
	var/end_effect = "Leave zlevel"

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (!ctrl)
			var/choice = tgui_input_list(usr, "Upload or clear file?", "Choose", list("Upload", "Clear"))
			if (choice == "Upload")
				src.image = input(usr, "Upload an image:","File Uploader - Downsize your images to fit on the screen, local testing helps!", null) as null|icon
			else
				src.image = null
			src.end_effect = tgui_input_list(usr, "Pick ending effect", "End Effect", list("Leave zlevel", "Explode", "Fade away", "Run away"))
		else
			src.audio_choice = tgui_input_list(usr, "Loop sound globally or play once on arrival?", "Choose", list("Global loop", "Once"))
			src.audio = input(usr, "Upload a file:", "File Uploader - Long files WILL lag people out, sounds will loop.", null) as null|sound

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			src.dir_input = tgui_input_list(usr, "Pick starting direction", "Direction", list(NORTH, SOUTH, EAST, WEST, "Random"))
			var/choice = tgui_input_list(usr, "Choose a set speed or random values", "Choose", list("Set", "Clear"))
			switch(choice)
				if ("Set")
					src.move_delay = tgui_input_number(usr, "Enter speed value", "Higher is slower", 1)
				else
					src.move_delay = 1

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			src.target_loc = get_turf(object)
			aim_pilot()

	proc/aim_pilot()
		var/turf/start
		var/random_dir = pick(NORTH, SOUTH, EAST, WEST)
		var/new_dir

		if (!src.target_loc || !src.dir_input)
			return
		if (src.dir_input == "Random")
			start = get_edge_target_turf(src.target_loc, random_dir)
			new_dir = random_dir
		else
			start = get_edge_target_turf(src.target_loc, src.dir_input)
			new_dir = src.dir_input

		new_dir = turn(new_dir, 180)

		send_pilot(start,new_dir)

	proc/send_pilot(var/turf/startloc,var/direction=EAST)
		var/mob/image_pilot/pilot = new /mob/image_pilot()
		pilot.image_overlay = image
		pilot.set_loc(startloc)
		pilot.attached_sound = src.audio

		if (src.audio_choice == "Global loop" && src.audio)
			pilot.loopsound = TRUE

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

		if (!pilot.loopsound && src.audio)
			for (var/mob/player in view(25, pilot))
				player << sound(src.audio, volume=10)

		switch (src.end_effect)
			if ("Leave zlevel")
				while (pilot.loc) // pilot gets deleted if they don't have a loc in move_foward
					move_forward(pilot, direction)
					sleep(src.move_delay)
			if ("Run away")
				SPAWN(3 SECONDS)
					direction = turn(direction, 180)
					sprint_particle(pilot, pilot.loc)
					playsound(pilot.loc, 'sound/effects/sprint_puff.ogg', 29, 1)
					while (pilot.loc)
						move_forward(pilot, direction, TRUE)
						sleep(src.move_delay)
			if ("Explode")
				var/turf/T = get_turf(pilot)
				playsound(T, "sound/effects/Explosion[pick(1, 2)].ogg", 15, 1)
				new /obj/effects/explosion(T)
				qdel(pilot)
				robogibs(T)
			if ("Fade away")
				animate(pilot, transform = matrix(), alpha  = 0, time = 10)
				pilot.ClearAllOverlays()
				SPAWN(2 SECONDS)
					qdel(pilot)

	proc/move_forward(var/mob/image_pilot/pilot, var/direction,var/defaultspeed)
		var/glide = 0
		if (defaultspeed) // should be checked if you're changing speed at any point, so you don't change every called version's speed too
			glide = (32 / 1) * world.tick_lag
		else
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
	layer = EFFECTS_LAYER_4
	flags = KEEP_TOGETHER
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	var/icon/image_overlay
	var/sound/attached_sound
	var/loopsound = FALSE
	var/dirturncheck = FALSE

	New()
		..()
		SPAWN(0)
			var/image/ship
			ship = image(icon=src.image_overlay, loc=src, layer = EFFECTS_LAYER_4)
			AddOverlays(ship, "ship")
			if (src.loopsound)
				play()

	disposing()
		var/sound/stopsound = sound(null, wait = 0, channel=1020)
		world << stopsound
		..()

	proc/play()
		while (!QDELETED(src))
			src.attached_sound = sound(src.attached_sound, TRUE, TRUE, 1020, 10)
			world << src.attached_sound
			sleep(2 SECONDS)










