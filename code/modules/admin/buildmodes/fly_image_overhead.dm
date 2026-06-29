#define LEAVE "Leave zlevel"
#define RUN "Run away"
#define EXPLODE "Explode"
#define FADE "Fade away"

/datum/buildmode/fly_image_overhead
	name = "Fly Image Overhead"
	desc = {"***********************************************************<br>
Upload an image and/or audio and have it fly to target turf then play an ending effect.
Protip: tinker with this on a local first so you know what you're doing. Images are best around 100-200 pixels wide and long.<br>
<br>
RMB on buildmode button                = Set image and ending effect<br>
Ctrl  + RMB on buildmode button        = Set audio<br>
Alt   + RMB off of buildmode button    = Set optional obj/mob spawns<br>
Shift + RMB off of buildmode button    = Set direction and speed<br>
Shift + RMB off of buildmode button    = Spawn flying object<br>
***********************************************************"}
	// settings. behold my vars
	icon_state = "flyoverhead"
	var/move_delay = 1
	var/icon/image
	var/atom/icon_from_thing
	var/turf/target_loc
	var/audio
	var/image_layers_over_blackness = FALSE
	var/dir_input = "Random"
	var/end_effect = LEAVE
	var/spawnpath
	var/spawnamount = 1
	var/alphainput = 255
	var/startnearby = TRUE

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (!ctrl && !alt && !shift)
			src.icon_from_thing = tgui_input_list(usr, "Upload an image, set it from an icon or clear?", "Choose", list("Upload", "Icon Ref", "Clear"))
			switch (src.icon_from_thing)
				if ("Upload")
					src.image = null
					src.image = input(usr, "Upload an image:","File Uploader - Downsize your images to fit on the screen, local testing helps!", null) as null|icon
				if ("Clear")
					src.image = null
					usr.visible_message("Image cleared.")
					return
				if ("Icon Ref")
					src.image = null
					src.image = get_one_match(input("Type path", "Type path", "[src.spawnpath]"), /atom)
			src.alphainput = tgui_input_number(usr, "Enter an alpha level.", "Alpha", 255, 255, 0)
			if (src.image)
				logTheThing(LOG_ADMIN, usr, "uploaded an image [src.image] to use with Fly Object Overhead buildmode")
			src.end_effect = tgui_input_list(usr, "Pick ending effect", "End Effect", list(LEAVE, EXPLODE, FADE, RUN))
			src.image_layers_over_blackness = (tgui_alert(usr, "Layer above blackness?", "Blackness layer", list("Yes", "No")) == "Yes")

		if (ctrl)
			src.audio = input(usr, "Upload a file:", "Uploader - Long files WILL lag people out, sound will play once at destination", null) as null|sound
			if (src.audio)
				logTheThing(LOG_ADMIN, usr, "uploaded a sound [src.audio] to use with Fly Object Overhead buildmode")

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			src.dir_input = tgui_input_list(usr, "Pick starting direction", "Direction", list(NORTH, SOUTH, EAST, WEST, "Random"))
			var/choice = tgui_input_list(usr, "Choose a set speed or random values", "Choose", list("Set", "Clear"))
			var/choice2 = tgui_input_list(usr, "Start from edge of zlevel or nearby? (About 2 screens away)", "Choose", list("Edge", "Nearby"))
			if (choice == "Set")
				src.move_delay = tgui_input_number(usr, "Enter speed value of image", "Higher is slower, gets very slow by 5", 1)
			else
				src.move_delay = 1
			if (choice2 == "Nearby")
				src.startnearby = TRUE
			else
				src.startnearby = FALSE
		if (alt)
			var/choice = tgui_input_list(usr, "Spawn mobs/objects or clear?", "Choose", list("Spawn", "Clear"))
			if (choice == "Spawn")
				src.spawnpath = get_one_match(input("Type path", "Type path", "[src.spawnpath]"), /atom)
				src.spawnamount = tgui_input_number(usr, "Amount to spawn", "Amount - Be responsible!!", 1)
			else
				src.spawnpath = null
				src.spawnamount = 1

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (shift)
			src.target_loc = get_turf(object)
			aim_pilot()

	proc/aim_pilot() // Spawn pilot at edge of zlevel then redirect to target
		var/turf/start
		var/random_dir = pick(NORTH, SOUTH, EAST, WEST)
		var/new_dir
		if (!src.target_loc || !src.dir_input)
			boutput(usr, "No target location and/or direction input found.")
			return
		if (!src.audio && !src.image)
			boutput(usr, "No audio or image file found.")
			return

		if (src.dir_input == "Random")
			new_dir = random_dir
		else
			new_dir = src.dir_input

		if (src.startnearby) // set pilot's spawn location
			start = get_ranged_target_turf(src.target_loc, new_dir, 35)
		else
			start = get_edge_target_turf(src.target_loc, new_dir)

		new_dir = turn(new_dir, 180) // set where the pilot is facing to the direction of target loc
		send_pilot(start,new_dir)

	proc/send_pilot(var/turf/startloc,var/direction=EAST)
		var/obj/image_pilot/pilot = new /obj/image_pilot()
		var/speedinput = src.move_delay
		var/pathinput = src.spawnpath
		var/pathamountinput = src.spawnamount
		var/turf/target_locinput = src.target_loc
		pilot.image_overlay = src.image
		pilot.attached_sound = src.audio
		pilot.alpha = 0
		pilot.set_loc(startloc)
		animate(pilot, transform = matrix(), alpha = src.alphainput, time = 0.8 SECONDS)

		if (src.image_layers_over_blackness)
			pilot.plane = PLANE_ABOVE_BLACKNESS
		else
			pilot.plane = PLANE_DEFAULT

		if (direction == WEST || direction == EAST)
			while (pilot.x != target_locinput.x)
				if(QDELETED(pilot)) // pilot gets deleted in move_forward when it is without a loc
					break
				move_forward(pilot, direction, speed=speedinput)
				sleep(speedinput)
		if (direction == NORTH || direction == SOUTH)
			while (pilot.y != target_locinput.y)
				if(QDELETED(pilot))
					break
				move_forward(pilot, direction, speed=speedinput)
				sleep(speedinput)

		// everything below is after the pilot reaches its destination

		if (pilot.attached_sound)
			playsound(target_locinput, pilot.attached_sound, 30)

		if (pathinput) // spawn your optional mobs and objects if chosen
			if(ispath(pathinput, /atom/movable))
				playsound(pilot.loc, 'sound/effects/poff.ogg', 30, TRUE, pitch = 1)
				for (var/i in 1 to pathamountinput)
					var/turf/T = GetRandomPerimeterTurf(get_turf(pilot), 1)
					new pathinput(T)
					var/obj/itemspecialeffect/poof/P = new
					P.setup(T)

		switch (src.end_effect)
			if (LEAVE)
				while (pilot.loc)
					move_forward(pilot, direction, speed=speedinput)
					sleep(speedinput)
			if (RUN)
				SPAWN(3 SECONDS)
					direction = turn(direction, 180)
					new/obj/particle/attack/sprint(pilot.loc)
					playsound(pilot.loc, 'sound/effects/sprint_puff.ogg', 30, 1)
					while (pilot.loc)
						move_forward(pilot, direction)
						sleep(1)
			if (EXPLODE)
				var/turf/T = get_turf(pilot)
				new /obj/effects/explosion(T)
				robogibs(T)
				playsound(T, pick(big_explosions), 80, 1)
				animate(pilot, transform = matrix(), alpha = 0, time = 0.5 SECONDS)
				SPAWN(15 SECONDS) // Wait some time to let most uploaded sounds play out first. Couldn't get rustg sound len to work instead
					qdel(pilot)
			if (FADE)
				animate(pilot, transform = matrix(), alpha = 0, time = 0.5 SECONDS)
				for (var/i=0,i<=3,i++)
					move_forward(pilot, direction, 3)
					sleep(2)
				SPAWN(0)
					pilot.ClearAllOverlays()
					qdel(pilot)

	proc/move_forward(var/obj/image_pilot/pilot, var/direction, var/speed=1)
	 	// this system seems to desync sometimes, not a huge issue it seems to add a bit of variety to the way they move
		var/glide = (32 / speed) * world.tick_lag
		pilot.glide_size = glide
		pilot.animate_movement = SLIDE_STEPS
		var/old_loc = pilot.loc
		pilot.set_loc(get_step(pilot, direction))
		pilot.dir = direction
		SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, direction)
		if (!pilot.loc)
			qdel(pilot)
		pilot.glide_size = glide
		pilot.animate_movement = SLIDE_STEPS

/obj/image_pilot
	name = ""
	desc = ""
	anchored = ANCHORED_ALWAYS
	density = 0
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	flags = KEEP_TOGETHER
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	var/icon/image_overlay
	var/sound/attached_sound
	var/loopsound = FALSE
	var/parent_admin

	New()
		..()
		SPAWN(0)
			var/image/ship
			ship = image(icon=src.image_overlay, loc=src, layer = EFFECTS_LAYER_4)
			AddOverlays(ship, "ship")

#undef LEAVE
#undef RUN
#undef EXPLODE
#undef FADE
