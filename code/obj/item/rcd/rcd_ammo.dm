/*
	RCD Ammo types
*/

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for a rapid construction device."
	icon = 'icons/obj/items/rcd.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "ammo"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = UNANCHORED
	m_amt = 30000
	g_amt = 15000
	health = 6
	var/matter = 10

	get_desc()
		. += "<br>It contains [matter] units of ammo."

	attackby(obj/item/W, mob/user, params)
		if(istype(W, /obj/item/rcd) || istype(W, /obj/item/places_pipes))
			W.Attackby(src, user, params)
			return
		. = ..()

/obj/item/rcd_ammo/medium
		name = "medium compressed matter cartridge"
		icon_state = "ammo_big"
		matter = 50

/obj/item/rcd_ammo/big
		name = "large compressed matter cartridge"
		icon_state = "ammo_biggest"
		matter = 100
