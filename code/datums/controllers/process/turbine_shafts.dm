/datum/controller/process/turbine_shafts
	var/list/datum/shaft_network/networks = list()

	setup()
		name = "Turbine shafts"
		schedule_interval = 1 SECOND

	doWork()
		for_by_tcl(network, /datum/shaft_network)
			network.process()
