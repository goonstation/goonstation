/datum/controller/process/corroding
	setup()
		name = "Corroding"
		schedule_interval = 2.3 SECONDS

	copyStateFrom(datum/controller/process/target)
		return

	doWork()
		var/c
		for(var/obj/item/I as anything in by_cat[TR_CAT_CORRODING_ITEMS])
			if (!I || I.disposed || I.qdeled)
				continue
			I.process_corrode()
			if (!(c++ % 20))
				scheck()
