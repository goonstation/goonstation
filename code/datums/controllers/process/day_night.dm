
/datum/controller/process/day_night
	var/tmp/list/detailed_count
	var/tmp/tick_counter

	setup()
		name = "Day/Night"
		schedule_interval = 2.5 MINUTES

		detailed_count = new

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/day_night/old_day_night = target
		src.detailed_count = old_day_night.detailed_count

	doWork()
		var/i
		for(var/id in daynight_controllers)
			var/datum/daynight_controller/controller = daynight_controllers[id]
			controller:process()
			if (!(i++ % 10))
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
