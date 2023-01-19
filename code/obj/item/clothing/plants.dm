/obj/item/clothing/head/rafflesia
	name = "rafflesia"
	desc = "Usually reffered to as corpseflower due to its horrid odor, perfect for masking the smell of your stinky head."
	icon_state = "rafflesiahat"
	item_state = "rafflesiahat"

/obj/item/clothing/head/flower/gardenia
	name = "gardenia"
	desc = ""
	icon_state = "flower_gard"
	item_state = "flower_gard"

/obj/item/clothing/head/flower/bird_of_paradise
	name = "bird of paradise"
	desc = "Contrary to popular belief, this"
	icon_state = "flower_bop"
	item_state = "flower_bop"

/obj/item/clothing/head/flower/hydrangea
	name = "hydrangea"
	desc = ""
	icon_state = "flower_hyd"
	item_state = "flower_hyd"

/obj/item/clothing/head/flower/hydrangea/pink
	name = "pink hydrangea"
	icon_state = "flower_hyd-pink"
	item_state = "flower_hyd-pink"

/obj/item/clothing/head/flower/hydrangea/blue
	name = "blue hydrangea"
	icon_state = "flower_hyd-blue"
	item_state = "flower_hyd-blue"

/obj/item/clothing/head/flower/hydrangea/purple
	name = "purple hydrangea"
	icon_state = "flower_hyd-purple"
	item_state = "flower_hyd-purple"

/obj/item/clothing/head/flower/lavender
	name = "lavender"
	desc = ""
	icon_state = "flower_lav"
	item_state = "flower_lav"

	New()
		src.create_reagents(100)
		..()
