
/// handles mobcritters
datum/controller/process/mob_ai
	setup()
		name = "Mob AI"
		schedule_interval = 0.1 SECONDS

	doWork()
		for(var/X in ai_mobs)
			var/mob/M = X

			last_object = X

			if (!M)
				continue

			if ((M.mob_flags & LIGHTWEIGHT_AI_MOB) && ticks % 60 == 0) //call life() with a slowed update rate on mobs we manage that arent part of the standard mobs list
				if( M.z == 4 && !Z4_ACTIVE ) continue
				if (istype(X, /mob/living))
					var/mob/living/L = X
					L.Life(src)
				scheck()

			if ((ticks % 30) == 0)
				M.handle_stamina_updates()
				if (!M.client) continue

				if (M.abilityHolder && !M.abilityHolder.composite_owner)
					if (world.time >= M.abilityHolder.next_update) //after a failure to update (no abbilities!!) wait 10 seconds instead of checking again next process
						if (M.abilityHolder.updateCounters() > 0)
							M.abilityHolder.next_update = 1 SECOND
						else
							M.abilityHolder.next_update = 10 SECONDS
				scheck()

			if((M.mob_flags & HEAVYWEIGHT_AI_MOB) || ticks % 10 == 0) //either we can tick every time, or we tick every 1 second
				var/mob/living/L = M
				if((isliving(M) && (L.is_npc || L.ai_active) || !isliving(M)))
					if(istype(X, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = X
						if(H.uses_mobai && H.ai)
							H.ai.tick()
						else
							H.ai_process()
						scheck()
					else if(istype(X,/mob/living/critter))
						var/mob/living/critter/C = X
						if(C.is_npc && C.ai)
							C.ai.tick()
					else if(M.ai)
						M.ai.tick()
						scheck()
