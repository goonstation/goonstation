/*
/obj/npcmonkeyspawner/New()
	var/mob/living/carbon/monkey/M = new /mob/living/carbon/monkey ( loc )
	M.AIactive = 1
	M.think()
	qdel(src)

/obj/npcmonkeyspawner/angry/New()
	var/mob/living/carbon/monkey/M = new /mob/living/carbon/monkey ( loc )
	M.AIactive = 1
	M.aggressiveness = 22
	M.think()
	qdel(src)

/obj/npcmonkeyspawner/special/New()
	var/mob/living/carbon/monkey/special/M = new /mob/living/carbon/monkey/special ( loc )
	M.AIactive = 1
	M.think()
	qdel(src)

/mob/living/carbon/monkey/proc/helpme(mob/M as mob) // GANGBANG
	target = M
	mainstate = 3

/mob/living/carbon/monkey/proc/think()

	var/turf/T = get_turf(src)
	var/nolos = 0
	var/cantact = 0

	//emote("EMOTENAME")
	//var/count = 0
	//var/friend // His friend . real_name .
	//var/mainstate = 0
		// 0 = Idle
		// 1 = Targeting
		// 2 = Angry
		// 3 = Attacking
		// 4 = Moving out of Danger.
		// 5 = Run awayyy
		// 6 = Following
	//var/substate = 0
	//var/target = null // His target .
	//var/AIactive = 0 // Is the AI on or off?

	if (special)	// Just testing
		HealDamage("All", 10000, 10000)
		delStatus("weakened")
		drowsyness = 0
		stunned = 0
		paralysis = 0
		toxloss = 0
		oxyloss = 0

	if (!AIactive) return
	if (transforming) return

	if (stat || stunned || getStatusDuration("weakened") || getStatusDuration("paralysis")) cantact = 1

	if(target && (mainstate == 2 || mainstate == 3))
		var/list/L = new/list()
		L = getline(get_turf(src), get_turf(target))
		for (var/turf/Trf as turf in L)
			if (Trf.density) nolos = 1
			for (var/atom/C in Trf)
				if (!isliving(C) && C.density) // Somethings blocking our way
					nolos = 1

	switch(mainstate)

		if(0)

			if(target)
				target = null

			if((T.sl_gas || T.poison) && !special) // ahaha what a shitty workaround.
				mainstate = 4
				SaferTurf()
				SPAWN_DBG(0.5 SECONDS) //////////////////////////////////////!!!
					think()
				return

			var/mob/Temp
			var/TempHp = 100

			for(var/mob/M as mob in oview(world.view-3,src))
				if(!M.client || !ishuman(M)) continue
				if(M.health <= TempHp && !M.stat)
					Temp = M
					TempHp = M.health
			if ((Temp && prob( ( (100 - TempHp) * 2) + aggressiveness )) || Temp && health < 90 + (aggressiveness / 2) )
				if (!isliving(Temp))
					SPAWN_DBG(0.5 SECONDS) //////////////////////////////////////!!!
						think()
					return
				mainstate = 1
				target = Temp
			else
				if(!cantact && canmove)
					step_rand(src)


		if(1)

			if(!target || cantact || target:stat)
				mainstate = 0
				target = null
				SPAWN_DBG(0.5 SECONDS) //////////////////////////////////////!!!
					think()
				return

			for(var/mob/M as mob in oview(world.view,src))
				boutput(M, "<span style=\"color:red\">The [src.name] stares at [target]</span>")
			if (prob(10) && !special) emote("gnarl")
			mainstate = 2
			SPAWN_DBG(1.5 SECONDS) //////////////////////////////////////!!!
				think()
			return

		if(2)

			if(!target)
				mainstate = 0
				SPAWN_DBG(0.5 SECONDS) //////////////////////////////////////!!!
					think()
				return

			if( (get_dist(src,target) >= world.view - 2) && !cantact)
				for(var/mob/M as mob in oview(world.view,src))
					boutput(M, "<span style=\"color:red\">The [src.name] calms down.</span>")
				target = null
				count = 0
				mainstate = 0
				SPAWN_DBG(1 SECOND) //////////////////////////////////////!!!
					think()
				return

			if ((prob(33) || health < 50) && !cantact)
				if (prob(10) && !special) emote("paw")
				for(var/mob/living/carbon/monkey/M as mob in oview(world.view,src))
					if (istype(M,/mob/living/carbon/monkey)) // BYOND SUCKS ARRRGH
						if(M.AIactive && !M.stat && M.canmove)
							M.helpme(target)

			if (!nolos && canmove && !cantact)
				for(var/mob/M as mob in oview(world.view,src))
					boutput(M, "<span style=\"color:red\">The [src.name] lunges at [target].</span>")
				if (prob(10) && !special) emote("roar")
				while(get_dist(src,target) > 2)
					step_towards(src,target)
					sleep(0.2 SECONDS)

			mainstate = 3

		if(3)

			if( ( (target:stat && prob(50-aggressiveness) ) && !cantact) || count > 300 )
				for(var/mob/M as mob in oview(world.view,src))
					boutput(M, "<span style=\"color:red\">The [src.name] loses interest in its target.</span>")
				target = null
				count = 0
				mainstate = 0
				SPAWN_DBG(1 SECOND) //////////////////////////////////////!!!
					think()
				return

			if(get_dist(src,target) > world.view + 2 && !cantact)
				for(var/mob/M as mob in oview(world.view,src))
					boutput(M, "<span style=\"color:red\">The [src.name] calms down.</span>")
				target = null
				count = 0
				mainstate = 0
				SPAWN_DBG(1 SECOND) //////////////////////////////////////!!!
					think()
				return

			if(get_dist(src,target) > 1 && !cantact && canmove)
				count++
				step_towards(src,target)

			if((T.sl_gas > 3000 || T.poison > 3000 ) && !special) // ahaha what a shitty workaround.
				mainstate = 4
				SaferTurf()

			if(get_dist(src,target) == 2 && prob(50) && (!cantact && canmove))

				if(!nolos)
					for(var/mob/M as mob in oview(world.view,src))
						boutput(M, "<span style=\"color:red\">The [src.name] pounces [target].</span>")
					target:weakened += 3
					step_towards(src,target)
					step_towards(src,target)
					SPAWN_DBG(1 SECOND)
						think()
					return


			if(get_dist(src,target) < 2 && (!cantact && !istype(src.wear_mask, /obj/item/clothing/mask/muzzle)) )
				for(var/mob/M as mob in oview(world.view,src))
					boutput(M, "<span style=\"color:red\">The [src.name] bites [target].</span>")
				if(prob(15) && special)
					randmutb(target)
					for(var/mob/M as mob in oview(world.view,src))
						boutput(M, "<span style=\"color:red\">[target] has been infected.</span>")
				target:TakeDamage("chest", 5, 0)
				SPAWN_DBG(2 SECONDS)
					think()
				return



		if(4)
			if (prob(5) && !special) emote("whimper")
			if((T.sl_gas || T.poison || t_oxygen) && !special)
				SaferTurf()
			else
				if(target) mainstate = 2
				if(!target) mainstate = 0

	SPAWN_DBG(0.5 SECONDS)
		think()
	return

/mob/living/carbon/monkey/proc/SaferTurf()
	var/turf/Current = get_turf(src)
	var/turf/Temp = Current
	var/turf/Check = Current
	var/blocked = 0
	var/cantact = 0

	if (stat || stunned || getStatusDuration("weakened") || getStatusDuration("paralysis")) cantact = 1

	if(Current.sl_gas && canmove && !cantact)
		Current = get_turf(src)
		Temp = Current
		Check = Current
		for(var/A in alldirs)
			Check = get_step(src, A)
			if(!istype(Check,/turf)) continue
			if (Check.sl_gas < Current.sl_gas && Check.sl_gas < Temp.sl_gas && !Check.density)
				blocked = 0
				for (var/atom/B in Check)
					if(B.density)
						blocked = 1
				if(!blocked)
					Temp = Check
		step_towards(src,Temp)

	if(Current.poison && canmove && !cantact)
		Current = get_turf(src)
		Temp = Current
		Check = Current
		for(var/A in alldirs)
			Check = get_step(src, A)
			if(!istype(Check,/turf)) continue
			if (Check.poison < Current.poison && Check.poison < Temp.poison && !Check.density)
				blocked = 0
				for (var/atom/B in Check)
					if(B.density)
						blocked = 1
				if(!blocked)
					Temp = Check
		step_towards(src,Temp)


	if(t_oxygen && canmove && !cantact)
		Current = get_turf(src)
		Temp = Current
		Check = Current
		for(var/A in alldirs)
			Check = get_step(src, A)
			if(!istype(Check,/turf)) continue
			if (Check.oxygen > Current.oxygen && Check.oxygen > Temp.oxygen && !Check.density)
				blocked = 0
				for (var/atom/B in Check)
					if(B.density)
						blocked = 1
				if(!blocked)
					Temp = Check
		step_towards(src,Temp)
*/
