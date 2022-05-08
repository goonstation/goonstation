/obj/machinery/warren
	name = "warren"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	desc = "A rat warren."
	anchored = 1
	density = 0
	_health = 25
	var/linked_critters = 0
	var/max_critters = 5
	var/next_spawn_check = 10 SECONDS

	New()
		..()
		next_spawn_check = world.time + (10 SECONDS)
		return

	attackby(obj/item/P as obj, mob/living/user as mob)
		src._health -= P.force
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if(src._health <= 0)
			src.gib(src.loc)
			qdel(src)

	process()
		if (src.next_spawn_check != null)//Check about mad mice assaulting the plague rat
			if (src.next_spawn_check < world.time)
				next_spawn_check = world.time + rand(10 SECONDS, 15 SECONDS)
				if (linked_critters < max_critters)
					var/obj/critter/mouse/mad/warren/M = new /obj/critter/mouse/mad/warren(src.loc)
					M.linked_warren = src
					linked_critters ++

		for (var/mob/living/critter/plaguerat/P in range(5, src))
			if((P.health < 100))
				for(var/damage_type in P.healthlist)
					var/datum/healthHolder/hh = P.healthlist[damage_type]
					hh.HealDamage(3)
				boutput(P, "The proximity of the warren fills you with renewed malevolence.")
