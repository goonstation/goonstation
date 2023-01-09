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
