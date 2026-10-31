/// Handles mob stamina recovery
/datum/controller/process/stamina_updates
	setup()
		name = "Stamina Updates"
		schedule_interval = 1 SECOND

	doWork()
		var/c = 0
		for(var/mob/living/L as anything in by_cat[TR_CAT_STAMINA_MOBS])
			L.handle_stamina_updates()
			if (!(c++ % 20))
				scheck()
