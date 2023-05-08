/mob/living/carbon/human/proc/show_inv(mob/user as mob)
	src.inventory.ui_interact(user)

/mob/living/carbon/human/proc/update_inv()
	tgui_process.update_uis(src.inventory)

/// Get list of slots obstructed by other items
/mob/living/carbon/human/proc/get_obstructed_slots()
	var/list/obstructed_slots = list()
	var/item_flags = null

	for(var/obj/item/clothing/I in get_worn_items())
		item_flags |= I.obstructs

	if(item_flags & C_GLASSES)
		obstructed_slots |= "slot_glasses"
	if(item_flags & C_MASK)
		obstructed_slots |= "slot_wear_mask"
	if(item_flags & C_EARS)
		obstructed_slots |= "slot_ears"
	if(item_flags & C_UNIFORM)
		obstructed_slots |= "slot_w_uniform"
	if(item_flags & C_SHOES)
		obstructed_slots |= "slot_shoes"
	if(item_flags & C_GLOVES)
		obstructed_slots |= "slot_gloves"

	return obstructed_slots

///Get all items as a list in worn slots
/mob/living/carbon/human/proc/get_worn_items()
	return list(
		src.head,
		src.belt,
		src.ears,
		src.gloves,
		src.shoes,
		src.glasses,
		src.back,
		src.w_uniform,
		src.wear_mask,
		src.wear_suit,
		src.wear_id
	)

///Check the inventory slot against the list of obstructed slots
/mob/living/carbon/human/proc/check_obstructed(var/id)
	if(id in get_obstructed_slots())
		return TRUE

/mob/living/carbon/human/proc/obstructed_by(var/slot)
	var/list/head_slots = list(SLOT_EARS, SLOT_GLASSES, SLOT_WEAR_MASK)
	if(slot in head_slots)
		if (src.head && src.head.obstructs & C_MASK) // if a head item is covering the mask its probably covering the entire head
			return src.head
		else if (src.wear_suit && src.wear_suit.obstructs & (C_MASK | C_GLASSES | C_EARS)) // for bedsheets, rando cloak, ect. they are the only wear_suit items to cover heads.
			return src.wear_suit
		else
			return src.wear_mask
	else
		return src.wear_suit // body slots blocked by body item
