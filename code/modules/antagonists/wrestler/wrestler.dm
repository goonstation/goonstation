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

		src.ability_holder.is_inherent = TRUE

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

