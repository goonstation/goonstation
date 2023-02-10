
/// Handles sending ghost notifications to players
/datum/controller/process/ghost_notifications
	var/datum/ghost_notification_controller/notifier

	setup()
		name = "Ghost Notifications"
		schedule_interval = 5 SECONDS // it really does not need to update that often
		notifier = ghost_notifier

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/ghost_notifications/old_ghost_notifications = target
		src.notifier = old_ghost_notifications.notifier

	doWork()
		notifier.process()
