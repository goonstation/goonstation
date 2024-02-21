/datum/controller/process/camera_coverage_emitter_queue

/datum/controller/process/camera_coverage_emitter_queue/setup()
	name = "Camera Coverage - Queue Emitters"
	schedule_interval = CAM_PROCESS_QUEUE_INTERVAL

/datum/controller/process/camera_coverage_emitter_queue/doWork()
	var/list/queue = camera_coverage_controller.emitter_update_queue?.Copy()
	if (islist(queue))
		camera_coverage_controller.emitter_update_queue = null
		camera_coverage_controller.update_emitters(queue)
