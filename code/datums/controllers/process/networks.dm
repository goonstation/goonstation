datum/controller/process/networks

	setup()
		name = "Networks"
		schedule_interval = 11

	doWork()
		for(var/datum/n in node_networks)
			n:update()
			scheck()
		/*
		var/currentTick = ticks
		for (var/datum/node_network/network in node_networks)
			network.update()
			scheck(currentTick)*/
