/datum/antagonist/subordinate/thrall
	id = ROLE_VAMPTHRALL
	display_name = "vampire thrall"
	remove_on_death = TRUE
	remove_on_clone = TRUE

	/// The ability holder of this vampire, containing their respective abilities. This is also used for tracking blood, at the moment.
	var/datum/abilityHolder/vampiric_thrall/ability_holder

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current

		H.decomp_stage = DECOMP_STAGE_NO_ROT
		H.coreMR = H.mutantrace
		H.set_mutantrace(/datum/mutantrace/vampiric_thrall)
		H.AddComponent(/datum/component/tracker_hud/vampthrall, src.owner)

		var/datum/abilityHolder/vampiric_thrall/A = H.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
		if (!A)
			src.ability_holder = H.add_ability_holder(/datum/abilityHolder/vampiric_thrall)
		else
			src.ability_holder = A

		var/datum/abilityHolder/vampire/master_ability_holder = src.master.current.get_ability_holder(/datum/abilityHolder/vampire)
		if (master_ability_holder)
			src.ability_holder.master = master_ability_holder
			master_ability_holder.thralls += H
			master_ability_holder.getAbility(/datum/targetable/vampire/enthrall)?.pointCost = 200 + 100 * length(master_ability_holder.thralls)

		src.ability_holder.addAbility(/datum/targetable/vampiric_thrall/speak)
		src.ability_holder.addAbility(/datum/targetable/vampire/vampire_bite/thrall)

	remove_equipment()
		var/mob/living/carbon/human/H = src.owner.current

		remove_mindhack_status(H, "vthrall", "death")
		H.set_mutantrace(H.coreMR)
		var/datum/component/C = H.GetComponent(/datum/component/tracker_hud/vampthrall)
		C?.RemoveComponent(/datum/component/tracker_hud/vampthrall)

		if (src.ability_holder.master)
			src.ability_holder.master.thralls -= H
			src.ability_holder.master.getAbility(/datum/targetable/vampire/enthrall)?.pointCost = 200 + 100 * length(src.ability_holder.master.thralls)

		src.ability_holder.removeAbility(/datum/targetable/vampiric_thrall/speak)
		src.ability_holder.removeAbility(/datum/targetable/vampire/vampire_bite/thrall)
		H.remove_ability_holder(/datum/abilityHolder/vampiric_thrall)

	announce()
		. = ..()
		boutput(src.owner.current, "<span class='alert'><b>You awaken filled with purpose - you must serve your master vampire, [src.master.current.real_name]!</B></span>")
