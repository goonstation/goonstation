/*
	Pipes. That move fluids. Probably.
	By Firebarrage //nuh uh, its my turn to make fluid pipes now -cringe
*/
ABSTRACT_TYPE(/obj/fluid_pipe)
/obj/fluid_pipe
	name = "fluid pipe"
	desc = "A pipe. For fluids. Necessary to connect fluid machines."
	icon = 'icons/obj/fluidpipes/fluid_pipe.dmi'
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_BELOW
	layer = FLUID_PIPE_LAYER
	density = FALSE
	level = UNDERFLOOR
	pass_unstable = FALSE
	var/capacity = DEFAULT_FLUID_CAPACITY
	/// What directions are valid for connections.
	var/initialize_directions
	/// The network we belong to.
	var/datum/flow_network/network
	var/exclusionary = FALSE
	/// Reagent to begin with
	var/default_reagent = ""

/obj/fluid_pipe/New()
	..()
	var/turf/T = get_turf(src)
	src.hide(T.intact)
	src.initialize_dir_vars()

/obj/fluid_pipe/initialize()
	var/datum/reagents/default
	if(src.default_reagent)
		default = new(src.capacity)
		default.add_reagent(src.default_reagent, src.capacity)
	src.refresh_connections(default)

/obj/fluid_pipe/onDestroy()
	src.network.remove_pipe(src)

/obj/fluid_pipe/disposing()
	if (network)
		var/datum/flow_network/net = src.network
		var/turf/T = get_turf(src)
		var/datum/reagents/fluid = net.reagents.remove_any_to(net.reagents.total_volume * (src.capacity/net.reagents.maximum_volume))
		fluid?.trans_to(T, fluid.total_volume)
		net.reagents.maximum_volume -= src.capacity
		net.pipes -= src
		src.network = null
		src.set_loc(null)
		net.rebuild_network_force()
	..()

/// Accepts a reagents datum to start with.
/// Replaces our network with a new one and relooks for pipes to connect to.
/obj/fluid_pipe/proc/refresh_connections(datum/reagents/flow_network/leftover)
	src.network = src.network || new(src)
	leftover?.trans_to_direct(src.network.reagents, leftover.total_volume)
	var/connect_directions = src.initialize_directions
	for(var/direction in cardinal) // Look for pipes to connect to.
		if(HAS_ANY_FLAGS(direction, connect_directions))
			for(var/obj/fluid_pipe/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					src.network.merge_pipe(target)
					connect_directions &= ~direction
					break
	if(connect_directions) // If we have any remaining directions, look for machines.
		for(var/direction in cardinal)
			if(HAS_ANY_FLAGS(direction, connect_directions))
				for(var/obj/machinery/fluid_machinery/target in get_step(src,direction))
					if(target.initialize_directions & get_dir(target,src))
						target.refresh_network()
						break

/obj/fluid_pipe/proc/initialize_dir_vars()

/obj/fluid_pipe/hide(var/intact)
	var/hide_pipe = CHECKHIDEPIPE(src)
	invisibility = hide_pipe ? INVIS_ALWAYS : INVIS_NONE


/obj/fluid_pipe/straight
	icon_state = "straight"

/obj/fluid_pipe/straight/overfloor
	level = OVERFLOOR

/obj/fluid_pipe/straight/initialize_dir_vars()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/fluid_pipe/straight/see_fluid
	icon_state = "straight-viewable"

/obj/fluid_pipe/straight/see_fluid/overfloor
	level = OVERFLOOR

/obj/fluid_pipe/straight/see_fluid/refresh_connections(datum/reagents/flow_network/leftover)
	..()
	src.AddComponent( \
		/datum/component/reagent_overlay/other_target, \
		reagent_overlay_icon = src.icon, \
		reagent_overlay_icon_state = src.icon_state, \
		reagent_overlay_states = 1, \
		queue_updates = FALSE, \
		target = src.network)

/obj/fluid_pipe/straight/see_fluid/get_desc(dist, mob/user)
	if (dist > 2)
		return
	. = "<br>[SPAN_NOTICE("[src.network.reagents.get_description(user, RC_FULLNESS | RC_VISIBLE | RC_SPECTRO)]")]"

/obj/fluid_pipe/t_junction
	icon_state = "junction"

/obj/fluid_pipe/t_junction/overfloor
	level = OVERFLOOR

/obj/fluid_pipe/t_junction/initialize_dir_vars()
	switch(dir)
		if(NORTH)
			initialize_directions = NORTH|EAST|WEST
		if(SOUTH)
			initialize_directions = SOUTH|EAST|WEST
		if(EAST)
			initialize_directions = EAST|NORTH|SOUTH
		if(WEST)
			initialize_directions = WEST|NORTH|SOUTH

/obj/fluid_pipe/elbow
	icon_state = "elbow"

/obj/fluid_pipe/elbow/overfloor
	level = OVERFLOOR

/obj/fluid_pipe/elbow/initialize_dir_vars()
	switch(dir)
		if(NORTH)
			initialize_directions = NORTH|WEST
		if(SOUTH)
			initialize_directions = SOUTH|EAST
		if(EAST)
			initialize_directions = EAST|NORTH
		if(WEST)
			initialize_directions = WEST|SOUTH

/obj/fluid_pipe/quad
	icon_state = "quad"
	initialize_directions = NORTH|SOUTH|EAST|WEST

/obj/fluid_pipe/quad/overfloor
	level = OVERFLOOR

/obj/fluid_pipe/fluid_tank
	name = "fluid tank"
	desc = "A big ol' tank of fluid. Basically a big pipe."
	icon = 'icons/obj/fluidpipes/fluid_tank.dmi'
	icon_state = "tank"
	density = TRUE
	plane = PLANE_DEFAULT
	layer = EFFECTS_LAYER_BASE
	level = OVERFLOOR
	capacity = LARGE_FLUID_CAPACITY

/obj/fluid_pipe/fluid_tank/initialize_dir_vars()
	src.initialize_directions = src.dir

/obj/fluid_pipe/fluid_tank/attackby(obj/item/I, mob/user)
	if (I.force)
		src.visible_message(SPAN_ALERT("[user] hits \the [src] with \a [I]!"))
		user.lastattacked = get_weakref(src)
		attack_particle(user,src)
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		src.changeHealth(-I.force)
	..()

/obj/fluid_pipe/fluid_tank/see_fluid
	icon_state = "tank-view"

/obj/fluid_pipe/fluid_tank/see_fluid/refresh_connections(datum/reagents/flow_network/leftover)
	..()
	src.AddComponent( \
		/datum/component/reagent_overlay/other_target, \
		reagent_overlay_icon = src.icon, \
		reagent_overlay_icon_state = src.icon_state, \
		reagent_overlay_states = 8, \
		queue_updates = FALSE, \
		target = src.network)

/obj/fluid_pipe/fluid_tank/see_fluid/get_desc(dist, mob/user)
	if (dist > 2)
		return
	. = "<br>[SPAN_NOTICE("[src.network.reagents.get_description(user, RC_FULLNESS | RC_VISIBLE | RC_SPECTRO)]")]"

// Represents a single connected set of fluid pipes
/datum/flow_network
	/// Our shared reagents.
	var/datum/reagents/flow_network/reagents
	/// A list of every pipe we own.
	var/list/obj/fluid_pipe/pipes
	/// Connected machines to update whenever our network is merged or destroyed.
	var/list/obj/machinery/fluid_machinery/machines
	/// We're gonna destroy ourselves, discard further attempts to destroy. Currently used to prevent network deletion and creation spam during booms.
	var/awaiting_removal = FALSE

/datum/flow_network/New(var/obj/fluid_pipe/startpipe)
	..()
	src.reagents = new(startpipe.capacity)
	src.reagents.fluid_network = src
	src.pipes = list(startpipe)
	src.machines = list()

/datum/flow_network/disposing()
	src.reagents.fluid_network = null
	QDEL_NULL(src.reagents)
	src.pipes.len = 0
	src.machines.len = 0
	..()

/// Accepts a pipe to merge with.
/datum/flow_network/proc/merge_pipe(obj/fluid_pipe/fluid_pipe)
	if(isnull(fluid_pipe.network))
		fluid_pipe.network = src
		var/datum/component/reagent_overlay/other_target/fluid_component = fluid_pipe.GetComponent(/datum/component/reagent_overlay/other_target)
		if(fluid_component)
			var/states = fluid_component.reagent_overlay_states
			fluid_component.RemoveComponent()
			fluid_pipe.AddComponent( \
				/datum/component/reagent_overlay/other_target, \
				reagent_overlay_icon = fluid_pipe.icon, \
				reagent_overlay_icon_state = fluid_pipe.icon_state, \
				reagent_overlay_states = states, \
				queue_updates = FALSE, \
				target = src)
		return

	src.merge_network(fluid_pipe.network)

/// Accepts a network to merge with.
/// Merges all machines and pipes into the bigger network then deletes the smaller one.
/datum/flow_network/proc/merge_network(datum/flow_network/network)
	if(src == network)
		return
	var/datum/flow_network/assuming_network
	var/datum/flow_network/assumed_network
	if(length(src.pipes) > length(network.pipes)) //lets iterate through the smaller list, not the bigger one
		assuming_network = src
		assumed_network = network
	else
		assuming_network = network
		assumed_network = src
	assuming_network.reagents.maximum_volume += assumed_network.reagents.maximum_volume
	assumed_network.reagents.trans_to_direct(assuming_network.reagents, assumed_network.reagents.total_volume)
	for(var/obj/fluid_pipe/pipe as anything in assumed_network.pipes)
		pipe.network = assuming_network
		var/datum/component/reagent_overlay/other_target/fluid_component = pipe.GetComponent(/datum/component/reagent_overlay/other_target)
		if(fluid_component)
			var/states = fluid_component.reagent_overlay_states
			fluid_component.RemoveComponent()
			pipe.AddComponent( \
				/datum/component/reagent_overlay/other_target, \
				reagent_overlay_icon = pipe.icon, \
				reagent_overlay_icon_state = pipe.icon_state, \
				reagent_overlay_states = states, \
				queue_updates = FALSE, \
				target = assuming_network)
	for(var/obj/machinery/fluid_machinery/machine as anything in assumed_network.machines)
		machine.refresh_network(assuming_network)
	assuming_network.pipes += assumed_network.pipes
	assumed_network.pipes.len = 0
	qdel(assumed_network)


/// Refreshes all machines and pipes and removes ourself. Delays during explosions.
/datum/flow_network/proc/rebuild_network()
	set waitfor = FALSE
	if(src.awaiting_removal)
		return
	src.awaiting_removal = TRUE
	UNTIL(!explosions.exploding, 0) //not best but fine for explosions
	for(var/obj/fluid_pipe/pipe as anything in src.pipes)
		pipe.network = new(pipe)
	for(var/obj/fluid_pipe/pipe as anything in src.pipes)
		pipe.refresh_connections(src.reagents.remove_any_to(src.reagents.total_volume * (pipe.capacity/src.reagents.maximum_volume)))
		src.reagents.maximum_volume -= pipe.capacity
	for(var/obj/machinery/fluid_machinery/machine as anything in src.machines)
		machine.refresh_network(src)
	src.awaiting_removal = FALSE
	qdel(src)

/// Refreshes all machines and pipes and removes ourself. Does not delay during explosions.
/datum/flow_network/proc/rebuild_network_force()
	for(var/obj/fluid_pipe/pipe as anything in src.pipes)
		pipe.network = new(pipe)
	for(var/obj/fluid_pipe/pipe as anything in src.pipes)
		pipe.refresh_connections(src.reagents.remove_any_to(src.reagents.total_volume * (pipe.capacity/src.reagents.maximum_volume)))
		src.reagents.maximum_volume -= pipe.capacity
	for(var/obj/machinery/fluid_machinery/machine as anything in src.machines)
		machine.refresh_network(src)
	src.awaiting_removal = FALSE
	qdel(src)

/// Removes a pipe from our network. Spills its contents on its turf. Refreshes network afterwards.
/datum/flow_network/proc/remove_pipe(obj/fluid_pipe/node)
	var/turf/T = get_turf(node)
	var/datum/reagents/fluid = src.reagents.remove_any_to(src.reagents.total_volume * (node.capacity/src.reagents.maximum_volume))
	fluid?.trans_to(T, fluid.total_volume)
	src.reagents.maximum_volume -= node.capacity
	src.pipes -= node
	node.network = null
	qdel(node)
	src.rebuild_network()

/datum/flow_network/proc/on_reagent_changed()
	SEND_SIGNAL(src, COMSIG_ATOM_REAGENT_CHANGE)

// Whenever I put the flow network in reagents/var/my_atom, it disappears for some reason and therefore it cant update, so i made this instead -cringe
/datum/reagents/flow_network
	var/datum/flow_network/fluid_network
	inert = TRUE //you can do that somewhere else

/datum/reagents/flow_network/reagents_changed(add = 0)
	fluid_network.on_reagent_changed()
