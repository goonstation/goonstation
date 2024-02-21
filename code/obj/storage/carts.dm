/obj/storage/cart
	name = "supply cart"
	desc = "A big rolling supply cart."
	is_short = 1
	icon_state = "cart"
	icon_closed = "cart"
	icon_opened = "cartopen"
	icon_welded = "welded-crate"
	soundproofing = 5
	throwforce = 50
	flip_health = 4
	can_flip_bust = 1
	p_class = 1.5
	var/obj/storage/cart/next_cart = null

	recalcPClass()
		var/maxPClass = 0
		for (var/atom/movable/O in contents)
			if (ishuman(O)) // can't use p_class for human mobs as we need to use the heavier one regardless of whether they're standing/lying down
				maxPClass = max(maxPClass, 3) //horay magic number
			else
				maxPClass = max(maxPClass, O.p_class)
		p_class = initial(p_class) + maxPClass / 2

/obj/storage/cart/mechcart
	name = "mechanics cart"
	desc = "A big rolling supply cart for station mechanics."
	icon_state = "mechcart"
	icon_closed = "mechcart"
	icon_opened = "mechcartopen"

/obj/storage/cart/medcart
	name = "medical cart"
	desc = "A big rolling supply cart for station medics."
	icon_state = "medcart"
	icon_closed = "medcart"
	icon_opened = "medcartopen"

/obj/storage/cart/forensic
	name = "forensics cart"
	desc = "A big rolling supply cart for crimescene forensics work."
	icon_state = "forensiccart"
	icon_closed = "forensiccart"
	icon_opened = "forensiccartopen"

/obj/storage/cart/trash
	name = "trash cart"
	desc = "Well at least you're in space, right?"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashcart"
	icon_closed = "trashcart"
	icon_opened = "trashcartopen"

/obj/storage/cart/trash/syndicate
	crunches_contents = 1

/obj/storage/cart/hotdog
	name = "hotdog stand"
	desc = "This will probably never be used to sell hotdogs."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "hotdogstand"
	icon_closed = "hotdogstand"
	icon_opened = "hotdogstandopen"

/obj/storage/cart/hotdog/syndicate
	crunches_contents = 1
	crunches_deliciously = 1
