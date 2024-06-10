/datum/storage/lanyard

/datum/storage/lanyard/check_can_hold(obj/item/W)
	. = ..()
	if (. != STORAGE_CAN_HOLD)
		return
	if (istype(W, /obj/item/card/id) && (locate(/obj/item/card/id) in src.get_contents()))
		return STORAGE_CANT_HOLD

/datum/storage/lanyard/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (!istype(I, /obj/item/card/id))
		return
	var/obj/item/clothing/lanyard/lanyard = src.linked_item
	lanyard.copy_access(I)
	lanyard.update_wearer_name()

/datum/storage/lanyard/transfer_stored_item_extra(obj/item/I, atom/location, add_to_storage, mob/user)
	..()
	if (!istype(I, /obj/item/card/id))
		return
	var/obj/item/clothing/lanyard/lanyard = src.linked_item
	lanyard.copy_access(null)
	lanyard.update_wearer_name()
