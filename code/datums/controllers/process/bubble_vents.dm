/datum/controller/process/bubble_vents
	setup()
		name = "Bubble vents"
		schedule_interval = 3 SECONDS

	doWork()
		for_by_tcl(bubble_vent, /obj/bubble_vent)
			bubble_vent.process()
