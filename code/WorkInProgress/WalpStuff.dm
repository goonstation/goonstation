// Stuff for my office weehoo

/obj/item/decoration/incenseholder
	name = "stick of incense"
	desc = "A fragrant stick of burning incense. Smells sweet, a little spicy, and comforting."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "incenseholder"

/obj/decoration/regallamp/walp
	name = "gothic lamp"
	desc = "It's a little ominous."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "lamp_walp_unlit"
	density = 0
	anchored = UNANCHORED
	deconstructable = 0
	icon_off = "lamp_walp_unlit"
	icon_on = "lamp_walp_lit"

/obj/decal/poster/cygportrait
	name = "Cyg and Kuiper Glamour Photo"
	desc = "A photo of Cygnus and their cat, Kuiper. They must've gotten this taken at the mall..."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "frame_walp"

/obj/item/decoration/walpfeathers
	name = "mysterious pile of feathers"
	desc = "A shimmering pile of feathers. They look a little like bizarre, white-pupiled eyes."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "eyelikefeathers"
	density = 0
	anchored = ANCHORED

// MISC DECOR

/obj/item/decoration/photoframe
	name = "little photo frame"
	desc = "Someone has left the sample photo of a dog in this frame, how delightful."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "picframe_brown"

	black
		icon_state = "picframe_black"

// CRITTERS

/obj/critter/domestic_bee/walp_bee
	name = "pastel bee"
	desc = "This bee is highly A E S T H E T I C."
	icon_state = "walpbee-wings"
	sleeping_icon_state = "walpbee-sleep"
	icon_body = "walpbee"
	honey_color = "#aa33fe"
	is_pet = 1
	generic = FALSE

/mob/living/critter/small_animal/bee/walp_bee
	name = "pastel bee"
	desc = "This bee is highly A E S T H E T I C."
	icon_state = "walpbee-wings"
	icon_body = "walpbee"
	icon_state_dead = "walpbee-dead"
	icon_state_sleep = "walpbee-sleep"
	honey_color = "#aa33fe"
	add_abilities = list(/datum/targetable/critter/bite/bee,
						 /datum/targetable/critter/bee_sting/hugs,
						 /datum/targetable/critter/bee_teleport)

//I'm stealing this from aloe IM SORRY!!!

/datum/targetable/critter/bee_sting/hugs

	cast(atom/target)
		if (..())
			return TRUE
		src.venom1 = "LSD"
		src.venom2 = "hugs"
		src.amt1 = rand(1, 10)
		src.amt2 = rand(1, 10)

//Placeholder Items

/obj/item/clothing/under/misc/walpoutfit1
/obj/item/clothing/under/misc/walpoutfit2
/obj/item/clothing/head/walphat
/obj/item/clothing/suit/walpcardigan
/obj/item/nature/resin/frankincense
/obj/item/nature/resin/dragonsblood
/obj/item/nature/mushroom
/obj/item/nature/flower/lavender
/obj/item/nature/flower/rose
/obj/item/nature/flower/daisy
/obj/item/nature/crystal
