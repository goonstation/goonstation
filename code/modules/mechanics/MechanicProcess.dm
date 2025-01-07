/// handles obj/item/mechanics/process()
/datum/controller/process/mechanics
	setup()
		name = "Mechanics"
		schedule_interval = 0.4 SECONDS

	doWork()
		var/c
		for(var/obj/item/mechanics/target in global.processing_mechanics)
			if (QDELETED(target))
				global.processing_mechanics -= target
				continue
			if(target.process_fast == TRUE)
				target.process()
			else if(!(src.ticks % 7)) //Target schedule time is 2.8 seconds (was 2.9)
				target.process()
			if (!(c++ % 20))
				scheck()

