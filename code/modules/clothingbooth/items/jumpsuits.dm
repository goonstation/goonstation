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
	name = "Red Pants"
	swatch_background_color = "#8d1422"
	item_path = /obj/item/clothing/under/misc/dirty_vest/

	blackpants
		name = "Black Jeans"
		swatch_background_color = "#323232"
		item_path = /obj/item/clothing/under/misc/dirty_vest/blackpants

	bluepants
		name = "Blue Jeans"
		swatch_background_color = "#0f5b70"
		item_path = /obj/item/clothing/under/misc/dirty_vest/bluepants

	brownpants
		name = "Brown Pants"
		swatch_background_color = "#724f29"
		item_path = /obj/item/clothing/under/misc/dirty_vest/brownpants

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

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/racing)
/datum/clothingbooth_item/w_uniform/racing
	cost = PAY_DOCTORATE/3

	bee
		name = "Bee"
		swatch_background_color = "#fbdf35"
		item_path = /obj/item/clothing/under/misc/racingsuitbee

	pink_and_blue
		name = "Pink and Blue"
		swatch_background_color = "#EE1978"
		item_path = /obj/item/clothing/under/misc/racingsuitpnk

	blue_and_white
		name = "Blue and White"
		swatch_background_color = "#4A72E1"
		item_path = /obj/item/clothing/under/misc/racingsuitrbw

	purple_and_black
		name = "Purple and Black"
		swatch_background_color = "#BF2BF2"
		item_path = /obj/item/clothing/under/misc/racingsuitprp

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

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/blouse_skirt)
/datum/clothingbooth_item/w_uniform/blouse_skirt
	name = "Blouse and Skirt"

	white
		name = "White"
		swatch_background_color = "#ffffff"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/white
	cream
		name = "Cream"
		swatch_background_color = "#fff3dd"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/cream
	khaki
		name = "Khaki"
		swatch_background_color = "#c7b491"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/khaki
	pink
		name = "Pink"
		swatch_background_color = "#f8aaaa"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/pink
	red
		name = "Red"
		swatch_background_color = "#8d1422"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/red
	dark_red
		name = "Dark Red"
		swatch_background_color = "#510f22"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/dark_red
	orange
		name = "Orange"
		swatch_background_color = "#ffc074"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/orange
	brown
		name = "Brown"
		swatch_background_color = "#724f29"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/brown
	yellow
		name = "Yellow"
		swatch_background_color = "#fcf574"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/yellow
	green
		name = "Green"
		swatch_background_color = "#9eee80"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/green
	dark_green
		name = "Dark Green"
		swatch_background_color = "#3fb43f"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/dark_green
	mint
		name = "Mint"
		swatch_background_color = "#86ddc9"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/mint
	blue
		name = "Blue"
		swatch_background_color = "#62a5ee"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/blue
	dark_blue
		name = "Dark Blue"
		swatch_background_color = "#1a378d"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/dark_blue
	purple
		name = "Purple"
		swatch_background_color = "#5a1d8a"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/purple
	black
		name = "Black"
		swatch_background_color = "#1d223c"
		item_path = /obj/item/clothing/under/misc/blouse_skirt/black

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/collar_shirt)
/datum/clothingbooth_item/w_uniform/collar_shirt
	name = "Collar Shirt"

	white
		name = "White"
		swatch_background_color = "#ffffff"
		item_path = /obj/item/clothing/under/misc/collar_shirt/white
	cream
		name = "Cream"
		swatch_background_color = "#fff3dd"
		item_path = /obj/item/clothing/under/misc/collar_shirt/cream
	khaki
		name = "Khaki"
		swatch_background_color = "#c7b491"
		item_path = /obj/item/clothing/under/misc/collar_shirt/khaki
	pink
		name = "Pink"
		swatch_background_color = "#f8aaaa"
		item_path = /obj/item/clothing/under/misc/collar_shirt/pink
	red
		name = "Red"
		swatch_background_color = "#8d1422"
		item_path = /obj/item/clothing/under/misc/collar_shirt/red
	dark_red
		name = "Dark Red"
		swatch_background_color = "#510f22"
		item_path = /obj/item/clothing/under/misc/collar_shirt/dark_red
	orange
		name = "Orange"
		swatch_background_color = "#ffc074"
		item_path = /obj/item/clothing/under/misc/collar_shirt/orange
	brown
		name = "Brown"
		swatch_background_color = "#724f29"
		item_path = /obj/item/clothing/under/misc/collar_shirt/brown
	yellow
		name = "Yellow"
		swatch_background_color = "#fcf574"
		item_path = /obj/item/clothing/under/misc/collar_shirt/yellow
	green
		name = "Green"
		swatch_background_color = "#9eee80"
		item_path = /obj/item/clothing/under/misc/collar_shirt/green
	dark_green
		name = "Dark Green"
		swatch_background_color = "#3fb43f"
		item_path = /obj/item/clothing/under/misc/collar_shirt/dark_green
	mint
		name = "Mint"
		swatch_background_color = "#86ddc9"
		item_path = /obj/item/clothing/under/misc/collar_shirt/mint
	blue
		name = "Blue"
		swatch_background_color = "#62a5ee"
		item_path = /obj/item/clothing/under/misc/collar_shirt/blue
	dark_blue
		name = "Dark Blue"
		swatch_background_color = "#1a378d"
		item_path = /obj/item/clothing/under/misc/collar_shirt/dark_blue
	purple
		name = "Purple"
		swatch_background_color = "#5a1d8a"
		item_path = /obj/item/clothing/under/misc/collar_shirt/purple
	black
		name = "Black"
		swatch_background_color = "#1d223c"
		item_path = /obj/item/clothing/under/misc/collar_shirt/black

ABSTRACT_TYPE(/datum/clothingbooth_item/w_uniform/tea_party_dress)
/datum/clothingbooth_item/w_uniform/tea_party_dress
	name = "Tea Party Dress"

	pink
		name = "Pink"
		swatch_background_color = "#ffbcea"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/pink

	pink_and_black
		name = "Pink and Black"
		swatch_background_color = "#ffbcea"
		swatch_foreground_color = "#000000"
		swatch_foreground_shape = SWATCH_BISECT_RIGHT
		item_path = /obj/item/clothing/under/misc/tea_party_dress/pink_and_black

	black_and_white
		name = "Black and White"
		swatch_background_color = "#000000"
		swatch_foreground_color = "#ffffff"
		swatch_foreground_shape = SWATCH_BISECT_RIGHT
		item_path = /obj/item/clothing/under/misc/tea_party_dress/black_and_white

	black
		name = "Black"
		swatch_background_color = "#000000"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/black

	white
		name = "White"
		swatch_background_color = "#ffffff"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/white

	white_and_black
		name = "White and Black"
		swatch_background_color = "#ffffff"
		swatch_foreground_color = "#000000"
		swatch_foreground_shape = SWATCH_BISECT_RIGHT
		item_path = /obj/item/clothing/under/misc/tea_party_dress/white_and_black

	blue
		name = "Blue"
		swatch_background_color = "#3946b7"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/blue

	dark_blue
		name = "Dark Blue"
		swatch_background_color = "#1c1192"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/dark_blue

	light_blue
		name = "Light Blue"
		swatch_background_color = "#8bdbf2"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/light_blue

	cyan
		name = "Cyan"
		swatch_background_color = "#9edbdb"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/cyan

	green
		name = "Green"
		swatch_background_color = "#61bf71"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/green

	light_green
		name = "Light Green"
		swatch_background_color = "#8be099"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/light_green

	orange
		name = "Orange"
		swatch_background_color = "#ff9042"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/orange

	red
		name = "Red"
		swatch_background_color = "#bf2a1d"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/red

	yellow
		name = "Yellow"
		swatch_background_color = "#ffe156"
		item_path = /obj/item/clothing/under/misc/tea_party_dress/yellow
