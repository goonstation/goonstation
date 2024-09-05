/datum/controller/process/event_recorder
	setup()
		name = "Event Recording"
		schedule_interval = 30 SECONDS

	doWork()
		eventRecorder.process()
