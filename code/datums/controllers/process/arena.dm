datum/controller/process/arena
	var/list/arenas = list()

	setup()
		name = "Arena"
		schedule_interval = 8 // 0.8 seconds

		arenas += gauntlet_controller
		arenas += colosseum_controller

	doWork()
		for (var/datum/arena/A in arenas)
			A.tick()
