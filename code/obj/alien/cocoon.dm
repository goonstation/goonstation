/*

Better way to do this might be to make it a verb on a person and to cocoon the person in some kind of resin
If they're next to a wall this would change their pixel and attach them to the wall, otherwise it'd cause
Them to lie down and attach them to the floor, this could be easily done by changing the bed code.

This would mean having a variable affected_mob or something that we could keep the person stunned/alive while
they're trapped
*/
/obj/alien/cocoon
	name = "cocoon"
	desc = "a strange... something..."
	density = 1.0
	anchored = 1.0
	icon = 'icons/obj/objects.dmi'
	icon_state = "toilet"

	var/health = 10

	MouseDrop_T(mob/M as mob, mob/user as mob)
		if (!ismob(M))
			return
		buckle(M, user)

	can_buckle(mob/M, mob/user)
		if (get_dist(src, user) > 1 || user.restrained() || usr.stat && ..())
			return TRUE
		return FALSE

	buckle_mob(mob/M, mob/user)
		. = ..()
		M.anchored = 1
		M.set_loc(src.loc)
		src.add_fingerprint(user)

	unbuckle_mob(mob/M)
		M.anchored = 0
		src.add_fingerprint(user)
		return ..()

	mob_unbuckled(mob/M)
		src.visible_message("<span class='notice'>[M] appears from [src].</span>")

	mob_buckled(mob/M)
		src.visible_message("<span class='notice'>[M] is absorbed by [src].</span>")

	attack_hand(mob/user)
		if(health <= 0 && buckled_mob)
			unbuckle(buckled_mob, user)
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.health <= 0)
			src.visible_message("<span class='alert'><B>[user] has destroyed the cocoon.</B></span>")
			if (buckled_mob)
				unbuckle_mob(buckled_mob, user)
			src.death()
			return

		switch(W.damtype)
			if("fire")
				src.health -= W.force * 0.75
			if("brute")
				src.health -= W.force * 0.1
			else
		..()

	proc/death()
		src.icon_state = "egg_destroyed"	//need an icon for this
		src.set_density(0)
