// handles telescope signals and whatnot
datum/controller/process/telescope
	var/datum/telescope_manager/manager

	setup()
		name = "Telescope"
		schedule_interval = 100

	doWork()
		if(tele_man)
			if(!manager) manager = tele_man
			tele_man.tick()
