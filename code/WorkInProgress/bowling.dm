/turf/simulated/bowling
	name = "floor"
	icon = 'bowling.dmi'
	icon_state = "bowling_floor"

	wet = 2

	Entered(atom/movable/entered as mob|obj)
		if (ismob(entered))
			var/mob/M = entered
			if (M.weakened<4 && !M.lying)
				M.remove_pulling()
				random_brute_damage(M, 5)
				M.weakened = max(8, M.weakened)

				if (M.client)
					M.show_message("<span class='notice'>You slipped on the floor!</span>")

				playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)

			SPAWN(0.1)
				step(M, M.dir)

		else
			var/obj/O = entered
			SPAWN(0.1)
				step(O, O.dir)

/obj/machinery/gutter
	density = 1
	flags = NOSPLASH
	anchored = 1

	name = "gutter"
	icon = 'bowling.dmi'
	icon_state = "bowling_gutter"

	var/datum/gas_mixture/air_contents
	var/obj/disposalpipe/trunk/trunk = null

	var/mode = 1

	New()
		..()
		SPAWN(0)
			src.link_gutter()

	proc/link_gutter()
		trunk = locate() in src.loc
		if(!trunk)
			mode = 0
			//icon_state = "" //broken, no trunk
		else
			trunk.linked = src	// link the pipe trunk to self
			//icon_state = "bowling_gutter"

		if(!air_contents)
			air_contents = new /datum/gas_mixture

	disposing()
		if(air_contents)
			qdel(air_contents)
			air_contents = null
		..()

	Bumped(atom/movable/bumper as mob|obj)
		if (mode)
			if (ismob(bumper))
				var/mob/living/M = bumper
				M.set_loc(src)
				boutput(M, "You fall into the [src]!")
				for(var/mob/V in viewers(src))
					if (V.client)
						V.show_message("[M] falls into the [src]!", 3)

			else
				var/obj/O = bumper
				O.set_loc(src)

			flush()

	relaymove(atom/movable/mover as mob|obj)
		return

	proc/flush()
		var/obj/disposalholder/H = new()	// virtual holder object which actually
											// travels through the pipes.

		H.init(src)	// copy the contents of disposer to holder
		H.start(src)

	proc/expel(var/obj/disposalholder/H)

		var/turf/target
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.set_loc(src.loc)
			AM.pipe_eject(0)
			SPAWN(1 DECI SECOND)
				if(AM)
					AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

	alter_health()
		return get_turf(src)

/turf/simulated/floor/pin
	name = "pin"
	icon = 'bowling.dmi'
	icon_state = "pin"

	Enter(atom/movable/mover as mob|obj)
		if (ismob(mover))
			var/mob/M = mover
			if (M.client)
				M.show_message("You hit [src]!", 3) //You get stuck here, turf is solid for some reason. Had a headache and didn't want to try to figure it out.
		..(mover)
