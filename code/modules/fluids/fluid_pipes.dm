/*
	Pipes. That move fluids. Probably.
	By Firebarrage //nuh uh, its my turn to make fluid pipes now -cringe
*/

/obj/fluid_pipe
	name = "fluid pipe"
	desc = "A pipe. For fluids."
	icon = 'icons/obj/fluid_pipe.dmi'
	anchored = ANCHORED
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

/obj/fluid_pipe/proc/refresh_connections()
	src.network?.pipes -= src
	src.network = new(src)
	var/connect_directions = src.initialize_directions
	for(var/direction in cardinal)
		if(HAS_ANY_FLAGS(direction, connect_directions))
			for(var/obj/fluid_pipe/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					if(target.network != src.network)
						src.network.merge_network(target.network)
						break

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

/obj/fluid_pipe/straight/see_fluid/disposing()
	src.network.viewable_pipes -= src
	..()

/obj/fluid_pipe/straight/see_fluid/refresh_connections()
	..()
	src.network.viewable_pipes += src
	src.update_reagent_overlay()

/obj/fluid_pipe/straight/see_fluid/proc/update_reagent_overlay() //cant stuff the component because reagents is stored in the network
	if (src.network.reagents.total_volume)
		var/image/reagent_image = image('icons/obj/fluid_pipe.dmi', "overlay", dir=src.dir)
		var/datum/color/average = src.network.reagents.get_average_color()
		average.a = max(average.a, RC_MINIMUM_REAGENT_ALPHA)
		reagent_image.color = average.to_rgba()
		src.AddOverlays(reagent_image, "reagent_overlay")

	else
		src.ClearSpecificOverlays("reagent_overlay")

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
	var/list/obj/fluid_pipe/straight/see_fluid/viewable_pipes
	var/list/obj/machinery/fluidmachinery/machines
	var/awaiting_removal = FALSE

/datum/flow_network/New(var/obj/fluid_pipe/startpipe)
	..()
	src.reagents = new(startpipe.capacity)
	src.reagents.fn = src
	src.pipes = list(startpipe)
	src.viewable_pipes = list()
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
		pipe.network = src
		src.pipes += pipe
	src.viewable_pipes |= network.viewable_pipes
	network.viewable_pipes.len = 0
	network.pipes.len = 0
	src.reagents.maximum_volume += network.reagents.maximum_volume
	network.reagents.trans_to_direct(src.reagents, network.reagents.maximum_volume)
	qdel(network)

/datum/flow_network/proc/remove_pipe(var/obj/fluid_pipe/node)
	var/turf/T = get_turf(node)
	var/datum/reagents/fluid = src.reagents.remove_any_to(src.reagents.total_volume * (node.capacity/src.reagents.maximum_volume))
	fluid.trans_to(T, fluid.total_volume)
	qdel(fluid)
	src.reagents.maximum_volume -= node.capacity
	qdel(node)
	if(src.awaiting_removal == TRUE)
		return
	src.awaiting_removal = TRUE
	UNTIL(!explosions.exploding) //not best but fine for explosions
	for(var/obj/fluid_pipe/pipe as anything in src.pipes)
		pipe.refresh_connections()
	for(var/obj/machinery/fluidmachinery/machine as anything in src.machines)
		machine.refresh_network(src)
	src.awaiting_removal = FALSE

/datum/flow_network/proc/on_reagent_changed()
	for(var/obj/fluid_pipe/straight/see_fluid/pipe as anything in src.viewable_pipes)
		pipe.update_reagent_overlay()

/datum/reagents/flow_network
	var/datum/flow_network/fn

/datum/reagents/flow_network/reagents_changed(var/add = 0)
	fn.on_reagent_changed()
