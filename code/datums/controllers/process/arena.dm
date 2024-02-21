
/// Handles the gauntlet
/datum/controller/process/arena
	var/list/arenas = list()

	setup()
		name = "Arena"
		schedule_interval = 0.8 SECONDS

		arenas += gauntlet_controller

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/arena/old_arena = target
		src.arenas = old_arena.arenas

	doWork()
		for (var/datum/arena/A in arenas)
			A.tick()
