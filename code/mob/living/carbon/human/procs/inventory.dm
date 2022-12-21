/mob/living/carbon/human/proc/show_inv(mob/user as mob)
	src.inventory.ui_interact(user)

/mob/living/carbon/human/proc/update_inv()
	tgui_process.update_uis(src.inventory)

/// Check for slots obscured by other items
/mob/living/carbon/human/proc/CheckObsctructed()
	var/list/obsctructedItems = list()
	var/hiddenItem = null

	for(var/obj/item/clothing/I in src.GetWornItems())
		hiddenItem |= I.hides_from_examine

	if(hiddenItem & C_UNIFORM)
		obsctructedItems += SLOT_W_UNIFORM
	if(hiddenItem & C_SHOES)
		obsctructedItems += SLOT_SHOES
	if(hiddenItem & C_GLOVES)
		obsctructedItems += SLOT_GLOVES
	if(hiddenItem & C_GLASSES)
		obsctructedItems += SLOT_GLASSES
	if(hiddenItem & C_MASK)
		obsctructedItems += SLOT_WEAR_MASK
	if(hiddenItem & C_EARS)
		obsctructedItems += SLOT_EARS

	return obsctructedItems

/mob/living/carbon/human/proc/GetWornItems()
	return list(src.head,
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

