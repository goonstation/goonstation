/datum/controller/process/tracker_hud
	var/tmp/list/processing_components
	setup()
		name = "tracker hud"
		schedule_interval = 0.5 SECONDS
		src.processing_components = list()

	doWork()
		var/c
		for(var/datum/component/tracker_hud/component in src.processing_components)
			if (!component || component:disposed || component:qdeled) //if the object was pooled or qdeled we have to remove it from this list... otherwise the lagchecks cause this loop to hold refs and block GC!!!
				src.processing_components -= component
				continue
			component.process()
			if (!(c++ % 20))
				scheck()
