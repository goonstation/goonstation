/// Controller for misc. processing on areas
/// Areas will only process when active (player inside)
/// Calls [/area/proc/area_process], register your area to [TR_CAT_AREA_PROCESS]
/datum/controller/process/area_process
	setup()
		name = "Area Process"
		schedule_interval = 12 SECONDS
		schedule_jitter = 6 SECONDS

	doWork()
		for(var/area/A as anything in by_cat[TR_CAT_AREA_PROCESS])
			if (A.active) // Could register signals instead for the cat, but potentially would be more overhead than needless looping (quick mvmt.)
				last_object = "[A]"
				A.area_process()

/// Called by [/datum/controller/process/area_process].
/// Runs while area is active, every (gaussian distrib. centered on 12 from 6 to 18) SECONDS
/area/proc/area_process()
	return
