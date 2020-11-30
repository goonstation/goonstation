// handles timed player actions
datum/controller/process/actions
	var/action_controller

	setup()
		name = "Actions"
		schedule_interval = 5

		action_controller = actions

	doWork()
		actions.process()
