#define OVERRIDE_ARM_L 1
#define OVERRIDE_ARM_R 2
#define OVERRIDE_LEG_R 4
#define OVERRIDE_LEG_L 8

/// mutant races: cheap way to add new "types" of mobs
TYPEINFO(/datum/mutantrace)
	var/list/special_styles // special styles which currently change the icon (sprite sheet)
/datum/mutantrace
	var/name = null				// used for identification in diseases, clothing, etc
	/// The mutation associted with the mutantrace. Saurian genetics for lizards, for instance
	var/race_mutation = null
	/// The mutant's own appearanceholder, modified to suit our target appearance
	var/datum/appearanceHolder/AH
	/// The mutant's original appearanceholder, from before they were a mutant, to restore their old appearance
	var/datum/appearanceHolder/origAH
	var/override_eyes = 1
	var/override_hair = 1
	var/override_beard = 1
	var/override_detail = 1
	var/override_skintone = 1
	var/override_attack = FALSE		 // set to 1 to override the limb attack actions. Mutantraces may use the limb action within custom_attack(),
								// but they must explicitly specify if they're overriding via this var
	var/override_language = null // set to a language ID to replace the language of the human
	var/understood_languages = list() // additional understood languages (in addition to override_language if set, or english if not)
	/** Mutant Appearance Flags - used to modify how the mob is drawn
	*
	* For a purely static-icon mutantrace (drawn from a single, non-chunked image), use:
	*
	* (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | HAS_NO_HEAD | USES_STATIC_ICON)
	*
	* NOT_DIMORPHIC tells the sprite builder not to use any female sprites or vars. If you remove this, make sure there's a torso_f and groin_f in the mutant's DMI!
	*
	* HAS_NO_SKINTONE, HAS_NO_EYES, HAS_NO_HEAD each prevent the renderer from trying to colorize the player's body or apply hair / eyes. They tend to be baked in.
	*
	* USES_STATIC_IMAGE tells the renderer to skip most of the body-sprite assembly stuff, since our sprite is already fully assembled
	*
	* To make a dismemberable mutant, here's an example from lizard:
	*
	* (NOT_DIMORPHIC | HAS_HUMAN_EYES | BUILT_FROM_PIECES | HAS_EXTRA_DETAILS | FIX_COLORS | SKINTONE_USES_PREF_COLOR_1 | HAS_SPECIAL_HAIR)
	*
	* SKINTONE_USES_PREF_COLOR_1 tells the renderer that the skintone will come from the appearanceholder's first customization color
	*
	* HAS_HUMAN_EYES tells the head builder to render their eyes
	*
	* HAS_EXTRA_DETAILS tells the sprite builder to apply whatever's defined in their mob_detail_1 vars to their sprite
	*
	* FIX_COLORS clamps the RGB values of the customization colors betwen 50 and 190. Keeps them from getting too dark or oversaturated
	*
	* HAS_SPECIAL_HAIR tells the hair renderer to display the sprites stored iin the head's special hair, which can be defined here (through the appearanceholder)
	*
	* BUILT_FROM_PIECES is important, it tells the renderer to assemble the mutant from a set of separate pieces, like a human
	* this allows them to apppear to be missing limbs when dismembered. Check out lizard.dmi for an example of how it should be set up.
	*
	* SEE: appearance.dm for more flags and details!
	*/
	var/mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | HAS_NO_HEAD | USES_STATIC_ICON)

	/// if TRUE, allows human diseases and dna injectors to affect this mutantrace
	var/human_compatible = TRUE
	/// if FALSE, can only wear clothes if listed in [/obj/item/clothing/var/compatible_species]
	var/uses_human_clothes = TRUE
	/// if TRUE, only understood by others of this mutantrace
	var/exclusive_language = FALSE
	/// overrides normal voice message if defined (and others don't understand us, ofc)
	var/voice_message = null
	var/voice_name = "human"
	/// Should robots arrest these by default?
	var/jerk = FALSE
	/// Should stable mutagen not copy from this mutant?
	var/dna_mutagen_banned = TRUE
	/// Should a genetics terminal be able to remove this mutantrace?
	var/genetics_removable = TRUE
	/// Should they be able to walk on shards barefoot
	var/can_walk_on_shards = FALSE
	/// This is used for static icons if the mutant isn't built from pieces
	/// For chunked mutantraces this must still point to a valid full-body image to generate a staticky sprite for ghostdrones.
	var/icon = 'icons/effects/genetics.dmi'
	var/icon_state = "blank_c"
	/// The icon used to render their eyes
	var/eye_icon = 'icons/mob/human_hair.dmi'
	/// The state used to render their eyes
	var/eye_state = "eyes"

	/// If the mutant uses a non-human head, this'll tell the head builder which head to build
	var/special_head = null
	/// If our mutant has a female variant, it'll use this head instead
	var/special_head_f = null
	/// The icon_state of the head we're using
	var/special_head_state = "head"
	/// If our mutant has a female variant, it'll use this head image instead
	var/special_head_state_f = null
	/// The icon of the head, body, and limbs we're using
	var/mutant_folder = 'icons/effects/genetics.dmi'
	/// Swaps out the entries in the mob's organ_holder with these (hopefully) organs
	/// Format: ("entry_in_organholder's_organlist", /obj/item/organ/path)
	var/list/mutant_organs = list()
	/// If our mutant has a female variant that has different organs, these will be used instead
	var/list/mutant_organs_f = null

	// icon definitions for mutantrace clothing variants. one icon file per slot.
	var/clothing_icon_uniform = null
	var/clothing_icon_id = null
	var/clothing_icon_hands = null
	var/clothing_icon_feet = null
	var/clothing_icon_overcoats = null
	var/clothing_icon_back = null
	var/clothing_icon_eyes = null
	var/clothing_icon_ears = null
	var/clothing_icon_mask = null
	var/clothing_icon_head = null
	var/clothing_icon_belt = null

	var/head_offset = 0 // affects pixel_y of clothes
	var/hand_offset = 0
	var/body_offset = 0
	var/arm_offset = 0
	/// affects pixel_y of the legs and stump, in case the mutant has a non-human length torsocrotch
	var/leg_offset = 0
	/// affects pixel_y of eyes if they're different from normal head-placement. darn anime monkey eyes
	/// If 0, it inherits that of the head offset. Otherwise, it applies as normal
	/// So, it should typically be something like head_offset +/- a few pixels
	var/eye_offset = 0

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

	var/mob/living/carbon/human/mob = null	// ...is this the owner?

	var/anchor_to_floor = 0

	var/special_style

	/// Special Hair is anything additional that's supposed to be stuck to the mob's head
	/// Can be anything, honestly. Used for lizard head things and cow horns
	/// Will only show up if the mob's appearance flag includes HAS_SPECIAL_HAIR
	var/special_hair_1_icon
	/// The "_f" vars are applied for female variants, if the appearance flags don't have NOT_DIMORPHIC
	var/special_hair_1_icon_f
	/// State to be used. Human hairstyles must be defined by their icon state, not hairstyle name!
	var/special_hair_1_state
	var/special_hair_1_state_f
	/// Which preference entry to colorize this from.
	/// CUST_1 to use the appearanceholder's custom_first_color, and so on. Make null for just "#FFFFFF"
	var/special_hair_1_color = CUST_1
	var/special_hair_1_color_f
	/// Which layer should this hair appear? Defaults to the normal hair-layer
	var/special_hair_1_layer = MOB_HAIR_LAYER2
	var/special_hair_1_layer_f = MOB_HAIR_LAYER2
	/// The image to be inserted into the mob's appearanceholder's customization_second
	var/special_hair_2_icon
	var/special_hair_2_icon_f
	var/special_hair_2_state
	var/special_hair_2_state_f
	var/special_hair_2_color = CUST_2
	var/special_hair_2_color_f
	var/special_hair_2_layer = MOB_HAIR_LAYER2
	var/special_hair_2_layer_f = MOB_HAIR_LAYER2
	/// The image to be inserted into the mob's appearanceholder's customization_third
	var/special_hair_3_icon
	var/special_hair_3_icon_f
	var/special_hair_3_state
	var/special_hair_3_state_f
	var/special_hair_3_color = CUST_3
	var/special_hair_3_color_f
	var/special_hair_3_layer = MOB_HAIR_LAYER2
	var/special_hair_3_layer_f = MOB_HAIR_LAYER2

	/// These details will show up layered just in front of the mob's skin
	/// The image to be inserted into the mob's appearanceholder's mob_detail_1
	var/detail_1_icon
	var/detail_1_icon_f
	var/detail_1_state
	var/detail_1_state_f
	var/detail_1_color = CUST_1
	var/detail_1_color_f

	/// These details will show up layered between the backpack and the outer suit
	/// The image to be inserted into the mob's appearanceholder's mob_oversuit_1
	/// Will only show up if the mob's appearance flag includes HAS_O
	var/detail_oversuit_1_icon
	var/detail_oversuit_1_icon_f
	var/detail_oversuit_1_state
	var/detail_oversuit_1_state_f
	var/detail_oversuit_1_color = CUST_1
	var/detail_oversuit_1_color_f

	var/datum/movement_modifier/movement_modifier

	var/decomposes = TRUE

	/// List of 0 to 3 strings representing the names for the color channels
	/// used in the character creator. For vanilla humans (or HAS_HUMAN_HAIR)
	/// this is list("Bottom Detail", "Mid Detail", "Top Detail").
	var/list/color_channel_names = list()

	var/self_click_fluff //used when clicking self on help intent

	proc/say_filter(var/message)
		return message

	proc/say_verb()
		return null

	proc/emote(var/act)
		return null

	// custom attacks, should return attack_hand by default or bad things will happen!!
	// if you did something, return TRUE, else return FALSE and the normal hand stuff will be done
	// ^--- Outdated, please use limb datums instead if possible.
	proc/custom_attack(atom/target)
		return FALSE

	// vision modifier (see_mobs, etc i guess)
	proc/sight_modifier()
		return

	proc/onLife(var/mult = 1)	//Called every Life cycle of our mob
		return

	/// Called when our mob dies.  Returning a true value will short circuit the normal death proc right before deathgasp/headspider/etc
	proc/onDeath(gibbed)
		return

	/// For calling of procs when a mob is given a mutant race, to avoid issues with abstract representation in New()
	proc/on_attach()
		return

	New(var/mob/living/carbon/human/M)
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
			src.mob = M
			var/list/obj/item/clothing/restricted = list(mob.w_uniform, mob.shoes, mob.wear_suit)
			for(var/obj/item/clothing/W in restricted)
				if (istype(W,/obj/item/clothing))
					if(W.compatible_species.Find(src.name) || (src.uses_human_clothes && W.compatible_species.Find("human")))
						continue
					src.mob.u_equip(W)
					boutput(src.mob, "<span class='alert'><B>You can no longer wear the [W.name] in your current state!</B></span>")
					if (W)
						W.set_loc(src.mob.loc)
						W.dropped(src.mob)
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

	disposing()
		if (src.mob)
			src.mob.mutantrace = null
			src.mob.set_face_icon_dirty()
			src.mob.set_body_icon_dirty()

			if (movement_modifier)
				REMOVE_MOVEMENT_MODIFIER(src.mob, movement_modifier, src.type)
			if (needs_oxy)
				REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_BREATHLESS, src.type)

			var/list/obj/item/clothing/restricted = list(src.mob.w_uniform, src.mob.shoes, src.mob.wear_suit)
			for (var/obj/item/clothing/W in restricted)
				if (istype(W,/obj/item/clothing))
					if (W.compatible_species.Find("human"))
						continue
					src.mob.u_equip(W)
					boutput(src.mob, "<span class='alert'><B>You can no longer wear the [W.name] in your current state!</B></span>")
					if (W)
						W.set_loc(src.mob.loc)
						W.dropped(src.mob)
						W.layer = initial(W.layer)
			if (ishuman(src.mob))
				var/mob/living/carbon/human/H = src.mob
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
				REMOVE_MOVEMENT_MODIFIER(src.mob, movement_modifier, src.type)

			src.mob.set_clothing_icon_dirty()
			src.mob = null

		..()
		return

	proc/AppearanceSetter(var/mob/living/carbon/human/H, var/mode as text)
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


	proc/LimbSetter(var/mob/living/carbon/human/L, var/mode as text)
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

	proc/organ_mutator(var/mob/living/carbon/human/O, var/mode as text)
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
	proc/MutateMutant(var/mob/living/carbon/human/H, var/mode as text)
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
	proc/MakeMutantDimorphic(var/mob/living/carbon/human/H)
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

/datum/mutantrace/blob // podrick's july assjam submission, it's pretty cute
	name = "blob"
	icon = 'icons/mob/blob_ambassador.dmi'
	mutant_folder = 'icons/mob/blob_ambassador.dmi'
	icon_state = "blob"
	human_compatible = 0
	uses_human_clothes = 0
	hand_offset = -1
	body_offset = -8
	voice_override = "bloop"
	firevuln = 1.5
	typevulns = list("cut" = 1.25, "stab" = 0.5, "blunt" = 0.75)

	say_verb()
		return pick("burbles", "gurgles", "blurbs", "gloops")

/datum/mutantrace/flubber
	name = "flubber"
	icon = 'icons/mob/flubber.dmi'
	mutant_folder = 'icons/mob/flubber.dmi'
	icon_state = "flubber"
	uses_human_clothes = 0
	head_offset = -7
	voice_override = "bloop"

	movement_modifier = /datum/movement_modifier/flubber

	//override_static = 1

	jerk = FALSE //flubber is a good goo person

	New()
		..()
		if (src.mob)
			RegisterSignal(src.mob, COMSIG_MOVABLE_MOVED, .proc/flub)

	sight_modifier()
		src.mob.see_in_dark = SEE_DARK_FULL

	proc/flub()
		playsound(src.mob, "sound/misc/boing/[rand(1,6)].ogg", 20, 1 )
		animate(src.mob, time = 1, pixel_y = 16, easing = ELASTIC_EASING)
		animate(time = 1, pixel_y = 0, easing = ELASTIC_EASING)

	say_filter(var/message)
		return pick("Wooo!!", "Whopeee!!", "Boing!!", "Čapaš!!")

	onLife(var/mult = 1)
		if (!isdead(src.mob))
			src.mob.reagents.add_reagent("flubber", 10) //change "flubber" to whatever flubber is in code obviously

		if (src.mob.health < src.mob.max_health && src.mob.health>0) //you can kill flubber with extreme measures
			src.mob.full_heal()

	onDeath(gibbed)
		var/turf/T = get_turf(src.mob)
		T.fluid_react_single("flubber", 500)
		src.mob.gib()


	say_verb()
		return "flubbers"

/datum/mutantrace/flashy
	name = "flashy"
	icon = 'icons/mob/flashy.dmi'
	icon_state = "body_m"
	mutant_appearance_flags = (HAS_NO_SKINTONE | HAS_HUMAN_HAIR | HEAD_HAS_OWN_COLORS | HAS_HUMAN_EYES | WEARS_UNDERPANTS | BUILT_FROM_PIECES)
	override_attack = 0
	mutant_folder = 'icons/mob/flashy.dmi'
	special_head = HEAD_FLASHY
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/flashy/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/flashy/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/flashy/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/flashy/left
	dna_mutagen_banned = FALSE


/datum/mutantrace/virtual
	name = "virtual"
	icon = 'icons/mob/virtual.dmi'
	icon_state = "body_m"
	override_attack = 0
	mutant_folder = 'icons/mob/virtual.dmi'
	special_head = HEAD_VIRTUAL
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/virtual/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/virtual/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/virtual/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/virtual/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_HUMAN_HAIR | HAS_HUMAN_EYES | BUILT_FROM_PIECES)


	New(var/mob/living/carbon/human/H)
		..()
		if(ishuman(src.mob))
			src.mob.blood_color = pick("#FF0000","#FFFF00","#00FF00","#00FFFF","#0000FF","#FF00FF")
			var/datum/abilityHolder/virtual/A = H.get_ability_holder(/datum/abilityHolder/virtual)
			if (A && istype(A))
				return
			var/datum/abilityHolder/virtual/W = H.add_ability_holder(/datum/abilityHolder/virtual)
			W.addAbility(/datum/targetable/virtual/logout)
//for sure didnt steal code from ww. no siree

/datum/mutantrace/blank
	name = "blank"
	icon_state = "blank"
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_HUMAN_HAIR | HAS_NO_EYES | HAS_NO_HEAD | WEARS_UNDERPANTS | USES_STATIC_ICON)
	override_attack = 0

/datum/mutantrace/grey
	name = "grey"
	icon_state = "grey"
	voice_name = "grey"
	voice_message = "hums"

	exclusive_language = 1
	jerk = TRUE
	var/original_blood_color = null

	New(var/mob/living/carbon/human/M)
		..()
		if(ishuman(src.mob))
			original_blood_color = src.mob.blood_color
			src.mob.blood_color = "#000000"

	disposing()
		if(ishuman(src.mob))
			if(!isnull(original_blood_color))
				src.mob.blood_color = original_blood_color
		original_blood_color = null
		..()

	sight_modifier()
		src.mob.sight |= SEE_MOBS
		src.mob.see_in_dark = SEE_DARK_FULL
		src.mob.see_invisible = INVIS_CLOAK

	emote(var/act)
		var/message = null
		if(act == "scream")
			if(src.mob.emote_allowed)
				src.mob.emote_allowed = 0
				message = "<B>[src.mob]</B> screams with [his_or_her(src.mob)] mind! Guh, that's creepy!"
				playsound(src.mob, 'sound/voice/screams/Psychic_Scream_1.ogg', 80, 0, 0, clamp(1.0 + (30 - src.mob.bioHolder.age)/60, 0.7, 1.2), channel=VOLUME_CHANNEL_EMOTE)
				SPAWN(3 SECONDS)
					src.mob?.emote_allowed = 1
			return message
		else
			..()

/datum/mutantrace/lizard
	name = "lizard"
	icon = 'icons/mob/lizard.dmi'
	icon_state = "body_m"
	override_attack = 0
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_HUMAN_EYES | BUILT_FROM_PIECES | HAS_EXTRA_DETAILS | FIX_COLORS | SKINTONE_USES_PREF_COLOR_1 | HAS_SPECIAL_HAIR | TORSO_HAS_SKINTONE | WEARS_UNDERPANTS)
	voice_override = "lizard"
	special_head = HEAD_LIZARD
	special_head_state = "head"
	eye_state = "eyes_lizard"
	mutant_organs = list("tail" = /obj/item/organ/tail/lizard,
	"left_eye" = /obj/item/organ/eye/lizard,
	"right_eye" = /obj/item/organ/eye/lizard)
	mutant_folder = 'icons/mob/lizard.dmi'
	special_hair_1_icon = 'icons/mob/lizard.dmi'
	special_hair_1_state = "head-detail_1"
	special_hair_1_color = CUST_3
	special_hair_1_layer = MOB_HAIR_LAYER1
	special_hair_1_layer_f = MOB_HAIR_LAYER1
	detail_1_icon = 'icons/mob/lizard.dmi'
	detail_1_state = "lizard_detail-1"
	detail_1_color = CUST_2
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/lizard/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/lizard/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/lizard/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/lizard/left
	race_mutation = /datum/bioEffect/mutantrace // Most mutants are just another form of lizard, didn't you know?
	clothing_icon_overcoats = 'icons/mob/lizard/overcoats.dmi'
	clothing_icon_eyes = 'icons/mob/lizard/eyes.dmi'
	clothing_icon_mask = 'icons/mob/lizard/mask.dmi'
	clothing_icon_head = 'icons/mob/lizard/head.dmi'
	color_channel_names = list("Episcutus", "Ventral Aberration", "Sagittal Crest")
	dna_mutagen_banned = FALSE
	self_click_fluff = "scales"

	New(var/mob/living/carbon/human/H)
		..()
		if(ishuman(H))
			H.give_lizard_powers()
			H.AddComponent(/datum/component/consume/organpoints, /datum/abilityHolder/lizard)
			H.AddComponent(/datum/component/consume/can_eat_inedible_organs)
			H.mob_flags |= SHOULD_HAVE_A_TAIL

			H.update_face()
			H.update_body()
			H.update_clothing()
			H.thermoregulation_mult = 0.004
			H.base_body_temp = T0C + 38

	sight_modifier()
		src.mob.see_in_dark = SEE_DARK_HUMAN + 1
		src.mob.see_invisible = INVIS_INFRA

	say_filter(var/message)
		var/replace_lowercase = replacetextEx(message, "s", stutter("ss"))
		var/replace_uppercase = replacetextEx(replace_lowercase, "S", stutter("SS"))
		return replace_uppercase

	disposing()
		if(ishuman(src.mob))
			var/mob/living/carbon/human/L = src.mob
			var/datum/component/C = L.GetComponent(/datum/component/consume/organpoints)
			C?.RemoveComponent(/datum/component/consume/organpoints)
			var/datum/component/D = L.GetComponent(/datum/component/consume/can_eat_inedible_organs)
			D?.RemoveComponent(/datum/component/consume/can_eat_inedible_organs)
			L.remove_lizard_powers()
			src.mob.mob_flags &= ~SHOULD_HAVE_A_TAIL
			src.mob.thermoregulation_mult = initial(src.mob.thermoregulation_mult)
			src.mob.base_body_temp = initial(src.mob.base_body_temp)
		. = ..()

	say_verb()
		return "hisses"

/datum/mutantrace/zombie
	name = "zombie"
	icon_state = "zombie"
	human_compatible = FALSE
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_HUMAN_HAIR | HAS_NO_EYES | HAS_NO_HEAD | USES_STATIC_ICON | HEAD_HAS_OWN_COLORS)
	jerk = TRUE
	override_attack = 0
	needs_oxy = 0
	movement_modifier = /datum/movement_modifier/zombie
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/right/zombie
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/left/zombie
	var/strain = 0

	//this is terrible, but I do anyway.
	can_infect/bubs
		strain = 1

	can_infect/spitter
		strain = 2

	can_infect/normal
		strain = -1

	New(var/mob/living/carbon/human/M)
		..()
		if(ishuman(src.mob))
			src.add_ability(src.mob)
			M.is_zombie = 1
			M.max_health += 100
			M.health = max(M.max_health, M.health)

			if (strain == 1)
				make_bubs(M)
			else if (strain == 2)
				make_spitter(M)
			else if (strain == 0 && prob(30))	//chance to be one or the other
				strain = rand(1,2)
				if(strain == 1) //Bubs
					make_bubs(M)
				if(strain == 2) // spitter ranged zombie
					make_spitter(M)

			M.add_stam_mod_max("zombie", 100)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "zombie", -5)
			M.full_heal()
			M.real_name = "Zombie [M.real_name]"

			//give em zombie arms if they don't have em...
			if (!istype(M.limbs.r_arm, /obj/item/parts/human_parts/arm/right/zombie))
				M.limbs.replace_with("r_arm", /obj/item/parts/human_parts/arm/right/zombie, M, 0)
			if (!istype(M.limbs.l_arm, /obj/item/parts/human_parts/arm/left/zombie))
				M.limbs.replace_with("l_arm", /obj/item/parts/human_parts/arm/left/zombie, M, 0)

			SPAWN(rand(4, 30))
				M.emote("scream")
			M.mind.add_antagonist(ROLE_ZOMBIE, "Yes", "Yes", ANTAGONIST_SOURCE_MUTANT, FALSE)
			M.show_antag_popup("zombie")

	on_attach()
		if(ishuman(src.mob))
			src.mob.antagonist_overlay_refresh(1)

	proc/make_bubs(var/mob/living/carbon/human/M)
		M.bioHolder.AddEffect("strong")
		M.bioHolder.AddEffect("mattereater")
		M.Scale(1.15, 1.15) //Fat bioeffect doesn't exist anymore, so they're just bigger now.
		M.max_health += 150
		M.health = max(M.max_health, M.health)

	proc/make_spitter(var/mob/living/carbon/human/M)
		M.max_health -= 45
		M.health = max(M.max_health, M.health)
		M.Scale(1, 0.9)
		M.add_sm_light("glowy", list(94, 209, 31, 175))
		M.bioHolder.AddEffect("shoot_limb")
		M.bioHolder.AddEffect("acid_bigpuke")
		boutput(M, "<h2><span class='alert'><B>You're a spitter zombie, check your BIOEFFECTS for your POWERS!</B></span></h2>")

	onLife(var/mult = 1)
		..()

		src.mob.HealDamage("All", 2*mult, 2*mult)
		if (strain == 1)
			src.mob.HealDamage("All", 1*mult, 1*mult)
		else if (strain == 2 && prob(5))//spitter, then regrow their arms possibly
			src.mob.limbs.mend(1)

	disposing()
		if (ishuman(src.mob))
			src.mob.remove_stam_mod_max("zombie")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STAMINA_REGEN_BONUS, "zombie")
		..()

	proc/add_ability(var/mob/living/carbon/human/H)
		return

	sight_modifier()
		src.mob.sight |= SEE_MOBS
		src.mob.see_in_dark = SEE_DARK_FULL
		src.mob.see_invisible = INVIS_NONE

	say_filter(var/message)
		return pick("Urgh...", "Brains...", "Hungry...", "Kill...")

	emote(var/act)
		var/message = null
		if(act == "scream")
			if(src.mob.emote_allowed)
				src.mob.emote_allowed = 0
				message = "<B>[src.mob]</B> moans!"
				playsound(src.mob, "sound/voice/Zgroan[pick("1","2","3","4")].ogg", 80, 0, 0, clamp(1.0 + (30 - src.mob.bioHolder.age)/60, 0.7, 1.2), channel=VOLUME_CHANNEL_EMOTE)
				SPAWN(3 SECONDS)
					src.mob?.emote_allowed = 1
			return message
		else
			..()

	onDeath(gibbed)
		if(gibbed)
			return
		src.mob.show_message("<span class='notice'>You can feel your flesh re-assembling. You will rise once more. (This will take about one minute.)</span>")
		SPAWN(45 SECONDS)
			if (src.mob)
				if (!src.mob.organHolder.brain || !src.mob.organHolder.skull || !src.mob.organHolder.head)
					src.mob.show_message("<span class='notice'>You fail to rise, your brain has been destroyed.</span>")
				else
					src.mob.full_heal()

					src.mob.emote("scream")
					src.mob.visible_message("<span class='alert'><B>[src.mob]</B> rises from the dead!</span>")

					if (strain == 0 && prob(25))	//chance to be one or the other
						strain = rand(1,2)
						if(strain == 1) //Bubs
							make_bubs(src.mob)
						if(strain == 2) // spitter ranged zombie
							make_spitter(src.mob)

		return 1

/datum/mutantrace/zombie/can_infect

	add_ability(var/mob/living/carbon/human/H)
		var/datum/abilityHolder/critter/C = H.add_ability_holder(/datum/abilityHolder/critter) //lol
		C.transferOwnership(H)
		C.addAbility(/datum/targetable/critter/zombify)

	disposing()
		if (ishuman(src.mob))
			var/mob/living/carbon/human/H = src.mob
			H.abilityHolder.removeAbility(/datum/targetable/critter/zombify)
		..()

/datum/mutantrace/vampiric_thrall
	name = "vampiric thrall"
	icon = 'icons/mob/vampiric_thrall.dmi'
	icon_state = "body_m"
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_HUMAN_HAIR | HAS_HUMAN_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS | WEARS_UNDERPANTS)
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/right/zombie
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/left/zombie
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/vampiric_thrall/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/vampiric_thrall/left
	mutant_folder = 'icons/mob/vampiric_thrall.dmi'
	special_head = HEAD_VAMPTHRALL
	jerk = TRUE
	genetics_removable = FALSE

	var/blood_points = 0
#ifdef RP_MODE
	var/blood_decay = 0.25
#else
	var/blood_decay = 0.5
#endif
	var/cleanable_tally = 0
	var/blood_to_health_scalar = 0.75 //200 blood = 150 health
	var/min_max_health = 40 //! Minimum health we can get to via blood loss. also lol

	New(var/mob/living/carbon/human/M)
		..()
		if(ishuman(src.mob))
			M.update_face()
			M.update_body()
			M.update_clothing()
			src.add_ability(src.mob)
			M.add_stam_mod_max("vampiric_thrall", 100)
			M.bioHolder.AddEffect("accent_thrall", magical=TRUE)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_BREATHLESS, src)
			//APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "vampiric_thrall", 15)

	disposing()
		if (ishuman(src.mob))
			src.mob.remove_stam_mod_max("vampiric_thrall")
			src.mob.bioHolder.RemoveEffect("accent_thrall")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_BREATHLESS, src)
			//REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STAMINA_REGEN_BONUS, "vampiric_thrall")
		..()

	proc/add_ability(var/mob/living/carbon/human/H)
		H.make_vampiric_thrall()

	onLife(var/mult = 1)
		..()

		if (src.mob.bleeding)
			blood_points -= blood_decay * src.mob.bleeding

		var/prev_blood = blood_points
		blood_points -= blood_decay * mult
		blood_points = max(0,blood_points)
		cleanable_tally += (prev_blood - blood_points)
		if (cleanable_tally > 20)
			make_cleanable(/obj/decal/cleanable/blood,get_turf(src.mob))
			cleanable_tally = 0

		src.mob.max_health = blood_points * blood_to_health_scalar
		src.mob.max_health = max(src.min_max_health, src.mob.max_health)
		health_update_queue |= src.mob

	emote(var/act)
		var/message = null
		if(act == "scream")
			if(src.mob.emote_allowed)
				src.mob.emote_allowed = 0
				message = "<B>[src.mob]</B> moans!"
				playsound(src.mob, "sound/voice/Zgroan[pick("1","2","3","4")].ogg", 80, 0, 0, clamp(1.0 + (30 - src.mob.bioHolder.age)/60, 0.7, 1.2), channel=VOLUME_CHANNEL_EMOTE)
				SPAWN(3 SECONDS)
					src.mob?.emote_allowed = 1
			return message
		else
			..()

	onDeath(gibbed)
		var/datum/abilityHolder/vampiric_thrall/abil = src.mob.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
		if (abil)
			if (abil.master)
				abil.master.remove_thrall(src.mob)
			else
				remove_mindhack_status(src.mob)
		..()

/datum/mutantrace/skeleton
	name = "skeleton"
	icon = 'icons/mob/skeleton.dmi'
	mutant_folder = 'icons/mob/skeleton.dmi'
	icon_state = "skeleton"
	voice_override = "skelly"
	mutant_organs = list("left_eye" = /obj/item/organ/eye/skeleton,
	"right_eye" = /obj/item/organ/eye/skeleton)
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS | WEARS_UNDERPANTS)
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/skeleton/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/skeleton/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/skeleton/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/skeleton/left
	special_head = HEAD_SKELETON
	decomposes = FALSE
	race_mutation = /datum/bioEffect/mutantrace/skeleton
	dna_mutagen_banned = FALSE
	var/obj/item/organ/head/head_tracker
	self_click_fluff = list("ribcage", "funny bone", "femur", "scapula")

	New(var/mob/living/carbon/human/M)
		..()
		if(ishuman(M))
			M.mob_flags |= IS_BONEY
			M.blood_id = "calcium"
			set_head(M.organHolder.head)

	disposing()
		if (ishuman(src.mob))
			src.mob.mob_flags &= ~IS_BONEY
			src.mob.blood_id = initial(src.mob.blood_id)
		. = ..()

	proc/set_head(var/obj/item/organ/head/head)
		// if the head was previous linked to someone else
		if (isskeleton(head.linked_human) && head.linked_human != src.mob)
			var/mob/living/carbon/human/H = head.linked_human
			var/datum/mutantrace/skeleton/S = H.mutantrace
			if (H.eye == head)
				H.set_eye(null)
			S.head_tracker = null
			boutput(H, "<span class='alert'><b>You feel as if your head has been repossessed by another!</b></span>")
		// if we were previously linked to another head
		if (src.head_tracker)
			src.head_tracker.UnregisterSignal(src.head_tracker.linked_human, COMSIG_CREATE_TYPING)
			src.head_tracker.UnregisterSignal(src.head_tracker.linked_human, COMSIG_REMOVE_TYPING)
			src.head_tracker.UnregisterSignal(src.head_tracker.linked_human, COMSIG_SPEECH_BUBBLE)
			src.head_tracker.linked_human = null
		head_tracker = head
		head_tracker.linked_human = src.mob

/obj/item/joint_wax
	name = "joint wax"
	desc = "Does what it says on the jar."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "wax"
	w_class = W_CLASS_SMALL
	var/uses = 10

	attack(mob/M, mob/user)
		if (isskeleton(M))
			var/mob/living/carbon/human/H = M
			if (user.zone_sel.selecting in H.limbs.vars)
				var/obj/item/parts/limb = H.limbs.vars[user.zone_sel.selecting]
				if (!limb)
					if (!src.uses)
						boutput(user, "<span class='alert'>The joint wax is empty!</alert>")
					else
						H.changeStatus("spry", 1 MINUTE)
						playsound(H, 'sound/effects/smear.ogg', 50, 1)
						H.visible_message("<span class='notice'>[user] applies some joint wax to [H].</notice>")
						src.uses--
						if (!src.uses)
							src.icon_state = "wax-empty"
					return
		..()

	get_desc()
		. += " It looks like it has [uses ? uses : "no"] applications left."

/*
/datum/mutantrace/ape
	name = "ape"
	icon_state = "ape"
*/

/datum/mutantrace/nostalgic
	name = "Homo nostalgius"
	icon_state = "oldhuman"
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_HUMAN_SKINTONE | HAS_NO_EYES | HAS_NO_HEAD | USES_STATIC_ICON)
	override_attack = 0


/datum/mutantrace/abomination
	name = "abomination"
	mutant_folder = 'icons/mob/abomination.dmi'
	icon = 'icons/mob/abomination.dmi'
	icon_state = "abomination"
	human_compatible = 0
	uses_human_clothes = 0
	jerk = TRUE
	brutevuln = 0.2
	override_attack = 0
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/right/abomination
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/left/abomination
	ignore_missing_limbs = 1 //OVERRIDE_ARM_L | OVERRIDE_ARM_R
	anchor_to_floor = 1
	movement_modifier = /datum/movement_modifier/abomination
	self_click_fluff = "disgusting writhing appendages"

	var/last_drain = 0
	var/drains_dna_on_life = 1
	var/ruff_tuff_and_ultrabuff = 1

	New(var/mob/living/carbon/human/M)
		if(ruff_tuff_and_ultrabuff && ishuman(M))
			M.add_stam_mod_max("abomination", 1000)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "abomination", 1000)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "abomination", 100)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "abomination", 100)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTSPRINT, src)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANT_BE_PINNED, src)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/grab_grabbed_by in M.grabbed_by)
					if (!istype(grab_grabbed_by, /obj/item/grab/block))
						qdel(grab_grabbed_by)
		last_drain = world.time
		return ..(M)

	disposing()
		if(src.mob)
			src.mob.remove_stam_mod_max("abomination")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STAMINA_REGEN_BONUS, "abomination")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STUN_RESIST, "abomination")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STUN_RESIST_MAX, "abomination")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_CANTSPRINT, src)
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_CANT_BE_PINNED, src)
		return ..()


	onLife(var/mult = 1)
		//Bringing it more in line with how it was before it got broken (in a hilarious fashion)
		if (ruff_tuff_and_ultrabuff && !(src.mob.getStatusDuration("burning") && prob(90))) //Are you a macho abomination or not?
			src.mob.delStatus("disorient")
			src.mob.delStatus("drowsy")
			src.mob.change_misstep_chance(-INFINITY)
			src.mob.delStatus("slowed")
			src.mob.stuttering = 0
			changeling_super_heal_step(src.mob, mult = mult)

		if (drains_dna_on_life) //Do you continuously lose DNA points when in this form?
			var/datum/abilityHolder/changeling/C = src.mob.get_ability_holder(/datum/abilityHolder/changeling)

			if(!C)
				src.mob.show_text("<I><B>You cannot hold this form!</B></I>", "red")
				src.mob.revert_from_horror_form()

			if (C?.points)
				if (last_drain + 30 <= world.time)
					C.points = max(0, C.points - (1 * mult))

				switch (C.points)
					if (-INFINITY to 0)
						src.mob.show_text("<I><B>We cannot hold this form!</B></I>", "red")
						src.mob.revert_from_horror_form()
					if (5)
						src.mob.show_text("<I><B>Our DNA stockpile is almost depleted!</B></I>", "red")
					if (10)
						src.mob.show_text("<I><B>We cannot maintain this form much longer!</B></I>", "red")
		return

	say_filter(var/message)
		return pick("We are one...", "Join with us...", "Sssssss...")

	say_verb()
		return "screeches"

	emote(var/act)
		var/message = null
		switch (act)
			if ("scream")
				if (src.mob.emote_allowed)
					src.mob.emote_allowed = 0
					message = "<span class='alert'><B>[src.mob] screeches!</B></span>"
					playsound(src.mob, 'sound/voice/creepyshriek.ogg', 60, 1, channel=VOLUME_CHANNEL_EMOTE)
					SPAWN(3 SECONDS)
						if (src.mob) src.mob.emote_allowed = 1
		return message

/datum/mutantrace/abomination/admin //This will not revert to human form
	drains_dna_on_life = 0

/datum/mutantrace/abomination/admin/weak //This also does not get any of the OnLife effects
	ruff_tuff_and_ultrabuff = 0

/datum/mutantrace/werewolf
	name = "werewolf"
	icon = 'icons/mob/werewolf.dmi'
	icon_state = "body_m"
	human_compatible = 0
	uses_human_clothes = 0
	var/original_name
	jerk = TRUE
	override_attack = 0
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/werewolf/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/werewolf/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/werewolf/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/werewolf/left
	ignore_missing_limbs = 1 // heck it, just regenerate your limbs, you shambling dogbomination
	var/old_client_color = null
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS)
	mutant_folder = 'icons/mob/werewolf.dmi'
	clothing_icon_back = 'icons/mob/werewolf/back.dmi'
	clothing_icon_mask = 'icons/mob/werewolf/mask.dmi'
	special_head = HEAD_WEREWOLF
	mutant_organs = list("tail" = /obj/item/organ/tail/wolf)
	self_click_fluff = "fur"
	can_walk_on_shards = TRUE

	head_offset = 5
	hand_offset = 3
	arm_offset = 3

	New()
		..()
		if (ishuman(src.mob))
			src.mob.AddComponent(/datum/component/consume/organheal)
			src.mob.AddComponent(/datum/component/consume/can_eat_inedible_organs, 1) // can also eat heads
			src.mob.mob_flags |= SHOULD_HAVE_A_TAIL
			src.mob.add_stam_mod_max("werewolf", 40) // Gave them a significant stamina boost, as they're melee-orientated (Convair880).
			APPLY_ATOM_PROPERTY(src.mob, PROP_MOB_STAMINA_REGEN_BONUS, "werewolf", 9) //mbc : these increase as they feast now. reduced!
			APPLY_ATOM_PROPERTY(src.mob, PROP_MOB_STUN_RESIST, "werewolf", 40)
			APPLY_ATOM_PROPERTY(src.mob, PROP_MOB_STUN_RESIST_MAX, "werewolf", 40)
			src.mob.max_health += 50
			health_update_queue |= src.mob
			src.original_name = src.mob.real_name
			src.mob.real_name = "werewolf"
			src.mob.UpdateName()

			src.mob.bioHolder.AddEffect("protanopia", null, null, 0, 1)
			src.mob.bioHolder.AddEffect("accent_scoob_nerf", null, null, 0, 1)
			src.mob.bioHolder.AddEffect("regenerator_wolf", null, null, 0, 1)

	disposing()
		if (ishuman(src.mob))
			var/datum/component/C = src.mob.GetComponent(/datum/component/consume/organheal)
			C?.RemoveComponent(/datum/component/consume/organheal)
			var/datum/component/D = src.mob.GetComponent(/datum/component/consume/can_eat_inedible_organs)
			D?.RemoveComponent(/datum/component/consume/can_eat_inedible_organs)
			src.mob.remove_stam_mod_max("werewolf")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STAMINA_REGEN_BONUS, "werewolf")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STUN_RESIST, "werewolf")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STUN_RESIST_MAX, "werewolf")
			src.mob.max_health -= 50
			health_update_queue |= src.mob
			src.mob.bioHolder.RemoveEffect("protanopia")
			src.mob.bioHolder.RemoveEffect("accent_scoob_nerf")
			src.mob.bioHolder.RemoveEffect("regenerator_wolf")

			if (!isnull(src.original_name))
				src.mob.real_name = src.original_name
				src.mob.UpdateName()

			src.mob.mob_flags &= ~SHOULD_HAVE_A_TAIL
		. = ..()

	sight_modifier()
		if (ishuman(src.mob))
			src.mob.sight |= SEE_MOBS
			src.mob.see_in_dark = SEE_DARK_FULL
			src.mob.see_invisible = INVIS_CLOAK
		return

	// Werewolves (being a melee-focused role) are quite buff.
	onLife(var/mult = 1)
		if (src.mob && ismob(mob))
			if (src.mob.hasStatus("drowsy"))
				src.mob.changeStatus("drowsy", -10 SECONDS)
			if (src.mob.misstep_chance)
				src.mob.change_misstep_chance(-10 * mult)
			if (src.mob.getStatusDuration("slowed"))
				src.mob.changeStatus("slowed", -2 SECONDS * mult)

		return

	say_verb()
		return "snarls"

	say_filter(var/message)
		return message

	emote(var/act)
		var/message = null
		switch(act)
			if("howl", "scream")
				if(src.mob.emote_allowed)
					src.mob.emote_allowed = 0
					message = "<span class='alert'><B>[src.mob] howls [pick("ominously", "eerily", "hauntingly", "proudly", "loudly")]!</B></span>"
					playsound(src.mob, 'sound/voice/animal/werewolf_howl.ogg', 65, 0, 0, clamp(1.0 + (30 - src.mob.bioHolder.age)/60, 0.7, 1.2), channel=VOLUME_CHANNEL_EMOTE)
					SPAWN(3 SECONDS)
						src.mob?.emote_allowed = 1
			if("burp")
				if(src.mob.emote_allowed)
					src.mob.emote_allowed = 0
					message = "<B>[src.mob]</B> belches."
					playsound(src.mob, 'sound/voice/burp_alien.ogg', 60, 1, channel=VOLUME_CHANNEL_EMOTE)
					SPAWN(1 SECOND)
						src.mob?.emote_allowed = 1
		return message

/datum/mutantrace/hunter
	name = "hunter"
	icon = 'icons/mob/hunter.dmi'
	icon_state = "full"
	human_compatible = 0
	jerk = TRUE
	override_attack = 0
	mutant_folder = 'icons/mob/hunter.dmi'
	special_head = HEAD_HUNTER //heh
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/hunter/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/hunter/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/hunter/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/hunter/left
	ignore_missing_limbs = 0
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS)

	// Gave them a minor stamina boost (Convair880).
	New(var/mob/living/carbon/human/M)
		. = ..()
		if(ishuman(M))
			M.add_stam_mod_max("hunter", 50)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "hunter", 10)

	disposing()
		if(ishuman(src.mob))
			src.mob.remove_stam_mod_max("hunter")
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_STAMINA_REGEN_BONUS, "hunter")
		return ..()

	sight_modifier()
		src.mob.see_in_dark = SEE_DARK_FULL
		return

	say_verb()
		return "snarls"


/datum/mutantrace/ithillid
	name = "ithillid"
	icon = 'icons/mob/ithillid.dmi'
	icon_state = "body_m"
	jerk = FALSE
	override_attack = 0
	aquatic = 1
	voice_override = "blub"
	mutant_folder = 'icons/mob/ithillid.dmi'
	special_head = HEAD_ITHILLID
	special_hair_1_icon = 'icons/mob/ithillid.dmi'
	special_hair_1_state = "head_detail_1"
	special_hair_1_color = null
	special_hair_1_layer = MOB_HAIR_LAYER1
	special_hair_1_layer_f = MOB_HAIR_LAYER1
	race_mutation = /datum/bioEffect/mutantrace/ithillid
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/ithillid/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/ithillid/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/ithillid/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/ithillid/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | BUILT_FROM_PIECES | HAS_SPECIAL_HAIR | HEAD_HAS_OWN_COLORS | WEARS_UNDERPANTS)
	dna_mutagen_banned = FALSE
	self_click_fluff = "gills"

	say_verb()
		return "glubs"

/datum/mutantrace/monkey
	name = "monkey"
	icon = 'icons/mob/monkey.dmi'
	mutant_folder = 'icons/mob/monkey.dmi'
	icon_state = "monkey"
	eye_state = "eyes_monkey"
	head_offset = -6
	hand_offset = -2
	body_offset = -7
	leg_offset = -4
	arm_offset = -8
	human_compatible = TRUE
	special_head = HEAD_MONKEY
	special_head_state = "head"
	exclusive_language = 1
	voice_message = "chimpers"
	voice_name = "monkey"
	override_language = "monkey"
	override_attack = FALSE
	understood_languages = list("english")
	clothing_icon_uniform = 'icons/mob/monkey/jumpsuits.dmi'
	clothing_icon_id = 'icons/mob/monkey/card.dmi'
	clothing_icon_hands = 'icons/mob/monkey/hands.dmi'
	clothing_icon_feet = 'icons/mob/monkey/feet.dmi'
	clothing_icon_overcoats = 'icons/mob/monkey/overcoats.dmi'
	clothing_icon_back = 'icons/mob/monkey/back.dmi'
	clothing_icon_eyes = 'icons/mob/monkey/eyes.dmi'
	clothing_icon_ears = 'icons/mob/monkey/ears.dmi'
	clothing_icon_mask = 'icons/mob/monkey/mask.dmi'
	clothing_icon_head = 'icons/mob/monkey/head.dmi'
	clothing_icon_belt = 'icons/mob/monkey/belt.dmi'
	race_mutation = /datum/bioEffect/mutantrace/monkey
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/monkey/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/monkey/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/monkey/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/monkey/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_HUMAN_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS)
	var/sound_monkeyscream = 'sound/voice/screams/monkey_scream.ogg'
	mutant_organs = list("tail" = /obj/item/organ/tail/monkey)
	dna_mutagen_banned = FALSE
	self_click_fluff = "fur"

	New(var/mob/living/carbon/human/M)
		. = ..()
		if(ishuman(M))
			M.add_stam_mod_max("monkey", -50)
			M.mob_flags |= SHOULD_HAVE_A_TAIL

	disposing()
		if (ishuman(src.mob))
			src.mob.remove_stam_mod_max("monkey")
			src.mob.mob_flags &= ~SHOULD_HAVE_A_TAIL
		. = ..()

	say_verb()
		return "chimpers"

	emote(var/act, var/voluntary)
		. = null
		var/muzzled = istype(src.mob.wear_mask, /obj/item/clothing/mask/muzzle)
		switch(act)
			if("scratch")
				if (!src.mob.restrained())
					. = "<B>[src.mob.name]</B> scratches."
			if("whimper")
				if (!muzzled)
					. = "<B>[src.mob.name]</B> whimpers."
			if("yawn")
				if (!muzzled)
					. = "<b>[src.mob.name]</B> yawns."
			if("roar")
				if (!muzzled)
					. = "<B>[src.mob.name]</B> roars."
			if("tail")
				. = "<B>[src.mob.name]</B> waves [his_or_her(src.mob)] tail."
			if("paw")
				if (!src.mob.restrained())
					. = "<B>[src.mob.name]</B> flails [his_or_her(src.mob)] paw."
			if("scretch")
				if (!muzzled)
					. = "<B>[src.mob.name]</B> scretches."
			if("sulk")
				. = "<B>[src.mob.name]</B> sulks down sadly."
			if("roll")
				if (!src.mob.restrained())
					. = "<B>[src.name]</B> rolls."
			if("gnarl")
				if (!muzzled)
					. = "<B>[src.mob]</B> gnarls and shows [his_or_her(src.mob)] teeth.."
			if("jump")
				. = "<B>[src.mob.name]</B> jumps!"
			if ("scream")
				if (src.mob.emote_check(voluntary, 50))
					. = "<B>[src.mob]</B> screams!"
					playsound(src.mob, src.sound_monkeyscream, 80, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			if ("fart")
				if(farting_allowed && (!src.mob.reagents || !src.mob.reagents.has_reagent("anti_fart")))
					if (!src.mob.emote_check(voluntary, 10))
						return
					var/fart_on_other = 0
					for(var/mob/living/M in src.mob.loc)
						if(M == src.mob || !M.lying)
							continue
						. = "<span class='alert'><B>[src.mob]</B> farts in [M]'s face!</span>"
						fart_on_other = 1
						break
					if(!fart_on_other)
						switch(rand(1, 27))
							if(1) . = "<B>[src.mob]</B> farts. It smells like... bananas. Huh."
							if(2) . = "<B>[src.mob]</B> goes apeshit! Or at least smells like it."
							if(3) . = "<B>[src.mob]</B> releases an unbelievably foul fart."
							if(4) . = "<B>[src.mob]</B> chimpers out of its ass."
							if(5) . = "<B>[src.mob]</B> farts and looks incredibly amused about it."
							if(6) . = "<B>[src.mob]</B> unleashes the king kong of farts!"
							if(7) . = "<B>[src.mob]</B> farts and does a silly little dance."
							if(8) . = "<B>[src.mob]</B> farts gloriously."
							if(9) . = "<B>[src.mob]</B> plays the song of its people. With farts."
							if(10) . = "<B>[src.mob]</B> screeches loudly and wildly flails its arms in a poor attempt to conceal a fart."
							if(11) . = "<B>[src.mob]</B> clenches and bares its teeth, but only manages a sad squeaky little fart."
							if(12) . = "<B>[src.mob]</B> unleashes a chain of farts by beating its chest."
							if(13) . = "<B>[src.mob]</B> farts so hard a bunch of fur flies off its ass."
							if(14) . = "<B>[src.mob]</B> does an impression of a baboon by farting until its ass turns red."
							if(15) . = "<B>[src.mob]</B> farts out a choking, hideous stench!"
							if(16) . = "<B>[src.mob]</B> reflects on its captive life aboard a space station, before farting and bursting into hysterial laughter."
							if(17) . = "<B>[src.mob]</B> farts megalomaniacally."
							if(18) . = "<B>[src.mob]</B> rips a floor-rattling fart. Damn."
							if(19) . = "<B>[src.mob]</B> farts. What a damn dirty ape!"
							if(20) . = "<B>[src.mob]</B> farts. It smells like a nuclear engine. Not that you know what that smells like."
							if(21) . = "<B>[src.mob]</B> performs a complex monkey divining ritual. By farting."
							if(22) . = "<B>[src.mob]</B> farts out the smell of the jungle. The jungle smells gross as hell apparently."
							if(23) . = "<B>[src.mob]</B> farts up a methane monsoon!"
							if(24) . = "<B>[src.mob]</B> unleashes an utterly rancid stink from its ass."
							if(25) . = "<B>[src.mob]</B> makes a big goofy grin and farts loudly."
							if(26) . = "<B>[src.mob]</B> hovers off the ground for a moment using a powerful fart."
							if(27) . = "<B>[src.mob]</B> plays drums on its ass while farting."
					playsound(src.mob.loc, 'sound/voice/farts/poo2.ogg', 80, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)

					src.mob.remove_stamina(STAMINA_DEFAULT_FART_COST)
					src.mob.stamina_stun()
	#ifdef DATALOGGER
					game_stats.Increment("farts")
	#endif
					src.mob.expel_fart_gas(0)
					src.mob.add_karma(0.5)


/datum/mutantrace/monkey/seamonkey
	name = "sea monkey"
	icon = 'icons/mob/monkey.dmi'
	mutant_folder = 'icons/mob/seamonkey.dmi'
	icon_state = "seamonkey"
	special_head = HEAD_SEAMONKEY
	special_head_state = "head"
	aquatic = 1
	race_mutation = /datum/bioEffect/mutantrace/seamonkey
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/seamonkey/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/seamonkey/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/seamonkey/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/seamonkey/left
	mutant_organs = list("tail" = /obj/item/organ/tail/monkey/seamonkey)

/datum/mutantrace/martian
	name = "martian"
	icon_state = "martian"
	human_compatible = 0
	uses_human_clothes = 0
	override_language = "martian"



/datum/mutantrace/stupidbaby
	name = "stupid alien baby"
	icon_state = "stupidbaby"
	human_compatible = 0
	uses_human_clothes = 0
	jerk = TRUE

	New()
		..()
		if(ishuman(src.mob))
			src.mob.real_name = pick("a", "ay", "ey", "eh", "e") + pick("li", "lee", "lhi", "ley", "ll") + pick("n", "m", "nn", "en")
			if(prob(50))
				src.mob.real_name = uppertext(src.mob.real_name)
			src.mob.bioHolder.AddEffect("clumsy")
			src.mob.take_brain_damage(80)
			src.mob.stuttering = 120
			src.mob.contract_disease(/datum/ailment/disability/clumsy,null,null,1)

/datum/mutantrace/premature_clone
	name = "premature clone"
	icon = 'icons/mob/human.dmi'
	mutant_folder = 'icons/mob/human.dmi'
	icon_state = "mutant3"
	human_compatible = 1
	uses_human_clothes = 1
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_HUMAN_SKINTONE | HAS_HUMAN_HAIR | HAS_HUMAN_EYES | HAS_NO_HEAD | USES_STATIC_ICON)
	dna_mutagen_banned = FALSE


	New()
		..()
		if(ishuman(src.mob))
			if (isitem(src.mob.l_hand))
				var/obj/item/toDrop = src.mob.l_hand
				src.mob.u_equip(toDrop)
				if (toDrop)
					toDrop.layer = initial(toDrop.layer)
					toDrop.set_loc(src.mob.loc)

			if (src.mob.limbs && src.mob.limbs.l_arm)
				src.mob.limbs.l_arm.delete()

	say_verb()
		return "gurgles"

	onDeath(gibbed)
		if(gibbed)
			return
		SPAWN(2 SECONDS)
			if (ishuman(src.mob))
				src.mob.visible_message("<span class='alert'><B>[src.mob]</B> starts convulsing violently!</span>", "You feel as if your body is tearing itself apart!")
				src.mob.changeStatus("weakened", 15 SECONDS)
				src.mob.make_jittery(1000)
				sleep(rand(40, 120))
				src.mob.gib()

// some new simple gimmick junk

/datum/mutantrace/gross
	name = "mutilated"
	icon_state = "gross"
	override_attack = 0


	say_verb()
		return "shrieks"

/datum/mutantrace/faceless
	name = "humanoid"
	icon_state = "faceless"
	override_attack = 0


	say_verb()
		return "murmurs"

/datum/mutantrace/cyclops
	name = "cyclops"
	icon_state = "cyclops"
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_HUMAN_HAIR | HAS_NO_EYES | HAS_NO_HEAD | WEARS_UNDERPANTS | USES_STATIC_ICON)


/datum/mutantrace/roach
	name = "roach"
	icon = 'icons/mob/roach.dmi'
	icon_state = "body_m"
	override_attack = 0
	voice_override = "roach"
	race_mutation = /datum/bioEffect/mutantrace/roach
	mutant_organs = list("tail" = /obj/item/organ/tail/roach)
	mutant_folder = 'icons/mob/roach.dmi'
	special_head = HEAD_ROACH
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/roach/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/roach/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/roach/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/roach/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_HUMAN_EYES | BUILT_FROM_PIECES | FIX_COLORS | HAS_SPECIAL_HAIR | TORSO_HAS_SKINTONE | WEARS_UNDERPANTS)
	eye_state = "eyes_roach"
	typevulns = list("blunt" = 1.5, "crush" = 1.5)
	dna_mutagen_banned = FALSE
	self_click_fluff = list("thorax", "exoskeleton", "antenna")

	New(mob/living/carbon/human/M)
		. = ..()
		if(ishuman(M))
			M.blood_id = "hemolymph"
			//H.blood_color = "#009E81"
			M.mob_flags |= SHOULD_HAVE_A_TAIL
		APPLY_ATOM_PROPERTY(M, PROP_MOB_RADPROT_INT, src, 100)



	say_verb()
		return "clicks"

	sight_modifier()
		src.mob.see_in_dark = SEE_DARK_HUMAN + 1
		src.mob.see_invisible = INVIS_INFRA

	disposing()
		if(ishuman(src.mob))
			src.mob.mob_flags &= ~SHOULD_HAVE_A_TAIL
			src.mob.blood_id = initial(src.mob.blood_id)
		if(src.mob)
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_RADPROT_INT, src)
		. = ..()

/datum/mutantrace/cat // we have the sprites so ~why not add them~? (I fully expect to get shit for this)
	name = "cat"
	icon = 'icons/mob/cat.dmi'
	icon_state = "body_m"
	jerk = TRUE
	override_attack = 0
	firevuln = 1.5 // very flammable catthings
	race_mutation = /datum/bioEffect/mutantrace/cat
	mutant_organs = list("tail" = /obj/item/organ/tail/cat)
	mutant_folder = 'icons/mob/cat.dmi'
	special_head = HEAD_CAT
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/cat/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/cat/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/cat/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/cat/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS | WEARS_UNDERPANTS)

	New(mob/living/carbon/human/M)
		. = ..()
		if(ishuman(M))
			M.mob_flags |= SHOULD_HAVE_A_TAIL

	say_verb()
		return "meows"

	sight_modifier()
		src.mob.see_in_dark = SEE_DARK_HUMAN + 1
		src.mob.see_invisible = INVIS_INFRA

	disposing()
		if(ishuman(src.mob))
			src.mob.mob_flags &= ~SHOULD_HAVE_A_TAIL
		. = ..()


/datum/mutantrace/amphibian
	name = "amphibian"
	icon = 'icons/mob/amphibian.dmi'
	icon_state = "body_m"
	firevuln = 1.3
	brutevuln = 0.7
	human_compatible = 0
	uses_human_clothes = 1
	aquatic = 1
	voice_name = "amphibian"
	jerk = FALSE
	head_offset = 0
	hand_offset = -3
	body_offset = -3
	movement_modifier = /datum/movement_modifier/amphibian
	var/original_blood_color = null
	mutant_folder = 'icons/mob/amphibian.dmi'
	special_head = HEAD_FROG
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/amphibian/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/amphibian/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/amphibian/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/amphibian/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS)


	say_verb()
		return "croaks"

	say_filter(var/message)
		return replacetext(message, "r", stutter("rrr"))


	New(var/mob/living/carbon/human/M)
		..()
		if(ishuman(src.mob))
			original_blood_color = src.mob.blood_color
			src.mob.blood_color = "#22EE99"
			M.bioHolder.AddEffect("mattereater")
			M.bioHolder.AddEffect("jumpy")
			M.bioHolder.AddEffect("vowelitis")
			M.bioHolder.AddEffect("accent_chav")


	disposing()
		if(ishuman(src.mob))
			if(!isnull(original_blood_color))
				src.mob.blood_color = original_blood_color
				src.mob.bioHolder.RemoveEffect("mattereater")
				src.mob.bioHolder.RemoveEffect("jumpy")
				src.mob.bioHolder.RemoveEffect("vowelitis")
				src.mob.bioHolder.RemoveEffect("accent_chav")
		original_blood_color = null
		..()

	emote(var/act)
		var/message = null
		switch (act)
			if ("scream","howl","laugh")
				if (src.mob.emote_allowed)
					src.mob.emote_allowed = 0
					message = "<span class='alert'><B>[src.mob] makes an awful noise!</B></span>"
					playsound(src.mob, pick('sound/voice/screams/frogscream1.ogg','sound/voice/screams/frogscream3.ogg','sound/voice/screams/frogscream4.ogg'), 60, 1, channel=VOLUME_CHANNEL_EMOTE)
					SPAWN(3 SECONDS)
						if (src.mob) src.mob.emote_allowed = 1
					return message

			if("burp","fart","gasp")
				if(src.mob.emote_allowed)
					src.mob.emote_allowed = 0
					message = "<B>[src.mob]</B> croaks."
					playsound(src.mob, 'sound/voice/farts/frogfart.ogg', 60, 1, channel=VOLUME_CHANNEL_EMOTE)
					SPAWN(1 SECOND)
						if (src.mob) src.mob.emote_allowed = 1
					return message
			else ..()

/datum/mutantrace/amphibian/shelter
	name = "Shelter Amphibian"
	icon = 'icons/mob/shelterfrog.dmi'
	icon_state = "body_m"
	human_compatible = 1
	jerk = FALSE
	var/permanent = 0
	mutant_folder = 'icons/mob/shelterfrog.dmi'
	special_head = HEAD_SHELTER
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/shelterfrog/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/shelterfrog/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/shelterfrog/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/shelterfrog/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_NO_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS)


	New()
		..()
		if(ishuman(src.mob))
			src.mob.blood_color = "#91b978"

	disposing()
		if(ishuman(src.mob))
			src.mob.bioHolder.RemoveEffect("mattereater")
			src.mob.bioHolder.RemoveEffect("jumpy")
			src.mob.bioHolder.RemoveEffect("vowelitis")
			src.mob.bioHolder.RemoveEffect("accent_chav")
		..()

/datum/mutantrace/kudzu
	name = "kudzu"
	icon = 'icons/mob/kudzu.dmi'
	icon_state = "kudzu-w"
	human_compatible = 0
	uses_human_clothes = 0
	var/original_name
	jerk = TRUE //Not really, but NT doesn't really like treehuggers
	aquatic = 1
	needs_oxy = 0 //get their nutrients from the kudzu
	understood_languages = list("english", "kudzu")
	movement_modifier = /datum/movement_modifier/kudzu
	genetics_removable = FALSE
	mutant_folder = 'icons/mob/human.dmi' // vOv
	mutant_organs = list(\
		"left_eye"=/obj/item/organ/eye/synth,\
		"right_eye"=/obj/item/organ/eye/synth,\
		"heart"=/obj/item/organ/heart/synth,\
		"appendix"=/obj/item/organ/appendix/synth,\
		"intestines"=/obj/item/organ/intestines/synth,\
		"left_kidney"=/obj/item/organ/kidney/synth/left,\
		"right_kidney"=/obj/item/organ/kidney/synth/right,\
		"liver"=/obj/item/organ/liver/synth,\
		"left_lung"=/obj/item/organ/lung/synth/left,\
		"right_lung"=/obj/item/organ/lung/synth/right,\
		"pancreas"=/obj/item/organ/pancreas/synth,\
		"spleen"=/obj/item/organ/spleen/synth,\
		"stomach"=/obj/item/organ/stomach/synth,\
		"butt"=/obj/item/clothing/head/butt/synth) //dont be mean to the kudzupeople
	special_hair_1_icon = 'icons/mob/kudzu.dmi'
	special_hair_1_state = "kudzu_hair"
	special_hair_1_color = null
	detail_1_icon = 'icons/mob/kudzu.dmi'
	detail_1_state = "kudzu_torso"
	detail_1_color = null
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/kudzu/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/kudzu/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/kudzu/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/kudzu/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_HUMAN_SKINTONE | TORSO_HAS_SKINTONE | HAS_HUMAN_HAIR | HAS_HUMAN_EYES | HAS_SPECIAL_HAIR | HAS_EXTRA_DETAILS | BUILT_FROM_PIECES)
	override_attack = 1

	custom_attack(atom/target)
		if(ishuman(target))
			src.mob.visible_message("<span class='alert'><B>[src.mob]</B> waves its limbs at [target] threateningly!</span>")
			return TRUE
		return FALSE

	say_verb()
		return "rasps"

	New(var/mob/living/carbon/human/H)
		..(H)
		SPAWN(0)	//ugh
			if(ishuman(src.mob))
				H.setStatus("maxhealth-", null, -50)
				H.add_stam_mod_max("kudzu", -100)
				APPLY_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "kudzu", -5)
				H.bioHolder.AddEffect("xray", power = 2, magical=1)
				H.abilityHolder = new /datum/abilityHolder/kudzu(H)
				H.abilityHolder.owner = H
				H.abilityHolder.addAbility(/datum/targetable/kudzu/guide)
				H.abilityHolder.addAbility(/datum/targetable/kudzu/growth)
				H.abilityHolder.addAbility(/datum/targetable/kudzu/seed)
				H.abilityHolder.addAbility(/datum/targetable/kudzu/heal_other)
				H.abilityHolder.addAbility(/datum/targetable/kudzu/stealth)
				H.abilityHolder.addAbility(/datum/targetable/kudzu/kudzusay)
				H.abilityHolder.addAbility(/datum/targetable/kudzu/vine_appendage)


	disposing()
		if(ishuman(src.mob))
			var/mob/living/carbon/human/H = src.mob
			if(H.abilityHolder)
				H.abilityHolder.removeAbility(/datum/targetable/kudzu/guide)
				H.abilityHolder.removeAbility(/datum/targetable/kudzu/growth)
				H.abilityHolder.removeAbility(/datum/targetable/kudzu/seed)
				H.abilityHolder.removeAbility(/datum/targetable/kudzu/heal_other)
				H.abilityHolder.removeAbility(/datum/targetable/kudzu/stealth)
				H.abilityHolder.removeAbility(/datum/targetable/kudzu/kudzusay)
				H.abilityHolder.removeAbility(/datum/targetable/kudzu/vine_appendage)
			H.remove_stam_mod_max("kudzu")
			REMOVE_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "kudzu")
		return ..()
/* Commented out as this bypasses restricted Z checks. We will just lazily give them xray genes instead
	// vision modifier (see_mobs, etc i guess)
	sight_modifier()
		src.mob.sight |= SEE_TURFS
		src.mob.sight |= SEE_MOBS
		src.mob.sight |= SEE_OBJS
		src.mob.see_in_dark = SEE_DARK_FULL
*/
	//Should figure out what I'm doing with this and the onLife in the abilityHolder one day. I'm thinking, maybe move it all to the abilityholder, but idk, composites are weird.
	onLife(var/mult = 1)
		if (!src.mob.abilityHolder)
			src.mob.abilityHolder = new /datum/abilityHolder/kudzu(src.mob)

		var/datum/abilityHolder/kudzu/KAH = src.mob.abilityHolder
		var/round_mult = max(1, round((mult)))
		var/turf/T = get_turf(src.mob)
		//if on kudzu, get nutrients for later use. If at max nutrients. Then heal self.
		if (T && T.temp_flags & HAS_KUDZU)
			if (KAH.points < KAH.MAX_POINTS)
				KAH.points += round_mult
			else
				//at max points, so heal
				src.mob.take_toxin_damage(-round_mult)
				src.mob.HealDamage("All", round_mult, round_mult)
				if (prob(7) && src.mob.find_ailment_by_type(/datum/ailment/malady/flatline))
					src.mob.cure_disease_by_path(/datum/ailment/malady/heartfailure)
					src.mob.cure_disease_by_path(/datum/ailment/malady/flatline)

		else
			//nutrients for a bit of grace period
			if (KAH.points > 0)
				KAH.points -= 10
			else
				//do effects from not being on kudzu here.
				src.mob.take_toxin_damage(2 * round_mult)
				src.mob.changeStatus("slowed", 3 SECONDS)
				// random_brute_damage(src.mob, 2 * mult)
				if (prob(30))
					src.mob.changeStatus("weakened", 3 SECONDS)

		return

/datum/mutantrace/cow
	name = "cow"
	icon = 'icons/mob/cow.dmi'
	icon_state = "body_m"
	human_compatible = TRUE
	uses_human_clothes = FALSE
	override_attack = 0
	voice_override = "cow"
	step_override = "footstep"
	race_mutation = /datum/bioEffect/mutantrace/cow
	mutant_organs = list("tail" = /obj/item/organ/tail/cow,
	"left_eye" = /obj/item/organ/eye/cow,
	"right_eye" = /obj/item/organ/eye/cow)
	mutant_folder = 'icons/mob/cow.dmi'
	special_head = HEAD_COW
	special_hair_1_icon = 'icons/mob/cow.dmi'
	special_hair_1_state = "head-detail1"
	special_hair_1_color = CUST_1
	special_hair_2_icon = 'icons/mob/cow.dmi'
	special_hair_2_state = "cow_over_suit"
	special_hair_2_color = null
	special_hair_2_layer = MOB_OVERMASK_LAYER
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/cow/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/cow/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/cow/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/cow/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_HUMAN_EYES | BUILT_FROM_PIECES | HAS_EXTRA_DETAILS | HAS_OVERSUIT_DETAILS | HAS_SPECIAL_HAIR | HEAD_HAS_OWN_COLORS | WEARS_UNDERPANTS)
	color_channel_names = list("Horn Detail", "Hoof Detail")
	eye_state = "eyes-cow"
	dna_mutagen_banned = FALSE
	can_walk_on_shards = TRUE
	self_click_fluff = list("fur", "hooves", "horns")

	New(var/mob/living/carbon/human/H)
		..()
		if(ishuman(src.mob))
			src.mob.update_face()
			src.mob.update_body()
			src.mob.update_clothing()
			src.mob.mob_flags |= SHOULD_HAVE_A_TAIL
			src.mob.kickMessage = "stomps"
			src.mob.traitHolder?.addTrait("hemophilia")

			H.blood_id = "milk"
			H.blood_color = "FFFFFF"


	disposing()
		if (ishuman(src.mob))
			var/mob/living/carbon/human/H = src.mob
			H.blood_id = initial(H.blood_id)
			H.blood_color = initial(H.blood_color)
			if (H.mob_flags & SHOULD_HAVE_A_TAIL)
				H.mob_flags &= ~SHOULD_HAVE_A_TAIL
			H.kickMessage = initial(H.kickMessage)
			H.traitHolder?.removeTrait("hemophilia")
		. = ..()

	say_filter(var/message)
		.= replacetext(message, "cow", "human")
		var/replace_lowercase = replacetextEx(., "m", stutter("mm"))
		var/replace_uppercase = replacetextEx(replace_lowercase, "M", stutter("MM"))
		return replace_uppercase

	emote(var/act, var/voluntary)
		switch(act)
			if ("scream")
				if (src.mob.emote_check(voluntary, 50))
					. = "<B>[src.mob]</B> moos!"
					playsound(src.mob, 'sound/voice/screams/moo.ogg', 50, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
			if ("milk")
				if (src.mob.emote_check(voluntary))
					.= release_milk()
			else
				.= ..()

	proc/release_milk() //copy pasted some piss code, im sorry
		var/obj/item/storage/toilet/toilet = locate() in src.mob.loc
		var/obj/item/reagent_containers/glass/beaker = locate() in src.mob.loc

		var/can_output = 0
		if (ishuman(src.mob))
			var/mob/living/carbon/human/H = src.mob
			if (H.blood_volume > 0)
				can_output = 1

		if (!can_output)
			.= "<B>[src.mob]</B> strains, but fails to output milk!"
		else if (toilet && (src.mob.buckled != null))
			for (var/obj/item/storage/toilet/T in src.mob.loc)
				.= "<B>[src.mob]</B> dispenses milk into the toilet. What a waste."
				T.clogged += 0.1
				break
		else if (beaker)
			.= pick("<B>[src.mob]</B> takes aim and dispenses some milk into the beaker.", "<B>[src.mob]</B> takes aim and dispenses milk into the beaker!", "<B>[src.mob]</B> fills the beaker with milk!")
			transfer_blood(src.mob, beaker, 10)
		else
			var/obj/item/reagent_containers/milk_target = src.mob.equipped()
			if(istype(milk_target) && milk_target.reagents && milk_target.reagents.total_volume < milk_target.reagents.maximum_volume && milk_target.is_open_container())
				.= ("<span class='alert'><B>[src.mob] dispenses milk into [milk_target].</B></span>")
				playsound(src.mob, 'sound/misc/pourdrink.ogg', 50, 1)
				transfer_blood(src.mob, milk_target, 10)
				return

			// possibly change the text colour to the gray emote text
			.= (pick("<B>[src.mob]</B> milk fall out.", "<B>[src.mob]</B> makes a milk puddle on the floor."))

			var/turf/T = get_turf(src.mob)
			bleed(src.mob, 10, 3, T)
			T.react_all_cleanables()

TYPEINFO(/datum/mutantrace/pug)
	special_styles = list("apricot" = 'icons/mob/pug/apricot.dmi',
	"black" = 'icons/mob/pug/black.dmi',
	"chocolate" = 'icons/mob/pug/chocolate.dmi',
	"fawn" = 'icons/mob/pug/fawn.dmi')
/datum/mutantrace/pug
	name = "pug"
	icon = 'icons/mob/pug/fawn.dmi'
	icon_state = "body_m"
	human_compatible = TRUE
	override_attack = 0
	voice_override = "pug"
	step_override = "footstep"
	race_mutation = /datum/bioEffect/mutantrace/pug
	mutant_organs = list("tail" = /obj/item/organ/tail/pug,
	"left_eye" = /obj/item/organ/eye/pug,
	"right_eye" = /obj/item/organ/eye/pug)
	mutant_folder = 'icons/mob/pug/fawn.dmi'
	special_head = HEAD_PUG
	r_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/pug/right
	l_limb_arm_type_mutantrace = /obj/item/parts/human_parts/arm/mutant/pug/left
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/pug/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/pug/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_NO_SKINTONE | HAS_HUMAN_EYES | WEARS_UNDERPANTS | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS)
	eye_state = "eyes-pug"
	dna_mutagen_banned = FALSE
	var/static/image/snore_bubble = image('icons/mob/mob.dmi', "bubble")
	self_click_fluff = "fur"

	New(var/mob/living/carbon/human/H)
		if (prob(1)) // need to modify flags before calling parent
			mutant_appearance_flags &= ~HAS_NO_SKINTONE
			mutant_appearance_flags |= (TORSO_HAS_SKINTONE | HAS_PARTIAL_SKINTONE)
		..()
		if (ishuman(src.mob))
			src.mob.mob_flags |= SHOULD_HAVE_A_TAIL
			SPAWN(0)
				if(src.mob) //how??
					APPLY_ATOM_PROPERTY(src.mob, PROP_MOB_FAILED_SPRINT_FLOP, src)
		if (prob(50))
			voice_override = "pugg"
		RegisterSignal(src.mob, COMSIG_MOB_THROW_ITEM_NEARBY, .proc/throw_response)

	disposing()
		if (ishuman(src.mob))
			if (src.mob.mob_flags & SHOULD_HAVE_A_TAIL)
				src.mob.mob_flags &= ~SHOULD_HAVE_A_TAIL
			REMOVE_ATOM_PROPERTY(src.mob, PROP_MOB_FAILED_SPRINT_FLOP, src)
		UnregisterSignal(src.mob, COMSIG_MOB_THROW_ITEM_NEARBY)
		..()

	say_verb()
		return "barks"

	say_filter(var/message)
		. = replacetext(message, "rough", "ruff")
		. = replacetext(., "pog", "pug")

	emote(var/act, var/voluntary)
		switch(act)
			if ("sleuth")
				if (src.mob.emote_check(voluntary, 5 SECONDS))
					. = src.sleuth()
			if ("scream")
				if (src.mob.emote_check(voluntary, 5 SECONDS))
					playsound(src.mob, "sound/voice/screams/[voice_override].ogg", 50, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
					. = list("<B>[src.mob]</B> growls!", "<I>growls</I>")
			if ("sneeze")
				if (src.mob.emote_check(voluntary, 2 SECONDS))
					. = src.sneeze()
			if ("sniff")
				if (src.mob.emote_check(voluntary, 2 SECONDS))
					. = src.sniff()
			if ("snore")
				if (src.mob.emote_check(voluntary, 3 SECONDS))
					. = src.snore()
			if ("wheeze")
				if (src.mob.emote_check(voluntary, 2 SECONDS))
					playsound(src.mob, 'sound/voice/pug_wheeze.ogg', 80, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
					. = list("<B>[src.mob]</B> wheezes.", "<I>wheezes</I>")
			else
				. = ..()

	proc/sleuth()
		if (src.mob.hasStatus("poisoned"))
			boutput(src.mob, "<span class='alert'>You're sick and definitely aren't up for sleuthing!</span>")
			return
		var/atom/A = tgui_input_list(src.mob, "What would you like to sleuth?", "Sleuthing", src.mob.get_targets(1, "both"), 20 SECONDS)
		if (!A)
			return
		playsound(src.mob, 'sound/voice/pug_sniff.ogg', 50, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		var/adjective = pick("astutely", "discerningly", "intently")
		. = list("<B>[src.mob]</B> sniffs [adjective].", "<I>sniffs [adjective]</I>")
		if (ismob(A))
			var/mob/living/M = A
			if (M.mind)
				boutput(src.mob, "<span class='notice'>[M] smells like a [M.mind?.color].</span>")
				return
		var/list/L = A.fingerprints_full
		if (!length(L))
			boutput(src.mob, "<span class='notice'>Smells like \a [A], alright.</span>")
			return
		var/list/print = L[pick(L)]
		var/color = print["color"]
		if (!color)
			boutput(src.mob, "<span class='notice'>Smells like \a [A], alright.</span>")
			return
		var/timestamp = print["timestamp"]
		var/intensity = "faintly"
		if (TIME < timestamp + 3 MINUTES)
			intensity = "strongly"
		else if (TIME < timestamp + 10 MINUTES)
			intensity = "kind"
		boutput(src.mob, "<span class='notice'>\The [A] smells [intensity] of a [color].</span>")

	proc/sneeze()
		playsound(src.mob, 'sound/voice/pug_sneeze.ogg', 50, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		. = list("<B>[src.mob]</B> sneezes.", "<I>sneezes</I>")
		animate(src.mob, pixel_y=3, time=0.1 SECONDS, flags=ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(pixel_y=-6, time=0.2 SECONDS, flags=ANIMATION_RELATIVE)
		animate(pixel_y=3, time=0.1 SECONDS, flags=ANIMATION_RELATIVE)

	proc/sniff()
		playsound(src.mob, 'sound/voice/pug_sniff.ogg', 50, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		. = list("<B>[src.mob]</B> sniffs.", "<I>sniffs</I>")

	proc/snore()
		playsound(src.mob, 'sound/voice/snore.ogg', rand(5,10) * 10, 0, 0, src.mob.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
		. = list("<B>[src.mob]</B> snores.", "<I>snores</I>")
		src.mob.UpdateOverlays(snore_bubble, "snore_bubble")
		SPAWN(1.5 SECONDS)
			src.mob.UpdateOverlays(null, "snore_bubble")

	proc/throw_response(target, item, thrower)
		// Don't dive at things we throw; don't dive if we're stunned or dead; dive 15% of the time, 100% at limbs
		if (src.mob == thrower || is_incapacitated(src.mob) || (prob(85) && !istype(item, /obj/item/parts)))
			return
		src.mob.throw_at(get_turf(item), 1, 1)
		src.mob.visible_message("<span class='alert'>[src.mob] staggers.</span>")
		src.mob.emote("scream")

/datum/mutantrace/chicken
	name = "Chicken"
	icon_state = "chicken_m"
	human_compatible = 1
	jerk = FALSE
	race_mutation = /datum/bioEffect/mutantrace/chicken
	mutant_folder = 'icons/mob/chicken.dmi'
	special_head = HEAD_CHICKEN
	r_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/chicken/right
	l_limb_leg_type_mutantrace = /obj/item/parts/human_parts/leg/mutant/chicken/left
	mutant_appearance_flags = (NOT_DIMORPHIC | HAS_PARTIAL_SKINTONE | HAS_NO_EYES | BUILT_FROM_PIECES | HEAD_HAS_OWN_COLORS | TORSO_HAS_SKINTONE | WEARS_UNDERPANTS)

	emote(var/act, var/voluntary)
		switch(act)
			if ("scream")
				if (src.mob.emote_check(voluntary, 50))
					. = "<B>[src.mob]</B> BWAHCAWCKs!"
					playsound(src.mob, 'sound/voice/screams/chicken_bawk.ogg', 50, 0, 0, src.mob.get_age_pitch())

#undef OVERRIDE_ARM_L
#undef OVERRIDE_ARM_R
#undef OVERRIDE_LEG_R
#undef OVERRIDE_LEG_L
