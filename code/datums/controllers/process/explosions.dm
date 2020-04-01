// handles timed player actions
datum/controller/process/explosions
	var/datum/explosion_controller/explosion_controller

	setup()
		name = "Explosions"
		schedule_interval = 5

		explosion_controller = explosions

	doWork()
		explosion_controller.process() //somehow runtimes null.process(), why the fuck is explosion controller gone???
