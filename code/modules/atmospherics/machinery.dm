/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/

/obj/machinery/atmospherics
	anchored = TRUE

	var/initialize_directions = 0

/obj/machinery/atmospherics/process()
	build_network()
	..()

	// override default subscribes to be in a different process loop. that's why they don't call parent ( ..() )
/obj/machinery/atmospherics/SubscribeToProcess()
	START_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

/obj/machinery/atmospherics/UnsubscribeProcess()
	STOP_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

/// Called by a network associated with this machine when it is being disposed.
/// This must be implemented to unhook any references to the network.
/obj/machinery/atmospherics/proc/network_disposing(datum/pipe_network/reference)
	return null

/// Check to see if should be added to network. Add self if so and adjust variables appropriately.
/// Note don't forget to have neighbors look as well!
/obj/machinery/atmospherics/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	return null

/// Called to build a network from this node.
/obj/machinery/atmospherics/proc/build_network()
	return null

/// Returns pipe_network associated with connection to reference.
/// Notes: should create network if necessary.
/// Should never return null.
/obj/machinery/atmospherics/proc/return_network(obj/machinery/atmospherics/reference)
	return null

/// Used when two pipe_networks are combining
/obj/machinery/atmospherics/proc/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)

/// Return a list of gas_mixture(s) in the object
/// associated with reference pipe_network for use in rebuilding the networks gases list.
/// Is permitted to return null
/obj/machinery/atmospherics/proc/return_network_air(datum/pipe_network/reference)

/// Called to disconnect everything from this node
/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	return null
