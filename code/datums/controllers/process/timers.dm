///NB: this is just for the item timers used to make pipebombs etc.
///did u know timers have been horribly inaccurate at short durations all this time? well no more!!
/datum/controller/process/timers
	setup()
		name = "Timers"
		schedule_interval = 1 SECOND

	doWork()
		for (var/obj/item/device/timer/timer as anything in by_cat[TR_CAT_TIMING_TIMERS])
			timer.process()
