/mob/living/carbon/human/proc/show_inv(mob/user as mob)
	src.inventory.ui_interact(user)

/mob/living/carbon/human/proc/update_inv()
	tgui_process.update_uis(src.inventory)

/// Get list of slots obstructed by other items
/mob/living/carbon/human/proc/get_obstructed_Slots()
	var/list/obsctructedSlots = list()
	var/ItemFlags = null

	for(var/obj/item/clothing/I in get_worn_items())
		ItemFlags |= I.obstructs

	if(ItemFlags & C_GLASSES)
		obsctructedSlots |= "slot_glasses"
	if(ItemFlags & C_MASK)
		obsctructedSlots |= "slot_wear_mask"
	if(ItemFlags & C_EARS)
		obsctructedSlots |= "slot_ears"
	if(ItemFlags & C_UNIFORM)
		obsctructedSlots |= "slot_w_uniform"
	if(ItemFlags & C_SHOES)
		obsctructedSlots |= "slot_shoes"
	if(ItemFlags & C_GLOVES)
		obsctructedSlots |= "slot_gloves"

	return obsctructedSlots

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
	if(id in get_obstructed_Slots())
		return TRUE

/mob/living/carbon/human/proc/obstructed_by(var/slot)
	var/list/headslots = list(SLOT_EARS, SLOT_GLASSES, SLOT_WEAR_MASK)
	if(slot in headslots)
		if (src.head && src.head.obstructs & C_MASK) // if a head item is covering the mask its probably covering the entire head
			return src.head
		else if (src.wear_suit && src.wear_suit.obstructs & (C_MASK | C_GLASSES | C_EARS)) // for bedsheets, rando cloak, ect. they are the only wear_suit items to cover heads.
			return src.wear_suit
		else
			return src.wear_mask
	else
		return src.wear_suit // body slots blocked by body item
