/// proocess for flock_structure objects
/datum/controller/process/flock
	var/list/detailed_count
	setup()
		name = "Flock"
		schedule_interval = FLOCK_PROCESS_SCHEDULE_INTERVAL

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/flock/old_flock = target
		src.detailed_count = old_flock.detailed_count

	doWork()
		var/i
		for (var/obj/flock_structure/O as anything in by_cat[TR_CAT_FLOCK_STRUCTURE])
			if (!QDELETED(O))
				O.process(O.get_multiplier())
				O.last_process = TIME
			if (!(i++ % 10))
				scheck()

	tickDetail()
		if (length(detailed_count))
			var/stats = "<b>[name] ticks:</b>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")
