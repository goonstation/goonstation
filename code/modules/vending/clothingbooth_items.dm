/datum/clothingbooth_item
	var/name = null
	var/path
	var/category = "Misc"
	var/cost = 0
	var/amount = 0 // UNUSED FOR NOW but keeping it here for possible future purposes
	var/hidden = 0 // also unused, maybe you'll need to bribe the goblin inside the booth with snacks in the future? :)
	var/icon/cached_icon = null

/datum/clothingbooth_item/New()
	..()
	if(!name)
		var/obj/O = src.path
		src.name = initial(O.name)

/datum/clothingbooth_item/proc/get_icon()
	if(isnull(src.cached_icon))
		if(ispath(src.path, /obj/item/clothing/shoes))
			var/obj/item/clothing/shoes/dummy = src.path
			src.cached_icon = new/icon(initial(dummy.wear_image_icon), "right_" + initial(dummy.icon_state))
			src.cached_icon.Blend(new/icon(initial(dummy.wear_image_icon), "left_" + initial(dummy.icon_state)), ICON_OVERLAY)
		else if(ispath(src.path, /obj/item/clothing))
			var/obj/item/clothing/dummy = src.path
			src.cached_icon = new/icon(initial(dummy.wear_image_icon), initial(dummy.icon_state))
	return src.cached_icon

//Accessories
/datum/clothingbooth_item/gold
	name = "Gold Ring"
	path = /obj/item/clothing/gloves/ring/gold
	category = "Accessories"
	cost = 200
	hidden = 1

/datum/clothingbooth_item/monocole
	name = "Monocole"
	path = /obj/item/clothing/glasses/monocle
	category = "Accessories"
	cost = 180

/datum/clothingbooth_item/scarf
	name = "French Scarf"
	path = /obj/item/clothing/suit/scarf
	category = "Accessories"
	cost = 45

/datum/clothingbooth_item/suspenders
	name = "Suspenders"
	path = /obj/item/clothing/suit/suspenders
	category = "Accessories"
	cost = 70

//Casual
/datum/clothingbooth_item/hawaiian
	name = "Hawaiian Dress"
	path = /obj/item/clothing/under/misc/dress/hawaiian
	category = "Casual"
	cost = 300

/datum/clothingbooth_item/lshirt
	name = "Long Sleeved Shirt"
	path = /obj/item/clothing/suit/lshirt
	category = "Casual"
	cost = 60

/datum/clothingbooth_item/poncho
	name = "Poncho"
	path = /obj/item/clothing/suit/poncho
	category = "Casual"
	cost = 30

/datum/clothingbooth_item/yoga
	name = "Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga
	category = "Casual"
	cost = 40

/datum/clothingbooth_item/yogared
	name = "Red Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga/red
	category = "Casual"
	cost = 40

/datum/clothingbooth_item/yogacommunist
	name = "VERY Red Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga/communist
	category = "Casual"
	cost = 80
	hidden = 1

/datum/clothingbooth_item/dirtyvest
	name = "Dirty Tank Top Vest"
	path = /obj/item/clothing/under/misc/head_of_security
	category = "Casual"
	cost = 25

/datum/clothingbooth_item/bandshirt
	name = "Band Shirt"
	path = /obj/item/clothing/under/misc/bandshirt
	category = "Casual"
	cost = 50

/datum/clothingbooth_item/orangehoodie
	name = "Orange Hoodie"
	path = /obj/item/clothing/suit/hoodie
	category = "Casual"
	cost = 75

/datum/clothingbooth_item/bluehoodie
	name = "Blue Hoodie"
	path = /obj/item/clothing/suit/hoodie/blue
	category = "Casual"
	cost = 75

//Costumes
/datum/clothingbooth_item/rando
	name = "Skull Mask and Cloak"
	path = /obj/item/clothing/suit/rando
	category = "Costumes"
	cost = 160
	hidden = 1

/datum/clothingbooth_item/offbrandlabcoat
	name = "Off-Brand Lab Coat"
	path = /obj/item/clothing/suit/labcoatlong
	category = "Costumes"
	cost = 100

/datum/clothingbooth_item/russsianmob
	name = "Russian Mobster Suit"
	path = /obj/item/clothing/under/misc/rusmob
	category = "Costumes"
	cost = 125

/datum/clothingbooth_item/columbianmob
	name = "Columbian Mobster Suit"
	path = /obj/item/clothing/under/misc/colmob
	category = "Costumes"
	cost = 125

/datum/clothingbooth_item/mobilesuit
	name = "Mobile Robot Suit"
	path = /obj/item/clothing/under/gimmick/mobile_suit
	category = "Costumes"
	cost = 10000

/datum/clothingbooth_item/mobilesuithelmet
	name = "Mobile Robot Helmet"
	path = /obj/item/clothing/head/mobile_suit
	category = "Costumes"
	cost = 1000

//Formal

/datum/clothingbooth_item/shirtandpantsblack
	name = "Shirt and Black Pants"
	path = /obj/item/clothing/under/shirt_pants_b
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantsblack_redtie
	name = "Shirt and Black Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_b/redtie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantsblack_blacktie
	name = "Shirt and Black Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_b/blacktie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantsblack_bluetie
	name = "Shirt and Black Pants with Blue Tie"
	path = /obj/item/clothing/under/shirt_pants_b/bluetie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantsbrown
	name = "Shirt and Brown Pants"
	path = /obj/item/clothing/under/shirt_pants_br
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantsbrown_redtie
	name = "Shirt and Brown Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_br/redtie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantsbrown_blacktie
	name = "Shirt and Brown Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_br/blacktie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantsbrown_bluetie
	name = "Shirt and Brown Pants with Blue Tie"
	path = /obj/item/clothing/under/shirt_pants_br/bluetie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantswhite
	name = "Shirt and White Pants"
	path = /obj/item/clothing/under/shirt_pants_w
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantswhite_redtie
	name = "Shirt and White Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_w/redtie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantswhite_blacktie
	name = "Shirt and White Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_w/blacktie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/shirtandpantswhite_bluetie
	name = "Shirt and White Pants with White Tie"
	path = /obj/item/clothing/under/shirt_pants_w/bluetie
	category = "Formal"
	cost = 100

/datum/clothingbooth_item/redtie
	name = "Shirt and Loose Red Tie"
	path = /obj/item/clothing/under/redtie
	category = "Formal"
	cost = 250

/datum/clothingbooth_item/tux
	name = "Tuxedo"
	path = /obj/item/clothing/under/rank/bartender/tuxedo
	category = "Formal"
	cost = 80
	hidden = 1

/datum/clothingbooth_item/waistcoat
	name = "Waistcoat"
	path = /obj/item/clothing/suit/wcoat
	category = "Formal"
	cost = 60

/datum/clothingbooth_item/butler
	name = "Butler's Suit"
	path = /obj/item/clothing/under/gimmick/butler
	category = "Formal"
	cost = 120

/datum/clothingbooth_item/maid
	name = "Maid's Outfit"
	path = /obj/item/clothing/under/gimmick/maid
	category = "Formal"
	cost = 120

/datum/clothingbooth_item/dress
	name = "Little Black Dress"
	path = /obj/item/clothing/under/misc/dress
	category = "Formal"
	cost = 200

/datum/clothingbooth_item/dressred
	name = "Little Red Dress"
	path = /obj/item/clothing/under/misc/dress/red
	category = "Formal"
	cost = 250

/datum/clothingbooth_item/weddingdress
	name = "Wedding Dress"
	path = /obj/item/clothing/under/gimmick/wedding_dress
	category = "Formal"
	cost = 5000
	hidden = 1

/datum/clothingbooth_item/veil
	name = "Lace Veil"
	path = /obj/item/clothing/head/veil
	category = "Formal"
	cost = 80
	hidden = 1

//Jackets

/datum/clothingbooth_item/cerulean
	name = "Cerulean Jacket"
	path = /obj/item/clothing/suit/jacket/design/cerulean
	category = "Jackets"
	cost = 100

/datum/clothingbooth_item/grey
	name = "Grey Jacket"
	path = /obj/item/clothing/suit/jacket/design/grey
	category = "Jackets"
	cost = 100

/datum/clothingbooth_item/indigo
	name = "Indigo Jacket"
	path = /obj/item/clothing/suit/jacket/design/indigo
	category = "Jackets"
	cost = 100

/datum/clothingbooth_item/magenta
	name = "Magenta Jacket"
	path = /obj/item/clothing/suit/jacket/design/magenta
	category = "Jackets"
	cost = 100

/datum/clothingbooth_item/maroon
	name = "Maroon Jacket"
	path = /obj/item/clothing/suit/jacket/design/maroon
	category = "Jackets"
	cost = 100

/datum/clothingbooth_item/mint
	name = "Mint Jacket"
	path = /obj/item/clothing/suit/jacket/design/mint
	category = "Jackets"
	cost = 100

/datum/clothingbooth_item/navy
	name = "Navy Jacket"
	path = /obj/item/clothing/suit/jacket/design/navy
	category = "Jackets"
	cost = 100

/datum/clothingbooth_item/tan
	name = "Tan Jacket"
	path = /obj/item/clothing/suit/jacket/design/tan
	category = "Jackets"
	cost = 100

/datum/clothingbooth_item/loosejacket
	name = "Loose Jacket"
	path = /obj/item/clothing/suit/loosejacket
	category = "Jackets"
	cost = 250

/datum/clothingbooth_item/johhnycoat
	name = "Overcoat and Scarf"
	path = /obj/item/clothing/suit/johnny_coat
	category = "Jackets"
	cost = 150

/datum/clothingbooth_item/merchantjacket
	name = "Tacky Merchants Jacket"
	path = /obj/item/clothing/suit/merchant
	category = "Jackets"
	cost = 80

/datum/clothingbooth_item/tuxedojacket
	name = "Tuxedo Jacket"
	path = /obj/item/clothing/suit/tuxedo_jacket
	category = "Jackets"
	cost = 250
	hidden = 1

//Masquerade
/datum/clothingbooth_item/blossommask
	name = "Cherryblossom Mask"
	path = /obj/item/clothing/mask/blossommask
	category = "Masquerade"
	cost = 50

/datum/clothingbooth_item/blossomdress
	name = "Cherryblossom Dress"
	path = /obj/item/clothing/under/blossomdress
	category = "Masquerade"
	cost = 300

/datum/clothingbooth_item/peacockmask
	name = "Peacock Mask"
	path = /obj/item/clothing/mask/peacockmask
	category = "Masquerade"
	cost = 50

/datum/clothingbooth_item/peacockdress
	name = "Peacock Dress"
	path = /obj/item/clothing/under/peacockdress
	category = "Masquerade"
	cost = 300

//Sci-Fi
/datum/clothingbooth_item/cwhat
	name = "Moebius-Brand Headwear"
	path = /obj/item/clothing/head/cwhat
	category = "Sci-Fi"
	cost = 120

/datum/clothingbooth_item/fthat
	name = "Trader's Headwear"
	path = /obj/item/clothing/head/fthat
	category = "Sci-Fi"
	cost = 75

/datum/clothingbooth_item/ftscanplate
	name = "FTX-480 Scanner Plate"
	path = /obj/item/clothing/glasses/ftscanplate
	category = "Sci-Fi"
	cost = 250

/datum/clothingbooth_item/cwfashion
	name = "CW Fashionista's Outfit"
	path = /obj/item/clothing/under/gimmick/cwfashion
	category = "Sci-Fi"
	cost = 250

/datum/clothingbooth_item/ftuniform
	name = "Free Trader's Outfit"
	path = /obj/item/clothing/under/gimmick/ftuniform
	category = "Sci-Fi"
	cost = 150

/datum/clothingbooth_item/handcomp
	name = "Compudyne 0451 Handcomp"
	path = /obj/item/clothing/gloves/handcomp
	category = "Sci-Fi"
	cost = 150

/datum/clothingbooth_item/cwboots
	name = "Macando Boots"
	path = /obj/item/clothing/shoes/cwboots
	category = "Sci-Fi"
	cost = 130

//Shoes
/datum/clothingbooth_item/dress_shoes
	name = "Dress Shoes"
	path = /obj/item/clothing/shoes/dress_shoes
	category = "Shoes"
	cost = 130
	hidden = 1

/datum/clothingbooth_item/floppyboots
	name = "Floppy Boots"
	path = /obj/item/clothing/shoes/floppy
	category = "Shoes"
	cost = 130

/datum/clothingbooth_item/blackheels
	name = "Black Heels"
	path = /obj/item/clothing/shoes/heels/black
	category = "Shoes"
	cost = 120

/datum/clothingbooth_item/redheels
	name = "Red Heels"
	path = /obj/item/clothing/shoes/heels/red
	category = "Shoes"
	cost = 120

/datum/clothingbooth_item/whiteheels
	name = "White Heels"
	path = /obj/item/clothing/shoes/heels
	category = "Shoes"
	cost = 150
	hidden = 1

//Summer
/datum/clothingbooth_item/collardressbl
	name = "Black Collar Dress"
	path = /obj/item/clothing/under/collardressbl
	category = "Summer"
	cost = 50

/datum/clothingbooth_item/sunhatb
	name = "Blue Sunhat"
	path = /obj/item/clothing/head/sunhat
	category = "Summer"
	cost = 25

/datum/clothingbooth_item/collardressb
	name = "Blue Collar Dress"
	path = /obj/item/clothing/under/collardressb
	category = "Summer"
	cost = 50

/datum/clothingbooth_item/sunhatg
	name = "Green Sunhat"
	path = /obj/item/clothing/head/sunhat/sunhatg
	category = "Summer"
	cost = 25

/datum/clothingbooth_item/collardressg
	name = "Green Collar Dress"
	path = /obj/item/clothing/under/collardressg
	category = "Summer"
	cost = 50

/datum/clothingbooth_item/sunhatr
	name = "Red Sunhat"
	path = /obj/item/clothing/head/sunhat/sunhatr
	category = "Summer"
	cost = 25

/datum/clothingbooth_item/collardressr
	name = "Red Collar Dress"
	path = /obj/item/clothing/under/collardressr
	category = "Summer"
	cost = 50



// stuff from clothing vendor

/datum/clothingbooth_item/dressb
	path = /obj/item/clothing/suit/dressb
	category = "Formal"
	amount = 2
	cost = 300

//Headwear
/datum/clothingbooth_item/catears_white
	path = /obj/item/clothing/head/nyan/white
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_gray
	path = /obj/item/clothing/head/nyan/gray
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_black
	path = /obj/item/clothing/head/nyan/black
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_red
	path = /obj/item/clothing/head/nyan/red
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_orange
	path = /obj/item/clothing/head/nyan/orange
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_yellow
	path = /obj/item/clothing/head/nyan/yellow
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_green
	path = /obj/item/clothing/head/nyan/green
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_blue
	path = /obj/item/clothing/head/nyan/blue
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_purple
	path = /obj/item/clothing/head/nyan/purple
	category = "Headwear"
	amount = 3
	cost = 200

/datum/clothingbooth_item/tophat
	path = /obj/item/clothing/head/that
	name = "Top Hat"
	category = "Headwear"
	amount = 3
	cost = 100

/datum/clothingbooth_item/blackfedora
	path = /obj/item/clothing/head/fedora
	name = "Black Fedora"
	category = "Headwear"
	cost = 75


/datum/clothingbooth_item/brownfedora
	path = /obj/item/clothing/head/det_hat
	name = "Brown Fedora"
	category = "Headwear"
	cost = 75

/datum/clothingbooth_item/whitefedora
	path = /obj/item/clothing/head/mj_hat
	name = "White Fedora"
	category = "Headwear"
	cost = 75

/datum/clothingbooth_item/bowler
	path = /obj/item/clothing/head/mime_bowler
	name = "Bowler Hat"
	category = "Headwear"
	cost = 50

/datum/clothingbooth_item/beret
	path = /obj/item/clothing/head/mime_beret
	name = "Black Beret"
	category = "Headwear"
	cost = 60

/datum/clothingbooth_item/cowboy
	path = /obj/item/clothing/head/cowboy
	name = "Cowboy Hat"
	category = "Headwear"
	cost = 75

/datum/clothingbooth_item/pokervisor
	path = /obj/item/clothing/head/pokervisor
	name = "Green Visor"
	category = "Accessories"
	cost = 150
