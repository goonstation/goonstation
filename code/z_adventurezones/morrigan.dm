// Morrigan Azone Objects
// ID Cards
/obj/item/card/id/morrigan

/obj/item/card/id/morrigan/botany
	name = "Moldy Botanist ID"
	icon_state = "id_civ"
	desc = "Ew..."
	access = list(access_morrigan_botany)

/obj/item/card/id/morrigan/inspector
	name = "Old Inspector's Card"
	icon_state = "data"
	desc = "Looks like and old proto-type ID card!"
	access = list(access_morrigan_teleporter)

/obj/item/card/id/morrigan/engineer
	name = "Richard S. Batherl (Engineer)"
	icon_state = "id_eng"
	desc = "This should let you get into engineering..."
	access = list(access_morrigan_engineering)

/obj/item/card/id/morrigan/ce
	name = "Misplaced CE Card"
	icon_state = "id_com"
	desc = "Name and picture are scratched off. It's in pretty poor shape"
	access = list(access_morrigan_CE, access_morrigan_engineering)

/obj/item/card/id/morrigan/medical
	name = "Harther Monoshoe (EMT)"
	icon_state = "id_res"
	desc = "A card for medbay!"
	access = list(access_morrigan_medical)

/obj/item/card/id/morrigan/mdir
	name = "Barara J. June (Medical Director)"
	icon_state = "id_com"
	desc = "An important ID card belonging to a medical director"
	access = list(access_morrigan_medical, access_morrigan_mdir, access_morrigan_bridge)

/obj/item/card/id/morrigan/science
	name = "Troy Wentworth (Scientist)"
	icon_state = "id_res"
	desc = "An ID card of a scientist."
	access = list(access_morrigan_science)

/obj/item/card/id/morrigan/rd
	name = "Partially melted Research Director ID"
	icon_state = "id_pink"
	desc = "This card looks badly damaged, does it still work ?"
	access = list(access_morrigan_science, access_morrigan_RD)

/obj/item/card/id/morrigan/janitor
	name = "Yi Wong (Janitor)"
	icon_state = "id_civ"
	desc = "It's sparkling clean."
	access = list(access_morrigan_janitor)

/obj/item/card/id/morrigan/security
	name = "Harrier S. Jentlil (Patrol Officer)"
	icon_state = "id_sec"
	desc = "Wow, a still intact security ID ! This could come in handy..."
	access = list(access_morrigan_security)

/obj/item/card/id/morrigan/hos
	name = "Alexander Nash (Elite Head of Security)"
	icon_state = "id_syndie"
	desc = "Jackpot!"
	access = list(access_morrigan_bridge, access_morrigan_security, access_morrigan_HOS)

/obj/item/card/id/morrigan/customs
	name = "William B. Ron"
	icon_state = "id_com"
	desc = "Hop ID but it seems to be lacking something..."
	access = list(access_morrigan_customs, access_morrigan_bridge)

/obj/item/card/id/morrigan/captain
	name = "Captain's Spare ID"
	icon_state = "id_syndie"
	desc = "This is your key to get out of here..."

	New()
		..()
		access = morrigan_access() - list(access_morrigan_exit)

/obj/item/card/id/morrigan/all_access
	name = "Spare HQ Card"
	icon_state = "id_syndie"
	desc = "Someone must've been in a rush and left this behind..."

	New()
		..()
		access = morrigan_access()

/proc/morrigan_access()
	return list(access_morrigan_bridge, access_morrigan_medical, access_morrigan_CE, access_morrigan_captain, access_morrigan_RD, access_morrigan_engineering,
	access_morrigan_factory, access_morrigan_HOS, access_morrigan_meetingroom, access_morrigan_customs, access_morrigan_exit, access_morrigan_science,
	access_morrigan_mdir, access_morrigan_security, access_morrigan_janitor)

//fake objects

/obj/decal/fakeobjects/pod
	name = "Pod"
	icon = 'icons/effects/64x64.dmi'
	bound_width = 64
	bound_height = 64

/obj/decal/fakeobjects/pod/syndicate/racepod
	name = "Syndicate Security Pod"
	desc = "A Syndicate-crafted light pod, seems locked."
	icon_state = "pod_raceRed"

/obj/decal/fakeobjects/pod/nanotrasen/racepod
	name = "Nanotrasen Light Pod"
	desc = "A Nanotrasen light Pod! It seems locked.. "
	icon_state = "pod_raceBlue"

/obj/decal/fakeobjects/pod/black
	name = "Black Pod"
	desc = "A black pod, seems locked."
	icon_state = "pod_black"

/obj/decal/fakeobjects/miniputt
	name = "Miniputt"
	icon = 'icons/obj/ship.dmi'

/obj/decal/fakeobjects/miniputt/syndicate/raceputt
	name = "Syndicate Security MiniPutt"
	desc = "A Syndicate-crafted light miniputt, seems locked."
	icon_state = "putt_raceRed_alt"

/obj/decal/fakeobjects/miniputt/nanotrasen/raceputt
	name = "Nanotrasen Light MiniPutt"
	desc = "A Nanotrasen light miniputt! It seems locked.."
	icon_state = "putt_raceBlue"

/obj/decal/fakeobjects/miniputt/black
	name = "Black Miniputt"
	desc = "A black miniputt, seems locked."
	icon_state = "putt_black"

//NPCS for Morrigan

/mob/living/carbon/human/hobo
	New()
		..()
		src.equip_new_if_possible(pick(/obj/item/clothing/head/apprentice, /obj/item/clothing/head/beret/random_color, /obj/item/clothing/head/black, /obj/item/clothing/head/chav,
		/obj/item/clothing/head/fish_fear_me/emagged, /obj/item/clothing/head/flatcap, /obj/item/clothing/head/party/random, /obj/item/clothing/head/plunger,
		/obj/item/clothing/head/towel_hat, /obj/item/clothing/head/wizard/green, /obj/item/clothing/head/snake, /obj/item/clothing/head/raccoon,
		/obj/item/clothing/head/bandana/random_color), SLOT_HEAD)
		src.equip_new_if_possible(pick(/obj/item/clothing/under/gimmick/yay, /obj/item/clothing/under/misc/casualjeansgrey, /obj/item/clothing/under/misc/dirty_vest,
		/obj/item/clothing/under/misc/yoga/communist, /obj/item/clothing/under/patient_gown, /obj/item/clothing/under/shorts/random_color,
		/obj/item/clothing/under/shorts/trashsinglet, /obj/item/clothing/under/misc/flannel), SLOT_W_UNIFORM)
		src.equip_new_if_possible(pick(/obj/item/clothing/suit/walpcardigan, /obj/item/clothing/suit/gimmick/hotdog, /obj/item/clothing/suit/loosejacket,
		/obj/item/clothing/suit/torncloak/random, /obj/item/clothing/suit/gimmick/guncoat/dirty, /obj/item/clothing/suit/bathrobe, /obj/item/clothing/suit/apron,
		/obj/item/clothing/suit/apron/botanist, /obj/item/clothing/suit/bedsheet/random), SLOT_WEAR_SUIT)
		src.equip_new_if_possible((/obj/item/clothing/shoes/tourist), SLOT_SHOES)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(2) && !src.stat)
			src.emote("scream")

	initializeBioholder()
		. = ..()
		randomize_look(src, FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, src)
		bioHolder.mobAppearance.gender = "male"
		bioHolder.age = rand(50, 90)
		bioHolder.mobAppearance.customization_first_color = pick("#292929", "#504e00" , "#1a1016")
		bioHolder.mobAppearance.customization_second_color = pick("#292929", "#504e00" , "#1a1016")
		var/beard = pick(/datum/customization_style/hair/gimmick/shitty_beard, /datum/customization_style/hair/gimmick.wiz, /datum/customization_style/beard/braided,
		/datum/customization_style/beard/abe, /datum/customization_style/beard/fullbeard, /datum/customization_style/beard/longbeard, /datum/customization_style/beard/trampstains)
		bioHolder.mobAppearance.customization_second = new beard

/mob/living/carbon/human/hobo/vladimir
	real_name = "Vladimir Dostoevsky"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(10) && !src.stat)
			src.say(pick( "I neeeda zzrink...", "Fugh...", "Where me am...", "I pischd on duh floor...","Why duh bluee ann sen how..."))

/mob/living/carbon/human/hobo/laraman
	real_name = "The Lara Man"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.stat)
			return

		src.setStatusMin("weakened", 10 SECONDS)
		if (prob(10))
			src.say(pick( "Don't look for Lara...", "Lara??", "Lara the oven!", "Please don't talk to Lara", "LAAAAARRRAAAAAAAA!!!" ,"L-Lara."))
