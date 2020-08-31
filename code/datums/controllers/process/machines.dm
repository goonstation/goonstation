// handles machines
datum/controller/process/machines
	var/tmp/list/machines
	var/tmp/list/pipe_networks
	var/tmp/list/powernets
	var/tmp/list/atmos_machines
	var/tmp/ticker = 0
	var/mult

	setup()
		name = "Machine"
		schedule_interval = 4

		Station_VNet = new /datum/v_space/v_space_network()

	proc/d_print()
		for(var/obj/machinery/machine in src.machines)
			boutput(world,"[machine.name] : [machine.type]")

	doWork()
		var/c = 0

		if (ticker % 8 == 0)
			src.atmos_machines = global.atmos_machines
			for(var/X in atmos_machines)
				var/obj/machinery/machine = X
				if( !machine || machine.z == 4 && !Z4_ACTIVE ) continue
	#ifdef MACHINE_PROCESSING_DEBUG
				var/t = world.time
	#endif
				machine.process()
	#ifdef MACHINE_PROCESSING_DEBUG
				register_machine_time(machine, world.time - t)
	#endif

				if (!(c++ % 100))
					scheck()
		if (ticker % 8 == 1)
			src.pipe_networks = global.pipe_networks
			for(var/X in src.pipe_networks)
				if(!X) continue
				var/datum/pipe_network/network = X
	#ifdef MACHINE_PROCESSING_DEBUG
				var/t = world.time
	#endif
				network.process()
	#ifdef MACHINE_PROCESSING_DEBUG
				register_machine_time(network, world.time - t)
	#endif
				if (!(c++ % 100))
					scheck()

		if (ticker % 8 == 2)
			src.powernets = global.powernets
			for(var/X in src.powernets)
				if(!X) continue
				var/datum/powernet/PN = X
	#ifdef MACHINE_PROCESSING_DEBUG
				var/t = world.time
	#endif
				PN.reset()
	#ifdef MACHINE_PROCESSING_DEBUG
				register_machine_time(PN, world.time - t)
	#endif
				if (!(c++ % 100))
					scheck()

		src.machines = global.processing_machines

		for (var/i in 1 to PROCESSING_MAX_IN_USE)
			var/list/machlist = src.machines[i]

			for(var/X in machlist[(src.ticker % (1<<(i-1)))+1])
				if(!X) continue
				var/obj/machinery/machine = X
				if( machine.z == 4 && !Z4_ACTIVE ) continue
		#ifdef MACHINE_PROCESSING_DEBUG
				var/t = world.time
		#endif
				var/base_spacing = machine.base_tick_spacing*(2**(machine.processing_tier-1))	// The ideal time a machine in any given tier should take
				var/max_spacing = machine.cap_base_tick_spacing*(2**(machine.processing_tier-1))	// The most time we're willing to give it
				mult = clamp(TIME - machine.last_process, base_spacing, max_spacing) / base_spacing	// (time it took between processes) / (time it should've taken) = (do certain things this much more)
				machine.process(mult)	// Passes the mult as an arg of process(), so it can be accessible by ~any~ machine! Even Guardbots!
				machine.last_process = TIME	// set the last time the machine processed to now, so we can compare it next loop
		#ifdef MACHINE_PROCESSING_DEBUG
				register_machine_time(machine, world.time - t)
		#endif
				if (!(c++ % 100))
					scheck()
		src.ticker++

#ifdef MACHINE_PROCESSING_DEBUG
proc/register_machine_time(var/datum/machine, var/time)
	if(!machine) return
	var/list/mtl = detailed_machine_timings[machine.type]
	if(!mtl)
		mtl = list()
		mtl.len = 2
		mtl[1] = 0	//The amount of time spent processing this machine in total
		mtl[2] = 0	//The amount of times this machine has been processed
		detailed_machine_timings[machine.type] = mtl

	mtl[1] += time
	mtl[2]++


#endif
