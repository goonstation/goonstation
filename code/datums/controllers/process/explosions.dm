
/// handles EXPLOSIONS
/datum/controller/process/explosions
	var/datum/explosion_controller/explosion_controller

	setup()
		name = "Explosions"
		schedule_interval = 0.5 SECONDS

		explosion_controller = explosions

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/explosions/old_explosions = target
		src.explosion_controller = old_explosions.explosion_controller

	doWork()
		explosion_controller.process() //somehow runtimes null.process(), why the fuck is explosion controller gone???
