// allows first aid kits to hold pill bottles
/datum/storage/firstaid

/datum/storage/firstaid/check_can_hold(obj/item/W)
	. = ..()
	if(istype(W, /obj/item/storage/pill_bottle))
		return src.get_fullness(W)
