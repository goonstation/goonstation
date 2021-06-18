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

/datum/clothingbooth_item/gold
	name = "Gold Ring"
	path = /obj/item/clothing/gloves/ring/gold
	slot = SLOT_GLOVES
	category = "Accessories"
	cost = PAY_IMPORTANT
	hidden = 1

/datum/clothingbooth_item/monocle
	name = "Monocle"
	path = /obj/item/clothing/glasses/monocle
	slot = SLOT_GLASSES
	category = "Accessories"
	cost = PAY_IMPORTANT/3

/datum/clothingbooth_item/scarf
	name = "French Scarf"
	path = /obj/item/clothing/suit/scarf
	slot = SLOT_WEAR_SUIT
	category = "Accessories"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/suspenders
	name = "Suspenders"
	path = /obj/item/clothing/suit/suspenders
	slot = SLOT_WEAR_SUIT
	category = "Accessories"
	cost = PAY_TRADESMAN/3

//Casual

/datum/clothingbooth_item/casualjeanswb
	name = "White Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeanswb
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casualjeansskr
	name = "Red Skull Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansskr
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casualjeansskb
	name = "Black Skull Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansskb
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casualjeansyel
	name = "Yellow Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansyel
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casualjeansacid
	name = "Skull Shirt and Acid Wash Jeans"
	path = /obj/item/clothing/under/misc/casualjeansacid
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casualjeansgrey
	name = "Grey Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansgrey
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casualjeanspurp
	name = "Purple Shirt and White Jeans"
	path = /obj/item/clothing/under/misc/casualjeanspurp
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casualjeansblue
	name = "Blue Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeansblue
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casualjeanskhaki
	name = "Khaki Shirt and Jeans"
	path = /obj/item/clothing/under/misc/casualjeanskhaki
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/lshirt
	name = "Long Sleeved Shirt"
	path = /obj/item/clothing/suit/lshirt
	slot = SLOT_WEAR_SUIT
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/yoga
	name = "Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/yogared
	name = "Red Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga/red
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/yogacommunist
	name = "VERY Red Yoga Outfit"
	path = /obj/item/clothing/under/misc/yoga/communist
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_TRADESMAN/3
	hidden = 1

/datum/clothingbooth_item/dirtyvest
	name = "Dirty Tank Top Vest"
	path = /obj/item/clothing/under/misc/head_of_security
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/bandshirt
	name = "Band Shirt"
	path = /obj/item/clothing/under/misc/bandshirt
	slot = SLOT_W_UNIFORM
	category = "Casual"
	cost = PAY_UNTRAINED/3

//Dresses

/datum/clothingbooth_item/hawaiian
	name = "Hawaiian Dress"
	path = /obj/item/clothing/under/misc/dress/hawaiian
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/casdressblk
	name = "Black Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressblk
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casdressblu
	name = "Blue Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressblu
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casdressgrn
	name = "Green Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressgrn
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casdresspnk
	name = "Pink Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdresspnk
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casdresswht
	name = "White Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdresswht
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/casdressbolty
	name = "Bolt Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressbolty
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/casdressboltp
	name = "Purple Bolt Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressboltp
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/casdressleoy
	name = "Leopard Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressleoy
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/casdressleop
	name = "Pink Leopard Tshirt Dress"
	path = /obj/item/clothing/under/misc/casdressleop
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/sktdress_red
	name = "Red and Black Skirt Dress"
	path = /obj/item/clothing/under/misc/sktdress_red
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/sktdress_purple
	name = "Purple and Black Skirt Dress"
	path = /obj/item/clothing/under/misc/sktdress_purple
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/sktdress_blue
	name = "Blue and Black Skirt Dress"
	path = /obj/item/clothing/under/misc/sktdress_blue
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/sktdress_gold
	name = "Gold and Black Skirt Dress"
	path = /obj/item/clothing/under/misc/sktdress_gold
	slot = SLOT_W_UNIFORM
	category = "Dresses"
	cost = PAY_TRADESMAN/3

//Formalwear

/datum/clothingbooth_item/shirtandpantsblack
	name = "Shirt and Black Pants"
	path = /obj/item/clothing/under/shirt_pants_b
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantsblack_redtie
	name = "Shirt and Black Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_b/redtie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantsblack_blacktie
	name = "Shirt and Black Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_b/blacktie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantsblack_bluetie
	name = "Shirt and Black Pants with Blue Tie"
	path = /obj/item/clothing/under/shirt_pants_b/bluetie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantsbrown
	name = "Shirt and Brown Pants"
	path = /obj/item/clothing/under/shirt_pants_br
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantsbrown_redtie
	name = "Shirt and Brown Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_br/redtie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantsbrown_blacktie
	name = "Shirt and Brown Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_br/blacktie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantsbrown_bluetie
	name = "Shirt and Brown Pants with Blue Tie"
	path = /obj/item/clothing/under/shirt_pants_br/bluetie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantswhite
	name = "Shirt and White Pants"
	path = /obj/item/clothing/under/shirt_pants_w
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantswhite_redtie
	name = "Shirt and White Pants with Red Tie"
	path = /obj/item/clothing/under/shirt_pants_w/redtie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantswhite_blacktie
	name = "Shirt and White Pants with Black Tie"
	path = /obj/item/clothing/under/shirt_pants_w/blacktie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/shirtandpantswhite_bluetie
	name = "Shirt and White Pants with White Tie"
	path = /obj/item/clothing/under/shirt_pants_w/bluetie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/redtie
	name = "Shirt and Loose Red Tie"
	path = /obj/item/clothing/under/redtie
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/tux
	name = "Tuxedo"
	path = /obj/item/clothing/under/rank/bartender/tuxedo
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_DOCTORATE/3
	hidden = 1

/datum/clothingbooth_item/waistcoat
	name = "Waistcoat"
	path = /obj/item/clothing/suit/wcoat
	slot = SLOT_WEAR_SUIT
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/butler
	name = "Butler's Suit"
	path = /obj/item/clothing/under/gimmick/butler
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/maid
	name = "Maid's Outfit"
	path = /obj/item/clothing/under/gimmick/maid
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dress
	name = "Little Black Dress"
	path = /obj/item/clothing/under/misc/dress
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_IMPORTANT/3

/datum/clothingbooth_item/dressred
	name = "Little Red Dress"
	path = /obj/item/clothing/under/misc/dress/red
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_IMPORTANT/3

/datum/clothingbooth_item/dressb
	name = "Black Sun Dress"
	path = /obj/item/clothing/suit/dressb
	slot = SLOT_WEAR_SUIT
	category = "Formal"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/weddingdress
	name = "Wedding Dress"
	path = /obj/item/clothing/under/gimmick/wedding_dress
	slot = SLOT_W_UNIFORM
	category = "Formal"
	cost = PAY_IMPORTANT*3
	hidden = 1

/datum/clothingbooth_item/veil
	name = "Lace Veil"
	path = /obj/item/clothing/head/veil
	slot = SLOT_HEAD
	category = "Formal"
	cost = PAY_IMPORTANT
	hidden = 1

//Outerwear

/datum/clothingbooth_item/cerulean
	name = "Cerulean Jacket"
	path = /obj/item/clothing/suit/jacket/design/cerulean
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/grey
	name = "Grey Jacket"
	path = /obj/item/clothing/suit/jacket/design/grey
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/indigo
	name = "Indigo Jacket"
	path = /obj/item/clothing/suit/jacket/design/indigo
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/magenta
	name = "Magenta Jacket"
	path = /obj/item/clothing/suit/jacket/design/magenta
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/maroon
	name = "Maroon Jacket"
	path = /obj/item/clothing/suit/jacket/design/maroon
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/mint
	name = "Mint Jacket"
	path = /obj/item/clothing/suit/jacket/design/mint
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/navy
	name = "Navy Jacket"
	path = /obj/item/clothing/suit/jacket/design/navy
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/tan
	name = "Tan Jacket"
	path = /obj/item/clothing/suit/jacket/design/tan
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/orangehoodie
	name = "Orange Hoodie"
	path = /obj/item/clothing/suit/hoodie
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/bluehoodie
	name = "Blue Hoodie"
	path = /obj/item/clothing/suit/hoodie/blue
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/poncho
	name = "Poncho"
	path = /obj/item/clothing/suit/poncho
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_UNTRAINED/3

/datum/clothingbooth_item/loosejacket
	name = "Loose Jacket"
	path = /obj/item/clothing/suit/loosejacket
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/johhnycoat
	name = "Overcoat and Scarf"
	path = /obj/item/clothing/suit/johnny_coat
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/merchantjacket
	name = "Tacky Merchants Jacket"
	path = /obj/item/clothing/suit/merchant
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/tuxedojacket
	name = "Tuxedo Jacket"
	path = /obj/item/clothing/suit/tuxedo_jacket
	slot = SLOT_WEAR_SUIT
	category = "Jackets"
	cost = PAY_DOCTORATE/3
	hidden = 1

//Shoes

/datum/clothingbooth_item/dress_shoes
	name = "Dress Shoes"
	path = /obj/item/clothing/shoes/dress_shoes
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_DOCTORATE/5
	hidden = 1

/datum/clothingbooth_item/floppyboots
	name = "Floppy Boots"
	path = /obj/item/clothing/shoes/floppy
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/blackheels
	name = "Black Heels"
	path = /obj/item/clothing/shoes/heels/black
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/redheels
	name = "Red Heels"
	path = /obj/item/clothing/shoes/heels/red
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/whiteheels
	name = "White Heels"
	path = /obj/item/clothing/shoes/heels
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_DOCTORATE/5
	hidden = 1

/datum/clothingbooth_item/bootsblk
	name = "Black Boots"
	path = /obj/item/clothing/shoes/bootsblk
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/bootswht
	name = "White Boots"
	path = /obj/item/clothing/shoes/bootswht
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/bootsbrn
	name = "Brown Boots"
	path = /obj/item/clothing/shoes/bootsbrn
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/bootsblu
	name = "Blue Boots"
	path = /obj/item/clothing/shoes/bootsblu
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/flatsblk
	name = "Black Flats"
	path = /obj/item/clothing/shoes/flatsblk
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/flatswht
	name = "White Flats"
	path = /obj/item/clothing/shoes/flatswht
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/flatsbrn
	name = "Brown Flats"
	path = /obj/item/clothing/shoes/flatsbrn
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/flatsblu
	name = "Blue Flats"
	path = /obj/item/clothing/shoes/flatsblu
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/flatspnk
	name = "Pink Flats"
	path = /obj/item/clothing/shoes/flatspnk
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/mjblack
	name = "Black Mary Janes"
	path = /obj/item/clothing/shoes/mjblack
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/mjbrown
	name = "Brown Mary Janes"
	path = /obj/item/clothing/shoes/mjbrown
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/mjnavy
	name = "Navy Mary Janes"
	path = /obj/item/clothing/shoes/mjnavy
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/mjwhite
	name = "White Mary Janes"
	path = /obj/item/clothing/shoes/mjwhite
	slot = SLOT_SHOES
	category = "Shoes"
	cost = PAY_TRADESMAN/5

//Headwear

/datum/clothingbooth_item/catears_white
	name = "White Cat Ears"
	path = /obj/item/clothing/head/nyan/white
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/catears_gray
	name = "Gray Cat Ears"
	path = /obj/item/clothing/head/nyan/gray
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/catears_black
	name = "Black Cat Ears"
	path = /obj/item/clothing/head/nyan/black
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/catears_red
	name = "Red Cat Ears"
	path = /obj/item/clothing/head/nyan/red
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/catears_orange
	name = "Orange Cat Ears"
	path = /obj/item/clothing/head/nyan/orange
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/catears_yellow
	name = "Yellow Cat Ears"
	path = /obj/item/clothing/head/nyan/yellow
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/catears_green
	name = "Green Cat Ears"
	path = /obj/item/clothing/head/nyan/green
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/catears_blue
	name = "Blue Cat Ears"
	path = /obj/item/clothing/head/nyan/blue
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/catears_purple
	name = "Purple Cat Ears"
	path = /obj/item/clothing/head/nyan/purple
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/maid_headwear
	name = "Maid Headwear"
	path = /obj/item/clothing/head/maid
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/tophat
	name = "Top Hat"
	path = /obj/item/clothing/head/that
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/whtophat
	name = "White Top Hat"
	path = /obj/item/clothing/head/that/white
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/blackfedora
	name = "Black Fedora"
	path = /obj/item/clothing/head/fedora
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/brownfedora
	name = "Brown Fedora"
	path = /obj/item/clothing/head/det_hat
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/whitefedora
	name = "White Fedora"
	path = /obj/item/clothing/head/mj_hat
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/bowler
	name = "Bowler Hat"
	path = /obj/item/clothing/head/mime_bowler
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/beret
	name = "Black Beret"
	path = /obj/item/clothing/head/mime_beret
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/cowboy
	name = "Cowboy Hat"
	path = /obj/item/clothing/head/cowboy
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/pokervisor
	name = "Green Visor"
	path = /obj/item/clothing/head/pokervisor
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/antlers
	name = "Antlers"
	path = /obj/item/clothing/head/antlers
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/headsprout
	name = "Leaf Hairclip"
	path = /obj/item/clothing/head/headsprout
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN/2

/datum/clothingbooth_item/ushanka
	name = "Ushanka"
	path = /obj/item/clothing/head/ushanka
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN

/datum/clothingbooth_item/pinwheel_hat
	name = "Pinwheel Hat"
	path = /obj/item/clothing/head/pinwheel_hat
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN

/datum/clothingbooth_item/frog_hat
	name = "Frog Hat"
	path = /obj/item/clothing/head/frog_hat
	slot = SLOT_HEAD
	category = "Headwear"
	cost = PAY_TRADESMAN

//Sci-Fi

/datum/clothingbooth_item/sfjumpsuitbp
	name = "Black and Purple Sci-Fi Jumpsuit"
	path = /obj/item/clothing/under/misc/sfjumpsuitbp
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/sfjumpsuitrb
	name = "Black and Red Sci-Fi Jumpsuit"
	path = /obj/item/clothing/under/misc/sfjumpsuitrb
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/sfjumpsuitpnk
	name = "Pink and Blue Sci-Fi Jumpsuit"
	path = /obj/item/clothing/under/misc/sfjumpsuitpnk
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/sfjumpsuitbee
	name = "Bee Sci-Fi Jumpsuit"
	path = /obj/item/clothing/under/misc/sfjumpsuitbee
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/racingsuitbee
	name = "Bee Racing Jumpsuit"
	path = /obj/item/clothing/under/misc/racingsuitbee
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/racingsuitpnk
	name = "Pink and Blue Racing Jumpsuit"
	path = /obj/item/clothing/under/misc/racingsuitpnk
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/racingsuitrbw
	name = "Blue and White Racing Jumpsuit"
	path = /obj/item/clothing/under/misc/racingsuitrbw
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/racingsuitprp
	name = "Purple and Black Racing Jumpsuit"
	path = /obj/item/clothing/under/misc/racingsuitprp
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/cwhat
	name = "Moebius-Brand Headwear"
	path = /obj/item/clothing/head/cwhat
	slot = SLOT_HEAD
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/fthat
	name = "Trader's Headwear"
	path = /obj/item/clothing/head/fthat
	slot = SLOT_HEAD
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/ftscanplate
	name = "FTX-480 Scanner Plate"
	path = /obj/item/clothing/glasses/ftscanplate
	slot = SLOT_GLASSES
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/cwfashion
	name = "CW Fashionista's Outfit"
	path = /obj/item/clothing/under/gimmick/cwfashion
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/ftuniform
	name = "Free Trader's Outfit"
	path = /obj/item/clothing/under/gimmick/ftuniform
	slot = SLOT_W_UNIFORM
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/handcomp
	name = "Compudyne 0451 Handcomp"
	path = /obj/item/clothing/gloves/handcomp
	slot = SLOT_GLOVES
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/5

/datum/clothingbooth_item/cwboots
	name = "Macando Boots"
	path = /obj/item/clothing/shoes/cwboots
	slot = SLOT_SHOES
	category = "Sci-Fi"
	cost = PAY_DOCTORATE/5

//Summer

/datum/clothingbooth_item/collardressbl
	name = "Black Collar Dress"
	path = /obj/item/clothing/under/collardressbl
	slot = SLOT_W_UNIFORM
	category = "Summer"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/sunhatb
	name = "Blue Sunhat"
	path = /obj/item/clothing/head/sunhat
	slot = SLOT_HEAD
	category = "Summer"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/collardressb
	name = "Blue Collar Dress"
	path = /obj/item/clothing/under/collardressb
	slot = SLOT_W_UNIFORM
	category = "Summer"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/sunhatg
	name = "Green Sunhat"
	path = /obj/item/clothing/head/sunhat/sunhatg
	slot = SLOT_HEAD
	category = "Summer"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/collardressg
	name = "Green Collar Dress"
	path = /obj/item/clothing/under/collardressg
	slot = SLOT_W_UNIFORM
	category = "Summer"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/sunhatr
	name = "Red Sunhat"
	path = /obj/item/clothing/head/sunhat/sunhatr
	slot = SLOT_HEAD
	category = "Summer"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/collardressr
	name = "Red Collar Dress"
	path = /obj/item/clothing/under/collardressr
	slot = SLOT_W_UNIFORM
	category = "Summer"
	cost = PAY_TRADESMAN/3

//Masquerade

/datum/clothingbooth_item/blossommask
	name = "Cherryblossom Mask"
	path = /obj/item/clothing/mask/blossommask
	slot = SLOT_WEAR_MASK
	category = "Masquerade"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/blossomdress
	name = "Cherryblossom Dress"
	path = /obj/item/clothing/under/blossomdress
	slot = SLOT_W_UNIFORM
	category = "Masquerade"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/peacockmask
	name = "Peacock Mask"
	path = /obj/item/clothing/mask/peacockmask
	slot = SLOT_WEAR_MASK
	category = "Masquerade"
	cost = PAY_TRADESMAN/5

/datum/clothingbooth_item/peacockdress
	name = "Peacock Dress"
	path = /obj/item/clothing/under/peacockdress
	slot = SLOT_W_UNIFORM
	category = "Masquerade"
	cost = PAY_DOCTORATE/3

//Costumes

/datum/clothingbooth_item/rando
	name = "Skull Mask and Cloak"
	path = /obj/item/clothing/suit/rando
	slot = SLOT_WEAR_SUIT
	category = "Costumes"
	cost = PAY_TRADESMAN/2
	hidden = 1

/datum/clothingbooth_item/offbrandlabcoat
	name = "Off-Brand Lab Coat"
	path = /obj/item/clothing/suit/labcoatlong
	slot = SLOT_WEAR_SUIT
	category = "Costumes"
	cost = PAY_DOCTORATE/3

/datum/clothingbooth_item/russsianmob
	name = "Russian Mobster Suit"
	path = /obj/item/clothing/under/misc/rusmob
	slot = SLOT_W_UNIFORM
	category = "Costumes"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/columbianmob
	name = "Columbian Mobster Suit"
	path = /obj/item/clothing/under/misc/colmob
	slot = SLOT_W_UNIFORM
	category = "Costumes"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/mobilesuit
	name = "Mobile Robot Suit"
	path = /obj/item/clothing/under/gimmick/mobile_suit
	slot = SLOT_W_UNIFORM
	category = "Costumes"
	cost = PAY_EXECUTIVE

/datum/clothingbooth_item/mobilesuithelmet
	name = "Mobile Robot Helmet"
	path = /obj/item/clothing/head/mobile_suit
	slot = SLOT_HEAD
	category = "Costumes"
	cost = PAY_EXECUTIVE/2

/datum/clothingbooth_item/dinerdress_mint
	name = "Mint Diner Waitress's Dress"
	path = /obj/item/clothing/under/gimmick/dinerdress_mint
	slot = SLOT_W_UNIFORM
	category = "Costumes"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/dinerdress_pink
	name = "Pink Diner Waitress's Dress"
	path = /obj/item/clothing/under/gimmick/dinerdress_pink
	slot = SLOT_W_UNIFORM
	category = "Costumes"
	cost = PAY_TRADESMAN/3

/datum/clothingbooth_item/waitresshat
	name = "Diner Waitress's Hat"
	path = /obj/item/clothing/head/waitresshat
	slot = SLOT_HEAD
	category = "Costumes"
	cost = PAY_TRADESMAN/5
