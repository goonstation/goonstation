/datum/antagonist/wizard
	id = ROLE_WIZARD
	display_name = "wizard"
	antagonist_icon = "wizard"
	success_medal = "You're no Elminster!"
	faction = list(FACTION_WIZARD)
	uses_pref_name = FALSE
	var/list/datum/SWFuplinkspell/purchased_spells = list()

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
		H.RegisterSignal(H, COMSIG_LIVING_LIFE_TICK, /mob/proc/emp_slots)

		// Initial abilities; all unlockable abilities will be handled by the abilityHolder.
		if (!src.vr)
			src.ability_holder.addAbility(/datum/targetable/spell/phaseshift)
			src.ability_holder.addAbility(/datum/targetable/spell/magicmissile)
			src.ability_holder.addAbility(/datum/targetable/spell/clairvoyance)
		else
			src.ability_holder.addAbility(/datum/targetable/spell/magicmissile)

		// Assign wizard hair.
		H.bioHolder.mobAppearance.customizations["hair_bottom"].color = "#FFFFFF"
		H.bioHolder.mobAppearance.customizations["hair_middle"].color = "#FFFFFF"
		H.bioHolder.mobAppearance.customizations["hair_top"].color = "#FFFFFF"
		H.bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/hair/gimmick/wiz
		H.update_colorful_parts()

		// Assign wizard attire.
		H.unequip_all(TRUE)
		H.equip_if_possible(new /obj/item/clothing/under/shorts/black(H), SLOT_W_UNIFORM)
		H.equip_if_possible(new /obj/item/storage/backpack(H), SLOT_BACK)
		H.equip_if_possible(new /obj/item/device/radio/headset/wizard(H), SLOT_EARS)
		H.equip_if_possible(new /obj/item/clothing/suit/wizrobe(H), SLOT_WEAR_SUIT)
		H.equip_if_possible(new /obj/item/clothing/head/wizard(H), SLOT_HEAD)
		H.equip_if_possible(new /obj/item/clothing/shoes/sandal/magic/wizard(H), SLOT_SHOES)
		H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(H), SLOT_L_STORE)
		H.equip_if_possible(new /obj/item/paper/Wizardry101(H), SLOT_R_STORE)
		H.equip_if_possible(new /obj/item/staff(H), SLOT_R_HAND)

		if (!src.vr)
			H.equip_if_possible(new /obj/item/teleportation_scroll(H), SLOT_L_HAND)

		var/obj/item/SWF_uplink/SB = new /obj/item/SWF_uplink(src, src.vr)
		SB.wizard_key = src.owner.key
		H.equip_if_possible(SB, SLOT_BELT)

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
				var/newname = tgui_input_text(H, "You are a Wizard. Would you like to change your name to something else?", "Name change", randomname, max_length = 28)
				if(newname && newname != randomname)
					phrase_log.log_phrase("name-wizard", randomname, no_duplicates = TRUE)

				if (length(ckey(newname)) == 0)
					newname = randomname

				if (newname)
					newname = strip_html(newname)
					H.real_name = newname
					H.on_realname_change()

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

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_WIZARD)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_WIZARD)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	relocate()
		var/mob/M = src.owner.current
		M.set_loc(pick_landmark(LANDMARK_WIZARD))

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/regular/assassinate, src)

		var/objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
		if (ispath(objective_set_path, /datum/objective_set))
			new objective_set_path(src.owner, src)
		else if (ispath(objective_set_path, /datum/objective))
			ticker.mode.bestow_objective(src.owner, objective_set_path, src)

	get_statistics()
	// Add the wizard's chosen spells to the crew credits
		var/list/purchases = list()
		#define SPELL_ANIMATION_FRAME 5 // This will break if ever the wizard spell animations are changed

		for (var/datum/SWFuplinkspell/purchased_spell as anything in src.purchased_spells)
			if (purchased_spell.assoc_spell )
				var/datum/targetable/spell/S = purchased_spell.assoc_spell
				purchases += list(
					list(
						"iconBase64" = "[icon2base64(icon(initial(S.icon), initial(S.icon_state), frame = SPELL_ANIMATION_FRAME, dir = 0))]",
						"name" = "[purchased_spell.name]",
					)
				)
			else // If there's no assoc_spell (i.e. for Soulguard) the icon state is stored in a different spot
				purchases += list(
					list(
						"iconBase64" = "[icon2base64(icon(initial(purchased_spell.icon), initial(purchased_spell.icon_state), frame = 1, dir = 0))]",
						"name" = "[purchased_spell.name]"
					)
				)
		#undef SPELL_ANIMATION_FRAME

		. = list(
			list(
				"name" = "Spells",
				"type" = "itemList",
				"value" = purchases,
			)
		)
