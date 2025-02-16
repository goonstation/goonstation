/datum/random_event/minor/meatier_shower
	name = "Meatier Shower"
	required_elapsed_round_time = 26.6 MINUTES
	customization_available = 1
	disabled = TRUE // maybe a little silly
	var/wave_direction = 1
	var/bodies_in_wave = 45
	var/delay_between_bodies = 5
	var/tile_inaccuracy = 30
	var/map_boundary = 25
	var/warning_delay = 5 MINUTES
	var/body_speed = 10
	var/body_speed_variance = 4
	var/list/valid_directions = list(NORTH, EAST, SOUTH, WEST)
	var/shower_name = "meatier shower"
	var/meteor_type = /mob/living/carbon/human/normal

	event_effect(source, amount, direction, delay, warning_time, speed)
		..()

		if (isnum(direction) && direction == -1)
			direction = -1
		else
			if (!isnum(direction) || !(direction in valid_directions))
				// pick a random direction if no valid one given
				direction = pick(valid_directions)
				if (prob(2))
					direction = -1

		wave_direction = direction

		if (!isnum(amount))
			amount = rand(30,60)
		bodies_in_wave = amount

		if (!isnum(delay) || delay < 1)
			delay = rand(5,20)
		delay_between_bodies = delay

		if (!isnum(warning_time) || warning_time < 1)
			warning_time = 5 SECONDS
			//TODO: REMOVE TEST VALUE
			// warning_time = 5 MINUTES

		warning_delay = warning_time

		if (!isnum(speed) || speed < 1)
			speed = rand(5,15)
		body_speed = speed

		var/comdir = "an unknown direction"
		if (direction == -1)
			comdir = "from all directions"
		else
			if (station_or_ship() == "ship")
				comdir = "the [dir2nautical(direction, map_settings ? map_settings.dir_fore : NORTH, 1)] of the ship"
			else
				comdir = "from the [dir2text(direction)]"

		var/comsev = "Indeterminable"
		switch(amount)
			if(300 to INFINITY) comsev = "Apocalyptic" // one per world border size, ish
			if(50 to 299) comsev = "Catastrophic"
			if(25 to 49) comsev = "Major"
			if(11 to 24) comsev = "Significant"
			if(0 to 10) comsev = "Minor"

		var/commins = round((ticker.round_elapsed_ticks + warning_delay - ticker.round_elapsed_ticks)/10 ,1)
		commins = max(0,commins)
		if (random_events.announce_events)
			command_alert("[comsev] [shower_name] approaching [comdir]. Impact in [commins] seconds.", "Meatier Alert", alert_origin = ALERT_WEATHER)
			playsound_global(world, 'sound/machines/disaster_alert.ogg', 60)
			meteor_shower_active = (direction == -1 ? NORTH : direction)

		SPAWN(warning_delay)
			if (random_events.announce_events)
				command_alert("The [shower_name] has reached the [station_or_ship()]. Brace for impact.", "Meatier Alert", alert_origin = ALERT_WEATHER)
				playsound_global(world, 'sound/machines/disaster_alert.ogg', 60)

			var/start_x
			var/start_y
			var/targ_x
			var/targ_y
			var/effective_direction
			while(bodies_in_wave > 0)
				bodies_in_wave--

				// default to the given direction, but override it
				// for the special "every direction" one
				effective_direction = src.wave_direction
				if (effective_direction == -1)
					effective_direction = pick(valid_directions)

				// mostly target center station
				targ_x = 150
				targ_y = 150

				switch(effective_direction)
					if(NORTH) // north
						start_y = world.maxy-map_boundary
						start_x = rand(map_boundary, world.maxx-map_boundary)
					if(SOUTH) // south
						start_y = map_boundary
						start_x = rand(map_boundary, world.maxx-map_boundary)
					if(EAST) // east
						start_y = rand(map_boundary,world.maxy-map_boundary)
						start_x = world.maxx-map_boundary
					if(WEST) // west
						start_y = rand(map_boundary, world.maxy-map_boundary)
						start_x = map_boundary
					else // anywhere. this should not happen ever
						if(prob(50))
							start_y = pick(map_boundary,world.maxy-map_boundary)
							start_x = rand(map_boundary, world.maxx-map_boundary)
						else
							start_y = rand(map_boundary, world.maxy-map_boundary)
							start_x = pick(map_boundary,world.maxx-map_boundary)

				targ_x += rand(0 - tile_inaccuracy, tile_inaccuracy)
				targ_y += rand(0 - tile_inaccuracy, tile_inaccuracy)

				var/turf/pickedstart = locate(start_x, start_y, 1)
				var/target = locate(targ_x, targ_y, 1)
				var/mob/living/carbon/human/normal/meat = new meteor_type(pickedstart)
				meat.throw_at(target, 300, body_speed + rand(0 - body_speed_variance, body_speed_variance), throw_type=THROW_GIB)
				sleep(delay_between_bodies)

			meteor_shower_active = 0

	admin_call(var/source)
		if (..())
			return

		var/amtinput = input(usr,"How many bodies? (10~50++)",src.name) as num|null
		if (!isnum(amtinput) || amtinput < 1)
			return
		var/delinput = input(usr,"Tick delay between bodies? (10 = 1 second)",src.name) as num|null
		if (!isnum(delinput) || delinput < 1)
			return
		var/dirinput = input(usr,"Which direction should the bodies come from?",src.name) as null|anything in list("north","south","east","west","random","yes")
		if (!dirinput || !istext(dirinput))
			return
		switch(dirinput)
			if ("north") dirinput = NORTH
			if ("south") dirinput = SOUTH
			if ("east") dirinput = EAST
			if ("west") dirinput = WEST
			if ("random") dirinput = 0 // 0 = randomly chosen
			if ("yes") dirinput = -1 // yes
		var/timinput = input(usr,"How many ticks between the warning and the event? (10 = 1 second)",src.name) as num|null
		if (!isnum(timinput) || timinput < 1)
			return
		var/spdinput = input(usr,"How fast do the bodies move? (higher=faster)",src.name) as num|null
		if (!isnum(spdinput) || spdinput < 1)
			return

		src.event_effect(source,amtinput,dirinput,delinput,timinput,spdinput)
		return
