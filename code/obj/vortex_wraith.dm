/obj/vortex_wraith
	name = "Summoning portal"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	desc = "I wonder what this is."
	anchored = 1
	density = 0
	_health = 20
	var/list/mob_list = list()

	New()
		..()

		src.visible_message("<span class='alert'>A [src] appears into view, some shadows coalesce within!</b></span>")
		SPAWN(5 SECOND)
			var/amount_to_spawn = rand(4,7)
			var/mob_type = null
			var/amount_spawned = 0
			while (amount_spawned < amount_to_spawn)
				if(prob(10)) //Chance for strong critter
					mob_type = /obj/critter/gunbot/heavy
				else
					mob_type = pick(/obj/critter/shade,
					/obj/critter/crunched,
					/obj/critter/ancient_thing,
					/obj/critter/ancient_repairbot/grumpy,
					/obj/critter/gunbot/drone/buzzdrone)
				var/obj/minion = new mob_type(src.loc)
				mob_list += minion
				src.visible_message("<span class='alert'><b>[minion] emerges from the [src]!</b></span>")
				sleep(7 SECOND)
				amount_spawned++
			sleep(60 SECOND)
			for (var/obj/C in mob_list)
				qdel(C)
		qdel(src)
		return


	attackby(obj/item/P as obj, mob/living/user as mob)
		src._health -= P.force
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if(src._health <= 0)
			for (var/obj/C in mob_list)
				qdel(C)
			qdel(src)
