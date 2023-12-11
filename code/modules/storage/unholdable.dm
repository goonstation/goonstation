/* ================================================================== */
/* ----------------STORAGE DATUM FOR UNHOLDABLE ATOMS---------------- */
/* ================================================================== */

// Large items, meaning storages that you can't hold, ex. wall cabinets

/datum/storage/unholdable
	/// Should this thing do the storage rustle when we use it?
	var/rustle = FALSE

/datum/storage/unholdable/New(atom/storage_item, list/spawn_contents, list/can_hold, list/can_hold_exact, list/prevent_holding, check_wclass, max_wclass, slots, sneaky, stealthy_storage, opens_if_worn, list/params)
	. = ..()
	src.rustle = params["rustle"]


/datum/storage/unholdable/storage_item_attack_hand(mob/user)
	if (istype(user, /mob/living/critter/small_animal))
		return
	if (src.rustle)
		animate_storage_rustle(src.linked_item)
		playsound(src.linked_item.loc, "rustle", 50, TRUE, -5)
	src.storage_item_mouse_drop(user, user)

/datum/storage/unholdable/storage_item_mouse_drop(mob/user, atom/over_object, src_location, over_location)
	if (istype(user, /mob/living/critter/small_animal))
		return
	..()
