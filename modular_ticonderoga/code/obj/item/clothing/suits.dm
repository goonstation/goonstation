/obj/item/clothing/suit/un_coat
	name = "\improper PCN officer's coat"
	desc = "Even if covered in blood and soot, you must look prim and proper in the face of the enemy."
	body_parts_covered = TORSO|ARMS
	bloodoverlayimage = SUITBLOOD_COAT
	modularized = TRUE

	icon = 'modular_ticonderoga/icons/obj/clothing/item_suit.dmi'
	wear_image_icon = 'modular_ticonderoga/icons/mob/clothing/worn_suit.dmi'
	icon_state = "officer_coat"
	item_state = "officer_coat"

/obj/item/clothing/suit/un_coat/setupProperties()
	..()
	setProperty("coldprot", 35)
	setProperty("heatprot", 20)

/obj/item/clothing/suit/un_coat/slt
	name = "\improper PCN Sublieutenant's coat"
	icon_state = "officer_coat"
	item_state = "officer_coat"

/obj/item/clothing/suit/un_coat/lt
	name = "\improper PCN Lieutenant's coat"
	icon_state = "officer_coat-lt"
	item_state = "officer_coat-lt"

/obj/item/clothing/suit/un_coat/lcdr
	name = "\improper PCN Lieutenant Commander's coat"
	icon_state = "officer_coat-lcdr"
	item_state = "officer_coat-lcdr"

/obj/item/clothing/suit/un_coat/lcdr/get_desc(dist, mob/user)
	. = ..()

	var/datum/rank/observer_rank = get_rank(user)
	if (observer_rank?.name == RANK_OFFICER_O4)
		return

	. += "[SPAN_ALERT("<b><i>You</i> definitely aren't supposed to put this on.</b> ")]"

/obj/item/clothing/suit/un_jacket
	name = "\improper PCN deck jacket"
	desc = "A deck jacket issued by the United Nations Peacekeeper Corps Navy. How many owners has this one had?"
	body_parts_covered = TORSO|ARMS
	bloodoverlayimage = SUITBLOOD_COAT
	modularized = TRUE

	icon = 'modular_ticonderoga/icons/obj/clothing/item_suit.dmi'
	wear_image_icon = 'modular_ticonderoga/icons/mob/clothing/worn_suit.dmi'
	icon_state = "deck_jacket"
	item_state = "deck_jacket"
	coat_style = "deck_jacket"

/obj/item/clothing/suit/un_jacket/setupProperties()
	..()
	setProperty("coldprot", 25)
	setProperty("heatprot", 15)

/obj/item/clothing/suit/un_jacket/New()
	..()
	src.AddComponent(/datum/component/toggle_coat, coat_style = "[src.coat_style]", buttoned = TRUE)

/obj/item/clothing/suit/armor/vest/un
	name = "\improper UNPC flak vest"
	desc = "A flak vest in bright United Nations blue. Gaudy!"
	modularized = TRUE

	icon = 'modular_ticonderoga/icons/obj/clothing/item_suit.dmi'
	wear_image_icon = 'modular_ticonderoga/icons/mob/clothing/worn_suit.dmi'

	icon_state = "flak_vest"
	item_state = "flak_vest"

/obj/item/clothing/suit/armor/vest/un/attack_self(mob/user)
	return
