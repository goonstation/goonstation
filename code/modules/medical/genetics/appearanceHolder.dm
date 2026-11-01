/// Holds all the appearance information.
/datum/appearanceHolder
	/** Mob Appearance Flags - used to modify how the mob is drawn
	*
	* These flags help define what features get drawn when the mob's sprite is assembled
	*
	* For instance, WEARS_UNDERPANTS tells UpdateIcon.dm to draw the mob's underpants
	*
	* SEE: appearance.dm for more flags and details!
	*/
	var/mob_appearance_flags = HUMAN_APPEARANCE_FLAGS

	/// tells update_body() which DMI to use for rendering the chest/groin, torso-details, and oversuit tails
	var/body_icon = 'icons/mob/human.dmi'
	/// for mutant races that are rendered using a static icon. Ignored if BUILT_FROM_PIECES is set in mob_appearance_flags
	var/body_icon_state = "skeleton"
	/// What DMI holds the mob's head sprite
	var/head_icon = 'icons/mob/human_head.dmi'
	/// What icon state is our mob's head?
	var/head_icon_state = "head"

	// It's probably smarter to have customizations in an associative list for later - Glamurio
	var/list/datum/customizationHolder/customizations = list(
		"hair_bottom" = new /datum/customizationHolder/first,
		"hair_middle" = new /datum/customizationHolder/second,
		"hair_top" = new /datum/customizationHolder/third,
	)

	/// Currently changes which sprite sheet is used
	var/special_style

	/// Intended for extra head features that may or may not be hair
	var/special_hair_1_icon = 'icons/mob/human_hair.dmi'
	var/special_hair_1_state = "none"
	/// Which of the three customization colors to use (CUST_1, CUST_2, CUST_3)
	var/special_hair_1_color_ref = CUST_1
	var/special_hair_1_layer = MOB_HAIR_LAYER2
	var/special_hair_1_offset_y = 0
	var/special_hair_2_icon = 'icons/mob/human_hair.dmi'
	var/special_hair_2_state = "none"
	var/special_hair_2_color_ref = CUST_2
	var/special_hair_2_layer = MOB_HAIR_LAYER2
	var/special_hair_2_offset_y = 0
	var/special_hair_3_icon = 'icons/mob/human_hair.dmi'
	var/special_hair_3_state = "none"
	var/special_hair_3_color_ref = CUST_3
	var/special_hair_3_layer = MOB_HAIR_LAYER2
	var/special_hair_3_offset_y = 0

	/// Intended for extra, non-head body features that may or may not be hair (just not on their head)
	/// An image to be overlaid on the mob just above their skin
	var/mob_detail_1_icon = 'icons/mob/human_hair.dmi'
	var/mob_detail_1_state = "none"
	/// Which of the three customization colors to use (CUST_1, CUST_2, CUST_3)
	var/mob_detail_1_color_ref = CUST_1
	var/mob_detail_1_offset_y = 0

	/// An image to be overlaid on the mob between their outer-suit and backpack
	/// Not to be used to define a tail oversuit, that's done by the tail organ.
	/// This is for things like the cow having a muzzle that shows up over their outer-suit
	var/mob_oversuit_1_icon = 'icons/mob/human_hair.dmi'
	var/mob_oversuit_1_state = "none"
	/// Which of the three customization colors to use (CUST_1, CUST_2, CUST_3)
	var/mob_oversuit_1_color_ref = CUST_1
	var/mob_oversuit_1_offset_y = 0

	/// Used by changelings to determine which type of limbs their victim had
	var/datum/mutantrace/mutant_race = null
	/// The last mutant race that the owner of this appearance holder possessed that was not mutagen banned.
	var/datum/mutantrace/original_mutant_race = null

	var/e_color = "#101010"
	var/e_color_original = "#101010"
	/// Eye icon
	var/e_icon = 'icons/mob/human_hair.dmi'
	/// Eye icon state
	var/e_state = "eyes"
	/// How far up or down to move the eyes
	var/e_offset_y = 0

	var/s_tone_original = "#FFCC99"
	var/s_tone = "#FFCC99"

	var/mob_head_offset = 0
	var/mob_hand_offset = 0
	var/mob_body_offset = 0
	var/mob_arm_offset = 0
	var/mob_leg_offset = 0

	// Standard tone reference:
	// FAD7D0 - Albino
	// FFCC99 - White
	// CEAB69 - Olive
	// BD8A57 - Tan
	// 935D37 - Black
	// 483728 - Dark
	// -----------------
	// AA962D - Hunter
	// 158202 - Hulk
	// C5CFA9 - Zombie
	// B0AC96 - Drained Husk

	var/underwear = "No Underwear"
	var/u_color = "#FFFFFF"

	var/mob/owner = null
	var/datum/bioHolder/parentHolder = null

	var/gender = MALE
	var/datum/pronouns/pronouns
	var/screamsound = "male"
	var/fartsound = "default"
	var/voicetype = "1"
	var/flavor_text = null

	var/list/fartsounds = list("default" = 'sound/voice/farts/poo2.ogg', \
								 "fart1" = 'sound/voice/farts/fart1.ogg', \
								 "fart2" = 'sound/voice/farts/fart2.ogg', \
								 "fart3" = 'sound/voice/farts/fart3.ogg', \
								 "fart4" = 'sound/voice/farts/fart4.ogg', \
								 "fart5" = 'sound/voice/farts/fart5.ogg', \
								 "fart6" = 'sound/voice/farts/fart7.ogg')

	var/list/screamsounds = list("male" = 'sound/voice/screams/male_scream.ogg',\
								 "female" = 'sound/voice/screams/female_scream.ogg', \
								  "femalescream1" = 'sound/voice/screams/fescream1.ogg', \
								  "femalescream2" = 'sound/voice/screams/fescream2.ogg', \
								  "femalescream3" = 'sound/voice/screams/fescream3.ogg', \
								  "femalescream4" = 'sound/voice/screams/fescream4.ogg', \
								  "femalescream5" = 'sound/voice/screams/fescream5.ogg', \
								  "malescream4" = 'sound/voice/screams/mascream4.ogg', \
								  "malescream5" = 'sound/voice/screams/mascream5.ogg', \
								  "malescream6" = 'sound/voice/screams/mascream6.ogg', \
								  "malescream7" = 'sound/voice/screams/mascream7.ogg' )

	var/list/voicetypes = list("One" = "1","Two" = "2","Three" = "3","Four" = "4")

	New()
		..()
		voicetype = RANDOM_HUMAN_VOICE

	disposing()
		owner = null
		if(src.parentHolder)
			if(src.parentHolder.mobAppearance == src)
				src.parentHolder.mobAppearance = null
			src.parentHolder = null
		src.mutant_race = null
		src.original_mutant_race = null
		src.customizations = null
		..()

	proc/CopyOther(var/datum/appearanceHolder/toCopy, skip_update_colorful = FALSE)
		//Copies settings of another given holder. Used for the bioholder copy proc and such things.
		mob_appearance_flags = toCopy.mob_appearance_flags

		body_icon = toCopy.body_icon
		body_icon_state = toCopy.body_icon_state

		CopyOtherHeadAppearance(toCopy)
		CopyOtherCustomizationAppearance(toCopy)

		mob_detail_1_icon = toCopy.mob_detail_1_icon
		mob_detail_1_state = toCopy.mob_detail_1_state
		mob_detail_1_color_ref = toCopy.mob_detail_1_color_ref
		mob_detail_1_offset_y = toCopy.mob_detail_1_offset_y

		mob_oversuit_1_icon = toCopy.mob_oversuit_1_icon
		mob_oversuit_1_state = toCopy.mob_oversuit_1_state
		mob_oversuit_1_color_ref = toCopy.mob_oversuit_1_color_ref
		mob_oversuit_1_offset_y = toCopy.mob_oversuit_1_offset_y

		mutant_race = toCopy.mutant_race
		original_mutant_race = toCopy.original_mutant_race

		e_color = toCopy.e_color
		e_icon = toCopy.e_icon
		e_state = toCopy.e_state
		e_offset_y = toCopy.e_offset_y
		e_color_original = toCopy.e_color_original

		s_tone = toCopy.s_tone
		s_tone_original = toCopy.s_tone_original

		special_style = toCopy.special_style

		underwear = toCopy.underwear
		u_color = toCopy.u_color

		mob_head_offset = toCopy.mob_head_offset
		mob_hand_offset = toCopy.mob_hand_offset
		mob_body_offset = toCopy.mob_body_offset
		mob_arm_offset = toCopy.mob_arm_offset
		mob_leg_offset = toCopy.mob_leg_offset

		gender = toCopy.gender
		pronouns = toCopy.pronouns

		screamsound = toCopy.screamsound
		fartsound = toCopy.fartsound
		voicetype = toCopy.voicetype

		flavor_text = toCopy.flavor_text
		if(ishuman(owner) && !skip_update_colorful)
			var/mob/living/carbon/human/H = owner
			H.update_colorful_parts()
		return src

	proc/CopyOtherHeadAppearance(var/datum/appearanceHolder/toCopy)
		head_icon = toCopy.head_icon
		head_icon_state = toCopy.head_icon_state

		special_hair_1_icon = toCopy.special_hair_1_icon
		special_hair_1_state = toCopy.special_hair_1_state
		special_hair_1_color_ref = toCopy.special_hair_1_color_ref
		special_hair_1_offset_y = toCopy.special_hair_1_offset_y

		special_hair_2_icon = toCopy.special_hair_2_icon
		special_hair_2_state = toCopy.special_hair_2_state
		special_hair_2_color_ref = toCopy.special_hair_2_color_ref
		special_hair_2_offset_y = toCopy.special_hair_2_offset_y

		special_hair_3_icon = toCopy.special_hair_3_icon
		special_hair_3_state = toCopy.special_hair_3_state
		special_hair_3_color_ref = toCopy.special_hair_3_color_ref
		special_hair_3_offset_y = toCopy.special_hair_3_offset_y

	proc/CopyOtherCustomizationAppearance(var/datum/appearanceHolder/toCopy)
		for(var/holder in src.customizations)
			var/datum/customizationHolder/custom = src.customizations[holder]
			var/datum/customizationHolder/customCopy = toCopy.customizations[holder]
			custom.color_original = customCopy.color_original
			custom.color = customCopy.color
			custom.style_original = customCopy.style_original
			custom.style = customCopy.style
			custom.offset_y = customCopy.offset_y

	// Disabling this for now as I have no idea how to fit it into hex strings
	// I'm help -Spy
	// I might have messed this up when introducting customizationHolders - Glamurio
	proc/StaggeredCopyOther(var/datum/appearanceHolder/toCopy, var/progress = 1)
		var/adjust_denominator = 11 - progress

		e_color = StaggeredCopyHex(e_color, toCopy.e_color, adjust_denominator)
		s_tone = StaggeredCopyHex(s_tone, toCopy.s_tone, adjust_denominator)

		if (progress > 7 || prob(progress * 10))
			gender = toCopy.gender
			pronouns = toCopy.pronouns
			special_style = toCopy.special_style
			mutant_race = toCopy.mutant_race
			original_mutant_race = toCopy.original_mutant_race

		if (progress >= 9 || prob(progress * 10))

			for(var/holder in src.customizations)
				if (!src.CanCopyCustomization(toCopy))
					continue
				var/datum/customizationHolder/custom = src.customizations[holder]
				var/datum/customizationHolder/customCopy = toCopy.customizations[holder]

				custom.color = StaggeredCopyHex(custom.color, customCopy.color, adjust_denominator)
				custom.style = customCopy.style

		if(progress >= 10) //Finalize the copying here, with anything we may have missed.
			src.CopyOther(toCopy)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.update_colorful_parts()
		return

	proc/CanCopyCustomization(var/datum/appearanceHolder/toCopy)
		if (!length(src.customizations) > 0 || !length(toCopy.customizations) > 0)
			logTheThing(LOG_DEBUG, null, {"<b>Customizations:</b> Tried to copy customization [!length(src.customizations) > 0 ? "from" : "to"]
			 [toCopy.owner ? "\ref[toCopy.owner] [toCopy.owner.name]" : "*NULL*"] to [src.owner ? "\ref[src.owner] [src.owner.name]" : "*NULL*"],
			but the holder we are copying [!length(src.customizations) > 0 ? "to" : "from"] has no customizations!"})
			return FALSE
		return TRUE

	proc/UpdateMob() //Rebuild the appearance of the mob from the settings in this holder.
		if (ishuman(owner))

			var/mob/living/carbon/human/H = owner	// hair is handled by the head, applied by update_face

			H.gender = src.gender

			H.update_face() // wont get called if they dont have a head. probably wont do anything anyway, but best to be safe
			H.update_body()
			H.update_clothing()

			H.sound_scream = screamsounds[screamsound || "male"] || screamsounds["male"]
			H.sound_fart = fartsounds[fartsound || "default"] || fartsounds["default"]
			H.voice_type = voicetype || RANDOM_HUMAN_VOICE

			if (H.mutantrace?.voice_override)
				H.voice_type = H.mutantrace.voice_override

			H.update_name_tag()
		// if the owner's not human I don't think this would do anything anyway so fuck it
		return

/proc/StaggeredCopyHex(var/hex, var/targetHex, var/adjust_denominator)

	adjust_denominator = clamp(adjust_denominator, 1, 10)

	. = "#"
	for(var/i = 0, i < 3, i++)
		//Isolate the RGB values
		var/color = copytext(hex, 2 + (2 * i), 4 + (2 * i))
		var/targetColor = copytext(targetHex, 2 + (2 * i), 4 + (2 * i))

		//Turn them into numbers
		color = hex2num(color)
		targetColor = hex2num(targetColor)

		//Do the math and add to the output
		. += num2hex(color + ((targetColor - color) / adjust_denominator), 0)
