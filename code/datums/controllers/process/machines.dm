
/// handles machines processing
/datum/controller/process/machines
	var/tmp/list/list/list/machines
	var/tmp/list/pipe_networks
	var/tmp/list/powernets
	var/tmp/list/atmos_machines
	var/tmp/ticker = 0
	var/mult

	setup()
		name = "Machine"
		schedule_interval = MACHINE_PROC_INTERVAL

		Station_VNet = new /datum/v_space/v_space_network()

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/machines/old_machines = target
		src.machines = old_machines.machines
		src.pipe_networks = old_machines.pipe_networks
		src.powernets = old_machines.powernets
		src.atmos_machines = old_machines.atmos_machines
		src.ticker = old_machines.ticker
		src.mult = old_machines.mult

	proc/d_print()
		for(var/obj/machinery/machine in src.machines)
			boutput(world,SPAN_ADMIN("[machine.name] : [machine.type]"))

	doWork()
		var/c = 0

		if (ticker % 4 == 0)
			src.atmos_machines = by_cat[TR_CAT_ATMOS_MACHINES]
			for (var/obj/machinery/machine as anything in atmos_machines)
				if( !machine || machine.z == 4 && !Z4_ACTIVE || istype(machine.loc, /obj/item/electronics/frame) ) continue
	#ifdef MACHINE_PROCESSING_DEBUG
				var/t = world.time
	#endif
				src.setLastTask("atmos machines", machine)
				machine.ProcessMachine()
	#ifdef MACHINE_PROCESSING_DEBUG
				register_machine_time(machine, world.time - t)
	#endif

				if (!(c++ % 100))
					scheck()
		if (ticker % 4 == 1)
			src.pipe_networks = global.pipe_networks
			for(var/X in src.pipe_networks)
				if(!X) continue
				var/datum/pipe_network/network = X
	#ifdef MACHINE_PROCESSING_DEBUG
				var/t = world.time
	#endif
				src.setLastTask("pipe network", network)
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
				src.setLastTask("powernets", PN)
				PN.reset()
	#ifdef MACHINE_PROCESSING_DEBUG
				register_machine_time(PN, world.time - t)

				if(length(detailed_power_data.areas))
					detailed_power_data_last = detailed_power_data
					detailed_power_data = new
	#endif
				if (!(c++ % 100))
					scheck()

		src.machines = global.processing_machines

		for (var/i in 1 to PROCESSING_MAX_IN_USE)
			for(var/obj/machinery/machine as anything in src.machines[i][(src.ticker % (1<<(i-1)))+1])
				if(!machine) continue
				if(istype(machine.loc, /obj/item/electronics/frame)) continue /* machine.z == 4 && !Z4_ACTIVE || */
				#ifdef MACHINE_PROCESSING_DEBUG
				var/t = world.time
				#endif
				var/pr_base_spacing = machine.base_tick_spacing*(1 << (machine.processing_tier-1))	// The ideal time a machine in any given tier should take
				#define pr_max_spacing machine.cap_base_tick_spacing*(1 << (machine.processing_tier-1))	// The most time we're willing to give it
				#define pr_mult clamp(TIME - machine.last_process, pr_base_spacing, pr_max_spacing) / pr_base_spacing	// (time it took between processes) / (time it should've taken) = (do certain things this much more)
				SET_LAST_TASK("general machines", machine)
				machine.ProcessMachine(pr_mult)	// Passes the mult as an arg of process(), so it can be accessible by ~any~ machine! Even Guardbots!
				#undef pr_max_spacing
				#undef pr_mult
				machine.last_process = TIME	// set the last time the machine processed to now, so we can compare it next loop
				#ifdef MACHINE_PROCESSING_DEBUG
				register_machine_time(machine, world.time - t)
				#endif
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

/datum/machine_power_data
	var/list/area/areas
	var/list/obj/machinery/machines

	New()
		. = ..()
		areas = list()
		machines = list()

	proc/add_machinery(machine)
		var/area/A = get_area(machine)
		if(isnull(areas[A]))
			areas[A] = list()
		areas[A] += machine
		machines[machine] = 0

	proc/log_machine(obj/machinery/machine, amount)
		if(detailed_machine_power_log_zlevels & (1<<machine.z))
			if(isnull(machines[machine]))
				add_machinery(machine)
			machines[machine]+=amount

#endif
