/obj/vortex_wraith
	name = "Summoning portal"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	desc = "I wonder what this is."
	anchored = 1
	density = 0
	_health = 30
	var/list/mob_list = list()
	var/amount_to_spawn = 5
	var/elite_amount_to_spawn = 2
	New()
		..()
		//Todo add fade in and out. Make creatures despawn with an animation
		src.visible_message("<span class='alert'>A [src] appears into view, some shadows coalesce within!</b></span>")
		sleep(7 SECOND)	//Give crew some time to bash it while it's weak
		src._health += 40
		var/amount_to_spawn = rand(4,7)
		var/mob_type = null
		var/amount_spawned = 0
		var/elite_spawned = 0
		var/chance_increase = 0
		while (amount_spawned < amount_to_spawn)
			if ((elite_spawned < elite_amount_to_spawn) && prob(10 + chance_increase)) //Chance for strong critter
				mob_type = pick(/obj/critter/gunbot/heavy,
				/obj/critter/bear,
				/obj/critter/brullbar,
				/obj/critter/gunbot/drone)
				elite_spawned++
				chance_increase = 0
			else
				mob_type = pick(/obj/critter/shade,
				/obj/critter/crunched,
				/obj/critter/ancient_thing,
				/obj/critter/ancient_repairbot/security,
				/obj/critter/gunbot/drone/buzzdrone,
				/obj/critter/mechmonstrositycrawler,
				/obj/critter/bat/buff,
				/obj/critter/lion,
				/obj/critter/wraithskeleton,
				/obj/critter/spider/aggressive)
				chance_increase += 20
			var/obj/minion = new mob_type(src.loc)
			mob_list += minion
			src.visible_message("<span class='alert'><b>[minion] emerges from the [src]!</b></span>")
			sleep(8 SECOND)
			amount_spawned++
		sleep(180 SECOND)
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
