
/obj/machinery/fluidmachinery
	icon = 'icons/obj/fluid_pipe.dmi'
	processing_tier = PROCESSING_QUARTER
	anchored = ANCHORED
	plane = PLANE_FLOOR
	var/initialize_directions

/obj/machinery/fluidmachinery/New()
	..()
	if(current_state >= GAME_STATE_PREGAME)
		src.initialize()
		return

/obj/machinery/fluidmachinery/proc/pull_from_network(var/datum/flow_network/network, var/maximum = 100)
	return network.reagents.remove_any_to(max(0.1,round(maximum * (network.reagents.total_volume / network.reagents.maximum_volume), 0.1))) //linear pulling proportional to fill level. lowest caps at 0.1 units

/obj/machinery/fluidmachinery/proc/push_to_network(var/datum/flow_network/network, var/datum/reagents/topush)
	topush?.trans_to_direct(network.reagents, topush.maximum_volume)
	qdel(topush)

/obj/machinery/fluidmachinery/proc/refresh_network(var/datum/flow_network/network)
	return

/obj/machinery/fluidmachinery/unary
	var/datum/flow_network/network

/obj/machinery/fluidmachinery/unary/New()
	src.initialize_directions = src.dir
	..()

/obj/machinery/fluidmachinery/unary/disposing()
	src.network?.machines -= src
	src.network = null
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

/obj/machinery/fluidmachinery/unary/drain
	var/drain_min = 0
	var/drain_max = 0

/obj/machinery/fluidmachinery/unary/drain/proc/drain()
	if(!src.network)
		return
	var/turf/simulated/T = get_turf(src)
	if(T.active_liquid?.group?.amt_per_tile && T.active_liquid.group.drain(T.active_liquid, min(rand(src.drain_min, src.drain_max), src.network.reagents.maximum_volume - src.network.reagents.total_volume)/T.active_liquid.group.amt_per_tile, src.network))
		playsound(T, 'sound/misc/drain_glug.ogg', 50, TRUE)

/obj/machinery/fluidmachinery/unary/drain/passive
	name = "drain"
	desc = "A drainage pipe embedded in the floor to prevent flooding. Where does the drain go? Into that pipe obviously."
	icon_state = "drain"
	drain_min = 2
	drain_max = 7

/obj/machinery/fluidmachinery/unary/drain/passive/process()
	src.drain()

/obj/machinery/fluidmachinery/unary/drain/passive/big
	icon_state = "bigdrain"
	drain_min = 6
	drain_max = 14

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
		fluid?.trans_to(T, fluid.total_volume)

/obj/machinery/fluidmachinery/binary
	var/datum/flow_network/network1
	var/datum/flow_network/network2

/obj/machinery/fluidmachinery/binary/New()
	src.initialize_directions = src.dir|turn(src.dir, 180)
	..()

/obj/machinery/fluidmachinery/binary/disposing()
	src.network1?.machines -= src
	src.network2?.machines -= src
	..()

/obj/machinery/fluidmachinery/binary/initialize()
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

/obj/machinery/fluidmachinery/binary/refresh_network(var/datum/flow_network/network)
	src.network1?.machines -= src
	src.network2?.machines -= src
	src.network1 = null
	src.network2 = null
	src.initialize()

/obj/machinery/fluidmachinery/binary/pump
	name = "Fluid Pump"
	icon_state = "pump_off"
	var/on = FALSE
	var/pumprate = 200

/obj/machinery/fluidmachinery/binary/pump/attack_hand(mob/user)
	if(src.on)
		src.on = 0
		src.icon_state = "pump_off"
		boutput(user, "You turn off the fluid pump.")
	else
		src.on = 1
		src.icon_state = "pump_on"
		boutput(user, "You turn on the fluid pump.")

/obj/machinery/fluidmachinery/binary/pump/process()
	if(!src.on)
		return
	if(!src.network1 || !src.network2)
		src.on = FALSE
		src.icon_state = "pump_off"
		return
	src.push_to_network(src.network2, src.pull_from_network(src.network1, src.pumprate))
