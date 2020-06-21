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

//Formal
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

/datum/clothingbooth_item/redtie
	name = "Shirt and Red Tie"
	path = /obj/item/clothing/under/redtie
	category = "Formal"
	cost = 250

/datum/clothingbooth_item/tux
	name = "Tuxedo"
	path = /obj/item/clothing/under/rank/bartender/tuxedo
	category = "Formal"
	cost = 80
	hidden = 1

/datum/clothingbooth_item/veil
	name = "Lace Veil"
	path = /obj/item/clothing/head/veil
	category = "Formal"
	cost = 80
	hidden = 1

/datum/clothingbooth_item/weddingdress
	name = "Wedding Dress"
	path = /obj/item/clothing/under/gimmick/wedding_dress
	category = "Formal"
	cost = 5000
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

/datum/clothingbooth_item/pokervisor
	path = /obj/item/clothing/head/pokervisor
	category = "Accessories"
	amount = 3
	cost = 150

/datum/clothingbooth_item/catears_white
	path = /obj/item/clothing/head/nyan/white
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_gray
	path = /obj/item/clothing/head/nyan/gray
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_black
	path = /obj/item/clothing/head/nyan/black
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_red
	path = /obj/item/clothing/head/nyan/red
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_orange
	path = /obj/item/clothing/head/nyan/orange
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_yellow
	path = /obj/item/clothing/head/nyan/yellow
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_green
	path = /obj/item/clothing/head/nyan/green
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_blue
	path = /obj/item/clothing/head/nyan/blue
	amount = 3
	cost = 200

/datum/clothingbooth_item/catears_purple
	path = /obj/item/clothing/head/nyan/purple
	amount = 3
	cost = 200
