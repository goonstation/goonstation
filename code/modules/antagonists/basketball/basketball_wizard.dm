/datum/antagonist/basketball_wizard
	id = ROLE_BASKETBALL_WIZARD
	display_name = "basketball wizard"
	uses_pref_name = FALSE

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		var/mob/living/carbon/human/H = src.owner.current
		H.unequip_all(TRUE)
		H.equip_new_if_possible(pick(concrete_typesof(/obj/item/clothing/under/jersey)), SLOT_W_UNIFORM)
		H.equip_new_if_possible(/obj/item/clothing/shoes/white, SLOT_SHOES)
		H.equip_new_if_possible(pick(concrete_typesof(/obj/item/clothing/head/wizard)), SLOT_HEAD)
		H.equip_new_if_possible(/obj/item/bball_uplink, SLOT_R_STORE)
		H.equip_new_if_possible(/obj/item/storage/backpack, SLOT_BACK)
		H.equip_new_if_possible(/obj/item/basketball, SLOT_R_HAND)
		SPAWN(0)
			H.choose_name(what_you_are="Basketball Wizard")

		if("plasmalungs" in H.client?.preferences.traitPreferences.traits_selected)
			H.equip_if_possible(new /obj/item/clothing/mask/breath(H), SLOT_WEAR_MASK)
			H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended/plasma(H), SLOT_L_STORE)
		else
			H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(H), SLOT_L_STORE)

		H.equip_sensory_items()

