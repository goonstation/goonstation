/datum/controller/process/events
	setup()
		name = "Event Recording"
		schedule_interval = 1 MINUTE

	doWork()
		eventRecorder.process()
