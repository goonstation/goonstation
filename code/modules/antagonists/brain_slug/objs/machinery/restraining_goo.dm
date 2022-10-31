/obj/machinery/brain_slug/restraining_goo
	name = "sticky goo"
	//todo make an icon
	icon = 'icons/obj/objects.dmi'
	icon_state = "rat_den"
	desc = "A pile of sticky goo, restraining movement."
	anchored = 1
	density = 0
	_health = 30
	var/mob/linked_mob = null
	var/next_spawn_check = 10 SECONDS
	//Todo change sound when it is hit to something squishy

	New(var/turf/T, var/mob/mob_to_link = null)
		..()
		linked_mob = mob_to_link
		APPLY_ATOM_PROPERTY(linked_mob, PROP_MOB_CANTMOVE, "slimed_up")
		linked_mob.anchored = TRUE

	disposing()
		. = ..()
		if (linked_mob)
			REMOVE_ATOM_PROPERTY(linked_mob, PROP_MOB_CANTMOVE, "slimed_up")
			linked_mob.anchored = FALSE

	process()
		src._health -= 1
		if (linked_mob?.getStatusDuration("burning"))	//Burning will melt off the goo
			src._health -= 2
		if (src._health<= 0)
			qdel(src)

	attack_hand(mob/user)
		. = ..()
		src._health -= 1
		user.lastattacked = src
		interact_particle(user, src)
		user.visible_message("<span class='notice'>[user] removes some of the goo by hand. It's not very effective!</span>")
		if (src._health <= 0)
			qdel(src)

	attackby(obj/item/P, mob/living/user)
		src._health -= 3
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		user.visible_message("<span class='notice'>[user] Hacks away at the goo!</span>")
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if(src._health <= 0)
			qdel(src)
