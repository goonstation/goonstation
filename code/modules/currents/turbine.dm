#define TURBINE_MOVE_TIME (2 SECONDS)


/obj/turbine_shaft
	name = "turbine shaft"
	desc = "A heavy duty metal shaft."
	icon = 'icons/obj/power.dmi'
	icon_state = "turbine_shaft"
	anchored = ANCHORED
	density = FALSE
	layer = FLOOR_EQUIP_LAYER1
	glide_size = 32 / TURBINE_MOVE_TIME
	dir = NORTH

	var/obj/turbine_shaft/next_shaft = null
	var/obj/turbine_shaft/last_shaft = null

	///Try to move all upstream shafts in dir
	proc/shove(dir)
		var/obj/turbine_shaft/shoved_shaft = null
		var/turf/test_turf = null
		if (dir == src.dir)
			test_turf = src.next_turf()
			shoved_shaft = src.next_shaft
		else
			test_turf = src.last_turf()
			shoved_shaft = src.last_shaft
		var/success = FALSE
		if (!shoved_shaft)
			if (test_turf && !test_turf.density)
				success = TRUE
		else
			success = shoved_shaft.shove(dir)

		if (success)
			src.set_loc(test_turf)
			return TRUE
		return FALSE

	proc/next_turf()
		RETURN_TYPE(/turf)
		return get_step(src, src.dir)

	proc/last_turf()
		RETURN_TYPE(/turf)
		return get_step(src, turn(src.dir, 180))

	///Lock them to NORTH/WEST dirs just to make things easier
	set_dir(new_dir)
		if (new_dir == EAST)
			new_dir = WEST
		else if (new_dir == SOUTH)
			new_dir = NORTH
		. = ..(new_dir)

	attackby(obj/item/I, mob/user)
		if (iswrenchingtool(I))
			if (src.last_shaft || src.next_shaft)
				src.visible_message("[user] unsecures [src].")
				src.anchored = FALSE
				src.next_shaft?.last_shaft = null
				src.next_shaft = null
				src.last_shaft?.next_shaft = null
				src.last_shaft = null
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			else
				src.attach()
				if (src.last_shaft || src.next_shaft)
					src.visible_message("[user] secures [src] in place.")
					playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			return
		. = ..()

	///Try to attach to other shafts to form a beeg one
	proc/attach()
		src.set_dir(src.dir)
		for (var/obj/turbine_shaft/other_shaft in src.next_turf())
			if (other_shaft.dir == src.dir)
				src.next_shaft = other_shaft
				other_shaft.last_shaft = src
				other_shaft.anchored = ANCHORED
				break
		for (var/obj/turbine_shaft/other_shaft in src.last_turf())
			if (other_shaft.dir == src.dir)
				src.last_shaft = other_shaft
				other_shaft.next_shaft = src
				other_shaft.anchored = ANCHORED
				break
		if (src.next_shaft || src.last_shaft)
			src.anchored = ANCHORED

/obj/turbine_shaft/turbine
	name = "NT40 tidal current turbine"
	anchored = ANCHORED
	icon = 'icons/obj/power.dmi'
	icon_state = "current_turbine0" //TODO: animated states (fear)
	density = TRUE

/obj/machinery/power/current_turbine_base
	name = "turbine base"
	icon = 'icons/obj/power.dmi'
	icon_state = "turbine_base"
	anchored = ANCHORED
	density = TRUE
	flags = FLUID_DENSE | TGUI_INTERACTIVE
	///The actual turbine on the end. TODO: handle multiple turbines?
	var/obj/turbine_shaft/turbine/turbine = null
	///The current shaft, can be null if some idiot overextends the shaft all the way out
	var/obj/turbine_shaft/shaft = null
	///How many extra lengths of shaft stick out the back
	var/initial_length = 5

	var/reversed = FALSE

	var/generation = 0

	New(new_loc)
		. = ..()
		src.init()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "CurrentTurbine")
			ui.open()

	ui_data(mob/user)
		return list(
			"reversed" = src.reversed,
			"generation" = src.generation * (src.reversed ? -1 : 1),
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return FALSE
		switch(action)
			if ("reverse")
				if (src.generation > 0)
					playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
				else
					src.reversed = !src.reversed
			if ("retract")
				src.move_shaft(backwards = TRUE)
			if ("extend")
				src.move_shaft(backwards = FALSE)

	proc/init()
		var/turf/T = get_turf(src)
		src.turbine = new(get_step(T, src.dir))
		src.shaft = new(T)
		src.shaft.attach()
		for (var/i in 1 to initial_length)
			T = get_step(T, turn(src.dir, 180)) //step backwards
			if (!T || T.density)
				break
			var/obj/turbine_shaft/shaft = new(T)
			shaft.attach()

	///Return either end of the current shaft
	proc/end_shaft(dir)
		RETURN_TYPE(/obj/turbine_shaft)
		var/obj/turbine_shaft/current_shaft = src.shaft
		if (dir == current_shaft.dir)
			while (current_shaft?.last_shaft)
				current_shaft = current_shaft.last_shaft
		else
			while (current_shaft?.next_shaft)
				current_shaft = current_shaft.next_shaft
		return current_shaft

	proc/move_shaft(backwards = FALSE)
		if (GET_COOLDOWN(src, "move_shaft"))
			return
		ON_COOLDOWN(src, "move_shaft", TURBINE_MOVE_TIME)
		if (!src.shaft)
			src.shaft = locate() in get_turf(src)
		if (!src.shaft)
			src.visible_message(SPAN_ALERT("[src] whirrs pointlessly."))
			playsound(src, 'sound/machines/hydraulic.ogg', 50, 1)
			return
		var/dir = src.dir
		if (backwards)
			dir = turn(src.dir, 180)
		if (!src.end_shaft(dir).shove(dir))
			src.visible_message(SPAN_ALERT("[src] makes a protesting grinding noise."))
			animate_storage_thump(src)
			return
		src.shaft = locate() in get_turf(src)
		playsound(src, 'sound/machines/button.ogg', 50, 1)

	Cross(atom/movable/mover)
		if (istype(mover, /obj/turbine_shaft) && (mover.dir == NORTH || mover.dir == SOUTH))
			return TRUE
		. = ..()

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			if (src.shaft)
				return src.shaft.Attackby(W, user)
			else
				var/obj/turbine_shaft/shaft = locate() in get_turf(src)
				shaft?.Attackby(W, user)
		else
			. = ..()

	process(mult)
		if (!src.turbine)
			src.generation = 0
			return
		var/obj/effects/current/current = locate() in get_turf(src.turbine)
		if (!current)
			src.generation = 0
			return
		src.generation = 0.4 KILO WATTS * current.controller.get_flow_rate() //caps out at 40KW by default
		src.add_avail(src.generation)


#undef TURBINE_MOVE_TIME
