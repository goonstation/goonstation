//sportswear not including swimsuits
ABSTRACT_TYPE(/obj/item/clothing/under/athletic)
/obj/item/clothing/under/athletic
    name = "athletic Coder Jumpsuit"
    desc = "This is weird! Report this to a coder!"
    icon = 'icons/obj/clothing/jumpsuits/item_js_athletic.dmi'
    wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_athletic.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_athletic.dmi'

/obj/item/clothing/under/athletic/shorts
	name = "athletic shorts"
	desc = "95% Polyester, 5% Spandex!"
	icon_state = "shortsGy"
	item_state = "shortsGy"

/obj/item/clothing/under/athletic/shorts/red
	icon_state = "shortsR"
	item_state = "shortsR"

/obj/item/clothing/under/athletic/shorts/green
	icon_state = "shortsG"
	item_state = "shortsG"

/obj/item/clothing/under/athletic/shorts/blue
	icon_state = "shortsBl"
	item_state = "shortsBl"

/obj/item/clothing/under/athletic/shorts/purple
	icon_state = "shortsP"
	item_state = "shortsP"

/obj/item/clothing/under/athletic/shorts/black
	icon_state = "shortsB"
	item_state = "shortsB"

/obj/item/clothing/under/athletic/jersey
	name = "white basketball jersey"
	desc = "An all-white jersey. Be careful not to stain it!"
	icon_state = "jerseyW"
	item_state = "jerseyW"

	red
		name = "red basketball jersey"
		desc = "A jersey with the Martian Marauders away colors."
		icon_state = "jerseyR"
		item_state = "jerseyR"

	green
		name = "green basketball jersey"
		desc = "A jersey with the Neo-Boston Drunkards away colors."
		icon_state = "jerseyG"
		item_state = "jerseyG"

	blue
		name = "blue basketball jersey"
		desc = "A jersey with the Mississippi Singularities away colors."
		icon_state = "jerseyBl"
		item_state = "jerseyBl"

	purple
		name = "purple basketball jersey"
		desc = "A jersey with the Mercury Suns away colors."
		icon_state = "jerseyP"
		item_state = "jerseyP"

	black
		name = "black basketball jersey"
		desc = "A jersey banned from professional basketball after the Space Jam 2067 tragedy."
		icon_state = "jerseyB"
		item_state = "jerseyB"

	random
		name = "basketball jersey"
		desc = "A jersey for playing basketball. You can't use it for anything else, only playing basketball. That's how this works."
		New()
			..()
			src.color = random_saturated_hex_color(1)

	dan
		name = "basketball jersey"
		desc = "A jersey worn by Smokin' Sealpups during the last Space Olympics. It seems to be advertising something."
		icon_state = "dan_jersey"
		item_state = "dan_jersey"

TYPEINFO(/obj/item/clothing/under/athletic/shorts/luchador)
	random_subtypes = list(/obj/item/clothing/under/athletic/shorts/luchador,
		/obj/item/clothing/under/athletic/shorts/luchador/red,
		/obj/item/clothing/under/athletic/shorts/luchador/green)
/obj/item/clothing/under/athletic/shorts/luchador
	name = "luchador shorts"
	desc = "Taken from that strange uncle's trophy cabinet."
	icon_state = "lucha1"
	item_state = "lucha1"

/obj/item/clothing/under/athletic/shorts/luchador/green
	icon_state = "lucha2"
	item_state = "lucha2"

/obj/item/clothing/under/athletic/shorts/luchador/red
	icon_state = "lucha3"
	item_state = "lucha3"

/obj/item/clothing/under/athletic/shorts/random_color
	New()
		..()
		src.color = random_saturated_hex_color(1)

/obj/item/clothing/under/athletic/referee
	name = "referee uniform"
	desc = "For when yelling at athletes is your job, not just your hobby."
	icon_state = "referee"
	item_state = "referee"

/obj/item/clothing/under/athletic/eightiesmens
	name = "flashy vest"
	desc = "A confident pair of clothes guaranteed to get you into a stride."
	icon_state = "80smens"

/obj/item/clothing/under/athletic/eightieswomens
	name = "flashy shirt"
	desc = "A confident pair of clothes guaranteed to get you into a stride."
	icon_state = "80swomens"

/obj/item/clothing/under/athletic/adidad
	name = "black tracksuit"
	desc = "The result of outsourcing jumpsuit production to Russian companies."
	icon_state = "adidad"

TYPEINFO(/obj/item/clothing/under/athletic/shirtnjeans)
	mat_appearances_to_ignore = list("jean")
/obj/item/clothing/under/athletic/shirtnjeans
	name = "shirt and jeans"
	desc = "A white shirt and a pair of torn jeans."
	icon_state = "shirtnjeans"
	item_state = "white"
	material_piece = /obj/item/material_piece/cloth/jean
	mat_changename = FALSE
	default_material = "jean"

/obj/item/clothing/under/athletic/dirty_vest  //HoS uniform from the Elite Security era
	name = "dirty vest"
	desc = "This outfit has seen better days."
	icon_state = "vest"
	item_state = "vest"
	c_flags = SLEEVELESS

	blackpants
		icon_state = "vestblack"
		item_state = "vestblack"

	bluepants
		icon_state = "vestblue"
		item_state = "vestblue"

	brownpants
		icon_state = "vestbrown"
		item_state = "vestbrown"
