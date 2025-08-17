ABSTRACT_TYPE(/obj/machinery/fluid_pipe_machinery)
/obj/machinery/fluid_pipe_machinery
	icon = 'icons/obj/fluidpipes/fluid_pipe.dmi'
	desc = "Does cool things to fluids."
	processing_tier = PROCESSING_QUARTER
	anchored = ANCHORED
	plane = PLANE_FLOOR
	/// What directions are valid for connections.
	var/initialize_directions
	var/exclusionary = FALSE

/// Accepts an input network and an ideal amount of fluid to pull from network.
/// Returns a reagents datum containing a scaled amount of fluid linear to fullness of network or null if no fluid in network. Quantized to QUANTIZATION_UNITS units.
/obj/machinery/fluid_pipe_machinery/proc/pull_from_network(datum/flow_network/network, maximum = 100)
	return network.reagents.remove_any_to(max(MINIMUM_REAGENT_MOVED, round(maximum * (network.reagents.total_volume / network.reagents.maximum_volume), QUANTIZATION_UNITS)), TRUE)

/// Accepts an input network and the reagents datum to add to the network.
/// Returns TRUE on complete addition to network and deletion of reagents datum. Returns FALSE if reagents remaining and reagents not deleted.
/obj/machinery/fluid_pipe_machinery/proc/push_to_network(datum/flow_network/network, datum/reagents/topush)
	topush?.trans_to(network, topush.total_volume, 1, FALSE)
	if(topush.total_volume)
		return FALSE
	qdel(topush)
	return TRUE

/// Clear ourselves from our network and then relook.
/obj/machinery/fluid_pipe_machinery/proc/refresh_network(datum/flow_network/network)
	return

/obj/machinery/fluid_pipe_machinery/Move()
	..()
	src.refresh_network()


ABSTRACT_TYPE(/obj/machinery/fluid_pipe_machinery/unary)
/obj/machinery/fluid_pipe_machinery/unary
	exclusionary = TRUE
	var/datum/flow_network/network
	level = UNDERFLOOR

/obj/machinery/fluid_pipe_machinery/unary/New()
	..()
	src.initialize_directions = src.dir
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/fluid_pipe_machinery/unary/disposing()
	src.network?.machines -= src
	src.network = null
	..()

/obj/machinery/fluid_pipe_machinery/unary/initialize()
	for(var/obj/fluid_pipe/target in get_step(src, src.dir))
		if(target.initialize_directions & get_dir(target,src))
			src.network = target.network
			src.network.machines += src
			break

/obj/machinery/fluid_pipe_machinery/unary/refresh_network(datum/flow_network/network)
	src.network?.machines -= src
	src.network = null
	src.initialize()

/obj/machinery/fluid_pipe_machinery/unary/nullifier
	name = "Nullifier"
	icon_state = "nullifier"
	desc = "You're not really sure where the fluids go, but it probably doesn't matter."

	var/pullrate = 50

/obj/machinery/fluid_pipe_machinery/unary/nullifier/process()
	if(!src.network) return
	var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
	src.use_power(100 WATTS * fluid?.total_volume, ENVIRON)
	qdel(fluid)

/obj/machinery/fluid_pipe_machinery/unary/input
	name = "Port"
	desc = "Allows pouring in fluids."
	icon_state = "port"
	flags = NOSPLASH | OPENCONTAINER

/obj/machinery/fluid_pipe_machinery/unary/input/initialize()
	..()
	src.reagents = src.network?.reagents || new(0)

/obj/machinery/fluid_pipe_machinery/unary/input/get_chemical_effect_position()
	return 0

ABSTRACT_TYPE(/obj/machinery/fluid_pipe_machinery/unary/drain)
/obj/machinery/fluid_pipe_machinery/unary/drain
	var/drain_min = 0
	var/drain_max = 0

/obj/machinery/fluid_pipe_machinery/unary/drain/proc/drain()
	if(!src.network)
		return
	var/turf/simulated/T = get_turf(src)
	if(T.active_liquid?.group?.amt_per_tile)
		//pick a random unit between drain_min and drain_max to drain, if there is less fluid then what we chose, drain it all.
		var/amount = min(rand(src.drain_min, src.drain_max), src.network.reagents.maximum_volume - src.network.reagents.total_volume)/T.active_liquid.group.amt_per_tile
		if(amount > 0) // rounding errors can make it go very very slightly below zero
			T.active_liquid.group.drain(T.active_liquid, amount, src.network)
			playsound(T, 'sound/misc/drain_glug.ogg', 50, TRUE)

/obj/machinery/fluid_pipe_machinery/unary/drain/passive
	name = "Passive drain"
	icon_state = "drain"
	drain_min = 2
	drain_max = 7

/obj/machinery/fluid_pipe_machinery/unary/drain/passive/process()
	src.drain()

/obj/machinery/fluid_pipe_machinery/unary/drain/passive/big
	name = "Passive drain"
	icon_state = "drainbig"
	drain_min = 6
	drain_max = 14

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump
	name = "Inlet Pump"
	icon_state = "inlet0"
	desc = "A powered and togglable drainage pipe."

	var/on = FALSE
	drain_min = 10
	drain_max = 15

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump/attack_hand(mob/user)
	interact_particle(user, src)
	src.on = !src.on
	src.UpdateIcon(TRUE)
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump/process()
	var/area/A = get_area(src)
	if (!isarea(A))
		return
	if(!A.powered(ENVIRON))
		if(src.on)
			src.on = FALSE
			src.UpdateIcon(TRUE)
			src.visible_message(SPAN_ALERT("[src] shuts down due to lack of APC power."))
		return
	if(!src.on)
		return
	src.drain()
	src.use_power(100 WATTS, ENVIRON)

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump/hide(intact)
	src.icon_state = "inlet[src.on][CHECKHIDEPIPE(src) ? "h" : null]"

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump/update_icon(animate)
	var/turf/T = get_turf(src)
	var/intact = T.intact
	if(animate)
		FLICK("inlet[!src.on][src.on][CHECKHIDEPIPE(src) ? "h" : null]", src)
	src.icon_state = "inlet[src.on][CHECKHIDEPIPE(src) ? "h" : null]"

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump/overfloor
	level = OVERFLOOR

/obj/machinery/fluid_pipe_machinery/unary/hand_pump
	name = "Hand Pump"
	icon_state = "output0"
	desc = "A hand-operated pump."
	flags = NOSPLASH

	var/pullrate = 100

/obj/machinery/fluid_pipe_machinery/unary/hand_pump/attack_hand(mob/user)
	interact_particle(user, src)
	FLICK("output1", src)
	if(!src.network)
		return
	var/turf/simulated/T = get_turf(src)
	var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
	fluid?.trans_to(T, fluid.total_volume)
	qdel(fluid)

/obj/machinery/fluid_pipe_machinery/unary/hand_pump/attackby(obj/item/I, mob/user)
	if(!I.is_open_container(TRUE))
		return

	if (I.reagents.total_volume >= I.reagents.maximum_volume)
		boutput(user, SPAN_ALERT("[src] is full."))
		return

	FLICK("output1", src)
	if(!src.network)
		return

	if (!src.network.reagents.total_volume)
		boutput(user, SPAN_ALERT("You tried to fill [I] from [src], but nothing came out!"))
		return

	var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
	boutput(user, SPAN_NOTICE("You fill [I] with [fluid?.trans_to(I, fluid.total_volume)] units of the contents of [src]."))
	qdel(fluid)
	playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)

/obj/machinery/fluid_pipe_machinery/unary/dispenser
	name = "Dispenser"
	icon_state = "dispenser"
	desc = "Dispenses patches, pills, and vials when filled to the set amount or when prompted."
	HELP_MESSAGE_OVERRIDE("You can use a <b>multitool</b> to modify its settings.")
	var/automatic = TRUE
	var/max = 50
	var/min = 1
	var/amount = 50
	var/itemtodispense = "pills"
	var/static/list/itemlist = list("patches", "pills", "vials")

/obj/machinery/fluid_pipe_machinery/unary/dispenser/proc/dispense()
	if (src.reagents.total_volume < src.amount)
		return

	switch(src.itemtodispense)
		if("pills")
			var/obj/item/reagent_containers/pill/P = new(get_turf(src))
			src.reagents.trans_to(P, src.amount)
			src.visible_message("[src] ejects a pill.")
		if("vials")
			var/obj/item/reagent_containers/glass/vial/plastic/V = new(get_turf(src))
			src.reagents.trans_to(V, src.amount)
			src.visible_message("[src] ejects a vial.")
		if("patches")
			var/obj/item/reagent_containers/patch/P = new(get_turf(src))
			src.reagents.trans_to(P, src.amount)
			src.visible_message("[src] ejects a patch.")

/obj/machinery/fluid_pipe_machinery/unary/dispenser/proc/set_amount(var/datum/mechanicsMessage/input)
	var/newamount = text2num_safe(input.signal)
	if (!newamount)
		return
	src.amount = round(clamp(newamount, src.min, src.max), QUANTIZATION_UNITS)

/obj/machinery/fluid_pipe_machinery/unary/dispenser/proc/set_amount_manual(obj/item/W, mob/user)
	var/inp = tgui_input_number(user, "Please enter dispense amount (Will round to [QUANTIZATION_UNITS]):", "Dispense Amount", src.amount, src.max, src.min)
	if (!inp) return
	src.amount = round(inp, QUANTIZATION_UNITS)

/obj/machinery/fluid_pipe_machinery/unary/dispenser/proc/set_type(obj/item/W, mob/user)
	var/inp = tgui_input_list(user, "Select a type to output.", "Dispense Type", src.itemlist)
	src.itemtodispense = (inp in src.itemlist) ? inp : src.itemtodispense

/obj/machinery/fluid_pipe_machinery/unary/dispenser/proc/set_automatic(obj/item/W, mob/user)
	src.automatic = !src.automatic
	boutput(user, SPAN_NOTICE("Automatic mode is now set to [src.automatic ? "true" : "false"]."))

/obj/machinery/fluid_pipe_machinery/unary/dispenser/New()
	..()
	src.create_reagents(src.max)
	AddComponent(/datum/component/mechanics_holder)
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"dispense now", PROC_REF(dispense))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Dispense Amount", PROC_REF(set_amount_manual))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Dispense Type", PROC_REF(set_type))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Automatic dispensing", PROC_REF(set_automatic))

/obj/machinery/fluid_pipe_machinery/unary/dispenser/get_desc()
		. += "<br>[SPAN_NOTICE("Automatic: [src.automatic ? "true" : "false"]. Dispense Amount: [src.amount]. Dispensing: [src.itemtodispense]")]"

/obj/machinery/fluid_pipe_machinery/unary/dispenser/process()
	if (!src.network) return
	var/datum/reagents/fluid = src.pull_from_network(src.network, src.max)
	fluid.trans_to(src, src.max)
	src.push_to_network(src.network, fluid)
	src.reagents.handle_reactions()
	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "[src.reagents.total_volume]")
	if (!src.automatic)
		return
	src.dispense()

/obj/machinery/fluid_pipe_machinery/unary/node
	name = "Node"
	desc = "Used for connecting non-fluid machinery to fluid pipes, YOU SHOULDNT SEE THIS"
	invisibility = INVIS_ALWAYS

/obj/machinery/fluid_pipe_machinery/unary/node/ex_act()
	return

/obj/machinery/fluid_pipe_machinery/unary/node/meteorhit()
	return

/obj/machinery/fluid_pipe_machinery/unary/node/updateHealth()
	return


ABSTRACT_TYPE(/obj/machinery/fluid_pipe_machinery/binary)
/obj/machinery/fluid_pipe_machinery/binary
	var/datum/flow_network/network1
	var/datum/flow_network/network2

/obj/machinery/fluid_pipe_machinery/binary/New()
	..()
	src.initialize_directions = src.dir | turn(src.dir, 180)

/obj/machinery/fluid_pipe_machinery/binary/disposing()
	src.network1?.machines -= src
	src.network2?.machines -= src
	..()

/obj/machinery/fluid_pipe_machinery/binary/initialize()
	for(var/obj/fluid_pipe/target in get_step(src, turn(src.dir, 180)))
		if(target.initialize_directions & get_dir(target,src))
			src.network1 = target.network
			src.network1.machines += src
			break

	for(var/obj/fluid_pipe/target in get_step(src, src.dir))
		if(target.initialize_directions & get_dir(target,src))
			src.network2 = target.network
			src.network2.machines += src
			break

/obj/machinery/fluid_pipe_machinery/binary/refresh_network(datum/flow_network/network)
	src.network1?.machines -= src
	src.network2?.machines -= src
	src.network1 = null
	src.network2 = null
	src.initialize()


/obj/machinery/fluid_pipe_machinery/binary/pump
	name = "Fluid Pump"
	desc = "Moves fluids from one network to another at up to 200 units per pump."
	icon_state = "pump0"
	var/on = FALSE
	var/pumprate = 200

/obj/machinery/fluid_pipe_machinery/binary/pump/New()
	..()
	AddComponent(/datum/component/mechanics_holder)
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", PROC_REF(activate))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate", PROC_REF(deactivate))
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", PROC_REF(toggle))

/obj/machinery/fluid_pipe_machinery/binary/pump/proc/activate()
	if(src.on == FALSE)
		src.on = TRUE
		src.UpdateIcon()

/obj/machinery/fluid_pipe_machinery/binary/pump/proc/deactivate()
	if(src.on == TRUE)
		src.on = FALSE
		src.UpdateIcon()

/obj/machinery/fluid_pipe_machinery/binary/pump/proc/toggle()
	src.on = !src.on
	src.UpdateIcon()

/obj/machinery/fluid_pipe_machinery/binary/pump/attack_hand(mob/user)
	interact_particle(user, src)
	src.on = !src.on
	src.UpdateIcon(TRUE)
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))

/obj/machinery/fluid_pipe_machinery/binary/pump/update_icon(animate)
	if(animate)
		FLICK("pump[!src.on][src.on]", src)
	src.icon_state = "pump[src.on]"

/obj/machinery/fluid_pipe_machinery/binary/pump/process()
	if(!src.on)
		return
	var/datum/reagents/removed_fluid = src.pull_from_network(src.network1, src.pumprate)
	if(!src.push_to_network(src.network2, removed_fluid))
		removed_fluid.trans_to(network1, removed_fluid.total_volume)
	FLICK("actuallypump", src)

/obj/machinery/fluid_pipe_machinery/binary/valve
	name = "Fluid Valve"
	desc = "Connects fluid networks."
	icon_state = "valve0"
	var/on = FALSE

/obj/machinery/fluid_pipe_machinery/binary/valve/attack_hand(mob/user)
	interact_particle(user, src)
	if(ON_COOLDOWN(src, "fluidvalve", 1 SECOND))
		return
	src.on = !src.on
	src.UpdateIcon(TRUE)
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))
	if(!(src.network1 && src.network2))
		return
	if(src.on)
		src.network1.merge_network(src.network2)
	else
		src.network1.rebuild_network()

/obj/machinery/fluid_pipe_machinery/binary/valve/update_icon(animate)
	if(animate)
		FLICK("valve[!src.on][src.on]", src)
	src.icon_state = "valve[src.on]"

/obj/machinery/fluid_pipe_machinery/binary/valve/refresh_network(datum/flow_network/network)
	..()
	if(!src.on)
		return
	if(src.network1 && src.network2)
		src.network1.merge_network(src.network2)

/obj/machinery/fluid_pipe_machinery/binary/valve/disposing()
	src.on = FALSE
	src.network1.rebuild_network_force()
	..()

ABSTRACT_TYPE(/obj/machinery/fluid_pipe_machinery/trinary)
/obj/machinery/fluid_pipe_machinery/trinary
	var/datum/flow_network/network1
	var/datum/flow_network/network2
	var/datum/flow_network/network3

/obj/machinery/fluid_pipe_machinery/trinary/New()
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

/obj/machinery/fluid_pipe_machinery/trinary/disposing()
	src.network1?.machines -= src
	src.network2?.machines -= src
	src.network3?.machines -= src
	..()

/obj/machinery/fluid_pipe_machinery/trinary/initialize()
	for(var/obj/fluid_pipe/target in get_step(src, turn(src.dir, 180)))
		if(target.initialize_directions & get_dir(target,src))
			src.network1 = target.network
			src.network1.machines += src
			break

	for(var/obj/fluid_pipe/target in get_step(src, turn(src.dir, -90)))
		if(target.initialize_directions & get_dir(target,src))
			src.network2 = target.network
			src.network2.machines += src
			break

	for(var/obj/fluid_pipe/target in get_step(src, src.dir))
		if(target.initialize_directions & get_dir(target,src))
			src.network3 = target.network
			src.network3.machines += src
			break

/obj/machinery/fluid_pipe_machinery/trinary/refresh_network(datum/flow_network/network)
	src.network1?.machines -= src
	src.network2?.machines -= src
	src.network1 = null
	src.network2 = null
	src.initialize()

/obj/machinery/fluid_pipe_machinery/trinary/filter
	name = "Reagent Filter"
	desc = "Filters out a specific reagent."
	HELP_MESSAGE_OVERRIDE("Can be loaded with a <b>beaker</b>, which must contain at least 1 unit of a reagent. The most plentiful reagent is chosen for filtering.")
	icon_state = "filter0"
	flags = NOSPLASH
	var/pullrate = 200
	var/obj/item/reagent_containers/glass/beaker

/obj/machinery/fluid_pipe_machinery/trinary/filter/attackby(obj/item/reagent_containers/glass/B, mob/user)
	..()
	if(!istype(B))
		return

	if(src.beaker)
		boutput(user, "A beaker is already loaded into the machine.")

	var/reagent_to_filter = B.reagents.get_master_reagent_id()
	if(!B.reagents.has_reagent(reagent_to_filter, 1))
		boutput(user, "[B] doesn't have enough of any reagent!")
		return
	user.u_equip(B)
	src.beaker = B
	B.set_loc(src)
	icon_state = "filter1"

/obj/machinery/fluid_pipe_machinery/trinary/filter/attack_hand(mob/user)
	..()
	if(src.beaker)
		user.put_in_hand_or_drop(src.beaker)
		src.beaker = null
		icon_state = "filter0"

/obj/machinery/fluid_pipe_machinery/trinary/filter/process()
	if(!src.beaker)
		return
	var/reagent_to_filter = src.beaker.reagents.get_master_reagent_id()
	if(!src.beaker.reagents.has_reagent(reagent_to_filter, 1))
		src.beaker.set_loc(get_turf(src))
		src.visible_message(SPAN_ALERT("[src] ejects [src.beaker] due to insufficient reagents!"))
		src.beaker = null
		return
	var/datum/reagents/removed = src.pull_from_network(src.network1, src.pullrate)
	var/datum/reagents/filtered = new(removed.get_reagent_amount(reagent_to_filter))
	filtered.add_reagent(reagent_to_filter, filtered.maximum_volume, donotreact = TRUE)
	removed.remove_reagent(reagent_to_filter, filtered.maximum_volume)
	if(!src.push_to_network(src.network2, filtered))
		filtered.trans_to_direct(removed, filtered.total_volume)
	if(!src.push_to_network(src.network3, removed))
		src.push_to_network(src.network1, removed)
	FLICK("filtering", src)

