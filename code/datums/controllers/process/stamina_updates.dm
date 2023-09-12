/// Handles mob stamina recovery
/datum/controller/process/stamina_updates
	setup()
		name = "Stamina Updates"
		schedule_interval = 1 SECOND

	doWork()
		for(var/mob/living/L as anything in by_cat[TR_CAT_STAMINA_MOBS])
			L.handle_stamina_updates()
			scheck()
