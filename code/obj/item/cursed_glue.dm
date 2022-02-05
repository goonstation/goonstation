/obj/item/cursed_glue
	name = "cursed glue"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cursed_glue"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "glue"
	flags = FPRINT | TABLEPASS | ONBELT
	w_class = W_CLASS_TINY
	desc = "Impossibly sticky and very illegal glue."
	var/uses = 5
	var/gluing = TRUE

	get_desc()
		return "There's enough left to glue [uses] more items."

	attack_self(mob/user)
		. = ..()
		flip_sprite()
		if (gluing)
			gluing = FALSE
			user.show_message("The glue will now remove curses.")
		else
			gluing = TRUE
			user.show_message("The glue will now glue.")

	proc/flip_sprite()
		animate(src, transform = matrix(src.transform, 90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = FALSE, flags = ANIMATION_PARALLEL)
		sleep(0.1 SECONDS)
		animate(src, transform = matrix(src.transform, 90, MATRIX_ROTATE), time = 0.1 SECONDS, loop = FALSE, flags = ANIMATION_PARALLEL)

	attack(mob/target, mob/user)
		if (uses <= 0 && gluing)
			user.show_message("<span class='alert'>The glue is empty!</span>")
			return
		if (target == user)
			user.show_message("You probably shouldn't sniff this.")
			return
		if (!ishuman(target))
			return

		if (gluing)
			try_glue(target, user)
		else
			try_unglue(target, user)


	proc/try_glue(mob/living/carbon/human/target, mob/living/carbon/human/user)
		var/obj/item/item = src.get_target_item(target, user)

		if (isnull(item) || !istype(item, /obj/item))
			user.show_message("<span class='alert'>There's nothing there to glue.</span>")
			return
		if (item.cant_self_remove && item.cant_other_remove)
			user.show_message("<span class='alert'>[item] is already cursed.</span>")
			return
		user.visible_message("<span class='alert'>[user] glues [item] onto [target].</span>",\
			"<span class='alert'>You glue [item] onto [target].</span>")
		logTheThing("combat", user, target, "[user] glues [item] onto [target] at [log_loc(user)]")
		item.cant_self_remove = TRUE
		item.cant_other_remove = TRUE
		uses--

	proc/get_target_item(mob/living/carbon/human/target, mob/living/carbon/human/user)
		var/targetZone = user.zone_sel.selecting
		//welcome to the nested ternaries zone
		if (targetZone == "chest")
			//outer suit -> jumpsuit
			return target.wear_suit ? target.wear_suit : target.w_uniform ? target.w_uniform : null
		else if (targetZone == "head")
			//helmet -> mask -> glasses
			return target.head ? target.head : target.wear_mask ? target.wear_mask : target.glasses ? target.glasses : null
		else if (targetZone == "l_arm" || targetZone ==  "r_arm")
			return target.gloves
		else if (targetZone == "l_leg" || targetZone == "r_leg")
			return target.shoes

	proc/try_unglue(mob/living/carbon/human/target, mob/living/carbon/human/user)
		//exceptions for where this would break things that should not be broken
		if (iscluwne(target) || isslasher(target) || ishorse(target) || iswaldo(target))
			user.show_message("<span class='alert'>That curse is too strong.</span>")
			return
		if (!target?.hud)
			return
		for (var/obj/item/item in target.hud.inventory_items)
			if (item.cant_drop)
				continue
			item.cant_self_remove = FALSE
			item.cant_other_remove = FALSE
		user.visible_message("<span class='alert'>[user] Attempts to purge curses from [target]'s clothes.</span>",\
		"<span class='alert'>You attempt to remove curses from [target]'s clothes.</span>")
