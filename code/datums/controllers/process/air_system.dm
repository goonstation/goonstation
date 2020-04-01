
// handles air processing.
datum/controller/process/air_system

	setup()
		name = "Atmos"
		schedule_interval = 20 // 2 seconds

		if(!air_master)
			air_master = new /datum/controller/air_system()
			air_master.setup(src)
		air_master.set_controller(src)

	doWork()
		air_master.process()

	copyStateFrom(var/datum/controller/process/target)
		air_master.set_controller(src)
