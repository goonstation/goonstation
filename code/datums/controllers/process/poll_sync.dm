#define POLL_SYNC_PROCESS_SCHEDULE_INTERVAL 1 MINUTE

/// Syncs poll data with API every minute
/datum/controller/process/poll_sync
	setup()
		name = "Poll Sync"
		schedule_interval = POLL_SYNC_PROCESS_SCHEDULE_INTERVAL

		// initial pregame sync
		poll_manager.sync_polldata()
	doWork()
		poll_manager.sync_polldata()
