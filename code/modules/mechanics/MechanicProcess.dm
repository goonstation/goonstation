/// handles obj/item/mechanics/process()
/datum/controller/process/mechanics
	var/tmp/list/detailed_count
	var/tmp/tick_counter
	var/tmp/processing_mechanics

	setup()
		name = "Mechanics"

		schedule_interval = 0.4 SECONDS

		logTheThing(LOG_DEBUG, src, "Mechanics initialize loop completed")

		detailed_count = new

		src.processing_mechanics = global.processing_mechanics

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/mechanics/old_items = target
		src.processing_mechanics = old_items.processing_mechanics
		src.detailed_count = old_items.detailed_count

	doWork()
		var/c
		for(var/obj/item/mechanics/target in global.processing_mechanics)
			if (!target || target:disposed || target:qdeled) //if the object was pooled or qdeled we have to remove it from this list... otherwise the lagchecks cause this loop to hold refs and block GC!!!
				global.processing_mechanics -= target
				continue
			if(target.process_fast == TRUE)
				target.process()
			else if(!(src.ticks % 7)) //Target schedule time is 2.8 seconds (was 2.9)
				target.process()
			if (!(c++ % 20))
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
