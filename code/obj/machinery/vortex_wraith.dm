/obj/machinery/wraith/vortex_wraith
	name = "Summoning portal"
	icon = 'icons/obj/objects.dmi'
	icon_state = "harbinger_circle_inact"
	desc = "It hums and thrums as you stare at it. Dark shadows weave in and out of sight within."
	anchored = 1
	density = 1
	_health = 25
	var/list/mob_list = list()
	var/mob_value_cap = 10	//Total allowed point value of all linked mobs
	var/growth = 0
	var/next_growth = 10 SECONDS
	var/next_spawn = 5 SECONDS
	var/total_mob_value = 0	//Total point value of all linked mobs
	var/obj/mob_type = null
	var/random_mode = true
	var/mob/wraith/master = null
	var/datum/light/light
	var/datum/light/portal_light
	var/list/default_mobs = list(/obj/critter/crunched,	//Useful for random mode or when we dont have a mob_type on spawn
								/obj/critter/ancient_thing,
								/obj/critter/ancient_repairbot/security,
								/obj/critter/mechmonstrositycrawler,
								/obj/critter/shade,
								/obj/critter/bat/buff,
								/obj/critter/lion,
								/obj/critter/wraithskeleton,
								/obj/critter/bear,
								/obj/critter/brullbar,
								/obj/critter/gunbot/heavy)

	New(var/mob_type_chosen = null)
		if(mob_type_chosen != null)
			src.mob_type = mob_type_chosen
		else	//In case we arent spawned by a wraith, or are spawned on random mode
			src.mob_type = pick(src.default_mobs)
		src.visible_message("<span class='alert'>A [src] appears into view, some shadows coalesce within!</b></span>")
		next_growth = world.time + (20 SECONDS)
		next_spawn = world.time + (21 SECONDS)	//Should call the first spawn check after the portal grew once.

		light = new /datum/light/point
		light.set_brightness(0.1)
		light.set_color(150, 40, 40)
		light.attach(src)
		light.enable()

		..()

	process()
		if ((src.next_growth != null) && (growth < 4))	//Dont grow if we are at max level
			if (src.next_growth < world.time)	//Growth grants us more health, spawn range, and spawn cap
				next_growth = world.time + 10 SECONDS + (growth * 10) SECONDS	//Subsequent levels are slower
				if (growth == 0)
					icon_state = "harbinger_circle"
				growth++
				src._health += 10
				src.mob_value_cap += 5
		if ((src.next_spawn != null) && (src.next_spawn < world.time))	//Spawn timer is up
			var/minion_value = 0

			for (var/obj/critter/M in mob_list)	//Check for dead mobs and adjust cap
				if ((M == null) || (M?.health <= 0) || (!M.loc))	//We have a mob in the list, but it's dead or missing...
					var/point_value = getMobValue(M.type)
					src.total_mob_value -= point_value
					mob_list -= M

			if (growth > 0)	//Are we spawning mobs yet? If not, wait for next tick
				var/list/eligible_turf = list()
				var/turf/chosen_turf = null
				for (var/mob/living/carbon/human/H in range((1 + src.growth), src))	//Lets try to spawn near someone
					if(isalive(H))
						for (var/turf/T in range(3, H))
							if (isturf(T) && istype(T, /turf/simulated/floor))	//Find a non-wall, non-space turf to spawn in
								eligible_turf += T
				if (length(eligible_turf) <= 0)	//No spot to spawn near a human, or no human in range, lets try to find a regular turf instead
					for (var/turf/T in range((1 + src.growth), src))
						if (isturf(T) && istype(T, /turf/simulated/floor))	//Find a non-wall, non-space turf to spawn in
							eligible_turf += T
				if (length(eligible_turf) <= 0)
					src.visible_message("<span class='alert'><b>[src] sputters and crackles, it seems it couldnt find a spot to summon something!</b></span>")
					return 1
				chosen_turf = pick(eligible_turf)
				var/obj/decal/harbinger_portal/portal = new /obj/decal/harbinger_portal
				portal.set_loc(chosen_turf)
				portal.alpha = 0
				animate(portal, alpha=255, time=1 SECONDS)
				portal_light = new /datum/light/point
				portal_light.set_brightness(0.1)
				portal_light.set_color(150, 40, 40)
				portal_light.attach(portal)
				portal_light.enable()
				playsound(chosen_turf, "sound/effects/flameswoosh.ogg" , 80, 1)
				SPAWN(3 SECOND)
					animate(portal, alpha=0, time=1 SECONDS)
					SPAWN(1 SECOND)
						qdel(portal_light)
						qdel(portal)
					if (src.random_mode)
						src.mob_type = pick(src.default_mobs)
					minion_value = getMobValue(src.mob_type)
					if ((src.total_mob_value + minion_value) <= src.mob_value_cap)
						var/obj/minion = new src.mob_type(chosen_turf)
						src.mob_list += minion
						minion.alpha = 0
						animate(minion, alpha=255, time = 2 SECONDS)
						src.visible_message("<span class='alert'><b>[minion] emerges from the [src]!</b></span>")
						src.total_mob_value += minion_value
			next_spawn = world.time + (20 SECONDS) + (minion_value * 5) SECONDS

	attackby(obj/item/P as obj, mob/living/user as mob)
		src._health -= P.force
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if(src._health <= 0)
			if (src.master != null)
				src.master.linked_portal = null
			deleteLinkedMobs()
			qdel(src)

	onDestroy()
		. = ..()
		if (src.master != null)
			src.master.linked_portal = null
		deleteLinkedMobs()

	disposing()
		if (src.master != null)
			src.master.linked_portal = null
		deleteLinkedMobs()
		. = ..()

	proc/getMobValue(var/obj/O)
		switch (O)
			if (/obj/critter/bear)
				return 10
			if (/obj/critter/wraithskeleton)
				return 4
			if (/obj/critter/shade)
				return 4
			if (/obj/critter/crunched)
				return 4
			if (/obj/critter/bat/buff)
				return 3
			if (/obj/critter/lion)
				return 5
			if (/obj/critter/brullbar)
				return 15
			if (/obj/critter/gunbot/heavy)
				return 15
			if (/obj/critter/ancient_thing)
				return 7
			if (/obj/critter/mechmonstrositycrawler)
				return 4
			else	//You never know, lets give an average point cost
				return 6

	proc/deleteLinkedMobs()
		for (var/obj/C in src.mob_list)
			animate(C, alpha=0, time=2 SECONDS)
			SPAWN(2 SECOND)
				qdel(C)
