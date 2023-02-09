/* ================================================================== */
/* ----------------STORAGE DATUM FOR UNHOLDABLE ATOMS---------------- */
/* ================================================================== */

// Large items, meaning storages that you can't hold, ex. wall cabinets

/datum/storage/unholdable

	storage_item_attack_hand(atom/source, mob/user)
		return src.storage_item_mouse_drop(source, user, user)
