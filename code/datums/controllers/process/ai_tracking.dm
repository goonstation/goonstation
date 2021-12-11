
/// Handles the AI camera tracking players
/datum/controller/process/ai_tracking

	setup()
		name = "AI Tracking"
		schedule_interval = 1 SECOND

	doWork()
		for(var/datum/ai_camera_tracker/T in global.tracking_list)
			T.process()

			scheck()
