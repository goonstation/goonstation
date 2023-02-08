/* ================================================================== */
/* ---------------------STORAGE DATUM FOR BIBLES--------------------- */
/* ================================================================== */

/datum/storage/bible
	// stored item list and bible_contents can be read interchangeably

	storage_item_attack_by(atom/source, obj/item/W, mob/user)
		if (istype(W, /obj/item/bible))
			user.show_text("You try to put \the [W] in \the [src.linked_item]. It doesn't work. You feel dumber.", "red")
			return TRUE
		return ..()

	storage_item_attack_hand(atom/source, mob/user)
		if (isvampire(user) || user.bioHolder.HasEffect("revenant"))
			user.visible_message("<span class='alert'><B>[user] tries to take the [src.linked_item], but their hand bursts into flames!</B></span>", \
				"<span class='alert'><b>Your hand bursts into flames as you try to take the [src.linked_item]! It burns!</b></span>")
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, 25)
			user.changeStatus("stunned", 15 SECONDS)
			user.changeStatus("weakened", 15 SECONDS)
			return TRUE
		return ..()

	add_contents(obj/item/I)
		I.dropped()
		for_by_tcl(bible, /obj/item/bible)
			bible.storage.stored_items += I
			bible.storage.hud.add_item(I)
		bible_contents += I
		I.set_loc(src.linked_item)
		I.stored = src

	transfer_stored_item(obj/item/I, atom/location, add_to_storage)
		if (!(I in src.stored_items))
			return
		for_by_tcl(bible, /obj/item/bible)
			bible.storage.stored_items -= I
			bible.storage.hud.remove_item(I)
		bible_contents -= I
		I.stored = null

		if (location.storage && add_to_storage)
			location.storage.add_contents(I)
		else
			I.set_loc(location)
			if (isturf(location))
				I.dropped()

/datum/storage/bible/loaded
	var/obj/item/gun/kinetic/faith/faith = null

	New(atom/storage_item, list/spawn_contents = list(), list/can_hold = list(), in_list_or_max = FALSE, max_wclass = W_CLASS_SMALL, slots = 7, sneaky = FALSE, does_not_open_in_pocket = FALSE)
		..()
		src.faith = new
		src.faith.set_loc(src.linked_item)

	disposing()
		if (src.faith.loc == src.linked_item)
			src.faith.set_loc(get_turf(src.linked_item))
		..()

	storage_item_attack_by(atom/source, obj/item/W, mob/user)
		if (istype(W, /obj/item/gun/kinetic/faith) && user.traitHolder?.hasTrait("training_chaplain"))
			user.u_equip(W)
			W.set_loc(src.linked_item)
			user.show_text("You hide [W] in \the [src.linked_item].", "blue")
			return TRUE
		return ..()

	storage_item_attack_hand(atom/source, mob/user)
		if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain") && user.is_in_hands(src.linked_item))
			var/obj/item/gun/kinetic/faith/F = locate() in src.linked_item.contents
			if (F)
				user.put_in_hand_or_drop(F)
				return TRUE
		return ..()
