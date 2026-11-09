/// Controller for misc. processing on areas
/// Areas will only process when active (player inside)
/// Calls [/area/proc/area_process], register your area to [TR_CAT_AREA_PROCESS]
/datum/controller/process/area_process
	schedule_jitter = 6 SECONDS

	setup()
		name = "Area Process"
		schedule_interval = 12 SECONDS

	doWork()
		for(var/area/A as anything in by_cat[TR_CAT_AREA_PROCESS])
			if (A.active) // Could register signals instead for the cat, but potentially would be more overhead than needless looping (quick mvmt.)
				last_object = "[A]"
				A.area_process()

/// Called by [/datum/controller/process/area_process].
/// Runs while area is active, every 6 to 18 SECONDS (uniformly distributed)
/area/proc/area_process()
	return
