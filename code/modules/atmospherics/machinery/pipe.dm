/// The basic pipe parent for things that can support pipelines and bursting and stuff.
/obj/machinery/atmospherics/pipe
	text = ""
	layer = PIPE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	//Temporary gas mixture used when reconstructing a pipeline that broke.
	var/datum/gas_mixture/air_temporary
	/// Our pipeline.
	var/datum/pipeline/parent
	/// Our volume for gas.
	var/volume = 0
	/// Some debug thing when a node breaks.
	var/nodealert = FALSE

/// Returns a list of nodes that we can add to the pipeline. List may be null or contain nulls.
/obj/machinery/atmospherics/pipe/proc/pipeline_expansion()
	return null

/// Return TRUE if parent should continue checking other pipes.
/// Return FALSE or null if parent should stop checking other pipes. Recall: qdel(src) will by default return null.
/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	return TRUE

/obj/machinery/atmospherics/pipe/network_disposing(datum/pipe_network/reference)
	if (parent.network == reference)
		parent.dispose()
		parent = null

/obj/machinery/atmospherics/pipe/return_air()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.air

/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.return_network()

/obj/machinery/atmospherics/pipe/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.network_expand(new_network, reference)

/obj/machinery/atmospherics/pipe/return_network(obj/machinery/atmospherics/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

	return parent.return_network(reference)

/obj/machinery/atmospherics/pipe/disposing()
	if (parent)
		parent.dispose()
	parent = null
	if(air_temporary)
		if (loc) loc.assume_air(air_temporary)
		air_temporary = null

	..()

/// The pipe type you usually see wandering around and are most familiar with.
/obj/machinery/atmospherics/pipe/simple
	name = "pipe"
	desc = "A one meter section of regular pipe."

	icon = 'icons/obj/atmospherics/pipes/pipe.dmi'
	icon_state = "intact"
	color = "#B4B4B4"

	volume = 70

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	/// The minimum temperature between us and the environment before we start sharing temperature.
	var/minimum_temperature_difference = 300
	/// How well we share temperature.
	var/thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	/// Pressure needed before the pipe gets a chance to burst.
	var/fatigue_pressure = 150*ONE_ATMOSPHERE
	/// Can this pipe rupture?
	var/can_rupture = FALSE // Currently only used for red pipes (insulated).
	/// How broken is our pipe.
	var/ruptured = 0
	/// Are we destroyed and need replacement?
	var/destroyed = FALSE
	var/initial_icon_state = null //what do i change back to when repaired???

	level = UNDERFLOOR
	alpha = 128

/// Returns list of coordinates to start and stop welding animation.
/obj/machinery/atmospherics/pipe/simple/proc/get_welding_positions()
	var/start
	var/stop
	var/axis_start_value
	var/axis_stop_value
	if(icon_state=="exposed")
		axis_start_value = 6
		axis_stop_value = 20
	else
		axis_start_value = 12
		axis_stop_value = -12

	switch(dir)
		if(SOUTH)
			start = list(0, axis_start_value)
			stop = list(0, axis_stop_value)
		if(NORTH)
			start = list(0, -axis_start_value)
			stop = list(0, -axis_stop_value)
		if(EAST)
			start = list(-axis_start_value, 0)
			stop = list(-axis_stop_value, 0)
		if(WEST)
			start = list(axis_start_value, 0)
			stop = list(axis_stop_value, 0)
		if(SOUTHEAST)
			start = list(0, -axis_start_value)
			stop = list(axis_start_value, 0)
		if(SOUTHWEST)
			start = list(0, -axis_start_value)
			stop = list(-axis_start_value, 0)
		if(NORTHEAST)
			start = list(0, axis_start_value)
			stop = list(axis_start_value, 0)
		if(NORTHWEST)
			start = list(0, axis_start_value)
			stop = list(-axis_start_value, 0)

	if(rand(50))
		. = list(start, stop)
	else
		. = list(stop, start)

/// Repairs the pipe back to orginal state.
/obj/machinery/atmospherics/pipe/simple/proc/repair_pipe()
	src.ruptured = 0
	desc = initial(desc)
	UpdateIcon()
	ON_COOLDOWN(src, "rupture_protection", 20 SECONDS + rand(10 SECONDS, 220 SECONDS))

/// Rebuilds pipe from completely destroyed state to disconnected state.
/obj/machinery/atmospherics/pipe/simple/proc/reconstruct_pipe(mob/M, obj/item/rods/R)
	if(istype(R) && istype(M))
		R.change_stack_amount(-1)
		src.setMaterial(R.material)
		src.destroyed = FALSE
		src.icon_state = "disco"
		src.desc = "A one meter section of regular pipe has been placed but needs to be welded into place."
		// create valid edges back to us and rebuild from here out to merge pipeline(s)
		if(!istype(node1, /obj/machinery/atmospherics/pipe/manifold))
			node1.dir = node1.initialize_directions
		node1.initialize()
		if(!istype(node2, /obj/machinery/atmospherics/pipe/manifold))
			node2.dir = node2.initialize_directions
		node2.initialize()
		src.parent.build_pipeline(src)

/// Ruptures the pipe, with varying levels of leakage.
/obj/machinery/atmospherics/pipe/simple/proc/rupture(pressure, destroy=FALSE)
	var/new_rupture
	if (src.destroyed || destroy)
		ruptured = 10
		src.destroyed = TRUE
		src.desc = "The remnants of a section of pipe that needs to be replaced.  Perhaps rods would be sufficient?"
		parent?.mingle_with_turf(loc, volume)
		node1?.disconnect(src)
		node2?.disconnect(src)
		UpdateIcon()
		return

	if(pressure && src.fatigue_pressure)
		var/iterations = clamp(log(pressure/src.fatigue_pressure)/log(2),0,20)
		for(var/i = iterations; i>0 && i>=ruptured; i--)
			if(prob(5/i))
				new_rupture = i + 1
				break
	if(new_rupture > src.ruptured)
		ON_COOLDOWN(parent, "pipeline_rupture_protection", 16 SECONDS + rand(4 SECONDS, 24 SECONDS))
	ruptured = max(src.ruptured, new_rupture, 1)
	src.desc = "A one meter section of ruptured pipe still looks salvageable through some careful welding."
	UpdateIcon()

/// Moves gas from the high pressure mixture to the low pressure mixture, usually pipe to tile.
/obj/machinery/atmospherics/pipe/simple/proc/leak_gas()
	var/datum/gas_mixture/gas = return_air()
	var/datum/gas_mixture/environment = loc.return_air()

	var/datum/gas_mixture/hi_side = gas
	var/datum/gas_mixture/lo_side = environment

	if(destroyed)
		parent.mingle_with_turf(loc, volume) // maintain network for simplicity but replicate behavior of it being disconnected
		return

	// vacuum
	if( MIXTURE_PRESSURE(lo_side) > MIXTURE_PRESSURE(hi_side) )
		hi_side = environment
		lo_side = gas

	var/pressure = lerp(100*(src.ruptured**2), MIXTURE_PRESSURE(hi_side)*(ruptured/150), 0.1 )
	pressure = min(pressure,  MIXTURE_PRESSURE(hi_side) - MIXTURE_PRESSURE(lo_side))

	if(pressure > 0 && hi_side.temperature )
		var/transfer_moles = pressure*lo_side.volume/(hi_side.temperature * R_IDEAL_GAS_EQUATION)
		var/datum/gas_mixture/removed = hi_side.remove(transfer_moles)
		if(removed) lo_side==environment ? loc.assume_air(removed) : lo_side.merge(removed)
		UpdateIcon()

/obj/machinery/atmospherics/pipe/simple/New()
	..()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST
		else
			initialize_directions = dir

	initial_icon_state = icon_state

/obj/machinery/atmospherics/pipe/simple/hide(var/i)
	if(level == UNDERFLOOR && istype(loc, /turf/simulated))
		invisibility = i ? INVIS_ALWAYS : INVIS_NONE
	UpdateIcon()

/obj/machinery/atmospherics/pipe/simple/process()
	if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
		..()
	if(!parent?.air || !loc)
		return

	if(TOTAL_MOLES(parent.air) < ATMOS_EPSILON )
		if(ruptured) leak_gas()
		return

	if(!node1)
		parent.mingle_with_turf(loc, volume)
		if(!nodealert)
			//boutput(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
			nodealert = TRUE

	else if(!node2)
		parent.mingle_with_turf(loc, volume)
		if(!nodealert)
			//boutput(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
			nodealert = TRUE

	else if(ruptured)
		leak_gas()

	else if(parent)
		var/environment_temperature = 0

		if(istype(loc, /turf/simulated/))
			if(loc:gas_impermeable)
				environment_temperature = loc:temperature
			else
				var/datum/gas_mixture/environment = loc.return_air()
				environment_temperature = environment.temperature

		else
			environment_temperature = loc:temperature

		var/datum/gas_mixture/pipe_air = return_air()

		if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
			parent.temperature_interact(loc, volume, src.thermal_conductivity)

	var/datum/gas_mixture/gas = return_air()
	var/pressure = MIXTURE_PRESSURE(gas)
	if(pressure > fatigue_pressure) check_pressure(pressure)



/obj/machinery/atmospherics/pipe/simple/check_pressure(pressure)
	if (!loc)
		return

	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - MIXTURE_PRESSURE(environment)

	if(can_rupture && !GET_COOLDOWN(parent, "pipeline_rupture_protection") && !GET_COOLDOWN(src, "rupture_protection") && pressure_difference > fatigue_pressure)
		var/rupture_prob = (pressure_difference - fatigue_pressure)/50000
		if(prob(rupture_prob))
			rupture(pressure_difference)

/obj/machinery/atmospherics/pipe/simple/ex_act(severity) // cogwerks - adding an override so pda bombs aren't quite so ruinous in the engine
	switch(severity)
		if(1)
			if(prob(5))
				qdel(src)
			else
				rupture(destroy=TRUE)
		if(2)
			if(prob(10))
				rupture(destroy=TRUE)
			else
				rupture()
		if(3)
			if (prob(50))
				rupture()

/obj/machinery/atmospherics/pipe/simple/attackby(var/obj/item/W, var/mob/user)
	if(isweldingtool(W))
		if(!ruptured)
			boutput(user, "<span class='alert'>That isn't damaged!</span>")
			return
		else if(destroyed)
			boutput(user, "<span class='alert'>This needs more than just a welder. We need to make a new pipe!</span>")
			return

		if(!W:try_weld(user, 0.8, noisy=2))
			return

		boutput(user, "You start to repair the [src.name].")

		var/positions = src.get_welding_positions()
		actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, /obj/machinery/atmospherics/pipe/simple/proc/repair_pipe, \
				list(user), "<span class='notice'>[user] repairs the [src.name].</span>", positions[1], positions[2]),user)

	else if(destroyed && istype(W, /obj/item/rods))
		var/duration = 15 SECONDS
		if (user.traitHolder.hasTrait("carpenter") || user.traitHolder.hasTrait("training_engineer"))
			duration = round(duration / 2)
		var/obj/item/rods/S = W
		var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(user, src, duration, /obj/machinery/atmospherics/pipe/simple/proc/reconstruct_pipe,\
		list(user, S), W.icon, W.icon_state, "[user] finishes working with \the [src].")
		actions.start(action_bar, user)


/obj/machinery/atmospherics/pipe/simple/disposing()
	node1?.disconnect(src)
	node2?.disconnect(src)
	parent = null
	..()

/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	. = list(node1, node2)
	if(destroyed)
		. = list(null, null)

/obj/machinery/atmospherics/pipe/simple/update_icon()
	if(destroyed)
		icon_state = "destroyed"
	else if(node1 && node2)
		if(ruptured)
			icon_state = "exposed"

			var/image/leak
			var/datum/gas_mixture/gas = return_air()
			var/datum/gas_mixture/environment = loc.return_air()

			if( (MIXTURE_PRESSURE(gas) - (2 * MIXTURE_PRESSURE(environment))) > 0 )
				leak = SafeGetOverlayImage("leak", src.icon, "leak")
				leak.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_ALPHA | RESET_COLOR
				leak.alpha = clamp(ruptured * 10, 40, 200)
			UpdateOverlays(leak,"leak")
		else
			icon_state = "intact"
			UpdateOverlays(null,"leak")
		alpha = invisibility ? 128 : 255

	else
		icon_state = "exposed"
		alpha = invisibility ? 128 : 255

		if(node1) //TODO: REPLACE WITH SYSTEM SIMILAR TO MANIFOLDS
			dir = get_dir(src, node1)

		else if(node2)
			dir = get_dir(src, node2)

/obj/machinery/atmospherics/pipe/simple/initialize()
	var/connect_directions

	switch(dir)
		if(NORTH, SOUTH)
			connect_directions = NORTH|SOUTH
		if(EAST, WEST)
			connect_directions = EAST|WEST
		else
			connect_directions = dir

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			connect_directions &= ~direction
			break

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					node2 = target
					break

			connect_directions &= ~direction
			break

	var/turf/T = src.loc // hide if turf is not intact
	hide(T.intact)

/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node2 = null

	UpdateIcon()

/obj/machinery/atmospherics/pipe/simple/overfloor
	level = OVERFLOOR
	alpha = 255


/obj/machinery/atmospherics/pipe/simple/color_pipe
	color = "#FFFFFF"

/obj/machinery/atmospherics/pipe/simple/color_pipe/cyan_pipe
	name = "air hookup pipe"
	desc = "A one meter section of pipe connected to an air hookup reservoir."
	color = "#64BCC8"

/obj/machinery/atmospherics/pipe/simple/color_pipe/cyan_pipe/overfloor
	level = OVERFLOOR
	alpha = 255

/obj/machinery/atmospherics/pipe/simple/color_pipe/green_pipe
	name = "purge pipe"
	desc = "A one meter section of pipe connected to a waste vent in space."
	color = "#57C45D"

/obj/machinery/atmospherics/pipe/simple/color_pipe/green_pipe/overfloor
	level = OVERFLOOR
	alpha = 255

/obj/machinery/atmospherics/pipe/simple/color_pipe/yellow_pipe
	name = "riot control gas pipe"
	desc = "A one meter section of pipe connected to an riot control gas reservoir."
	color = "#D2C75B"

/obj/machinery/atmospherics/pipe/simple/color_pipe/yellow_pipe/overfloor
	level = OVERFLOOR
	alpha = 255


/obj/machinery/atmospherics/pipe/simple/insulated
	icon_state = "intact"
	color = "#FF0000"
	minimum_temperature_difference = 10000 KELVIN
	thermal_conductivity = 0
	level = OVERFLOOR
	alpha = 255
	can_rupture = TRUE

/obj/machinery/atmospherics/pipe/simple/insulated/underfloor //insulated pipes are by default overfloor
	level = UNDERFLOOR
	alpha = 128

/obj/machinery/atmospherics/pipe/simple/insulated/cold
	color = "#017FFF"

/obj/machinery/atmospherics/pipe/simple/insulated/cold/underfloor
	level = UNDERFLOOR
	alpha = 128

/obj/machinery/atmospherics/pipe/simple/junction
	icon = 'icons/obj/atmospherics/pipes/junction_pipe.dmi'
	icon_state = "intact"
	level = OVERFLOOR
	alpha = 255
	fatigue_pressure = INFINITY

/obj/machinery/atmospherics/pipe/simple/junction/update_icon()
	if(istype(node1, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
		dir = get_dir(src, node1)

		if(node2)
			icon_state = "intact"
		else
			icon_state = "exposed"

	else if(istype(node2, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
		dir = get_dir(src, node2)

		if(node1)
			icon_state = "intact"
		else
			icon_state = "exposed"

	else
		icon_state = "exposed"

/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/obj/atmospherics/pipes/heat_pipe.dmi'
	icon_state = "intact"
	level = OVERFLOOR
	alpha = 255

	minimum_temperature_difference = 20 KELVIN
	thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT
	fatigue_pressure = INFINITY

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/update_icon()
	if(node1 && node2)
		icon_state = "intact"

		var/node1_direction = get_dir(src, node1)
		var/node2_direction = get_dir(src, node2)

		icon_state = "[node1_direction|node2_direction]"


/obj/machinery/atmospherics/pipe/vertical_pipe
	icon = 'icons/obj/atmospherics/pipes/manifold_pipe.dmi'
	icon_state = "vertical"
	name = "Vertical Pipe"
	desc = "a section of piping dropping dropping into the floor"
	level = UNDERFLOOR
	volume = 250
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2

/obj/machinery/atmospherics/pipe/vertical_pipe/New()
	..()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/vertical_pipe/disposing()
	node1?.disconnect(src)
	node2?.disconnect(src)
	parent = null
	..()

/obj/machinery/atmospherics/pipe/vertical_pipe/pipeline_expansion()
	return list(node1, node2)

/obj/machinery/atmospherics/pipe/vertical_pipe/initialize()
	var/turf/T = get_turf(src)
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	// Search disjoint connections for vertical pipe
	node2 = locate() in T.get_disjoint_objects_by_type(DISJOINT_TURF_CONNECTION_ATMOS_MACHINERY, /obj/machinery/atmospherics/pipe/vertical_pipe)
	UpdateIcon()

/obj/machinery/atmospherics/pipe/vertical_pipe/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node2 = null

	UpdateIcon()


/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold_pipe.dmi'
	icon_state = "manifold"
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes"
	level = UNDERFLOOR
	volume = 105
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

/obj/machinery/atmospherics/pipe/manifold/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/pipe/manifold/New()
	..()
	initialize_directions = (NORTH|SOUTH|EAST|WEST) ^ dir

/obj/machinery/atmospherics/pipe/manifold/hide(var/i)
	if(level == UNDERFLOOR && istype(loc, /turf/simulated))
		invisibility = i ? INVIS_ALWAYS : INVIS_NONE
	UpdateIcon()

/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)

/obj/machinery/atmospherics/pipe/manifold/process()
	..()

	if(!node1)
		parent.mingle_with_turf(loc, 70)

	else if(!node2)
		parent.mingle_with_turf(loc, 70)

	else if(!node3)
		parent.mingle_with_turf(loc, 70)

/obj/machinery/atmospherics/pipe/manifold/disposing()
	node1?.disconnect(src)
	node2?.disconnect(src)
	node3?.disconnect(src)
	parent = null
	..()

/obj/machinery/atmospherics/pipe/manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node3 = null

	UpdateIcon()

	..()

/obj/machinery/atmospherics/pipe/manifold/update_icon()
	if(node1 && node2&& node3)
		icon_state = "manifold"
		alpha = invisibility ? 128 : 255

	else
		var/connected = 0
		var/unconnected = 0
		var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

		if(node1)
			connected |= get_dir(src, node1)
		if(node2)
			connected |= get_dir(src, node2)
		if(node3)
			connected |= get_dir(src, node3)

		unconnected = (~connected)&(connect_directions)

		icon_state = "manifold_[connected]_[unconnected]"

/obj/machinery/atmospherics/pipe/manifold/initialize()
	var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			connect_directions &= ~direction
			break

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					node2 = target
					break

			connect_directions &= ~direction
			break

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					node3 = target
					break

			connect_directions &= ~direction
			break

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
