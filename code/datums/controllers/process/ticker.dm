// handles the game ticker
//var/datum/controller/process/ticker/sorry_for_the_global_this_is_the_gameticker


datum/controller/process/ticker
/*
	New(var/datum/controller/processScheduler/scheduler)
		// Okay so this is the same as the tgui override except stupider because
		// originally the ticker was going to run AFTER everything else, right
		// but what if we make it run FIRST, because all it does is wait 150 seconds
		// and spawn a map vote.
		// So here's what we do: we spawn a gameticker earlier on,
		// then start up the pregame shit.
		// when the process controller comes in later we say "hey just use this one
		// we already made :-)" and hopefully that works.
		// hopefully.
		// this stuff is kind of complicated and there's no real way to order things
		// beyond "do this last" which is kinda bleeeeeeeh but whatever
		if (sorry_for_the_global_this_is_the_gameticker && sorry_for_the_global_this_is_the_gameticker != src)
			// Set the scheduler, since the initial run won't have one (since it doesn't exist yet)
			sorry_for_the_global_this_is_the_gameticker.main = scheduler
			return sorry_for_the_global_this_is_the_gameticker
		sorry_for_the_global_this_is_the_gameticker = src
		..()
*/
	setup()
		name = "Game"
		schedule_interval = 5

		if (!ticker)
			ticker = new /datum/controller/gameticker()
			SPAWN_DBG(0)
				ticker.pregame()

	doWork()
		ticker.process()
