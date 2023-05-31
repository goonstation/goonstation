/datum/antagonist/floor_goblin
	id = ROLE_FLOOR_GOBLIN
	display_name = "floor goblin"

	/// The ability holder of this floor goblin, containing their respective abilities.
	var/datum/abilityHolder/floor_goblin/ability_holder

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		// Handle tranformation.
		var/mob/living/carbon/human/H = src.owner.current
		H.bioHolder.age = -200
		H.Scale(0.5, 0.5)
		H.real_name = "Floor Goblin"
		H.bioHolder.AddEffect("breathless", 0, 0, 0, 1)
		H.bioHolder.AddEffect("nightvision", 0, 0, 0, 1)
		H.bioHolder.mobAppearance.s_tone = "#00FF1B"
		H.bioHolder.mobAppearance.s_tone_original = "#00FF1B"
		H.bioHolder.mobAppearance.UpdateMob()
		H.update_colorful_parts()

		// Assign floor goblin attire.
		H.unequip_all(TRUE)
		H.equip_new_if_possible(/obj/item/clothing/shoes/sandal/magic/wizard, SLOT_SHOES)
		H.equip_new_if_possible(/obj/item/clothing/under/gimmick/viking, SLOT_W_UNIFORM)
		H.equip_new_if_possible(/obj/item/clothing/head/helmet/viking, SLOT_HEAD)
		H.equip_new_if_possible(/obj/item/storage/backpack/, SLOT_BACK)
		H.equip_new_if_possible(/obj/item/card/id/syndicate, SLOT_WEAR_ID)
		H.equip_new_if_possible(/obj/item/tank/emergency_oxygen/extended, SLOT_R_STORE)
		H.equip_new_if_possible(/obj/item/device/radio/headset/command, SLOT_EARS)
		H.equip_new_if_possible(/obj/item/storage/fanny, SLOT_BELT)
		H.equip_new_if_possible(/obj/item/shoethief_bag, SLOT_IN_BELT)

		// Assign abilities.
		var/datum/abilityHolder/floor_goblin/A = src.owner.current.get_ability_holder(/datum/abilityHolder/floor_goblin)
		if (!A)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/floor_goblin)
		else
			src.ability_holder = A

		src.ability_holder.addAbility(/datum/targetable/steal_shoes)
		src.ability_holder.addAbility(/datum/targetable/hide_between_floors)
		src.ability_holder.addAbility(/datum/targetable/ankle_bite)

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/steal_shoes)
		src.ability_holder.removeAbility(/datum/targetable/hide_between_floors)
		src.ability_holder.removeAbility(/datum/targetable/ankle_bite)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/floor_goblin)
