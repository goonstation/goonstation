/*
	Pipes. That move fluids. Probably.
	By Firebarrage //nuh uh, its my turn to make fluid pipes now -cringe
*/

/obj/fluid_pipe
	name = "fluid pipe"
	desc = "A pipe. For fluids."
	icon = 'icons/obj/fluidpipes.dmi'
	anchored = ANCHORED
	density = FALSE
	var/capacity = DEFAULT_FLUID_CAPACITY
	var/initialize_directions
	var/datum/flow_network/network // Which network is mine?

/obj/fluid_pipe/New()
	..()
	src.network = new(src)
	if(current_state >= GAME_STATE_PREGAME)
		src.initialize()
		return

/obj/fluid_pipe/initialize()
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
					if(target.network != src.network)
						src.network.merge_network(target.network)
						break

/obj/fluid_pipe/disposing()
	src.network.reagents.remove_any(src.network.reagents.total_volume * (src.capacity/src.network.reagents.maximum_volume))
	src.network.reagents.maximum_volume -= src.capacity
	src.network.pipes -= src
	src.network.try_split_network(src)
	src.network = null
	..()

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
	icon_state = "straight_viewable"

/obj/fluid_pipe/straight/see_fluid/New()
	..()/*
	src.RegisterSignal(src.network, COMSIG_ATOM_REAGENT_CHANGE, PROC_REF(update_reagent_overlay))

/obj/fluid_pipe/proc/update_reagent_overlay()
	if (reagent_state)
		var/image/reagent_image = image(src.reagent_overlay_icon, "f-[src.reagent_overlay_icon_state]-[reagent_state]", dir=src.dir)
		var/datum/color/average = src.network.reagents.get_average_color()
		average.a = max(average.a, RC_MINIMUM_REAGENT_ALPHA)
		reagent_image.color = average.to_rgba()
		src.AddOverlays(reagent_image, "reagent_overlay")

	else
		src.ClearSpecificOverlays("reagent_overlay")
*/
/obj/fluid_pipe/t_junction
	icon_state = "tjunction"

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
	var/datum/reagents/reagents
	var/list/obj/fluid_pipe/pipes
	var/list/obj/machinery/fluidmachinery/machines

/datum/flow_network/New(var/obj/fluid_pipe/startpipe)
	..()
	src.reagents = new(startpipe.capacity)
	src.pipes = list(startpipe)


/datum/flow_network/proc/merge_network(var/datum/flow_network/network)
	if(src == network)
		return
	for(var/obj/fluid_pipe/pipe in network.pipes)
		pipe.network = src
		src.pipes += pipe
	network.pipes.len = 0
	src.reagents.maximum_volume += network.reagents.maximum_volume
	network.reagents.trans_to_direct(src.reagents, network.reagents.maximum_volume)
	qdel(network)

/datum/flow_network/proc/try_split_network(var/obj/fluid_pipe/node)


