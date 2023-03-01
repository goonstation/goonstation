/datum/antagonist/arcfiend
	id = ROLE_ARCFIEND
	display_name = "arcfiend"

	/// The ability holder of this arcfiend, containing their respective abilities. We also use this for tracking power, at the moment.
	var/datum/abilityHolder/arcfiend/ability_holder

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current) || ismobcritter(mind.current)

	give_equipment()
		var/datum/abilityHolder/arcfiend/A = src.owner.current.get_ability_holder(/datum/abilityHolder/arcfiend)
		if (!A)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/arcfiend)
		else
			src.ability_holder = A
		src.ability_holder.addAbility(/datum/targetable/arcfiend/sap_power)
		src.ability_holder.addAbility(/datum/targetable/arcfiend/discharge)
		src.ability_holder.addAbility(/datum/targetable/arcfiend/elecflash)
		src.ability_holder.addAbility(/datum/targetable/arcfiend/arcFlash)
		src.ability_holder.addAbility(/datum/targetable/arcfiend/polarize)
		src.ability_holder.addAbility(/datum/targetable/arcfiend/voltron)
		src.ability_holder.addAbility(/datum/targetable/arcfiend/jamming_field)
		src.ability_holder.addAbility(/datum/targetable/arcfiend/jolt)

		src.owner.current.bioHolder.AddEffect("resist_electric", power = 2, magical = TRUE)
		src.owner.current.ClearSpecificOverlays("resist_electric")

	remove_equipment()
		// now this is pod racing
		src.ability_holder.removeAbility(/datum/targetable/arcfiend/sap_power)
		src.ability_holder.removeAbility(/datum/targetable/arcfiend/discharge)
		src.ability_holder.removeAbility(/datum/targetable/arcfiend/elecflash)
		src.ability_holder.removeAbility(/datum/targetable/arcfiend/arcFlash)
		src.ability_holder.removeAbility(/datum/targetable/arcfiend/polarize)
		src.ability_holder.removeAbility(/datum/targetable/arcfiend/voltron)
		src.ability_holder.removeAbility(/datum/targetable/arcfiend/jamming_field)
		src.ability_holder.removeAbility(/datum/targetable/arcfiend/jolt)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/arcfiend)

	assign_objectives()
		new /datum/objective_set/arcfiend(src.owner, src)

	handle_round_end(log_data)
		var/list/dat = ..()
		if (length(dat) && src.ability_holder)
			dat.Insert(2, {"They consumed a total of [ability_holder.lifetime_energy] units of energy during this shift.
							<br>Hearts stopped: [ability_holder.hearts_stopped]"})
		if (src.ability_holder.hearts_stopped >= 6)
			src.owner.current.unlock_medal("A shocking demise", TRUE)
		return dat
