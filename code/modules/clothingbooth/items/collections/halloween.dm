#ifdef HALLOWEEN

/* ------------------------ Masks ------------------------ */
/datum/clothingbooth_item/mask/tengumask
	cost = PAY_TRADESMAN/2
	item_path = /obj/item/clothing/mask/tengu

/* ------------------------- Head ------------------------ */
/datum/clothingbooth_item/head/giraffehat
	item_path = /obj/item/clothing/head/giraffehat

/datum/clothingbooth_item/head/axehat
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/head/axehat

ABSTRACT_TYPE(/datum/clothingbooth_item/head/beetlehat)
/datum/clothingbooth_item/head/beetlehat

	rhinobeetle
		name = "Rhino Beetle"
		swatch_background_color = "#63a5ee"
		item_path = /obj/item/clothing/head/rhinobeetle

	stagbeetle
		name = "Stag Beetle"
		swatch_background_color = "#d73715"
		item_path = /obj/item/clothing/head/stagbeetle

ABSTRACT_TYPE(/datum/clothingbooth_item/head/elephanthat)
/datum/clothingbooth_item/head/elephanthat
	cost = PAY_TRADESMAN/3

	pink
		name = "Pink"
		swatch_background_color = "#f9aaaa"
		item_path = /obj/item/clothing/head/elephanthat/pink

	gold
		name = "Gold"
		swatch_background_color = "#ebb02c"
		item_path = /obj/item/clothing/head/elephanthat/gold

	green
		name = "Green"
		swatch_background_color = "#9eee7f"
		item_path = /obj/item/clothing/head/elephanthat/green

	blue
		name = "Blue"
		swatch_background_color = "#55eec2"
		item_path = /obj/item/clothing/head/elephanthat/blue

ABSTRACT_TYPE(/datum/clothingbooth_item/head/mushroomcap)
/datum/clothingbooth_item/head/mushroomcap

	red
		name = "Red"
		swatch_background_color = "#d73715"
		item_path = /obj/item/clothing/head/mushroomcap/red

	shiitake
		name = "Shiitake"
		swatch_background_color = "#724f29"
		item_path = /obj/item/clothing/head/mushroomcap/shiitake

	indigo
		name = "Indigo"
		swatch_background_color = "#24bdc6"
		item_path = /obj/item/clothing/head/mushroomcap/indigo

	inky
		name = "Inky"
		swatch_background_color = "#545461"
		cost = PAY_TRADESMAN
		item_path = /obj/item/clothing/head/mushroomcap/inky

/datum/clothingbooth_item/head/minotaurmask
	cost = PAY_TRADESMAN
	item_path = /obj/item/clothing/head/minotaurmask

#endif
