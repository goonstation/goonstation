/* ================================================================== */
/* ---------------------STORAGE DATUM FOR BIBLES--------------------- */
/* ================================================================== */

/datum/storage/bible
	// stored item list and bible_contents can be read interchangeably

	add_contents(obj/item/I, mob/user = usr)
		I.dropped()
		for_by_tcl(bible, /obj/item/bible)
			bible.storage.stored_items += I
			bible.storage.hud.add_item(I, user)
		bible_contents += I
		I.set_loc(src.linked_item)
		I.stored = src

	transfer_stored_item(obj/item/I, atom/location, add_to_storage = FALSE, mob/user = usr)
		if (!(I in src.stored_items))
			return
		for_by_tcl(bible, /obj/item/bible)
			bible.storage.stored_items -= I
			bible.storage.hud.remove_item(I, user)
		bible_contents -= I
		I.stored = null

		if (location.storage && add_to_storage)
			location.storage.add_contents(I)
		else
			I.set_loc(location)
			if (isturf(location))
				I.dropped()
