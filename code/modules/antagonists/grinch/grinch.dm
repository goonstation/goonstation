/datum/antagonist/grinch
	id = ROLE_GRINCH
	display_name = "grinch"
	antagonist_icon = "grinch"
	success_medal = "You're a mean one..."
	wiki_link = "https://wiki.ss13.co/Grinch"

	/// The ability holder of this grinch, containing their respective abilities.
	var/datum/abilityHolder/grinch/ability_holder

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		var/datum/abilityHolder/grinch/A = src.owner.current.get_ability_holder(/datum/abilityHolder/grinch)
		if (!A)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/grinch)
		else
			src.ability_holder = A

		src.ability_holder.addAbility(/datum/targetable/grinch/vandalism)
		src.ability_holder.addAbility(/datum/targetable/grinch/poison)
		src.ability_holder.addAbility(/datum/targetable/grinch/instakill)
		src.ability_holder.addAbility(/datum/targetable/grinch/grinch_cloak)

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/grinch/vandalism)
		src.ability_holder.removeAbility(/datum/targetable/grinch/poison)
		src.ability_holder.removeAbility(/datum/targetable/grinch/instakill)
		src.ability_holder.removeAbility(/datum/targetable/grinch/grinch_cloak)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/grinch)

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_GRINCH)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_GRINCH)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	assign_objectives()
		new /datum/objective_set/grinch(src.owner, src)
