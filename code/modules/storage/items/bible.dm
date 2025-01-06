/* ================================================================== */
/* ---------------------STORAGE DATUM FOR BIBLES--------------------- */
/* ================================================================== */

var/global/list/bible_contents = list()

/datum/storage/bible
	// stored item list and bible_contents can be read interchangeably

/datum/storage/bible/New()
	..()

	for (var/obj/item/I as anything in bible_contents)
		src.stored_items += I
		src.hud.add_item(I)

	if (istype(src.linked_item, /obj/item))
		var/obj/item/W = src.linked_item
		W.tooltip_rebuild = TRUE

	LAZYLISTADDUNIQUE(src.prevent_holding, /obj/item/bible)

/datum/storage/bible/add_contents(obj/item/I, mob/user = null, visible = TRUE)
	if (I in user?.equipped_list())
		user.u_equip(I)
	for_by_tcl(bible, /obj/item/bible)
		bible.storage.stored_items += I
		bible.storage.hud.add_item(I, user)
		bible.tooltip_rebuild = TRUE
	bible_contents += I
	I.set_loc(src.linked_item)
	I.stored = src

	src.add_contents_extra(I, user, visible)

/datum/storage/bible/transfer_stored_item(obj/item/I, atom/location, add_to_storage = FALSE, mob/user = null)
	if (!(I in src.stored_items))
		return
	for_by_tcl(bible, /obj/item/bible)
		bible.storage.stored_items -= I
		bible.storage.hud.remove_item(I, user)
		bible.tooltip_rebuild = TRUE
	bible_contents -= I
	I.stored = null

	src.transfer_stored_item_extra(I, location, add_to_storage, user)
