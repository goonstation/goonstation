/datum/antagonist/vampire
	id = ROLE_VAMPIRE
	display_name = "vampire"
	antagonist_icon = "vampire"
	wiki_link = "https://wiki.ss13.co/Vampire"

	/// The ability holder of this vampire, containing their respective abilities. This is also used for tracking blood, at the moment.
	var/datum/abilityHolder/vampire/ability_holder

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current) || ismobcritter(mind.current)

	give_equipment()
		var/datum/abilityHolder/vampire/A = src.owner.current.get_ability_holder(/datum/abilityHolder/vampire)
		if (!A)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/vampire)
		else
			src.ability_holder = A

		// Initial abilities; all unlockable abilities will be handled by the abilityHolder.
		src.ability_holder.addAbility(/datum/targetable/vampire/vampire_bite)
		src.ability_holder.addAbility(/datum/targetable/vampire/blood_steal)
		src.ability_holder.addAbility(/datum/targetable/vampire/blood_tracking)
		src.ability_holder.addAbility(/datum/targetable/vampire/cancel_stuns)
		src.ability_holder.addAbility(/datum/targetable/vampire/glare)
		src.ability_holder.addAbility(/datum/targetable/vampire/hypnotize)

		src.owner.current.assign_gimmick_skull()

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/vampire/vampire_bite)
		src.ability_holder.removeAbility(/datum/targetable/vampire/blood_steal)
		src.ability_holder.removeAbility(/datum/targetable/vampire/blood_tracking)
		src.ability_holder.removeAbility(/datum/targetable/vampire/cancel_stuns)
		src.ability_holder.removeAbility(/datum/targetable/vampire/glare)
		src.ability_holder.removeAbility(/datum/targetable/vampire/hypnotize)
		src.ability_holder.remove_unlocks()
		src.owner.current.remove_ability_holder(/datum/abilityHolder/vampire)

		SPAWN(2.5 SECONDS)
			src.owner.current.assign_gimmick_skull()

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.ability_holder)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image(), FALSE)
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.ability_holder)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	assign_objectives()
		new /datum/objective_set/vampire(src.owner, src)

	get_statistics()
		return list(
			list(
				"name" = "Blood Drank",
				"value" = "[src.ability_holder.get_vampire_blood(TRUE)] units",
			)
		)
