/datum/clothingbooth_item
	var/name = null
	var/path
	var/slot
	var/category = "Misc"
	var/cost = 0
	var/amount = 0 // UNUSED FOR NOW but keeping it here for possible future purposes
	var/hidden = 0 // also unused, maybe you'll need to bribe the goblin inside the booth with snacks in the future? :)

/datum/clothingbooth_item/New()
	..()
	if(!name)
		var/obj/O = src.path
		src.name = initial(O.name)
	cost = round(cost)


//Accessories

ABSTRACT_TYPE(/datum/clothingbooth_item/accessory)
/datum/clothingbooth_item/accessory
	name = "accessory"
	category = "Accessories"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/accessory/gold
	name = "Gold Ring"
	path = /obj/item/clothing/gloves/ring/gold
	slot = SLOT_GLOVES
	cost = PAY_IMPORTANT
	hidden = 1

/datum/clothingbooth_item/accessory/monocle
	name = "Monocle"
	path = /obj/item/clothing/glasses/monocle
	slot = SLOT_GLASSES
	cost = PAY_IMPORTANT/3

/datum/clothingbooth_item/accessory/scarf
	name = "French Scarf"
	path = /obj/item/clothing/suit/scarf
	slot = SLOT_WEAR_SUIT

/datum/clothingbooth_item/accessory/suspenders
	name = "Suspenders"
	path = /obj/item/clothing/suit/suspenders
	slot = SLOT_WEAR_SUIT

ABSTRACT_TYPE(/datum/clothingbooth_item/accessory/goggles)
/datum/clothingbooth_item/accessory/goggles
	name = "Costume Goggles"
	slot = SLOT_HEAD

	yellow
		name = "Yellow Costume Goggles"
		path = /obj/item/clothing/head/goggles/yellow

	red
		name = "Red Costume Goggles"
		path = /obj/item/clothing/head/goggles/red

	purple
		name = "Purple Costume Goggles"
		path = /obj/item/clothing/head/goggles/purple

	green
		name = "Green Costume Goggles"
		path = /obj/item/clothing/head/goggles/green

	blue
		name = "Blue Costume Goggles"
		path = /obj/item/clothing/head/goggles/blue

ABSTRACT_TYPE(/datum/clothingbooth_item/accessory/hbow)
/datum/clothingbooth_item/accessory/hbow
	name = "Hair Bow"
	slot = SLOT_HEAD

	magenta
		name = "Magenta Hair Bow"
		path = /obj/item/clothing/head/hairbow/magenta

	pink
		name = "Pink Hair Bow"
		path = /obj/item/clothing/head/hairbow/pink

	red
		name = "Red Hair Bow"
		path = /obj/item/clothing/head/hairbow/red

	gold
		name = "Gold Hair Bow"
		path = /obj/item/clothing/head/hairbow/gold

	green
		name = "Green Hair Bow"
		path = /obj/item/clothing/head/hairbow/green

	mint
		name = "Mint Hair Bow"
		path = /obj/item/clothing/head/hairbow/mint

	blue
		name = "Blue Hair Bow"
		path = /obj/item/clothing/head/hairbow/blue

	navy
		name = "Navy Hair Bow"
		path = /obj/item/clothing/head/hairbow/navy

	purple
		name = "Purple Hair Bow"
		path = /obj/item/clothing/head/hairbow/purple

	purple
		name = "Purple Hair Bow"
		path = /obj/item/clothing/head/hairbow/purple

	shinyblack
		name = "Shiny Black Hair Bow"
		path = /obj/item/clothing/head/hairbow/shinyblack

	matteblack
		name = "Matte Black Hair Bow"
		path = /obj/item/clothing/head/hairbow/matteblack

	white
		name = "White Hair Bow"
		path = /obj/item/clothing/head/hairbow/white

	rainbow
		name = "Rainbow Hair Bow"
		path = /obj/item/clothing/head/hairbow/rainbow

	yellowpolkadot
		name = "Yellow Polka-Dot Hair Bow"
		path = /obj/item/clothing/head/hairbow/yellowpolkadot

ABSTRACT_TYPE(/datum/clothingbooth_item/accessory/hairclips)
/datum/clothingbooth_item/accessory/hairclips
	name = "Hairclips"
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/5

	red
		name = "Red Hairclip"
		path = /obj/item/clothing/head/sailormoon

	butterflyblu
		name = "Blue Butterfly Hairclip"
		path = /obj/item/clothing/head/barrette/butterflyblu

	butterflyorg
		name = "Orange Butterfly Hairclip"
		path = /obj/item/clothing/head/barrette/butterflyorg

	barrette_blue
		name = "Blue Hairclips"
		path = /obj/item/clothing/head/barrette/blue

	barrette_green
		name = "Green Hairclips"
		path = /obj/item/clothing/head/barrette/green

	barrette_pink
		name = "Pink Hairclips"
		path = /obj/item/clothing/head/barrette/pink

	barrette_gold
		name = "Gold Hairclips"
		path = /obj/item/clothing/head/barrette/gold

	barrette_black
		name = "Black Hairclips"
		path = /obj/item/clothing/head/barrette/black

	barrette_silver
		name = "Silver Hairclips"
		path = /obj/item/clothing/head/barrette/silver

//Casual

ABSTRACT_TYPE(/datum/clothingbooth_item/casual)
/datum/clothingbooth_item/casual
	name = "casual"
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casual/casualjeanswb
	name = "White Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeanswb

/datum/clothingbooth_item/casual/casualjeansskr
	name = "Red Skull Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansskr

/datum/clothingbooth_item/casual/casualjeansskb
	name = "Black Skull Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansskb

/datum/clothingbooth_item/casual/casualjeansyel
	name = "Yellow Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansyel

/datum/clothingbooth_item/casual/casualjeansacid
	name = "Skull Shirt and Acid Wash Jeans"
	path = /obj/item/clothing/under/misc/casualjeansacid

/datum/clothingbooth_item/casual/casualjeansgrey
	name = "Grey Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansgrey

/datum/clothingbooth_item/casual/casualjeanspurp
	name = "Purple Shirt and White Jeans"
	path = /obj/item/clothing/under/misc/casualjeanspurp

/datum/clothingbooth_item/casual/casualjeansblue
	name = "Blue Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansblue

/datum/clothingbooth_item/casual/casualjeanskhaki
	name = "Khaki Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeanskhaki

/datum/clothingbooth_item/casual/lshirt
	name = "Long Sleeved Shirt"
	path = /obj/item/clothing/suit/lshirt

/datum/clothingbooth_item/casual/tracksuit_black
	name = "Black Tracksuit"
	path = /obj/item/clothing/under/gimmick/adidad

/datum/clothingbooth_item/casual/yoga
	name = "Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/casual/yogared
	name = "Red Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga/red
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/casual/yogacommunist
	name = "VERY Red Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga/communist
	cost = PAY_TRADESMAN/3
	hidden = 1

/datum/clothingbooth_item/casual/dirtyvest
	name = "Dirty Tank Top Vest"
	path = /obj/item/clothing/under/misc/dirty_vest

/datum/clothingbooth_item/casual/bandshirt
	name = "Band Shirt"
	path = /obj/item/clothing/under/misc/bandshirt

/datum/clothingbooth_item/casual/flannel
	name = "Flannel"
	path = /obj/item/clothing/under/misc/flannel

/datum/clothingbooth_item/casual/tech_shirt
	name = "Tech Shirt"
	path = /obj/item/clothing/under/misc/tech_shirt

/datum/clothingbooth_item/casual/bubble_shirt
	name = "Bubble Shirt"
	path = /obj/item/clothing/under/misc/bubble

/datum/clothingbooth_item/casual/spade
	name = "Spade Shirt"
	path = /obj/item/clothing/under/misc/spade

/datum/clothingbooth_item/casual/club
	name = "Club Shirt"
	path = /obj/item/clothing/under/misc/club

/datum/clothingbooth_item/casual/heart
	name = "Heart Shirt"
	path = /obj/item/clothing/under/misc/heart

/datum/clothingbooth_item/casual/diamond
	name = "Diamond Shirt"
	path = /obj/item/clothing/under/misc/diamond

/datum/clothingbooth_item/casual/collar_pink
	name = "Pink Collar Shirt"
	path = /obj/item/clothing/under/misc/collar_pink

/datum/clothingbooth_item/casual/flame_purple
	name = "Purple Flame Shirt"
	path = /obj/item/clothing/under/misc/flame_purple

/datum/clothingbooth_item/casual/flame_rainbow
	name = "Rainbow Flame Shirt"
	path = /obj/item/clothing/under/misc/flame_rainbow
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/casual/fish
	name = "Fish Shirt"
	path = /obj/item/clothing/under/misc/fish

//Dresses

ABSTRACT_TYPE(/datum/clothingbooth_item/dress)
/datum/clothingbooth_item/dress
	name = "dress"
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_UNTRAINED/3
/datum/clothingbooth_item/dress/hawaiian
	name = "Hawaiian Dress"
	path = /obj/item/clothing/under/misc/dress/hawaiian
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/dress/casdressblk
	name = "Black Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressblk

/datum/clothingbooth_item/dress/casdressblu
	name = "Blue Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressblu

/datum/clothingbooth_item/dress/casdressgrn
	name = "Green Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressgrn

/datum/clothingbooth_item/dress/casdresspnk
	name = "Pink Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdresspnk

/datum/clothingbooth_item/dress/casdresswht
	name = "White Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdresswht

/datum/clothingbooth_item/dress/casdressbolty
	name = "Bolt Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressbolty
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dress/casdressboltp
	name = "Purple Bolt Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressboltp
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dress/casdressleoy
	name = "Leopard Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressleoy
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dress/casdressleop
	name = "Pink Leopard Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressleop
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dress/sktdress_red
	name = "Red and Black Skirt Dress"
	path = /obj/item/clothing/under/misc/sktdress_red
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dress/sktdress_purple
	name = "Purple and Black Skirt Dress"
	path = /obj/item/clothing/under/misc/sktdress_purple
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dress/sktdress_blue
	name = "Blue and Black Skirt Dress"
	path = /obj/item/clothing/under/misc/sktdress_blue
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dress/sktdress_gold
	name = "Gold and Black Skirt Dress"
	path = /obj/item/clothing/under/misc/sktdress_gold
	cost = PAY_TRADESMAN/3

//Formalwear

ABSTRACT_TYPE(/datum/clothingbooth_item/formal)
/datum/clothingbooth_item/formal
	name = "formal"
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/formal/shirtandpantsblack
	name = "Shirt and Black Pants"
	path = /obj/item/clothing/under/shirt_pants_b
/datum/clothingbooth_item/formal/shirtandpantsblack_redtie
	name = "Shirt and Black Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_b/redtie

/datum/clothingbooth_item/formal/shirtandpantsblack_blacktie
	name = "Shirt and Black Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_b/blacktie

/datum/clothingbooth_item/formal/shirtandpantsblack_bluetie
	name = "Shirt and Black Pants with Blue Tie"
	path = /obj/item/clothing/under/shirt_pants_b/bluetie

/datum/clothingbooth_item/formal/shirtandpantsbrown
	name = "Shirt and Brown Pants"
	path = /obj/item/clothing/under/shirt_pants_br

/datum/clothingbooth_item/formal/shirtandpantsbrown_redtie
	name = "Shirt and Brown Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_br/redtie

/datum/clothingbooth_item/formal/shirtandpantsbrown_blacktie
	name = "Shirt and Brown Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_br/blacktie

/datum/clothingbooth_item/formal/shirtandpantsbrown_bluetie
	name = "Shirt and Brown Pants with Blue Tie"
	path = /obj/item/clothing/under/shirt_pants_br/bluetie

/datum/clothingbooth_item/formal/shirtandpantswhite
	name = "Shirt and White Pants"
	path = /obj/item/clothing/under/shirt_pants_w

/datum/clothingbooth_item/formal/shirtandpantswhite_redtie
	name = "Shirt and White Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_w/redtie

/datum/clothingbooth_item/formal/shirtandpantswhite_blacktie
	name = "Shirt and White Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_w/blacktie

/datum/clothingbooth_item/formal/shirtandpantswhite_bluetie
	name = "Shirt and White Pants with White Tie"
	path = /obj/item/clothing/under/shirt_pants_w/bluetie

/datum/clothingbooth_item/formal/redtie
	name = "Shirt and Loose Red Tie"
	path = /obj/item/clothing/under/redtie

/datum/clothingbooth_item/formal/tux
	name = "Tuxedo"
	path = /obj/item/clothing/under/rank/bartender/tuxedo
	cost = PAY_DOCTORATE/3
	hidden = 1

/datum/clothingbooth_item/formal/waistcoat
	name = "Waistcoat"
	path = /obj/item/clothing/suit/wcoat

/datum/clothingbooth_item/formal/black_wcoat
	name = "Black Waistcoat"
	path = /obj/item/clothing/under/gimmick/black_wcoat
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/formal/red_wcoat
	name = "Red Waistcoat"
	path = /obj/item/clothing/under/gimmick/red_wcoat
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/formal/blue_wcoat
	name = "Blue Waistcoat"
	path = /obj/item/clothing/under/gimmick/blue_wcoat
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/formal/butler
	name = "Butler's Suit"
	path = /obj/item/clothing/under/gimmick/butler
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/formal/maid
	name = "Maid's Outfit"
	path = /obj/item/clothing/under/gimmick/maid

/datum/clothingbooth_item/formal/dress
	name = "Little Black Dress"
	path = /obj/item/clothing/under/misc/dress
	cost = PAY_IMPORTANT/3

/datum/clothingbooth_item/formal/dressred
	name = "Little Red Dress"
	path = /obj/item/clothing/under/misc/dress/red
	cost = PAY_IMPORTANT/3

/datum/clothingbooth_item/formal/dressb
	name = "Black Sun Dress"
	path = /obj/item/clothing/suit/dressb
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/formal/weddingdress
	name = "Wedding Dress"
	path = /obj/item/clothing/under/gimmick/wedding_dress
	cost = PAY_IMPORTANT*3
	hidden = 1

/datum/clothingbooth_item/formal/veil
	name = "Lace Veil"
	path = /obj/item/clothing/head/veil
	slot = SLOT_HEAD
	cost = PAY_IMPORTANT
	hidden = 1

/datum/clothingbooth_item/formal/fancy_vest
	name = "Fancy Vest"
	path = /obj/item/clothing/under/misc/fancy_vest
	cost = PAY_DOCTORATE/3

//Outerwear

ABSTRACT_TYPE(/datum/clothingbooth_item/outerwear)
/datum/clothingbooth_item/outerwear
	name = "outerwear"
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/outerwear/cerulean
	name = "Cerulean Jacket"
	path = /obj/item/clothing/suit/jacket/design/cerulean

/datum/clothingbooth_item/outerwear/grey
	name = "Grey Jacket"
	path = /obj/item/clothing/suit/jacket/design/grey

/datum/clothingbooth_item/outerwear/indigo
	name = "Indigo Jacket"
	path = /obj/item/clothing/suit/jacket/design/indigo

/datum/clothingbooth_item/outerwear/magenta
	name = "Magenta Jacket"
	path = /obj/item/clothing/suit/jacket/design/magenta

/datum/clothingbooth_item/outerwear/maroon
	name = "Maroon Jacket"
	path = /obj/item/clothing/suit/jacket/design/maroon

/datum/clothingbooth_item/outerwear/mint
	name = "Mint Jacket"
	path = /obj/item/clothing/suit/jacket/design/mint

/datum/clothingbooth_item/outerwear/navy
	name = "Navy Jacket"
	path = /obj/item/clothing/suit/jacket/design/navy

/datum/clothingbooth_item/outerwear/tan
	name = "Tan Jacket"
	path = /obj/item/clothing/suit/jacket/design/tan

/datum/clothingbooth_item/outerwear/orangehoodie
	name = "Orange Hoodie"
	path = /obj/item/clothing/suit/hoodie
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/bluehoodie
	name = "Blue Hoodie"
	path = /obj/item/clothing/suit/hoodie/blue
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/darkbluehoodie
	name = "Dark Blue Hoodie"
	path = /obj/item/clothing/suit/hoodie/darkblue
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/whitehoodie
	name = "White Hoodie"
	path = /obj/item/clothing/suit/hoodie/white
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/pinkhoodie
	name = "Pink Hoodie"
	path = /obj/item/clothing/suit/hoodie/pink
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/blackhoodie
	name = "Black Hoodie"
	path = /obj/item/clothing/suit/hoodie/black
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/greyhoodie
	name = "Grey Hoodie"
	path = /obj/item/clothing/suit/hoodie/grey
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/dullgreyhoodie
	name = "Dull Grey Hoodie"
	path = /obj/item/clothing/suit/hoodie/dullgrey
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/magentahoodie
	name = "Magenta Hoodie"
	path = /obj/item/clothing/suit/hoodie/magenta
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/greenhoodie
	name = "Green Hoodie"
	path = /obj/item/clothing/suit/hoodie/green
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/yellowhoodie
	name = "Yellow Hoodie"
	path = /obj/item/clothing/suit/hoodie/yellow
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/redhoodie
	name = "Red Hoodie"
	path = /obj/item/clothing/suit/hoodie/red
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/poncho
	name = "Poncho"
	path = /obj/item/clothing/suit/poncho
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/outerwear/loosejacket
	name = "Loose Jacket"
	path = /obj/item/clothing/suit/loosejacket

/datum/clothingbooth_item/outerwear/johhnycoat
	name = "Overcoat and Scarf"
	path = /obj/item/clothing/suit/johnny_coat

/datum/clothingbooth_item/outerwear/merchantjacket
	name = "Tacky Merchants Jacket"
	path = /obj/item/clothing/suit/merchant

/datum/clothingbooth_item/outerwear/jean_jacket
	name = "Jean Jackett"
	path = /obj/item/clothing/suit/jean_jacket

/datum/clothingbooth_item/outerwear/tuxedojacket
	name = "Tuxedo Jacket"
	path = /obj/item/clothing/suit/tuxedo_jacket
	cost = PAY_DOCTORATE/3
	hidden = 1

/datum/clothingbooth_item/outerwear/guardscoat
	name = "Guard's Coat"
	path = /obj/item/clothing/suit/guards_coat
	cost = PAY_IMPORTANT/3

//Shoes

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes)
/datum/clothingbooth_item/shoes
	name = "shoes"
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/shoes/dress_shoes
	name = "Dress Shoes"
	path = /obj/item/clothing/shoes/dress_shoes
	cost = PAY_DOCTORATE/5
	hidden = 1

/datum/clothingbooth_item/shoes/floppyboots
	name = "Floppy Boots"
	path = /obj/item/clothing/shoes/floppy

/datum/clothingbooth_item/shoes/blackheels
	name = "Black Heels"
	path = /obj/item/clothing/shoes/heels/black
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/shoes/redheels
	name = "Red Heels"
	path = /obj/item/clothing/shoes/heels/red
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/shoes/whiteheels
	name = "White Heels"
	path = /obj/item/clothing/shoes/heels
	cost = PAY_DOCTORATE/5
	hidden = 1

/datum/clothingbooth_item/shoes/bootsblk
	name = "Black Boots"
	path = /obj/item/clothing/shoes/bootsblk
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/shoes/bootswht
	name = "White Boots"
	path = /obj/item/clothing/shoes/bootswht
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/shoes/bootsbrn
	name = "Brown Boots"
	path = /obj/item/clothing/shoes/bootsbrn
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/shoes/bootsblu
	name = "Blue Boots"
	path = /obj/item/clothing/shoes/bootsblu
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/shoes/flatsblk
	name = "Black Flats"
	path = /obj/item/clothing/shoes/flatsblk

/datum/clothingbooth_item/shoes/flatswht
	name = "White Flats"
	path = /obj/item/clothing/shoes/flatswht

/datum/clothingbooth_item/shoes/flatsbrn
	name = "Brown Flats"
	path = /obj/item/clothing/shoes/flatsbrn

/datum/clothingbooth_item/shoes/flatsblu
	name = "Blue Flats"
	path = /obj/item/clothing/shoes/flatsblu

/datum/clothingbooth_item/shoes/flatspnk
	name = "Pink Flats"
	path = /obj/item/clothing/shoes/flatspnk

/datum/clothingbooth_item/shoes/mjblack
	name = "Black Mary Janes"
	path = /obj/item/clothing/shoes/mjblack

/datum/clothingbooth_item/shoes/mjbrown
	name = "Brown Mary Janes"
	path = /obj/item/clothing/shoes/mjbrown

/datum/clothingbooth_item/shoes/mjnavy
	name = "Navy Mary Janes"
	path = /obj/item/clothing/shoes/mjnavy

/datum/clothingbooth_item/shoes/mjwhite
	name = "White Mary Janes"
	path = /obj/item/clothing/shoes/mjwhite

//Headwear

ABSTRACT_TYPE(/datum/clothingbooth_item/head)
/datum/clothingbooth_item/head
	name = "head"
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/head/catears_white
	name = "White Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/white

/datum/clothingbooth_item/head/catears_gray
	name = "Gray Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/gray

/datum/clothingbooth_item/head/catears_black
	name = "Black Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/black

/datum/clothingbooth_item/head/catears_red
	name = "Red Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/red

/datum/clothingbooth_item/head/catears_orange
	name = "Orange Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/orange

/datum/clothingbooth_item/head/catears_yellow
	name = "Yellow Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/yellow

/datum/clothingbooth_item/head/catears_green
	name = "Green Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/green

/datum/clothingbooth_item/head/catears_blue
	name = "Blue Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/blue

/datum/clothingbooth_item/head/catears_purple
	name = "Purple Cat Ears"
	path = /obj/item/clothing/head/headband/nyan/purple

/datum/clothingbooth_item/head/maid_headwear
	name = "Maid Headwear"
	path = /obj/item/clothing/head/maid
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/head/tophat
	name = "Top Hat"
	path = /obj/item/clothing/head/that

/datum/clothingbooth_item/head/whtophat
	name = "White Top Hat"
	path = /obj/item/clothing/head/that/white

/datum/clothingbooth_item/head/blackfedora
	name = "Black Fedora"
	path = /obj/item/clothing/head/fedora
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/head/brownfedora
	name = "Brown Fedora"
	path = /obj/item/clothing/head/det_hat
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/head/whitefedora
	name = "White Fedora"
	path = /obj/item/clothing/head/mj_hat
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/head/bowler
	name = "Bowler Hat"
	path = /obj/item/clothing/head/mime_bowler
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/head/beret
	name = "Black Beret"
	path = /obj/item/clothing/head/mime_beret
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/head/cowboy
	name = "Cowboy Hat"
	path = /obj/item/clothing/head/cowboy
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/head/pokervisor
	name = "Green Visor"
	path = /obj/item/clothing/head/pokervisor
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/head/headsprout
	name = "Leaf Hairclip"
	path = /obj/item/clothing/head/headsprout

/datum/clothingbooth_item/head/pomhat_red
	name = "Red Pomhat"
	path = /obj/item/clothing/head/pomhat_red

/datum/clothingbooth_item/head/pomhat_blue
	name = "Blue Pomhat"
	path = /obj/item/clothing/head/pomhat_blue

/datum/clothingbooth_item/head/ushanka
	name = "Ushanka"
	path = /obj/item/clothing/head/ushanka
	cost = PAY_TRADESMAN

/datum/clothingbooth_item/head/pinwheel_hat
	name = "Pinwheel Hat"
	path = /obj/item/clothing/head/pinwheel_hat
	cost = PAY_TRADESMAN

/datum/clothingbooth_item/head/frog_hat
	name = "Frog Hat"
	path = /obj/item/clothing/head/frog_hat
	cost = PAY_TRADESMAN

/datum/clothingbooth_item/head/link
	name = "Hero Hat"
	path = /obj/item/clothing/head/link
	cost = PAY_TRADESMAN

ABSTRACT_TYPE(/datum/clothingbooth_item/head/frenchberet)
/datum/clothingbooth_item/head/frenchberet
	name = "French Beret"
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/3

	white
		name = "White French Beret"
		path = /obj/item/clothing/head/frenchberet/white

	purple
		name = "Purple French Beret"
		path = /obj/item/clothing/head/frenchberet/purple

	blue
		name = "Blue French Beret"
		path = /obj/item/clothing/head/frenchberet/blue

	pink
		name = "Pink French Beret"
		path = /obj/item/clothing/head/frenchberet/pink

	mint
		name = "Mint French Beret"
		path = /obj/item/clothing/head/frenchberet/mint

	yellow
		name = "Yellow French Beret"
		path = /obj/item/clothing/head/frenchberet/yellow

	strawberry
		name = "Strawberry Beret"
		path = /obj/item/clothing/head/frenchberet/strawberry

	blueberry
		name = "Blueberry Beret"
		path = /obj/item/clothing/head/frenchberet/blueberry

ABSTRACT_TYPE(/datum/clothingbooth_item/head/basecap)
/datum/clothingbooth_item/head/basecap
	name = "Baseball Cap"
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/5

	black
		name = "Black Baseball Cap"
		path = /obj/item/clothing/head/basecap/black

	purple
		name = "Purple Baseball Cap"
		path = /obj/item/clothing/head/basecap/purple

	red
		name = "Red Baseball Cap"
		path = /obj/item/clothing/head/basecap/red

	yellow
		name = "Yellow Baseball Cap"
		path = /obj/item/clothing/head/basecap/yellow

	green
		name = "Green Baseball Cap"
		path = /obj/item/clothing/head/basecap/green

	blue
		name = "Blue Baseball Cap"
		path = /obj/item/clothing/head/basecap/blue

	white
		name = "White Baseball Cap"
		path = /obj/item/clothing/head/basecap/white

	pink
		name = "Pink Baseball Cap"
		path = /obj/item/clothing/head/basecap/pink

//Sci-Fi

ABSTRACT_TYPE(/datum/clothingbooth_item/scifi)
/datum/clothingbooth_item/scifi
	name = "scifi"
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/scifi/sfjumpsuitbp
	name = "Black and Purple Sci-Fi Jumpsuit"
	path = /obj/item/clothing/under/misc/sfjumpsuitbp

/datum/clothingbooth_item/scifi/sfjumpsuitrb
	name = "Black and Red Sci-Fi Jumpsuit"
	path = /obj/item/clothing/under/misc/sfjumpsuitrb

/datum/clothingbooth_item/scifi/sfjumpsuitpnk
	name = "Pink and Blue Sci-Fi Jumpsuit"
	path = /obj/item/clothing/under/misc/sfjumpsuitpnk

/datum/clothingbooth_item/scifi/sfjumpsuitbee
	name = "Bee Sci-Fi Jumpsuit"
	path = /obj/item/clothing/under/misc/sfjumpsuitbee

/datum/clothingbooth_item/scifi/racingsuitbee
	name = "Bee Racing Jumpsuit"
	path = /obj/item/clothing/under/misc/racingsuitbee

/datum/clothingbooth_item/scifi/racingsuitpnk
	name = "Pink and Blue Racing Jumpsuit"
	path = /obj/item/clothing/under/misc/racingsuitpnk

/datum/clothingbooth_item/scifi/racingsuitrbw
	name = "Blue and White Racing Jumpsuit"
	path = /obj/item/clothing/under/misc/racingsuitrbw

/datum/clothingbooth_item/scifi/racingsuitprp
	name = "Purple and Black Racing Jumpsuit"
	path = /obj/item/clothing/under/misc/racingsuitprp

/datum/clothingbooth_item/scifi/cwhat
	name = "Moebius-Brand Headwear"
	path = /obj/item/clothing/head/cwhat
	slot = SLOT_HEAD

/datum/clothingbooth_item/scifi/fthat
	name = "Trader's Headwear"
	path = /obj/item/clothing/head/fthat
	slot = SLOT_HEAD
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/scifi/ftscanplate
	name = "FTX-480 Scanner Plate"
	path = /obj/item/clothing/glasses/ftscanplate
	slot = SLOT_GLASSES
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/scifi/cwfashion
	name = "CW Fashionista's Outfit"
	path = /obj/item/clothing/under/gimmick/cwfashion
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/scifi/ftuniform
	name = "Free Trader's Outfit"
	path = /obj/item/clothing/under/gimmick/ftuniform

/datum/clothingbooth_item/scifi/handcomp
	name = "Compudyne 0451 Handcomp"
	path = /obj/item/clothing/gloves/handcomp
	slot = SLOT_GLOVES
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/scifi/cwboots
	name = "Macando Boots"
	path = /obj/item/clothing/shoes/cwboots
	slot = SLOT_SHOES
	cost = PAY_DOCTORATE/5

//Summer

ABSTRACT_TYPE(/datum/clothingbooth_item/summer)
/datum/clothingbooth_item/summer
	name = "summer"
	slot = SLOT_W_UNIFORM
	category = "Summer"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/summer/collardressbl
	name = "Black Collar Dress"
	path = /obj/item/clothing/under/collardressbl

/datum/clothingbooth_item/summer/sunhatb
	name = "Blue Sunhat"
	path = /obj/item/clothing/head/sunhat
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/summer/collardressb
	name = "Blue Collar Dress"
	path = /obj/item/clothing/under/collardressb

/datum/clothingbooth_item/summer/sunhatg
	name = "Green Sunhat"
	path = /obj/item/clothing/head/sunhat/sunhatg
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/summer/collardressg
	name = "Green Collar Dress"
	path = /obj/item/clothing/under/collardressg

/datum/clothingbooth_item/summer/sunhatr
	name = "Red Sunhat"
	path = /obj/item/clothing/head/sunhat/sunhatr
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/summer/collardressr
	name = "Red Collar Dress"
	path = /obj/item/clothing/under/collardressr

//Masquerade

ABSTRACT_TYPE(/datum/clothingbooth_item/masquerade)
/datum/clothingbooth_item/masquerade/
	name = "masquerade"
	category = "Masquerade"

/datum/clothingbooth_item/masquerade/blossommask
	name = "Cherryblossom Mask"
	path = /obj/item/clothing/mask/blossommask
	slot = SLOT_WEAR_MASK
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/masquerade/blossomdress
	name = "Cherryblossom Dress"
	path = /obj/item/clothing/under/blossomdress
	slot = SLOT_W_UNIFORM
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/masquerade/peacockmask
	name = "Peacock Mask"
	path = /obj/item/clothing/mask/peacockmask
	slot = SLOT_WEAR_MASK
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/masquerade/peacockdress
	name = "Peacock Dress"
	path = /obj/item/clothing/under/peacockdress
	slot = SLOT_W_UNIFORM
	cost = PAY_DOCTORATE/3

//Costumes

ABSTRACT_TYPE(/datum/clothingbooth_item/costume)
/datum/clothingbooth_item/costume
	name = "costume"
	slot = SLOT_W_UNIFORM
	category = "Costumes"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/costume/rando
	name = "Skull Mask and Cloak"
	path = /obj/item/clothing/suit/rando
	slot = SLOT_WEAR_SUIT
	cost = PAY_TRADESMAN/2
	hidden = 1

/datum/clothingbooth_item/costume/offbrandlabcoat
	name = "Off-Brand Lab Coat"
	path = /obj/item/clothing/suit/labcoatlong
	slot = SLOT_WEAR_SUIT
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/costume/russsianmob
	name = "Russian Mobster Suit"
	path = /obj/item/clothing/under/misc/rusmob

/datum/clothingbooth_item/costume/columbianmob
	name = "Columbian Mobster Suit"
	path = /obj/item/clothing/under/misc/colmob

/datum/clothingbooth_item/costume/dinerdress_mint
	name = "Mint Diner Waitress's Dress"
	path = /obj/item/clothing/under/gimmick/dinerdress_mint

/datum/clothingbooth_item/costume/dinerdress_pink
	name = "Pink Diner Waitress's Dress"
	path = /obj/item/clothing/under/gimmick/dinerdress_pink

/datum/clothingbooth_item/costume/waitresshat
	name = "Diner Waitress's Hat"
	path = /obj/item/clothing/head/waitresshat
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/costume/pirate_blk
	name = "Black Pirate Hat"
	path = /obj/item/clothing/head/pirate_blk
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/costume/pirate_brn
	name = "Brown Pirate Hat"
	path = /obj/item/clothing/head/pirate_brn
	slot = SLOT_HEAD
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/costume/guybrush
	name = "Wannabe Pirate Costume"
	path = /obj/item/clothing/under/gimmick/guybrush

/datum/clothingbooth_item/costume/dinosuar
	name = "Dinosaur Pajamas"
	path = /obj/item/clothing/suit/gimmick/dinosaur
	slot = SLOT_WEAR_SUIT
	cost = PAY_TRADESMAN/2

//Western

ABSTRACT_TYPE(/datum/clothingbooth_item/western)
/datum/clothingbooth_item/western
	name = "western"
	category = "Western"
	cost = PAY_UNTRAINED/1

ABSTRACT_TYPE(/datum/clothingbooth_item/western/westhat)
/datum/clothingbooth_item/western/westhat
	name = "Ten-gallon Hat"
	slot = SLOT_HEAD
	cost = PAY_UNTRAINED/2

	beige
		name = "Ten-gallon Hat"
		path = /obj/item/clothing/head/westhat

	black
		name = "Black Ten-gallon Hat"
		path = /obj/item/clothing/head/westhat/black

	blue
		name = "Blue Ten-gallon Hat"
		path = /obj/item/clothing/head/westhat/blue

	brown
		name = "Brown Ten-gallon Hat"
		path = /obj/item/clothing/head/westhat/brown

	tan
		name = "Tan Ten-gallon Hat"
		path = /obj/item/clothing/head/westhat/tan

	red
		name = "Red Ten-gallon Hat"
		path = /obj/item/clothing/head/westhat/red

//Coats, Moved to Cargo Crate Supply pack: west_coats

//Ponchos

/datum/clothingbooth_item/western/flowerponcho
	name = "Flower Poncho"
	path = /obj/item/clothing/suit/poncho/flower
	slot = SLOT_WEAR_SUIT
	cost = PAY_UNTRAINED/1

/datum/clothingbooth_item/western/leafponcho
	name = "Leaf poncho"
	path = /obj/item/clothing/suit/poncho/leaf
	slot = SLOT_WEAR_SUIT
	cost = PAY_UNTRAINED/1

//Jumpsuit

/datum/clothingbooth_item/western/western
	name = "Western Shirt and Pants"
	path = /obj/item/clothing/under/misc/western
	slot = SLOT_W_UNIFORM
	cost = PAY_UNTRAINED/1

/datum/clothingbooth_item/western/westerndress
	name = "Western Saloon Dress"
	path = /obj/item/clothing/under/misc/westerndress
	slot = SLOT_W_UNIFORM
	cost = PAY_UNTRAINED/1

//shoes

ABSTRACT_TYPE(/datum/clothingbooth_item/western/westboot)
/datum/clothingbooth_item/western/westboot
	name = "Real Cowboy Boots"
	slot = SLOT_SHOES
	cost = PAY_UNTRAINED/2

	real
		name = "Real Cowboy Boots"
		path = /obj/item/clothing/shoes/westboot

	dirty
		name = "Dirty Cowboy Boots"
		path = /obj/item/clothing/shoes/westboot/dirty

	black
		name = "Black Cowboy Boots"
		path = /obj/item/clothing/shoes/westboot/black

	brown
		name = "Brown Cowboy Boots"
		path = /obj/item/clothing/shoes/westboot/brown


