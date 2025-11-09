/datum/controller/process/maint_critters
	name = "Maintenance Critter Spawner"
	schedule_interval = 2 MINUTES

	doWork()
		if (global.critter_controller)
			global.critter_controller.check_critter_locations()
			global.critter_controller.spawn_scheduled_critters()
