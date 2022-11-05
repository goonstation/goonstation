var/global/datum/tutorial/manager/tutorial_manager

/// Handles running the player tutorial
/datum/controller/process/tutorial
	setup()
		name = "Tutorial"
		schedule_interval = 1.5 SECONDS
		tutorial_manager = new

	doWork()
		if (tutorial_manager)
			tutorial_manager.process()
