/obj/machinery/imp/chair
	name = "Implant Chair"
	desc = "Implants the user with an counter-revolutionary implant"
	icon = 'icons/misc/simroom.dmi'
	icon_state = "simchair"
	anchored = 1
	density = 0
	var/obj/item/implant/imp = null

	New()
		..()
		UnsubscribeProcess()

/obj/machinery/imp/chair/MouseDrop_T(mob/M as mob, mob/user as mob)
	if (!ticker)
		boutput(user, "You can't buckle anyone in before the game starts.")
		return
	if ((!( iscarbon(M) ) || BOUNDS_DIST(src, user) > 0 || M.loc != src.loc || user.restrained() || user.stat))
		return
	if (M.buckled)	return
	if (M == user)
		user.visible_message("<span class='notice'>[M] buckles in!</span>", "<span class='notice'>You buckle yourself in.</span>")
	else
		user.visible_message("<span class='notice'>[M] is buckled in by [user].</span>", "<span class='notice'>You buckle in [M].</span>")
	M.anchored = 1
	M.buckled = src
	M.set_loc(src.loc)
	implantgo(M)
	src.add_fingerprint(user)
	playsound(src, 'sound/misc/belt_click.ogg', 50, 1)
	M.setStatus("buckled", duration = INFINITE_STATUS)
	return

/obj/machinery/imp/chair/attack_hand(mob/user)
	for(var/mob/M in src.loc)
		if (M.buckled)
			if (M != user)
				user.visible_message("<span class='notice'>[M] is unbuckled by [user].</span>", "<span class='notice'>You unbuckle [M].</span>")
			else
				user.visible_message("<span class='notice'>[M] unbuckles.</span>", "<span class='notice'>You unbuckle.</span>")
			reset_anchored(M)
			M.buckled = null
			src.add_fingerprint(user)
			playsound(src, 'sound/misc/belt_click.ogg', 50, 1)
	return

/obj/machinery/imp/chair/proc/implantgo(mob/M as mob)
	if (!ismob(M))
		return

	src.imp = new/obj/item/implant/counterrev(src)

	M.visible_message("<span class='alert'>[M] has been implanted by the [src].</span>")


	logTheThing(LOG_COMBAT, usr, "has implanted [constructTarget(M,"combat")] with a [src.imp] implant ([src.imp.type]) at [log_loc(M)].")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.implant.Add(src.imp)

	src.imp.set_loc(M)
	src.imp.owner = M
	src.imp.implanted = 1
	src.imp.implanted(M)
	src.imp = null
	return
