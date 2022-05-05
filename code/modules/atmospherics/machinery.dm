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
	anchored = 1

	var/initialize_directions = 0
	New()
		..()
		if(current_state >= GAME_STATE_PLAYING) // we dont want to possibly mess up the engine
			SPAWN(0.5 SECONDS)
			construct(. , src) // action bar is for crafting it
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


		return_all_nodes(var/obj/machinery/atmospherics/R)
			// Have you ever had enough with how atmos pipes name their vars?
			// do you want to stop slamming your head on your keyboard in frustration as your code fails to compile?
			// well now you can use this and skip the headache and just get a list of all the nodes of a machine.
			// revolutionary new technology

		construct(var/datum/action/bar/icon/build/B,var/obj/machinery/atmospherics/R)
			if(isnull(R))
				return
			R.initialize()
			var/list/obj/machinery/atmospherics/node_list = R.return_all_nodes(R)
			var/list/datum/pipe_network/nodenet_list = list()
			for(var/obj/machinery/atmospherics/N in node_list)
				if(N?.return_network()) // only add networked nodes to our list
					nodenet_list += N.return_network()
				N.UpdateIcon()
				N.initialize() // update it for good measure anyway
			R.build_network()
			if(R.return_network()) // some devices CANT have a network, such as valves
				for(var/datum/pipe_network/nodenet in nodenet_list)
					nodenet.merge(R.return_network())

				 // crazy idea: what if we built a network first
				 // and skipped all the logic we would need otherwise

			R.UpdateIcon()
			R.initialize()

		deconstruct(var/obj/machinery/atmospherics/pipe/manifold/R)
			if(isnull(R))
				return
			var/atom/A = new /obj/item/sheet(R.loc)
			if (R.material)
				A.setMaterial(R.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M)
			qdel(R)
