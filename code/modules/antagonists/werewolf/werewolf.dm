/datum/antagonist/werewolf
	id = ROLE_WEREWOLF
	display_name = "werewolf"

	/// The ability holder of this werewolf, containing their respective abilities.
	var/datum/abilityHolder/werewolf/ability_holder

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/datum/abilityHolder/werewolf/A = src.owner.current.get_ability_holder(/datum/abilityHolder/werewolf)
		if (!A)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/werewolf)
		else
			src.ability_holder = A

		src.ability_holder.addAbility(/datum/targetable/werewolf/werewolf_feast)
		src.ability_holder.addAbility(/datum/targetable/werewolf/werewolf_pounce)
		src.ability_holder.addAbility(/datum/targetable/werewolf/werewolf_thrash)
		src.ability_holder.addAbility(/datum/targetable/werewolf/werewolf_throw)
		src.ability_holder.addAbility(/datum/targetable/werewolf/werewolf_tainted_saliva)
		src.ability_holder.addAbility(/datum/targetable/werewolf/werewolf_defense)
		src.ability_holder.addAbility(/datum/targetable/werewolf/werewolf_transform)
		src.owner.current.resistances += /datum/ailment/disease/lycanthropy

		src.owner.current.assign_gimmick_skull()

	remove_equipment()
		var/mob/living/carbon/human/H = src.owner.current
		if (istype(H.mutantrace, /datum/mutantrace/werewolf))
			H.werewolf_transform()

		src.ability_holder.removeAbility(/datum/targetable/werewolf/werewolf_feast)
		src.ability_holder.removeAbility(/datum/targetable/werewolf/werewolf_pounce)
		src.ability_holder.removeAbility(/datum/targetable/werewolf/werewolf_thrash)
		src.ability_holder.removeAbility(/datum/targetable/werewolf/werewolf_throw)
		src.ability_holder.removeAbility(/datum/targetable/werewolf/werewolf_tainted_saliva)
		src.ability_holder.removeAbility(/datum/targetable/werewolf/werewolf_defense)
		src.ability_holder.removeAbility(/datum/targetable/werewolf/werewolf_transform)
		H.remove_ability_holder(/datum/abilityHolder/werewolf)
		H.resistances -= /datum/ailment/disease/lycanthropy

		SPAWN(2.5 SECONDS)
			H.assign_gimmick_skull()

	assign_objectives()
		new /datum/objective_set/werewolf(src.owner, src)

	handle_round_end(log_data)
		var/list/dat = ..()
		if (length(dat) && src.ability_holder)
			dat.Insert(2, {"They fed on a total of [length(src.ability_holder.feed_objective?.mobs_fed_on)] crew members during this shift."})

			if (!iswerewolf(src.owner.current))
				dat.Insert(3, {"Their body was destroyed."})

		return dat
