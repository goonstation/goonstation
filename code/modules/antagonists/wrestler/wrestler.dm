/datum/antagonist/wrestler
	id = ROLE_WRESTLER
	display_name = "wrestler"
	antagonist_icon = "wrestler"
	success_medal = "Cream of the Crop"
	var/fake = FALSE

	/// The ability holder of this wrestler, containing their respective abilities.
	var/datum/abilityHolder/wrestler/ability_holder

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment(fake_equipment = FALSE)
		src.fake = fake_equipment
		src.owner.current.add_wrestle_powers(fake_equipment)
		if (ismobcritter(src))
			display_name = "wrestledoodle"
			return

		// Assign wrestle attire.
		if (ishuman(src.owner.current))
			var/mob/living/carbon/human/H = src.owner.current
			H.unequip_all(TRUE)
			H.equip_new_if_possible(/obj/item/storage/backpack, H.slot_back)
			H.equip_new_if_possible(/obj/item/device/radio/headset/civilian, H.slot_ears)
			H.equip_new_if_possible(/obj/item/tank/emergency_oxygen/extended, H.slot_l_store)
			if (prob(50)) // Are they a luchador or not?
				var/obj/item/clothing/mask/rand_mask = get_random_subtype (/obj/item/clothing/mask/wrestling)
				H.equip_new_if_possible(rand_mask, H.slot_wear_mask)
				var/obj/item/clothing/under/shorts/luchador/rand_shorts = get_random_subtype (/obj/item/clothing/under/shorts/luchador)
				H.equip_new_if_possible(rand_shorts, H.slot_w_uniform)
			else
				if (prob(50))
					var/obj/item/clothing/under/shorts/rand_shorts = get_random_subtype (/obj/item/clothing/under/shorts)
					H.equip_new_if_possible(rand_shorts, H.slot_w_uniform)
				else
					H.equip_new_if_possible(/obj/item/clothing/under/gimmick/macho/random_color, H.slot_w_uniform)
				if (prob(33))
					H.equip_new_if_possible(/obj/item/clothing/head/bandana/random_color, H.slot_head)
			var/obj/item/clothing/under/shorts/rand_shoes
			switch(pick(1, 2, 3, 4))
				if(1)
					rand_shoes = /obj/item/clothing/shoes/macho
				if(2)
					rand_shoes = /obj/item/clothing/shoes/cowboy
				if(3)
					rand_shoes = pick(/obj/item/clothing/shoes/bootsblk, /obj/item/clothing/shoes/bootswht, /obj/item/clothing/shoes/bootsblu)
				if(4)
					rand_shoes = /obj/item/clothing/shoes/black
			H.equip_new_if_possible(rand_shoes, H.slot_shoes)
			H.equip_new_if_possible(/obj/item/storage/belt/macho_belt, H.slot_belt)

	remove_equipment()
		src.owner.current.remove_wrestle_powers(src.fake)

	assign_objectives()
		var/objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
		new objective_set_path(src.owner, src)

/mob/proc/add_wrestle_powers(fake = FALSE)
	src.add_stam_mod_max("wrestler", 50)
	APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "wrestler", 5)
	src.max_health += 50
	health_update_queue |= src

	if (ismobcritter(src))
		APPLY_ATOM_PROPERTY(src, PROP_MOB_PASSIVE_WRESTLE, "wrestledoodle")

	if (fake)
		var/datum/abilityHolder/wrestler/A = src.get_ability_holder(/datum/abilityHolder/wrestler/fake)
		if (!A)
			A = src.add_ability_holder(/datum/abilityHolder/wrestler/fake)

		A.addAbility(/datum/targetable/wrestler/kick/fake)
		A.addAbility(/datum/targetable/wrestler/strike/fake)
		A.addAbility(/datum/targetable/wrestler/drop/fake)
		A.addAbility(/datum/targetable/wrestler/throw/fake)
		A.addAbility(/datum/targetable/wrestler/slam/fake)

	else
		var/datum/abilityHolder/wrestler/A = src.get_ability_holder(/datum/abilityHolder/wrestler)
		if (!A)
			A = src.add_ability_holder(/datum/abilityHolder/wrestler)

		A.addAbility(/datum/targetable/wrestler/kick)
		A.addAbility(/datum/targetable/wrestler/strike)
		A.addAbility(/datum/targetable/wrestler/drop)
		A.addAbility(/datum/targetable/wrestler/throw)
		A.addAbility(/datum/targetable/wrestler/slam)

/mob/proc/remove_wrestle_powers(fake = FALSE)
	src.remove_stam_mod_max("wrestler", 50)
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "wrestler")
	src.max_health -= 50
	health_update_queue |= src

	if (ismobcritter(src))
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_PASSIVE_WRESTLE, "wrestledoodle")

	if (fake)
		src.removeAbility(/datum/targetable/wrestler/kick/fake)
		src.removeAbility(/datum/targetable/wrestler/strike/fake)
		src.removeAbility(/datum/targetable/wrestler/drop/fake)
		src.removeAbility(/datum/targetable/wrestler/throw/fake)
		src.removeAbility(/datum/targetable/wrestler/slam/fake)
		src.remove_ability_holder(/datum/abilityHolder/wrestler/fake)

	else
		src.removeAbility(/datum/targetable/wrestler/kick)
		src.removeAbility(/datum/targetable/wrestler/strike)
		src.removeAbility(/datum/targetable/wrestler/drop)
		src.removeAbility(/datum/targetable/wrestler/throw)
		src.removeAbility(/datum/targetable/wrestler/slam)
		src.remove_ability_holder(/datum/abilityHolder/wrestler)
