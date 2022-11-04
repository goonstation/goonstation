
#ifdef MAP_OVERRIDE_OSHAN
/// Controls sea hotspots and their movement
/datum/controller/process/sea_hotspot_update
	var/tmp/datum/hotspot_controller/controller

	setup()
		name = "Sea Hotspot Process"
		schedule_interval = 1 MINUTE // important : this controls the speed of drift for every hotspot!
		controller = global.hotspot_controller

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/sea_hotspot_update/old_sea_hotspot_update = target
		src.controller = old_sea_hotspot_update.controller

	doWork()
		if (controller)
			if (map_currently_underwater)
				controller.process()
			else
				controller = 0
				global.hotspot_controller.clear()
#endif
