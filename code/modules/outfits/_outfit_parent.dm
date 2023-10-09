/** ====== OUTFIT DATUM ======
 * A datum which stores an outfit that can be applied to humans
 * Allows for you to have clothing to equip on corpses / spawns without a job
 */
/datum/outfit
	var/outfit_name = "outfit"

	// Following slots support single item list or weighted list - Do not use regular lists or it will error!
	var/list/slot_head = list()
	var/list/slot_mask = list()
	var/list/slot_eyes = list()
	var/list/slot_ears = list()
	var/list/slot_outer = list()
	var/list/slot_under = list()
	var/list/slot_back = list()
	var/list/slot_belt = list()
	var/list/slot_gloves = list()
	var/list/slot_shoes = list()
	var/list/left_hand = list()
	var/list/right_hand = list()
	var/list/left_pocket = list()
	var/list/right_pocket = list()

	// These are just normal lists, bare in mind the normal 7 item limit.
	var/list/backpack_items = list()
	var/list/belt_items = list()

/mob/living/carbon/human/proc/equip_outfit(var/datum/outfit/outfit)
	// Jumpsuit - Important! Must be equipped early to provide valid slots for other items
	var/datum/outfit/equip = new outfit()
	if (!isnull(equip))
		return
	if (equip.slot_under && length(equip.slot_under) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_under), SLOT_W_UNIFORM)
	else if (length(equip.slot_under))
		src.equip_new_if_possible(equip.slot_under[1], SLOT_W_UNIFORM)
	// Backpack and contents
	if (equip.slot_back && length(equip.slot_back) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_back), SLOT_BACK)
	else if (length(equip.slot_back))
		src.equip_new_if_possible(equip.slot_back[1], SLOT_BACK)
	if (equip.slot_back && length(equip.backpack_items))
		for (var/X in equip.backpack_items)
			if(ispath(X))
				src.equip_new_if_possible(X, SLOT_IN_BACKPACK)
	// Belt and contents
	if (equip.slot_belt && length(equip.slot_belt) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_belt), SLOT_BELT)
	else if (length(equip.slot_belt))
		src.equip_new_if_possible(equip.slot_belt[1], SLOT_BELT)
	if (equip.slot_belt && length(equip.belt_items) && src.belt?.storage)
		for (var/X in equip.belt_items)
			if(ispath(X))
				src.equip_new_if_possible(X, SLOT_IN_BELT)
	// Footwear
	if (equip.slot_shoes && length(equip.slot_shoes) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_shoes), SLOT_SHOES)
	else if (length(equip.slot_shoes))
		src.equip_new_if_possible(equip.slot_shoes[1], SLOT_SHOES)
	// Suit
	if (equip.slot_outer && length(equip.slot_outer) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_outer), SLOT_WEAR_SUIT)
	else if (length(equip.slot_outer))
		src.equip_new_if_possible(equip.slot_outer[1], SLOT_WEAR_SUIT)
	// Ears
	if (equip.slot_ears && length(equip.slot_ears) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_ears), SLOT_EARS)
	else if (length(equip.slot_ears))
		if (!(src.traitHolder && src.traitHolder.hasTrait("allears") && ispath(equip.slot_ears[1],
	list(/obj/item/device/radio/headset))))
			src.equip_new_if_possible(equip.slot_ears[1], SLOT_EARS)
	// Mask
	if (equip.slot_mask && length(equip.slot_mask) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_mask), SLOT_WEAR_MASK)
	else if (length(equip.slot_mask))
		src.equip_new_if_possible(equip.slot_mask[1], SLOT_WEAR_MASK)
	// Gloves
	if (equip.slot_gloves && length(equip.slot_gloves) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_gloves), SLOT_GLOVES)
	else if (length(equip.slot_gloves))
		src.equip_new_if_possible(equip.slot_gloves[1], SLOT_GLOVES)
	// Eyes
	if (equip.slot_eyes && length(equip.slot_eyes) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_eyes), SLOT_GLASSES)
	else if (length(equip.slot_eyes))
		src.equip_new_if_possible(equip.slot_eyes[1], SLOT_GLASSES)
	// Head
	if (equip.slot_head && length(equip.slot_head) > 1)
		src.equip_new_if_possible(weighted_pick(equip.slot_head), SLOT_HEAD)
	else if (length(equip.slot_head))
		src.equip_new_if_possible(equip.slot_head[1], SLOT_HEAD)
	// Left pocket
	if (equip.left_pocket && length(equip.left_pocket) > 1)
		src.equip_new_if_possible(weighted_pick(equip.left_pocket), SLOT_L_STORE)
	else if (length(equip.left_pocket))
		src.equip_new_if_possible(equip.left_pocket[1], SLOT_L_STORE)
	// Right pocket
	if (equip.right_pocket && length(equip.right_pocket) > 1)
		src.equip_new_if_possible(weighted_pick(equip.right_pocket), SLOT_R_STORE)
	else if (length(equip.right_pocket))
		src.equip_new_if_possible(equip.right_pocket[1], SLOT_R_STORE)
	// Left hand
	if (equip.left_hand && length(equip.left_hand) > 1)
		src.equip_new_if_possible(weighted_pick(equip.left_pocket), SLOT_L_HAND)
	else if (length(equip.left_hand))
		src.equip_new_if_possible(equip.left_hand[1], SLOT_L_HAND)
	// Right hand
	if (equip.right_hand && length(equip.right_hand) > 1)
		src.equip_new_if_possible(weighted_pick(equip.left_pocket), SLOT_R_HAND)
	else if (length(equip.right_hand))
		src.equip_new_if_possible(equip.right_hand[1], SLOT_R_HAND)

#ifdef APRIL_FOOLS
	src.back?.setMaterial(getMaterial("jean"))
	src.gloves?.setMaterial(getMaterial("jean"))
	src.wear_suit?.setMaterial(getMaterial("jean"))
	src.wear_mask?.setMaterial(getMaterial("jean"))
	src.w_uniform?.setMaterial(getMaterial("jean"))
	src.shoes?.setMaterial(getMaterial("jean"))
	src.head?.setMaterial(getMaterial("jean"))
#endif
