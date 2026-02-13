ABSTRACT_TYPE(/obj/machinery/fluid_machinery)
/obj/machinery/fluid_machinery
	icon = 'icons/obj/fluidpipes/fluid_machines.dmi'
	desc = "Does cool things to fluids."
	processing_tier = PROCESSING_QUARTER
	anchored = ANCHORED
	plane = PLANE_FLOOR
	/// What directions are valid for connections.
	var/initialize_directions
	var/exclusionary = FALSE

/// Accepts an input network and an ideal amount of fluid to pull from network.
/// Returns a reagents datum containing a scaled amount of fluid linear to fullness of network or null if no fluid in network. Quantized to QUANTIZATION_UNITS units.
/// Can return null on an empty network.
/obj/machinery/fluid_machinery/proc/pull_from_network(datum/flow_network/network, maximum = 100)
	return network.reagents.remove_any_to(max(round(maximum * (network.reagents.total_volume / network.reagents.maximum_volume), QUANTIZATION_UNITS), MINIMUM_REAGENT_MOVED), TRUE)

/// Accepts an input network and the reagents datum to add to the network.
/// Returns TRUE on complete addition to network and deletion of reagents datum. Returns FALSE if reagents remaining and reagents not deleted.
/obj/machinery/fluid_machinery/proc/push_to_network(datum/flow_network/network, datum/reagents/topush)
	if (isnull(topush)) return TRUE
	topush.trans_to(network, topush.total_volume, 1, FALSE)
	if(topush.total_volume)
		return FALSE
	qdel(topush)
	return TRUE

/// Clear ourselves from our network and then relook.
/obj/machinery/fluid_machinery/proc/refresh_network(datum/flow_network/network)
	return

/obj/machinery/fluid_machinery/Move()
	..()
	src.refresh_network()


ABSTRACT_TYPE(/obj/machinery/fluid_machinery/unary)
/obj/machinery/fluid_machinery/unary
	exclusionary = TRUE
	var/datum/flow_network/network
	level = UNDERFLOOR

/obj/machinery/fluid_machinery/unary/New()
	..()
	src.initialize_directions = src.dir
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/fluid_machinery/unary/disposing()
	src.network?.machines -= src
	src.network = null
	..()

/obj/machinery/fluid_machinery/unary/initialize()
	for(var/obj/fluid_pipe/target in get_step(src, src.dir))
		if(target.initialize_directions & get_dir(target,src))
			if(target.network)
				src.network = target.network
				src.network.machines += src
			break

/obj/machinery/fluid_machinery/unary/refresh_network(datum/flow_network/network)
	src.network?.machines -= src
	src.network = null
	src.initialize()

/obj/machinery/fluid_machinery/unary/nullifier
	name = "nullifier"
	icon_state = "nullifier"
	desc = "You're not really sure where the fluids go, but it probably doesn't matter."
	HELP_MESSAGE_OVERRIDE("Removes up to 50 units per cycle.")

	var/pullrate = 50

/obj/machinery/fluid_machinery/unary/nullifier/process()
	if(!src.network) return
	var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
	qdel(fluid)

/obj/machinery/fluid_machinery/unary/input
	name = "port"
	desc = "A big ol' hole for pouring in fluids."
	icon_state = "port"
	flags = NOSPLASH | OPENCONTAINER | ACCEPTS_MOUSEDROP_REAGENTS
	HELP_MESSAGE_OVERRIDE("You can connect glass plumbing to this machine. Can pull 100 units from a screwed barrel per cycle.")
	var/obj/reagent_dispensers/chemicalbarrel/connectedcontainer = null

/obj/machinery/fluid_machinery/unary/input/initialize()
	..()
	src.reagents = src.network?.reagents || new(0)

/obj/machinery/fluid_machinery/unary/input/process()
	src.connectedcontainer?.reagents.trans_to(src, 100)

/obj/machinery/fluid_machinery/unary/input/get_chemical_effect_position()
	return 0

ABSTRACT_TYPE(/obj/machinery/fluid_machinery/unary/drain)
/obj/machinery/fluid_machinery/unary/drain
	var/drain_min = 0
	var/drain_max = 0

/obj/machinery/fluid_machinery/unary/drain/proc/drain()
	if(!src.network)
		return
	var/turf/simulated/T = get_turf(src)
	if(T.active_liquid?.group?.amt_per_tile)
		//pick a random unit between drain_min and drain_max to drain, if there is less fluid then what we chose, drain it all.
		var/amount = min(rand(src.drain_min, src.drain_max), src.network.reagents.maximum_volume - src.network.reagents.total_volume)/T.active_liquid.group.amt_per_tile
		if(amount > 0) // rounding errors can make it go very very slightly below zero
			T.active_liquid.group.drain(T.active_liquid, amount, src.network)
			playsound(T, 'sound/misc/drain_glug.ogg', 50, TRUE)

/obj/machinery/fluid_machinery/unary/drain/inlet_pump
	name = "inlet drain"
	icon_state = "inlet0"
	desc = "A powered and togglable drainage pipe."
	HELP_MESSAGE_OVERRIDE("Pulls anywhere from 10 to 15 units from a turf.")

	var/on = FALSE
	drain_min = 10
	drain_max = 15

/obj/machinery/fluid_machinery/unary/drain/inlet_pump/proc/activate()


/obj/machinery/fluid_machinery/unary/drain/inlet_pump/attack_hand(mob/user)
	interact_particle(user, src)
	src.on = !src.on
	src.UpdateIcon(TRUE)
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))
	logTheThing(LOG_STATION, user, "turns a fluid drain [src.on ? "on" : "off"] at [log_loc(src)].")

/obj/machinery/fluid_machinery/unary/drain/inlet_pump/process()
	var/area/A = get_area(src)
	if (!isarea(A))
		return
	if(!A.powered(ENVIRON))
		if(src.on)
			src.on = FALSE
			src.UpdateIcon(TRUE)
			src.visible_message(SPAN_ALERT("[src] shuts down due to lack of APC power."))
			logTheThing(LOG_STATION, null, "A fluid drain shuts off from a lack of power at [log_loc(src)].")
		return
	if(!src.on)
		return
	src.drain()

/obj/machinery/fluid_machinery/unary/drain/inlet_pump/hide(intact)
	src.icon_state = "inlet[src.on][CHECKHIDEPIPE(src) ? "h" : null]"

/obj/machinery/fluid_machinery/unary/drain/inlet_pump/update_icon(animate)
	var/turf/T = get_turf(src)
	var/intact = T.intact
	if(animate)
		FLICK("inlet[!src.on][src.on][CHECKHIDEPIPE(src) ? "h" : null]", src)
	src.icon_state = "inlet[src.on][CHECKHIDEPIPE(src) ? "h" : null]"

/obj/machinery/fluid_machinery/unary/drain/inlet_pump/overfloor
	level = OVERFLOOR

/obj/machinery/fluid_machinery/unary/hand_pump
	name = "hand pump"
	icon_state = "output0"
	desc = "A hand-operated pump."
	flags = NOSPLASH
	HELP_MESSAGE_OVERRIDE("Click with an open container to pour into it. Outputs up to 100 units. Use a <b>wrench</b> to change max output.")

	var/maxpullrate = 100
	var/pullrate = 100

/obj/machinery/fluid_machinery/unary/hand_pump/attack_hand(mob/user)
	interact_particle(user, src)
	FLICK("output1", src)
	if(!src.network)
		return
	var/turf/simulated/T = get_turf(src)
	var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
	if (isnull(fluid)) return
	logTheThing(LOG_STATION, user, "pumped to the floor [log_reagents(fluid)] with a hand pump at [log_loc(src)].")
	fluid?.trans_to(T, fluid.total_volume)
	qdel(fluid)

/obj/machinery/fluid_machinery/unary/hand_pump/attackby(obj/item/I, mob/user)
	if (iswrenchingtool(I))
		var/inp = tgui_input_number(user, "Please enter dispense amount (Will round to [QUANTIZATION_UNITS]):", "Dispense Amount", src.pullrate, src.maxpullrate, MINIMUM_REAGENT_MOVED)
		if (!inp) return
		src.pullrate = clamp(round(inp, QUANTIZATION_UNITS), MINIMUM_REAGENT_MOVED, src.maxpullrate)
		return

	if(!I.is_open_container(TRUE))
		return

	if (I.reagents.total_volume >= I.reagents.maximum_volume)
		boutput(user, SPAN_ALERT("[I] is full."))
		return

	FLICK("output1", src)
	if(!src.network)
		return

	if (!src.network.reagents.total_volume)
		boutput(user, SPAN_ALERT("You tried to fill [I] from [src], but nothing came out!"))
		return

	var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
	boutput(user, SPAN_NOTICE("You fill [I] with [fluid.trans_to(I, fluid.total_volume)] units of the contents of [src]."))
	logTheThing(LOG_STATION, user, "filled [log_object(I)] [log_reagents(I)] with a hand pump at [log_loc(src)].")
	qdel(fluid)
	playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)


/obj/machinery/fluid_machinery/unary/dripper
	name = "dripper"
	icon_state = "dripper"
	desc = "A modified hand pump, it passively drips fluid onto the floor or, if it has, into containers, but at a low rate."
	flags = NOSPLASH
	HELP_MESSAGE_OVERRIDE("Can connect glass plumbing from this machine. Drips up to 30 units at a time. Use a <b>wrench</b> to change max output.")

	var/maxpullrate = 30
	var/pullrate = 30
	//me when i steal code :3
	var/list/connected_containers //! the containers currently connected to the condenser
	var/max_amount_of_containers = 4

/obj/machinery/fluid_machinery/unary/dripper/proc/try_adding_container(var/obj/container, var/mob/user)
	if (!isturf(container.loc)) //if the condenser or container isn't on the floor you cannot hook it up
		return
	if (BOUNDS_DIST(src, user) > 0)
		boutput(user, SPAN_ALERT("The [src.name] is too for away for you to mess with it!"))
		return
	if (GET_DIST(container, src) > 1)
		usr.show_text("The [src.name] is too far away from the [container.name]!", "red")
		return
	if(length(src.connected_containers) >= src.max_amount_of_containers)
		boutput(user, SPAN_ALERT("The [src.name] can only be connected to [max_amount_of_containers] containers!"))
	else
		boutput(user, "<span class='notice'>You hook the [container.name] up to the [src.name].</span>")
	add_container(container)

/obj/machinery/fluid_machinery/unary/dripper/proc/add_line(var/obj/container)
	var/datum/lineResult/result = drawLineImg(src, container, "condenser", "condenser_end", src.pixel_x + 9, src.pixel_y - 2, container.pixel_x, container.pixel_y + container.get_chemical_effect_position())
	result.lineImage.pixel_x = -src.pixel_x
	result.lineImage.pixel_y = -src.pixel_y
	result.lineImage.layer = src.layer+0.01
	src.AddOverlays(result.lineImage, "tube\ref[container]")

/obj/machinery/fluid_machinery/unary/dripper/proc/add_container(var/obj/container)
	//this is a mess but we need it to disconnect if ANYTHING happens
	if (!(container in src.connected_containers))
		RegisterSignal(container, COMSIG_ATTACKHAND, PROC_REF(remove_container)) //empty hand on either condenser or its connected container should disconnect
		RegisterSignal(container, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(remove_container_xsig))
		RegisterSignal(container, COMSIG_MOVABLE_MOVED, PROC_REF(remove_container))
	add_line(container)
	LAZYLISTADD(src.connected_containers, container)

/obj/machinery/fluid_machinery/unary/dripper/proc/remove_container(var/obj/container)
	while (container in src.connected_containers)
		LAZYLISTREMOVE(src.connected_containers, container)
	src.ClearSpecificOverlays("tube\ref[container]")
	UnregisterSignal(container, COMSIG_ATTACKHAND)
	UnregisterSignal(container, XSIG_OUTERMOST_MOVABLE_CHANGED)
	UnregisterSignal(container, COMSIG_MOVABLE_MOVED)

/obj/machinery/fluid_machinery/unary/dripper/proc/remove_container_xsig(datum/component/complexsignal, old_movable, new_movable)
	src.remove_container(complexsignal.parent)

/obj/machinery/fluid_machinery/unary/dripper/proc/try_adding_reagents_to_container(reagent, amount, sdata, temp_new, donotreact, donotupdate, priority) //called when a reaction occurs inside the condenser flagged with "chemical_reaction = TRUE"
	src.reagents.add_reagent(reagent, amount, sdata, temp_new, donotreact, donotupdate)

/obj/machinery/fluid_machinery/unary/dripper/proc/remove_all_containers()
	for(var/obj/container in src.connected_containers)
		remove_container(container)

/obj/machinery/fluid_machinery/unary/dripper/mouse_drop(atom/over_object, src_location, over_location)
	if(over_object == src)
		return
	if (istype(over_object, /obj/item/reagent_containers) && (over_object.is_open_container()))
		try_adding_container(over_object, usr)
	if (istype(over_object, /obj/reagent_dispensers/chemicalbarrel)) //barrels don't need to be open for condensers because it would be annoying I think
		try_adding_container(over_object, usr)
	if (istype(over_object, /obj/machinery/fluid_machinery/unary/input)) //hehe
		try_adding_container(over_object, usr)

/obj/machinery/fluid_machinery/unary/dripper/attack_hand(var/mob/user)
	if(length(src.connected_containers))
		src.remove_all_containers()
		boutput(user, SPAN_ALERT("You remove all connections to the [src.name]."))
	..()

/obj/machinery/fluid_machinery/unary/dripper/get_desc()
	. += "<br>[SPAN_NOTICE("Current Max Drip Amount: [src.pullrate].")]"

/obj/machinery/fluid_machinery/unary/dripper/attackby(obj/item/I, mob/user)
	if (iswrenchingtool(I))
		var/inp = tgui_input_number(user, "Please enter drip amount (Will round to [QUANTIZATION_UNITS]):", "Dispense Amount", src.pullrate, src.maxpullrate, MINIMUM_REAGENT_MOVED)
		if (!inp) return
		src.pullrate = clamp(round(inp, QUANTIZATION_UNITS), MINIMUM_REAGENT_MOVED, src.maxpullrate)
		logTheThing(LOG_STATION, user, "set a dripper's pullrate to [src.pullrate] units at [log_loc(src)].")

/obj/machinery/fluid_machinery/unary/dripper/process()
	if(!src.network)
		return
	var/turf/simulated/T = get_turf(src)
	var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
	if (isnull(fluid)) return
	if (isnull(src.connected_containers))
		fluid.trans_to(T, fluid.total_volume)
		qdel(fluid)
		return

	var/list/non_full_containers = list()
	for(var/obj/container as anything in connected_containers)
		if(container.reagents.maximum_volume > container.reagents.total_volume) //don't bother with this if it's already full, move onto other containers
			non_full_containers.Add(container)
	if(!length(non_full_containers))	//all full? backflow!!
		src.push_to_network(src.network, fluid)
		return
	var/divided_amount = (fluid.total_volume / length(non_full_containers)) //cut the reagents needed into chunks
	for(var/obj/container as anything in non_full_containers)
		var/remaining_container_space = container.reagents.maximum_volume - container.reagents.total_volume
		if(remaining_container_space < divided_amount) 	//if there's more reagent to add than the beaker can hold...
			fluid.trans_to(container, remaining_container_space) //...add what we can to the beaker...
			if ((length(non_full_containers) - 1))
				divided_amount = (divided_amount - remaining_container_space) / (length(non_full_containers) - 1) //...then run the loop again with the remaining reagent, evenly distributing to remaining containers
			else
				src.push_to_network(src.network, fluid) // or if we ran out of containers, shove it back into the network
		else
			fluid.trans_to(container, divided_amount)
	qdel(fluid)


/obj/machinery/fluid_machinery/unary/dispenser
	name = "dispenser"
	icon_state = "dispenser"
	desc = "Fills itself with fluid and dispenses patches, pills, and vials when reaching the set amount or when prompted to."
	HELP_MESSAGE_OVERRIDE("FYou can use a <b>multitool</b> to modify its settings.")
	var/automatic = TRUE
	var/max = 50
	var/min = 1
	var/amount = 50
	var/itemtodispense = "pills"
	var/static/list/itemlist = list("patches", "pills", "vials")

/obj/machinery/fluid_machinery/unary/dispenser/proc/dispense()
	if (src.reagents.total_volume < src.amount)
		return

	switch(src.itemtodispense)
		if("pills")
			var/obj/item/reagent_containers/pill/P = new(get_turf(src))
			src.reagents.trans_to(P, src.amount)
			var/datum/color/average = P.reagents.get_average_color()
			P.color_overlay = image('icons/obj/items/pills.dmi', "pill0")
			P.color_overlay.color = average.to_rgb()
			P.color_overlay.alpha = P.color_overlay_alpha
			P.overlays += P.color_overlay
			src.visible_message("[src] ejects a pill.")
			logTheThing(LOG_STATION, null, "A fluid dispenser dispensed a [log_object(P)] [log_reagents(P)] at [log_loc(src)].")
		if("vials")
			var/obj/item/reagent_containers/glass/vial/plastic/V = new(get_turf(src))
			src.reagents.trans_to(V, src.amount)
			src.visible_message("[src] ejects a vial.")
			logTheThing(LOG_STATION, null, "A fluid dispenser dispensed a [log_object(V)] [log_reagents(V)] at [log_loc(src)].")
		if("patches")
			var/obj/item/reagent_containers/patch/P = new(get_turf(src))
			src.reagents.trans_to(P, src.amount)
			src.visible_message("[src] ejects a patch.")
			logTheThing(LOG_STATION, null, "A fluid dispenser dispensed a [log_object(P)] [log_reagents(P)] at [log_loc(src)].")

/obj/machinery/fluid_machinery/unary/dispenser/proc/set_amount(var/datum/mechanicsMessage/input)
	var/newamount = text2num_safe(input.signal)
	if (!newamount)
		return
	src.amount = round(clamp(newamount, src.min, src.max), QUANTIZATION_UNITS)
	logTheThing(LOG_STATION, null, "A fluid dispenser was set to dispense [src.amount] units through MechComp at [log_loc(src)].")

/obj/machinery/fluid_machinery/unary/dispenser/proc/set_amount_manual(obj/item/W, mob/user)
	var/inp = tgui_input_number(user, "Please enter dispense amount (Will round to [QUANTIZATION_UNITS]):", "Dispense Amount", src.amount, src.max, src.min)
	if (!inp) return
	src.amount = round(inp, QUANTIZATION_UNITS)
	logTheThing(LOG_STATION, user, "set a fluid dispenser to dispense [src.amount] units at [log_loc(src)].")

/obj/machinery/fluid_machinery/unary/dispenser/proc/set_type(obj/item/W, mob/user)
	var/inp = tgui_input_list(user, "Select a type to output.", "Dispense Type", src.itemlist)
	src.itemtodispense = (inp in src.itemlist) ? inp : src.itemtodispense
	logTheThing(LOG_STATION, user, "set a fluid dispenser to dispense [src.itemtodispense] at [log_loc(src)].")

/obj/machinery/fluid_machinery/unary/dispenser/proc/set_automatic(obj/item/W, mob/user)
	src.automatic = !src.automatic
	boutput(user, SPAN_NOTICE("Automatic mode is now set to [src.automatic ? "true" : "false"]."))
	logTheThing(LOG_STATION, user, "set a fluid dispenser's automatic mode [src.automatic ? "on" : "false"] at [log_loc(src)].")

/obj/machinery/fluid_machinery/unary/dispenser/New()
	..()
	src.create_reagents(src.max)
	AddComponent(/datum/component/mechanics_holder)
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"dispense now", PROC_REF(dispense))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Dispense Amount", PROC_REF(set_amount_manual))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Dispense Type", PROC_REF(set_type))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Automatic dispensing", PROC_REF(set_automatic))

/obj/machinery/fluid_machinery/unary/dispenser/get_desc()
	. += "<br>[SPAN_NOTICE("Automatic: [src.automatic ? "true" : "false"]. Dispense Amount: [src.amount]. Dispensing: [src.itemtodispense]")]"

/obj/machinery/fluid_machinery/unary/dispenser/process()
	if (!src.network) return
	var/datum/reagents/fluid = src.pull_from_network(src.network, src.max)
	fluid?.trans_to(src, src.max)
	src.push_to_network(src.network, fluid)
	src.reagents.handle_reactions()
	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "[src.reagents.total_volume]")
	if (!src.automatic)
		return
	src.dispense()

/obj/machinery/fluid_machinery/unary/node
	name = "node"
	desc = "Used for connecting non-fluid machinery to fluid pipes, AKA, YOU SHOULDNT SEE THIS."
	invisibility = INVIS_ALWAYS

/obj/machinery/fluid_machinery/unary/node/ex_act()
	return

/obj/machinery/fluid_machinery/unary/node/meteorhit()
	return

/obj/machinery/fluid_machinery/unary/node/updateHealth()
	return


ABSTRACT_TYPE(/obj/machinery/fluid_machinery/binary)
/obj/machinery/fluid_machinery/binary
	var/datum/flow_network/network1
	var/datum/flow_network/network2

/obj/machinery/fluid_machinery/binary/New()
	..()
	src.initialize_directions = src.dir | turn(src.dir, 180)

/obj/machinery/fluid_machinery/binary/disposing()
	src.network1?.machines -= src
	src.network2?.machines -= src
	..()

/obj/machinery/fluid_machinery/binary/initialize()
	for(var/obj/fluid_pipe/target in get_step(src, turn(src.dir, 180)))
		if(target.initialize_directions & get_dir(target,src))
			if(target.network)
				src.network1 = target.network
				src.network1.machines += src
			break

	for(var/obj/fluid_pipe/target in get_step(src, src.dir))
		if(target.initialize_directions & get_dir(target,src))
			if(target.network)
				src.network2 = target.network
				src.network2.machines += src
			break

/obj/machinery/fluid_machinery/binary/refresh_network(datum/flow_network/network)
	src.network1?.machines -= src
	src.network2?.machines -= src
	src.network1 = null
	src.network2 = null
	src.initialize()


/obj/machinery/fluid_machinery/binary/pump
	name = "fluid pump"
	desc = "Pulls from one side, pushes to the other."
	HELP_MESSAGE_OVERRIDE("You can use a <b>multitool</b> to connect MechComp. This pump moves up to 200 units per pump.")
	icon_state = "pump0"
	var/on = FALSE
	var/pumprate = 200

/obj/machinery/fluid_machinery/binary/pump/New()
	..()
	AddComponent(/datum/component/mechanics_holder)
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", PROC_REF(activate))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate", PROC_REF(deactivate))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", PROC_REF(toggle))

/obj/machinery/fluid_machinery/binary/pump/proc/activate()
	if(src.on == FALSE)
		src.on = TRUE
		src.UpdateIcon(TRUE)
		logTheThing(LOG_STATION, null, "A fluid pump was toggled on through MechComp at [log_loc(src)].")

/obj/machinery/fluid_machinery/binary/pump/proc/deactivate()
	if(src.on == TRUE)
		src.on = FALSE
		src.UpdateIcon(TRUE)
		logTheThing(LOG_STATION, null, "A fluid pump was toggled off through MechComp at [log_loc(src)].")

/obj/machinery/fluid_machinery/binary/pump/proc/toggle()
	src.on = !src.on
	src.UpdateIcon(TRUE)
	logTheThing(LOG_STATION, null, "A fluid pump was toggled [src.on ? "on" : "off"] through MechComp at [log_loc(src)].")

/obj/machinery/fluid_machinery/binary/pump/attack_hand(mob/user)
	interact_particle(user, src)
	src.on = !src.on
	src.UpdateIcon(TRUE)
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))
	logTheThing(LOG_STATION, user, "turned a fluid pump [src.on ? "on" : "off"] at [log_loc(src)].")

/obj/machinery/fluid_machinery/binary/pump/update_icon(animate)
	if(animate)
		FLICK("pump[!src.on][src.on]", src)
	src.icon_state = "pump[src.on]"

/obj/machinery/fluid_machinery/binary/pump/process()
	if(!src.on)
		return

	if(!(src.network1 && src.network2))
		src.on = FALSE
		src.UpdateIcon(TRUE)
		return

	var/datum/reagents/removed_fluid = src.pull_from_network(src.network1, src.pumprate)
	if(!src.push_to_network(src.network2, removed_fluid))
		removed_fluid.trans_to(src.network1, removed_fluid.total_volume)
	FLICK("actuallypump", src)

/obj/machinery/fluid_machinery/binary/valve
	name = "fluid valve"
	desc = "Separates two fluid pipe networks."
	icon_state = "valve0"
	var/on = FALSE

/obj/machinery/fluid_machinery/binary/valve/attack_hand(mob/user)
	interact_particle(user, src)
	if(ON_COOLDOWN(src, "fluidvalve", 1 SECOND))
		return
	src.on = !src.on
	src.UpdateIcon(TRUE)
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))
	logTheThing(LOG_STATION, user, "turns a fluid valve [src.on ? "on" : "off"] at [log_loc(src)].")

	if(!(src.network1 && src.network2))
		return
	if(src.on)
		src.network1.merge_network(src.network2)
	else
		src.network1.rebuild_network()

/obj/machinery/fluid_machinery/binary/valve/update_icon(animate)
	if(animate)
		FLICK("valve[!src.on][src.on]", src)
	src.icon_state = "valve[src.on]"

/obj/machinery/fluid_machinery/binary/valve/refresh_network(datum/flow_network/network)
	..()
	if(!src.on)
		return
	if(src.network1 && src.network2)
		src.network1.merge_network(src.network2)

/obj/machinery/fluid_machinery/binary/valve/disposing()
	src.on = FALSE
	src.network1.rebuild_network_force()
	..()

ABSTRACT_TYPE(/obj/machinery/fluid_machinery/trinary)
/obj/machinery/fluid_machinery/trinary
	var/datum/flow_network/network1
	var/datum/flow_network/network2
	var/datum/flow_network/network3

/obj/machinery/fluid_machinery/trinary/New()
	..()
	switch(src.dir)
		if(NORTH)
			src.initialize_directions = NORTH|EAST|SOUTH
		if(EAST)
			src.initialize_directions = EAST|SOUTH|WEST
		if(SOUTH)
			src.initialize_directions = SOUTH|WEST|NORTH
		if(WEST)
			src.initialize_directions = WEST|NORTH|EAST

/obj/machinery/fluid_machinery/trinary/disposing()
	src.network1?.machines -= src
	src.network2?.machines -= src
	src.network3?.machines -= src
	..()

/obj/machinery/fluid_machinery/trinary/initialize()
	for(var/obj/fluid_pipe/target in get_step(src, turn(src.dir, 180)))
		if(target.initialize_directions & get_dir(target,src))
			if(target.network)
				src.network1 = target.network
				src.network1.machines += src
			break

	for(var/obj/fluid_pipe/target in get_step(src, turn(src.dir, -90)))
		if(target.initialize_directions & get_dir(target,src))
			if(target.network)
				src.network2 = target.network
				src.network2.machines += src
			break

	for(var/obj/fluid_pipe/target in get_step(src, src.dir))
		if(target.initialize_directions & get_dir(target,src))
			if(target.network)
				src.network3 = target.network
				src.network3.machines += src
			break

/obj/machinery/fluid_machinery/trinary/refresh_network(datum/flow_network/network)
	src.network1?.machines -= src
	src.network2?.machines -= src
	src.network1 = null
	src.network2 = null
	src.initialize()

/obj/machinery/fluid_machinery/trinary/filter
	name = "reagent filter"
	desc = "Filters out a specific reagent."
	HELP_MESSAGE_OVERRIDE("Can be loaded with a <b>beaker</b>, which must contain at least 1 unit of a reagent. The most plentiful reagent is chosen for filtering.")
	icon_state = "filter0"
	flags = NOSPLASH
	var/pullrate = 200
	var/obj/item/reagent_containers/glass/beaker

/obj/machinery/fluid_machinery/trinary/filter/attackby(obj/item/reagent_containers/glass/B, mob/user)
	..()
	if(!istype(B))
		return

	var/reagent_to_filter = B.reagents.get_master_reagent_id()
	if(!B.reagents.has_reagent(reagent_to_filter, 1))
		boutput(user, "[B] doesn't have enough of any reagent!")
		return

	if(src.beaker)
		user?.put_in_hand_or_drop(src.beaker)
		boutput(user, "You swap the [B] with the [src.beaker] already loaded into the machine.")
		logTheThing(LOG_STATION, user, "removed [log_object(src.beaker)] [log_reagents(src.beaker)] from a fluid filter at [log_loc(src)].")
		src.beaker = null

	user.u_equip(B)
	src.beaker = B
	B.set_loc(src)
	icon_state = "filter1"
	logTheThing(LOG_STATION, user, "added [log_object(src.beaker)] [log_reagents(src.beaker)] to a fluid filter at [log_loc(src)].")

/obj/machinery/fluid_machinery/trinary/filter/attack_hand(mob/user)
	..()
	if(src.beaker)
		logTheThing(LOG_STATION, user, "removed [log_object(src.beaker)] [log_reagents(src.beaker)] from a fluid filter at [log_loc(src)].")
		user.put_in_hand_or_drop(src.beaker)
		src.beaker = null
		icon_state = "filter0"

/obj/machinery/fluid_machinery/trinary/filter/process()
	if(!src.beaker)
		return
	var/reagent_to_filter = src.beaker.reagents.get_master_reagent_id()
	if(!src.beaker.reagents.has_reagent(reagent_to_filter, 1))
		src.beaker.set_loc(get_turf(src))
		src.visible_message(SPAN_ALERT("[src] ejects [src.beaker] due to insufficient reagents!"))
		src.beaker = null
		return
	var/datum/reagents/removed = src.pull_from_network(src.network1, src.pullrate)
	if (isnull(removed))
		FLICK("filtering", src)
		return
	var/datum/reagents/filtered = new(removed.get_reagent_amount(reagent_to_filter))
	filtered.add_reagent(reagent_to_filter, filtered.maximum_volume, donotreact = TRUE)
	removed.remove_reagent(reagent_to_filter, filtered.maximum_volume)
	if(!src.push_to_network(src.network2, filtered))
		src.push_to_network(src.network1, filtered)
	if(!src.push_to_network(src.network3, removed))
		src.push_to_network(src.network1, removed)
	FLICK("filtering", src)

