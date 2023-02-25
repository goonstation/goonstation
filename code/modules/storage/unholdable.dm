/* ================================================================== */
/* ----------------STORAGE DATUM FOR UNHOLDABLE ATOMS---------------- */
/* ================================================================== */

// Large items, meaning storages that you can't hold, ex. wall cabinets

/datum/storage/unholdable

/datum/storage/unholdable/storage_item_attack_hand(mob/user)
	src.storage_item_mouse_drop(user, user)
