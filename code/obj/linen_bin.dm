ABSTRACT_TYPE(/obj/linen_bin)
/obj/linen_bin
	name = "bin"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bedbin"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	anchored = ANCHORED

	var/amount = 23
	var/obj/item/stored_itempath = null

/obj/linen_bin/attackby(obj/item/I, mob/user)
	if (istype(I, src.stored_itempath))
		var/old_amount = src.amount
		qdel(I)
		src.amount++
		boutput(user, "You place \the [I] into \the [src].")
		if (old_amount <= 0)
			src.UpdateIcon()

/obj/linen_bin/attack_hand(mob/user)
	add_fingerprint(user)
	if (src.amount >= 1)
		src.amount--
		var/obj/item/linen = new stored_itempath(src.loc)
		user.put_in_hand_or_drop(linen)
		if (src.amount <= 0)
			src.UpdateIcon()
	else
		boutput(user, SPAN_ALERT("There's no [stored_itempath::name][s_es(src.amount)] left in [src]!"))

/obj/linen_bin/get_desc(dist, mob/user)
	. += "There's [src.amount ? src.amount : "no"] [stored_itempath::name][s_es(src.amount)] in [src]."

/obj/linen_bin/update_icon()
	if (src.amount == 0)
		src.icon_state = "bedbin0"
	else
		src.icon_state = "bedbin"

/obj/linen_bin/bedsheet
	name = "linen bin"
	desc = "A bin for containing bedsheets."
	stored_itempath = /obj/item/clothing/suit/bedsheet

/obj/linen_bin/towel
	name = "towel bin"
	desc = "A bin for containing towels."
	stored_itempath = /obj/item/clothing/under/towel
