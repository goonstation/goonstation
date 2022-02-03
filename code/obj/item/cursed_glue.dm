/obj/item/cursed_glue
	name = "cursed glue"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cursed_glue"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "glue"
	flags = FPRINT | TABLEPASS | ONBELT
	w_class = W_CLASS_TINY
	desc = "Impossibly sticky and very illegal glue."
	var/uses = 3

	get_desc()
		return "There's enough left to glue [uses] more items."

	attack(mob/target, mob/user)
		if (uses <= 0)
			user.show_message("<span class='alert'>The glue is empty!</span>")
			return
		if (target == user)
			user.show_message("You probably shouldn't sniff this.")
			return
		if (!ishuman(target))
			return

		var/obj/item/item = src.get_target_item(target, user)

		if (isnull(item) || !istype(item, /obj/item))
			user.show_message("<span class='alert'>There's nothing there to glue.</span>")
			return
		if (item.cant_self_remove && item.cant_other_remove)
			user.show_message("<span class='alert'>[item] is already cursed.</span>")
		user.visible_message("<span class='alert'>[user] glues [item] onto [target].</span>",\
			"<span class='alert'>You glue [item] onto [target].</span>")
		logTheThing("combat", user, target, "[user] glues [item] onto [target] at [log_loc(user)]")
		var/self = item.cant_self_remove
		var/other = item.cant_other_remove
		item.cant_self_remove = TRUE
		item.cant_other_remove = TRUE
		uses--
		SPAWN_DBG(rand(5, 10) SECONDS)
			if (!item)
				return
			item.cant_self_remove = self
			item.cant_other_remove = other
			if (item.loc && istype(item.loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/owner = item.loc
				owner.show_message("[item] is no longer glued to you.")


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
