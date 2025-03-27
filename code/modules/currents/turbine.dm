#define TURBINE_MOVE_TIME (2 SECONDS)


/datum/shaft_network
	var/rpm = 0
	var/list/obj/machinery/turbine_shaft/shafts = list()

	New()
		..()
		START_TRACKING

	disposing()
		shafts = null
		STOP_TRACKING
		..()

	///Split the network in two around the specified shaft
	proc/split(obj/machinery/turbine_shaft/split_on)
		src.split_internal(split_on)
		if (length(split_on.network.shafts) > 1)
			var/next_shaft = split_on.network.shafts[split_on.network.shafts.Find(split_on) + 1]
			split_on.network.split_internal(next_shaft)

	proc/split_internal(obj/machinery/turbine_shaft/split_on)
		var/index = src.shafts.Find(split_on)
		if (index == 0)
			CRASH("Attempting to split on shaft not in network!!")
		var/datum/shaft_network/new_network = new
		new_network.shafts = src.shafts.Copy(index)
		src.shafts.Cut(index)
		for (var/obj/machinery/turbine_shaft/shaft as anything in new_network.shafts)
			shaft.network = new_network
		if (length(new_network.shafts) == 1)
			new_network.shafts[1].anchored = FALSE
		if (length(src.shafts) == 0)
			qdel(src)

	///Join two networks together
	proc/join(obj/machinery/turbine_shaft/new_shaft, obj/machinery/turbine_shaft/adjacent)
		//put them in the right place in the network
		if (adjacent == src.shafts[1])
			src.shafts = new_shaft.network.shafts + src.shafts
		else if (adjacent == src.shafts[length(src.shafts)])
			src.shafts = src.shafts + new_shaft.network.shafts
		else
			CRASH("Attempting to add shaft to non-end shaft, what??")
		//claim the other shafts
		for (var/obj/machinery/turbine_shaft/other_network_shaft in new_shaft.network.shafts)
			other_network_shaft.network.remove_shaft(other_network_shaft)
			other_network_shaft.network = src
			other_network_shaft.update(src.rpm)
			other_network_shaft.anchored = TRUE
		adjacent.anchored = TRUE

	proc/remove_shaft(obj/machinery/turbine_shaft/shaft)
		src.shafts -= shaft
		if (length(src.shafts) == 0)
			qdel(src)

	proc/try_move(dir)
		var/turf/test_turf = null
		if (dir == src.shafts[1].dir)
			test_turf = get_step(src.shafts[length(src.shafts)], dir)
		else
			test_turf = get_step(src.shafts[1], dir)
		if (test_turf && !test_turf.density) // TODO: better check? Make sure turbines can't pass through things
			for (var/obj/machinery/turbine_shaft/shaft as anything in src.shafts)
				shaft.set_loc(get_step(shaft, dir))
			return TRUE
		return FALSE

	proc/process()
		if (!length(src.shafts))
			qdel(src)
			return
		var/max_flow_rate = 0
		for (var/obj/machinery/turbine_shaft/turbine/turbine in src.shafts)
			//maaaybe could do something smarter than this in future but for now this does at least provide a slight advantage to multiple turbines
			max_flow_rate = max(max_flow_rate, turbine.get_flow_rate())
		src.update_rpm(max_flow_rate)

	proc/update_rpm(max_flow_rate)
		if (max_flow_rate)
			//this part is total hand-waving, just do some basic maths to make the RPM slowly increase and decrease with the flow rate
			src.rpm += (max_flow_rate - src.rpm)/4
		else
			src.rpm = max(src.rpm - 2 - src.rpm/4, 0) //spin down rapidly if there's no current
		for (var/obj/machinery/turbine_shaft/shaft as anything in src.shafts)
			shaft.update(src.rpm)


/obj/machinery/turbine_shaft
	name = "turbine shaft"
	desc = "A heavy duty metal shaft."
	icon = 'icons/obj/machines/current_turbine.dmi' //TODO: east west sprites
	icon_state = "shaft_0"
	density = FALSE
	layer = FLOOR_EQUIP_LAYER1
	glide_size = 32 / TURBINE_MOVE_TIME
	dir = NORTH
	processing_tier = PROCESSING_QUARTER

	var/base_icon_state = "shaft"
	var/speed_state = 0
	var/datum/shaft_network/network = new

	New()
		. = ..()
		src.network.shafts = list(src) //me, myself and I

	///Lock them to NORTH/WEST dirs just to make things easier
	set_dir(new_dir)
		if (new_dir == EAST)
			new_dir = WEST
		else if (new_dir == SOUTH)
			new_dir = NORTH
		. = ..(new_dir)

	attackby(obj/item/I, mob/user)
		if (iswrenchingtool(I))
			if (length(src.network.shafts) > 1)
				src.visible_message("[user] unsecures [src].")
				src.network.split(src)
				src.anchored = FALSE
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			else
				src.attach()
				if (length(src.network.shafts) > 1)
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
		for (var/obj/machinery/turbine_shaft/other_shaft in get_step(src, src.dir))
			if (other_shaft.dir == src.dir)
				other_shaft.network.join(src, other_shaft)
				break
		for (var/obj/machinery/turbine_shaft/other_shaft in get_step(src, turn(src.dir, 180)))
			if (other_shaft.dir == src.dir)
				src.network.join(other_shaft, src)
				break
		if (length(src.network.shafts) > 1)
			src.anchored = ANCHORED

	proc/update(rpm)
		switch(rpm)
			if (-INFINITY to 0)
				src.speed_state = 0
			if (1 to 33)
				src.speed_state = 3
			if (34 to 66)
				src.speed_state = 2
			if (67 to INFINITY)
				src.speed_state = 1
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
		src.SubscribeToProcess()

	proc/get_flow_rate()
		var/obj/effects/current/current = locate() in get_turf(src)
		return current?.controller.get_flow_rate() || 0

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


/obj/machinery/power/current_turbine_base
	name = "turbine base"
	icon = 'icons/obj/machines/current_turbine.dmi'
	icon_state = "turbine_base"
	anchored = ANCHORED
	density = TRUE
	flags = FLUID_DENSE | TGUI_INTERACTIVE
	processing_tier = PROCESSING_HALF
	///The current shaft, can be null if some idiot overextends the shaft all the way out
	var/obj/machinery/turbine_shaft/shaft = null
	///How many extra lengths of shaft stick out the back
	var/initial_length = 5

	var/reversed = FALSE

	var/generation = 0

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
			"rpm" = src.get_rpm(),
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
		new /obj/machinery/turbine_shaft/turbine(get_step(T, src.dir))
		src.shaft = new(T)
		src.shaft.attach()
		for (var/i in 1 to initial_length)
			T = get_step(T, turn(src.dir, 180)) //step backwards
			if (!T || T.density)
				break
			var/obj/machinery/turbine_shaft/shaft = new(T)
			shaft.attach()

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
		if (!src.shaft.network.try_move(dir))
			src.visible_message(SPAN_ALERT("[src] makes a protesting grinding noise."))
			animate_storage_thump(src)
			return
		src.shaft = locate() in get_turf(src)
		playsound(src, 'sound/machines/button.ogg', 50, 1)

	proc/get_rpm()
		return src.shaft?.network.rpm || 0

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
		if (!src.shaft)
			src.shaft = locate() in get_turf(src)
		if (!src.shaft)
			if (src.generation != 0)
				src.UpdateIcon()
			src.generation = 0
			return
		//this part is physics though!
		src.generation = src.stator_load * src.shaft.network.rpm/60
		src.add_avail(src.generation)
		src.UpdateIcon()

	update_icon(...)
		var/image/indicator_overlay = image(src.icon, "indicator_[round(src.get_rpm()/10, 1)]")
		indicator_overlay.plane = PLANE_ABOVE_LIGHTING
		src.UpdateOverlays(indicator_overlay, "indicator")

#undef TURBINE_MOVE_TIME
