/datum/controller/process/burning
	setup()
		name = "Burning"
		schedule_interval = 2.9 SECONDS

	copyStateFrom(datum/controller/process/target)
		return

	doWork()
		var/c
		for(var/obj/item/I as anything in by_cat[TR_CAT_BURNING_ITEMS])
			if (!I || I.disposed || I.qdeled)
				continue
			I.process_burning()
			if (!(c++ % 20))
				scheck()
