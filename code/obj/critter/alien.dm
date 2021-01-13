/obj/critter/alien/larva
	name = "alien larva"
	icon_state = "larva" // icon_state = "larva_l" - dead
	dead_state = "larva_l"
	health = 10
	aggressive = 0
	defensive = 1
	var/amount_grown = 0
	desc = "You know, it'd be kind of cute if it wasn't trying to eat you."

	process() //overriding default sleeping behavior
		if (!src.alive) // and completely ruining their ability to die by not including some very important bits I guess
			return 0
		check_health()

		src.amount_grown++

		if(amount_grown >= 100)
			new /obj/critter/alien/humanoid( src.loc )

			qdel(src)

		else
			ai_think()

/obj/critter/alien/humanoid
	density = 1

/obj/critter/alien
	name = "Alien"
	desc = "An alien."
	icon_state = "alien"
	density = 1
	anchored = 0
	health = 40
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	firevuln = 1
	brutevuln = 1
	atcritter = 1

	seek_target()
		if (!src.alive) return
		src.anchored = 0
		for (var/mob/living/C in hearers(src.seekrange,src))
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			//if(isalien(C)) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> charges at [C:name]!</span>")
				src.task = "chasing"
				return
			else
				continue

		if(!src.atcritter) return
		for (var/obj/critter/C in view(src.seekrange,src))
			if (!C.alive) continue
			if (C.health < 0) continue
			if (!istype(C, /obj/critter/alien)) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> lunges at [C.name]!</span>")

				src.task = "chasing"
				return

			else continue

	CritterAttack(mob/M)
		src.attacking = 1
		if(istype(M,/obj/critter))
			var/obj/critter/C = M
			src.visible_message("<span class='combat'><B>[src]</B> claws [src.target]!</span>")
			playsound(C.loc, "punch", 25, 1, -1)
			C.health -= 10
			if(C.health <= 0)
				C.CritterDeath()
			SPAWN_DBG(1.5 SECONDS)
				src.attacking = 0
			return

		src.visible_message("<span class='combat'><B>[src]</B> claws at [src.target]!</span>")
		random_brute_damage(src.target, rand(5,10),1)
		SPAWN_DBG(1 SECOND)
			src.attacking = 0

	ChaseAttack(mob/M)
		src.visible_message("<span class='combat'><B>[src]</B> jumps at [M]!</span>")
		if(iscarbon(M))
			if (prob(60)) M.changeStatus("stunned", rand(10, 50))
			random_brute_damage(M, rand(2,5),1)
