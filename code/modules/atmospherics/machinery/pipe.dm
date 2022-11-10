// Problem: Pumps seem to reset the temperature or something??
// Had a pipe on one end of a pump with 240 C, the other end was 20 C.

obj/machinery/atmospherics/pipe
	text = ""
	layer = PIPE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent

	var/volume = 0
	var/nodealert = 0

	proc/pipeline_expansion()
		return null

	proc/check_pressure(pressure)
		//Return 1 if parent should continue checking other pipes
		//Return null if parent should stop checking other pipes. Recall:	qdel(src) will by default return null

		return 1

	network_disposing(datum/pipe_network/reference)
		if (parent.network == reference)
			parent.dispose()
			parent = null

	return_air()
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.air

	build_network()
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.return_network()

	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.network_expand(new_network, reference)

	return_network(obj/machinery/atmospherics/reference)
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.return_network(reference)

	disposing()
		if (parent)
			parent.dispose()
		parent = null
		if(air_temporary)
			if (loc) loc.assume_air(air_temporary)
			air_temporary = null

		..()


	simple
		icon = 'icons/obj/atmospherics/pipes/regular_pipe.dmi'
		icon_state = "intact"//-f"

		name = "pipe"
		desc = "A one meter section of regular pipe."

		volume = 70

		dir = SOUTH
		initialize_directions = SOUTH|NORTH

		var/obj/machinery/atmospherics/node1
		var/obj/machinery/atmospherics/node2

		var/minimum_temperature_difference = 300
		var/thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

		var/fatigue_pressure = 150*ONE_ATMOSPHERE

		var/can_rupture = FALSE //currently only need red pipes (insulated) to rupture
		var/ruptured = 0 //oh no it broke and is leaking everywhere
		var/destroyed = FALSE // it needs to be replaced!
		var/initial_icon_state = null //what do i change back to when repaired???

		level = 1
		alpha = 128

		vertical
			dir = NORTH
		northeast
			dir = NORTHEAST
		horizontal
			dir = EAST
		southeast
			dir = SOUTHEAST
		southwest
			dir = SOUTHWEST
		northwest
			dir = NORTHWEST

		New()
			..()
			switch(dir)
				if(SOUTH)
					initialize_directions = SOUTH|NORTH
				if(NORTH)
					initialize_directions = SOUTH|NORTH
				if(EAST)
					initialize_directions = EAST|WEST
				if(WEST)
					initialize_directions = EAST|WEST
				if(NORTHEAST)
					initialize_directions = NORTH|EAST
				if(NORTHWEST)
					initialize_directions = NORTH|WEST
				if(SOUTHEAST)
					initialize_directions = SOUTH|EAST
				if(SOUTHWEST)
					initialize_directions = SOUTH|WEST
			initial_icon_state = icon_state

		overfloor
			level = 2
			alpha = 255

			vertical
				dir = NORTH
			northeast
				dir = NORTHEAST
			horizontal
				dir = EAST
			southeast
				dir = SOUTHEAST
			southwest
				dir = SOUTHWEST
			northwest
				dir = NORTHWEST

		color_pipe
			icon = 'icons/obj/atmospherics/pipes/color_pipe.dmi'
			cyan_pipe
				name = "air hookup pipe"
				desc = "A one meter section of pipe connected to an air hookup reservoir."
				//icon = 'icons/obj/atmospherics/pipes/cyan_pipe.dmi'
				color = "#64BCC8"

				vertical
					dir = NORTH
				northeast
					dir = NORTHEAST
				horizontal
					dir = EAST
				southeast
					dir = SOUTHEAST
				southwest
					dir = SOUTHWEST
				northwest
					dir = NORTHWEST

				overfloor
					level = 2
					alpha = 255

					vertical
						dir = NORTH
					northeast
						dir = NORTHEAST
					horizontal
						dir = EAST
					southeast
						dir = SOUTHEAST
					southwest
						dir = SOUTHWEST
					northwest
						dir = NORTHWEST

			green_pipe
				name = "purge pipe"
				desc = "A one meter section of pipe connected to a waste vent in space."
				//icon = 'icons/obj/atmospherics/pipes/green_pipe.dmi'
				color = "#57C45D"

				vertical
					dir = NORTH
				northeast
					dir = NORTHEAST
				horizontal
					dir = EAST
				southeast
					dir = SOUTHEAST
				southwest
					dir = SOUTHWEST
				northwest
					dir = NORTHWEST

				overfloor
					level = 2
					alpha = 255

					vertical
						dir = NORTH
					northeast
						dir = NORTHEAST
					horizontal
						dir = EAST
					southeast
						dir = SOUTHEAST
					southwest
						dir = SOUTHWEST
					northwest
						dir = NORTHWEST

			yellow_pipe
				name = "riot control gas pipe"
				desc = "A one meter section of pipe connected to an riot control gas reservoir."
				//icon = 'icons/obj/atmospherics/pipes/yellow_pipe.dmi'
				color = "#D2C75B"

				vertical
					dir = NORTH
				northeast
					dir = NORTHEAST
				horizontal
					dir = EAST
				southeast
					dir = SOUTHEAST
				southwest
					dir = SOUTHWEST
				northwest
					dir = NORTHWEST

				overfloor
					level = 2
					alpha = 255

					vertical
						dir = NORTH
					northeast
						dir = NORTHEAST
					horizontal
						dir = EAST
					southeast
						dir = SOUTHEAST
					southwest
						dir = SOUTHWEST
					northwest
						dir = NORTHWEST

		hide(var/i)
			if(level == 1 && istype(loc, /turf/simulated))
				invisibility = i ? INVIS_ALWAYS : INVIS_NONE
			UpdateIcon()

		process()
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
					nodealert = 1

			else if(!node2)
				parent.mingle_with_turf(loc, volume)
				if(!nodealert)
					//boutput(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
					nodealert = 1

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

		proc/leak_gas()
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

		check_pressure(pressure)
			if (!loc)
				return

			var/datum/gas_mixture/environment = loc.return_air()

			var/pressure_difference = pressure - MIXTURE_PRESSURE(environment)

			if(can_rupture && !GET_COOLDOWN(parent, "pipeline_rupture_protection") && !GET_COOLDOWN(src, "rupture_protection") && pressure_difference > fatigue_pressure)
				var/rupture_prob = (pressure_difference - fatigue_pressure)/50000
				if(prob(rupture_prob))
					rupture(pressure_difference)

		proc/rupture(pressure, destroy=FALSE)
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

		ex_act(severity) // cogwerks - adding an override so pda bombs aren't quite so ruinous in the engine
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
			return


		attackby(var/obj/item/W, var/mob/user)
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

		proc/get_welding_positions()
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

		proc/repair_pipe()
			src.ruptured = 0
			desc = initial(desc)
			UpdateIcon()
			ON_COOLDOWN(src, "rupture_protection", 20 SECONDS + rand(10 SECONDS, 220 SECONDS))

		proc/reconstruct_pipe(mob/M, obj/item/rods/R)
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

		disposing()
			node1?.disconnect(src)
			node2?.disconnect(src)
			parent = null
			..()

		pipeline_expansion()
			. = list(node1, node2)
			if(destroyed)
				. = list(null, null)

		update_icon()
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
					icon_state = "intact"//[invisibility ? "-f" : "" ]"
					UpdateOverlays(null,"leak")
				alpha = invisibility ? 128 : 255

				var/node1_direction = get_dir(src, node1)
				var/node2_direction = get_dir(src, node2)

				dir = node1_direction|node2_direction
				if(dir==3) dir = 1
				else if(dir==12) dir = 4

			else
				icon_state = "exposed"//[invisibility ? "-f" : "" ]"
				alpha = invisibility ? 128 : 255

				if(node1)
					dir = get_dir(src, node1)

				else if(node2)
					dir = get_dir(src, node2)

				// Deletion should be added as part of constructable atmos
				//else
				//	qdel(src)

		initialize()
			var/connect_directions

			switch(dir)
				if(NORTH)
					connect_directions = NORTH|SOUTH
				if(SOUTH)
					connect_directions = NORTH|SOUTH
				if(EAST)
					connect_directions = EAST|WEST
				if(WEST)
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

			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			//UpdateIcon()

		disconnect(obj/machinery/atmospherics/reference)
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

			return null

	simple/insulated
		//icon = 'icons/obj/atmospherics/pipes/red_pipe.dmi'
		icon = 'icons/obj/atmospherics/pipes/color_pipe.dmi'
		icon_state = "intact"
		color = "#FF0000"
		minimum_temperature_difference = 10000
		thermal_conductivity = 0
		level = 2
		alpha = 255
		can_rupture = 1

		vertical
			dir = NORTH
		northeast
			dir = NORTHEAST
		horizontal
			dir = EAST
		southeast
			dir = SOUTHEAST
		southwest
			dir = SOUTHWEST
		northwest
			dir = NORTHWEST

		cold
			//icon = 'icons/obj/atmospherics/pipes/blue_pipe.dmi'
			color = "#017FFF"

			vertical
				dir = NORTH
			northeast
				dir = NORTHEAST
			horizontal
				dir = EAST
			southeast
				dir = SOUTHEAST
			southwest
				dir = SOUTHWEST
			northwest
				dir = NORTHWEST

	simple/junction
		icon = 'icons/obj/atmospherics/pipes/junction_pipe.dmi'
		icon_state = "intact"
		level = 2
		alpha = 255
		fatigue_pressure = INFINITY

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		update_icon()

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

	simple/heat_exchanging
		icon = 'icons/obj/atmospherics/pipes/heat_pipe.dmi'
		icon_state = "intact"
		level = 2
		alpha = 255

		minimum_temperature_difference = 20
		thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT
		fatigue_pressure = INFINITY

		vertical
			dir = NORTH
		horizontal
			dir = EAST
		northeast
			dir = NORTHEAST
		southeast
			dir = SOUTHEAST
		southwest
			dir = SOUTHWEST
		northwest
			dir = NORTHWEST

		update_icon()

			if(node1 && node2)
				icon_state = "intact"

				var/node1_direction = get_dir(src, node1)
				var/node2_direction = get_dir(src, node2)

				icon_state = "[node1_direction|node2_direction]"

	tank
		icon = 'icons/obj/atmospherics/tanks/grey_pipe_tank.dmi'
		icon_state = "intact"
		name = "Pressure Tank"
		desc = "A large vessel containing pressurized gas."
		volume = 1620 //in liters, 0.9 meters by 0.9 meters by 2 meters
		dir = SOUTH
		initialize_directions = SOUTH
		plane = PLANE_DEFAULT
		density = 1
		var/obj/machinery/atmospherics/node1

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		New()
			initialize_directions = dir
			..()

		process()
			..()
			if(!node1)
				parent.mingle_with_turf(loc, 200)

		carbon_dioxide
			name = "Pressure Tank (Carbon Dioxide)"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

			New()
				air_temporary = new /datum/gas_mixture
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.carbon_dioxide = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		toxins
			icon = 'icons/obj/atmospherics/tanks/orange_pipe_tank.dmi'
			name = "Pressure Tank (Plasma)"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

			New()
				air_temporary = new /datum/gas_mixture
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.toxins = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		oxygen_agent_b
			icon = 'icons/obj/atmospherics/tanks/red_orange_pipe_tank.dmi'
			name = "Pressure Tank (Oxygen + Plasma)"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

			New()
				air_temporary = new /datum/gas_mixture
				air_temporary.volume = volume
				air_temporary.temperature = T0C

				var/datum/gas/oxygen_agent_b/trace_gas = air_temporary.get_or_add_trace_gas_by_type(/datum/gas/oxygen_agent_b)
				trace_gas.moles = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		oxygen
			icon = 'icons/obj/atmospherics/tanks/blue_pipe_tank.dmi'
			name = "Pressure Tank (Oxygen)"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

			New()
				air_temporary = new /datum/gas_mixture
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.oxygen = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		nitrogen
			icon = 'icons/obj/atmospherics/tanks/red_pipe_tank.dmi'
			name = "Pressure Tank (Nitrogen)"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

			New()
				air_temporary = new /datum/gas_mixture
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.nitrogen = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		sleeping_agent
			icon = 'icons/obj/atmospherics/tanks/red_white_pipe_tank.dmi'
			name = "Pressure Tank (N2O)"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

			New()
				air_temporary = new /datum/gas_mixture
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				var/datum/gas/sleeping_agent/trace_gas = air_temporary.get_or_add_trace_gas_by_type(/datum/gas/sleeping_agent/)
				trace_gas.moles = (50*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		air
			icon = 'icons/obj/atmospherics/tanks/white_pipe_tank.dmi'
			name = "Pressure Tank (Air)"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

			New()
				air_temporary = new /datum/gas_mixture
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.oxygen = (50*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
				air_temporary.nitrogen = (50*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		// Experiment for improving the usefulness of air hookups. They have twice the capacity of portable
		// canisters and contain 4 times the volume of their default air mixture (Convair880).
		air_repressurization
			icon = 'icons/obj/atmospherics/tanks/whitered_pipe_tank.dmi'
			name = "High-Pressure Tank (Air)"
			desc = "Large vessel containing a pressurized air mixture for emergency purposes."
			volume = 2000

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

			New()
				air_temporary = new /datum/gas_mixture
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.oxygen = (180*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
				air_temporary.nitrogen = (180*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		disposing()
			node1?.disconnect(src)
			parent = null
			..()

		pipeline_expansion()
			return list(node1)

		update_icon()
			if(node1)
				icon_state = "intact"

				dir = get_dir(src, node1)

			else
				icon_state = "exposed"

		initialize()
			var/connect_direction = dir

			for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			UpdateIcon()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					if (parent)
						parent.dispose()
					parent = null
				node1 = null

			UpdateIcon()

			return null

	vent
		icon = 'icons/obj/atmospherics/pipe_vent.dmi'
		icon_state = "intact"
		name = "Vent"
		desc = "A large air vent"
		level = 1
		volume = 250
		dir = SOUTH
		initialize_directions = SOUTH
		var/obj/machinery/atmospherics/node1

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		New()
			initialize_directions = dir
			..()

		process()
			..()
			if(parent)
				parent.mingle_with_turf(loc, 250)

		disposing()
			node1?.disconnect(src)
			parent = null
			..()

		pipeline_expansion()
			return list(node1)

		update_icon()
			if(node1)
				icon_state = "intact"

				dir = get_dir(src, node1)

			else
				icon_state = "exposed"

		initialize()
			var/connect_direction = dir

			for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			UpdateIcon()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					if (parent)
						parent.dispose()
					parent = null
				node1 = null

			UpdateIcon()

			return null

		hide(var/i) //to make the little pipe section invisible, the icon changes.
			if(node1)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
				dir = get_dir(src, node1)
			else
				icon_state = "exposed"

	vertical_pipe
		icon = 'icons/obj/atmospherics/pipes/manifold_pipe.dmi'
		icon_state = "vertical"
		name = "Vertical Pipe"
		desc = "a section of piping dropping dropping into the floor"
		level = 1
		volume = 250
		dir = SOUTH
		initialize_directions = SOUTH
		var/obj/machinery/atmospherics/node1
		var/obj/machinery/atmospherics/node2

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		New()
			initialize_directions = dir
			..()

		process()
			..()

		disposing()
			node1?.disconnect(src)
			node2?.disconnect(src)
			parent = null
			..()

		pipeline_expansion()
			return list(node1, node2)

		initialize()
			var/turf/T = get_turf(src)
			var/connect_direction = dir

			for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			// Search disjoint connections for vertical pipe
			node2 = locate() in T.get_disjoint_objects_by_type(DISJOINT_TURF_CONNECTION_ATMOS_MACHINERY, /obj/machinery/atmospherics/pipe/vertical_pipe)
			UpdateIcon()

		disconnect(obj/machinery/atmospherics/reference)
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
			return null


	manifold
		icon = 'icons/obj/atmospherics/pipes/manifold_pipe.dmi'
		icon_state = "manifold"//-f"
		name = "pipe manifold"
		desc = "A manifold composed of regular pipes"
		level = 1
		volume = 105
		dir = SOUTH
		initialize_directions = EAST|NORTH|WEST
		var/obj/machinery/atmospherics/node1
		var/obj/machinery/atmospherics/node2
		var/obj/machinery/atmospherics/node3

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		overfloor
			level = 2

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		New()
			switch(dir)
				if(NORTH)
					initialize_directions = EAST|SOUTH|WEST
				if(SOUTH)
					initialize_directions = WEST|NORTH|EAST
				if(EAST)
					initialize_directions = SOUTH|WEST|NORTH
				if(WEST)
					initialize_directions = NORTH|EAST|SOUTH

			..()

		hide(var/i)
			if(level == 1 && istype(loc, /turf/simulated))
				invisibility = i ? INVIS_ALWAYS : INVIS_NONE
			UpdateIcon()

		pipeline_expansion()
			return list(node1, node2, node3)

		process()
			..()

			if(!node1)
				parent.mingle_with_turf(loc, 70)

			else if(!node2)
				parent.mingle_with_turf(loc, 70)

			else if(!node3)
				parent.mingle_with_turf(loc, 70)

		disposing()
			node1?.disconnect(src)
			node2?.disconnect(src)
			node3?.disconnect(src)
			parent = null
			..()

		disconnect(obj/machinery/atmospherics/reference)
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

		update_icon()
			if(node1 && node2&& node3)
				icon_state = "manifold"//[invisibility ? "-f" : ""]"
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

				if(!connected)
					qdel(src)

			return

		initialize()
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
			//UpdateIcon()
