
/// Controls the respawn controller
datum/controller/process/respawn

	setup()
		name = "Respawn Controller"
		schedule_interval = 1 MINUTE	// Since we will be operating on a longer time-scale, processing once per minute seems enough

	doWork()
		if (respawn_controller)
			respawn_controller.process()
