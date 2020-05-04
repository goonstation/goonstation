datum/controller/process/respawn

	setup()
		name = "Respawn Controller"
		schedule_interval = 600	// Since we will be operating on a longer time-scale, processing once per minute seems enough

	doWork()
		if (respawn_controller)
			respawn_controller.process()
//renamed this from ..../process/ghost_notifications to ..../process/respawn so it wont conflict with the other process - moon
//what does this do? i got no clue. keeping it in. better be safe then sorry - moon