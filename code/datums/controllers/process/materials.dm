/datum/controller/process/materials
	var/tmp/list/atom/processing_targets

	setup()
		name = "Materials"
		schedule_interval = 5 SECONDS

	doWork()
		return
