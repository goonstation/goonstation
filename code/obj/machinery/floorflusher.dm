//Floor Flushing Mechanism.

/obj/machinery/floorflusher
	name = "\improper Floor Flusher"
	desc = "It's totally not just a gigantic disposal chute!"
	//icon = 'icons/obj/disposal.dmi'
	icon = 'icons/obj/delivery.dmi' // new icon
	icon_state = "floorflush_c"
	anchored = 1
	density = 0
	flags = NOSPLASH
	event_handler_flags = USE_HASENTERED
	plane = PLANE_NOSHADOW_BELOW

	var/open = 0 //is it open
	var/id = null //ID used for brig stuff
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = 1	// item mode 0=off 1=charging 2=charged
	var/flush = 0	// true if triggered
	var/obj/disposalpipe/trunk/trunk = null // the attached pipe trunk, if none reject user
	var/flushing = 0	// true if flushing in progress

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/storage/secure/closet/brig/automatic (secure_closets.dm)
	// /obj/machinery/door_timer (door_timer.dm)
	// /obj/machinery/door/window/brigdoor (window.dm)
	// /obj/machinery/flasher (flasher.dm)
	solitary
		name = "\improper Floor Flusher (Cell #1)"
		id = "solitary"

	solitary2
		name = "\improper Floor Flusher (Cell #2)"
		id = "solitary2"

	solitary3
		name = "\improper Floor Flusher (Cell #3)"
		id = "solitary3"

	solitary4
		name = "\improper Floor Flusher (Cell #4)"
		id = "solitary4"

	minibrig
		name = "\improper Floor Flusher (Mini-Brig)"
		id = "minibrig"

	minibrig2
		name = "\improper Floor Flusher (Mini-Brig #2)"
		id = "minibrig2"

	minibrig3
		name = "\improper Floor Flusher (Mini-Brig #3)"
		id = "minibrig3"

	genpop
		name = "\improper Floor Flusher (Genpop)"
		id = "genpop"

	genpop_n
		name = "\improper Floor Flusher (Genpop North)"
		id = "genpop_n"

	genpop_s
		name = "\improper Floor Flusher (Genpop South)"
		id = "genpop_s"

	// create a new floor flusher
	// find the attached trunk (if present) and init gas resvr.
	New()
		..()
		SPAWN_DBG(0.5 SECONDS)
			trunk = locate() in src.loc
			if(!trunk)
				mode = 0
				flush = 0
			else
				trunk.linked = src	// link the pipe trunk to self

			air_contents = unpool(/datum/gas_mixture)
			//gas.volume = 1.05 * CELLSTANDARD
			update()

	disposing()
		if(air_contents)
			pool(air_contents)
			air_contents = null
		..()

	// attack by item places it in to disposal
	attackby(var/obj/item/I, var/mob/user)
		if(status & BROKEN)
			return

		if(open == 1)
			if (istype(I, /obj/item/grab))
				return
			if (isghostdrone(user))
				var/mob/living/silicon/ghostdrone/G = user
				if (istype(G.active_tool, /obj/item/magtractor))
					var/obj/item/magtractor/mag = G.active_tool
					if (mag.holding == I)
						mag.dropItem(0)
						I.set_loc(src)
						user.visible_message("[user] drops \the [I] into the [src].", "You drop \the [I] into the inky blackness of the [src].")
						update()
					return
				else if (G.active_tool == I)
					return
			else if (isrobot(user) || isshell(user)) // neither of these guys should be able to drop things in here!!
				return
			user.drop_item()
			I.set_loc(src)
			user.visible_message("[user] drops \the [I] into the [src].", "You drop \the [I] into the inky blackness of the [src].")

		update()

	// mouse drop another mob or self

	HasEntered(atom/AM)
		//you can fall in if its open
		if (open == 1)
			if (isobj(AM))
				if (AM:anchored) return //can't have hotspots, overlays, etc.
				var/obj/O = AM
				src.visible_message("[O] falls into [src].")
				O.set_loc(src)
				update()

			if (isliving(AM))
				if (AM:anchored) return
				if (isintangible(AM)) // STOP EATING BLOB OVERMINDS ALSO
					return
				var/mob/living/M = AM
				if (M.buckled)
					M.buckled = null
				boutput(M, "You fall into the [src].")
				src.visible_message("[M] falls into the [src].")
				M.set_loc(src)
				flush = 1
				update()

	MouseDrop_T(mob/target, mob/user)
		if (!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || user.getStatusDuration("paralysis") || user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || isAI(user))
			return

		if(open != 1)
			return

		var/msg

		if(target == user && !user.stat)	// if drop self, then climbed in
												// must be awake
			msg = "[user.name] falls into [src]."
			boutput(user, "You fall into [src].")
		else if(target != user && !user.restrained())
			msg = "[user.name] pushes [target.name] into the [src]!"
			boutput(user, "You push [target.name] into the [src]!")
		else
			return
		target.set_loc(src)

		for (var/mob/C in AIviewers(src))
			if(C == user)
				continue
			C.show_message(msg, 3)

		update()
		return

	// can breath normally in the disposal
	alter_health()
		return get_turf(src)

	// attempt to move while inside
	relaymove(mob/user as mob)
		if(user.stat || src.flushing)
			return
		boutput(user, "<span class='alert'>It's too deep. You can't climb out.</span>")
		return

	// ai cannot interface.
	attack_ai(mob/user as mob)
		boutput(user, "<span class='alert'>You cannot interface with this device.</span>")

	// human interact with machine
	attack_hand(mob/user as mob)
		src.add_fingerprint(usr)
		if (open != 1)
			return
		if(status & BROKEN)
			src.remove_dialog(user)
			return

		//fall in hilariously
		boutput(user, "You slip and fall in.")
		user.set_loc(src)
		update()


	// eject the contents of the unit
	proc/eject()
		for(var/atom/movable/AM in src)
			AM.set_loc(src.loc)
			AM.pipe_eject(0)
		update()

	// update the icon & overlays to reflect mode & status
	proc/update()
		overlays = null
		if(status & BROKEN)
			icon_state = "floorflush_c"
			mode = 0
			flush = 0
			return

		// 	check for items in disposal - if there is a mob in there, flush.
		if(contents.len > 0)
			var/mob/living/M = locate() in contents
			if(M)
				flush = 1
				if(M.hasStatus("handcuffed"))
					boutput(M, "You feel your handcuffs being removed.")
					M.handcuffs.drop_handcuffs(M)

	// timed process
	// charge the gas reservoir and perform flush if ready
	process()
		if(status & BROKEN)			// nothing can happen if broken
			return

		if(open && flush)	// flush can happen even without power, must be open first
			SPAWN_DBG(0)
				flush()

		if(status & NOPOWER)			// won't charge if no power
			return

		use_power(100)		// base power usage

		if(mode != 1)		// if off or ready, no need to charge
			return
		return

	// perform a flush
	proc/flush()

		flushing = 1

		closeup()
		var/obj/disposalholder/H = unpool(/obj/disposalholder)	// virtual holder object which actually
																// travels through the pipes.

		H.init(src)	// copy the contents of disposer to holder

		air_contents.zero() // empty gas

		sleep(1 SECOND)
		playsound(src, "sound/machines/disposalflush.ogg", 50, 0, 0)
		sleep(0.5 SECONDS) // wait for animation to finish


		H.start(src) // start the holder processing movement
		flushing = 0
		// now reset disposal state
		flush = 0



		if(mode == 2)	// if was ready,
			mode = 1	// switch to charging
		update()
		return

	// called when area power changes
	power_change()
		..()	// do default setting/reset of stat NOPOWER bit
		update()	// update icon
		return


	//open up, called on trigger
	proc/openup()
		open = 1
		flick("floorflush_a", src)
		src.icon_state = "floorflush_o"

	proc/closeup()
		open = 0
		flick("floorflush_a2", src)
		src.icon_state = "floorflush_c"

	// called when holder is expelled from a disposal
	// should usually only occur if the pipe network is modified
	proc/expel(var/obj/disposalholder/H)

		var/turf/target
		playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.set_loc(src.loc)
			AM.pipe_eject(0)
			AM?.throw_at(target, 5, 1)

		H.vent_gas(loc)
		pool(H)


/obj/machinery/floorflusher/industrial
	name = "industrial loading chute"
	desc = "Totally just a giant disposal chute"
	icon = 'icons/obj/delivery.dmi'
	event_handler_flags = USE_HASENTERED

	New()
		..()
		SPAWN_DBG (10)
			openup()

	Crossed(atom/movable/AM)
		if (AM && AM.loc == src.loc)
			HasEntered(AM)

		return 1

	HasEntered(atom/movable/AM)
		if (open == 1)
			if (isobj(AM))
				if (AM.anchored) return
				var/obj/O = AM
				if (O.loc != src.loc)
					return

				src.visible_message("[O] falls into [src].")
				O.set_loc(src)

				flush = 1
				update()

			else if (isliving(AM))
				if (AM.anchored) return
				if (isintangible(AM)) // STOP EATING BLOB OVERMINDS ALSO
					return
				var/mob/living/M = AM
				if (M.buckled)
					M.buckled = null
				boutput(M, "You fall into the [src].")
				src.visible_message("[M] falls into [src].")
				M.set_loc(src)
				flush = 1
				update()

	process()
		if(status & BROKEN)			// nothing can happen if broken
			return

		if(open && flush)	// flush can happen even without power, must be open first
			SPAWN_DBG(0) flush()

		if(status & NOPOWER)			// won't charge if no power
			return

		use_power(100)		// base power usage

		if(mode == 1)
			mode = 2
			if (!open)
				openup()

		return
