/datum/antagonist/vampire
	id = ROLE_VAMPIRE
	display_name = "vampire"

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

	assign_objectives()
		new /datum/objective_set/vampire(src.owner, src)

	handle_round_end(log_data)
		var/list/dat = ..()
		if (length(dat) && src.ability_holder)
			dat.Insert(2, {"They drank a total of [src.ability_holder.get_vampire_blood(TRUE)] units of blood during this shift."})

			if (!isvampire(src.owner.current))
				dat.Insert(3, {"Their body was destroyed."})

		return dat
