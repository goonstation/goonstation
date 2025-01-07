/// handles obj/item/mechanics/process()
/datum/controller/process/mechanics

		schedule_interval = 0.4 SECONDS

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
