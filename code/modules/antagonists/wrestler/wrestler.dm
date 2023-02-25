/datum/antagonist/wrestler
	id = ROLE_WRESTLER
	display_name = "wrestler"
	success_medal = "Cream of the Crop"

	/// The ability holder of this wrestler, containing their respective abilities.
	var/datum/abilityHolder/wrestler/ability_holder

	give_equipment(fake_equipment = FALSE)
		src.owner.current.add_stam_mod_max("wrestler", 50)
		APPLY_ATOM_PROPERTY(src.owner.current, PROP_MOB_STAMINA_REGEN_BONUS, "wrestler", 5)
		src.owner.current.max_health += 50
		health_update_queue |= src.owner.current

		if (ismobcritter(src.owner.current))
			display_name = "wrestledoodle"
			APPLY_ATOM_PROPERTY(src.owner.current, PROP_MOB_PASSIVE_WRESTLE, "wrestledoodle")

		if (fake_equipment)
			var/datum/abilityHolder/wrestler/A = src.owner.current.get_ability_holder(/datum/abilityHolder/wrestler/fake)
			if (A)
				src.ability_holder = A
			else
				src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/wrestler/fake)

			src.ability_holder.addAbility(/datum/targetable/wrestler/kick/fake)
			src.ability_holder.addAbility(/datum/targetable/wrestler/strike/fake)
			src.ability_holder.addAbility(/datum/targetable/wrestler/drop/fake)
			src.ability_holder.addAbility(/datum/targetable/wrestler/throw/fake)
			src.ability_holder.addAbility(/datum/targetable/wrestler/slam/fake)

		else
			var/datum/abilityHolder/wrestler/A = src.owner.current.get_ability_holder(/datum/abilityHolder/wrestler)
			if (A)
				src.ability_holder = A
			else
				src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/wrestler)

			src.ability_holder.addAbility(/datum/targetable/wrestler/kick)
			src.ability_holder.addAbility(/datum/targetable/wrestler/strike)
			src.ability_holder.addAbility(/datum/targetable/wrestler/drop)
			src.ability_holder.addAbility(/datum/targetable/wrestler/throw)
			src.ability_holder.addAbility(/datum/targetable/wrestler/slam)

		// Assign wrestle attire.
		if (ishuman(src.owner.current))
			var/mob/living/carbon/human/H = src.owner.current
			H.unequip_all(TRUE)
			H.equip_new_if_possible(/obj/item/storage/backpack, H.slot_back)
			H.equip_new_if_possible(/obj/item/device/radio/headset/civilian, H.slot_ears)
			H.equip_new_if_possible(/obj/item/tank/emergency_oxygen/extended, H.slot_l_store)
			var/is_luchador = pick(TRUE, FALSE)
			if (is_luchador)
				var/obj/item/clothing/mask/rand_mask = get_random_atom(/obj/item/clothing/mask/wrestling)
				H.equip_new_if_possible(rand_mask, H.slot_wear_mask)
				var/obj/item/clothing/under/shorts/luchador/rand_shorts = get_random_atom(/obj/item/clothing/under/shorts/luchador)
				H.equip_new_if_possible(rand_shorts, H.slot_w_uniform)
			else
				if (prob(50))
					var/obj/item/clothing/under/shorts/rand_shorts = get_random_atom(/obj/item/clothing/under/shorts)
					H.equip_new_if_possible(rand_shorts, H.slot_w_uniform)
				else
					H.equip_new_if_possible(/obj/item/clothing/under/gimmick/macho/random_color, H.slot_w_uniform)
				if (prob(33))
					H.equip_new_if_possible(/obj/item/clothing/head/bandana/random_color, H.slot_head)
			var/shoes_prob = rand(1, 100)
			var/obj/item/clothing/under/shorts/rand_shoes
			if (shoes_prob <= 25)
				rand_shoes = /obj/item/clothing/shoes/macho
			else if (shoes_prob <= 50)
				rand_shoes = /obj/item/clothing/shoes/cowboy
			else if (shoes_prob <= 75)
				rand_shoes = pick(/obj/item/clothing/shoes/bootsblk, /obj/item/clothing/shoes/bootswht, /obj/item/clothing/shoes/bootsblu)
			else
				rand_shoes = /obj/item/clothing/shoes/black
			H.equip_new_if_possible(rand_shoes, H.slot_shoes)
			H.equip_new_if_possible(/obj/item/storage/belt/macho_belt, H.slot_belt)

	remove_equipment()
		src.owner.current.remove_stam_mod_max("wrestler", 50)
		REMOVE_ATOM_PROPERTY(src.owner.current, PROP_MOB_STAMINA_REGEN_BONUS, "wrestler")
		src.owner.current.max_health -= 50
		health_update_queue |= src.owner.current

		if (ismobcritter(src.owner.current))
			REMOVE_ATOM_PROPERTY(src.owner.current, PROP_MOB_PASSIVE_WRESTLE, "wrestledoodle")

		if (istype(src.ability_holder, /datum/abilityHolder/wrestler/fake))
			src.ability_holder.removeAbility(/datum/targetable/wrestler/kick/fake)
			src.ability_holder.removeAbility(/datum/targetable/wrestler/strike/fake)
			src.ability_holder.removeAbility(/datum/targetable/wrestler/drop/fake)
			src.ability_holder.removeAbility(/datum/targetable/wrestler/throw/fake)
			src.ability_holder.removeAbility(/datum/targetable/wrestler/slam/fake)
			src.owner.current.remove_ability_holder(/datum/abilityHolder/wrestler/fake)

		else
			src.ability_holder.removeAbility(/datum/targetable/wrestler/kick)
			src.ability_holder.removeAbility(/datum/targetable/wrestler/strike)
			src.ability_holder.removeAbility(/datum/targetable/wrestler/drop)
			src.ability_holder.removeAbility(/datum/targetable/wrestler/throw)
			src.ability_holder.removeAbility(/datum/targetable/wrestler/slam)
			src.owner.current.remove_ability_holder(/datum/abilityHolder/wrestler)

	assign_objectives()
		var/objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
		new objective_set_path(src.owner, src)

