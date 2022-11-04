//#define DEBUG

datum/air_group/var/marker
datum/air_group/var/debugging = 0
datum/pipe_network/var/marker

datum/gas_mixture
	var/turf/parent
	var/debugging

/*
turf/simulated
	New()
		..()

		if(air)
			air.parent = src
*/
obj/machinery/door
	verb
		toggle_door()
			set src in world
			if(density)
				open()
			else
				close()

turf/space
	verb
		create_floor()
			set src in world
			new /turf/simulated/floor(src)

		create_meteor(direction as num)
			set src in world

			var/obj/newmeteor/M = new( src )
			walk(M, direction,10)


turf/simulated/wall
	verb
		create_floor()
			set src in world
			new /turf/simulated/floor(src)

obj/item/tank
	verb
		adjust_mixture(temperature as num, target_toxin_pressure as num, target_oxygen_pressure as num)
			set src in world
			if(!air_contents)
				boutput(usr, "<span class='alert'>ERROR: no gas_mixture associated with this tank</span>")
				return null

			air_contents.temperature = temperature
			air_contents.oxygen = target_oxygen_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
			air_contents.toxins = target_toxin_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

turf/simulated/floor
	verb
		parent_info()
			set src in world
			if(parent)
				boutput(usr, "<B>[x],[y] parent:</B> Processing: [parent.group_processing]")
				if(parent.members)
					boutput(usr, "Members: [parent.members.len]")
				else
					boutput(usr, "Members: None?")
				if(parent.borders)
					boutput(usr, "Borders: [parent.borders.len]")
				else
					boutput(usr, "Borders: None")
				if(parent.length_space_border)
					boutput(usr, "Space Borders: [parent.space_borders.len], Space Length: [parent.length_space_border]")
				else
					boutput(usr, "Space Borders: None")
			else
				boutput(usr, "<span class='notice'>[x],[y] has no parent air group.</span>")

	verb
		create_wall()
			set src in world
			new /turf/simulated/wall(src)
	verb
		adjust_mixture(temp as num, tox as num, oxy as num)
			set src in world
			var/datum/gas_mixture/stuff = return_air()
			stuff.temperature = temp
			stuff.toxins = tox
			stuff.oxygen = oxy

	verb
		boom(inner_range as num, middle_range as num, outer_range as num)
			set src in world
			explosion(src,src,inner_range,middle_range,outer_range,outer_range)

	verb
		flag_parent()
			set src in world
			if(parent)
				parent.debugging = !parent.debugging
				parent.air.debugging = parent.debugging
				boutput(usr, "[parent.members.len] set to [parent.debugging]")
	verb
		small_explosion()
			set src in world
			explosion(src, src, 1, 2, 3, 3)

	verb
		large_explosion()
			set src in world
			explosion(src, src, 3, 5, 7, 5)

obj/machinery/portable_atmospherics/canister
	verb/test_release()
		set src in world
		set category = "Minor"

		valve_open = 1
		release_pressure = 1000

obj/machinery/atmospherics
	unary
		heat_reservoir
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					UpdateIcon()
				adjust_temp(temp as num)
					set src in world
					set category = "Minor"

					current_temperature = temp
		cold_sink
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					UpdateIcon()
				adjust_temp(temp as num)
					set src in world
					set category = "Minor"

					current_temperature = temp
		vent_pump
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					UpdateIcon()

				toggle_direction()
					set src in world
					set category = "Minor"

					pump_direction = !pump_direction

					UpdateIcon()

				change_pressure_parameters()
					set src in world
					set category = "Minor"

					boutput(usr, "current settings: PC=[pressure_checks], EB=[external_pressure_bound], IB=[internal_pressure_bound]")

					var/mode = input(usr, "Select an option:") in list("Bound External", "Bound Internal", "Bound Both")

					switch(mode)
						if("Bound External")
							pressure_checks = 1
							external_pressure_bound = input(usr, "External Pressure Bound?") as num
						if("Bound Internal")
							pressure_checks = 2
							internal_pressure_bound = input(usr, "Internal Pressure Bound?") as num
						else
							pressure_checks = 3
							external_pressure_bound = input(usr, "External Pressure Bound?") as num
							internal_pressure_bound = input(usr, "Internal Pressure Bound?") as num

		outlet_injector
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					UpdateIcon()
			verb
				trigger_inject()
					set src in world
					set category = "Minor"

					inject()

		vent_scrubber
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					UpdateIcon()

				toggle_scrubbing()
					set src in world
					set category = "Minor"

					scrubbing = !scrubbing

					UpdateIcon()

				change_rate(amount as num)
					set src in world
					set category = "Minor"

					volume_rate = amount

	mixer
		verb
			toggle()
				set src in world
				set category = "Minor"

				on = !on

				UpdateIcon()

			change_pressure(amount as num)
				set src in world
				set category = "Minor"

				target_pressure = amount

			change_ratios()
				set src in world
				set category = "Minor"

				if(node_in1)
					var/node_ratio = input(usr, "Node 1 Ratio? ([dir2text(get_dir(src, node_in1))])") as num
					node_ratio = clamp(node_ratio, 0, 1)

					node1_concentration = node_ratio
					node2_concentration = 1-node_ratio
				else
					node2_concentration = 1
					node1_concentration = 0

				boutput(usr, "Node 1: [node1_concentration], Node 2: [node2_concentration]")


	filter
		verb
			toggle()
				set src in world
				set category = "Minor"

				on = !on

				UpdateIcon()

			change_pressure(amount as num)
				set src in world
				set category = "Minor"

				target_pressure = amount

	binary/pump
		verb
			DEBUG_MESSAGE()
				set src in world
				set category = "Minor"

				boutput(world, "Debugging: [x],[y]")

				if(node1)
					boutput(world, "Input node: [node1.x],[node1.y] [network1]")
				if(node2)
					boutput(world, "Output node: [node2.x],[node2.y] [network2]")

			toggle()
				set src in world
				set category = "Minor"

				on = !on

				UpdateIcon()
			change_pressure(amount as num)
				set src in world
				set category = "Minor"

				target_pressure = amount

	valve
		verb
			toggle()
				set src in world
				set category = "Minor"

				if(open)
					close()
				else
					open()
			network_data()
				set src in world
				set category = "Minor"

				boutput(world, "<span class='notice'>[x],[y]</span>")
				boutput(world, "network 1: [network_node1.normal_members.len], [network_node1.line_members.len]")
				for(var/obj/O in network_node1.normal_members)
					boutput(world, "member: [O.x], [O.y]")
				boutput(world, "network 2: [network_node2.normal_members.len], [network_node2.line_members.len]")
				for(var/obj/O in network_node2.normal_members)
					boutput(world, "member: [O.x], [O.y]")
	pipe
		verb
			destroy()
				set src in world
				set category = "Minor"

				qdel(src)

			pipeline_data()
				set src in world
				set category = "Minor"

				if(parent)
					boutput(usr, "[x],[y] is in a pipeline with [parent.members.len] members ([parent.edges.len] edges)! Volume: [parent.air.volume]")
					boutput(usr, "Pressure: [MIXTURE_PRESSURE(parent.air)], Temperature: [parent.air.temperature]")
					boutput(usr, "[MOLES_REPORT(parent.air)] .. [parent.alert_pressure]")
mob
	verb
		flag_all_pipe_networks()
			set category = "Debug"

			for(var/datum/pipe_network/network in pipe_networks)
				network.update = 1

		mark_pipe_networks()
			set category = "Debug"

			for(var/datum/pipe_network/network in pipe_networks)
				network.marker = rand(1,4)

			for(var/obj/machinery/atmospherics/pipe/P in atmos_machines)
				P.overlays = null

				var/datum/pipe_network/master = P.return_network()
				if(master)
					P.overlays += icon('icons/Testing/atmos_testing.dmi',"marker[master.marker]")
				else
					boutput(world, "error")
					P.overlays += icon('icons/Testing/atmos_testing.dmi',"marker0")

			for(var/obj/machinery/atmospherics/valve/V in atmos_machines)
				V.overlays = null

				if(V.network_node1)
					V.overlays += icon('icons/Testing/atmos_testing.dmi',"marker[V.network_node1.marker]")
				else
					V.overlays += icon('icons/Testing/atmos_testing.dmi',"marker0")

				if(V.network_node2)
					V.overlays += icon('icons/Testing/atmos_testing.dmi',"marker[V.network_node2.marker]")
				else
					V.overlays += icon('icons/Testing/atmos_testing.dmi',"marker0")

turf/simulated
	var/fire_verbose = 0

	verb
		mark_direction()
			set src in world
			overlays = null
			for(var/direction in cardinal)
				if(group_border&direction)
					overlays += icon('icons/Testing/turf_analysis.dmi',"red_arrow",direction)
				else if(air_check_directions&direction)
					overlays += icon('icons/Testing/turf_analysis.dmi',"arrow",direction)
		air_status()
			set src in world
			set category = "Minor"
			var/datum/gas_mixture/GM = return_air()
			boutput(usr, "<span class='notice'>@[x],[y] ([GM.group_multiplier])<br>[MOLES_REPORT(GM)] w [GM.temperature] Kelvin, [MIXTURE_PRESSURE(GM)] kPa [(active_hotspot)?("<span class='alert'>BURNING</span>"):(null)]")
			if(length(GM.trace_gases))
				for(var/datum/gas/trace_gas as anything in GM.trace_gases)
					boutput(usr, "[trace_gas.type]: [trace_gas.moles]")

		force_temperature(temp as num)
			set src in world
			set category = "Minor"
			if(parent?.group_processing)
				parent.suspend_group_processing()

			air.temperature = temp

		spark_temperature(temp as num, volume as num)
			set src in world
			set category = "Minor"

			hotspot_expose(temp, volume)

		fire_verbose()
			set src in world
			set category = "Minor"

			fire_verbose = !fire_verbose
			boutput(usr, "[x],[y] now [fire_verbose]")

		add_sleeping_agent(amount as num)
			set src in world
			set category = "Minor"

			if(amount>1)
				var/datum/gas_mixture/adding = new /datum/gas_mixture
				var/datum/gas/sleeping_agent/trace_gas = adding.get_or_add_trace_gas_by_type(var/datum/gas/sleeping_agent)

				trace_gas.moles = amount
				adding.temperature = T20C

				assume_air(adding)

obj/indicator
	icon = 'icons/air_meter.dmi'
	var/measure = "temperature"
	anchored = 1

	proc/process()
		icon_state = measurement()

	proc/measurement()
		var/turf/T = loc
		if(!isturf(T)) return
		var/datum/gas_mixture/GM = T.return_air()
		switch(measure)
			if("temperature")
				if(GM.temperature < 0)
					return "error"
				return "[round(GM.temperature/100+0.5)]"
			if("oxygen")
				if(GM.oxygen < 0)
					return "error"
				return "[round(GM.oxygen/MOLES_CELLSTANDARD*10+0.5)]"
			if("plasma")
				if(GM.toxins < 0)
					return "error"
				return "[round(GM.toxins/MOLES_CELLSTANDARD*10+0.5)]"
			if("nitrogen")
				if(GM.nitrogen < 0)
					return "error"
				return "[round(GM.nitrogen/MOLES_CELLSTANDARD*10+0.5)]"
			else
				return "[round((TOTAL_MOLES(GM))/MOLES_CELLSTANDARD*10+0.5)]"


	Click()
		process()

obj/window
	verb
		destroy()
			set category = "Minor"
			set src in world
			qdel(src)

mob
	sight = SEE_OBJS|SEE_TURFS

	verb
		update_indicators()
			set category = "Debug"
			if(!air_master)
				boutput(usr, "Cannot find air_system")
				return

			for(var/obj/indicator/T in world)
				T.process()
		change_indicators()
			set category = "Debug"
			if(!air_master)
				boutput(usr, "Cannot find air_system")
				return

			var/str = input("Select") in list("oxygen", "nitrogen","plasma","all","temperature")

			for(var/obj/indicator/T in world)
				T.measure = str
				T.process()

		fire_report()
			set category = "Debug"
			boutput(usr, "<span class='alert'><b>Fire Report</b></span>")
			for(var/obj/hotspot/flame in world)
				boutput(usr, "[flame.x],[flame.y]: [flame.temperature]K, [flame.volume] L - [flame.loc:air:temperature]")

		process_cycle()
			set category = "Debug"
			if(!processScheduler)
				boutput(usr, "Cannot find processScheduler")
				return

			boutput(usr, "Sorry, this needs to be rebuilt! Yell at Dr. Singh.")


		process_cycles(amount as num)
			set category = "Debug"
			if(!processScheduler)
				boutput(usr, "Cannot find processScheduler")
				return

			boutput(usr, "Sorry, this needs to be rebuilt! Yell at Dr. Singh.")


		process_updates_early()
			set category = "Debug"
			if(!air_master)
				boutput(usr, "Cannot find air_system")
				return

			air_master.process_update_tiles()
			air_master.process_rebuild_select_groups()

		mark_groups()
			set category = "Debug"
			if(!air_master)
				boutput(usr, "Cannot find air_system")
				return

			for(var/datum/air_group/group in air_master.air_groups)
				group.marker = 0

			for(var/turf/simulated/floor/S in world)
				S.icon = 'icons/Testing/turf_analysis.dmi'
				if(S.parent)
					if(S.parent.group_processing)
						if(S.parent.marker == 0)
							S.parent.marker = rand(1,5)
						if(S.parent.borders && S.parent.borders.Find(S))
							S.icon_state = "on[S.parent.marker]_border"
						else
							S.icon_state = "on[S.parent.marker]"

					else
						S.icon_state = "suspended"
				else
					if(S.processing)
						S.icon_state = "individual_on"
					else
						S.icon_state = "individual_off"

		get_broken_icons()
			set category = "Debug"
			getbrokeninhands()

