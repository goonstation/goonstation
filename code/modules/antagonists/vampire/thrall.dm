/datum/antagonist/subordinate/thrall
	id = ROLE_VAMPTHRALL
	display_name = "vampire thrall"
	antagonist_icon = "vampthrall"
	remove_on_death = TRUE
	remove_on_clone = TRUE
	wiki_link = "https://wiki.ss13.co/Vampire#Thralls"

	/// The ability holder of the master of this vampire thrall, which is to be used alongside `src.master`, due to vampire TEGs.
	var/datum/abilityHolder/vampire/master_ability_holder
	/// The ability holder of this vampire thrall, containing their respective abilities. This is also used for tracking blood, at the moment.
	var/datum/abilityHolder/vampiric_thrall/ability_holder

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		if (istype(master, /datum/abilityHolder/vampire))
			src.master_ability_holder = master

			if (istype(src.master_ability_holder.owner, /mob) && src.master_ability_holder.owner.mind)
				src.master = src.master_ability_holder.owner.mind
				src.master.subordinate_antagonists += src

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

		src.ability_holder.addAbility(/datum/targetable/vampiric_thrall/speak)
		src.ability_holder.addAbility(/datum/targetable/vampire/vampire_bite/thrall)

	remove_equipment()
		var/mob/living/carbon/human/H = src.owner.current
		var/datum/component/C = H.GetComponent(/datum/component/tracker_hud/vampthrall)
		C?.RemoveComponent(/datum/component/tracker_hud/vampthrall)

		if (src.ability_holder.master)
			src.ability_holder.master.thralls -= H

		src.ability_holder.removeAbility(/datum/targetable/vampiric_thrall/speak)
		src.ability_holder.removeAbility(/datum/targetable/vampire/vampire_bite/thrall)
		H.remove_ability_holder(/datum/abilityHolder/vampiric_thrall)

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.master_ability_holder)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.master_ability_holder)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	announce()
		. = ..()
		if (src.master)
			boutput(src.owner.current, SPAN_ALERT("<b>You awaken filled with purpose - you must serve your master vampire, [src.master.current.real_name]!</b>"))
		else if (istype(src.master_ability_holder.owner, /mob))
			boutput(src.owner.current, SPAN_ALERT("<b>You awaken filled with purpose - you must serve your master vampire, [src.master_ability_holder.owner.real_name]!</b>"))
		else if (istype(src.master_ability_holder.owner, /obj/machinery/power/generatorTemp))
			boutput(src.owner.current, SPAN_ALERT("<b>You awaken filled with purpose - you must serve the Bone Generator!</b>"))

	announce_removal(source)
		. = ..()

		switch (source)
			if (ANTAGONIST_REMOVAL_SOURCE_DEATH)
				src.owner.current.show_antag_popup("mindhackdeath")
				boutput(src.owner.current, SPAN_ALERT("<b>As you have died, you are no longer subservient to [src.master.current.real_name]! Do not obey your former master's orders even if you've been brought back to life somehow.</b>"))
				logTheThing(LOG_COMBAT, src.owner.current, "(enthralled by [src.master.current ? "[constructTarget(src.master.current, "combat")]" : "*NOKEYFOUND*"]) has died, removing vampire thrall status.")

			else
				src.owner.current.show_antag_popup("mindhackexpired")
				boutput(src.owner.current, SPAN_ALERT("<b>Your mind is your own again! You no longer feel the need to obey your former master's orders.</b>"))
				logTheThing(LOG_COMBAT, src.owner.current, "(enthralled by [src.master.current ? "[constructTarget(src.master.current, "combat")]" : "*NOKEYFOUND*"]) has been freed mysteriously, removing vampire thrall status.")
