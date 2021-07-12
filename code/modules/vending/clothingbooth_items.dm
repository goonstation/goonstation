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

	gold
		name = "Gold Ring"
		path = /obj/item/clothing/gloves/ring/gold
		slot = SLOT_GLOVES
		cost = PAY_IMPORTANT
		hidden = 1

	monocle
		name = "Monocle"
		path = /obj/item/clothing/glasses/monocle
		slot = SLOT_GLASSES
		cost = PAY_IMPORTANT/3

	scarf
		name = "French Scarf"
		path = /obj/item/clothing/suit/scarf
		slot = SLOT_WEAR_SUIT

	suspenders
		name = "Suspenders"
		path = /obj/item/clothing/suit/suspenders
		slot = SLOT_WEAR_SUIT


//Casual

ABSTRACT_TYPE(/datum/clothingbooth_item/casual)
/datum/clothingbooth_item/casual
	name = "casual"
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

	casualjeanswb
		name = "White Shirt and Jeans"
		path = /obj/item/clothing/under/misc/casualjeanswb

	casualjeansskr
		name = "Red Skull Shirt and Jeans"
		path = /obj/item/clothing/under/misc/casualjeansskr

	casualjeansskb
		name = "Black Skull Shirt and Jeans"
		path = /obj/item/clothing/under/misc/casualjeansskb

	casualjeansyel
		name = "Yellow Shirt and Jeans"
		path = /obj/item/clothing/under/misc/casualjeansyel

	casualjeansacid
		name = "Skull Shirt and Acid Wash Jeans"
		path = /obj/item/clothing/under/misc/casualjeansacid

	casualjeansgrey
		name = "Grey Shirt and Jeans"
		path = /obj/item/clothing/under/misc/casualjeansgrey

	casualjeanspurp
		name = "Purple Shirt and White Jeans"
		path = /obj/item/clothing/under/misc/casualjeanspurp

	casualjeansblue
		name = "Blue Shirt and Jeans"
		path = /obj/item/clothing/under/misc/casualjeansblue

	casualjeanskhaki
		name = "Khaki Shirt and Jeans"
		path = /obj/item/clothing/under/misc/casualjeanskhaki

	lshirt
		name = "Long Sleeved Shirt"
		path = /obj/item/clothing/suit/lshirt

	yoga
		name = "Yoga Outfit"
		path = /obj/item/clothing/under/misc/yoga
		cost = PAY_TRADESMAN/3

	yogared
		name = "Red Yoga Outfit"
		path = /obj/item/clothing/under/misc/yoga/red
		cost = PAY_TRADESMAN/3

	yogacommunist
		name = "VERY Red Yoga Outfit"
		path = /obj/item/clothing/under/misc/yoga/communist
		cost = PAY_TRADESMAN/3
		hidden = 1

	dirtyvest
		name = "Dirty Tank Top Vest"
		path = /obj/item/clothing/under/misc/head_of_security

	bandshirt
		name = "Band Shirt"
		path = /obj/item/clothing/under/misc/bandshirt


//Dresses

ABSTRACT_TYPE(/datum/clothingbooth_item/dress)
/datum/clothingbooth_item/dress
	name = "dress"
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_UNTRAINED/3
	hawaiian
		name = "Hawaiian Dress"
		path = /obj/item/clothing/under/misc/dress/hawaiian
		cost = PAY_DOCTORATE/3

	casdressblk
		name = "Black Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdressblk

	casdressblu
		name = "Blue Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdressblu

	casdressgrn
		name = "Green Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdressgrn

	casdresspnk
		name = "Pink Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdresspnk

	casdresswht
		name = "White Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdresswht

	casdressbolty
		name = "Bolt Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdressbolty
		cost = PAY_TRADESMAN/3

	casdressboltp
		name = "Purple Bolt Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdressboltp
		cost = PAY_TRADESMAN/3

	casdressleoy
		name = "Leopard Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdressleoy
		cost = PAY_TRADESMAN/3

	casdressleop
		name = "Pink Leopard Tshirt Dress"
		path = /obj/item/clothing/under/misc/casdressleop
		cost = PAY_TRADESMAN/3

	sktdress_red
		name = "Red and Black Skirt Dress"
		path = /obj/item/clothing/under/misc/sktdress_red
		cost = PAY_TRADESMAN/3

	sktdress_purple
		name = "Purple and Black Skirt Dress"
		path = /obj/item/clothing/under/misc/sktdress_purple
		cost = PAY_TRADESMAN/3

	sktdress_blue
		name = "Blue and Black Skirt Dress"
		path = /obj/item/clothing/under/misc/sktdress_blue
		cost = PAY_TRADESMAN/3

	sktdress_gold
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

	shirtandpantsblack
		name = "Shirt and Black Pants"
		path = /obj/item/clothing/under/shirt_pants_b
	shirtandpantsblack_redtie
		name = "Shirt and Black Pants with Red Tie"
		path = /obj/item/clothing/under/shirt_pants_b/redtie

	shirtandpantsblack_blacktie
		name = "Shirt and Black Pants with Black Tie"
		path = /obj/item/clothing/under/shirt_pants_b/blacktie

	shirtandpantsblack_bluetie
		name = "Shirt and Black Pants with Blue Tie"
		path = /obj/item/clothing/under/shirt_pants_b/bluetie

	shirtandpantsbrown
		name = "Shirt and Brown Pants"
		path = /obj/item/clothing/under/shirt_pants_br

	shirtandpantsbrown_redtie
		name = "Shirt and Brown Pants with Red Tie"
		path = /obj/item/clothing/under/shirt_pants_br/redtie

	shirtandpantsbrown_blacktie
		name = "Shirt and Brown Pants with Black Tie"
		path = /obj/item/clothing/under/shirt_pants_br/blacktie

	shirtandpantsbrown_bluetie
		name = "Shirt and Brown Pants with Blue Tie"
		path = /obj/item/clothing/under/shirt_pants_br/bluetie

	shirtandpantswhite
		name = "Shirt and White Pants"
		path = /obj/item/clothing/under/shirt_pants_w

	shirtandpantswhite_redtie
		name = "Shirt and White Pants with Red Tie"
		path = /obj/item/clothing/under/shirt_pants_w/redtie

	shirtandpantswhite_blacktie
		name = "Shirt and White Pants with Black Tie"
		path = /obj/item/clothing/under/shirt_pants_w/blacktie

	shirtandpantswhite_bluetie
		name = "Shirt and White Pants with White Tie"
		path = /obj/item/clothing/under/shirt_pants_w/bluetie

	redtie
		name = "Shirt and Loose Red Tie"
		path = /obj/item/clothing/under/redtie

	tux
		name = "Tuxedo"
		path = /obj/item/clothing/under/rank/bartender/tuxedo
		cost = PAY_DOCTORATE/3
		hidden = 1

	waistcoat
		name = "Waistcoat"
		path = /obj/item/clothing/suit/wcoat

	butler
		name = "Butler's Suit"
		path = /obj/item/clothing/under/gimmick/butler
		cost = PAY_DOCTORATE/3

	maid
		name = "Maid's Outfit"
		path = /obj/item/clothing/under/gimmick/maid

	dress
		name = "Little Black Dress"
		path = /obj/item/clothing/under/misc/dress
		cost = PAY_IMPORTANT/3

	dressred
		name = "Little Red Dress"
		path = /obj/item/clothing/under/misc/dress/red
		cost = PAY_IMPORTANT/3

	dressb
		name = "Black Sun Dress"
		path = /obj/item/clothing/suit/dressb
		cost = PAY_DOCTORATE/3

	weddingdress
		name = "Wedding Dress"
		path = /obj/item/clothing/under/gimmick/wedding_dress
		cost = PAY_IMPORTANT*3
		hidden = 1

	veil
		name = "Lace Veil"
		path = /obj/item/clothing/head/veil
		slot = SLOT_HEAD
		cost = PAY_IMPORTANT
		hidden = 1

//Outerwear

ABSTRACT_TYPE(/datum/clothingbooth_item/outerwear)
/datum/clothingbooth_item/outerwear
	name = "outerwear"
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

	cerulean
		name = "Cerulean Jacket"
		path = /obj/item/clothing/suit/jacket/design/cerulean

	grey
		name = "Grey Jacket"
		path = /obj/item/clothing/suit/jacket/design/grey

	indigo
		name = "Indigo Jacket"
		path = /obj/item/clothing/suit/jacket/design/indigo

	magenta
		name = "Magenta Jacket"
		path = /obj/item/clothing/suit/jacket/design/magenta

	maroon
		name = "Maroon Jacket"
		path = /obj/item/clothing/suit/jacket/design/maroon

	mint
		name = "Mint Jacket"
		path = /obj/item/clothing/suit/jacket/design/mint

	navy
		name = "Navy Jacket"
		path = /obj/item/clothing/suit/jacket/design/navy

	tan
		name = "Tan Jacket"
		path = /obj/item/clothing/suit/jacket/design/tan

	orangehoodie
		name = "Orange Hoodie"
		path = /obj/item/clothing/suit/hoodie

	bluehoodie
		name = "Blue Hoodie"
		path = /obj/item/clothing/suit/hoodie/blue
		cost = PAY_UNTRAINED/3

	poncho
		name = "Poncho"
		path = /obj/item/clothing/suit/poncho
		cost = PAY_UNTRAINED/3

	loosejacket
		name = "Loose Jacket"
		path = /obj/item/clothing/suit/loosejacket

	johhnycoat
		name = "Overcoat and Scarf"
		path = /obj/item/clothing/suit/johnny_coat

	merchantjacket
		name = "Tacky Merchants Jacket"
		path = /obj/item/clothing/suit/merchant

	tuxedojacket
		name = "Tuxedo Jacket"
		path = /obj/item/clothing/suit/tuxedo_jacket
		cost = PAY_DOCTORATE/3
		hidden = 1

//Shoes

ABSTRACT_TYPE(/datum/clothingbooth_item/shoes)
/datum/clothingbooth_item/shoes
	name = "shoes"
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

	dress_shoes
		name = "Dress Shoes"
		path = /obj/item/clothing/shoes/dress_shoes
		cost = PAY_DOCTORATE/5
		hidden = 1

	floppyboots
		name = "Floppy Boots"
		path = /obj/item/clothing/shoes/floppy

	blackheels
		name = "Black Heels"
		path = /obj/item/clothing/shoes/heels/black
		cost = PAY_DOCTORATE/5

	redheels
		name = "Red Heels"
		path = /obj/item/clothing/shoes/heels/red
		cost = PAY_DOCTORATE/5

	whiteheels
		name = "White Heels"
		path = /obj/item/clothing/shoes/heels
		cost = PAY_DOCTORATE/5
		hidden = 1

	bootsblk
		name = "Black Boots"
		path = /obj/item/clothing/shoes/bootsblk
		cost = PAY_DOCTORATE/5

	bootswht
		name = "White Boots"
		path = /obj/item/clothing/shoes/bootswht
		cost = PAY_DOCTORATE/5

	bootsbrn
		name = "Brown Boots"
		path = /obj/item/clothing/shoes/bootsbrn
		cost = PAY_DOCTORATE/5

	bootsblu
		name = "Blue Boots"
		path = /obj/item/clothing/shoes/bootsblu
		cost = PAY_DOCTORATE/5

	flatsblk
		name = "Black Flats"
		path = /obj/item/clothing/shoes/flatsblk

	flatswht
		name = "White Flats"
		path = /obj/item/clothing/shoes/flatswht

	flatsbrn
		name = "Brown Flats"
		path = /obj/item/clothing/shoes/flatsbrn

	flatsblu
		name = "Blue Flats"
		path = /obj/item/clothing/shoes/flatsblu

	flatspnk
		name = "Pink Flats"
		path = /obj/item/clothing/shoes/flatspnk

	mjblack
		name = "Black Mary Janes"
		path = /obj/item/clothing/shoes/mjblack

	mjbrown
		name = "Brown Mary Janes"
		path = /obj/item/clothing/shoes/mjbrown

	mjnavy
		name = "Navy Mary Janes"
		path = /obj/item/clothing/shoes/mjnavy

	mjwhite
		name = "White Mary Janes"
		path = /obj/item/clothing/shoes/mjwhite

//Headwear

ABSTRACT_TYPE(/datum/clothingbooth_item/head)
/datum/clothingbooth_item/head
	name = "head"
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

	catears_white
		name = "White Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/white

	catears_gray
		name = "Gray Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/gray

	catears_black
		name = "Black Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/black

	catears_red
		name = "Red Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/red

	catears_orange
		name = "Orange Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/orange

	catears_yellow
		name = "Yellow Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/yellow

	catears_green
		name = "Green Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/green

	catears_blue
		name = "Blue Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/blue

	catears_purple
		name = "Purple Cat Ears"
		path = /obj/item/clothing/head/headband/nyan/purple

	maid_headwear
		name = "Maid Headwear"
		path = /obj/item/clothing/head/maid
		cost = PAY_TRADESMAN/3

	tophat
		name = "Top Hat"
		path = /obj/item/clothing/head/that

	whtophat
		name = "White Top Hat"
		path = /obj/item/clothing/head/that/white

	blackfedora
		name = "Black Fedora"
		path = /obj/item/clothing/head/fedora
		cost = PAY_TRADESMAN/5

	brownfedora
		name = "Brown Fedora"
		path = /obj/item/clothing/head/det_hat
		cost = PAY_TRADESMAN/5

	whitefedora
		name = "White Fedora"
		path = /obj/item/clothing/head/mj_hat
		cost = PAY_TRADESMAN/5

	bowler
		name = "Bowler Hat"
		path = /obj/item/clothing/head/mime_bowler
		cost = PAY_TRADESMAN/5

	beret
		name = "Black Beret"
		path = /obj/item/clothing/head/mime_beret
		cost = PAY_TRADESMAN/5

	cowboy
		name = "Cowboy Hat"
		path = /obj/item/clothing/head/cowboy
		cost = PAY_TRADESMAN/5

	pokervisor
		name = "Green Visor"
		path = /obj/item/clothing/head/pokervisor
		cost = PAY_TRADESMAN/5

	headsprout
		name = "Leaf Hairclip"
		path = /obj/item/clothing/head/headsprout

	redhairclips
		name = "Red Hairclip"
		path = /obj/item/clothing/head/sailormoon

	butterflyclip_bl
		name = "Blue Butterfly Hairclip"
		path = /obj/item/clothing/head/barrette/butterflyblu

	butterflyclip_o
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

	ushanka
		name = "Ushanka"
		path = /obj/item/clothing/head/ushanka
		cost = PAY_TRADESMAN

	pinwheel_hat
		name = "Pinwheel Hat"
		path = /obj/item/clothing/head/pinwheel_hat
		cost = PAY_TRADESMAN

	frog_hat
		name = "Frog Hat"
		path = /obj/item/clothing/head/frog_hat
		cost = PAY_TRADESMAN

//Sci-Fi

ABSTRACT_TYPE(/datum/clothingbooth_item/scifi)
/datum/clothingbooth_item/scifi
	name = "scifi"
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

	sfjumpsuitbp
		name = "Black and Purple Sci-Fi Jumpsuit"
		path = /obj/item/clothing/under/misc/sfjumpsuitbp

	sfjumpsuitrb
		name = "Black and Red Sci-Fi Jumpsuit"
		path = /obj/item/clothing/under/misc/sfjumpsuitrb

	sfjumpsuitpnk
		name = "Pink and Blue Sci-Fi Jumpsuit"
		path = /obj/item/clothing/under/misc/sfjumpsuitpnk

	sfjumpsuitbee
		name = "Bee Sci-Fi Jumpsuit"
		path = /obj/item/clothing/under/misc/sfjumpsuitbee

	racingsuitbee
		name = "Bee Racing Jumpsuit"
		path = /obj/item/clothing/under/misc/racingsuitbee

	racingsuitpnk
		name = "Pink and Blue Racing Jumpsuit"
		path = /obj/item/clothing/under/misc/racingsuitpnk

	racingsuitrbw
		name = "Blue and White Racing Jumpsuit"
		path = /obj/item/clothing/under/misc/racingsuitrbw

	racingsuitprp
		name = "Purple and Black Racing Jumpsuit"
		path = /obj/item/clothing/under/misc/racingsuitprp

	cwhat
		name = "Moebius-Brand Headwear"
		path = /obj/item/clothing/head/cwhat
		slot = SLOT_HEAD

	fthat
		name = "Trader's Headwear"
		path = /obj/item/clothing/head/fthat
		slot = SLOT_HEAD
		cost = PAY_DOCTORATE/5

	ftscanplate
		name = "FTX-480 Scanner Plate"
		path = /obj/item/clothing/glasses/ftscanplate
		slot = SLOT_GLASSES
		cost = PAY_DOCTORATE/5

	cwfashion
		name = "CW Fashionista's Outfit"
		path = /obj/item/clothing/under/gimmick/cwfashion
		cost = PAY_DOCTORATE/5

	ftuniform
		name = "Free Trader's Outfit"
		path = /obj/item/clothing/under/gimmick/ftuniform

	handcomp
		name = "Compudyne 0451 Handcomp"
		path = /obj/item/clothing/gloves/handcomp
		slot = SLOT_GLOVES
		cost = PAY_DOCTORATE/5

	cwboots
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

	collardressbl
		name = "Black Collar Dress"
		path = /obj/item/clothing/under/collardressbl

	sunhatb
		name = "Blue Sunhat"
		path = /obj/item/clothing/head/sunhat
		slot = SLOT_HEAD
		cost = PAY_TRADESMAN/5

	collardressb
		name = "Blue Collar Dress"
		path = /obj/item/clothing/under/collardressb

	sunhatg
		name = "Green Sunhat"
		path = /obj/item/clothing/head/sunhat/sunhatg
		slot = SLOT_HEAD
		cost = PAY_TRADESMAN/5

	collardressg
		name = "Green Collar Dress"
		path = /obj/item/clothing/under/collardressg

	sunhatr
		name = "Red Sunhat"
		path = /obj/item/clothing/head/sunhat/sunhatr
		slot = SLOT_HEAD
		cost = PAY_TRADESMAN/5

	collardressr
		name = "Red Collar Dress"
		path = /obj/item/clothing/under/collardressr

//Masquerade

ABSTRACT_TYPE(/datum/clothingbooth_item/masquerade)
/datum/clothingbooth_item/masquerade
	name = "masquerade"
	category = "Masquerade"

	blossommask
		name = "Cherryblossom Mask"
		path = /obj/item/clothing/mask/blossommask
		slot = SLOT_WEAR_MASK
		cost = PAY_TRADESMAN/5

	blossomdress
		name = "Cherryblossom Dress"
		path = /obj/item/clothing/under/blossomdress
		slot = SLOT_W_UNIFORM
		cost = PAY_DOCTORATE/3

	peacockmask
		name = "Peacock Mask"
		path = /obj/item/clothing/mask/peacockmask
		slot = SLOT_WEAR_MASK
		cost = PAY_TRADESMAN/5

	peacockdress
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

	rando
		name = "Skull Mask and Cloak"
		path = /obj/item/clothing/suit/rando
		slot = SLOT_WEAR_SUIT
		cost = PAY_TRADESMAN/2
		hidden = 1

	offbrandlabcoat
		name = "Off-Brand Lab Coat"
		path = /obj/item/clothing/suit/labcoatlong
		slot = SLOT_WEAR_SUIT
		cost = PAY_DOCTORATE/3

	russsianmob
		name = "Russian Mobster Suit"
		path = /obj/item/clothing/under/misc/rusmob

	columbianmob
		name = "Columbian Mobster Suit"
		path = /obj/item/clothing/under/misc/colmob

	mobilesuit
		name = "Mobile Robot Suit"
		path = /obj/item/clothing/under/gimmick/mobile_suit
		cost = PAY_EXECUTIVE

	mobilesuithelmet
		name = "Mobile Robot Helmet"
		path = /obj/item/clothing/head/mobile_suit
		slot = SLOT_HEAD
		cost = PAY_EXECUTIVE/2

	dinerdress_mint
		name = "Mint Diner Waitress's Dress"
		path = /obj/item/clothing/under/gimmick/dinerdress_mint

	dinerdress_pink
		name = "Pink Diner Waitress's Dress"
		path = /obj/item/clothing/under/gimmick/dinerdress_pink

	waitresshat
		name = "Diner Waitress's Hat"
		path = /obj/item/clothing/head/waitresshat
		slot = SLOT_HEAD
		cost = PAY_TRADESMAN/5
