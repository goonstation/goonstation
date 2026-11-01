/* ================================================================== */
/* -------------------STORAGE DATUM FOR TERMINII--------------------- */
/* -----------------totally not just the bible code------------------ */
/* ================================================================== */

var/global/list/terminus_storage = list()

/datum/storage/terminus
	// unlike bibles, contents don't accessibly exist in each terminus while it's unsynchronized
	// and a detonation or other such effect will apply at the terminus an item was most recently placed into

///Brings an individual terminus that's being activated up to date with the terminus storage in The Cloud(TM)
/datum/storage/terminus/proc/synchronize()
	for (var/obj/item/I as anything in terminus_storage)
		src.stored_items += I
		src.hud.add_item(I)

	if (istype(src.linked_item, /obj/item))
		var/obj/item/W = src.linked_item
		W.tooltip_rebuild = TRUE

	linked_item:synchronized = TRUE

///Unlinks an individual terminus from other terminii
/datum/storage/terminus/proc/desync()
	for (var/obj/item/I as anything in src.stored_items)
		src.stored_items -= I
		src.hud.remove_item(I)
	src.hide_all_huds()

	linked_item:synchronized = FALSE

/datum/storage/terminus/add_contents(obj/item/I, mob/user = null, visible = TRUE)
	if (I in user?.equipped_list())
		user.u_equip(I)
	for_by_tcl(terminus, /obj/item/terminus_drive)
		if(terminus.synchronized)
			terminus.storage.stored_items += I
			terminus.storage.hud.add_item(I, user)
			terminus.tooltip_rebuild = TRUE
	terminus_storage += I
	I.set_loc(src.linked_item)
	I.stored = src

	src.add_contents_extra(I, user, visible)

/datum/storage/terminus/transfer_stored_item(obj/item/I, atom/location, add_to_storage = FALSE, mob/user = null)
	if (!(I in terminus_storage))
		return
	for_by_tcl(terminus, /obj/item/terminus_drive)
		if(terminus.synchronized)
			terminus.storage.stored_items -= I
			terminus.storage.hud.remove_item(I, user)
			terminus.tooltip_rebuild = TRUE
	terminus_storage -= I
	I.stored = null

	src.transfer_stored_item_extra(I, location, add_to_storage, user)

//don't allow storage interaction while terminus is shut

/datum/storage/terminus/storage_item_attack_by(obj/item/W,mob/user)
	if(!linked_item:synchronized)
		return TRUE
	..()

/datum/storage/terminus/storage_item_attack_hand(mob/user)
	if(!linked_item:synchronized)
		return FALSE
	..()

/datum/storage/terminus/storage_item_after_attack(atom/target, mob/user, reach)
	if(!linked_item:synchronized)
		return FALSE
	..()

//fully overridden to allow fine-grained behavior and prevent contents dumping
/datum/storage/terminus/storage_item_mouse_drop(mob/user, atom/over_object, src_location, over_location)
	// if mouse dropping storage item onto a hand slot, attempt to hold it
	if (istype(over_object, /atom/movable/screen/hud))
		var/atom/movable/screen/hud/S = over_object
		playsound(src.linked_item.loc, "rustle", 50, TRUE, -5)
		if (!user.restrained() && !is_incapacitated(user) && src.linked_item.loc == user)
			if (S.id == "rhand" && !user.r_hand)
				user.u_equip(src.linked_item)
				user.put_in_hand_or_drop(src.linked_item)
			else if (S.id == "lhand" && !user.l_hand)
				user.u_equip(src.linked_item)
				user.put_in_hand_or_drop(src.linked_item)
	// if mouse dropping storage item onto self, look inside if it's open
	else if (over_object == user && in_interact_range(src.linked_item, user) && isliving(user) && !is_incapacitated(user) && !isintangible(user) && linked_item:synchronized)
		user.s_active?.master.hide_hud(user)
		if (src.mousetrap_check(user))
			return
		src.show_hud(user)
