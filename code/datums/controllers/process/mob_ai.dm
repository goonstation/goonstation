// handles critters
datum/controller/process/mob_ai
	setup()
		name = "Mob AI"
		schedule_interval = 16 // 1.6 seconds

	doWork()
		for(var/mob/living/carbon/human/H in mobs)
			H.ai_process()
			scheck()

		// this needs to be made more generic, but for now, do it like this, i guess, ugh
		for(var/mob/living/critter/flock/F in mobs)
			if(F.is_npc && F.ai)
				F.ai.tick()
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
