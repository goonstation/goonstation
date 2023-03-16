/datum/antagonist/wizard
	id = ROLE_WIZARD
	display_name = "wizard"
	success_medal = "You're no Elminster!"

	/// The ability holder of this wizard, containing their respective abilities.
	var/datum/abilityHolder/wizard/ability_holder

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/H = src.owner.current
		var/datum/abilityHolder/wizard/A = H.get_ability_holder(/datum/abilityHolder/wizard)
		if (!A)
			src.ability_holder = H.add_ability_holder(/datum/abilityHolder/wizard)
		else
			src.ability_holder = A

		H.RegisterSignal(H, COMSIG_MOB_PICKUP, /mob/proc/emp_touchy)
		H.RegisterSignal(H, COMSIG_LIVING_LIFE_TICK, /mob/proc/emp_hands)

		// Initial abilities; all unlockable abilities will be handled by the abilityHolder.
		if (!src.vr)
			src.ability_holder.addAbility(/datum/targetable/spell/phaseshift)
			src.ability_holder.addAbility(/datum/targetable/spell/magicmissile)
			src.ability_holder.addAbility(/datum/targetable/spell/clairvoyance)
		else
			src.ability_holder.addAbility(/datum/targetable/spell/magicmissile)

		// Assign wizard hair.
		H.bioHolder.mobAppearance.customization_first_color = "#FFFFFF"
		H.bioHolder.mobAppearance.customization_second_color = "#FFFFFF"
		H.bioHolder.mobAppearance.customization_third_color = "#FFFFFF"
		H.bioHolder.mobAppearance.customization_second = new /datum/customization_style/hair/gimmick/wiz
		H.update_colorful_parts()

		// Assign wizard attire.
		H.unequip_all(TRUE)
		H.equip_if_possible(new /obj/item/clothing/under/shorts/black(H), H.slot_w_uniform)
		H.equip_if_possible(new /obj/item/storage/backpack(H), H.slot_back)
		H.equip_if_possible(new /obj/item/device/radio/headset/wizard(H), H.slot_ears)
		H.equip_if_possible(new /obj/item/clothing/suit/wizrobe(H), H.slot_wear_suit)
		H.equip_if_possible(new /obj/item/clothing/head/wizard(H), H.slot_head)
		H.equip_if_possible(new /obj/item/clothing/shoes/sandal/wizard(H), H.slot_shoes)
		H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(H), H.slot_l_store)
		H.equip_if_possible(new /obj/item/paper/Wizardry101(H), H.slot_r_store)
		H.equip_if_possible(new /obj/item/staff(H), H.slot_r_hand)

		if (!src.vr)
			H.equip_if_possible(new /obj/item/teleportation_scroll(H), H.slot_l_hand)

		var/obj/item/SWF_uplink/SB = new /obj/item/SWF_uplink(src.vr)
		SB.wizard_key = src.owner.key
		H.equip_if_possible(SB, H.slot_belt)

		H.equip_sensory_items()

		H.assign_gimmick_skull()

		// Permit the wizard to change their name upon spawning.
		var/randomname
		if (H.gender == "female")
			randomname = pick_string_autokey("names/wizard_female.txt")
		else
			randomname = pick_string_autokey("names/wizard_male.txt")

		if (!src.vr && !src.pseudo)
			SPAWN(0)
				var/newname = tgui_input_text(H, "You are a Wizard. Would you like to change your name to something else?", "Name change", randomname)
				if(newname && newname != randomname)
					phrase_log.log_phrase("name-wizard", randomname, no_duplicates = TRUE)

				if (length(ckey(newname)) == 0)
					newname = randomname

				if (newname)
					if (length(newname) >= 26) newname = copytext(newname, 1, 26)
					newname = strip_html(newname)
					H.real_name = newname
					H.UpdateName()

	remove_equipment()
		src.owner.current.UnregisterSignal(src.owner.current, COMSIG_MOB_PICKUP)
		src.owner.current.UnregisterSignal(src.owner.current, COMSIG_LIVING_LIFE_TICK)

		src.ability_holder.removeAbility(/datum/targetable/spell/phaseshift)
		src.ability_holder.removeAbility(/datum/targetable/spell/magicmissile)
		src.ability_holder.removeAbility(/datum/targetable/spell/clairvoyance)
		for (var/datum/targetable/ability in src.ability_holder.abilities)
			src.ability_holder.removeAbility(ability.type)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/wizard)

		SPAWN(2.5 SECONDS)
			src.owner.current.assign_gimmick_skull()

	relocate()
		if (!job_start_locations["wizard"])
			boutput(src.owner.current, "<B><span class='alert'>A starting location for you could not be found, please report this bug!</span></B>")
		else
			src.owner.current.set_loc(pick(job_start_locations["wizard"]))

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/regular/assassinate, src)

		var/objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
		if (ispath(objective_set_path, /datum/objective_set))
			new objective_set_path(src.owner, src)
		else if (ispath(objective_set_path, /datum/objective))
			ticker.mode.bestow_objective(src.owner, objective_set_path, src)
