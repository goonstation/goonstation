/datum/antagonist/wrestler
	id = ROLE_WRESTLER
	display_name = "wrestler"
	success_medal = "Cream of the Crop"
	var/fake = FALSE

	/// The ability holder of this wrestler, containing their respective abilities.
	var/datum/abilityHolder/wrestler/ability_holder

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment(fake_equipment = FALSE)
		src.fake = fake_equipment
		if (ismobcritter(src))
			display_name = "wrestledoodle"
		src.owner.current.add_wrestle_powers(fake_equipment)

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
