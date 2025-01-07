/// handles obj/item/mechanics/process()
/datum/controller/process/mechanics

		schedule_interval = 0.4 SECONDS
			else if(!(src.ticks % 7)) //Target schedule time is 2.8 seconds (was 2.9)
				target.process()
			if (!(c++ % 20))
				scheck()

