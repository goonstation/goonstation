
/// handles air processing.
/datum/controller/process/air_system

	setup()
		name = "Atmos"
		schedule_interval = 1 SECOND

		if(!air_master)
			air_master = new /datum/controller/air_system()
			air_master.setup(src)
		air_master.parent_controller = src

	doWork()
		air_master.process()

	copyStateFrom(datum/controller/process/target)
		air_master.parent_controller = src
