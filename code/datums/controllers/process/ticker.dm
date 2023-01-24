
/// handles the game ticker, for gamemodes and such
/datum/controller/process/ticker

	setup()
		name = "Game"
		schedule_interval = 0.5 SECONDS

		if (!ticker)
			ticker = new /datum/controller/gameticker()
			SPAWN(0)
				ticker.pregame()

	doWork()
		ticker.process()
