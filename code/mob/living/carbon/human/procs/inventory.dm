/mob/living/carbon/human/proc/show_inv(mob/user as mob)
	src.inventory.ui_interact(user)

/mob/living/carbon/human/proc/update_inv()
	tgui_process.update_uis(src.inventory)

/// Get list of slots obstructed by other items
/mob/living/carbon/human/proc/GetObstructedSlots()
	var/list/obsctructedSlots = list()
	var/ItemFlags = null

	for(var/obj/item/clothing/I in GetWornItems())
		ItemFlags |= I.obstructs

	if(ItemFlags & C_GLASSES)
		obsctructedSlots |= SLOT_GLASSES
	if(ItemFlags & C_MASK)
		obsctructedSlots |= SLOT_WEAR_MASK
	if(ItemFlags & C_EARS)
		obsctructedSlots |= SLOT_EARS
	if(ItemFlags & C_UNIFORM)
		obsctructedSlots |= SLOT_W_UNIFORM
	if(ItemFlags & C_SHOES)
		obsctructedSlots |= SLOT_SHOES
	if(ItemFlags & C_GLOVES)
		obsctructedSlots |= SLOT_GLOVES

	return obsctructedSlots

///Get all items as a list in worn slots
/mob/living/carbon/human/proc/GetWornItems()
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
/mob/living/carbon/human/proc/CheckObstructed(var/id)
	for (var/obj/slot as anything in GetObstructedSlots())
		if(id == slot)
			return TRUE
