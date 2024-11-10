/* ------------------------ Masks ------------------------ */
ABSTRACT_TYPE(/datum/clothingbooth_item/mask)
/datum/clothingbooth_item/mask
	slot = SLOT_WEAR_MASK

ABSTRACT_TYPE(/datum/clothingbooth_item/mask/masquerade)
/datum/clothingbooth_item/mask/masquerade
	cost = PAY_TRADESMAN/5

	cherryblossom
		name = "Cherryblossom"
		swatch_background_color = "#8d1422"
		item_path = /obj/item/clothing/mask/blossommask

	peacock
		name = "Peacock"
		swatch_background_color = "#2f457c"
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
		swatch_background_color = "#314250"
		item_path = /obj/item/clothing/head/barrette/black

	blue
		name = "Blue"
		swatch_background_color = "#10a789"
		item_path = /obj/item/clothing/head/barrette/blue

	gold
		name = "Gold"
		swatch_background_color = "#cf842e"
		item_path = /obj/item/clothing/head/barrette/gold
	green
		name = "Green"
		swatch_background_color = "#10a789"
		item_path = /obj/item/clothing/head/barrette/green

	pink
		name = "Pink"
		swatch_background_color = "#c70f61"
		item_path = /obj/item/clothing/head/barrette/pink

	silver
		name = "Silver"
		swatch_background_color = "#899ba9"
		item_path = /obj/item/clothing/head/barrette/silver

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

ABSTRACT_TYPE(/datum/clothingbooth_item/head/basecap)
/datum/clothingbooth_item/head/basecap
	cost = PAY_TRADESMAN/5

	black
		name = "Black"
		swatch_background_color = "#424554"
		item_path = /obj/item/clothing/head/basecap/black

	white
		name = "White"
		swatch_background_color = "#ebf0f2"
		item_path = /obj/item/clothing/head/basecap/white

	pink
		name = "Pink"
		swatch_background_color = "#c9294e"
		item_path = /obj/item/clothing/head/basecap/pink

	red
		name = "Red"
		swatch_background_color = "#d73715"
		item_path = /obj/item/clothing/head/basecap/red

	yellow
		name = "Yellow"
		swatch_background_color = "#ebc921"
		item_path = /obj/item/clothing/head/basecap/yellow

	green
		name = "Green"
		swatch_background_color = "#3fb54f"
		item_path = /obj/item/clothing/head/basecap/green

	blue
		name = "Blue"
		swatch_background_color = "#24bdc6"
		item_path = /obj/item/clothing/head/basecap/blue

	purple
		name = "Purple"
		swatch_background_color = "#8718b0"
		item_path = /obj/item/clothing/head/basecap/purple

ABSTRACT_TYPE(/datum/clothingbooth_item/head/beret)
/datum/clothingbooth_item/head/beret
	cost = PAY_TRADESMAN/3

	white
		name = "White"
		swatch_background_color = "#d8d8d8"
		item_path = /obj/item/clothing/head/frenchberet/white

	purple
		name = "Purple"
		swatch_background_color = "#9326cf"
		item_path = /obj/item/clothing/head/frenchberet/purple

	blue
		name = "Blue"
		swatch_background_color = "#3698cb"
		item_path = /obj/item/clothing/head/frenchberet/blue

	pink
		name = "Pink"
		swatch_background_color = "#e13da1"
		item_path = /obj/item/clothing/head/frenchberet/pink

	mint
		name = "Mint"
		swatch_background_color = "#1ab692"
		item_path = /obj/item/clothing/head/frenchberet/mint

	yellow
		name = "Yellow"
		swatch_background_color = "#d49d0f"
		item_path = /obj/item/clothing/head/frenchberet/yellow

	strawberry
		name = "Strawberry"
		swatch_background_color = "#c20038"
		item_path = /obj/item/clothing/head/frenchberet/strawberry

	blueberry
		name = "Blueberry"
		swatch_background_color = "#3510b0"
		item_path = /obj/item/clothing/head/frenchberet/blueberry

/datum/clothingbooth_item/head/bowler
	cost = PAY_TRADESMAN/5
	item_path = /obj/item/clothing/head/mime_bowler

/datum/clothingbooth_item/head/sailormoon
	cost = PAY_TRADESMAN/5
	item_path = /obj/item/clothing/head/sailormoon

ABSTRACT_TYPE(/datum/clothingbooth_item/head/butterfly_hairclip)
/datum/clothingbooth_item/head/butterfly_hairclip
	cost = PAY_TRADESMAN/5

	blue
		name = "Blue"
		swatch_background_color = "#0090cb"
		item_path = /obj/item/clothing/head/barrette/butterflyblu

	orange
		name = "Orange"
		swatch_background_color = "#eb7f46"
		item_path = /obj/item/clothing/head/barrette/butterflyorg

ABSTRACT_TYPE(/datum/clothingbooth_item/head/cat_ears)
/datum/clothingbooth_item/head/cat_ears
	cost = PAY_TRADESMAN/2

	white
		name = "White"
		swatch_background_color = "#e5e5e5"
		item_path = /obj/item/clothing/head/headband/nyan/white

	black
		name = "Black"
		swatch_background_color = "#191919"
		item_path = /obj/item/clothing/head/headband/nyan/black

	blue
		name = "Blue"
		swatch_background_color = "#007f7f"
		item_path = /obj/item/clothing/head/headband/nyan/blue

	green
		name = "Green"
		swatch_background_color = "#007f00"
		item_path = /obj/item/clothing/head/headband/nyan/green

	grey
		name = "Grey"
		swatch_background_color = "#4c4c4c"
		item_path = /obj/item/clothing/head/headband/nyan/gray

	orange
		name = "Orange"
		swatch_background_color = "#7f3f00"
		item_path = /obj/item/clothing/head/headband/nyan/orange

	purple
		name = "Purple"
		swatch_background_color = "#55007f"
		item_path = /obj/item/clothing/head/headband/nyan/purple

	red
		name = "Red"
		swatch_background_color = "#7f0000"
		item_path = /obj/item/clothing/head/headband/nyan/red

	yellow
		name = "Yellow"
		swatch_background_color = "#7f6a00"
		item_path = /obj/item/clothing/head/headband/nyan/yellow

ABSTRACT_TYPE(/datum/clothingbooth_item/head/costume_goggles)
/datum/clothingbooth_item/head/costume_goggles
	cost = PAY_TRADESMAN/3

	yellow
		name = "Yellow"
		swatch_background_color = "#ffcb1f"
		item_path = /obj/item/clothing/head/goggles/yellow

	red
		name = "Red"
		swatch_background_color = "#ff3535"
		item_path = /obj/item/clothing/head/goggles/red

	green
		name = "Green"
		swatch_background_color = "#6dff5d"
		item_path = /obj/item/clothing/head/goggles/green

	blue
		name = "Blue"
		swatch_background_color = "#5ecfcf"
		item_path = /obj/item/clothing/head/goggles/blue

	purple
		name = "Purple"
		swatch_background_color = "#dc70ff"
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
	cost = PAY_TRADESMAN/5

	black
		name = "Black"
		swatch_background_color = "#090a22"
		item_path = /obj/item/clothing/head/fedora

	brown
		name = "Brown"
		swatch_background_color = "#4a281b"
		item_path = /obj/item/clothing/head/det_hat

	white
		name = "White"
		swatch_background_color = "#c9b796"
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
	cost = PAY_TRADESMAN/3

	blue
		name = "Blue"
		swatch_background_color = "#3c6dc3"
		item_path = /obj/item/clothing/head/hairbow/blue

	matteblack
		name = "Matte Black"
		swatch_background_color = "#343442"
		item_path = /obj/item/clothing/head/hairbow/matteblack

	shinyblack
		name = "Shiny Black"
		swatch_background_color = "#1c0223"
		item_path = /obj/item/clothing/head/hairbow/shinyblack

	gold
		name = "Gold"
		swatch_background_color = "#cf842e"
		item_path = /obj/item/clothing/head/hairbow/gold

	green
		name = "Green"
		swatch_background_color = "#3fb54f"
		item_path = /obj/item/clothing/head/hairbow/green

	magenta
		name = "Magenta"
		swatch_background_color = "#dc0380"
		item_path = /obj/item/clothing/head/hairbow/magenta

	mint
		name = "Mint"
		swatch_background_color = "#329297"
		item_path = /obj/item/clothing/head/hairbow/mint

	navy
		name = "Navy"
		swatch_background_color = "#24639a"
		item_path = /obj/item/clothing/head/hairbow/navy

	pink
		name = "Pink"
		swatch_background_color = "#e98b8b"
		item_path = /obj/item/clothing/head/hairbow/pink

	purple
		name = "Purple"
		swatch_background_color = "#8d1bc2"
		item_path = /obj/item/clothing/head/hairbow/purple

	red
		name = "Red"
		swatch_background_color = "#a40322"
		item_path = /obj/item/clothing/head/hairbow/red

	white
		name = "White"
		swatch_background_color = "#cbd4da"
		item_path = /obj/item/clothing/head/hairbow/white

	rainbow
		name = "Rainbow"
		swatch_foreground_shape = SWATCH_RAINBOW
		item_path = /obj/item/clothing/head/hairbow/rainbow

	yellowpolkadot
		name = "Yellow Polka-dot"
		swatch_background_color = "#d3cb21"
		swatch_foreground_color = "#0d0c19"
		swatch_foreground_shape = SWATCH_POLKADOTS
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

	black
		name = "Black"
		swatch_background_color = "#1d223c"
		item_path = /obj/item/clothing/head/pirate_blk

	brown
		name = "Brown"
		swatch_background_color = "#4a281b"
		item_path = /obj/item/clothing/head/pirate_brn

ABSTRACT_TYPE(/datum/clothingbooth_item/head/pomhat)
/datum/clothingbooth_item/head/pomhat

	red
		name = "Red"
		swatch_background_color = "#d73715"
		item_path = /obj/item/clothing/head/pomhat_red

	blue
		name = "Blue"
		swatch_background_color = "#3c6dc3"
		item_path = /obj/item/clothing/head/pomhat_blue

ABSTRACT_TYPE(/datum/clothingbooth_item/head/sunhat)
/datum/clothingbooth_item/head/sunhat
	cost = PAY_TRADESMAN/5

	red
		name = "Red"
		swatch_background_color = "#a7231b"
		item_path = /obj/item/clothing/head/sunhat/sunhatr

	green
		name = "Green"
		swatch_background_color = "#128f3d"
		item_path = /obj/item/clothing/head/sunhat/sunhatg

	blue
		name = "Blue"
		swatch_background_color = "#13788f"
		item_path = /obj/item/clothing/head/sunhat

	yellow
		name = "Yellow"
		swatch_background_color = "#d3cb21"
		item_path = /obj/item/clothing/head/sunhat/sunhaty

ABSTRACT_TYPE(/datum/clothingbooth_item/head/tophat)
/datum/clothingbooth_item/head/tophat

	black
		name = "Black"
		swatch_background_color = "#333333"
		item_path = /obj/item/clothing/head/that

	white
		name = "White"
		swatch_background_color = "#d3d2d4"
		item_path = /obj/item/clothing/head/that/white

ABSTRACT_TYPE(/datum/clothingbooth_item/head/westhat)
/datum/clothingbooth_item/head/westhat
	cost = PAY_UNTRAINED/2

	beige
		name = "Beige"
		swatch_background_color = "#975d24"
		item_path = /obj/item/clothing/head/westhat

	black
		name = "Black"
		swatch_background_color = "#1a1b1c"
		item_path = /obj/item/clothing/head/westhat/black

	blue
		name = "Blue"
		swatch_background_color = "#1d223c"
		item_path = /obj/item/clothing/head/westhat/blue

	brown
		name = "Brown"
		swatch_background_color = "#5b2a0e"
		item_path = /obj/item/clothing/head/westhat/brown

	tan
		name = "Tan"
		swatch_background_color = "#ba8450"
		item_path = /obj/item/clothing/head/westhat/tan

	red
		name = "Red"
		swatch_background_color = "#6b0b0d"
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

// todo: distinguish these two somehow
ABSTRACT_TYPE(/datum/clothingbooth_item/wear_suit/poncho)
/datum/clothingbooth_item/wear_suit/poncho
	cost = PAY_UNTRAINED/1

	flower
		name = "Flower"
		swatch_background_color = "#aa6e36"
		item_path = /obj/item/clothing/suit/poncho/flower

	leaf
		name = "Leaf"
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

	hearts
		name = "Hearts"
		item_path = /obj/item/clothing/under/misc/heart
		swatch_background_color = "#ffffff"
		swatch_foreground_color = "#d73715"
		swatch_foreground_shape = SWATCH_HEART

	diamonds
		name = "Diamonds"
		item_path = /obj/item/clothing/under/misc/diamond
		swatch_background_color = "#ffffff"
		swatch_foreground_color = "#d73715"
		swatch_foreground_shape = SWATCH_DIAMOND

	clubs
		name = "Clubs"
		item_path = /obj/item/clothing/under/misc/club
		swatch_background_color = "#ffffff"
		swatch_foreground_color = "#2d3c52"
		swatch_foreground_shape = SWATCH_CLUB

	spades
		name = "Spades"
		item_path = /obj/item/clothing/under/misc/spade
		swatch_background_color = "#ffffff"
		swatch_foreground_color = "#2d3c52"
		swatch_foreground_shape = SWATCH_SPADE

// todo, double check that blacj
ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/collar_dress)
/datum/clothingbooth_item/w_uniform/collar_dress

	black
		name = "Black"
		swatch_background_color = "#3f4c5b"
		item_path = /obj/item/clothing/under/collardressbl

	blue
		name = "Blue"
		swatch_background_color = "#63a5ee"
		item_path = /obj/item/clothing/under/collardressb

	green
		name = "Green"
		swatch_background_color = "#3eb54e"
		item_path = /obj/item/clothing/under/collardressg

	red
		name = "Red"
		swatch_background_color = "#d73715"
		item_path = /obj/item/clothing/under/collardressr

/datum/clothingbooth_item/w_uniform/cwfashion
	cost = PAY_DOCTORATE/5
	item_path = /obj/item/clothing/under/gimmick/cwfashion

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/diner_waitress_dress)
/datum/clothingbooth_item/w_uniform/diner_waitress_dress

	mint
		name = "Mint"
		swatch_background_color = "#5bc7a8"
		item_path = /obj/item/clothing/under/gimmick/dinerdress_mint

	pink
		name = "Pink"
		swatch_background_color = "#f9aaaa"
		item_path = /obj/item/clothing/under/gimmick/dinerdress_pink

/datum/clothingbooth_item/w_uniform/dirty_vest
	item_path = /obj/item/clothing/under/misc/dirty_vest

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/dress_shirt_wcoat)
/datum/clothingbooth_item/w_uniform/dress_shirt_wcoat
	cost = PAY_DOCTORATE/3

	black
		name = "Black"
		swatch_background_color = "#3f4c5b"
		item_path = /obj/item/clothing/under/gimmick/black_wcoat

	blue
		name = "Blue"
		swatch_background_color = "#094882"
		item_path = /obj/item/clothing/under/gimmick/blue_wcoat

	red
		name = "Red"
		swatch_background_color = "#8d1522"
		item_path = /obj/item/clothing/under/gimmick/red_wcoat

/datum/clothingbooth_item/w_uniform/fancy_vest
	cost = PAY_DOCTORATE/3
	item_path = /obj/item/clothing/under/misc/fancy_vest

/datum/clothingbooth_item/w_uniform/fish
	item_path = /obj/item/clothing/under/misc/fish

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/flame_shirt)
/datum/clothingbooth_item/w_uniform/flame_shirt

	purple
		name = "Purple"
		swatch_background_color = "#ee59e3"
		item_path = /obj/item/clothing/under/misc/flame_purple

	rainbow
		name = "Rainbow"
		swatch_foreground_shape = SWATCH_RAINBOW
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
	cost = PAY_IMPORTANT/3

	black
		name = "Black"
		swatch_background_color = "#404977"
		item_path = /obj/item/clothing/under/misc/dress

	red
		name = "Red"
		swatch_background_color = "#c8193a"
		item_path = /obj/item/clothing/under/misc/dress/red

/datum/clothingbooth_item/w_uniform/long_sleeved_shirt
	item_path = /obj/item/clothing/suit/lshirt

/datum/clothingbooth_item/w_uniform/maid
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/under/gimmick/maid

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/masquerade)
/datum/clothingbooth_item/w_uniform/masquerade
	cost = PAY_DOCTORATE/3

	cherryblossom
		name = "Cherryblossom"
		swatch_background_color = "#8d1522"
		item_path = /obj/item/clothing/under/blossomdress

	peacock
		name = "Peacock"
		swatch_background_color = "#30457c"
		item_path = /obj/item/clothing/under/peacockdress

/datum/clothingbooth_item/w_uniform/pink_collared_shirt
	item_path = /obj/item/clothing/under/misc/collar_pink

/datum/clothingbooth_item/w_uniform/redtie
	cost = PAY_TRADESMAN/3
	item_path = /obj/item/clothing/under/redtie

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/scifi)
/datum/clothingbooth_item/w_uniform/scifi
	cost = PAY_DOCTORATE/3

	black_and_purple
		name = "Black and Purple"
		swatch_background_color = "#681f86"
		item_path = /obj/item/clothing/under/misc/sfjumpsuitbp

	black_and_red
		name = "Black and Red"
		swatch_background_color = "#e90f11"
		item_path = /obj/item/clothing/under/misc/sfjumpsuitrb

	pink_and_blue
		name = "Pink and Blue"
		swatch_background_color = "#49e5f2"
		item_path = /obj/item/clothing/under/misc/sfjumpsuitpnk

	bee
		name = "Bee"
		swatch_background_color = "#fbdf35"
		item_path = /obj/item/clothing/under/misc/sfjumpsuitbee

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/shirt_and_jeans)
/datum/clothingbooth_item/w_uniform/shirt_and_jeans

	white
		name = "White"
		swatch_background_color = "#e5e5e5"
		item_path = /obj/item/clothing/under/misc/casualjeanswb

	black_skull
		name = "Black Skull"
		swatch_background_color = "#2d2c30"
		swatch_foreground_color = "#0a4e68"
		swatch_foreground_shape = SWATCH_BISECT_RIGHT
		item_path = /obj/item/clothing/under/misc/casualjeansskb

	red_skull
		name = "Red Skull"
		swatch_background_color = "#ff2f6e"
		item_path = /obj/item/clothing/under/misc/casualjeansskr

	skull_acid_wash
		name = "Skull Shirt and Acid Wash Jeans"
		swatch_background_color = "#2d2c30"
		swatch_foreground_color = "#7d878a"
		swatch_foreground_shape = SWATCH_BISECT_RIGHT
		item_path = /obj/item/clothing/under/misc/casualjeansacid

	blue
		name = "Blue"
		swatch_background_color = "#63d7dc"
		item_path = /obj/item/clothing/under/misc/casualjeansblue

	grey
		name = "Grey"
		swatch_background_color = "#988ba4"
		item_path = /obj/item/clothing/under/misc/casualjeansgrey

	khaki
		name = "Khaki"
		swatch_background_color = "#3e7962"
		item_path = /obj/item/clothing/under/misc/casualjeanskhaki

	purple
		name = "Purple"
		swatch_background_color = "#bb1de9"
		item_path = /obj/item/clothing/under/misc/casualjeanspurp

	yellow
		name = "Yellow"
		swatch_background_color = "#e5c728"
		item_path = /obj/item/clothing/under/misc/casualjeansyel

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/shirt_and_pants)
/datum/clothingbooth_item/w_uniform/shirt_and_pants
	cost = PAY_TRADESMAN/3

	black_pants_no_tie
		name = "Black Pants No Tie"
		item_path = /obj/item/clothing/under/shirt_pants_b
		swatch_background_color = "#2d3c52"
		swatch_foreground_color = "#ebf0f2"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	black_pants_red_tie
		name = "Black Pants Red Tie"
		item_path = /obj/item/clothing/under/shirt_pants_b/redtie
		swatch_background_color = "#2d3c52"
		swatch_foreground_color = "#d73715"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	black_pants_black_tie
		name = "Black Pants Black Tie"
		item_path = /obj/item/clothing/under/shirt_pants_b/blacktie
		swatch_background_color = "#2d3c52"

	black_pants_blue_tie
		name = "Black Pants Blue Tie"
		item_path = /obj/item/clothing/under/shirt_pants_b/bluetie
		swatch_background_color = "#2d3c52"
		swatch_foreground_color = "#62a5ee"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	brown_pants_no_tie
		name = "Brown Pants No Tie"
		item_path = /obj/item/clothing/under/shirt_pants_br
		swatch_background_color = "#907e47"
		swatch_foreground_color = "#ebf0f2"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	brown_pants_red_tie
		name = "Brown Pants Red Tie"
		item_path = /obj/item/clothing/under/shirt_pants_br/redtie
		swatch_background_color = "#907e47"
		swatch_foreground_color = "#d73715"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	brown_pants_black_tie
		name = "Brown Pants Black Tie"
		item_path = /obj/item/clothing/under/shirt_pants_br/blacktie
		swatch_background_color = "#907e47"
		swatch_foreground_color = "#2d3c52"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	brown_pants_blue_tie
		name = "Brown Pants Blue Tie"
		item_path = /obj/item/clothing/under/shirt_pants_br/bluetie
		swatch_background_color = "#907e47"
		swatch_foreground_color = "#62a5ee"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	white_pants_no_tie
		name = "White Pants No Tie"
		item_path = /obj/item/clothing/under/shirt_pants_w
		swatch_background_color = "#ebf0f2"

	white_pants_red_tie
		name = "White Pants Red Tie"
		item_path = /obj/item/clothing/under/shirt_pants_w/redtie
		swatch_background_color = "#ebf0f2"
		swatch_foreground_color = "#d73715"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	white_pants_black_tie
		name = "White Pants Black Tie"
		item_path = /obj/item/clothing/under/shirt_pants_w/blacktie
		swatch_background_color = "#ebf0f2"
		swatch_foreground_color = "#2d3c52"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

	white_pants_blue_tie
		name = "White Pants Blue Tie"
		item_path = /obj/item/clothing/under/shirt_pants_w/bluetie
		swatch_background_color = "#ebf0f2"
		swatch_foreground_color = "#62a5ee"
		swatch_foreground_shape = SWATCH_BISECT_LEFT

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/skirt_dress)
/datum/clothingbooth_item/w_uniform/skirt_dress
	cost = PAY_TRADESMAN/3

	red
		name = "Red and Black"
		swatch_background_color = "#f61019"
		item_path = /obj/item/clothing/under/misc/sktdress_red

	blue
		name = "Blue and Black"
		swatch_background_color = "#0efbe0"
		item_path = /obj/item/clothing/under/misc/sktdress_blue

	gold
		name = "Gold and Black"
		swatch_background_color = "#e5be43"
		item_path = /obj/item/clothing/under/misc/sktdress_gold

	purple
		name = "Purple and Black"
		swatch_background_color = "#cf41f2"
		item_path = /obj/item/clothing/under/misc/sktdress_purple

/datum/clothingbooth_item/w_uniform/tech_shirt
	item_path = /obj/item/clothing/under/misc/tech_shirt

/datum/clothingbooth_item/w_uniform/tracksuit
	item_path = /obj/item/clothing/under/gimmick/adidad

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/tshirt_dress)
/datum/clothingbooth_item/w_uniform/tshirt_dress

	black
		name = "Black"
		swatch_background_color = "#705ba9"
		item_path = /obj/item/clothing/under/misc/casdressblk

	blue
		name = "Blue"
		swatch_background_color = "#00badc"
		item_path = /obj/item/clothing/under/misc/casdressblu

	green
		name = "Green"
		swatch_background_color = "#1fdc00"
		item_path = /obj/item/clothing/under/misc/casdressgrn

	pink
		name = "Pink"
		swatch_background_color = "#ee1392"
		item_path = /obj/item/clothing/under/misc/casdresspnk

	white
		name = "White"
		swatch_background_color = "#e9e9e9"
		item_path = /obj/item/clothing/under/misc/casdresswht

	bolt
		name = "Bolt"
		cost = PAY_TRADESMAN/3
		swatch_background_color = "#7c77ad"
		swatch_foreground_color = "#ffe244"
		swatch_foreground_shape = SWATCH_BISECT_RIGHT
		item_path = /obj/item/clothing/under/misc/casdressbolty

	purple_bolt
		name = "Purple Bolt"
		cost = PAY_TRADESMAN/3
		swatch_background_color = "#b726ff"
		swatch_foreground_color = "#ecddff"
		swatch_foreground_shape = SWATCH_BISECT_RIGHT
		item_path = /obj/item/clothing/under/misc/casdressboltp

	leopard
		name = "Leopard"
		cost = PAY_TRADESMAN/3
		swatch_background_color = "#f2cb2f"
		swatch_foreground_color = "#57435f"
		swatch_foreground_shape = SWATCH_POLKADOTS
		item_path = /obj/item/clothing/under/misc/casdressleoy

	pink_leopard
		name = "Pink Leopard"
		swatch_background_color = "#cb3083"
		swatch_foreground_color = "#57435f"
		swatch_foreground_shape = SWATCH_POLKADOTS
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
	cost = PAY_TRADESMAN/3

	white
		name = "White"
		swatch_background_color = "#ebf0f2"
		item_path = /obj/item/clothing/under/misc/yoga

	red
		name = "Red"
		swatch_background_color = "#d73715"
		item_path = /obj/item/clothing/under/misc/yoga/red

	very_red
		name = "VERY Red"
		swatch_background_color = "#d73715"
		swatch_foreground_color = "#ffe244"
		swatch_foreground_shape = SWATCH_BISECT_LEFT
		item_path = /obj/item/clothing/under/misc/yoga/communist

/* ------------------------------------------------------- */
/* ------------------------ AUTUMN ----------------------- */
/* ------------------------------------------------------- */
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

/* ------------------------------------------------------- */
/* ----------------------- HALLOWEEN --------------------- */
/* ------------------------------------------------------- */
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
