/// Updates the color of the short, connecting underlays between pipes.
/obj/machinery/atmospherics/proc/update_pipe_underlay(obj/machinery/atmospherics/node, var/direction, var/size, var/hide_pipe)
	PROTECTED_PROC(TRUE)
	var/color = null;
	if (issimplepipe(node))
		color = node.color;
	else if (ismanifoldorquad(node))
		if (ismanifoldorquad(src))
			// If both we and the node are manifolds, we want to update the color only if we are both of the same material. This avoids weird patches of conflicting colors.
			if (src.material == node.material)
				color = src.color;
		else
			color = node.color;
	else if (ismanifoldorquad(src))
		// If we are a manifold and the node is neither manifold nor pipe, we want to use our color.
		color = src.color;

	SET_PIPE_UNDERLAY(node, direction, size, color, hide_pipe);

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
	/// Pressure needed before the pipe gets a chance to burst, see proc/effective_fatigue_pressure for the value that takes into account material stats too
	var/fatigue_pressure = 150*ONE_ATMOSPHERE
	/// Can this pipe rupture?
	var/can_rupture = FALSE // Currently only used for simple pipes and manifolds
	/// How broken is our pipe.
	var/ruptured = 0
	/// What do I change back to when repaired???
	var/initial_icon_state = null
	/// Do we weld this pipe at a right angle to its actual direction?
	var/orthogonal_welding = FALSE

/obj/machinery/atmospherics/pipe/New()
	. = ..()
	initial_icon_state = icon_state

/obj/machinery/atmospherics/pipe/proc/effective_fatigue_pressure()
	var/output = src.fatigue_pressure * ((src.material?.getProperty("density") ** 2) || 1)
	var/turf/pipe_location = get_turf(src)
	//pipes encased by walls get a bonus in fatigue pressure equal to the density of the material times 5, times 10 for reinforced walls. So pipes that lay bare should be the main weak point of the engine.
	if(istype(pipe_location, /turf/simulated/wall))
		var/turf/simulated/wall/wall_location = pipe_location
		output *= ((wall_location.material?.getProperty("density") * 5) || 1)
		if(istype(pipe_location, /turf/simulated/wall/auto/reinforced))
			output *= 2
	return output

/// Returns list of coordinates to start and stop welding animation.
/obj/machinery/atmospherics/pipe/proc/get_welding_positions()
	var/start
	var/stop
	var/axis_start_value
	var/axis_stop_value
	if(icon_state=="broken")
		axis_start_value = 6
		axis_stop_value = 6
	else
		axis_start_value = 12
		axis_stop_value = 12
	var/dir = src.dir
	if (src.orthogonal_welding)
		dir = turn(dir, 90)
	switch(dir)
		if(SOUTH, NORTH)
			start = list(0, axis_start_value)
			stop = list(0, -axis_stop_value)
		if(EAST, WEST)
			start = list(-axis_start_value, 0)
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
/obj/machinery/atmospherics/pipe/proc/repair_pipe()
	src.ruptured = 0
	desc = initial(desc)
	UpdateIcon()
	ON_COOLDOWN(src, "rupture_protection", 20 SECONDS + rand(10 SECONDS, 220 SECONDS))

/// Ruptures the pipe, with varying levels of leakage.
/obj/machinery/atmospherics/pipe/proc/rupture(pressure)
	if(!can_rupture)
		return // nah, don't feel like it.

	var/new_rupture

	if(pressure && src.fatigue_pressure)
		var/iterations = clamp(log(pressure/effective_fatigue_pressure())/log(2),0,20)
		for(var/i = iterations; i>0 && i>=ruptured; i--)
			if(prob(5/i))
				new_rupture = i + 1
				break
	if(new_rupture > src.ruptured)
		ON_COOLDOWN(parent, "pipeline_rupture_protection", 16 SECONDS + rand(4 SECONDS, 24 SECONDS))
	ruptured = max(src.ruptured, new_rupture, 1)
	for (var/obj/window/window in get_turf(src))
		window.smash()
	src.desc = "[initial(src.desc)] Still looks salvageable through some careful welding."
	UpdateIcon()

/// Moves gas from the high pressure mixture to the low pressure mixture, usually pipe to tile.
/obj/machinery/atmospherics/pipe/proc/leak_gas()
	var/datum/gas_mixture/gas = return_air()
	var/datum/gas_mixture/environment = loc.return_air()

	var/datum/gas_mixture/hi_side = gas
	var/datum/gas_mixture/lo_side = environment

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

#define SHEETS_TO_REINFORCE 5
/obj/machinery/atmospherics/pipe/attackby(var/obj/item/W, var/mob/user)
	if (!src.can_rupture) //can't rupture, so can't reinforce either
		return ..()

	if(isweldingtool(W))
		if(!ruptured)
			boutput(user, SPAN_ALERT("That isn't damaged!"))
			return

		if(!W:try_weld(user, 0.8, noisy=2))
			return

		boutput(user, "You start to repair the [src.name].")

		var/positions = src.get_welding_positions()
		actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, /obj/machinery/atmospherics/pipe/proc/repair_pipe, \
				list(user), SPAN_NOTICE("[user] repairs the [src.name]."), positions[1], positions[2]),user)

	else if (istype(W, /obj/item/sheet))
		if (actions.hasAction(user, /datum/action/bar/private/welding))
			return
		if (src.ruptured)
			boutput(user, SPAN_ALERT("You should repair [src] first."))
			return
		if (!(W.material?.getMaterialFlags() & MATERIAL_METAL))
			boutput(user, SPAN_ALERT("You can't weld that!"))
			return
		if (W.material?.isSameMaterial(src.material))
			boutput(user, SPAN_ALERT("[src] is already reinforced with [src.material.getName()]!"))
			return
		var/obj/item/weldingtool/welder = user.find_tool_in_hand(TOOL_WELDING)
		if (W.amount < SHEETS_TO_REINFORCE)
			boutput(user, SPAN_ALERT("You need at least 10 sheets to reinforce [src]."))
		if (!welder || !welder.welding)
			boutput(user, SPAN_ALERT("You need something to weld [W] to [src] with!"))
			return
		if (!welder.try_weld(user, 0.8, noisy=2))
			return
		var/positions = src.get_welding_positions()
		actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, PROC_REF(weld_sheet), \
				list(W, user), SPAN_NOTICE("[user] welds [W] to [src]"), positions[1], positions[2]),user)

/obj/machinery/atmospherics/pipe/proc/weld_sheet(obj/item/sheet/sheet, mob/user)
	if (sheet.amount < SHEETS_TO_REINFORCE)
		return
	src.setMaterial(sheet.material)
	sheet.change_stack_amount(-SHEETS_TO_REINFORCE)
	if (!("reinforced" in src.name_prefixes))
		src.name_prefix("reinforced") // so it says "bohrum reinforced pipe"
	src.UpdateName()
	src.UpdateIcon()

#undef SHEETS_TO_REINFORCE

/obj/machinery/atmospherics/pipe/update_icon()
	if(ruptured)
		icon_state = "[src.initial_icon_state]-broken"

		var/image/leak
		var/datum/gas_mixture/gas = return_air()
		var/datum/gas_mixture/environment = loc.return_air()

		if( (MIXTURE_PRESSURE(gas) - (2 * MIXTURE_PRESSURE(environment))) > 0 )
			leak = SafeGetOverlayImage("leak", 'icons/obj/atmospherics/pipes/pipe.dmi', "leak")
			leak.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_ALPHA | RESET_COLOR
			leak.alpha = clamp(ruptured * 10, 40, 200)
		UpdateOverlays(leak,"leak")
	else
		icon_state = src.initial_icon_state
		ClearSpecificOverlays("leak")
	alpha = invisibility ? 128 : 255


/obj/machinery/atmospherics/pipe/check_pressure(pressure)
	if (!loc)
		return

	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - MIXTURE_PRESSURE(environment)

	if(can_rupture && !GET_COOLDOWN(parent, "pipeline_rupture_protection") && !GET_COOLDOWN(src, "rupture_protection") && pressure_difference > src.effective_fatigue_pressure())
		var/rupture_prob = (pressure_difference - src.effective_fatigue_pressure())/50000
		if(prob(rupture_prob))
			rupture(pressure_difference)

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

/obj/machinery/atmospherics/pipe/return_air(direct = FALSE)
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
#ifdef IN_MAP_EDITOR
	icon_state = "intact"
#else
	icon_state = "normal"
#endif
	color = "#B4B4B4"

	volume = 70

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	/// The minimum temperature between us and the environment before we start sharing temperature.
	var/minimum_temperature_difference = 300
	/// How well we share temperature.
	var/thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	level = UNDERFLOOR
	alpha = 128

/obj/machinery/atmospherics/pipe/simple/New()
	..()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST
		else
			initialize_directions = dir

/obj/machinery/atmospherics/pipe/simple/hide(var/i)
	if(level == UNDERFLOOR && istype(loc, /turf/simulated))
		invisibility = i ? INVIS_ALWAYS : INVIS_NONE
	UpdateIcon()

/obj/machinery/atmospherics/pipe/process()
	if (!src.parent) //This should cut back on the overhead calling build_network thousands of times per cycle
		..()
	if(!parent?.air || !loc)
		return
	if(TOTAL_MOLES(src.parent.air) < ATMOS_EPSILON)
		if(src.ruptured)
			leak_gas()
		return
	if(src.ruptured)
		leak_gas()
		return
	if (src.can_rupture)
		var/datum/gas_mixture/gas = src.return_air()
		var/pressure = MIXTURE_PRESSURE(gas)
		if(pressure > src.effective_fatigue_pressure())
			src.check_pressure(pressure)

/obj/machinery/atmospherics/pipe/simple/process()
	..()
	if(!node1)
		parent.mingle_with_turf(loc, volume)

	else if(!node2)
		parent.mingle_with_turf(loc, volume)

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

/obj/machinery/atmospherics/pipe/simple/ex_act(severity) // cogwerks - adding an override so pda bombs aren't quite so ruinous in the engine
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(30))
				qdel(src)
			else
				rupture()
		if(3)
			if (prob(50))
				rupture()

/obj/machinery/atmospherics/pipe/simple/weld_sheet(obj/item/sheet/sheet, mob/user)
	. = ..()
	src.node1?.UpdateIcon()
	src.node2?.UpdateIcon()

/obj/machinery/atmospherics/pipe/simple/disposing()
	node1?.disconnect(src)
	node2?.disconnect(src)
	..()

/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)

/obj/machinery/atmospherics/pipe/simple/update_icon()
	. = ..()
	switch(src.dir)
		if(NORTH, SOUTH, EAST, WEST)
			SET_SIMPLE_PIPE_UNDERLAY(src.node1, turn(src.dir, 180))
			SET_SIMPLE_PIPE_UNDERLAY(src.node2, src.dir)
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			SET_SIMPLE_PIPE_UNDERLAY(src.node1, turn(src.dir, 45))
			SET_SIMPLE_PIPE_UNDERLAY(src.node2, turn(src.dir, -45))


/obj/machinery/atmospherics/pipe/simple/initialize(player_caused_init)
	var/node1_connect
	var/node2_connect
	switch(src.dir)
		if(NORTH, SOUTH, EAST, WEST)
			node1_connect = turn(src.dir, 180)
			node2_connect = src.dir
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			node1_connect = turn(src.dir, 45)
			node2_connect = turn(src.dir, -45)

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node2 = target
			break
	if(player_caused_init)
		src.node1?.initialize(FALSE)
		src.node2?.initialize(FALSE)
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
	icon_state = (src.node1 && src.node2) ? "intact" : "exposed"

/obj/machinery/atmospherics/pipe/simple/junction/cant_connect(obj/machinery/atmospherics/device, direction)
	if(!istype(device, /obj/machinery/atmospherics/pipe/simple/heat_exchanging) && direction != src.dir)
		return TRUE
	if(istype(device, /obj/machinery/atmospherics/pipe/simple/heat_exchanging) && direction == src.dir)
		return TRUE

/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/obj/atmospherics/pipes/heat_pipe.dmi'
	icon_state = "intact"
	level = OVERFLOOR
	alpha = 255

	minimum_temperature_difference = 20 KELVIN
	thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT
	fatigue_pressure = INFINITY

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/update_icon()
	icon_state = (node1 && node2) ? "intact" : "exposed"

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/cant_connect(obj/machinery/atmospherics/device, direction)
	if(!(istype(device, /obj/machinery/atmospherics/pipe/simple/heat_exchanging) || istype(device, /obj/machinery/atmospherics/pipe/simple/junction)))
		return TRUE

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

/obj/machinery/atmospherics/pipe/vertical_pipe/initialize(player_caused_init)
	var/turf/T = get_turf(src)
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			node1 = target
			break
	if(player_caused_init)
		src.node1?.initialize(FALSE)
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
#ifdef IN_MAP_EDITOR
	icon_state = "manifold-map"
#else
	icon_state = "manifold"
#endif
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."
	level = UNDERFLOOR
	volume = 105
	can_rupture = TRUE
	orthogonal_welding = TRUE
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

/obj/machinery/atmospherics/pipe/manifold/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/pipe/manifold/New()
	..()
	initialize_directions = (NORTH|SOUTH|EAST|WEST) ^ dir

/obj/machinery/atmospherics/pipe/manifold/hide(var/intact)
	var/hide_pipe = CHECKHIDEPIPE(src)
	invisibility = hide_pipe ? INVIS_ALWAYS : INVIS_NONE
	update_pipe_underlay(src.node1, turn(src.dir, 90),  "short", hide_pipe)
	update_pipe_underlay(src.node2, turn(src.dir, 180), "short", hide_pipe)
	update_pipe_underlay(src.node3, turn(src.dir, -90), "short", hide_pipe)

/obj/machinery/atmospherics/pipe/manifold/weld_sheet(obj/item/sheet/sheet, mob/user)
	. = ..()
	src.node1?.UpdateIcon()
	src.node2?.UpdateIcon()
	src.node3?.UpdateIcon()

/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)

/obj/machinery/atmospherics/pipe/manifold/process()
	..()

	if(!(src.node1 && src.node2 && src.node3))
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
	. = ..()
	var/turf/T = get_turf(src)
	src.hide(T.intact)
	alpha = invisibility ? 128 : 255

/obj/machinery/atmospherics/pipe/manifold/initialize(player_caused_init)
	var/node1_connect = turn(src.dir, 90)
	var/node2_connect = turn(src.dir, 180)
	var/node3_connect = turn(src.dir, -90)

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node3 = target
			break
	if(player_caused_init)
		src.node1?.initialize(FALSE)
		src.node2?.initialize(FALSE)
		src.node3?.initialize(FALSE)
	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)


/obj/machinery/atmospherics/pipe/quadway
	icon = 'icons/obj/atmospherics/pipes/manifold_pipe.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "4way-map"
#else
	icon_state = "4way"
#endif
	name = "pipe 4-way manifold"
	desc = "A manifold composed of regular pipes"
	level = UNDERFLOOR
	volume = 140
	can_rupture = TRUE
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4

/obj/machinery/atmospherics/pipe/quadway/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/pipe/quadway/New()
	..()
	initialize_directions = NORTH|SOUTH|EAST|WEST

/obj/machinery/atmospherics/pipe/quadway/hide(var/intact)
	var/hide_pipe = CHECKHIDEPIPE(src)
	invisibility = hide_pipe ? INVIS_ALWAYS : INVIS_NONE
	update_pipe_underlay(src.node1, SOUTH,  "short", hide_pipe)
	update_pipe_underlay(src.node2, WEST,   "short", hide_pipe)
	update_pipe_underlay(src.node3, NORTH,  "short", hide_pipe)
	update_pipe_underlay(src.node4, EAST,   "short", hide_pipe)

/obj/machinery/atmospherics/pipe/quadway/pipeline_expansion()
	return list(src.node1, src.node2, src.node3, src.node4)

/obj/machinery/atmospherics/pipe/quadway/process()
	..()

	if(!(src.node1 && src.node2 && src.node3 && src.node4))
		src.parent.mingle_with_turf(loc, 70)

/obj/machinery/atmospherics/pipe/quadway/disposing()
	src.node1?.disconnect(src)
	src.node2?.disconnect(src)
	src.node3?.disconnect(src)
	src.node4?.disconnect(src)
	src.parent = null
	..()

/obj/machinery/atmospherics/pipe/quadway/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			src.parent?.dispose()
			src.parent = null
		src.node1 = null

	else if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			src.parent?.dispose()
			src.parent = null
		src.node2 = null

	else if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			src.parent?.dispose()
			src.parent = null
		src.node3 = null

	else if(reference == src.node4)
		if(istype(src.node4, /obj/machinery/atmospherics/pipe))
			src.parent?.dispose()
			src.parent = null
		src.node4 = null

	UpdateIcon()

	..()

/obj/machinery/atmospherics/pipe/quadway/update_icon()
	. = ..()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/pipe/quadway/initialize(player_caused_init)

	for(var/obj/machinery/atmospherics/target in get_step(src, SOUTH))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src, WEST))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src, NORTH))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node3 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src, EAST))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node4 = target
			break
	if(player_caused_init)
		src.node1?.initialize(FALSE)
		src.node2?.initialize(FALSE)
		src.node3?.initialize(FALSE)
		src.node4?.initialize(FALSE)
	var/turf/T = src.loc // hide if turf is not intact
	hide(T.intact)
