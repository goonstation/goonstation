/datum/controller/process/camera_coverage_turf_queue

/datum/controller/process/camera_coverage_turf_queue/setup()
	name = "Camera Coverage - Queue Turfs"
	schedule_interval = CAM_PROCESS_QUEUE_TURF_INTERVAL

/datum/controller/process/camera_coverage_turf_queue/doWork()
	var/list/queue = camera_coverage_controller.turf_update_queue?.Copy()
	if (islist(queue))
		camera_coverage_controller.turf_update_queue = null
		camera_coverage_controller.update_turfs(queue)
