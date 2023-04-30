/datum/antagonist/grinch
	id = ROLE_GRINCH
	display_name = "grinch"

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

	assign_objectives()
		new /datum/objective_set/grinch(src.owner, src)
