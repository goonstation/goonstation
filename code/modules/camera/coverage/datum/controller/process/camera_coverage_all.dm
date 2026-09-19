/datum/controller/process/camera_coverage_all

/datum/controller/process/camera_coverage_all/setup()
	name = "Camera Coverage - All Emitters"
	schedule_interval = CAM_PROCESS_ALL_INTERVAL
	// This is just to catch opaque stuff getting built, not a huge priority.
	tick_allowance = 1

/datum/controller/process/camera_coverage_all/doWork()
	for (var/datum/component/camera_coverage_emitter/emitter as anything in by_type[/datum/component/camera_coverage_emitter]?.Copy())
		camera_coverage_controller.update_emitter(emitter)
		scheck()
