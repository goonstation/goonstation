/datum/controller/process/camera_coverage_all

/datum/controller/process/camera_coverage_all/setup()
	name = "Camera Coverage - All Emitters"
	schedule_interval = CAM_PROCESS_ALL_INTERVAL

/datum/controller/process/camera_coverage_all/doWork()
	camera_coverage_controller.update_all_emitters()
