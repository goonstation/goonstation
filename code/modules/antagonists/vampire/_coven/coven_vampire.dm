/datum/antagonist/coven_vampire
	id = ROLE_COVEN_VAMPIRE
	display_name = "coven vampire"
	antagonist_icon = "vampire"
	wiki_link = "https://wiki.ss13.co/Vampire"

	/// The ability holder of this vampire, containing their respective abilities. This is also used for tracking blood, at the moment.
	var/datum/abilityHolder/vampire/ability_holder = null
	/// The vampire coven datum that this vampire belongs to.
	var/datum/vampire_coven/coven = null

/datum/antagonist/coven_vampire/is_compatible_with(datum/mind/mind)
	return ishuman(mind.current) || ismobcritter(mind.current)

/datum/antagonist/coven_vampire/give_equipment()
	src.coven = global.get_singleton(/datum/vampire_coven)
	src.coven.add_member(src.owner)

	src.ability_holder = src.owner.current.get_ability_holder(/datum/abilityHolder/vampire)
	src.ability_holder ||= src.owner.current.add_ability_holder(/datum/abilityHolder/vampire)

	// Initial abilities; all unlockable abilities will be handled by the abilityHolder.
	src.ability_holder.addAbility(/datum/targetable/vampire/vampire_bite)
	src.ability_holder.addAbility(/datum/targetable/vampire/blood_steal)
	src.ability_holder.addAbility(/datum/targetable/vampire/blood_tracking)
	src.ability_holder.addAbility(/datum/targetable/vampire/cancel_stuns)
	src.ability_holder.addAbility(/datum/targetable/vampire/glare)
	src.ability_holder.addAbility(/datum/targetable/vampire/hypnotize)
	src.ability_holder.addAbility(/datum/targetable/vampire/vamp_cloak)

	// Special nightvision ability.
	src.ability_holder.addAbility(/datum/targetable/vampire/nightvision)

	// Give coven vampires high power abilities early, but prevent future unlocks.
	src.ability_holder.addAbility(/datum/targetable/vampire/phaseshift_vampire)
	src.ability_holder.addAbility(/datum/targetable/vampire/mark_coffin)
	src.ability_holder.addAbility(/datum/targetable/vampire/coffin_escape)
	src.ability_holder.addAbility(/datum/targetable/vampire/call_frost_bats)
	src.ability_holder.addAbility(/datum/targetable/vampire/vampire_scream)

	src.owner.current.assign_gimmick_skull()

/datum/antagonist/coven_vampire/remove_equipment()
	src.coven.remove_member(src.owner)

	src.ability_holder.removeAbility(/datum/targetable/vampire/vampire_bite)
	src.ability_holder.removeAbility(/datum/targetable/vampire/blood_steal)
	src.ability_holder.removeAbility(/datum/targetable/vampire/blood_tracking)
	src.ability_holder.removeAbility(/datum/targetable/vampire/cancel_stuns)
	src.ability_holder.removeAbility(/datum/targetable/vampire/glare)
	src.ability_holder.removeAbility(/datum/targetable/vampire/hypnotize)
	src.ability_holder.removeAbility(/datum/targetable/vampire/vamp_cloak)

	src.ability_holder.removeAbility(/datum/targetable/vampire/nightvision)

	src.ability_holder.removeAbility(/datum/targetable/vampire/phaseshift_vampire)
	src.ability_holder.removeAbility(/datum/targetable/vampire/mark_coffin)
	src.ability_holder.removeAbility(/datum/targetable/vampire/coffin_escape)
	src.ability_holder.removeAbility(/datum/targetable/vampire/call_frost_bats)
	src.ability_holder.removeAbility(/datum/targetable/vampire/vampire_scream)

	src.owner.current.remove_ability_holder(/datum/abilityHolder/vampire)

	SPAWN(2.5 SECONDS)
		src.owner.current.assign_gimmick_skull()

/datum/antagonist/coven_vampire/add_to_image_groups()
	. = ..()
	var/datum/client_image_group/image_group = global.get_image_group(ref(src.coven))
	image_group.add_mind_mob_overlay(src.owner, src.get_antag_icon_image())
	image_group.add_mind(src.owner)

/datum/antagonist/coven_vampire/remove_from_image_groups()
	. = ..()
	var/datum/client_image_group/image_group = global.get_image_group(ref(src.coven))
	image_group.remove_mind_mob_overlay(src.owner)
	image_group.remove_mind(src.owner)

/datum/antagonist/coven_vampire/assign_objectives()
	global.ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/coven_vampire, src)

/datum/antagonist/coven_vampire/get_statistics()
	return list(
		list(
			"name" = "Blood Drank",
			"value" = "[src.ability_holder.get_vampire_blood(TRUE)] units",
		),
		list(
			"name" = "Coven Blood Total",
			"value" = "[src.coven.total_blood] units",
		),
	)


/datum/objective/specialist/coven_vampire
	explanation_text = "Work with your Coven to feast on the blood of the crew!"
