/obj/machinery/imp/chair
	name = "Implant Chair"
	desc = "Implants the user with a loyalty implant"
	icon = 'icons/misc/simroom.dmi'
	icon_state = "simchair"
	anchored = 1
	density = 0
	var/obj/item/implant/imp = null

	New()
		..()
		UnsubscribeProcess()

/obj/machinery/imp/chair/MouseDrop_T(mob/M, mob/user)
	buckle(M, user)

/obj/machinery/imp/chair/attack_hand(mob/user)
	if (buckled_mob)
		unbuckle(buckled_mob, user)

/obj/machinery/imp/chair/can_buckle(mob/M, mob/user)
	. = ..()
	if (. && iscarbon(M) && get_dist(src, user) <= 1 && M.loc == src.loc && !user.restrained() && !user.stat)
		return TRUE

/obj/machinery/imp/chair/mob_buckled(mob/M, mob/user)
	if (M == usr)
		user.visible_message("<span class='notice'>[M] buckles in!</span>", "<span class='notice'>You buckle yourself in.</span>")
	else
		user.visible_message("<span class='notice'>[M] is buckled in by [user].</span>", "<span class='notice'>You buckle in [M].</span>")
	playsound(get_turf(src), "sound/misc/belt_click.ogg", 50, 1)
	if (user)
		src.add_fingerprint(user)
	implantgo(M)
	M.setStatus("buckled", duration = INFINITE_STATUS)

/obj/machinery/imp/chair/mob_unbuckled(mob/M, mob/user)
	if (M != user)
		user.visible_message("<span class='notice'>[M] is unbuckled by [user].</span>", "<span class='notice'>You unbuckle [M].</span>")
	else
		user.visible_message("<span class='notice'>[M] unbuckles.</span>", "<span class='notice'>You unbuckle.</span>")
	playsound(get_turf(src), "sound/misc/belt_click.ogg", 50, 1)
	src.add_fingerprint(user)

/obj/machinery/imp/chair/buckle_mob(mob/M, mob/user)
	. = ..()
	M.anchored = 1
	M.set_loc(src.loc)

/obj/machinery/imp/chair/unbuckle_mob(mob/M, mob/user)
	. = ..()
	M.anchored = 0


/obj/machinery/imp/chair/proc/implantgo(mob/M)
	if (!ismob(M))
		return

	src.imp = new/obj/item/implant/antirev(src)

	M.visible_message("<span class='alert'>[M] has been implanted by the [src].</span>")

	logTheThing("combat", M, "has implanted %target% with a [src.imp] implant ([src.imp.type]) at [log_loc(M)].")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.implant.Add(src.imp)

	src.imp.set_loc(M)
	src.imp.owner = M
	src.imp.implanted = 1
	src.imp.implanted(M)
	src.imp = null
	return
