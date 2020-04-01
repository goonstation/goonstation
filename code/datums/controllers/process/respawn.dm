datum/controller/process/ghost_notifications

	setup()
		name = "Respawn Controller"
		schedule_interval = 600	// Since we will be operating on a longer time-scale, processing once per minute seems enough

	doWork()
		if (respawn_controller)
			respawn_controller.process()
