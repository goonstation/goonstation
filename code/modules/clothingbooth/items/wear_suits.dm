ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit)
/datum/clothingbooth_item/wear_suit
	slot = SLOT_WEAR_SUIT
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/wear_suit/baseball_jacket
	item_path = /obj/item/clothing/suit/jacketsjacket

/datum/clothingbooth_item/wear_suit/dinosaur_pajamas
	cost = PAY_TRADESMAN/2
	item_path = /obj/item/clothing/suit/gimmick/dinosaur

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/dress)
/datum/clothingbooth_item/wear_suit/dress
	cost = PAY_DOCTORATE/3

	black
		name = "Black"
		swatch_background_color = "#1f1e23"
		item_path = /obj/item/clothing/suit/dressb

	blue
		name = "Blue"
		swatch_background_color = "#11728a"
		item_path = /obj/item/clothing/suit/dressb/dressbl

	green
		name = "Green"
		swatch_background_color = "#108a37"
		item_path = /obj/item/clothing/suit/dressb/dressg

	red
		name = "Red"
		swatch_background_color = "#921a14"
		item_path = /obj/item/clothing/suit/dressb/dressr

/datum/clothingbooth_item/wear_suit/guards_coat
	cost = PAY_IMPORTANT/3
	item_path = /obj/item/clothing/suit/guards_coat

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/hoodie)
/datum/clothingbooth_item/wear_suit/hoodie
	cost = PAY_UNTRAINED/3

	orange
		name = "Orange"
		swatch_background_color = "#ebb02c"
		item_path = /obj/item/clothing/suit/hoodie

	pink
		name = "Pink"
		swatch_background_color = "#f9aaaa"
		item_path = /obj/item/clothing/suit/hoodie/pink

	red
		name = "Red"
		swatch_background_color = "#d73715"
		item_path = /obj/item/clothing/suit/hoodie/red

	yellow
		name = "Yellow"
		swatch_background_color = "#d4cb22"
		item_path = /obj/item/clothing/suit/hoodie/yellow

	green
		name = "Green"
		swatch_background_color = "#3eb54e"
		item_path = /obj/item/clothing/suit/hoodie/green

	blue
		name = "Blue"
		swatch_background_color = "#63a5ee"
		item_path = /obj/item/clothing/suit/hoodie/blue

	dark_blue
		name = "Dark Blue"
		swatch_background_color = "#1a378d"
		item_path = /obj/item/clothing/suit/hoodie/darkblue

	magenta
		name = "Magenta"
		swatch_background_color = "#862272"
		item_path = /obj/item/clothing/suit/hoodie/magenta

	white
		name = "White"
		swatch_background_color = "#ebf0f2"
		item_path = /obj/item/clothing/suit/hoodie/white

	dull_grey
		name = "Dull Grey"
		swatch_background_color = "#c6c6c6"
		item_path = /obj/item/clothing/suit/hoodie/dullgrey

	grey
		name = "Grey"
		swatch_background_color = "#adb6bc"
		item_path = /obj/item/clothing/suit/hoodie/grey

	black
		name = "Black"
		swatch_background_color = "#3f4c5b"
		item_path = /obj/item/clothing/suit/hoodie/black

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/hoodie_large)
/datum/clothingbooth_item/wear_suit/hoodie_large
	cost = PAY_UNTRAINED / 3

	orange
		name = "Orange - Large"
		swatch_background_color = "#ebb02c"
		item_path = /obj/item/clothing/suit/hoodie/large

	pink
		name = "Pink - Large"
		swatch_background_color = "#ff009d"
		item_path = /obj/item/clothing/suit/hoodie/large/pink

	red
		name = "Red - Large"
		swatch_background_color = "#d73715"
		item_path = /obj/item/clothing/suit/hoodie/large/red

	green
		name = "Green - Large"
		swatch_background_color = "#3eb54e"
		item_path = /obj/item/clothing/suit/hoodie/large/green

	blue
		name = "Blue - Large"
		swatch_background_color = "#63a5ee"
		item_path = /obj/item/clothing/suit/hoodie/large/blue

	white
		name = "White - Large"
		swatch_background_color = "#ebf0f2"
		item_path = /obj/item/clothing/suit/hoodie/large/white

	black
		name = "Black - Large"
		swatch_background_color = "#3f4c5b"
		item_path = /obj/item/clothing/suit/hoodie/large/black

	purple
		name = "Purple - Large"
		swatch_background_color = "#8c00ff"
		item_path = /obj/item/clothing/suit/hoodie/large/purple

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/jacket)
/datum/clothingbooth_item/wear_suit/jacket
	cost = PAY_TRADESMAN/3

	cerulean
		name = "Cerulean"
		swatch_background_color = "#31759d"
		item_path = /obj/item/clothing/suit/jacket/design/cerulean

	grey
		name = "Grey"
		swatch_background_color = "#666666"
		item_path = /obj/item/clothing/suit/jacket/design/grey

	indigo
		name = "Indigo"
		swatch_background_color = "#51319d"
		item_path = /obj/item/clothing/suit/jacket/design/indigo

	magenta
		name = "Magenta"
		swatch_background_color = "#b42473"
		item_path = /obj/item/clothing/suit/jacket/design/magenta

	maroon
		name = "Maroon"
		swatch_background_color = "#b42448"
		item_path = /obj/item/clothing/suit/jacket/design/maroon

	mint
		name = "Mint"
		swatch_background_color = "#24b46a"
		item_path = /obj/item/clothing/suit/jacket/design/mint

	navy
		name = "Navy"
		swatch_background_color = "#31519d"
		item_path = /obj/item/clothing/suit/jacket/design/navy

	tan
		name = "Tan"
		swatch_background_color = "#cb9f5b"
		item_path = /obj/item/clothing/suit/jacket/design/tan

/datum/clothingbooth_item/wear_suit/jean_jacket
	item_path = /obj/item/clothing/suit/jean_jacket

/datum/clothingbooth_item/wear_suit/loose_jacket
	item_path = /obj/item/clothing/suit/loosejacket

/datum/clothingbooth_item/wear_suit/offbrand_labcoat
	cost = PAY_DOCTORATE/3
	item_path = /obj/item/clothing/suit/labcoatlong

/datum/clothingbooth_item/wear_suit/overcoat_and_scarf
	name = "Overcoat and Scarf"
	item_path = /obj/item/clothing/suit/johnny_coat

/datum/clothingbooth_item/wear_suit/long_sleeved_shirt
	item_path = /obj/item/clothing/suit/lshirt

// todo: distinguish these two somehow
ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/poncho)
/datum/clothingbooth_item/wear_suit/poncho
	cost = PAY_UNTRAINED/1

	poncho
		name = "Poncho"
		swatch_background_color = "#4C2417"
		item_path = /obj/item/clothing/suit/poncho

	flower
		name = "Flower Poncho"
		swatch_background_color = "#aa6e36"
		item_path = /obj/item/clothing/suit/poncho/flower

	leaf
		name = "Leaf Poncho"
		swatch_background_color = "#aa6e36"
		item_path = /obj/item/clothing/suit/poncho/leaf

/datum/clothingbooth_item/wear_suit/salesman_jacket
	item_path = /obj/item/clothing/suit/merchant

/datum/clothingbooth_item/wear_suit/scarf
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/suit/scarf

/datum/clothingbooth_item/wear_suit/skull_mask_and_cloak
	cost = PAY_TRADESMAN/2
	item_path = /obj/item/clothing/suit/rando

/datum/clothingbooth_item/wear_suit/suspenders
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/suit/suspenders

/datum/clothingbooth_item/wear_suit/hitman
	item_path = /obj/item/clothing/suit/hitman

/datum/clothingbooth_item/wear_suit/tuxedo_jacket
	cost = PAY_DOCTORATE/3
	item_path = /obj/item/clothing/suit/tuxedo_jacket

/datum/clothingbooth_item/wear_suit/waistcoat
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/suit/wcoat

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/sweater_vest)
/datum/clothingbooth_item/wear_suit/sweater_vest

	tan
		name = "Tan"
		swatch_background_color = "#C9A46E"
		item_path = /obj/item/clothing/suit/sweater_vest/tan
	red
		name = "Red"
		swatch_background_color = "#8D1422"
		item_path = /obj/item/clothing/suit/sweater_vest/red
	navy
		name = "Navy"
		swatch_background_color = "#37598D"
		item_path = /obj/item/clothing/suit/sweater_vest/navy
	green
		name = "Green"
		swatch_background_color = "#5D8038"
		item_path = /obj/item/clothing/suit/sweater_vest/green
	grey
		name = "Grey"
		swatch_background_color = "#747E84"
		item_path = /obj/item/clothing/suit/sweater_vest/grey
	black
		name = "Black"
		swatch_background_color = "#343442"
		item_path = /obj/item/clothing/suit/sweater_vest/black

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/denim_dress)
/datum/clothingbooth_item/wear_suit/denim_dress
	cost = PAY_UNTRAINED/3
	name = "Denim Dress"

	blue
		name = "Blue"
		swatch_background_color = "#3c6dc3"
		item_path = /obj/item/clothing/suit/dress/denim/blue

	turquoise
		name = "Turquoise"
		swatch_background_color = "#053a4e"
		item_path = /obj/item/clothing/suit/dress/denim/turquoise

	white
		name = "White"
		swatch_background_color = "#ffffff"
		item_path = /obj/item/clothing/suit/dress/denim/white

	black
		name = "Black"
		swatch_background_color = "#1c1c1c"
		item_path = /obj/item/clothing/suit/dress/denim/black

	grey
		name = "Grey"
		swatch_background_color = "#9fa6a9"
		item_path = /obj/item/clothing/suit/dress/denim/grey

	khaki
		name = "Khaki"
		swatch_background_color = "#c9a46e"
		item_path = /obj/item/clothing/suit/dress/denim/khaki
