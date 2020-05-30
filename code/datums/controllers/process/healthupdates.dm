// handles health updates
datum/controller/process/healthupdates
	var/tmp/list/detailed_count
	var/tmp/tick_counter

	setup()
		name = "HealthUpdate"
		schedule_interval = 5
		detailed_count = new

	doWork()
		var/c
		for(var/mob/M in global.health_update_queue)
			M.UpdateDamage()
			if (!(c++ % 20))
				scheck()
	
	onFinish()
		global.health_update_queue.len = 0

	tickDetail()
		if (detailed_count && detailed_count.len)
			var/stats = "<b>[name] ticks:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")
