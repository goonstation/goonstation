/* ================================================================== */
/* ---------------------STORAGE DATUM FOR BIBLES--------------------- */
/* ================================================================== */

var/global/list/bible_contents = list()

/datum/storage/bible
	// stored item list and bible_contents can be read interchangeably

	add_contents(obj/item/I, mob/user = usr, visible = TRUE)
		I.dropped()
		for_by_tcl(bible, /obj/item/bible)
			bible.storage.stored_items += I
			bible.storage.hud.add_item(I, user)
		bible_contents += I
		I.set_loc(src.linked_item)
		I.stored = src

		if (!istype(user))
			return
		src.linked_item.add_fingerprint(user)
		if (visible)
			animate_storage_rustle(src.linked_item)
			if (!src.sneaky && !istype(I, /obj/item/gun/energy/crossbow))
				user.visible_message("<span class='notice'>[user] has added [I] to [src.linked_item]!</span>",
					"<span class='notice'>You have added [I] to [src.linked_item].</span>")
			playsound(src.linked_item.loc, "rustle", 50, TRUE, -5)

	transfer_stored_item(obj/item/I, atom/location, add_to_storage = FALSE, mob/user = usr)
		if (!(I in src.stored_items))
			return
		for_by_tcl(bible, /obj/item/bible)
			bible.storage.stored_items -= I
			bible.storage.hud.remove_item(I, user)
		bible_contents -= I
		I.stored = null

		if (location.storage && add_to_storage)
			location.storage.add_contents(I, user)
		else
			I.set_loc(location)
			if (isturf(location))
				I.dropped()
