// handles critters
datum/controller/process/mob_ai
	setup()
		name = "Mob AI"
		schedule_interval = 16 // 1.6 seconds

	doWork()
		for(var/X in ai_mobs)
			var/mob/M = X

			if (!M)
				continue

			if (M.mob_flags & LIGHTWEIGHT_AI_MOB) //call life() with a slowed update rate on mobs we manage that arent part of the standard mobs list
				if( M.z == 4 && !Z4_ACTIVE ) continue
				if ((ticks % 5) == 0)
					if (istype(X, /mob/living))
						var/mob/living/L = X
						L.Life(src)
					scheck()

				if ((ticks % 3) == 0)
					M.handle_stamina_updates()
					if (!M.client) continue

					if (M.abilityHolder && !M.abilityHolder.composite_owner)
						if (world.time >= M.abilityHolder.next_update) //after a failure to update (no abbilities!!) wait 10 seconds instead of checking again next process
							if (M.abilityHolder.updateCounters() > 0)
								M.abilityHolder.next_update = 1 SECOND
							else
								M.abilityHolder.next_update = 10 SECONDS
					scheck()

			var/mob/living/L = M
			if((isliving(M) && L.is_npc || !isliving(M)))
				if(istype(X, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = X
					if(H.uses_mobai && H.ai)
						H.ai.tick()
					else
						H.ai_process()
					scheck()
				else if(M.ai)
					M.ai.tick()
					scheck()

		//we actually remove fish from Mobs list to save on some server load. sorry. commenting this out for now
		/*
		for(var/mob/living/critter/aquatic/A in mobs)
			if(A.is_npc && A.ai)
				A.ai.tick()
				scheck()
		*/

		/*var/currentTick = ticks
		for(var/obj/critter in critters)
			tick_counter = world.timeofday

			critter:process()

			tick_counter = world.timeofday - tick_counter
			if (critter && tick_counter > 0)
				detailed_count["[critter.type]"] += tick_counter

			scheck(currentTick)*/
