// Stuff you wear on your back
/obj/item/clothing/back
	wear_layer = MOB_BACK_LAYER
	c_flags = ONBACK



/obj/item/clothing/back/hoscape
	name = "Head of Security's cape"
	desc = "A lightly-armored and stylish cape, made of heat-resistant materials. It probably won't keep you warm, but it would make a great security blanket!"
	icon = 'icons/obj/clothing/overcoats/item_suit_armor.dmi' // too lazy to move sprites around rn. will do if we add more back clothes
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'
	icon_state = "hos-cape"
	item_state = "hos-cape"
	body_parts_covered = TORSO|ARMS

	setupProperties()
		..()
		setProperty("meleeprot", 2)
		setProperty("rangedprot", 0.5)
		setProperty("coldprot", 5)
		setProperty("heatprot", 15)
