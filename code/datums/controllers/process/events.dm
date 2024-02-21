/datum/controller/process/event_recorder
	setup()
		name = "Event Recording"
		schedule_interval = 1 MINUTE

	doWork()
		eventRecorder.process()
