/obj/item/reagent_containers/ampoule
	name = "ampoule"
	desc = "A chemical-containing ampoule."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "ampoule-0"
	initial_volume = 5
	flags = FPRINT | TABLEPASS
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	var/expended = FALSE //Whether or not the ampoule has been used.
	var/image/fluid_image

/obj/item/reagent_containers/ampoule/get_desc()
	if(reagents.total_volume > 0)
		. += "<br>It contains [reagents.total_volume] units."
	else
		. += "<br>It's empty."

/obj/item/reagent_containers/ampoule/New()
	..()
	UpdateIcon()

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
	playsound(user.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 50, 1)
	return

// based off of plants.dm
/obj/item/reagent_containers/ampoule/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/spacecash) || istype(W, /obj/item/paper))
		var/obj/item/clothing/mask/cigarette/custom/ampoule/C = new(user.loc)
    
		boutput(user, "<span class='alert'>You wrap the [src] in the [W].</span>")
		src.reagents.copy_to(C.ampoulereagents)
		src.reagents.trans_to(C, src.reagents.total_volume)
		C.name = src.build_name(W)
		C.ampoulename = src.name
		C.reagents.maximum_volume = src.reagents.total_volume
		C.ampoulecolor = src.color_id

		W.force_drop(user)
		src.force_drop(user)
		qdel(W)
		qdel(src)
		user.put_in_hand_or_drop(C)

	else if (istype(W, /obj/item/bluntwrap))
		var/obj/item/bluntwrap/B = W
		var/obj/item/clothing/mask/cigarette/cigarillo/ampoule/doink = new(user.loc)

		boutput(user, "<span class='alert'>You roll the [src] in the [W] and make a fat doink.</span>")
		doink.reagents.clear_reagents()
		if(B.flavor)
			doink.flavor = B.flavor
		src.reagents.copy_to(doink.ampoulereagents)
		src.reagents.trans_to(doink, src.reagents.total_volume)
		W.reagents.trans_to(doink, W.reagents.total_volume)
		doink.ampoulename = src.name
		doink.reagents.maximum_volume = (src.reagents.total_volume + 50)
		doink.name = "[reagent_id_to_name(doink.flavor)]-flavored [pick("doink","'Rillo","cigarillo","brumbpo")]"
		doink.ampoulecolor = src.color_id

		W.force_drop(user)
		src.force_drop(user)
		qdel(W)
		qdel(src)
		user.put_in_hand_or_drop(doink)

/obj/item/reagent_containers/ampoule/proc/build_name(obj/item/W)
	return "[istype(W, /obj/item/spacecash) ? "[W.amount]-credit " : ""][pick("joint","doobie","spliff","roach","blunt","roll","fatty","reefer")]"

/obj/item/reagent_containers/ampoule/on_reagent_change()
	..()
	src.UpdateIcon()

/obj/item/reagent_containers/ampoule/update_icon()
	src.underlays = null
	if (!src.fluid_image)
		src.fluid_image = image('icons/obj/chemical.dmi')
	src.fluid_image.icon_state = "ampoule_liquid"
	if(reagents.total_volume)
		var/datum/color/average = reagents.get_average_color()
		src.fluid_image.color = average.to_rgba()
		src.underlays += src.fluid_image
		icon_state = "ampoule-5"
		item_state = "ampoule-5"
	else
		icon_state = "ampoule-0"
		item_state = "ampoule-0"
	signal_event("icon_updated")


//ampoule types

/obj/item/reagent_containers/ampoule/smelling_salts
	name = "ampoule (smelling salts)"

/obj/item/reagent_containers/ampoule/smelling_salts/New()
	..()
	reagents.add_reagent("smelling_salt", 5)
