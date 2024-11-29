ABSTRACT_TYPE(/obj/machinery/fluid_pipe_machinery)
/obj/machinery/fluid_pipe_machinery
	icon = 'icons/obj/fluidpipes/fluid_pipe.dmi'
	processing_tier = PROCESSING_QUARTER
	anchored = ANCHORED
	plane = PLANE_FLOOR
	/// What directions are valid for connections.
	var/initialize_directions

/// Accepts an input network and an ideal amount of fluid to pull from network.
/// Returns a reagents datum containing a scaled amount of fluid linear to fullness of network or null if no fluid in network. Quantized to QUANTIZATION_UNITS units.
/obj/machinery/fluid_pipe_machinery/proc/pull_from_network(datum/flow_network/network, maximum = 100)
	return network.reagents.remove_any_to(max(MINIMUM_REAGENT_MOVED, round(maximum * (network.reagents.total_volume / network.reagents.maximum_volume), QUANTIZATION_UNITS)))

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


ABSTRACT_TYPE(/obj/machinery/fluid_pipe_machinery/unary)
/obj/machinery/fluid_pipe_machinery/unary
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
	src.UpdateIcon()
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump/process()
	if(!src.on)
		return
	src.drain()

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump/hide(intact)
	src.icon_state = "inlet[src.on][CHECKHIDEPIPE(src) ? "h" : null]"

/obj/machinery/fluid_pipe_machinery/unary/drain/inlet_pump/update_icon()
	var/turf/T = get_turf(src)
	var/intact = T.intact
	flick("inlet[!src.on][src.on][CHECKHIDEPIPE(src) ? "h" : null]", src)
	src.icon_state = "inlet[src.on][CHECKHIDEPIPE(src) ? "h" : null]"


/obj/machinery/fluid_pipe_machinery/unary/outlet_pump
	name = "Outlet Pump"
	icon_state = "output0"
	desc = "A hand"

	var/on = FALSE
	var/pullrate = 200

/obj/machinery/fluid_pipe_machinery/unary/outlet_pump/attack_hand(mob/user)
	interact_particle(user, src)
	src.on = !src.on
	src.UpdateIcon()
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))

/obj/machinery/fluid_pipe_machinery/unary/outlet_pump/process()
	if(!src.on || !src.network)
		return
	var/turf/simulated/T = get_turf(src)
	var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
	fluid?.trans_to(T, fluid.total_volume)

/obj/machinery/fluid_pipe_machinery/unary/outlet_pump/update_icon()
	icon_state = "output[src.on]"

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
	icon_state = "pump0"
	var/on = FALSE
	var/pumprate = 200

/obj/machinery/fluid_pipe_machinery/binary/pump/attack_hand(mob/user)
	interact_particle(user, src)
	src.on = !src.on
	src.UpdateIcon()
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))

/obj/machinery/fluid_pipe_machinery/binary/pump/update_icon()
	flick("pump[!src.on][src.on]", src)
	src.icon_state = "pump[src.on]"

/obj/machinery/fluid_pipe_machinery/binary/pump/process()
	if(!src.on)
		return
	var/datum/reagents/removed_fluid = src.pull_from_network(src.network1, src.pumprate)
	if(!src.push_to_network(src.network2, removed_fluid))
		removed_fluid.trans_to(network1, removed_fluid.total_volume)

/obj/machinery/fluid_pipe_machinery/binary/valve
	name = "Fluid Valve"
	icon_state = "valve0"
	var/on = FALSE

/obj/machinery/fluid_pipe_machinery/binary/valve/attack_hand(mob/user)
	interact_particle(user, src)
	if(ON_COOLDOWN(src, "fluidvalve", 1 SECOND))
		return
	src.on = !src.on
	src.UpdateIcon()
	user.visible_message(SPAN_NOTICE("[user] turns [src.on ? "on" : "off"] [src]."), SPAN_NOTICE("You turn [src.on ? "on" : "off"] [src]."))
	if(!(src.network1 && src.network2))
		return
	if(src.on)
		src.network1.merge_network(src.network2)
	else
		src.network1.rebuild_network()

/obj/machinery/fluid_pipe_machinery/binary/valve/update_icon()
	flick("valve[!src.on][src.on]", src)
	src.icon_state = "valve[src.on]"

/obj/machinery/fluid_pipe_machinery/binary/valve/refresh_network(datum/flow_network/network)
	..()
	if(!src.on)
		return
	if(src.network1 && src.network2)
		src.network1.merge_network(src.network2)
