/obj/item/clothing/lanyard
	name = "lanyard"
	desc = "Only dorks wear these."
	icon = 'icons/obj/clothing/item_ids.dmi'
	wear_image_icon = 'icons/mob/clothing/card.dmi'
	icon_state = "lanyard"
	var/registered = null
	var/assignment = null
	var/access = list()

	New()
		..()
		src.create_storage(/datum/storage/lanyard, max_wclass = W_CLASS_TINY, slots = 3, opens_if_worn = TRUE)

	attackby(obj/item/W, mob/user, params)
		if (!istype(W, /obj/item/card/id) || user.equipped() != W)
			return ..()
		var/obj/item/card/id/stored_id = src.get_stored_id()
		if (!stored_id)
			return ..()

		stored_id.set_loc(get_turf(src))
		W.set_loc(get_turf(src))

		boutput(user, SPAN_NOTICE(">You swap the held ID with the ID in the lanyard."))
		src.storage.add_contents(W, user, FALSE)
		user.put_in_hand_or_drop(stored_id)

	proc/get_stored_id()
		for (var/obj/item/card/id/id in src.storage.get_contents())
			return id

	// id_card can be null to reset access
	proc/copy_access(obj/item/card/id/id_card)
		src.registered = id_card?.registered
		src.assignment = id_card?.assignment
		src.access = id_card?.access || list()

	proc/update_wearer_name()
		var/mob/living/carbon/human/H = src.loc
		if (!istype(H))
			return
		if (H.wear_id == src)
			H.UpdateName()

	verb/eject()
		set name = "Eject lanyard ID"
		set desc = "Eject the currently loaded ID card from this lanyard."
		set category = "Local"
		set src in usr

		if (is_incapacitated(usr))
			return

		usr.put_in_hand_or_drop(src.get_stored_id())
