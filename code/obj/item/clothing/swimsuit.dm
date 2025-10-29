//swimsuits and swimwear

ABSTRACT_TYPE(/obj/item/clothing/under/swimsuit)
/obj/item/clothing/under/swimsuit
	name = "coder swimsuit"
	icon = 'icons/obj/clothing/jumpsuits/item_js_swimsuit.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_swimsuit.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js_swimsuit.dmi'
	desc = "Bought and never used, report this to a coder!"

//Swimsuits, by RubberRats
//Please don't wear a bikini as a work uniform on the RP servers, it would make me very unhappy.

ABSTRACT_TYPE(/obj/item/clothing/under/swimsuit/bikini)
/obj/item/clothing/under/swimsuit/bikini
	name = "bikini"
	icon_state = "bikini_w"
	item_state = "bikini_w"
	desc = "A stylish two-piece swimsuit. Well suited for a day at the beach, less so the cold depths of space."
	hide_underwear = TRUE

	white
		name = "white bikini"
		icon_state = "bikini_w"
		item_state = "bikini_w"

	yellow
		name = "yellow bikini"
		icon_state = "bikini_y"
		item_state = "bikini_y"

	red
		name = "red bikini"
		icon_state = "bikini_r"
		item_state = "bikini_r"

	blue
		name = "blue bikini"
		icon_state = "bikini_u"
		item_state = "bikini_u"

	pink
		name = "pink bikini"
		icon_state = "bikini_p"
		item_state = "bikini_p"

	black
		name = "black bikini"
		icon_state = "bikini_b"
		item_state = "bikini_b"

	pdot_red
		name = "red polka-dot bikini"
		icon_state = "bikini_pdotr"
		item_state = "bikini_pdotr"

	pdot_yellow
		name = "yellow polka-dot bikini"
		icon_state = "bikini_pdoty"
		item_state = "bikini_pdoty"
		desc = "An itsy-bisty, teeny-weeny swimsuit. What's it doing out here in space?"

	strawberry
		name = "strawberry bikini"
		icon_state = "bikini_strawb"
		item_state = "bikini_strawb"

	bee
		name = "beekini"
		icon_state = "beekini"
		item_state = "beekini"
		desc = "A stylish two-piece swimsuit. It even has little wings! Aww."


// Donkini

/obj/item/clothing/under/swimsuit/donkini
	name = "\improper Donkini"
	desc = "A Donk suit that appears to have been gussied and repurposed as a space bikini. Snazzy, but utterly useless for space travel."
	icon_state = "donkini"
	item_state = "donkini"
	hide_underwear = TRUE


//one piece swimsuits

ABSTRACT_TYPE(/obj/item/clothing/under/swimsuit/onepiece)
/obj/item/clothing/under/swimsuit/onepiece
	name = "white one-piece swimsuit"
	icon_state = "onepiece_w"
	item_state = "onepiece_w"
	desc = "A fashionable swimsuit. Well-suited for a day at the beach, less so the cold depths of space."
	hide_underwear = TRUE

	white
		name = "white one-piece swimsuit"
		icon_state = "onepiece_w"
		item_state = "onepiece_w"

	red
		name = "red one-piece swimsuit"
		icon_state = "onepiece_r"
		item_state = "onepiece_r"

	orange
		name = "orange one-piece swimsuit"
		icon_state = "onepiece_o"
		item_state = "onepiece_o"

	yellow
		name = "yellow one-piece swimsuit"
		icon_state = "onepiece_y"
		item_state = "onepiece_y"

	green
		name = "green one-piece swimsuit"
		icon_state = "onepiece_g"
		item_state = "onepiece_g"

	blue
		name = "blue one-piece swimsuit"
		icon_state = "onepiece_u"
		item_state = "onepiece_u"

	purple
		name = "purple one-piece swimsuit"
		icon_state = "onepiece_p"
		item_state = "onepiece_p"

	black
		name = "black one-piece swimsuit"
		icon_state = "onepiece_b"
		item_state = "onepiece_b"


//frilly swimsuits

ABSTRACT_TYPE(/obj/item/clothing/under/swimsuit/frillyswimsuit)
/obj/item/clothing/under/swimsuit/frillyswimsuit
	name = "frilly swimsuit"
	icon_state = "frillyswimsuit_w"
	item_state = "frillyswimsuit_w"
	desc = "A playful swimsuit with a ruffled top. How did it get all the way out here?"
	hide_underwear = TRUE

	white
		name = "frilly white swimsuit"
		icon_state = "frillyswimsuit_w"
		item_state = "frillyswimsuit_w"


	yellow
		name = "frilly yellow swimsuit"
		icon_state = "frillyswimsuit_y"
		item_state = "frillyswimsuit_y"

	blue
		name = "frilly blue swimsuit"
		icon_state = "frillyswimsuit_u"
		item_state = "frillyswimsuit_u"

	pink
		name = "frilly pink swimsuit"
		icon_state = "frillyswimsuit_p"
		item_state = "frillyswimsuit_p"

	bubblegum
		name = "frilly bubblegum swimsuit"
		icon_state = "frillyswimsuit_pu"
		item_state = "frillyswimsuit_pu"

	circus
		name = "frilly circus swimsuit"
		icon_state = "frillyswimsuit_circus"
		item_state = "frillyswimsuit_circus"
		desc = "A playful swimsuit with a ruffled top. This one has an alarming polka-dot pattern."

//swim trunks

ABSTRACT_TYPE(/obj/item/clothing/under/swimsuit/swimtrunks)
/obj/item/clothing/under/swimsuit/swimtrunks
	name = "swim trunks"
	icon_state = "swimtrunks_w"
	item_state = "swimtrunks_w"
	desc = "A pair of swim trunks. Well-suited for a day at the beach, less so the cold depths of space."

	white
		name = "white swim trunks"
		icon_state = "swimtrunks_w"
		item_state = "swimtrunks_w"

	red
		name = "red swim trunks"
		icon_state = "swimtrunks_r"
		item_state = "swimtrunks_r"

	orange
		name = "orange swim trunks"
		icon_state = "swimtrunks_o"
		item_state = "swimtrunks_o"

	green
		name = "green swim trunks"
		icon_state = "swimtrunks_g"
		item_state = "swimtrunks_g"

	blue
		name = "blue swim trunks"
		icon_state = "swimtrunks_u"
		item_state = "swimtrunks_u"

	black
		name = "black swim trunks"
		icon_state = "swimtrunks_b"
		item_state = "swimtrunks_b"

	circus
		name = "circus swim trunks"
		icon_state = "swimtrunks_circus"
		item_state = "swimtrunks_circus"
		desc = "A pair of swim trunks. This one has an alarming polka-dot pattern."


//wetsuits

/obj/item/clothing/under/swimsuit/wetsuit
	name = "wetsuit"
	icon_state = "wetsuit"
	item_state = "wetsuit"
	desc = "A skin-tight, flexible suit meant to keep divers warm underwater. Unfortunately, the material on this one is too thin to provide any real protection."

	red
		name = "red wetsuit"
		icon_state = "wetsuit_r"
		item_state = "wetsuit_r"

	orange
		name = "orange wetsuit"
		icon_state = "wetsuit_o"
		item_state = "wetsuit_o"

	yellow
		name = "yellow wetsuit"
		icon_state = "wetsuit_y"
		item_state = "wetsuit_y"

	purple
		name = "purple wetsuit"
		icon_state = "wetsuit_pu"
		item_state = "wetsuit_pu"

	cyan
		name = "cyan wetsuit"
		icon_state = "wetsuit_u"
		item_state = "wetsuit_u"

	pink
		name = "pink wetsuit"
		icon_state = "wetsuit_p"
		item_state = "wetsuit_p"


//old, as in vintage, swimsuits

ABSTRACT_TYPE(/obj/item/clothing/under/swimsuit/oldswimsuit)
/obj/item/clothing/under/swimsuit/oldswimsuit
	name = "old-timey swimsuit"
	icon_state = "oldswimsuit_rw"
	item_state = "oldswimsuit_rw"
	desc = "A mildly tacky bathing suit in a style nearly 200 years old. Can't fault the classics."

	red
		icon_state = "oldswimsuit_rw"
		item_state = "oldswimsuit_rw"

	blue
		icon_state = "oldswimsuit_uw"
		item_state = "oldswimsuit_uw"

	black
		icon_state = "oldswimsuit_bw"
		item_state = "oldswimsuit_bw"

	bee
		icon_state = "oldswimsuit_by"
		item_state = "oldswimsuit_by"


//swimsuits

/obj/item/clothing/under/swimsuit/swimsuits
	name = "white swimsuit"
	desc = "This piece of clothing is good for when you want to be in the water, but not wearing your normal clothes, but also not naked."
	icon_state = "fswimW"
	item_state = "fswimW"
	hide_underwear = TRUE

	red
		name = "red swimsuit"
		icon_state = "fswimR"
		item_state = "fswimR"

	green
		name = "green swimsuit"
		icon_state = "fswimG"
		item_state = "fswimG"

	blue
		name = "blue swimsuit"
		icon_state = "fswimBl"
		item_state = "fswimBl"

	purple
		name = "purple swimsuit"
		icon_state = "fswimP"
		item_state = "fswimP"

	black
		name = "black swimsuit"
		icon_state = "fswimB"
		item_state = "fswimB"

	random
		name = "swimsuit"
		New()
			..()
			src.color = random_saturated_hex_color(1)
