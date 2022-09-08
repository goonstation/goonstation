
/// handles item/process()
/datum/controller/process/items
	var/tmp/list/detailed_count
	var/tmp/tick_counter
	var/tmp/list/processing_items

	setup()
		name = "Item"
		schedule_interval = 2.9 SECONDS
		// this probably lags some but it helps give the sign to people that the game
		// is in fact still doing something, which i feel is important
		// plus i like watching number go up
		var/itemcount = 0
		var/lasttime = 0

		// Zamu here -- I checked and this doesn't even register as 1 on a timeofday check
		var/totalcount = 0
		for(var/obj/object in world)
			totalcount++

		for(var/obj/object in world)
			object.initialize()
			itemcount++
			if (game_start_countdown)
				if (lasttime != world.timeofday)
					lasttime = world.timeofday
					game_start_countdown.update_status("Initializing items\n([itemcount], [round(itemcount / totalcount * 100)]%)")

			LAGCHECK(LAG_HIGH)

		detailed_count = new

		src.processing_items = global.processing_items

	copyStateFrom(datum/controller/process/target)
		var/datum/controller/process/items/old_items = target
		src.processing_items = old_items.processing_items
		src.detailed_count = old_items.detailed_count

	doWork()
		var/c
		for(var/datum/i in global.processing_items)
			if (!i || i:disposed || i:qdeled) //if the object was pooled or qdeled we have to remove it from this list... otherwise the lagchecks cause this loop to hold refs and block GC!!!
				global.processing_items -= i
				continue
			SEND_SIGNAL(i, COMSIG_ITEM_PROCESS)
			i:process()
			if (!(c++ % 20))
				scheck()

		/*for(var/obj/item/item in processing_items)
			tick_counter = world.timeofday

			item.process()

			tick_counter = world.timeofday - tick_counter
			if (item && tick_counter > 0)
				detailed_count["[item.type]"] += tick_counter

			scheck(currentTick)
*/
	tickDetail()
		if (length(detailed_count))
			var/stats = "<b>[name] ticks:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")
