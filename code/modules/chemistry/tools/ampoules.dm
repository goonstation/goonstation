/obj/item/reagent_containers/ampoule
	name = "ampoule"
	desc = "A chemical-containing ampoule."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "amp-1"
	initial_volume = 5
	flags = FPRINT | TABLEPASS
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	var/expended = FALSE //Whether or not the ampoule has been used.
	var/color_id = "1"

/obj/item/reagent_containers/ampoule/New()
	..()
	color_id = pick("1", "2", "3", "4")
	update_icon()

/obj/item/reagent_containers/ampoule/get_desc()
	if(reagents.total_volume > 0)
		. += "<br>It contains [reagents.total_volume] units."
	else
		. += "<br>It's empty."

/obj/item/reagent_containers/ampoule/proc/update_icon()
	if(icon_state != "amp-[color_id]")
		icon_state = "amp-[color_id]"

/obj/item/reagent_containers/ampoule/attack(mob/M, mob/user)
	if(expended || reagents.total_volume <= 0)
		boutput(user, "<span class='alert'>[src] is empty!</span>")
		return
	else if(M == user)
		boutput(user, "<span class='notice'>You crack open and inhale [src].</span>")
	else
		user.visible_message("<span class='alert'>[user] attempts to force [M] to inhale [src]!</span>")
		logTheThing("combat", user, M, "tries to make [constructTarget(M,"combat")] inhale [src] [log_reagents(src)] at [log_loc(user)].")
		if(!do_mob(user, M))
			if(user && ismob(user))
				boutput(user, "<span class='alert'>You were interrupted!</span>")
			return
		user.visible_message("<span class='alert'>[user] forces [M] to inhale [src]!</span>", \
								"<span class='alert'>You force [M] to inhale [src]!</span>")
	logTheThing("combat", user, M, "[user == M ? "inhales" : "makes [constructTarget(M,"combat")] inhale"] an ampoule [log_reagents(src)] at [log_loc(user)].")
	reagents.trans_to(M, 5)
	reagents.reaction(M, INGEST)
	expended = TRUE
	icon_state = "amp-broken"
	playsound(user.loc, "sound/effects/snap.ogg", 50, 1)
	return

//ampoule types

/obj/item/reagent_containers/ampoule/smelling_salts
	name = "ampoule (smelling salts)"

/obj/item/reagent_containers/ampoule/smelling_salts/New()
	..()
	reagents.add_reagent("smelling_salt", 5)
