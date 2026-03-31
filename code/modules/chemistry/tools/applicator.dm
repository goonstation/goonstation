// TODO: this should probably be the real path of shakers / condiment bottles
/obj/item/reagent_containers/applicator
	name = "chemical applicator"
	desc = "Applies some units of a thing topically. Comes with a cap."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spacelipstick0"
	incompatible_with_chem_dispensers = TRUE
	rand_pos = 1
	flags = TABLEPASS | SUPPRESSATTACK
	object_flags = NO_GHOSTCRITTER

	var/open = FALSE
	var/infinite = FALSE

	var/image/image_stick = null

	New(loc, new_initial_reagents)
		. = ..()
		UpdateIcon()

	update_icon()
		src.icon_state = "spacelipstick[src.open]"
		if (src.open)
			ENSURE_IMAGE(src.image_stick, src.icon, "spacelipstick")
			src.image_stick.color = src.reagents.get_average_rgb()
			src.UpdateOverlays(src.image_stick, "stick")
		else
			src.UpdateOverlays(null, "stick")

	attack_self(var/mob/user)
		src.open = !src.open
		src.UpdateIcon()

	afterattack(atom/target, mob/user, reach, params)
		user.lastattacked = get_weakref(target)
		if (src.open)
			if (src.reagents?.total_volume)
				user.visible_message(
					SPAN_NOTICE("[user] applies some of [src] to [target]."),
					SPAN_NOTICE("You apply some of [src] to [target]."),
				)
				src.reagents.reaction(target, TOUCH, min(src.amount_per_transfer_from_this, src.reagents.total_volume), paramslist = list("nopenetrate"))
				if (!src.infinite)
					src.reagents.remove_any(src.amount_per_transfer_from_this)
				src.UpdateIcon()
			else
				boutput(user, SPAN_ALERT("[src] is empty!"))
			return
		. = ..()

/obj/item/reagent_containers/applicator/glue
	name = "glue stick"
	desc = "It's a stick. Of glue. Glue stick."
	initial_reagents = list("spaceglue" = 30)

/obj/item/reagent_containers/applicator/glue/infinite
	name = "really big glue stick"
	desc = "It's a stick. Of glue. Glue stick. This one looks really long."
	infinite = TRUE
