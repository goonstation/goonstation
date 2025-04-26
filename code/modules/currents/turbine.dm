#define TURBINE_MOVE_TIME (2 SECONDS)


/datum/shaft_network
	var/rpm = 0
	var/list/obj/turbine_shaft/shafts = list()

	New()
		..()
		START_TRACKING

	disposing()
		shafts = null
		STOP_TRACKING
		..()

	///Split the network in two around the specified shaft, leaving up to three separate networks
	proc/split(obj/turbine_shaft/split_on)
		src.split_internal(split_on)
		if (length(split_on.network.shafts) > 1) //still connected? split the other way too
			var/next_shaft = split_on.network.shafts[split_on.network.shafts.Find(split_on) + 1]
			split_on.network.split_internal(next_shaft)

	proc/split_internal(obj/turbine_shaft/split_on)
		var/index = src.shafts.Find(split_on)
		if (index == 0)
			CRASH("Attempting to split on shaft not in network!!")
		var/datum/shaft_network/new_network = new
		new_network.shafts = src.shafts.Copy(index)
		src.shafts.Cut(index)
		for (var/obj/turbine_shaft/shaft as anything in new_network.shafts)
			shaft.network = new_network
		if (length(new_network.shafts) == 1)
			new_network.shafts[1].anchored = FALSE
		if (length(src.shafts) == 0)
			qdel(src)

	///Join two networks together
	proc/join(obj/turbine_shaft/new_shaft, obj/turbine_shaft/adjacent)
		//put them in the right place in the network
		if (adjacent == src.shafts[1])
			src.shafts = new_shaft.network.shafts + src.shafts
		else if (adjacent == src.shafts[length(src.shafts)])
			src.shafts = src.shafts + new_shaft.network.shafts
		else
			CRASH("Attempting to add shaft to non-end shaft, what??")
		//claim the other shafts
		for (var/obj/turbine_shaft/other_network_shaft in new_shaft.network.shafts)
			other_network_shaft.network.remove_shaft(other_network_shaft)
			other_network_shaft.network = src
			other_network_shaft.update(src.rpm)
			other_network_shaft.anchored = TRUE
		adjacent.anchored = TRUE

	proc/remove_shaft(obj/turbine_shaft/shaft)
		src.shafts -= shaft
		if (length(src.shafts) == 0)
			qdel(src)

	///Try to move the whole shaft in a direction, returns TRUE on success and FALSE on failure
	proc/try_move(dir)
		for(var/obj/turbine_shaft/shaft as anything in src.shafts)
			if (!shaft.can_move(get_step(shaft, dir)))
				return FALSE
		for (var/obj/turbine_shaft/shaft as anything in src.shafts)
			shaft.set_loc(get_step(shaft, dir))
		return TRUE

	proc/process()
		if (!length(src.shafts))
			qdel(src)
			return
		var/max_flow_rate = 0
		for (var/obj/turbine_shaft/turbine/turbine in src.shafts)
			//maaaybe could do something smarter than this in future but for now this does at least provide a slight advantage to multiple turbines
			max_flow_rate = max(max_flow_rate, turbine.get_flow_rate())
		src.update_rpm(max_flow_rate)

	proc/update_rpm(max_flow_rate)
		if (max_flow_rate)
			//this part is total hand-waving, just do some basic maths to make the RPM slowly increase and decrease with the flow rate
			src.rpm += (max_flow_rate - src.rpm)/4
		else
			src.rpm = max(src.rpm - 2 - src.rpm/4, 0) //spin down rapidly if there's no current
		for (var/obj/turbine_shaft/shaft as anything in src.shafts)
			shaft.update(src.rpm)


/obj/turbine_shaft
	name = "turbine shaft"
	desc = "A heavy duty metal shaft."
	icon = 'icons/obj/machines/current_turbine.dmi'
	icon_state = "shaft_0"
	density = FALSE
	layer = FLOOR_EQUIP_LAYER1
	glide_size = 32 / TURBINE_MOVE_TIME
	dir = NORTH

	var/base_icon_state = "shaft"
	var/speed_state = 0
	var/datum/shaft_network/network = new

	New()
		. = ..()
		src.network.shafts = list(src) //me, myself and I

	get_help_message(dist, mob/user)
		if (length(src.network.shafts) > 1)
			. = "You can use a <b>wrench</b> to unsecure it from other shafts."
		else
			. = "You can use a <b>wrench</b> to secure it to other shafts,\nor a <b>crowbar</b> to rotate it."

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
		for (var/obj/turbine_shaft/other_shaft in get_step(src, src.dir))
			if (other_shaft.dir == src.dir)
				other_shaft.network.join(src, other_shaft)
				break
		for (var/obj/turbine_shaft/other_shaft in get_step(src, turn(src.dir, 180)))
			if (other_shaft.dir == src.dir)
				src.network.join(other_shaft, src)
				break
		if (length(src.network.shafts) > 1)
			src.anchored = ANCHORED

	///Distinct from Cross because we want to not be blocked by our own parts while moving but still have them collide with each other
	proc/can_move(turf/T)
		if (!T || T.density)
			return FALSE
		return TRUE

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

/obj/turbine_shaft/turbine
	name = "NT40 tidal current turbine"
	desc = "A heavy turbine designed to harness ocean currents. The blades look worryingly sharp."
	icon_state = "turbine_0"
	base_icon_state = "turbine"
	layer = OBJ_LAYER
	density = TRUE

	New()
		. = ..()
		src.UpdateOverlays(image(src.icon, "turbine_anchor", layer = src.layer - 0.1), "anchor")
		src.UpdateIcon(0)

	proc/get_flow_rate()
		var/obj/effects/current/current = locate() in get_turf(src)
		return current?.controller.get_flow_rate() || 0

	can_move(turf/T)
		if (!..())
			return FALSE
		for (var/atom/movable/AM in T.contents)
			if (AM.density && !istype(AM, src.type))
				return FALSE
		return TRUE

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
		src.UpdateOverlays(image(src.icon, "[/obj/turbine_shaft::base_icon_state]_[src.speed_state]", layer = src.layer - 0.1), "internal_shaft")


/obj/machinery/power/current_turbine_base
	name = "turbine base"
	icon = 'icons/obj/machines/current_turbine.dmi'
	icon_state = "turbine_base"
	anchored = ANCHORED
	density = TRUE
	flags = FLUID_DENSE | TGUI_INTERACTIVE
	processing_tier = PROCESSING_HALF
	directwired = FALSE
	pass_unstable = TRUE
	///The current shaft, can be null if some idiot overextends the shaft all the way out
	var/obj/turbine_shaft/shaft = null

	var/reversed = FALSE

	var/generation = 0

	//power = stator load * rpm/60
	//sooo if we want the power to cap out at ~40kw and 100rpm (big slow water turbine)
	//stator load = (60 * 40 * 1000)/100 = 24kj/rev
	var/stator_load = 24 KILO //per revolution

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
		if (!src.powernet)
			src.recheck_powernet()
		//this part is physics though!
		src.generation = src.stator_load * src.shaft.network.rpm/60
		src.add_avail(src.generation / 4) //divide four because we're processing faster than the powernet expects
		src.UpdateIcon()

	update_icon(...)
		var/image/indicator_overlay = image(src.icon, "indicator_[round(src.get_rpm()/10, 1)]")
		indicator_overlay.plane = PLANE_ABOVE_LIGHTING
		src.UpdateOverlays(indicator_overlay, "indicator")

/obj/mapping_helper/current_turbine
	name = "current turbine spawner"
	icon = 'icons/obj/machines/current_turbine.dmi'
	icon_state = "turbine_base"
	///How many extra lengths of shaft stick out the back
	var/tail_length = 4

	setup()
		var/turf/T = get_turf(src)
		var/obj/machinery/power/current_turbine_base/base = new(T)
		base.dir = src.dir
		new /obj/turbine_shaft/turbine(get_steps(T, src.dir, 2))
		var/obj/turbine_shaft/connector = new(get_step(T, src.dir))
		connector.attach()
		for (var/i in 0 to src.tail_length)
			T = get_steps(src, turn(src.dir, 180), i) //step backwards
			if (!T || T.density)
				break
			var/obj/turbine_shaft/shaft = new(T)
			shaft.attach()

#undef TURBINE_MOVE_TIME
