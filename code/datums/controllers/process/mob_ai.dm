///How many ticks a mobAI can skip before we decide it needs interupting and reporting
#define MOBAI_STUCK_THRESHOLD 10
///Uncomment to remove mobai loop runtime safety for debugging
//#define MOBAI_UNSAFE_LOOP

/// handles mobcritters
datum/controller/process/mob_ai
	setup()
		name = "Mob AI"
		schedule_interval = 0.2 SECONDS

	doWork()
		scheck()
		for(var/X in ai_mobs)
			var/mob/M = X
			last_object = X

			if (QDELETED(M))
				continue

			if( M.z == 4 && !Z4_ACTIVE ) continue

			//in case it isn't obvious, what we're doing here is giving each mob a raffle ticket, and mod 30ing it to determine if a mob should tick
			//this spreads out mob ticks, which still happen once every 6 seconds, but not all at the same time
			if(isnull(M.ai_tick_schedule))
				M.ai_tick_schedule = rand(0,30) //if you need bigger delays in the future, don't forget to increase this number proportionally
			var/ticknum = M.ai_tick_schedule + ticks

			var/tickme = FALSE

			if ((ticknum % 30) == 0)
				//call life() with a slowed update rate on mobs we manage that arent part of the standard mobs list
				if (M.ai?.exclude_from_mobs_list && istype(X, /mob/living))
					var/mob/living/L = X
					L.Life(src)
					scheck()
				//Lightweight mobs get ticked every 6 seconds
				if(M.mob_flags & LIGHTWEIGHT_AI_MOB)
					tickme = TRUE

			//normal mobs get ticked every second, heavyweight mobs get ticked every 0.2 seconds
			if((M.mob_flags & HEAVYWEIGHT_AI_MOB) || (ticknum % 5) == 0) //either we can tick every time, or we tick every 1 second
				tickme = TRUE

			if(tickme)
				var/mob/living/L = M
				if(istype(X, /mob/living/carbon/human) && (L.is_npc || L.ai_active))
					var/mob/living/carbon/human/H = X
					if(!(H.uses_mobai && H.ai))
						H.ai_process() //old human AI gets to be special until I get around to removing it
						scheck()
						continue

				if(isliving(M) && M.ai)
					if(!L.is_npc || !M.ai.enabled)
						continue
				else if(!M.ai || !M.ai.enabled)
					continue

				if(M.ai._mobai_being_processed)
					M.ai._mobai_being_processed++
					if(M.ai._mobai_being_processed > MOBAI_STUCK_THRESHOLD)
						logTheThing(LOG_DEBUG, "mobAI process", "!BAD! The mob [constructTarget(M)](\ref[M]) appears to be stuck processing its AI, and has been skipped for [M.ai._mobai_being_processed] ticks. Attempting a reset! You should *really* check why it's slow. AI = [M.ai] AI task = [M.ai?.current_task]")
						M.ai.current_task?.reset()
						M.ai.switch_to(M.ai.default_task)
						M.ai._mobai_being_processed = FALSE
					if(!ON_COOLDOWN(M, "mobAI_overran_warning", 30 SECONDS))
						logTheThing(LOG_DEBUG, "mobAI process", "The mob [constructTarget(M)](\ref[M]) overran while processing its AI, and will be skipped for one tick. You should probably check why it's slow. AI = [M.ai] AI task = [M.ai?.current_task]")
					continue

				SPAWN(0)
#ifndef MOBAI_UNSAFE_LOOP
					try
						M.ai._mobai_being_processed = TRUE
						M.ai.tick()
					catch(var/exception/e)
						logTheThing(LOG_DEBUG, "mobAI process", "A runtime was thrown by [constructTarget(M)](\ref[M]) while processing its AI. [e] on [e.file]:[e.line]")
#else
					M.ai._mobai_being_processed = TRUE
					M.ai.tick()
#endif
					M?.ai?._mobai_being_processed = FALSE //null checks just in case something went *really* wrong
				scheck()

#undef MOBAI_STUCK_THRESHOLD
