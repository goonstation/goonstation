/datum/buildmode/fly_image_overhead
	name = "Fly Image Overhead"
	desc = {"***********************************************************<br>
Upload an image and/or audio and have it fly to target turf then play an ending effect.
Protip: tinker with this on a local first so you know what you're doing.<br>
RMB on buildmode button                = Set image and ending effect<br>
Ctrl + RMB on buildmode button         = Set audio<br>
Alt + Right mouse button               = Set optional obj/mob spawns<br>
Shift + Right Mouse Button             = Set direction and speed<br>
Shift + Left Mouse Button              = Spawn flying object<br>
***********************************************************"}
	// settings
	var/move_delay = 1
	var/icon/image
	var/turf/target_loc
	var/audio
	var/audio_choice = "Once"
	var/dir_input = "Random"
	var/end_effect = "Leave zlevel"
	var/spawnpath
	var/spawnamount = 1
	var/startnearby = TRUE

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (!ctrl && !alt && !shift)
			var/choice = tgui_input_list(usr, "Upload or clear file?", "Choose", list("Upload", "Clear"))
			if (choice == "Upload")
				src.image = input(usr, "Upload an image:","File Uploader - Downsize your images to fit on the screen, local testing helps!", null) as null|icon
			else
				src.image = null
			src.end_effect = tgui_input_list(usr, "Pick ending effect", "End Effect", list("Leave zlevel", "Explode", "Fade away", "Run away"))
		if (ctrl)
			src.audio_choice = tgui_input_list(usr, "Loop sound globally or play once on arrival?", "Choose", list("Global loop", "Once", "Clear"))
			if (src.audio_choice == "Clear")
				src.audio = null
			else
				src.audio = input(usr, "Upload a file:", "File Uploader - Long files WILL lag people out, sounds will loop.", null) as null|sound

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			src.dir_input = tgui_input_list(usr, "Pick starting direction", "Direction", list(NORTH, SOUTH, EAST, WEST, "Random"))
			var/choice = tgui_input_list(usr, "Choose a set speed or random values", "Choose", list("Set", "Clear"))
			var/choice2 = tgui_input_list(usr, "Start from edge of zlevel or nearby? (About 2 screens away)", "Choose", list("Edge", "Nearby"))
			if (choice2 == "Nearby")
				src.startnearby = TRUE
			else
				src.startnearby = FALSE
			if (choice == "Set")
				src.move_delay = tgui_input_number(usr, "Enter speed value of image", "Higher is slower, gets very slow by 5", 1)
			else
				src.move_delay = 1
		if (alt)
			var/choice = tgui_input_list(usr, "Spawn mobs/objects or clear?", "Choose", list("Spawn", "Clear"))
			if (choice == "Spawn")
				src.spawnpath = get_one_match(input("Type path", "Type path", "[src.spawnpath]"), /atom)
				src.spawnamount = tgui_input_number(usr, "Amount to spawn", "Amount - Be responsible!!", 1)
			else
				src.spawnpath = null
				src.spawnamount = 1
				return

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			src.target_loc = get_turf(object)
			aim_pilot()

	proc/aim_pilot() // Spawn pilot at edge of zlevel then redirect to target
		var/turf/start
		var/random_dir = pick(NORTH, SOUTH, EAST, WEST)
		var/new_dir
		if (!src.target_loc || !src.dir_input)
			return

		if (src.dir_input == "Random")
			new_dir = random_dir
		else
			new_dir = src.dir_input

		if (src.startnearby)
			start = get_ranged_target_turf(src.target_loc, new_dir, 35)
		else
			start = get_edge_target_turf(src.target_loc, new_dir)

		new_dir = turn(new_dir, 180)
		send_pilot(start,new_dir)

	proc/send_pilot(var/turf/startloc,var/direction=EAST)
		var/mob/image_pilot/pilot = new /mob/image_pilot()
		var/speedinput = src.move_delay
		var/pathinput = src.spawnpath
		var/pathamountinput = src.spawnamount
		pilot.image_overlay = src.image
		pilot.attached_sound = src.audio
		pilot.alpha = 0
		pilot.set_loc(startloc)
		animate(pilot, transform = matrix(), alpha = 255, time = 1.5 SECONDS)

		if (src.audio_choice == "Global loop" && src.audio)
			pilot.loopsound = TRUE

		if (direction == WEST || direction == EAST)
			while (pilot.x != src.target_loc.x)
				if(QDELETED(pilot)) // pilot gets deleted in move_forward when it is without a loc
					break
				move_forward(pilot, direction, speed=speedinput)
				sleep(speedinput)
		if (direction == NORTH || direction == SOUTH)
			while (pilot.y != src.target_loc.y)
				if(QDELETED(pilot))
					break
				move_forward(pilot, direction, speed=speedinput)
				sleep(speedinput)

		// everything below is after the pilot reaches its destination

		if (!pilot.loopsound && pilot.attached_sound)
			for (var/mob/player in view(25, pilot))
				player << sound(pilot.attached_sound, volume=10)

		if (pathinput)
			if(ispath(pathinput, /atom/movable))
				var/counter
				playsound(pilot.loc, 'sound/effects/poff.ogg', 30, TRUE, pitch = 1)
				for (counter=0, counter<pathamountinput, counter++)
					var/turf/T = GetRandomPerimeterTurf(get_turf(pilot), 1)
					new pathinput(T)
					var/obj/itemspecialeffect/poof/P = new /obj/itemspecialeffect/poof
					P.setup(T)

		switch (src.end_effect)
			if ("Leave zlevel")
				while (pilot.loc)
					move_forward(pilot, direction, speed=speedinput)
					sleep(speedinput)
			if ("Run away")
				SPAWN(3 SECONDS)
					direction = turn(direction, 180)
					sprint_particle(pilot, pilot.loc)
					playsound(pilot.loc, 'sound/effects/sprint_puff.ogg', 30, 1)
					while (pilot.loc)
						move_forward(pilot, direction)
						sleep(1)
			if ("Explode")
				var/turf/T = get_turf(pilot)
				playsound(T, "sound/effects/Explosion[pick(1, 2)].ogg", 15, 1)
				new /obj/effects/explosion(T)
				qdel(pilot)
				robogibs(T)
			if ("Fade away")
				animate(pilot, transform = matrix(), alpha = 0, time = 0.5 SECONDS)
				for (var/i=0,i<=3,i++)
					move_forward(pilot, direction, 3)
					sleep(2)
				SPAWN(0)
					pilot.ClearAllOverlays()
					qdel(pilot)

	proc/move_forward(var/mob/image_pilot/pilot, var/direction, var/speed=1)
		var/glide = 0 // this system seems to desync sometimes, not a huge issue it seems to add a bit of variety to the way they move
		glide = (32 / speed) * world.tick_lag
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

	New()
		..()
		SPAWN(0)
			var/image/ship
			ship = image(icon=src.image_overlay, loc=src, layer = EFFECTS_LAYER_4)
			AddOverlays(ship, "ship")
			if (src.loopsound)
				play()

	disposing()
		src.attached_sound = null
		var/sound/stopsound = sound(null, wait = 0, channel=1020)
		world << stopsound
		..()

	proc/play()
		while (src) // replay sound if another spawned pilot is disposed, good for spamming
			src.attached_sound = sound(src.attached_sound, TRUE, TRUE, 1020, 10)
			world << src.attached_sound
			sleep(1 SECONDS)
