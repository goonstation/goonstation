//gimme your guts
/obj/item/clothing/suit/space/repo
	name = "leather overcoat"
	desc = "Dark and mysterious..."
	icon_state = "repo"
	item_state = "repo"
	icon = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
	wear_image_icon = 'icons/mob/overcoats/worn_suit_hazard.dmi'
	item_function_flags = IMMUNE_TO_ACID
	contraband = 3
	body_parts_covered = TORSO|LEGS|ARMS
	wear_layer = MOB_OVERLAY_BASE

	setupProperties()
		..()
		setProperty("space_movespeed", 0)
		setProperty("exploprot", 20)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 1.5)
		setProperty("disorient_resist", 65)

/obj/item/clothing/head/helmet/space/repo
	name = "ominous helmet"
	desc = "How is the visor glowing like that?"
	icon_state = "repo"
	item_state = "repo"
	icon = 'icons/obj/clothing/item_hats.dmi'
	wear_image_icon = 'icons/mob/head.dmi'
	item_function_flags = IMMUNE_TO_ACID
	color_r = 0.7
	color_g = 0.7
	color_b = 0.9

	equipped(mob/user)
		. = ..()
		APPLY_MOB_PROPERTY(user, PROP_THERMALVISION_MK2, src)

	unequipped(mob/user)
		REMOVE_MOB_PROPERTY(user, PROP_THERMALVISION_MK2, src)
		. = ..()

/mob/living/carbon/human/repo
	gender = "female"
	New()
		..()

		real_name = "Organ Repossession Agent"

		src.equip_new_if_possible(/obj/item/clothing/under/misc/syndicate, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/suit/space/repo, slot_wear_suit)
		src.equip_new_if_possible(/obj/item/clothing/shoes/swat, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/head/helmet/space/repo, slot_head)
		src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
		src.equip_new_if_possible(/obj/item/clothing/mask/gas/voice, slot_wear_mask)
		src.equip_new_if_possible(/obj/item/card/id/syndicate, slot_wear_id)
		src.equip_new_if_possible(/obj/item/storage/belt/security, slot_belt)
		src.equip_new_if_possible(/obj/item/tank/emergency_oxygen, slot_r_store)

	initializeBioholder()
		. = ..()
		bioHolder.age = 25
		bioHolder.bloodType = "O-"
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/hair/short/floof
		bioHolder.mobAppearance.customization_first_color = "#9b6927"
