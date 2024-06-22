/* ================================================================== */
/* -------------------STORAGE DATUM FOR TERMINII--------------------- */
/* -----------------totally not just the bible code------------------ */
/* ================================================================== */

var/global/list/terminus_storage = list()

/datum/storage/terminus
	// unlike bibles, contents don't actually exist in the terminus while it's unsynchronized

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
	for (var/obj/item/I as anything in terminus_storage)
		src.stored_items -= I
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
	if (!(I in src.stored_items))
		return
	for_by_tcl(terminus, /obj/item/terminus_drive)
		if(terminus.synchronized)
			terminus.storage.stored_items -= I
			terminus.storage.hud.remove_item(I, user)
			terminus.tooltip_rebuild = TRUE
	terminus_storage -= I
	I.stored = null

	src.transfer_stored_item_extra(I, location, add_to_storage, user)

/datum/storage/terminus/storage_item_attack_hand(mob/user)
	if(!linked_item:synchronized)
		return FALSE
	..()

/datum/storage/terminus/storage_item_after_attack(atom/target, mob/user, reach)
	if(!linked_item:synchronized)
		return FALSE
	..()
