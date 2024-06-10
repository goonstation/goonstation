
/// handles random events
datum/controller/process/randomevents
	hang_warning_time = 5 MINUTES
	hang_alert_time = 5.5 MINUTES
	hang_restart_time = 6 MINUTES

	setup()
		name = "Random Events"
		schedule_interval = 2.5 MINUTES

	doWork()
		#ifndef NO_RANDOM_EVENTS
		random_events.process()
		#endif
