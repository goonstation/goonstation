/* ================================================================== */
/* ----------------STORAGE DATUM FOR UNHOLDABLE ATOMS---------------- */
/* ================================================================== */

// Large items, meaning storages that you can't hold, ex. wall cabinets

/datum/storage/unholdable

/datum/storage/unholdable/storage_item_attack_hand(mob/user)
	if (istype(user, /mob/living/critter/small_animal))
		return
	src.storage_item_mouse_drop(user, user)

/datum/storage/unholdable/storage_item_mouse_drop(mob/user, atom/over_object, src_location, over_location)
	if (istype(user, /mob/living/critter/small_animal))
		return
	..()
