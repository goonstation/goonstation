/// handles obj/item/mechanics/process()
/datum/controller/process/mechanics
	/// The desired schedule time for standard devices
	var/standard_device_schedule_interval = 2.8 SECONDS
	/// Rounded number of ticks we must delay to sync our standard speed devices with the main loop
	var/standard_device_tick_delay

	setup()
		name = "Mechanics"
		schedule_interval = 0.4 SECONDS
		standard_device_tick_delay = max(round(standard_device_schedule_interval / schedule_interval), 1)

	doWork()
		var/c
		for(var/obj/item/mechanics/target in global.processing_mechanics)
			if (QDELETED(target))
				global.processing_mechanics -= target
				continue
			if(target.process_fast == TRUE)
				target.process()
			else if(!(src.ticks % standard_device_tick_delay))
				target.process()
			if (!(c++ % 20))
				scheck()

