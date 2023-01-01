/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/
//
/obj/machinery/atmospherics
	anchored = 1

	var/initialize_directions = 0
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/weldable = TRUE
	var/volume = 0

/obj/machinery/atmospherics/New(var/loc, var/newdir)
	..()
	dir = newdir ? newdir : dir

/obj/machinery/atmospherics/process()
	build_network()
	..()

// override default subscribes to be in a different process loop. that's why they don't call parent ( ..() )
/obj/machinery/atmospherics/SubscribeToProcess()
	START_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

/obj/machinery/atmospherics/UnsubscribeProcess()
	STOP_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

/obj/machinery/atmospherics/proc/network_disposing(datum/pipe_network/reference)
	// Called by a network associated with this machine when it is being disposed
	// This must be implemented to unhook any references to the network

	return null

/obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	// Check to see if should be added to network. Add self if so and adjust variables appropriately.
	// Note don't forget to have neighbors look as well!

	return null

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node

	return null

/obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	// Returns pipe_network associated with connection to reference
	// Notes: should create network if necessary
	// Should never return null

	return null

/obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	// Used when two pipe_networks are combining

/obj/machinery/atmospherics/proc/return_network_air(datum/pipe_network/reference)
	// Return a list of gas_mixture(s) in the object
	//		associated with reference pipe_network for use in rebuilding the networks gases list
	// Is permitted to return null

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	//Remove self from other pipes

/obj/machinery/atmospherics/proc/pipeline_expansion()
	//Return your nodes for expanding
	return null

/obj/machinery/atmospherics/proc/mergewithedges()
	for (var/obj/machinery/atmospherics/node in src.pipeline_expansion())
		node.initialize()
		if (istype(node, /obj/machinery/atmospherics/pipe))
			node:leakgas = TRUE
		node.UpdateIcon()

/obj/machinery/atmospherics/proc/itemify()
	new /obj/item/pipeconstruct(src.loc, src)
	for (var/obj/machinery/atmospherics/pipe/node in src.pipeline_expansion())
		node.leakgas = FALSE
	qdel(src)

/obj/machinery/atmospherics/attackby(obj/item/W, mob/user)
	if(isweldingtool(W) && user.a_intent == INTENT_HARM && src.weldable)
		if(!W:try_weld(user, 2, noisy=2))
			return
		SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/atmospherics/proc/itemify, list(), src.icon, src.icon_state, \
			"<span class='notice'>[user] repairs the [src.name].</span>", INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION)


