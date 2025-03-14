//TODO: SPRITES

//slightly cursed path because we just want the "immune to everything" quality
/obj/effects/current
	icon = 'icons/effects/effects.dmi'
	icon_state = "barrier"
	var/interval = 1

	Crossed(atom/movable/AM)
		..()
		if (HAS_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH) || (AM.event_handler_flags & IMMUNE_OCEAN_PUSH))
			return
		APPLY_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH, src, interval)
		BeginOceanPush(AM, interval, dir)

	Uncrossed(atom/movable/AM)
		..()
		REMOVE_ATOM_PROPERTY(AM, PROP_MOVABLE_OCEAN_PUSH, src)
		EndOceanPush(AM, interval)

/obj/landmark/current_spawner
	name = "current spawner"
	icon = 'icons/effects/effects.dmi'
	icon_state = "barrier"
	add_to_landmarks = FALSE
	var/interval = 10

	init(delay_qdel = FALSE)
		var/turf/T = get_turf(src)
		while(istype(T, /turf/space/fluid))
			var/obj/effects/current/new_current = new(T)
			new_current.dir = src.dir
			new_current.interval = src.interval
			T = get_step(T, src.dir)
		..()

/obj/machinery/current_turbine
	name = "NT40 tidal current turbine"
	anchored = ANCHORED
	icon = 'icons/obj/power.dmi'
	icon_state = "current_turbine0" //TODO: animated states (fear)
	density = TRUE
	glide_size = 32 / (1 SECOND)

/obj/turbine_shaft
	name = "turbine shaft"
	icon = 'icons/obj/power.dmi'
	icon_state = "turbine_shaft"
	anchored = ANCHORED
	density = FALSE
	layer = FLOOR_EQUIP_LAYER1
	glide_size = 32 / (1 SECOND)

	//this is all kind of unoptimized but it's only going to be running every few seconds and for relatively short shafts
	//refactor to be less pretty and more faster if we end up supporting very very long shafts for some reason
	proc/shove(dir)
		var/list/forward = src.get_connected(dir)
		var/turf/end_turf = length(forward) ? get_turf(forward[length(forward)]) : get_turf(src)
		var/turf/push_turf = get_step(end_turf, dir)
		if (push_turf.density)
			return FALSE //give up
		var/list/full_list = forward + list(src) + src.get_connected(turn(dir, 180))
		for (var/obj/machinery/current_turbine/turbine in full_list)
			if (locate(/obj/machinery/power/current_turbine_base) in get_step(turbine, dir)) //we're going to smack the turbine into the base
				return FALSE
		for (var/obj/shaft_piece in full_list)
			shaft_piece.set_loc(get_step(shaft_piece, dir))
		return TRUE

	proc/get_connected(dir)
		var/list/connected = list()
		var/turf/next_turf = get_step(src, dir)
		while(TRUE)
			if (next_turf.density)
				return connected
			var/obj/machinery/current_turbine/turbine = locate() in next_turf.contents
			var/obj/turbine_shaft/next_shaft = locate() in next_turf.contents
			if (turbine)
				connected += turbine
				return connected
			if (next_shaft)
				connected += next_shaft
			else
				return connected
			next_turf = get_step(next_turf, dir)

/obj/machinery/power/current_turbine_base
	name = "turbine base"
	icon = 'icons/obj/power.dmi'
	icon_state = "turbine_base"
	anchored = ANCHORED
	density = TRUE
	flags = FLUID_DENSE | TGUI_INTERACTIVE
	///The actual turbine on the end. TODO: handle multiple turbines?
	var/obj/machinery/current_turbine/turbine = null
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
		for (var/i in 1 to initial_length)
			T = get_step(T, turn(src.dir, 180)) //step backwards
			if (!T || T.density)
				break
			new /obj/turbine_shaft(T)

	proc/move_shaft(backwards = FALSE)
		if (!src.shaft)
			src.shaft = locate() in get_turf(src)
		if (!src.shaft)
			src.visible_message(SPAN_ALERT("[src] whirrs pointlessly."))
			playsound(src, 'sound/machines/hydraulic.ogg', 50, 1)
			return
		var/dir = src.dir
		if (backwards)
			dir = turn(src.dir, 180)
		if (!src.shaft.shove(dir))
			src.visible_message(SPAN_ALERT("[src] makes a protesting grinding noise."))
			animate_storage_thump(src)
			return
		src.shaft = locate() in get_turf(src)
		playsound(src, 'sound/machines/button.ogg', 50, 1)

	process(mult)
		if (!src.turbine)
			src.generation = 0
			return
		var/obj/effects/current/current = locate() in get_turf(src.turbine)
		if (!current)
			src.generation = 0
			return
		src.generation = 40 KILO WATTS / current.interval //caps out at 40KW by default
		src.add_avail(src.generation)
