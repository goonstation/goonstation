
/obj/machinery/fluidmachinery
	anchored = ANCHORED
	icon = 'icons/obj/fluid_pipe.dmi'
	var/initialize_directions

/obj/machinery/fluidmachinery/New()
	..()
	if(current_state >= GAME_STATE_PREGAME)
		src.initialize()
		return

/obj/machinery/fluidmachinery/proc/pull_from_network(var/datum/flow_network/network, var/maximum = 100)
	return network.reagents.remove_any_to(max(0.1,round(0.1, maximum * (network.reagents.total_volume / network.reagents.maximum_volume)))) //linear pulling proportional to fill level. lowest caps at 0.1 units

/obj/machinery/fluidmachinery/proc/push_to_network(var/datum/reagents/topush, var/datum/flow_network/network)
	topush.trans_to_direct(network.reagents, topush.maximum_volume)
	qdel(topush)

/obj/machinery/fluidmachinery/proc/refresh_network(var/datum/flow_network/network)
	return

/obj/machinery/fluidmachinery/unary
	var/datum/flow_network/network

/obj/machinery/fluidmachinery/unary/New()
	src.initialize_directions = src.dir
	..()

/obj/machinery/fluidmachinery/unary/disposing()
	src.network.machines -= src
	..()

/obj/machinery/fluidmachinery/unary/initialize()
	for(var/obj/fluid_pipe/target in get_step(src, src.dir))
		if(target.initialize_directions & get_dir(target,src))
			src.network = target.network
			src.network.machines += src
			break

/obj/machinery/fluidmachinery/unary/refresh_network(var/datum/flow_network/network)
	src.network?.machines -= src
	src.network = null
	src.initialize()

/obj/machinery/fluidmachinery/unary/inlet_pump
	name = "Inlet Pump"
	icon_state = "inlet_off"

	var/on = FALSE
	var/pullrate = 50

	attack_hand(mob/user)
		if(src.on)
			src.on = 0
			src.icon_state = "inlet_off"
			boutput(user, "You turn off the [src].")
		else
			if(!src.network)
				boutput(user, SPAN_ALERT("[src] isn't connected to anything!."))
				return
			src.on = 1
			src.icon_state = "inlet_on"
			boutput(user, "You turn on the [src].")

	process()
		if(!src.on)
			return
		if(!src.network)
			src.on = FALSE
			src.icon_state = "inlet_off"
			return
		var/turf/simulated/T = get_turf(src)
		T.active_liquid?.group?.drain(T.active_liquid, min(src.pullrate, src.network.reagents.maximum_volume - src.network.reagents.total_volume)/T.active_liquid.group.amt_per_tile, src.network)

/obj/machinery/fluidmachinery/unary/outlet_pump
	name = "Outlet Pump"
	icon_state = "inlet_off"

	var/on = FALSE
	var/pullrate = 200

	attack_hand(mob/user)
		if(src.on)
			src.on = 0
			src.icon_state = "inlet_off"
			boutput(user, "You turn off the fluid floor pump.")
		else
			src.on = 1
			src.icon_state = "inlet_on"
			boutput(user, "You turn on the fluid floor pump.")

	process()
		if(!src.on)
			return
		if(!src.network)
			src.on = FALSE
			src.icon_state = "inlet_off"
			return
		var/turf/simulated/T = get_turf(src)
		var/datum/reagents/fluid = src.pull_from_network(src.network, src.pullrate)
		fluid.trans_to(T, fluid.total_volume)

