#define TURBINE_MOVE_TIME (2 SECONDS)


/obj/machinery/turbine_shaft
	name = "turbine shaft"
	desc = "A heavy duty metal shaft."
	icon = 'icons/obj/machines/current_turbine.dmi' //TODO: east west sprites
	icon_state = "shaft_0"
	density = FALSE
	layer = FLOOR_EQUIP_LAYER1
	glide_size = 32 / TURBINE_MOVE_TIME
	dir = NORTH

	var/base_icon_state = "shaft"
	var/speed_state = 0
	var/obj/machinery/turbine_shaft/next_shaft = null
	var/obj/machinery/turbine_shaft/last_shaft = null
	var/obj/machinery/power/current_turbine_base/base = null

	///Try to move all upstream shafts in dir
	proc/shove(dir)
		var/obj/machinery/turbine_shaft/shoved_shaft = null
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
				src.base = null
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			else
				src.attach()
				if (src.last_shaft || src.next_shaft)
					src.visible_message("[user] secures [src] in place.")
					playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			return
		if (ispryingtool(I))
			src.set_dir(turn(src.dir, 90))
			return
		. = ..()

	///Try to attach to other shafts to form a beeg one
	proc/attach()
		src.set_dir(src.dir)
		for (var/obj/machinery/turbine_shaft/other_shaft in src.next_turf())
			if (other_shaft.dir == src.dir)
				src.next_shaft = other_shaft
				other_shaft.last_shaft = src
				other_shaft.anchored = ANCHORED
				break
		for (var/obj/machinery/turbine_shaft/other_shaft in src.last_turf())
			if (other_shaft.dir == src.dir)
				src.last_shaft = other_shaft
				other_shaft.next_shaft = src
				other_shaft.anchored = ANCHORED
				break
		if (src.next_shaft || src.last_shaft)
			src.anchored = ANCHORED

	proc/update(obj/machinery/power/current_turbine_base/base)
		ON_COOLDOWN(src, "last_updated", 2 SECONDS)
		src.speed_state = 0
		src.base = base
		switch(base.rpm)
			if (1 to 33)
				src.speed_state = 3
			if (34 to 66)
				src.speed_state = 2
			if (67 to INFINITY)
				src.speed_state = 1
		src.UpdateIcon()
		src.next_shaft?.update(base)

	process(mult)
		if (GET_COOLDOWN(src, "last_updated"))
			return
		src.speed_state = 0
		src.UpdateIcon()

	update_icon()
		src.icon_state = "[src.base_icon_state]_[src.speed_state]"

/obj/machinery/turbine_shaft/turbine
	name = "NT40 tidal current turbine"
	icon_state = "turbine_0"
	base_icon_state = "turbine"
	density = TRUE

	New()
		. = ..()
		src.UpdateOverlays(image(src.icon, "turbine_anchor", layer = src.layer - 0.1), "anchor")
		src.UpdateIcon(0)

	Bumped(mob/living/M)
		if (!istype(M) || isintangible(M))
			return
		switch(src.speed_state)
			if (3)
				src.visible_message(SPAN_ALERT("[M] smacks into [src]. Ow!"))
				random_brute_damage(M, rand(10,15))
				playsound(src, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
			if (2)
				src.visible_message(SPAN_ALERT("[M] gets slashed by the spinning blades of [src]!"))
				random_brute_damage(M, rand(15, 20))
				playsound(src, 'sound/impact_sounds/Flesh_Tear_3.ogg', 50, 1)
				M.changeStatus("stunned", 3 SECONDS)
				if (ishuman(M) && prob(30))
					var/mob/living/carbon/human/human = M
					human.limbs.sever(pick("l_arm", "r_arm", "l_leg", "r_leg"))
			if (1)
				src.visible_message(SPAN_ALERT("[M] gets mangled by the rapidly spinning blades of [src]! SHIT!"))
				random_brute_damage(M, rand(20, 30))
				playsound(src, 'sound/impact_sounds/Flesh_Tear_1.ogg', 50, 1)
				M.changeStatus("knockdown", 6 SECONDS)
				if (ishuman(M))
					var/mob/living/carbon/human/human = M
					human.limbs.sever(pick("l_arm", "r_arm", "l_leg", "r_leg", "both_legs"))


	update_icon()
		. = ..()
		src.UpdateOverlays(image(src.icon, "[/obj/machinery/turbine_shaft::base_icon_state]_[src.speed_state]", layer = src.layer - 0.1), "internal_shaft")

	update(obj/machinery/power/current_turbine_base/base)
		. = ..()
		base.turbine = src //TODO: handle multiple turbines???


/obj/machinery/power/current_turbine_base
	name = "turbine base"
	icon = 'icons/obj/machines/current_turbine.dmi'
	icon_state = "turbine_base"
	anchored = ANCHORED
	density = TRUE
	flags = FLUID_DENSE | TGUI_INTERACTIVE
	processing_tier = PROCESSING_HALF
	///The actual turbine on the end. TODO: handle multiple turbines?
	var/obj/machinery/turbine_shaft/turbine/turbine = null
	///The current shaft, can be null if some idiot overextends the shaft all the way out
	var/obj/machinery/turbine_shaft/shaft = null
	///How many extra lengths of shaft stick out the back
	var/initial_length = 5

	var/reversed = FALSE

	var/generation = 0

	var/rpm = 0

	//power = stator load * rpm/60
	//sooo if we want the power to cap out at ~40kw and 100rpm (big slow water turbine)
	//stator load = (60 * 40 * 1000)/100 = 24kj/rev
	var/stator_load = 24 KILO //per revolution

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
			"rpm" = src.rpm,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return FALSE
		switch(action)
			if ("reverse")
				if (src.generation > 0) //can't reverse while it's spinning
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
			var/obj/machinery/turbine_shaft/shaft = new(T)
			shaft.attach()

	///Return either end of the current shaft, depending on dir
	proc/end_shaft(dir)
		RETURN_TYPE(/obj/machinery/turbine_shaft)
		var/obj/machinery/turbine_shaft/current_shaft = src.shaft
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
			src.visible_message(SPAN_ALERT("[src] whirrs pointlessly.")) //you messed up
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
		if (!src.shaft)
			src.turbine = null
		playsound(src, 'sound/machines/button.ogg', 50, 1)

	Cross(atom/movable/mover)
		if (istype(mover, /obj/machinery/turbine_shaft) && (mover.dir == NORTH || mover.dir == SOUTH))
			return TRUE
		. = ..()

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			if (src.shaft)
				return src.shaft.Attackby(W, user)
			else
				var/obj/machinery/turbine_shaft/shaft = locate() in get_turf(src)
				shaft?.Attackby(W, user)
		else
			. = ..()

	// 1/2 * 1000 * pi * ((0.5) ** 2) * (v ** 3) = [roughly] total energy applied to the turbine per second
	// E = I(ω ** 2)
	// I = (1/2)m(r ** 2) [modelling the turbine as a disc for intertial purposes]
	//what the fuck is the mass?
	//are any of these equations even sane in context??

	//a bit less physically simulated than the reactor turbine, both because Amy is smarter than me and because we're not really fully simulating the currents
	//see above for my sanity loss trying to figure out the fluid energy transfer maths
	process(mult)
		if (!src.turbine)
			src.generation = 0
			return
		var/last_rpm = src.rpm
		var/flow_rate = 0
		var/obj/effects/current/current = locate() in get_turf(src.turbine)
		if (current)
			flow_rate = current.controller.get_flow_rate()
			//this part is total hand-waving, just do some basic maths to make the RPM slowly increase and decrease with the flow rate
			src.rpm += (flow_rate - src.rpm)/4
		else
			src.rpm = max(src.rpm - 2 - src.rpm/4, 0) //spin down rapidly if there's no current
		if (last_rpm != src.rpm) //just stop it updating when still
			src.end_shaft(src.shaft.dir).update(src)
			src.UpdateIcon()
		//this part is physics though!
		src.generation = src.stator_load * src.rpm/60
		src.add_avail(src.generation)

	update_icon(...)
		var/image/indicator_overlay = image(src.icon, "indicator_[round(src.rpm/10, 1)]")
		indicator_overlay.plane = PLANE_ABOVE_LIGHTING
		src.UpdateOverlays(indicator_overlay, "indicator")

#undef TURBINE_MOVE_TIME
