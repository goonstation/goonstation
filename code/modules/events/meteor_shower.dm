var/global/meteor_shower_active = 0

/datum/random_event/major/meteor_shower
	name = "Meteor Shower"
	// centcom message handled modularly here
#ifdef APRIL_FOOLS
	required_elapsed_round_time = 10 MINUTES
	weight = 300
#elif defined(RP_MODE)
	required_elapsed_round_time = 55 MINUTES
#else
	required_elapsed_round_time = 26.6 MINUTES
#endif
	customization_available = 1
	var/wave_direction = 1
	var/meteors_in_wave = 20
	var/delay_between_meteors = 5
	var/tile_inaccuracy = 10
	var/map_boundary = 25
	var/warning_delay = 5 MINUTES
	var/meteor_speed = 8
	var/meteor_speed_variance = 4
	var/list/valid_directions = list(NORTH, EAST, SOUTH, WEST)
#ifdef UNDERWATER_MAP
	var/shower_name = "cybershark attack"
	var/meteor_typepath = /obj/newmeteor/massive/shark
#else
	var/shower_name = "meteor shower"
	var/meteor_typepath = /obj/newmeteor/massive
#endif

	is_event_available(var/ignore_time_lock = 0)
		. = ..()
		if(.)
			if ( map_setting == "NADIR" ) // Nadir can have a counterpart to this event with acid hailstones, but it will need to function differently
				. = FALSE
			if (global.is_map_on_ground_terrain)
				. = FALSE

	event_effect(source, amount, direction, delay, warning_time, speed, datum/material/transmute_material_instead="random", custom_typepath = null, throw_flag=THROW_NORMAL, custom_name = null)
		..()
		var/thrown_thing_typepath = isnull(custom_typepath) ? meteor_typepath : custom_typepath
		// transmute effects only needed for `/obj/newmeteor`
		if (ispath(thrown_thing_typepath, /obj/newmeteor))
			if(transmute_material_instead == "random")
				#ifdef APRIL_FOOLS
				transmute_material_instead = "jean"
				#else
				if(prob(97))
					transmute_material_instead = null
				else
					if(prob(50))
						transmute_material_instead = "jean"
					else
						transmute_material_instead = pick(material_cache)
				#endif
			if(istext(transmute_material_instead))
				transmute_material_instead = getMaterial(transmute_material_instead)
			if(transmute_material_instead?.getID() == "jean")
				shower_name = "jeteor jower"

		if (!isnull(custom_name))
			shower_name = custom_name

		if (isnum(direction) && direction == -1)
			// dear station: get fucked
			// this is redundant. i'm a little stoned but
			// it feels better than leaving an empty code block
			direction = -1

		else
			if (!isnum(direction) || !(direction in valid_directions))
				// pick a random direction if no valid one given
				direction = pick(valid_directions)
				if (prob(2))
					// this is not nearly as bad as it might seem since so many miss
					direction = -1

		wave_direction = direction

		if (!isnum(amount))
			amount = rand(10,50)
		meteors_in_wave = amount

		if (!isnum(delay) || delay < 1)
			delay = rand(2,20)
		delay_between_meteors = delay

		if (!isnum(warning_time) || warning_time < 1)
			warning_time = 5 MINUTES
		warning_delay = warning_time

		if (!isnum(speed) || speed < 1)
			speed = rand(1,15)
		meteor_speed = speed

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
			command_alert("[comsev] [shower_name] approaching [comdir]. Impact in [commins] seconds.", "Meteor Alert", alert_origin = ALERT_WEATHER)
			playsound_global(world, 'sound/machines/disaster_alert.ogg', 60)
			// for all directions, just give, uh, up
			// todo: someone make shields have an all-sides option
			meteor_shower_active = (direction == -1 ? NORTH : direction)
			for (var/obj/machinery/shield_generator/S as anything in machine_registry[MACHINES_SHIELDGENERATORS])
				S.UpdateIcon()

		SPAWN(warning_delay)
			if (random_events.announce_events)
				command_alert("The [shower_name] has reached the [station_or_ship()]. Brace for impact.", "Meteor Alert", alert_origin = ALERT_WEATHER)
				playsound_global(world, 'sound/machines/disaster_alert.ogg', 60)

	#ifndef UNDERWATER_MAP
			switch(src.wave_direction)
				if (NORTH)
					ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/north, 0 SECONDS)
				if (EAST)
					ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/east, 0 SECONDS)
				if (SOUTH)
					ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/south, 0 SECONDS)
				if (WEST)
					ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/west, 0 SECONDS)
				if (-1)	// from ALL DIRECTIONS (may cause lag? probably not though, it's only 4 layers)
					ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/north, 0 SECONDS)
					ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/east, 0 SECONDS)
					ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/south, 0 SECONDS)
					ADD_PARALLAX_RENDER_SOURCE_TO_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/west, 0 SECONDS)
	#endif

			var/start_x
			var/start_y
			var/targ_x
			var/targ_y
			var/effective_direction
			while(meteors_in_wave > 0)
				meteors_in_wave--

				// default to the given direction, but override it
				// for the special "every direction" one
				effective_direction = src.wave_direction
				if (effective_direction == -1)
					effective_direction = pick(valid_directions)

				switch(effective_direction)
					if(NORTH) // north
						start_y = world.maxy-map_boundary
						targ_y = map_boundary
						start_x = rand(map_boundary, world.maxx-map_boundary)
						targ_x = start_x
					if(SOUTH) // south
						start_y = map_boundary
						targ_y = world.maxy-map_boundary
						start_x = rand(map_boundary, world.maxx-map_boundary)
						targ_x = start_x
					if(EAST) // east
						start_y = rand(map_boundary,world.maxy-map_boundary)
						targ_y = start_y
						start_x = world.maxx-map_boundary
						targ_x = map_boundary
					if(WEST) // west
						start_y = rand(map_boundary, world.maxy-map_boundary)
						targ_y = start_y
						start_x = map_boundary
						targ_x = world.maxx-map_boundary
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
				if (ispath(thrown_thing_typepath, /obj/newmeteor))
					var/obj/newmeteor/meteor = new thrown_thing_typepath(pickedstart, target)
					if(transmute_material_instead)
						meteor.set_transmute(transmute_material_instead)
						meteor.meteorhit_chance = 20
					meteor.pix_speed = meteor_speed + rand(0 - meteor_speed_variance,meteor_speed_variance)
				else
					var/atom/movable/thrown_thing = new thrown_thing_typepath(pickedstart)
					thrown_thing.throw_at(target, 300, meteor_speed + rand(0 - meteor_speed_variance,meteor_speed_variance), throw_type=throw_flag)

				sleep(delay_between_meteors)

			meteor_shower_active = 0
			for (var/obj/machinery/shield_generator/S as anything in machine_registry[MACHINES_SHIELDGENERATORS])
				S.UpdateIcon()

	#ifndef UNDERWATER_MAP
			REMOVE_PARALLAX_RENDER_SOURCE_FROM_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/north, 0 SECONDS)
			REMOVE_PARALLAX_RENDER_SOURCE_FROM_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/east, 0 SECONDS)
			REMOVE_PARALLAX_RENDER_SOURCE_FROM_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/south, 0 SECONDS)
			REMOVE_PARALLAX_RENDER_SOURCE_FROM_GROUP(Z_LEVEL_STATION, /atom/movable/screen/parallax_render_source/meteor_shower/west, 0 SECONDS)
	#endif

	admin_call(var/source)
		if (..())
			return

		var/used_meteor_typepath = src.meteor_typepath
		var/is_custom_type = alert(usr, "Specify a custom mob/obj path as meteor?", src.name, "Yes", "No")

		if (is_custom_type == "Yes")
			used_meteor_typepath = get_one_match(input("Type path", "Type path", "[used_meteor_typepath]"), /atom)

		var/amtinput = input(usr,"How many meteors? (10~50++)",src.name) as num|null
		if (!isnum(amtinput) || amtinput < 1)
			return
		var/delinput = input(usr,"Tick delay between meteors? (10 = 1 second)",src.name) as num|null
		if (!isnum(delinput) || delinput < 1)
			return
		var/dirinput = input(usr,"Which direction should the meteors come from?",src.name) as null|anything in list("north","south","east","west","random","yes")
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
		var/spdinput = input(usr,"How fast do the meteors move? (1~15, lower=faster)",src.name) as num|null
		if (!isnum(spdinput) || spdinput < 1)
			return

		var/transmute_material_instead = "random"
		var/throw_flag = THROW_NORMAL
		if (ispath(used_meteor_typepath, /obj/newmeteor))
			if(tgui_alert(usr, "Do you want the meteor to transmute into a material instead of exploding?", "Meteor Shower", list("Yes", "No")) == "Yes")
				var/matid = tgui_input_list(usr, "Select material to transmute to:", "Set Material", material_cache)
				transmute_material_instead = getMaterial(matid)
		else
			var/throw_flag_string = tgui_input_list(usr, "Choose throw flag", "Throw flag", global.throwflags, "THROW_NORMAL")
			throw_flag = global.throwflags[throw_flag_string]


		var/custom_name = null
		var/use_custom_name = alert(usr, "Specify a custom name to replace 'meteor shower'?", src.name, "Yes", "No")
		if (use_custom_name == "Yes")
			custom_name = input(usr, "Custom name to replace 'meteor shower':", src.name, src.shower_name)

		src.event_effect(source,amtinput,dirinput,delinput,timinput,spdinput,transmute_material_instead,used_meteor_typepath,throw_flag,custom_name)
		return

////////////////////////////////////////
// Defines for the meteors themselves //
////////////////////////////////////////

/obj/newmeteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "flaming"
	desc = "A chunk of space debris. You might want to stop staring at it and run."
	density = 1
	anchored = ANCHORED
	var/speed = 1
	var/pix_speed = 8
	var/hit_object = 0 //If we hit something we skip the next step (we dont move)
	var/time_to_die = 250
	var/hits = 16
	var/atom/target = null
	var/last_tile = null
	var/explodes = 0
	var/exploded = FALSE
	var/exp_dev = 0
	var/exp_hvy = 0
	var/exp_lit = 0
	var/exp_fsh = 0
	var/sound_impact = 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg'
	var/sound_explode = 'sound/effects/exlow.ogg'
	var/list/oredrops = list(/obj/item/raw_material/rock)
	var/list/oredrops_rare = list(/obj/item/raw_material/rock)
	var/datum/material/transmute_material = null
	var/transmute_range = 4
	var/meteorhit_chance = 100

	proc/set_transmute(datum/material/mat)
		src.setMaterial(mat)
		src.transmute_material = mat

	shark
		name = "shark chunk"
		desc = "A chunk of shark debris. You might want to stop staring at it and run. Trust me, this came from a shark."

	small
		name = "small meteor"
		icon_state = "smallf"
		hits = 9

		shark
			name = "small shark chunk"
			desc = "A chunk of shark debris. You might want to stop staring at it and run. Trust me, this came from a shark."

	New(var/atom/my_spawn, var/atom/trg)
		if(!my_spawn || !trg)
			..()
			return

		var/matrix/o = matrix()
		var/matrix/turn = turn(o, 120)
		animate(src, transform = o * turn, time = 8/3, loop = -1)
		animate(transform = o * turn * turn, time = 8/3, loop = -1)
		animate(transform = o, time = 8/3, loop = -1)
		//animate_spin(src, dir = "R", T = 1, looping = -1)
		src.set_loc(my_spawn)
		target = get_turf(trg)
		SPAWN(time_to_die)
			qdel(src)
		walk_towards(src, target, speed, pix_speed)
		process()
		..()

	disposing()
		target = null
		last_tile = null
		..()

	bump(atom/A)
		SPAWN(0)
			if (A)
				if (prob(meteorhit_chance))
					A.meteorhit(src)
				if (sound_impact)
					playsound(src.loc, sound_impact, 40, 1)
			if (--src.hits <= 0)
				if(istype(A, /obj/forcefield))
					src.explodes = 0
					shatter()
				else
					shatter(TRUE)

		return

	Move(atom/NewLoc, Dir)
		if(src.x == world.maxx || src.y == world.maxy || src.x == 1 || src.y == 1)
			qdel(src)
		if(src.loc == target)
			shatter(TRUE)
			return
		. = ..()
		if(src.loc == last_tile)
			walk_towards(src, target, speed, pix_speed)
		if(!hit_object)
			last_tile = src.loc
			src.loc.Exit(src, NewLoc)
			if(NewLoc.Enter())
				src.set_loc(NewLoc)
				src.set_dir(Dir)
				. = TRUE
		else
			hit_object = 0
		check_hits()

	ex_act(severity)
		shatter()

	meteorhit(var/obj/O as obj)
		if(O == src)
			return
		shatter()

	proc/process()
		if(src.x == world.maxx || src.y == world.maxy || src.x == 1 || src.y == 1)
			qdel(src)
		if(src.loc == target)
			shatter(TRUE)
			return
		if (src.loc == last_tile)
			walk_towards(src, target, speed, pix_speed)
		last_tile = src.loc
		SPAWN(1 SECOND)
			process()

	proc/check_hits()
		for(var/turf/T in range(1,src))
			if(!T.density)
				continue
			//let's not just go straight through unsimmed turfs and total the inside of the listening post
			if (!issimulatedturf(T) || !istype(T, /turf/unsimulated))
				if(istype(T, /turf/unsimulated/wall))
					qdel(src)
				continue
			hit_object = 1
			if (prob(meteorhit_chance))
				T.meteorhit(src)

		for(var/mob/M in range(1,src))
			if(M == src) continue //Just to make sure
			if(isobserver(M)) continue
			if(!M.density) continue
			hit_object = 1
			hits -= 5
			step(M,get_dir(src,M))
			if (prob(meteorhit_chance))
				M.meteorhit(src)
		var/dump_ore = TRUE
		for(var/obj/O in range(1,src))
			if (O == src) continue
			if (!O.density) continue
			hit_object = 1
			hits--
			if (istype(O, /obj/forcefield))
				dump_ore = FALSE
			if (prob(meteorhit_chance))
				O.meteorhit(src)
			if (O && !O.anchored)
				step(O,get_dir(src,O))

		if(hit_object)
			hits--
			playsound(src.loc, sound_impact, 40, 1)

		if(hits <= 0)
			shatter(dump_ore)

	proc/transmute_effect(range)
		var/range_squared = range**2
		var/turf/T = get_turf(src)
		var/smoothEdge = prob(10)
		var/affects_organic = pick(
			20; "transmute",
			5; "statue",
			40; "nothing"
		)
		for(var/atom/G in range(range, T))
			if(istype(G, /obj/overlay) || istype(G, /obj/effects) || istype(G, /turf/space) || istype(G, /obj/fluid))
				continue
			var/dist = GET_SQUARED_EUCLIDEAN_DIST(T, G)
			var/distPercent = (dist/range_squared)*80
			if(dist > range_squared)
				continue
			if(!smoothEdge && prob(distPercent))
				continue
			if(istype(G, /mob))
				if(!isliving(G) || isintangible(G)) // not stuff like ghosts, please
					continue
				var/mob/M = G
				switch(affects_organic)
					if("transmute")
						M.setMaterial(transmute_material)
						for(var/atom/I in M.get_all_items_on_mob())
							I.setMaterial(transmute_material)
					if("statue")
						if(distPercent < 40) // only inner 40% of range
							if(M)
								M.become_statue(transmute_material, survive = TRUE)
			else
				G.setMaterial(transmute_material)

	proc/shatter(dump_ore = FALSE, turf_safe = FALSE)
		if(exploded) return
		exploded = TRUE
		if(isnull(src.loc)) return
		playsound(src.loc, sound_explode, 50, 1)
		if (explodes)
			if(transmute_material)
				transmute_effect(src.transmute_range)
			else
				explosion(src, get_turf(src), exp_dev, exp_hvy, exp_lit, exp_fsh, turf_safe)
		if (dump_ore)
			src.dump_ore()
		qdel(src)

	proc/dump_ore()
		playsound(src.loc, sound_explode, 50, 1)
		for(var/turf/T in range(src,1))
			var/type
			if (prob(1)) type = pick(oredrops_rare)
			else type = pick(oredrops)
			var/atom/movable/A = new type
			A.set_loc(T)
			A.name = "[A.name] chunk"
			if(transmute_material)
				A.setMaterial(transmute_material)


/////////////////////////HUGE

/obj/newmeteor/massive
	name = "huge asteroid"
	icon = 'icons/obj/large/meteor96x96.dmi'
	icon_state = "flaming"
	density = 1
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_1
	//bound_width = 96
	//bound_height = 96
	pixel_x = -32
	pixel_y = -32
	hits = 10
	explodes = 1
	exp_dev = 0
	exp_hvy = 1
	exp_lit = 2
	exp_fsh = 3
	oredrops = list(/obj/item/raw_material/char, /obj/item/raw_material/mauxite, /obj/item/raw_material/rock)
	oredrops_rare = list(/obj/item/raw_material/starstone, /obj/item/raw_material/syreline)
	transmute_range = 10
	///Do we spawn a solid lump of rock on impact?
	var/solid_rock = TRUE

	shark
		name = "robotic shark"
		icon = 'icons/misc/64x32.dmi'
		icon_state = "gunshark"
		solid_rock = FALSE
		var/shatter_types = list(/obj/newmeteor/shark, /obj/newmeteor/small/shark)

		shatter()
			for(var/A in alldirs)
				if(prob(15))
					continue
				var/type = pick(shatter_types)
				var/atom/trg = get_step(src, A)
				var/obj/newmeteor/met = new type(src.loc, trg)
				met.meteorhit_chance = src.meteorhit_chance
			..()

	shatter(dump_ore = FALSE, turf_safe = FALSE)
		if (prob(50)) //chance to do normal ore spawn
			src.solid_rock = FALSE
		if (src.solid_rock)
			..(dump_ore, TRUE)
		else
			..()

	dump_ore()
		if (!src.solid_rock)
			return ..()

		var/list/turfs = list()
		for(var/turf/T in range(src,1))
			if (T.density || prob(40))
				continue
			var/turf/simulated/wall/auto/asteroid/asteroid = T.ReplaceWith(/turf/simulated/wall/auto/asteroid, FALSE, force = TRUE)
			if (src.transmute_material)
				asteroid.setMaterial(src.transmute_material)
			turfs += asteroid
		Turfspawn_Asteroid_SeedOre(turfs, rand(1,2), pick(90;1, 10;2, 1;3), FALSE)
