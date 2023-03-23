/datum/antagonist/subordinate/thrall
	id = ROLE_VAMPTHRALL
	display_name = "vampire thrall"
	remove_on_death = TRUE
	remove_on_clone = TRUE

	/// The ability holder of the master of this vampire thrall, which is to be used alongside `src.master`, due to vampire TEGs.
	var/datum/abilityHolder/vampire/master_ability_holder
	/// The ability holder of this vampire thrall, containing their respective abilities. This is also used for tracking blood, at the moment.
	var/datum/abilityHolder/vampiric_thrall/ability_holder

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		if (istype(master, /datum/abilityHolder/vampire))
			src.master_ability_holder = master

			if (istype(src.master_ability_holder.owner, /mob))
				src.owner = new_owner
				src.owner.master = src.master_ability_holder.owner.ckey

		. = ..()

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current

		if (!istype(H.mutantrace, /datum/mutantrace/vampiric_thrall))
			H.set_mutantrace(/datum/mutantrace/vampiric_thrall)

		var/datum/abilityHolder/vampiric_thrall/A = H.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
		if (!A)
			src.ability_holder = H.add_ability_holder(/datum/abilityHolder/vampiric_thrall)
		else
			src.ability_holder = A

		if (!src.master_ability_holder && src.master)
			src.master_ability_holder = src.master.current.get_ability_holder(/datum/abilityHolder/vampire)

		if (src.master_ability_holder)
			H.AddComponent(/datum/component/tracker_hud/vampthrall, src.master_ability_holder.owner)
			src.ability_holder.master = src.master_ability_holder
			src.master_ability_holder.thralls += H
			src.master_ability_holder.getAbility(/datum/targetable/vampire/enthrall)?.pointCost = 200 + 100 * length(src.master_ability_holder.thralls)

		src.ability_holder.addAbility(/datum/targetable/vampiric_thrall/speak)
		src.ability_holder.addAbility(/datum/targetable/vampire/vampire_bite/thrall)

	remove_equipment()
		var/mob/living/carbon/human/H = src.owner.current

		remove_mindhack_status(H, "vthrall", "death")
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
		if (src.master)
			boutput(src.owner.current, "<span class='alert'><b>You awaken filled with purpose - you must serve your master vampire, [src.master.current.real_name]!</B></span>")
		else if (istype(src.master_ability_holder.owner, /mob))
			boutput(src.owner.current, "<span class='alert'><b>You awaken filled with purpose - you must serve your master vampire, [src.master_ability_holder.owner.real_name]!</B></span>")
		else if (istype(src.master_ability_holder.owner, /obj/machinery/power/generatorTemp))
			boutput(src.owner.current, "<span class='alert'><b>You awaken filled with purpose - you must serve the Bone Generator!</B></span>")
