// handles timed player actions
datum/controller/process/actions
	var/action_controller

	setup()
		name = "Actions"
		schedule_interval = 5

		action_controller = actions

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/actions/old_actions = target
		src.action_controller = old_actions.action_controller

	doWork()
		actions.process()
