
/// handles mobs
/datum/controller/process/mobs
	var/tmp/list/detailed_count
	var/tmp/tick_counter
	var/list/mobs

	var/list/wraiths = list()
	var/list/adminghosts = list()

	var/nextpopcheck = 0
	var/schedule_override = null

	setup()
		name = "Mob"
		schedule_interval = 4 SECONDS
		detailed_count = new
		src.mobs = global.mobs

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/mobs/old_mobs = target
		src.detailed_count = old_mobs.detailed_count
		src.tick_counter = old_mobs.tick_counter
		src.mobs = old_mobs.mobs
		src.wraiths = old_mobs.wraiths
		src.adminghosts = old_mobs.adminghosts
		src.nextpopcheck = old_mobs.nextpopcheck

	doWork()
		src.mobs = global.mobs
		var/c

		if (TIME > nextpopcheck)
			nextpopcheck = TIME + 4 MINUTES
			var/clients_num = total_clients()
			if (clients_num >= SLOWEST_LIFE_PLAYERCOUNT)
				schedule_interval = 4 SECONDS
				footstep_extrarange = -10
			else if (clients_num >= SLOW_LIFE_PLAYERCOUNT)  //hacky lag saving measure
				schedule_interval = 3 SECONDS
				footstep_extrarange = -5
			else
				schedule_interval = 2 SECONDS
				footstep_extrarange = 0
			if(isnum_safe(schedule_override))
				schedule_interval = schedule_override

		for(var/X in src.mobs)
			last_object = X
			if(istype(X, /mob/living))
				var/mob/living/M = X
				if( M.z == 4 && !Z4_ACTIVE ) continue
				M.Life(src)
				if (!(c++ % 5))
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
		if (length(detailed_count))
			var/stats = "<b>[name] ticks:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")
