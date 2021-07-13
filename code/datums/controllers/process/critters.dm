
/// handles critters
/datum/controller/process/critters
	var/tmp/list/detailed_count
	var/tmp/tick_counter

	setup()
		name = "Critter"
		schedule_interval = 1.6 SECONDS

		detailed_count = new

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/critters/old_critters = target
		src.detailed_count = old_critters.detailed_count

	doWork()
		var/i
		for(var/datum/c in by_cat[TR_CAT_CRITTERS])
			if(c:z == 4 && !Z4_ACTIVE) continue
			c:process()
			if (!(i++ % 10))
				scheck()

		/*var/currentTick = ticks
		for(var/obj/critter in critters)
			tick_counter = world.timeofday

			critter:process()

			tick_counter = world.timeofday - tick_counter
			if (critter && tick_counter > 0)
				detailed_count["[critter.type]"] += tick_counter

			scheck(currentTick)*/

	tickDetail()
		if (length(detailed_count))
			var/stats = "<b>[name] ticks:</b>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")
