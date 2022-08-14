/datum/controller/process/camera_coverage_queue

/datum/controller/process/camera_coverage_queue/setup()
	name = "Camera Coverage - Queue"
	schedule_interval = CAM_PROCESS_QUEUE_INTERVAL

/datum/controller/process/camera_coverage_queue/doWork()
	boutput(world, "camera_coverage_queue/doWork() - [length(camera_coverage_controller.update_queue)]")
	camera_coverage_controller.update_emitters(camera_coverage_controller.update_queue)
	camera_coverage_controller.update_queue = null
