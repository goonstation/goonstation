/obj/machinery/imp/chair
	name = "Implant Chair"
	desc = "Implants the user with an counter-revolutionary implant"
	icon = 'icons/misc/simroom.dmi'
	icon_state = "simchair"
	anchored = ANCHORED
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
		user.visible_message(SPAN_NOTICE("[M] buckles in!"), SPAN_NOTICE("You buckle yourself in."))
	else
		user.visible_message(SPAN_NOTICE("[M] is buckled in by [user]."), SPAN_NOTICE("You buckle in [M]."))
	M.anchored = ANCHORED
	M.buckled = src
	M.set_loc(src.loc)
	implantgo(M)
	src.add_fingerprint(user)
	playsound(src, 'sound/misc/belt_click.ogg', 50, TRUE)
	M.setStatus("buckled", duration = INFINITE_STATUS)
	return

/obj/machinery/imp/chair/attack_hand(mob/user)
	for(var/mob/M in src.loc)
		if (M.buckled)
			if (M != user)
				user.visible_message(SPAN_NOTICE("[M] is unbuckled by [user]."), SPAN_NOTICE("You unbuckle [M]."))
			else
				user.visible_message(SPAN_NOTICE("[M] unbuckles."), SPAN_NOTICE("You unbuckle."))
			reset_anchored(M)
			M.buckled = null
			src.add_fingerprint(user)
			playsound(src, 'sound/misc/belt_click.ogg', 50, TRUE)
	return

/obj/machinery/imp/chair/proc/implantgo(mob/M as mob)
	if (!ismob(M))
		return

	src.imp = new/obj/item/implant/counterrev(src)

	M.visible_message(SPAN_ALERT("[M] has been implanted by the [src]."))

	src.imp.implanted(M)
	src.imp = null
	return
