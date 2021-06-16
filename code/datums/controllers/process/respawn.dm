datum/controller/process/respawn //WHY IN GODS NAME WAS THIS NAMED ..../ghost_notifications. NO WONDER THEY WERE BROKEN

	setup()
		name = "Respawn Controller"
		schedule_interval = 600	// Since we will be operating on a longer time-scale, processing once per minute seems enough

	doWork()
		if (respawn_controller)
			respawn_controller.process()
