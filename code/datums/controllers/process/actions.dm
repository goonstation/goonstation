
/// handles timed player actions
/datum/controller/process/actions
	var/datum/controller/process/actions/action_controller

	setup()
		name = "Actions"
		schedule_interval = ACTION_CONTROLLER_INTERVAL

		action_controller = actions

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/actions/old_actions = target
		src.action_controller = old_actions.action_controller

	doWork()
		action_controller.process()
