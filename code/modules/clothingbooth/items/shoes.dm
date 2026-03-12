ABSTRACT_TYPE(/datum/clothingbooth_item/shoes)
/datum/clothingbooth_item/shoes
	slot = SLOT_SHOES
	cost = PAY_TRADESMAN/5

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/boots)
/datum/clothingbooth_item/shoes/boots
	cost = PAY_DOCTORATE/5

	black
		name = "Black"
		swatch_background_color = "#2e2245"
		item_path = /obj/item/clothing/shoes/bootsblk

	white
		name = "White"
		swatch_background_color = "#e1e1e1"
		item_path = /obj/item/clothing/shoes/bootswht

	brown
		name = "Brown"
		swatch_background_color = "#5f2d0c"
		item_path = /obj/item/clothing/shoes/bootsbrn

	blue
		name = "Blue"
		swatch_background_color = "#28acb6"
		item_path = /obj/item/clothing/shoes/bootsblu

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/cowboy_boots)
/datum/clothingbooth_item/shoes/cowboy_boots
	cost = PAY_UNTRAINED/2

	real
		name = "Real"
		swatch_background_color = "#8a4f23"
		item_path = /obj/item/clothing/shoes/westboot

	dirty
		name = "Dirty"
		swatch_background_color = "#7d6d59"
		item_path = /obj/item/clothing/shoes/westboot/dirty

	black
		name = "Black"
		swatch_background_color = "#232424"
		item_path = /obj/item/clothing/shoes/westboot/black

	brown
		name = "Brown"
		swatch_background_color = "#5b2a0e"
		item_path = /obj/item/clothing/shoes/westboot/brown

/datum/clothingbooth_item/shoes/dress_shoes
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/shoes/dress_shoes

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/flats)
/datum/clothingbooth_item/shoes/flats

	black
		name = "Black"
		swatch_background_color = "#3a2b56"
		item_path = /obj/item/clothing/shoes/flatsblk

	white
		name = "White"
		swatch_background_color = "#fafafa"
		item_path = /obj/item/clothing/shoes/flatswht

	brown
		name = "Brown"
		swatch_background_color = "#5f2d0c"
		item_path = /obj/item/clothing/shoes/flatsbrn

	blue
		name = "Blue"
		swatch_background_color = "#28acb6"
		item_path = /obj/item/clothing/shoes/flatsblu

	pink
		name = "Pink"
		swatch_background_color = "#be22a6"
		item_path = /obj/item/clothing/shoes/flatspnk

/datum/clothingbooth_item/shoes/floppy_boots
	item_path = /obj/item/clothing/shoes/floppy

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/heels)
/datum/clothingbooth_item/shoes/heels
	cost = PAY_DOCTORATE/5

	white
		name = "White"
		swatch_background_color = "#f0f0f0"
		item_path = /obj/item/clothing/shoes/heels

	black
		name = "Black"
		swatch_background_color = "#3c3c3c"
		item_path = /obj/item/clothing/shoes/heels/black

	red
		name = "Red"
		swatch_background_color = "#c8183a"
		item_path = /obj/item/clothing/shoes/heels/red

/datum/clothingbooth_item/shoes/macando_boots
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/shoes/cwboots

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/mary_janes)
/datum/clothingbooth_item/shoes/mary_janes

	black
		name = "Black"
		swatch_background_color = "#1e1e32"
		item_path = /obj/item/clothing/shoes/mjblack

	brown
		name = "Brown"
		swatch_background_color = "#4a281b"
		item_path = /obj/item/clothing/shoes/mjbrown

	navy
		name = "Navy"
		swatch_background_color = "#0a4882"
		item_path = /obj/item/clothing/shoes/mjnavy

	white
		name = "White"
		swatch_background_color = "#ebf0f2"
		item_path = /obj/item/clothing/shoes/mjwhite
