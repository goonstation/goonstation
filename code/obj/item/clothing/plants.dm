/obj/item/clothing/head/rafflesia
	name = "rafflesia"
	desc = "Usually referred to as corpseflower due to its horrid odor. Perfect for masking the smell of your stinky head."
	icon_state = "rafflesiahat"
	item_state = "rafflesiahat"

/obj/item/clothing/head/flower
	name = "flower"
	desc = "A pretty nice flower... you shouldn't see this, though."
	icon_state = "flower_gard"
	item_state = "flower_gard"

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		HYPadd_harvest_reagents(src,origin_plant,passed_genes,quality_status)
		return src


/obj/item/clothing/head/flower/gardenia
	name = "gardenia"
	desc = "A delicate flower from the Gardenia shrub native to Earth, trimmed for you to wear. These white flowers are known for their strong and sweet floral scent."
	icon_state = "flower_gard"
	item_state = "flower_gard"

/obj/item/clothing/head/flower/bird_of_paradise
	name = "bird of paradise"
	desc = "Bird of Paradise flowers, or Crane Flowers, are named for their resemblance to the ACTUAL birds of the same name. Both look great sitting on your head either way."
	icon_state = "flower_bop"
	item_state = "flower_bop"

/obj/item/clothing/head/flower/hydrangea
	name = "hydrangea"
	desc = " Hydrangea act as natural pH indicators, sporting blue flowers when the soil is acidic and pink ones when the soil is alkaline. Popular ornamental flowers due to their colourful, pastel flower arrangements; this one has been trimmed nicely for wear as an accessory."
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
	desc = "Lavender is usually used as an ingredient or as a source of essential oil; you can tuck a sprig behind your ear for that garden aesthetic too."
	icon_state = "flower_lav"
	item_state = "flower_lav"

	New()
		src.create_reagents(100)
		..()

// Pumpkin hats

/obj/item/clothing/head/pumpkinlatte
	name = "carved spiced pumpkin"
	desc = "Cute!"
	icon_state = "pumpkinlatte"
	c_flags = COVERSEYES | COVERSMOUTH
	see_face = FALSE
	item_state = "pumpkinlatte"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/light/flashlight))
			user.visible_message("[user] adds [W] to [src].", "You add [W] to [src].")
			W.name = copytext(src.name, 8) + " lantern"	// "carved "
			W.desc = "Cute!"
			W.icon = 'icons/misc/halloween.dmi'
			W.icon_state = "flight[W:on]"
			W.item_state = "pumpkin"
			qdel(src)
		else
			. = ..()


/obj/item/clothing/head/pumpkin
	name = "carved pumpkin"
	desc = "Spookier!"
	icon_state = "pumpkin"
	c_flags = COVERSEYES | COVERSMOUTH
	see_face = FALSE
	item_state = "carved"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/light/flashlight))
			user.visible_message("[user] adds [W] to [src].", "You add [W] to [src].")
			W.name = copytext(src.name, 8) + " lantern"	// "carved "
			W.desc = "Spookiest!"
			W.icon = 'icons/misc/halloween.dmi'
			W.icon_state = "flight[W:on]"
			W.item_state = "lantern"
			W.transform = src.transform
			qdel(src)
		else
			..()
