/*
* mutantrace refactor current goals:
* rename mutantrace to be more descriptive of what it does
* make it so that the default mutantrace for humans is a "human" mutantrace
* since humans now have a mutantrace, take this opportunity to clean up human appearance building by moving all human appearance building instructions to an appearanceholder held in the mutantrace
* take this opportunity to investigate how to make appearance building easier to maintain (documenting code, rewriting segments to be less jank?? idk)
* potential complication: human has a bioholder which holds mutantrace and appearanceholder. this is like a deeply ingrained code hierarchy so messing with it may cause issues.
*/

ABSTRACT_TYPE(/datum/human_extension)
TYPEINFO(/datum/human_extension)
	// special styles which currently change the icon (sprite sheet)
	var/list/special_styles

/**
 * Human Extension Datum
 * This datum has several hooks to existing human procedures and allows you to override/extend existing human behaviour.
 * This datum also holds a reference to an appearanceHolder, which provides mob appearance rendering information.
 */
/datum/human_extension
	/// used for identification in diseases, clothing, etc
	var/name = ""
	/// the mutation associted with the human_extension
	var/human_extension_mutation = null
	/// appearanceHolder datum that stores all information related to building the appearance of the mob
	var/datum/appearanceHolder/appearance_holder = null
	/// previous appearanceHolder datum from a previous human_extension
	var/datum/appearanceHolder/prev_appearance_holder = null
	/// language id that the human_extension speaks
	var/language = ""
	/// a list of language ids that the human_extension can understand
	var/list/understood_languages = list()
	/// allows dna injectors and human diseases to affect the human_extension
	var/human_compatible = FALSE
	/// if FALSE, can only wear clothes if listed in [/obj/item/clothing/var/compatible_species]
	var/uses_human_clothes = FALSE
	/// if TRUE, only understood by others mobs with the same human_extension
	var/exclusive_language = FALSE
	/// overrides normal voice message if defined (and others don't understand us, ofc)
	var/voice_message = ""
	/// overrides normal name message if defined (and others don't understand us, ofc)
	var/voice_name = ""
	/// true if robots should arrest this human_extension by default
	var/jerk = FALSE
	/// true if should stable mutagen not copy to/from this human_extension
	var/dna_mutagen_banned = FALSE
	/// true if a genetics terminal can remove this human_extension
	var/genetics_removable = FALSE
	/// true if this human_extension can walk barefoot on glass shards
	var/can_walk_on_shards = FALSE
	/**
	 * Swaps out the entries in the mob's organ_holder with these (hopefully) organs
	 * assoc list with format: ("entry_in_organholder's_organlist" = /obj/item/organ/path)
	 */
	var/list/nonhuman_organs = list()
	/// if true, override the limb attack actions via custom_attack()
	var/override_attack = FALSE
	/**
	 * List of 0 to 3 strings representing the names for the color channels
	 * used in the character creator. For vanilla humans (or HAS_HUMAN_HAIR)
	 *  this is list("Bottom Detail", "Mid Detail", "Top Detail").
	 */
	var/list/color_channel_names = list()

	/// output to chat when clicking self on help intent
	var/self_click_fluff = ""


// start fuck this (cant be bothered to document or rename these)
	var/list/limb_list = list()
	var/r_limb_arm_type_mutantrace = null // Should we get custom arms? Dispose() replaces them with normal human arms.
	var/l_limb_arm_type_mutantrace = null
	var/r_limb_leg_type_mutantrace = null
	var/l_limb_leg_type_mutantrace = null

	var/r_limb_arm_type_mutantrace_f = null // Should we get custom arms? Dispose() replaces them with normal human arms.
	var/l_limb_arm_type_mutantrace_f = null
	var/r_limb_leg_type_mutantrace_f = null
	var/l_limb_leg_type_mutantrace_f = null

	//This stuff is for robot_parts, the stuff above is for human_parts
	var/r_robolimb_arm_type_mutantrace = null // Should we get custom arms? Dispose() replaces them with normal human arms.
	var/l_robolimb_arm_type_mutantrace = null
	var/r_robolimb_leg_type_mutantrace = null
	var/l_robolimb_leg_type_mutantrace = null

	/// Replace both arms regardless of mob status (new and dispose).
	var/ignore_missing_limbs = 0

	var/firevuln = 1 //Scales damage, just like critters.
	var/brutevuln = 1
	var/toxvuln = 1

	var/list/typevulns

	/// ignores suffocation from being underwater + moves at full speed underwater
	var/aquatic = 0
	var/needs_oxy = 1

	var/voice_override = 0
	var/step_override = null

	var/mob/living/carbon/human/owner = null

	var/anchor_to_floor = FALSE

	var/special_style

	var/datum/movement_modifier/movement_modifier

	var/decomposes = TRUE
// end fuck this

// i just copy pasted the mutantrace procs and absolute pathed them. no added documentation yet. also no vars work lmaooooo

/*

/datum/human_extension/proc/say_filter(var/message)
	return message

/datum/human_extension/proc/say_verb()
	return null

/datum/human_extension/proc/emote(var/act)
	return null

// custom attacks, should return attack_hand by default or bad things will happen!!
// if you did something, return TRUE, else return FALSE and the normal hand stuff will be done
// ^--- Outdated, please use limb datums instead if possible.
/datum/human_extension/proc/custom_attack(atom/target)
	return FALSE

// vision modifier (see_mobs, etc i guess)
/datum/human_extension/proc/sight_modifier()
	return

/datum/human_extension/proc/onLife(var/mult = 1)	//Called every Life cycle of our mob
	return

/// Called when our mob dies.  Returning a true value will short circuit the normal death proc right before deathgasp/headspider/etc
/datum/human_extension/proc/onDeath(gibbed)
	return

/// For calling of procs when a mob is given a mutant race, to avoid issues with abstract representation in New()
/datum/human_extension/proc/on_attach()
	return

/datum/human_extension/New(var/mob/living/carbon/human/M)
	..() // Cant trust not-humans with a mutantrace, they just runtime all over the place
	if(ishuman(M) && M?.bioHolder?.mobAppearance)
		if (movement_modifier)
			APPLY_MOVEMENT_MODIFIER(M, movement_modifier, src.type)
		if (!needs_oxy)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_BREATHLESS, src.type)
		src.AH = M.bioHolder?.mobAppearance // i mean its called appearance holder for a reason
		if(!(src.mutant_appearance_flags & NOT_DIMORPHIC))
			MakeMutantDimorphic(M)
		AppearanceSetter(M, "set")
		LimbSetter(M, "set")
		organ_mutator(M, "set")
		src.limb_list.Add(l_limb_arm_type_mutantrace, r_limb_arm_type_mutantrace, l_limb_leg_type_mutantrace, r_limb_leg_type_mutantrace)
		src.owner = M
		var/list/obj/item/clothing/restricted = list(owner.w_uniform, owner.shoes, owner.wear_suit)
		for(var/obj/item/clothing/W in restricted)
			if (istype(W,/obj/item/clothing))
				if(W.compatible_species.Find(src.name) || (src.uses_human_clothes && W.compatible_species.Find("human")))
					continue
				src.owner.u_equip(W)
				boutput(src.owner, "<span class='alert'><B>You can no longer wear the [W.name] in your current state!</B></span>")
				if (W)
					W.set_loc(src.owner.loc)
					W.dropped(src.owner)
					W.layer = initial(W.layer)
		M.update_colorful_parts()

		SPAWN(2.5 SECONDS) // Don't remove.
			if (M?.organHolder?.skull)
				M.assign_gimmick_skull() // For hunters (Convair880).
		if (movement_modifier) // down here cus it causes runtimes
			APPLY_MOVEMENT_MODIFIER(M, movement_modifier, src.type)
	else
		qdel(src)
	return

/datum/human_extension/disposing()
	if (src.owner)
		src.owner.mutantrace = null
		src.owner.set_face_icon_dirty()
		src.owner.set_body_icon_dirty()

		if (movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(src.owner, movement_modifier, src.type)
		if (needs_oxy)
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_BREATHLESS, src.type)

		var/list/obj/item/clothing/restricted = list(src.owner.w_uniform, src.owner.shoes, src.owner.wear_suit)
		for (var/obj/item/clothing/W in restricted)
			if (istype(W,/obj/item/clothing))
				if (W.compatible_species.Find("human"))
					continue
				src.owner.u_equip(W)
				boutput(src.owner, "<span class='alert'><B>You can no longer wear the [W.name] in your current state!</B></span>")
				if (W)
					W.set_loc(src.owner.loc)
					W.dropped(src.owner)
					W.layer = initial(W.layer)
		if (ishuman(src.owner))
			var/mob/living/carbon/human/H = src.owner
			AppearanceSetter(H, "reset")
			MutateMutant(H, "reset")
			organ_mutator(H, "reset")
			LimbSetter(H, "reset")
			qdel(src.limb_list)

			H.set_face_icon_dirty()
			H.set_body_icon_dirty()
			H.update_colorful_parts()

			SPAWN(2.5 SECONDS) // Don't remove.
				if (H?.organHolder?.skull) // check for H.organHolder as well so we don't get null.skull runtimes
					H.assign_gimmick_skull() // We might have to update the skull (Convair880).

		if (movement_modifier) // causes runtimes, so its down here now
			REMOVE_MOVEMENT_MODIFIER(src.owner, movement_modifier, src.type)

		src.owner.set_clothing_icon_dirty()
		src.owner = null

	..()
	return

/datum/human_extension/proc/AppearanceSetter(var/mob/living/carbon/human/H, var/mode as text)
	if(!ishuman(H) || !(H?.bioHolder?.mobAppearance) || !src.AH)
		return // please dont call set_mutantrace on a non-human non-appearanceholder

	switch(mode)
		if("set")	// upload everything, the appearance flags'll determine what gets used
			src.origAH = new/datum/appearanceHolder
			src.origAH.CopyOther(AH) // backup the old appearanceholder

			AH.mob_appearance_flags = src.mutant_appearance_flags
			AH.customization_first_offset_y = src.head_offset
			AH.customization_second_offset_y = src.head_offset
			AH.customization_third_offset_y = src.head_offset

			var/typeinfo/datum/mutantrace/typeinfo = src.get_typeinfo()
			if(typeinfo.special_styles)
				if (!AH.special_style || !typeinfo.special_styles[AH.special_style]) // missing or invalid style
					AH.special_style = pick(typeinfo.special_styles)
				src.special_style = AH.special_style
				src.mutant_folder = typeinfo.special_styles[AH.special_style]

			AH.special_hair_1_icon = src.special_hair_1_icon
			AH.special_hair_1_state = src.special_hair_1_state
			AH.special_hair_1_color_ref = src.special_hair_1_color
			AH.special_hair_1_layer = src.special_hair_1_layer
			AH.special_hair_1_offset_y = src.head_offset

			AH.special_hair_2_icon = src.special_hair_2_icon
			AH.special_hair_2_state = src.special_hair_2_state
			AH.special_hair_2_color_ref = src.special_hair_2_color
			AH.special_hair_2_layer = src.special_hair_2_layer
			AH.special_hair_2_offset_y = src.head_offset

			AH.special_hair_3_icon = src.special_hair_3_icon
			AH.special_hair_3_state = src.special_hair_3_state
			AH.special_hair_3_color_ref = src.special_hair_3_color
			AH.special_hair_3_layer = src.special_hair_1_layer
			AH.special_hair_3_offset_y = src.head_offset

			AH.mob_detail_1_icon = src.detail_1_icon
			AH.mob_detail_1_state = src.detail_1_state
			AH.mob_detail_1_color_ref = src.detail_1_color
			AH.mob_detail_1_offset_y = src.body_offset

			AH.mob_oversuit_1_icon = src.detail_oversuit_1_icon
			AH.mob_oversuit_1_state = src.detail_oversuit_1_state
			AH.mob_oversuit_1_color_ref = src.detail_oversuit_1_color
			AH.mob_oversuit_1_offset_y = src.body_offset

			AH.mob_head_offset = src.head_offset
			AH.mob_hand_offset = src.hand_offset
			AH.mob_body_offset = src.body_offset
			AH.mob_leg_offset = src.leg_offset
			AH.mob_arm_offset = src.arm_offset

			if (src.mutant_appearance_flags & FIX_COLORS)	// mods the special colors so it doesnt mess things up if we stop being special
				AH.customization_first_color = fix_colors(AH.customization_first_color)
				AH.customization_second_color = fix_colors(AH.customization_second_color)
				AH.customization_third_color = fix_colors(AH.customization_third_color)

			AH.s_tone_original = AH.s_tone
			if(src.mutant_appearance_flags & SKINTONE_USES_PREF_COLOR_1)
				AH.s_tone = AH.customization_first_color
			else if(src.mutant_appearance_flags & SKINTONE_USES_PREF_COLOR_2)
				AH.s_tone = AH.customization_second_color
			else if(src.mutant_appearance_flags & SKINTONE_USES_PREF_COLOR_3)
				AH.s_tone = AH.customization_third_color
			else
				AH.s_tone = AH.s_tone_original

			AH.mutant_race = src
			AH.body_icon = src.mutant_folder
			AH.body_icon_state = src.icon_state
			AH.e_icon = src.eye_icon
			AH.e_state = src.eye_state
			AH.e_offset_y = src.eye_offset ? src.eye_offset : src.head_offset

			AH.UpdateMob()
		if("reset")
			var/still_should_have_this_funky_skintone = null // Hulk and such still require us to be a funky color
			if(H.bioHolder.HasOneOfTheseEffects("hulk", "albinism", "blankman", "melanism", "achromia"))
				still_should_have_this_funky_skintone = AH.s_tone
			AH.CopyOther(src.origAH)
			if(still_should_have_this_funky_skintone)
				AH.s_tone = still_should_have_this_funky_skintone
			AH.mob_appearance_flags = HUMAN_APPEARANCE_FLAGS
			AH.body_icon = 'icons/mob/human.dmi'
			AH.mutant_race = null
			AH.customization_first_offset_y = 0
			AH.customization_second_offset_y = 0
			AH.customization_third_offset_y = 0
			AH.mob_head_offset = 0
			AH.mob_hand_offset = 0
			AH.mob_body_offset = 0
			AH.mob_arm_offset = 0
			AH.mob_leg_offset = 0
			AH.e_offset_y = 0 // Fun fact, monkey eyes are right at nipple height
			AH.mob_oversuit_1_offset_y = 0
			AH.mob_detail_1_offset_y = 0
			AH.special_hair_3_offset_y = 0
			AH.special_hair_2_offset_y = 0
			AH.special_hair_1_offset_y = 0
			AH.UpdateMob()
			qdel(origAH)


/datum/human_extension/proc/LimbSetter(var/mob/living/carbon/human/L, var/mode as text)
	if(!ishuman(L) || !L.organHolder || !L.limbs)
		return // you and what army

	switch(mode)
		if("set")
			//////////////ARMS//////////////////
			if (src.r_limb_arm_type_mutantrace)
				if ((L.limbs.r_arm && !(L.limbs.r_arm.limb_is_transplanted || L.limbs.r_arm.limb_is_unnatural)) || src.ignore_missing_limbs == 1)
					var/obj/item/parts/human_parts/arm/limb = new src.r_limb_arm_type_mutantrace(L)
					if (istype(limb))
						qdel(L.limbs.r_arm)
						limb.quality = 0.5
						L.limbs.r_arm = limb
						limb.holder = L
						limb.remove_stage = 0

			if (src.l_limb_arm_type_mutantrace)
				if ((L.limbs.l_arm && !(L.limbs.l_arm.limb_is_transplanted || L.limbs.l_arm.limb_is_unnatural)) || src.ignore_missing_limbs == 1)
					var/obj/item/parts/human_parts/arm/limb = new src.l_limb_arm_type_mutantrace(L)
					if (istype(limb))
						qdel(L.limbs.l_arm)
						limb.quality = 0.5
						L.limbs.l_arm = limb
						limb.holder = L
						limb.remove_stage = 0

			//////////////LEGS//////////////////
			if (src.r_limb_leg_type_mutantrace)
				if ((L.limbs.r_leg && !(L.limbs.r_leg.limb_is_transplanted || L.limbs.r_leg.limb_is_unnatural)) || src.ignore_missing_limbs == 1)
					var/obj/item/parts/human_parts/leg/limb = new src.r_limb_leg_type_mutantrace(L)
					if (istype(limb))
						qdel(L.limbs.r_leg)
						limb.quality = 0.5
						L.limbs.r_leg = limb
						limb.holder = L
						limb.remove_stage = 0

			if (src.l_limb_leg_type_mutantrace)
				if ((L.limbs.l_leg && !(L.limbs.l_leg.limb_is_transplanted || L.limbs.l_leg.limb_is_unnatural)) || src.ignore_missing_limbs == 1)
					var/obj/item/parts/human_parts/leg/limb = new src.l_limb_leg_type_mutantrace(L)
					if (istype(limb))
						qdel(L.limbs.l_leg)
						limb.quality = 0.5
						L.limbs.l_leg = limb
						limb.holder = L
						limb.remove_stage = 0

			//////////////HEAD//////////////////
			if (src.special_head)
				L.organHolder?.head?.MakeMutantHead(src.special_head, src.mutant_folder, src.special_head_state)

		if ("reset")
			// And the other way around (Convair880).
			if (src.r_limb_arm_type_mutantrace)
				if ((L.limbs.r_arm && !(L.limbs.r_arm.limb_is_transplanted || L.limbs.r_arm.limb_is_unnatural)) || src.ignore_missing_limbs == 1)
					var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/right(L)
					if (istype(limb))
						qdel(L.limbs.r_arm)
						limb.quality = 0.5
						L.limbs.r_arm = limb
						limb.holder = L
						limb.remove_stage = 0

			if (src.l_limb_arm_type_mutantrace)
				if ((L.limbs.l_arm && !(L.limbs.l_arm.limb_is_transplanted || L.limbs.l_arm.limb_is_unnatural)) || src.ignore_missing_limbs == 1)
					var/obj/item/parts/human_parts/arm/limb = new /obj/item/parts/human_parts/arm/left(L)
					if (istype(limb))
						qdel(L.limbs.l_arm)
						limb.quality = 0.5
						L.limbs.l_arm = limb
						limb.holder = L
						limb.remove_stage = 0

			//////////////LEGS//////////////////
			if (src.r_limb_leg_type_mutantrace)
				if ((L.limbs.r_leg && !(L.limbs.r_leg.limb_is_transplanted || L.limbs.r_leg.limb_is_unnatural)) || src.ignore_missing_limbs == 1)
					var/obj/item/parts/human_parts/leg/limb = new /obj/item/parts/human_parts/leg/right(L)
					if (istype(limb))
						qdel(L.limbs.r_leg)
						limb.quality = 0.5
						L.limbs.r_leg = limb
						limb.holder = L
						limb.remove_stage = 0

			if (src.l_limb_leg_type_mutantrace)
				if ((L.limbs.l_leg && !(L.limbs.l_leg.limb_is_transplanted || L.limbs.l_leg.limb_is_unnatural)) || src.ignore_missing_limbs == 1)
					var/obj/item/parts/human_parts/leg/limb = new /obj/item/parts/human_parts/leg/left(L)
					if (istype(limb))
						qdel(L.limbs.l_leg)
						limb.quality = 0.5
						L.limbs.l_leg = limb
						limb.holder = L
						limb.remove_stage = 0
			//////////////HEAD//////////////////
			L.organHolder?.head?.MakeMutantHead(HEAD_HUMAN, 'icons/mob/human_head.dmi', "head")

/datum/human_extension/proc/organ_mutator(var/mob/living/carbon/human/O, var/mode as text)
	if(!ishuman(O) || !(O?.organHolder))
		return // hard to mess with someone's organs if they can't have any

	var/datum/organHolder/OHM = O.organHolder

	switch(mode)
		if("set")
			if(!src.mutant_organs.len)
				return // All done!
			else
				for(var/mutorgan in src.mutant_organs)
					if (mutorgan == "tail") // Not everyone has a tail. So just force it in
						if (OHM.tail)
							qdel(OHM.tail)
					else if(mutorgan == "butt") // butts arent organs
						var/obj/item/clothing/head/butt/org = OHM.get_organ(mutorgan)
						if(!org || istype(org, /obj/item/clothing/head/butt/cyberbutt)) // No free butts, keep your robutt too
							continue
					else // everything else is an organ, though
						var/obj/item/organ/org = OHM.get_organ(mutorgan)
						if (!org || org.robotic) // No free organs, trade-ins only, keep ur robotic stuff
							continue
					var/obj/item/organ_get = src.mutant_organs[mutorgan]
					OHM.receive_organ(new organ_get(O, OHM), mutorgan, 0, 1)
				return
		if("reset") // Make everything mutant back into stock-ass human
			if(!src.mutant_organs.len)
				return // All done!
			if (OHM.tail) // mutant to human, drop the tail. Unless you're a changer, then your butt just eats it
				qdel(OHM.tail)
			else
				for(var/mutorgan in src.mutant_organs)
					if(mutorgan == "butt") // butts arent organs
						var/obj/item/clothing/head/butt/org = OHM.get_organ(mutorgan)
						if(!org || istype(org, /obj/item/clothing/head/butt/cyberbutt)) // No free butts, keep your robutt too
							continue
					else // everything else is an organ, though
						var/obj/item/organ/org = OHM.get_organ(mutorgan)
						if (!org || org.robotic) // No free organs, trade-ins only, keep ur robotic stuff
							continue
					var/obj/item/organ_get = OHM.organ_type_list[mutorgan] // organ_type_list holds all the default human-ass organs
					OHM.receive_organ(new organ_get(O, OHM), mutorgan, 0, 1)
				return

/// Applies or removes the bioeffect associated with the mutantrace
/datum/human_extension/proc/MutateMutant(var/mob/living/carbon/human/H, var/mode as text)
	if (!H || !mode || !race_mutation)
		return
	var/datum/bioEffect/mutantrace/mr = src.race_mutation
	switch (mode)
		if ("set")
			if(!H.bioHolder.HasEffect(initial(mr.id)))
				H.bioHolder.AddEffect(initial(mr.id), 0, 0, 0, 1)
		if ("reset")
			if(H.bioHolder.HasEffect(initial(mr.id)))
				H.bioHolder.RemoveEffect(initial(mr.id))

/// Copies over female variants of mutant heads and organs
/datum/human_extension/proc/MakeMutantDimorphic(var/mob/living/carbon/human/H)
	if(!src.AH || !ishuman(H)) return

	if(src.AH.gender == FEMALE)
		if(src.special_head_f)
			src.special_head = src.special_head_f
		if(src.special_head_state_f)
			src.special_head_state = src.special_head_state_f
		if(src.mutant_organs_f)
			src.mutant_organs =  src.mutant_organs_f

		if(src.r_limb_arm_type_mutantrace_f)
			src.r_limb_arm_type_mutantrace = src.r_limb_arm_type_mutantrace_f
		if(src.l_limb_arm_type_mutantrace_f)
			src.l_limb_arm_type_mutantrace = src.l_limb_arm_type_mutantrace_f
		if(src.r_limb_leg_type_mutantrace_f)
			src.r_limb_leg_type_mutantrace = src.r_limb_leg_type_mutantrace_f
		if(src.l_limb_leg_type_mutantrace_f)
			src.l_limb_leg_type_mutantrace = src.l_limb_leg_type_mutantrace_f

		if(src.special_hair_1_icon_f)
			src.special_hair_1_icon = src.special_hair_1_icon_f
		if(src.special_hair_1_state_f)
			src.special_hair_1_state = src.special_hair_1_state_f
		if(src.special_hair_1_color_f)
			src.special_hair_1_color = src.special_hair_1_color_f
		if(src.special_hair_1_layer_f)
			src.special_hair_1_layer = src.special_hair_1_layer_f

		if(src.special_hair_2_icon_f)
			src.special_hair_2_icon = src.special_hair_2_icon_f
		if(src.special_hair_2_state_f)
			src.special_hair_2_state = src.special_hair_2_state_f
		if(src.special_hair_2_color_f)
			src.special_hair_2_color = src.special_hair_2_color_f
		if(src.special_hair_2_layer_f)
			src.special_hair_2_layer = src.special_hair_2_layer_f

		if(src.special_hair_3_icon_f)
			src.special_hair_3_icon = src.special_hair_3_icon_f
		if(src.special_hair_3_state_f)
			src.special_hair_3_state = src.special_hair_3_state_f
		if(src.special_hair_3_color_f)
			src.special_hair_3_color = src.special_hair_3_color_f
		if(src.special_hair_3_layer_f)
			src.special_hair_3_layer = src.special_hair_3_layer_f

		if(src.detail_1_icon_f)
			src.detail_1_icon = src.detail_1_icon_f
		if(src.detail_1_state_f)
			src.detail_1_state = src.detail_1_state_f
		if(src.detail_1_color_f)
			src.detail_1_color = src.detail_1_color_f

		if(src.detail_oversuit_1_icon_f)
			src.detail_oversuit_1_icon = src.detail_oversuit_1_icon_f
		if(src.detail_oversuit_1_state_f)
			src.detail_oversuit_1_state = src.detail_oversuit_1_state_f
		if(src.detail_oversuit_1_color_f)
			src.detail_oversuit_1_color = src.detail_oversuit_1_color_f
*/
