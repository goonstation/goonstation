/* ------------------------ Masks ------------------------ */
ABSTRACT_TYPE(/datum/clothingbooth_item/mask)
/datum/clothingbooth_item/mask
	slot = SLOT_WEAR_MASK

ABSTRACT_TYPE(/datum/clothingbooth_item/mask/masquerade)
/datum/clothingbooth_item/mask/masquerade
	cost = PAY_TRADESMAN/5

	cherryblossom
		name = "Cherryblossom"
		swatch_background_colour = "#8D1422"
		item_path = /obj/item/clothing/mask/blossommask

	peacock
		name = "Peacock"
		swatch_background_colour = "#2F457C"
		item_path = /obj/item/clothing/mask/peacockmask

/* ------------------------- Head ------------------------ */
ABSTRACT_TYPE(/datum/clothingbooth_item/head)
/datum/clothingbooth_item/head
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/2

ABSTRACT_TYPE(/datum/clothingbooth_item/head/barrettes)
/datum/clothingbooth_item/head/barrettes
	cost = PAY_TRADESMAN/5

	black
		name = "Black"
		item_path = /obj/item/clothing/head/barrette/black

	blue
		name = "Blue"
		item_path = /obj/item/clothing/head/barrette/blue

	gold
		name = "Gold"
		item_path = /obj/item/clothing/head/barrette/gold
	green
		name = "Green"
		item_path = /obj/item/clothing/head/barrette/green

	pink
		name = "Pink"
		item_path = /obj/item/clothing/head/barrette/pink

	silver
		name = "Silver"
		item_path = /obj/item/clothing/head/barrette/silver

/*
/* ----------------------- Glasses ----------------------- */
ABSTRACT_TYPE(/datum/clothingbooth_item/glasses)
/datum/clothingbooth_item/glasses
	slot = SLOT_GLASSES

/datum/clothingbooth_item/glasses/ftscanplate
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/glasses/ftscanplate

/datum/clothingbooth_item/glasses/monocle
	cost = PAY_IMPORTANT/3
	item_path = /obj/item/clothing/glasses/monocle

/* ------------------------ Gloves ----------------------- */
ABSTRACT_TYPE(/datum/clothingbooth_item/gloves)
/datum/clothingbooth_item/gloves
	slot = SLOT_GLOVES

/datum/clothingbooth_item/gloves/handcomp
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/gloves/handcomp

/datum/clothingbooth_item/gloves/ring_gold
	cost = PAY_IMPORTANT
	item_path = /obj/item/clothing/gloves/ring/gold

/* ------------------------- Head ------------------------ */
ABSTRACT_TYPE(/datum/clothingbooth_item/head)
/datum/clothingbooth_item/head
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/2

ABSTRACT_TYPE(/datum/clothingbooth_item/head/barrettes)
/datum/clothingbooth_item/head/barrettes
	name = "Barrettes"
	cost = PAY_TRADESMAN/5

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/head/barrette/black

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/barrette/blue

	gold
		variant_name = "Gold"
		item_path = /obj/item/clothing/head/barrette/gold
	green
		variant_name = "Green"
		item_path = /obj/item/clothing/head/barrette/green

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/head/barrette/pink

	silver
		variant_name = "Silver"
		item_path = /obj/item/clothing/head/barrette/silver

ABSTRACT_TYPE(/datum/clothingbooth_item/head/basecap)
/datum/clothingbooth_item/head/basecap
	name = "Baseball Cap"
	cost = PAY_TRADESMAN/5

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/head/basecap/black

	white
		variant_name = "White"
		item_path = /obj/item/clothing/head/basecap/white

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/head/basecap/pink

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/head/basecap/red

	yellow
		variant_name = "Yellow"
		item_path = /obj/item/clothing/head/basecap/yellow

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/head/basecap/green

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/basecap/blue

	purple
		variant_name = "Purple"
		item_path = /obj/item/clothing/head/basecap/purple

ABSTRACT_TYPE(/datum/clothingbooth_item/head/beret)
/datum/clothingbooth_item/head/beret
	name = "Beret"
	cost = PAY_TRADESMAN/3

	white
		variant_name = "White"
		item_path = /obj/item/clothing/head/frenchberet/white

	purple
		variant_name = "Purple"
		item_path = /obj/item/clothing/head/frenchberet/purple

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/frenchberet/blue

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/head/frenchberet/pink

	mint
		variant_name = "Mint"
		item_path = /obj/item/clothing/head/frenchberet/mint

	yellow
		variant_name = "Yellow"
		item_path = /obj/item/clothing/head/frenchberet/yellow

	strawberry
		variant_name = "Strawberry"
		item_path = /obj/item/clothing/head/frenchberet/strawberry

	blueberry
		variant_name = "Blueberry"
		item_path = /obj/item/clothing/head/frenchberet/blueberry

/datum/clothingbooth_item/head/bowler
	cost = PAY_TRADESMAN/5
	item_path = /obj/item/clothing/head/mime_bowler

ABSTRACT_TYPE(/datum/clothingbooth_item/head/butterfly_hairclip)
/datum/clothingbooth_item/head/butterfly_hairclip
	name = "Butterfly Hairclip"
	cost = PAY_TRADESMAN/5

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/barrette/butterflyblu

	orange
		variant_name = "Orange"
		item_path = /obj/item/clothing/head/barrette/butterflyorg

ABSTRACT_TYPE(/datum/clothingbooth_item/head/cat_ears)
/datum/clothingbooth_item/head/cat_ears
	name = "Cat Ears"
	cost = PAY_TRADESMAN/2

	white
		variant_name = "White"
		item_path = /obj/item/clothing/head/headband/nyan/white

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/head/headband/nyan/black

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/headband/nyan/blue

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/head/headband/nyan/green

	grey
		variant_name = "Grey"
		item_path = /obj/item/clothing/head/headband/nyan/gray

	orange
		variant_name = "Orange"
		item_path = /obj/item/clothing/head/headband/nyan/orange

	purple
		variant_name = "Purple"
		item_path = /obj/item/clothing/head/headband/nyan/purple

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/head/headband/nyan/red

	yellow
		variant_name = "Yellow"
		item_path = /obj/item/clothing/head/headband/nyan/yellow

ABSTRACT_TYPE(/datum/clothingbooth_item/head/costume_goggles)
/datum/clothingbooth_item/head/costume_goggles
	name = "Costume Goggles"
	cost = PAY_TRADESMAN/3

	purple
		variant_name = "Yellow"
		item_path = /obj/item/clothing/head/goggles/yellow

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/head/goggles/red

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/head/goggles/green

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/goggles/blue

	purple
		variant_name = "Purple"
		item_path = /obj/item/clothing/head/goggles/purple

/datum/clothingbooth_item/head/cowboy
	cost = PAY_TRADESMAN/5
	item_path = /obj/item/clothing/head/cowboy

/datum/clothingbooth_item/head/cwhat
	item_path = /obj/item/clothing/head/cwhat

/datum/clothingbooth_item/head/diner_waitress_hat
	cost = PAY_TRADESMAN/5
	item_path = /obj/item/clothing/head/waitresshat

ABSTRACT_TYPE(/datum/clothingbooth_item/head/fedora)
/datum/clothingbooth_item/head/fedora
	name = "Fedora"
	cost = PAY_TRADESMAN/5

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/head/fedora

	brown
		variant_name = "Brown"
		item_path = /obj/item/clothing/head/det_hat

	white
		variant_name = "White"
		item_path = /obj/item/clothing/head/mj_hat

/datum/clothingbooth_item/head/frog
	cost = PAY_TRADESMAN
	item_path = /obj/item/clothing/head/frog_hat

/datum/clothingbooth_item/head/fthat
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/head/fthat

/datum/clothingbooth_item/head/green_visor
	cost = PAY_TRADESMAN/5
	item_path = /obj/item/clothing/head/pokervisor

ABSTRACT_TYPE(/datum/clothingbooth_item/head/hairbow)
/datum/clothingbooth_item/head/hairbow
	name = "Hairbow"
	cost = PAY_TRADESMAN/3

	blue
		variant_name = "blue"
		item_path = /obj/item/clothing/head/hairbow/blue

	matteblack
		variant_name = "Matte Black"
		item_path = /obj/item/clothing/head/hairbow/matteblack

	shinyblack
		variant_name = "Shiny Black"
		item_path = /obj/item/clothing/head/hairbow/shinyblack

	gold
		variant_name = "Gold"
		item_path = /obj/item/clothing/head/hairbow/gold

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/head/hairbow/green

	magenta
		variant_name = "Magenta"
		item_path = /obj/item/clothing/head/hairbow/magenta

	mint
		variant_name = "Mint"
		item_path = /obj/item/clothing/head/hairbow/mint

	navy
		variant_name = "Navy"
		item_path = /obj/item/clothing/head/hairbow/navy

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/head/hairbow/pink

	purple
		variant_name = "Purple"
		item_path = /obj/item/clothing/head/hairbow/purple

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/head/hairbow/red

	white
		variant_name = "White"
		item_path = /obj/item/clothing/head/hairbow/white

	rainbow
		variant_name = "Rainbow"
		item_path = /obj/item/clothing/head/hairbow/rainbow

	yellowpolkadot
		variant_name = "Yellow Polka-dot"
		item_path = /obj/item/clothing/head/hairbow/yellowpolkadot

/datum/clothingbooth_item/head/maid
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/head/maid

/datum/clothingbooth_item/head/lace_veil
	cost = PAY_IMPORTANT
	item_path = /obj/item/clothing/head/veil

/datum/clothingbooth_item/head/leaf_hairclip
	item_path = /obj/item/clothing/head/headsprout

/datum/clothingbooth_item/head/pinwheel
	cost = PAY_TRADESMAN
	item_path = /obj/item/clothing/head/pinwheel_hat

ABSTRACT_TYPE(/datum/clothingbooth_item/head/pirate)
/datum/clothingbooth_item/head/pirate
	name = "Pirate"

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/head/pirate_blk

	brown
		variant_name = "Brown"
		item_path = /obj/item/clothing/head/pirate_brn

ABSTRACT_TYPE(/datum/clothingbooth_item/head/pomhat)
/datum/clothingbooth_item/head/pomhat
	name = "Pomhat"

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/head/pomhat_red

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/pomhat_blue

ABSTRACT_TYPE(/datum/clothingbooth_item/head/sunhat)
/datum/clothingbooth_item/head/sunhat
	name = "Sunhat"
	cost = PAY_TRADESMAN/5

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/head/sunhat/sunhatr

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/head/sunhat/sunhatg

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/sunhat

ABSTRACT_TYPE(/datum/clothingbooth_item/head/tophat)
/datum/clothingbooth_item/head/tophat
	name = "Top Hat"

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/head/that

	white
		variant_name = "White"
		item_path = /obj/item/clothing/head/that/white

ABSTRACT_TYPE(/datum/clothingbooth_item/head/westhat)
/datum/clothingbooth_item/head/westhat
	name = "Ten-Gallon Hat"
	cost = PAY_UNTRAINED/2

	beige
		variant_name = "Beige"
		item_path = /obj/item/clothing/head/westhat

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/head/westhat/black

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/westhat/blue

	brown
		variant_name = "Brown"
		item_path = /obj/item/clothing/head/westhat/brown

	tan
		variant_name = "Tan"
		item_path = /obj/item/clothing/head/westhat/tan

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/head/westhat/red

/datum/clothingbooth_item/head/ushanka
	cost = PAY_TRADESMAN
	item_path = /obj/item/clothing/head/ushanka

/* ------------------------ Shoes ------------------------ */
ABSTRACT_TYPE(/datum/clothingbooth_item/shoes)
/datum/clothingbooth_item/shoes
	slot = SLOT_SHOES
	cost = PAY_TRADESMAN/5

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/boots)
/datum/clothingbooth_item/shoes/boots
	name = "Boots"
	cost = PAY_DOCTORATE/5

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/shoes/bootsblk

	white
		variant_name = "White"
		item_path = /obj/item/clothing/shoes/bootswht

	brown
		variant_name = "Brown"
		item_path = /obj/item/clothing/shoes/bootsbrn

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/shoes/bootsblu

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/cowboy_boots)
/datum/clothingbooth_item/shoes/cowboy_boots
	name = "Cowboy Boots"
	cost = PAY_UNTRAINED/2

	real
		variant_name = "Real"
		item_path = /obj/item/clothing/shoes/westboot

	dirty
		variant_name = "Dirty"
		item_path = /obj/item/clothing/shoes/westboot/dirty

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/shoes/westboot/black

	brown
		variant_name = "Brown"
		item_path = /obj/item/clothing/shoes/westboot/brown

/datum/clothingbooth_item/shoes/dress_shoes
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/shoes/dress_shoes

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/flats)
/datum/clothingbooth_item/shoes/flats
	name = "Flats"

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/shoes/flatsblk

	white
		variant_name = "White"
		item_path = /obj/item/clothing/shoes/flatswht

	brown
		variant_name = "Brown"
		item_path = /obj/item/clothing/shoes/flatsbrn

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/shoes/flatsblu

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/shoes/flatspnk

/datum/clothingbooth_item/shoes/floppy_boots
	item_path = /obj/item/clothing/shoes/floppy

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/heels)
/datum/clothingbooth_item/shoes/heels
	name = "Heels"
	cost = PAY_DOCTORATE/5

	white
		variant_name = "White"
		item_path = /obj/item/clothing/shoes/heels

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/shoes/heels/black

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/shoes/heels/red

/datum/clothingbooth_item/shoes/macando_boots
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/shoes/cwboots

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes/mary_janes)
/datum/clothingbooth_item/shoes/mary_janes
	name = "Mary Janes"

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/shoes/mjblack

	brown
		variant_name = "Brown"
		item_path = /obj/item/clothing/shoes/mjbrown

	navy
		variant_name = "Navy"
		item_path = /obj/item/clothing/shoes/mjnavy

	white
		variant_name = "White"
		item_path = /obj/item/clothing/shoes/mjwhite

/* ------------------------ Suits ------------------------ */

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
	name = "Dress"
	cost = PAY_DOCTORATE/3

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/suit/dressb

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/suit/dressb/dressbl

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/suit/dressb/dressg

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/suit/dressb/dressr

/datum/clothingbooth_item/wear_suit/guards_coat
	cost = PAY_IMPORTANT/3
	item_path = /obj/item/clothing/suit/guards_coat

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/hoodie)
/datum/clothingbooth_item/wear_suit/hoodie
	name = "Hoodie"
	cost = PAY_UNTRAINED/3

	orange
		variant_name = "Orange"
		item_path = /obj/item/clothing/suit/hoodie

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/suit/hoodie/pink

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/suit/hoodie/red

	yellow
		variant_name = "Yellow"
		item_path = /obj/item/clothing/suit/hoodie/yellow

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/suit/hoodie/green

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/suit/hoodie/blue

	dark_blue
		variant_name = "Dark Blue"
		item_path = /obj/item/clothing/suit/hoodie/darkblue

	magenta
		variant_name = "Magenta"
		item_path = /obj/item/clothing/suit/hoodie/magenta

	white
		variant_name = "White"
		item_path = /obj/item/clothing/suit/hoodie/white

	dull_grey
		variant_name = "Dull Grey"
		item_path = /obj/item/clothing/suit/hoodie/dullgrey

	grey
		variant_name = "Grey"
		item_path = /obj/item/clothing/suit/hoodie/grey

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/suit/hoodie/black

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/jacket)
/datum/clothingbooth_item/wear_suit/jacket
	name = "Jacket"
	cost = PAY_TRADESMAN/3

	cerulean
		variant_name = "Cerulean"
		item_path = /obj/item/clothing/suit/jacket/design/cerulean

	grey
		variant_name = "Grey"
		item_path = /obj/item/clothing/suit/jacket/design/grey

	indigo
		variant_name = "Indigo"
		item_path = /obj/item/clothing/suit/jacket/design/indigo

	magenta
		variant_name = "Magenta"
		item_path = /obj/item/clothing/suit/jacket/design/magenta

	maroon
		variant_name = "Maroon"
		item_path = /obj/item/clothing/suit/jacket/design/maroon

	mint
		variant_name = "Mint"
		item_path = /obj/item/clothing/suit/jacket/design/mint

	navy
		variant_name = "Navy"
		item_path = /obj/item/clothing/suit/jacket/design/navy

	tan
		variant_name = "Tan"
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

ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/poncho)
/datum/clothingbooth_item/wear_suit/poncho
	name = "Poncho"
	cost = PAY_UNTRAINED/1

	flower
		variant_name = "Flower"
		item_path = /obj/item/clothing/suit/poncho/flower

	leaf
		variant_name = "Leaf"
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

/datum/clothingbooth_item/wear_suit/tuxedo_jacket
	cost = PAY_DOCTORATE/3
	item_path = /obj/item/clothing/suit/tuxedo_jacket

/datum/clothingbooth_item/wear_suit/waistcoat
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/suit/wcoat

/* ---------------------- Jumpsuits ---------------------- */

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform)
/datum/clothingbooth_item/w_uniform
	slot = SLOT_W_UNIFORM
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/w_uniform/bandshirt
	item_path = /obj/item/clothing/under/misc/bandshirt

/datum/clothingbooth_item/w_uniform/bubble_shirt
	item_path = /obj/item/clothing/under/misc/bubble

/datum/clothingbooth_item/w_uniform/butler
	cost = PAY_DOCTORATE/3
	item_path = /obj/item/clothing/under/gimmick/butler

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/card_suit_shirt)
/datum/clothingbooth_item/w_uniform/card_suit_shirt
	name = "Card Suit Shirt"

	spades
		variant_name = "Spades"
		item_path = /obj/item/clothing/under/misc/spade

	clubs
		variant_name = "Clubs"
		item_path = /obj/item/clothing/under/misc/club

	hearts
		variant_name = "Hearts"
		item_path = /obj/item/clothing/under/misc/heart

	diamonds
		variant_name = "Diamonds"
		item_path = /obj/item/clothing/under/misc/diamond

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/collar_dress)
/datum/clothingbooth_item/w_uniform/collar_dress
	name = "Collar Dress"
	variant_name = "Black"
	item_path = /obj/item/clothing/under/collardressbl

	blue
		variant_name = "blue"
		item_path = /obj/item/clothing/under/collardressb

	green
		variant_name = "green"
		item_path = /obj/item/clothing/under/collardressg

	red
		variant_name = "red"
		item_path = /obj/item/clothing/under/collardressr

/datum/clothingbooth_item/w_uniform/cwfashion
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/under/gimmick/cwfashion

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/diner_waitress_dress)
/datum/clothingbooth_item/w_uniform/diner_waitress_dress
	name = "Diner Waitress's Dress"

	mint
		variant_name = "Mint"
		item_path = /obj/item/clothing/under/gimmick/dinerdress_mint

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/under/gimmick/dinerdress_pink

/datum/clothingbooth_item/w_uniform/dirty_vest
	item_path = /obj/item/clothing/under/misc/dirty_vest

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/dress_shirt_wcoat)
/datum/clothingbooth_item/w_uniform/dress_shirt_wcoat
	name = "Dress Shirt and Waistcoat"
	cost = PAY_DOCTORATE/3

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/under/gimmick/black_wcoat

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/under/gimmick/blue_wcoat

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/under/gimmick/red_wcoat

/datum/clothingbooth_item/w_uniform/fancy_vest
	cost = PAY_DOCTORATE/3
	item_path = /obj/item/clothing/under/misc/fancy_vest

/datum/clothingbooth_item/w_uniform/fish
	item_path = /obj/item/clothing/under/misc/fish

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/flame_shirt)
/datum/clothingbooth_item/w_uniform/flame_shirt
	name = "Flame Shirt"

	purple
		item_path = /obj/item/clothing/under/misc/flame_purple

	rainbow
		item_path = /obj/item/clothing/under/misc/flame_rainbow
		cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/w_uniform/flannel
	item_path = /obj/item/clothing/under/misc/flannel

/datum/clothingbooth_item/w_uniform/ftuniform
	item_path = /obj/item/clothing/under/gimmick/ftuniform

/datum/clothingbooth_item/w_uniform/hawaiian_dress
	cost = PAY_DOCTORATE/3
	item_path = /obj/item/clothing/under/misc/dress/hawaiian

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/little_dress)
/datum/clothingbooth_item/w_uniform/little_dress
	name = "Little Dress"
	cost = PAY_IMPORTANT/3

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/under/misc/dress

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/under/misc/dress/red

/datum/clothingbooth_item/w_uniform/long_sleeved_shirt
	item_path = /obj/item/clothing/suit/lshirt

/datum/clothingbooth_item/w_uniform/maid
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/under/gimmick/maid

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/masquerade)
/datum/clothingbooth_item/w_uniform/masquerade
	name = "Masquerade Dress"
	cost = PAY_DOCTORATE/3
	override_display_order = TRUE

	cherryblossom
		variant_name = "Cherryblossom"
		item_path = /obj/item/clothing/under/blossomdress

	peacock
		variant_name = "Peacock"
		item_path = /obj/item/clothing/under/peacockdress

/datum/clothingbooth_item/w_uniform/pink_collared_shirt
	item_path = /obj/item/clothing/under/misc/collar_pink

/datum/clothingbooth_item/w_uniform/redtie
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/under/redtie

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/scifi)
/datum/clothingbooth_item/w_uniform/scifi
	name = "Sci-Fi Jumpsuit"
	cost = PAY_DOCTORATE/3

	black_and_purple
		variant_name = "Black and Purple"
		item_path = /obj/item/clothing/under/misc/sfjumpsuitbp

	black_and_red
		variant_name = "Black and Red"
		item_path = /obj/item/clothing/under/misc/sfjumpsuitrb

	pink_and_blue
		variant_name = "Pink and Blue"
		item_path = /obj/item/clothing/under/misc/sfjumpsuitpnk

	bee
		variant_name = "Bee"
		item_path = /obj/item/clothing/under/misc/sfjumpsuitbee

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/shirt_and_jeans)
/datum/clothingbooth_item/w_uniform/shirt_and_jeans
	name = "Shirt and Jeans"

	white
		variant_name = "White"
		item_path = /obj/item/clothing/under/misc/casualjeanswb

	black_skull
		variant_name = "Black Skull"
		item_path = /obj/item/clothing/under/misc/casualjeansskb

	red_skull
		variant_name = "Red Skull"
		item_path = /obj/item/clothing/under/misc/casualjeansskr

	skull_acid_wash
		variant_name = "Skull Shirt and Acid Wash Jeans"
		item_path = /obj/item/clothing/under/misc/casualjeansacid

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/under/misc/casualjeansblue

	grey
		variant_name = "Grey"
		item_path = /obj/item/clothing/under/misc/casualjeansgrey

	khaki
		variant_name = "Khaki"
		item_path = /obj/item/clothing/under/misc/casualjeanskhaki

	purple
		variant_name = "Purple"
		item_path = /obj/item/clothing/under/misc/casualjeanspurp

	yellow
		variant_name = "Yellow"
		item_path = /obj/item/clothing/under/misc/casualjeansyel

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/shirt_and_pants)
/datum/clothingbooth_item/w_uniform/shirt_and_pants
	name = "Shirt and Pants"
	cost = PAY_TRADESMAN/3
	override_display_order = TRUE

	black_pants_no_tie
		variant_name = "Black Pants No Tie"
		item_path = /obj/item/clothing/under/shirt_pants_b

	black_pants_red_tie
		variant_name = "Black Pants Red Tie"
		item_path = /obj/item/clothing/under/shirt_pants_b/redtie

	black_pants_black_tie
		variant_name = "Black Pants Black Tie"
		item_path = /obj/item/clothing/under/shirt_pants_b/blacktie

	black_pants_blue_tie
		variant_name = "Black Pants Blue Tie"
		item_path = /obj/item/clothing/under/shirt_pants_b/bluetie

	brown_pants_no_tie
		variant_name = "Brown Pants No Tie"
		item_path = /obj/item/clothing/under/shirt_pants_br

	brown_pants_red_tie
		variant_name = "Brown Pants Red Tie"
		item_path = /obj/item/clothing/under/shirt_pants_br/redtie

	brown_pants_black_tie
		variant_name = "Brown Pants Black Tie"
		item_path = /obj/item/clothing/under/shirt_pants_br/blacktie

	brown_pants_blue_tie
		variant_name = "Brown Pants Blue Tie"
		item_path = /obj/item/clothing/under/shirt_pants_br/bluetie

	white_pants_no_tie
		variant_name = "White Pants No Tie"
		item_path = /obj/item/clothing/under/shirt_pants_w

	white_pants_red_tie
		variant_name = "White Pants Red Tie"
		item_path = /obj/item/clothing/under/shirt_pants_w/redtie

	white_pants_black_tie
		variant_name = "White Pants Black Tie"
		item_path = /obj/item/clothing/under/shirt_pants_w/blacktie

	white_pants_blue_tie
		variant_name = "White Pants Blue Tie"
		item_path = /obj/item/clothing/under/shirt_pants_w/bluetie

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/skirt_dress)
/datum/clothingbooth_item/w_uniform/skirt_dress
	name = "Skirt Dress"
	cost = PAY_TRADESMAN/3

	red
		variant_name = "Red and Black"
		item_path = /obj/item/clothing/under/misc/sktdress_red

	blue
		variant_name = "Blue and Black"
		item_path = /obj/item/clothing/under/misc/sktdress_blue

	gold
		variant_name = "Gold and Black"
		item_path = /obj/item/clothing/under/misc/sktdress_gold

	purple
		variant_name = "Purple and Black"
		item_path = /obj/item/clothing/under/misc/sktdress_purple

/datum/clothingbooth_item/w_uniform/tech_shirt
	item_path = /obj/item/clothing/under/misc/tech_shirt

/datum/clothingbooth_item/w_uniform/tracksuit
	name = "Tracksuit"
	item_path = /obj/item/clothing/under/gimmick/adidad

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/tshirt_dress)
/datum/clothingbooth_item/w_uniform/tshirt_dress
	name = "Tshirt Dress"

	black
		variant_name = "Black"
		item_path = /obj/item/clothing/under/misc/casdressblk

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/under/misc/casdressblu

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/under/misc/casdressgrn

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/under/misc/casdresspnk

	white
		variant_name = "White"
		item_path = /obj/item/clothing/under/misc/casdresswht

	bolt
		variant_name = "Bolt"
		cost = PAY_TRADESMAN/3
		item_path = /obj/item/clothing/under/misc/casdressbolty

	purple_bolt
		variant_name = "Purple Bolt"
		cost = PAY_TRADESMAN/3
		item_path = /obj/item/clothing/under/misc/casdressboltp

	leopard
		variant_name = "Leopard"
		cost = PAY_TRADESMAN/3
		item_path = /obj/item/clothing/under/misc/casdressleoy

	pink_leopard
		variant_name = "Pink Leopard"
		cost = PAY_TRADESMAN/3
		item_path = /obj/item/clothing/under/misc/casdressleop

/datum/clothingbooth_item/w_uniform/tuxedo
	cost = PAY_DOCTORATE/3
	item_path = /obj/item/clothing/under/rank/bartender/tuxedo

/datum/clothingbooth_item/w_uniform/wedding_dress
	cost = PAY_IMPORTANT*3
	item_path = /obj/item/clothing/under/gimmick/wedding_dress

/datum/clothingbooth_item/w_uniform/western
	cost = PAY_UNTRAINED/1
	item_path = /obj/item/clothing/under/misc/western

/datum/clothingbooth_item/w_uniform/western_dress
	cost = PAY_UNTRAINED/1
	item_path = /obj/item/clothing/under/misc/westerndress

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/yoga)
/datum/clothingbooth_item/w_uniform/yoga
	name = "Yoga Outfit"
	cost = PAY_TRADESMAN/3

	white
		variant_name = "White"
		item_path = /obj/item/clothing/under/misc/yoga

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/under/misc/yoga/red

	very_red
		variant_name = "VERY Red"
		item_path = /obj/item/clothing/under/misc/yoga/communist

/* ----------------------- SEASONAL ---------------------- */
/* ------------------------ Autumn ----------------------- */
#ifdef AUTUMN

/* ------------------------- Head ------------------------ */
/datum/clothingbooth_item/head/autumn_tree
	season = SEASON_AUTUMN
	cost = PAY_UNTRAINED
	item_path = /obj/item/clothing/head/autumn_tree

/datum/clothingbooth_item/head/leaf_wreath
	season = SEASON_AUTUMN
	cost = PAY_UNTRAINED
	item_path = /obj/item/clothing/head/leaf_wreath

/* ------------------------ Suits ------------------------ */
/datum/clothingbooth_item/wear_suit/autumn_cape
	season = SEASON_AUTUMN
	cost = PAY_UNTRAINED
	item_path = /obj/item/clothing/suit/autumn_cape

/datum/clothingbooth_item/wear_suit/autumn_jacket
	season = SEASON_AUTUMN
	cost = PAY_UNTRAINED
	item_path = /obj/item/clothing/suit/jacket/autumn_jacket

#endif

/* ---------------------- Halloween ---------------------- */
#ifdef HALLOWEEN

/* ------------------------ Masks ------------------------ */
/datum/clothingbooth_item/mask/tengumask
	season = SEASON_HALLOWEEN
	cost = PAY_TRADESMAN/2
	item_path = /obj/item/clothing/mask/tengu

/* ------------------------- Head ------------------------ */
/datum/clothingbooth_item/head/giraffehat
	season = SEASON_HALLOWEEN
	item_path = /obj/item/clothing/head/giraffehat

/datum/clothingbooth_item/head/axehat
	season = SEASON_HALLOWEEN
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/head/axehat

ABSTRACT_TYPE(/datum/clothingbooth_item/head/beetlehat)
/datum/clothingbooth_item/head/beetlehat
	name = "Beetle Helm"
	season = SEASON_HALLOWEEN

	rhinobeetle
		variant_name = "Rhino Beetle"
		item_path = /obj/item/clothing/head/rhinobeetle

	stagbeetle
		variant_name = "Stag Beetle"
		item_path = /obj/item/clothing/head/stagbeetle

ABSTRACT_TYPE(/datum/clothingbooth_item/head/elephanthat)
/datum/clothingbooth_item/head/elephanthat
	name = "Elephant Hat"
	season = SEASON_HALLOWEEN
	cost = PAY_TRADESMAN/3

	pink
		variant_name = "Pink"
		item_path = /obj/item/clothing/head/elephanthat/pink

	gold
		variant_name = "Gold"
		item_path = /obj/item/clothing/head/elephanthat/gold

	green
		variant_name = "Green"
		item_path = /obj/item/clothing/head/elephanthat/green

	blue
		variant_name = "Blue"
		item_path = /obj/item/clothing/head/elephanthat/blue

ABSTRACT_TYPE(/datum/clothingbooth_item/head/mushroomcap)
/datum/clothingbooth_item/head/mushroomcap
	name = "Mushroom Cap"
	season = SEASON_HALLOWEEN

	red
		variant_name = "Red"
		item_path = /obj/item/clothing/head/mushroomcap/red

	shiitake
		variant_name = "Shiitake Mushroom Cap"
		item_path = /obj/item/clothing/head/mushroomcap/shiitake

	indigo
		variant_name = "Indigo Mushroom Cap"
		item_path = /obj/item/clothing/head/mushroomcap/indigo

	inky
		variant_name = "Inky Mushroom Cap"
		cost = PAY_TRADESMAN
		item_path = /obj/item/clothing/head/mushroomcap/inky

/datum/clothingbooth_item/head/minotaurmask
	season = SEASON_HALLOWEEN
	cost = PAY_TRADESMAN
	item_path = /obj/item/clothing/head/minotaurmask

#endif
*/
