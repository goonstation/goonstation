
/// handles health updates
datum/controller/process/healthupdates
	var/tmp/list/detailed_count
	var/tmp/tick_counter

	setup()
		name = "HealthUpdate"
		schedule_interval = 0.5 SECONDS
		detailed_count = new

	doWork()
		var/c
		for(var/mob/M in global.health_update_queue)
			if(M && !M.disposed)
				M.UpdateDamage()
				if (!(c++ % 20))
					scheck()

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/healthupdates/old_healthupdates = target
		src.detailed_count = old_healthupdates.detailed_count

	onFinish()
		global.health_update_queue.len = 0

	tickDetail()
		if (length(detailed_count))
			var/stats = "<b>[name] ticks:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")
