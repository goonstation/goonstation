datum/controller/process/chemistry

	setup()
		name = "Chemistry"
		schedule_interval = 10

	doWork()
		for(var/datum/d in active_reagent_holders)
			d:process_reactions()
			scheck()
