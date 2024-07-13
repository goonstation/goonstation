/*
	Pipes. That move fluids. Probably.
	By Firebarrage //nuh uh, its my turn to make fluid pipes now -cringe
*/

/obj/fluid_pipe
	name = "fluid pipe"
	desc = "A pipe. For fluids."
	icon = 'icons/obj/fluid_pipe.dmi'
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_BELOW
	layer = FLUID_PIPE_LAYER
	density = FALSE
	var/capacity = DEFAULT_FLUID_CAPACITY
	var/initialize_directions
	var/datum/flow_network/network // Which network is mine?

/obj/fluid_pipe/New()
	..()
	src.refresh_connections()

/obj/fluid_pipe/onDestroy()
	src.network.remove_pipe(src)

/obj/fluid_pipe/disposing()
	src.network.pipes -= src
	src.network = null
	..()

/obj/fluid_pipe/proc/refresh_connections(var/datum/reagents/flow_network/leftover)
	src.network = new(src)
	leftover?.trans_to_direct(src.network.reagents, leftover.total_volume)
	var/connect_directions = src.initialize_directions
	for(var/direction in cardinal)
		if(HAS_ANY_FLAGS(direction, connect_directions))
			for(var/obj/fluid_pipe/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					if(target.network != src.network)
						src.network.merge_network(target.network)
					connect_directions &= ~direction
					break
	if(connect_directions)
		for(var/direction in cardinal)
			if(HAS_ANY_FLAGS(direction, connect_directions))
				for(var/obj/machinery/fluidmachinery/target in get_step(src,direction))
					if(target.initialize_directions & get_dir(target,src))
						target.refresh_network()
						break

/obj/fluid_pipe/straight
	icon_state = "straight"

/obj/fluid_pipe/straight/New()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST
	..()

/obj/fluid_pipe/straight/see_fluid
	icon_state = "straight-glass"

/obj/fluid_pipe/straight/see_fluid/New()
	..()
	src.AddComponent( \
		/datum/component/reagent_overlay/fluid_pipe, \
		reagent_overlay_icon = src.icon, \
		reagent_overlay_icon_state = src.icon_state, \
		reagent_overlay_states = 1)

/obj/fluid_pipe/straight/see_fluid/get_desc(dist, mob/user)
	if (dist > 2)
		return
	. = "<br>[SPAN_NOTICE("[src.network.reagents.get_description(user, RC_FULLNESS | RC_VISIBLE | RC_SPECTRO)]")]"

/obj/fluid_pipe/t_junction
	icon_state = "junction"

/obj/fluid_pipe/t_junction/New()
	switch(dir)
		if(NORTH)
			initialize_directions = NORTH|EAST|WEST
		if(SOUTH)
			initialize_directions = SOUTH|EAST|WEST
		if(EAST)
			initialize_directions = EAST|NORTH|SOUTH
		if(WEST)
			initialize_directions = WEST|NORTH|SOUTH
	..()

/obj/fluid_pipe/elbow
	icon_state = "elbow"

/obj/fluid_pipe/elbow/New()
	switch(dir)
		if(NORTH)
			initialize_directions = NORTH|WEST
		if(SOUTH)
			initialize_directions = SOUTH|EAST
		if(EAST)
			initialize_directions = EAST|NORTH
		if(WEST)
			initialize_directions = WEST|SOUTH
	..()

/obj/fluid_pipe/quad
	icon_state = "quad"
	initialize_directions = NORTH|SOUTH|EAST|WEST

// Represents a single connected set of fluid pipes
/datum/flow_network
	var/datum/reagents/flow_network/reagents
	var/list/obj/fluid_pipe/pipes
	var/list/obj/machinery/fluidmachinery/machines
	var/awaiting_removal = FALSE

/datum/flow_network/New(var/obj/fluid_pipe/startpipe)
	..()
	src.reagents = new(startpipe.capacity)
	src.reagents.fn = src
	src.pipes = list(startpipe)
	src.machines = list()

/datum/flow_network/disposing()
	src.reagents.fn = null
	qdel(src.reagents)
	src.reagents = null
	..()

/datum/flow_network/proc/merge_network(var/datum/flow_network/network)
	if(src == network)
		return
	for(var/obj/fluid_pipe/pipe as anything in network.pipes)
		var/datum/component/reagent_overlay/fluid_pipe/fluid_component = pipe.GetComponent(/datum/component/reagent_overlay)
		if(fluid_component)
			fluid_component.unregister_signals()
			pipe.network = src
			fluid_component.register_signals()
		else
			pipe.network = src

	for(var/obj/machinery/fluidmachinery/machine as anything in network.machines)
		machine.refresh_network(src)
	src.pipes += network.pipes
	network.pipes.len = 0
	src.reagents.maximum_volume += network.reagents.maximum_volume
	network.reagents.trans_to_direct(src.reagents, network.reagents.total_volume)
	qdel(network)

/datum/flow_network/proc/remove_pipe(var/obj/fluid_pipe/node)
	var/turf/T = get_turf(node)
	var/datum/reagents/fluid = src.reagents.remove_any_to(src.reagents.total_volume * (node.capacity/src.reagents.maximum_volume))
	fluid.trans_to(T, fluid.total_volume)
	src.reagents.maximum_volume -= node.capacity
	qdel(node)
	if(src.awaiting_removal == TRUE)
		return
	src.awaiting_removal = TRUE
	UNTIL(!explosions.exploding) //not best but fine for explosions
	for(var/obj/fluid_pipe/pipe as anything in src.pipes)
		pipe.network = null
	for(var/obj/fluid_pipe/pipe as anything in src.pipes)
		fluid = src.reagents.remove_any_to(src.reagents.total_volume * (node.capacity/src.reagents.maximum_volume))
		src.reagents.maximum_volume -= pipe.capacity
		pipe.refresh_connections(fluid)
	for(var/obj/machinery/fluidmachinery/machine as anything in src.machines)
		machine.refresh_network(src)
	src.awaiting_removal = FALSE
	qdel(src)

/datum/flow_network/proc/on_reagent_changed()
	SEND_SIGNAL(src, COMSIG_ATOM_REAGENT_CHANGE)

/datum/reagents/flow_network
	var/datum/flow_network/fn

/datum/reagents/flow_network/reagents_changed(var/add = 0)
	fn.on_reagent_changed()
