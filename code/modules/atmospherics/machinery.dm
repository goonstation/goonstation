/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/
//
obj/machinery/atmospherics
	anchored = ANCHORED

	var/initialize_directions = 0

	process()
		build_network()
		..()

	// override default subscribes to be in a different process loop. that's why they don't call parent ( ..() )
	SubscribeToProcess()
		START_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

	UnsubscribeProcess()
		STOP_TRACKING_CAT(TR_CAT_ATMOS_MACHINES)

	proc
		network_disposing(datum/pipe_network/reference)
			// Called by a network associated with this machine when it is being disposed
			// This must be implemented to unhook any references to the network

			return null

		network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
			// Check to see if should be added to network. Add self if so and adjust variables appropriately.
			// Note don't forget to have neighbors look as well!

			return null

		build_network()
			// Called to build a network from this node

			return null

		return_network(obj/machinery/atmospherics/reference)
			// Returns pipe_network associated with connection to reference
			// Notes: should create network if necessary
			// Should never return null

			return null

		reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
			// Used when two pipe_networks are combining

		return_network_air(datum/pipe_network/reference)
			// Return a list of gas_mixture(s) in the object
			//		associated with reference pipe_network for use in rebuilding the networks gases list
			// Is permitted to return null

		disconnect(obj/machinery/atmospherics/reference)
