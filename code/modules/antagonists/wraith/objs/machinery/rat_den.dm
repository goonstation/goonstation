/obj/machinery/wraith/rat_den
	name = "rat den"
	icon = 'icons/obj/objects.dmi'
	icon_state = "rat_den"
	desc = "A pile of garbage vaguely ressembling a nest."
	anchored = ANCHORED
	density = 0
	_health = 25
	var/linked_critters = 0
	var/max_critters = 5
	var/next_spawn_check = 10 SECONDS
	var/process_range = 2

	New()
		..()
		next_spawn_check = TIME + (10 SECONDS)
		return

	attackby(obj/item/P, mob/living/user)
		src._health -= P.force
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if(prob(20))
			playsound(src.loc, 'sound/voice/animal/mouse_squeak.ogg', 60, 1)
		if(src._health <= 0)
			src.gib(src.loc)
			qdel(src)

	process()	//Spawn some mad mice once in awhile
		if (src.next_spawn_check != null)
			if (src.next_spawn_check < TIME)
				next_spawn_check = TIME + rand(20 SECONDS, 25 SECONDS)
				if (linked_critters < max_critters)
					var/mob/living/critter/small_animal/mouse/mad/rat_den/M = new /mob/living/critter/small_animal/mouse/mad/rat_den(src.loc)
					LAZYLISTADDUNIQUE(M.faction, FACTION_WRAITH)
					M.linked_den = src
					linked_critters ++

		//Plague rats in range heal up slowly
		for_by_tcl(P, /mob/living/critter/wraith/plaguerat)
			if(!IN_RANGE(src, P, process_range)) continue
			if((P.health < (P.health_brute + P.health_burn)))
				for(var/damage_type in P.healthlist)
					var/datum/healthHolder/hh = P.healthlist[damage_type]
					hh.HealDamage(6)
				boutput(P, "The proximity of the rat den fills you with renewed malevolence.")
