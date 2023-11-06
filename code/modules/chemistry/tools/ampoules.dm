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

/obj/item/reagent_containers/ampoule/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if(expended || reagents.total_volume <= 0)
		boutput(user, SPAN_ALERT("[src] is empty!"))
		return
	else if(target == user)
		boutput(user, SPAN_NOTICE("You crack open and inhale [src]."))
	else
		user.visible_message(SPAN_ALERT("[user] attempts to force [target] to inhale [src]!"))
		logTheThing(LOG_COMBAT, user, "tries to make [constructTarget(target,"combat")] inhale [src] [log_reagents(src)] at [log_loc(user)].")
		if(!do_mob(user, target))
			if(user && ismob(user))
				boutput(user, SPAN_ALERT("You were interrupted!"))
			return
		user.visible_message(SPAN_ALERT("[user] forces [target] to inhale [src]!"), \
								SPAN_ALERT("You force [target] to inhale [src]!"))
	logTheThing(LOG_COMBAT, user, "[user == target ? "inhales" : "makes [constructTarget(target,"combat")] inhale"] an ampoule [log_reagents(src)] at [log_loc(user)].")
	reagents.reaction(target, INGEST, 5, paramslist = list("inhaled"))
	reagents.trans_to(target, 5)
	expended = TRUE
	icon_state = "amp-broken"
	playsound(user.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
	return

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
