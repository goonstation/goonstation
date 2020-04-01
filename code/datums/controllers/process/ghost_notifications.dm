datum/controller/process/ghost_notifications
	var/datum/ghost_notification_controller/notifier

	setup()
		name = "Ghost Notifications"
		schedule_interval = 30 // it really does not need to update that often
		notifier = ghost_notifier
			

	doWork()
		notifier.process()
