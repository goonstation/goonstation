/datum/antagonist/changeling
	id = ROLE_CHANGELING
	display_name = "changeling"
	antagonist_icon = "changeling"

	/// The ability holder of this changeling, containing their respective abilities. This is also used for tracking absorbtions, at the moment.
	var/datum/abilityHolder/changeling/ability_holder

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		if (!isliving(src.owner.current))
			return FALSE

		var/datum/abilityHolder/changeling/A = src.owner.current.get_ability_holder(/datum/abilityHolder/changeling)
		if (!A)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/changeling)
		else
			src.ability_holder = A

		src.ability_holder.addAbility(/datum/targetable/changeling/abomination)
		src.ability_holder.addAbility(/datum/targetable/changeling/absorb)
		src.ability_holder.addAbility(/datum/targetable/changeling/devour)
		src.ability_holder.addAbility(/datum/targetable/changeling/mimic_voice)
		src.ability_holder.addAbility(/datum/targetable/changeling/monkey)
		src.ability_holder.addAbility(/datum/targetable/changeling/regeneration)
		src.ability_holder.addAbility(/datum/targetable/changeling/scream)
		src.ability_holder.addAbility(/datum/targetable/changeling/spit)
		src.ability_holder.addAbility(/datum/targetable/changeling/stasis)
#ifdef RP_MODE
		src.ability_holder.addAbility(/datum/targetable/changeling/sting/capulettium)
#else
		src.ability_holder.addAbility(/datum/targetable/changeling/sting/neurotoxin)
#endif
		src.ability_holder.addAbility(/datum/targetable/changeling/sting/lsd)
		src.ability_holder.addAbility(/datum/targetable/changeling/sting/dna)
		src.ability_holder.addAbility(/datum/targetable/changeling/transform)
		src.ability_holder.addAbility(/datum/targetable/changeling/morph_arm)
		src.ability_holder.addAbility(/datum/targetable/changeling/critter/handspider)
		src.ability_holder.addAbility(/datum/targetable/changeling/critter/eyespider)
		src.ability_holder.addAbility(/datum/targetable/changeling/critter/legworm)
		src.ability_holder.addAbility(/datum/targetable/changeling/critter/buttcrab)
		src.ability_holder.addAbility(/datum/targetable/changeling/hivesay)
		src.ability_holder.addAbility(/datum/targetable/changeling/boot)
		src.ability_holder.addAbility(/datum/targetable/changeling/give_control)

		if(istype(src.owner.current, /mob/living))
			var/mob/living/L = src.owner.current
			L.blood_id = "bloodc"

		src.owner.current.assign_gimmick_skull()

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/changeling/abomination)
		src.ability_holder.removeAbility(/datum/targetable/changeling/absorb)
		src.ability_holder.removeAbility(/datum/targetable/changeling/devour)
		src.ability_holder.removeAbility(/datum/targetable/changeling/mimic_voice)
		src.ability_holder.removeAbility(/datum/targetable/changeling/monkey)
		src.ability_holder.removeAbility(/datum/targetable/changeling/regeneration)
		src.ability_holder.removeAbility(/datum/targetable/changeling/scream)
		src.ability_holder.removeAbility(/datum/targetable/changeling/spit)
		src.ability_holder.removeAbility(/datum/targetable/changeling/stasis)
#ifdef RP_MODE
		src.ability_holder.removeAbility(/datum/targetable/changeling/sting/capulettium)
#else
		src.ability_holder.removeAbility(/datum/targetable/changeling/sting/neurotoxin)
#endif
		src.ability_holder.removeAbility(/datum/targetable/changeling/sting/lsd)
		src.ability_holder.removeAbility(/datum/targetable/changeling/sting/dna)
		src.ability_holder.removeAbility(/datum/targetable/changeling/dna_target_select)
		src.ability_holder.removeAbility(/datum/targetable/changeling/transform)
		src.ability_holder.removeAbility(/datum/targetable/changeling/morph_arm)
		src.ability_holder.removeAbility(/datum/targetable/changeling/critter/handspider)
		src.ability_holder.removeAbility(/datum/targetable/changeling/critter/eyespider)
		src.ability_holder.removeAbility(/datum/targetable/changeling/critter/legworm)
		src.ability_holder.removeAbility(/datum/targetable/changeling/critter/buttcrab)
		src.ability_holder.removeAbility(/datum/targetable/changeling/hivesay)
		src.ability_holder.removeAbility(/datum/targetable/changeling/boot)
		src.ability_holder.removeAbility(/datum/targetable/changeling/give_control)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/changeling)

		if(istype(src.owner.current, /mob/living))
			var/mob/living/L = src.owner.current
			L.blood_id = initial(L.blood_id)

		SPAWN(2.5 SECONDS)
			src.owner.current.assign_gimmick_skull()

	add_to_image_groups()
		. = ..()
		var/image/image = image('icons/mob/antag_overlays.dmi', icon_state = src.antagonist_icon)
		var/datum/client_image_group/image_group = get_image_group(src.ability_holder)
		image_group.add_mind_mob_overlay(src.owner, image, FALSE)
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.ability_holder)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	assign_objectives()
		new /datum/objective_set/changeling(src.owner, src)

	handle_round_end(log_data)
		var/list/dat = ..()
		if (length(dat) && src.ability_holder)
			dat.Insert(2, {"<b>Absorbed DNA:</b> [max(0, src.ability_holder.absorbtions)]
							<br><b>Absorbed Identities:</b> [english_list(src.ability_holder.absorbed_dna)]"})

			if (!ischangeling(src.owner.current))
				dat.Insert(3, {"Their body was destroyed."})

		return dat
