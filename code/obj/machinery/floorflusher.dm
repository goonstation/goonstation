//Floor Flushing Mechanism.
ADMIN_INTERACT_PROCS(/obj/machinery/floorflusher, proc/flush)
/obj/machinery/floorflusher
	name = "\improper Floor Flusher"
	desc = "It's totally not just a gigantic disposal chute!"
	//icon = 'icons/obj/disposal.dmi'
	icon = 'icons/obj/delivery.dmi' // new icon
	icon_state = "floorflush_c"
	anchored = ANCHORED
	power_usage = 100
	density = 0
	flags = NOSPLASH
	plane = PLANE_NOSHADOW_BELOW

	var/open = 0 //is it open
	var/opening = FALSE // is the flusher opening/closing? Used for door_timer.dm
	var/id = null //ID used for brig stuff
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = 1	// item mode 0=off 1=charging 2=charged
	var/flush = 0	// true if triggered
	var/obj/disposalpipe/trunk/trunk = null // the attached pipe trunk, if none reject user
	var/flushing = 0	// true if flushing in progress
	var/mail_tag = null // mail_tag to apply on next flush
	var/mail_id = null // id for linking a flusher for mail tagging
	HELP_MESSAGE_OVERRIDE({"You can use a <b>crowbar</b> to pry it open."})
	// Please keep synchronizied with these lists for easy map changes:
	// /obj/storage/secure/closet/brig_automatic (secure_closets.dm)
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
		START_TRACKING
		SPAWN(0.5 SECONDS)
			trunk = locate() in src.loc
			if(!trunk)
				mode = 0
				flush = 0
			else
				trunk.linked = src	// link the pipe trunk to self

			air_contents = new /datum/gas_mixture
			//gas.volume = 1.05 * CELLSTANDARD
			update()

	disposing()
		if(air_contents)
			qdel(air_contents)
			air_contents = null
		..()
		STOP_TRACKING

	// attack by item places it in to disposal
	attackby(var/obj/item/I, var/mob/user)
		if(status & BROKEN)
			return
		if (ispryingtool(I) && !src.open && !src.opening && !src.flushing)
			playsound(src, 'sound/machines/airlock_pry.ogg', 35, TRUE)
			src.openup()
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

	Crossed(atom/movable/AM)
		..()
		//you can fall in if its open
		if (open == 1)
			if (isobj(AM))
				if (AM:anchored) return //can't have hotspots, overlays, etc.
				var/obj/O = AM
				src.visible_message("[O] falls into [src].")
				O.set_loc(src)
				flush = 1
				update()

			if (isliving(AM))
				if (AM:anchored >= ANCHORED_ALWAYS) return
				if (isintangible(AM)) // STOP EATING BLOB OVERMINDS ALSO
					return
				var/mob/living/M = AM
				if (M.buckled)
					M.buckled = null
				boutput(M, "You fall into [src].")
				src.visible_message("[M] falls into [src].")
				M.set_loc(src)
				flush = 1
				update()

			if(current_state <= GAME_STATE_PREGAME)
				SPAWN(0)
					flush()
					sleep(1 SECOND)
					openup()

	MouseDrop_T(mob/target, mob/user)
		if (!istype(target) || target.buckled || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, target) > 0 || is_incapacitated(user) || isAI(user))
			return

		if(open != 1)
			return

		var/msg

		if(target == user && !user.stat)	// if drop self, then climbed in
												// must be awake
			msg = "[user.name] falls into [src]."
			boutput(user, "You fall into [src].")
		else if(target != user && !user.restrained())
			msg = "[user.name] pushes [target.name] into [src]!"
			boutput(user, "You push [target.name] into [src]!")
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
		boutput(user, SPAN_ALERT("It's too deep. You can't climb out."))
		return

	// ai cannot interface.
	attack_ai(mob/user as mob)
		boutput(user, SPAN_ALERT("You cannot interface with this device."))

	// human interact with machine
	attack_hand(mob/user)
		src.add_fingerprint(user)
		if (open != 1)
			return
		if(status & BROKEN)
			src.remove_dialog(user)
			return


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
		if(length(contents) > 0)
			var/mob/living/M = locate() in contents
			if(M)
				flush = 1
				if(M.hasStatus("handcuffed"))
					boutput(M, "You feel your handcuffs being removed.")
					M.handcuffs.drop_handcuffs(M)

				//Might as well set their security record to "released"
				var/nameToCheck = M.name
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					// this makes it so that if your face is unobstructed and your id is wrong, i.e. you show up as John Smith (as Someone Else)
					// it will take into account your actual name (John Smith) and still work, instead of searching for a "John Smith (as Someone Else)" in the records
					// unless your face is obstructed, then it works normally by taking your visible name, with intended or unintended results
					nameToCheck = H.face_visible() ? H.real_name : H.name
					var/datum/db_record/R = data_core.security.find_record("name", nameToCheck)
					if(!isnull(R) && ((R["criminal"] == ARREST_STATE_INCARCERATED) || (R["criminal"] == ARREST_STATE_ARREST) || (R["criminal"] == ARREST_STATE_DETAIN)))
						R["criminal"] = ARREST_STATE_RELEASED
						H.update_arrest_icon()

	// timed process
	// charge the gas reservoir and perform flush if ready
	process()
		if(QDELETED(trunk))
			trunk = locate() in src.loc
			if(!trunk)
				mode = 0
				flush = 0
				if (src.open)
					src.closeup()
				for (var/atom/movable/AM in src)
					src.expel_thing(AM)
			else
				trunk.linked = src	// link the pipe trunk to self
				mode = 1

		if(status & BROKEN)			// nothing can happen if broken
			return

		if(open && flush)	// flush can happen even without power, must be open first
			SPAWN(0)
				flush()

		if(status & NOPOWER)			// won't charge if no power
			return

		..()
		if(mode != 1)		// if off or ready, no need to charge
			return
		return

	// perform a flush
	proc/flush()

		flushing = 1

		closeup()
		var/obj/disposalholder/H = new /obj/disposalholder	// virtual holder object which actually
																// travels through the pipes.
		H.mail_tag = src.mail_tag // apply mail_tag

		H.init(src)	// copy the contents of disposer to holder

		ZERO_GASES(air_contents)

		sleep(1 SECOND)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE, 0)
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
		opening = TRUE
		flick("floorflush_a", src)
		src.icon_state = "floorflush_o"
		for(var/atom/movable/AM in src.loc)
			src.Crossed(AM) // try to flush them
		SPAWN(0.7 SECONDS)
			opening = FALSE

	proc/closeup()
		open = 0
		opening = TRUE
		flick("floorflush_a2", src)
		src.icon_state = "floorflush_c"
		SPAWN(0.7 SECONDS)
			opening = FALSE

	// called when holder is expelled from a disposal
	// should usually only occur if the pipe network is modified
	proc/expel(var/obj/disposalholder/H)
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, 0)
		for(var/atom/movable/AM in H)
			src.expel_thing(AM)

		H.vent_gas(loc)
		qdel(H)

	proc/expel_thing(atom/movable/AM)
		var/turf/target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))
		AM.set_loc(get_turf(src))
		AM.pipe_eject(0)
		AM?.throw_at(target, 5, 1)

	return_air(direct = FALSE)
		return air_contents

/obj/machinery/floorflusher/industrial
	name = "industrial loading chute"
	desc = "Totally just a giant disposal chute"
	icon = 'icons/obj/delivery.dmi'

	New()
		..()
		SPAWN(1 SECOND)
			openup()

		return 1

	Crossed(atom/movable/AM)
		..()
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

			if(current_state <= GAME_STATE_PREGAME)
				SPAWN(0)
					flush()
					sleep(1 SECOND)
					openup()

	process()
		if(status & BROKEN)			// nothing can happen if broken
			return

		if(open && flush)	// flush can happen even without power, must be open first
			SPAWN(0) flush()

		if(status & NOPOWER)			// won't charge if no power
			return

		..()

		if(mode == 1)
			mode = 2
			if (!open)
				openup()

		return
