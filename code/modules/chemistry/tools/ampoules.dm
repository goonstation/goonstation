/obj/item/reagent_containers/ampoule
	name = "ampoule"
	desc = "A chemical-containing ampoule."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "ampoule-0"
	initial_volume = 5
	flags = TABLEPASS
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
	if(target == user)
		boutput(user, SPAN_NOTICE("You crack open and inhale [src]."))
		user.inhale_ampoule(src, user)
	else
		user.visible_message(SPAN_ALERT("[user] attempts to force [target] to inhale [src]!"))
		SETUP_GENERIC_ACTIONBAR(user, target, 3 SECONDS, /mob/proc/inhale_ampoule, list(src, user), src.icon, src.icon_state, null, \
			list(INTERRUPT_MOVE, INTERRUPT_ATTACKED, INTERRUPT_STUNNED, INTERRUPT_ACTION))

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
