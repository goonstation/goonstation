/obj/item/clothing/head/flower/lavender
	name = "lavender"
	desc = "Lavender is usually used as an ingredient or as a source of essential oil; you can tuck a sprig behind your ear for that garden aesthetic too."
	icon_state = "flower_lav"
	item_state = "flower_lav"
	planttype = /datum/plant/herb/lavender

	attackby(obj/item/W, mob/user)
		if istype(W, /obj/item/paper)
			user.visible_message("[user] roll up the [src] into a bouquet.", "You roll up the [src].")
			var/obj/item/bouquet/lavender/P = new(get_turf(user))
			qdel(src)

/obj/item/bouquet/lavender
	name = "lavender bouquet"
	desc = "They smell pretty, and the purple can't be beat."
	icon_state = "bouquet_lavender"
	item_state = "bouquet_lavender"
