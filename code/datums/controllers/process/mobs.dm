// handles mobs
datum/controller/process/mobs
	var/tmp/list/detailed_count
	var/tmp/tick_counter
	var/list/mobs

	var/list/wraiths = list()
	var/list/adminghosts = list()

	setup()
		name = "Mob"
		schedule_interval = 40
		detailed_count = new
		src.mobs = global.mobs

	copyStateFrom(var/datum/controller/process/mobs/other)
		detailed_count = other.detailed_count

	doWork()
		src.mobs = global.mobs
		var/c

		for(var/mob/living/M in src.mobs)
			if( M.z == 4 && !Z4_ACTIVE ) continue
			M.Life(src)
			if (!(c++ % 5))
				scheck()

		for(var/mob/wraith/W in src.mobs)
			W.Life(src)
			scheck()

		// For periodic antag overlay updates (Convair880).
		for (var/mob/dead/G in src.mobs)
#ifdef HALLOWEEN
			if (TRUE)
#else
			if (isadminghost(G) || IS_TWITCH_CONTROLLED(G))
#endif
				G:Life(src)
				scheck()

		/*
		for(var/mob/living/M in src.mobs)
			tick_counter = world.timeofday

			M.Life(src)

			tick_counter = world.timeofday - tick_counter
			if (M && tick_counter > 0)
				detailed_count["[M.type]-[M.name]"] += tick_counter

			scheck(currentTick)

		// a r g h
		for (var/mob/wraith/W in src.mobs)
			W.Life(src)
			scheck(currentTick)
		*/
	tickDetail()
		if (detailed_count && detailed_count.len)
			var/stats = "<b>[name] ticks:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")
