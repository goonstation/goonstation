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

		for(var/X in src.mobs)
			if(istype(X, /mob/living))
				var/mob/living/M = X
				if( M.z == 4 && !Z4_ACTIVE ) continue
				M.Life(src)
				if (!(c++ % 5))
					scheck()
			else if(istype(X, /mob/wraith))
				var/mob/wraith/W = X
				W.Life(src)
				scheck()
			else if(istype(X, /mob/dead))
				var/mob/dead/G = X
				#ifdef HALLOWEEN
				if (TRUE)
				#else
				if (isadminghost(G) || IS_TWITCH_CONTROLLED(G))
				#endif
					G:Life(src)
					scheck()

	tickDetail()
		if (detailed_count && detailed_count.len)
			var/stats = "<b>[name] ticks:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")
