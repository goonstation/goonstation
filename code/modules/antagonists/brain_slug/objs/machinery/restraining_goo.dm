/obj/machinery/brain_slug/restraining_goo
	name = "sticky goo"
	icon = 'icons/mob/brainslug.dmi'
	icon_state = "restrainer"
	desc = "A pile of sticky goo, restraining movement."
	anchored = 0
	density = 0
	_health = 30
	var/mob/linked_mob = null

	New(var/turf/T, var/mob/mob_to_link = null)
		..()
		if (mob_to_link)
			linked_mob = mob_to_link
			APPLY_ATOM_PROPERTY(linked_mob, PROP_MOB_CANTMOVE, "slimed_up")
			linked_mob.anchored = TRUE
			var/datum/component/gluecomp = src.GetComponent(/datum/component/glued)
			gluecomp?.RemoveComponent()
			var/atom/movable/our_atom = src
			our_atom.AddComponent(/datum/component/glued, linked_mob, -1, -1, FALSE)

	disposing()
		if (linked_mob)
			REMOVE_ATOM_PROPERTY(linked_mob, PROP_MOB_CANTMOVE, "slimed_up")
			linked_mob.anchored = FALSE
		. = ..()

	process()
		src._health -= 2
		if (linked_mob?.getStatusDuration("burning"))	//Burning will melt off the goo
			src._health -= 2
		if (src._health<= 0)
			qdel(src)

	attack_hand(mob/user)
		. = ..()
		src._health -= 2
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
		user.visible_message("<span class='notice'>[user] hacks away at the goo!</span>")
		playsound(src.loc, pick('sound/impact_sounds/Slimy_Hit_1.ogg', 'sound/impact_sounds/Slimy_Hit_2.ogg'), 50, 1)
		if(src._health <= 0)
			qdel(src)
