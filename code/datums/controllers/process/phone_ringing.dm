/// Handles phone ringer components' ringing
/datum/controller/process/phone_ringing

	setup()
		name = "Phone Ringing Process"
		schedule_interval = 5 SECONDS

	doWork()
		SEND_SIGNAL(src, COMSIG_PHONE_RING_TICK)
