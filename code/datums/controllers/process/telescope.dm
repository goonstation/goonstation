
/// handles telescope signals and whatnot
/datum/controller/process/telescope
	var/datum/telescope_manager/manager

	setup()
		name = "Telescope"
		schedule_interval = 10 SECONDS

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/telescope/old_telescope = target
		src.manager = old_telescope.manager

	doWork()
		if(tele_man)
			if(!manager) manager = tele_man
			tele_man.tick()
