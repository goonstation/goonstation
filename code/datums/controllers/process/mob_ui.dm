
/// Controls mob UI, like stamina and abilityholders
/datum/controller/process/mob_ui
	setup()
		name = "Mob UI"
		schedule_interval = 1 SECOND

	doWork()
		for(var/mob/M in mobs)
			M.handle_stamina_updates()

			if (!M.client) continue

			if (M.abilityHolder)
				if (world.time >= M.abilityHolder.next_update) //after a failure to update (no abbilities!!) wait 10 seconds instead of checking again next process
					if (M.abilityHolder.updateCounters() > 0)
						M.abilityHolder.next_update = 1 SECOND
					else
						M.abilityHolder.next_update = 10 SECONDS
			scheck()
