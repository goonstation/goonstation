/datum/controller/process/tracker_hud
	var/tmp/list/processing_components
	setup()
		name = "tracker hud"
		schedule_interval = 0.5 SECONDS
		src.processing_components = list()

	doWork()
		var/c
		for(var/datum/component/tracker_hud/component as anything in src.processing_components)
			if (QDELETED(component))
				src.processing_components -= component
				continue
			component.process()
			if (!(c++ % 20))
				scheck()
