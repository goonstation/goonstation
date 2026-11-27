
/// handles random events
datum/controller/process/randomevents
	schedule_jitter = 5 SECONDS
	hang_warning_time = 5 MINUTES
	hang_alert_time = 5.5 MINUTES
	hang_restart_time = 6 MINUTES

	setup()
		name = "Random Events"
		schedule_interval = 30 SECONDS // we don't have events this often, but we don't want them clumping up

	doWork()
		#ifndef NO_RANDOM_EVENTS
		random_events.process()
		#endif
