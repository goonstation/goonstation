/* ================================================================== */
/* ---------------------STORAGE DATUM FOR HOLY TEXTS--------------------- */
/* ================================================================== */

var/global/list/holy_texts_contents = list()

/datum/storage/holy_texts
	// stored item list and holy_texts_contents can be read interchangeably

/datum/storage/holy_texts/New()
	..()

	for (var/obj/item/I as anything in holy_texts_contents)
		src.stored_items += I
		src.hud.add_item(I)

	if (istype(src.linked_item, /obj/item))
		var/obj/item/W = src.linked_item
		W.tooltip_rebuild = TRUE

/datum/storage/holy_texts/add_contents(obj/item/I, mob/user = null, visible = TRUE)
	if (I in user?.equipped_list())
		user.u_equip(I)
	for_by_tcl(holy_texts, /obj/item/holy_texts)
		holy_texts.storage.stored_items += I
		holy_texts.storage.hud.add_item(I, user)
		holy_texts.tooltip_rebuild = TRUE
	holy_texts_contents += I
	I.set_loc(src.linked_item)
	I.stored = src

	src.add_contents_extra(I, user, visible)

/datum/storage/holy_texts/transfer_stored_item(obj/item/I, atom/location, add_to_storage = FALSE, mob/user = null)
	if (!(I in src.stored_items))
		return
	for_by_tcl(holy_texts, /obj/item/holy_texts)
		holy_texts.storage.stored_items -= I
		holy_texts.storage.hud.remove_item(I, user)
		holy_texts.tooltip_rebuild = TRUE
	holy_texts_contents -= I
	I.stored = null

	src.transfer_stored_item_extra(I, location, add_to_storage, user)
