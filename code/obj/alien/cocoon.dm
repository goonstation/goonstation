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
	density = 1
	anchored = 1
	icon = 'icons/obj/objects.dmi'
	icon_state = "toilet"

	var/health = 10

	MouseDrop_T(mob/M as mob, mob/user as mob)
		if (!ticker)
			boutput(user, "You can't buckle anyone in before the game starts.")
			return
		if ((!( ismob(M) ) || BOUNDS_DIST(src, user) > 0 || user.restrained() || user.stat))
			return
		for(var/mob/O in viewers(user, null))
			if ((O.client && !( O.blinded )))
				boutput(O, text("<span class='notice'>[M] is absorbed by the cocoon!</span>"))
		M.anchored = 1
		M.buckled = src
		M.set_loc(src.loc)
		src.add_fingerprint(user)
		return

	attack_hand(mob/user)
		if(health <= 0)
			for(var/mob/M in src.loc)
				if (M.buckled)
					src.visible_message("<span class='notice'>[M] appears from the cocoon.</span>")
		//			boutput(world, "[M] is no longer buckled to [src]")
					reset_anchored(M)
					M.buckled = null
					src.add_fingerprint(user)
		return

	attackby(obj/item/W, mob/user)
		if (src.health <= 0)
			src.visible_message("<span class='alert'><B>[user] has destroyed the cocoon.</B></span>")
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
