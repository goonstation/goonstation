var/list/bioUids = new/list() //Global list of all uids and their respective mobs

var/numbersAndLetters = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q",
"r", "s", "t", "u", "v", "w", "x", "y", "z" , "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
var/list/datum/bioEffect/bioEffectList = list()
var/list/datum/bioEffect/mutini_effects = list()

/proc/addBio()
	var/mob/M = input(usr, "Select Mob:") as mob in world
	if(!istype(M)) return
	//if(hasvar(M, "bioHolder"))
	var/id = input(usr, "Effect ID:")
	M.bioHolder.AddEffect(id)
	return

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

	/// What DMI holds the mob's hair sprites
	var/customization_icon = 'icons/mob/human_hair.dmi'

	/// The color that gets used for determining your colors
	var/customization_first_color = "#101010"
	/// The color that was set by the player's preferences
	var/customization_first_color_original = "#101010"
	/// The hair style / detail thing that gets displayed on your spaceperson
	var/datum/customization_style/customization_first = new /datum/customization_style/hair/short/short
	/// The hair style / detail thing that was set by the player in their settings
	var/customization_first_original = "None"
	/// The Y offset to display this image
	var/customization_first_offset_y = 0

	var/customization_second_color = "#101010"
	var/customization_second_color_original = "#101010"
	var/datum/customization_style/customization_second =  new /datum/customization_style/none
	var/customization_second_original = "None"
	var/customization_second_offset_y = 0

	var/customization_third_color = "#101010"
	var/customization_third_color_original = "#101010"
	var/datum/customization_style/customization_third = new /datum/customization_style/none
	var/customization_third_original = "None"
	var/customization_third_offset_y = 0

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
								 "fart5" = 'sound/voice/farts/fart5.ogg')

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

	proc/CopyOther(var/datum/appearanceHolder/toCopy)
		//Copies settings of another given holder. Used for the bioholder copy proc and such things.
		mob_appearance_flags = toCopy.mob_appearance_flags

		body_icon = toCopy.body_icon
		body_icon_state = toCopy.body_icon_state

		CopyOtherHeadAppearance(toCopy)

		mob_detail_1_icon = toCopy.mob_detail_1_icon
		mob_detail_1_state = toCopy.mob_detail_1_state
		mob_detail_1_color_ref = toCopy.mob_detail_1_color_ref
		mob_detail_1_offset_y = toCopy.mob_detail_1_offset_y

		mob_oversuit_1_icon = toCopy.mob_oversuit_1_icon
		mob_oversuit_1_state = toCopy.mob_oversuit_1_state
		mob_oversuit_1_color_ref = toCopy.mob_oversuit_1_color_ref
		mob_oversuit_1_offset_y = toCopy.mob_oversuit_1_offset_y

		mutant_race = toCopy.mutant_race

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
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.update_colorful_parts()
		return src

	proc/CopyOtherHeadAppearance(var/datum/appearanceHolder/toCopy)
		head_icon = toCopy.head_icon
		head_icon_state = toCopy.head_icon_state

		customization_icon = toCopy.customization_icon

		customization_first_color_original = toCopy.customization_first_color_original
		customization_first_color = toCopy.customization_first_color
		customization_first = toCopy.customization_first
		customization_first_offset_y = toCopy.customization_first_offset_y
		customization_first_original = toCopy.customization_first_original

		customization_second_color_original = toCopy.customization_second_color_original
		customization_second_color = toCopy.customization_second_color
		customization_second = toCopy.customization_second
		customization_second_offset_y = toCopy.customization_second_offset_y
		customization_second_original = toCopy.customization_second_original

		customization_third_color_original = toCopy.customization_third_color_original
		customization_third_color = toCopy.customization_third_color
		customization_third = toCopy.customization_third
		customization_third_offset_y = toCopy.customization_third_offset_y
		customization_third_original = toCopy.customization_third_original

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

	disposing()
		owner = null
		if(src.parentHolder)
			if(src.parentHolder.mobAppearance == src)
				src.parentHolder.mobAppearance = null
			src.parentHolder = null
		..()

	// Disabling this for now as I have no idea how to fit it into hex strings
	// I'm help -Spy
	proc/StaggeredCopyOther(var/datum/appearanceHolder/toCopy, var/progress = 1)
		var/adjust_denominator = 11 - progress

		customization_first_color = StaggeredCopyHex(customization_first_color, toCopy.customization_first_color, adjust_denominator)

		if (progress >= 9 || prob(progress * 10))
			customization_first = toCopy.customization_first
			customization_second = toCopy.customization_second
			customization_third = toCopy.customization_third

		customization_second_color = StaggeredCopyHex(customization_second_color, toCopy.customization_second_color, adjust_denominator)
		customization_third_color = StaggeredCopyHex(customization_third_color, toCopy.customization_third_color, adjust_denominator)
		e_color = StaggeredCopyHex(e_color, toCopy.e_color, adjust_denominator)

		s_tone = StaggeredCopyHex(s_tone, toCopy.s_tone, adjust_denominator)

		if (progress > 7 || prob(progress * 10))
			gender = toCopy.gender
			pronouns = toCopy.pronouns
			special_style = toCopy.special_style
			mutant_race = toCopy.mutant_race

		if(progress >= 10) //Finalize the copying here, with anything we may have missed.
			src.CopyOther(toCopy)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.update_colorful_parts()
		return

	proc/StaggeredCopyHex(var/hex, var/targetHex, var/adjust_denominator)

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

			if (H.mutantrace && H.mutantrace.voice_override)
				H.voice_type = H.mutantrace.voice_override

			H.update_name_tag()
		// if the owner's not human I don't think this would do anything anyway so fuck it
		return

/datum/bioHolder
	//Holds the appearanceholder aswell as the effects. Controls adding and removing of effects.
	var/list/effects = new/list()
	var/list/effectPool = new/list()

	var/mob/owner = null
	var/ownerName = null

	var/bloodType = "AB+-"
	var/bloodColor = null
	var/age = 30
	var/genetic_stability = 100
	var/clone_generation = 0 //Get this high enough and you can be like Arnold. Maybe. I found that movie fun. Don't judge me.

	var/datum/appearanceHolder/mobAppearance = null


	var/Uid = "not initialized" //Unique id for the mob. Used for fingerprints and whatnot.
	var/uid_hash
	var/fingerprints

	New(var/mob/owneri)
		owner = owneri
		Uid = CreateUid()
		bioUids[Uid] = null
		build_fingerprints()
		mobAppearance = new/datum/appearanceHolder()

		mobAppearance.owner = owner
		mobAppearance.parentHolder = src

		SPAWN(2 SECONDS) // fuck this shit
			if(owner)
				ownerName = owner.real_name
				bioUids[Uid] = owner?.real_name ? owner.real_name : owner?.name

		BuildEffectPool()
		return ..()

	proc/build_fingerprints()
		uid_hash = md5(Uid)
		var/fprint_base = uppertext(md5_to_more_pronouncable(uid_hash))
		var/list/fprint_parts = list()
		for(var/i in 1 to length(fprint_base) step 6)
			if(i + 6 <= length(fprint_base) + 1)
				fprint_parts += copytext(fprint_base, i, i + 6)
		fingerprints = jointext(fprint_parts, "-")

	disposing()
		for(var/D in effects)
			var/datum/bioEffect/BE = effects[D]
			qdel(BE)
			BE?.owner = null
		for(var/D in effectPool)
			var/datum/bioEffect/BE = effectPool[D]
			qdel(BE)
			BE?.owner = null

		if(src.mobAppearance)
			src.mobAppearance.dispose()
			src.mobAppearance = null

		src.owner = null

		effects.len = 0
		effectPool.len = 0
		effects = null
		effectPool = null

		if (mobAppearance)
			mobAppearance.owner = null
			mobAppearance = null

		..()

	proc/ActivatePoolEffect(var/datum/bioEffect/E, var/overrideDNA = 0, var/grant_research = 1)
		if(!E || !effectPool[E.id] || (!E.dnaBlocks.sequenceCorrect() && !overrideDNA) || HasEffect(E.id))
			return 0

		var/datum/bioEffect/global_BE = E.get_global_instance()
		if (grant_research)
			if (global_BE.research_level < EFFECT_RESEARCH_DONE)
				genResearch.mutations_researched++
			global_BE.research_level = max(global_BE.research_level, EFFECT_RESEARCH_ACTIVATED)

		//AddEffect(E.id)
		//effectPool.Remove(E)
		// changed this to transfer the instance across rather than add a copy
		// since some bioeffects have unique stuff
		effects[E.id] = E
		effectPool.Remove(E.id)
		E.owner = owner
		E.holder = src
		E.activated_from_pool = 1
		E.OnAdd()
		if(length(E.msgGain) > 0)
			if (E.isBad)
				boutput(owner, "<span class='alert'>[E.msgGain]</span>")
			else
				boutput(owner, "<span class='notice'>[E.msgGain]</span>")

		mobAppearance.UpdateMob()
		return E

	proc/AddNewPoolEffect(var/idToAdd)
		if(HasEffect(idToAdd) || HasEffectInPool(idToAdd))
			return 0

		var/datum/bioEffect/newEffect = bioEffectList[idToAdd]
		newEffect = newEffect.GetCopy()
		if (istype(newEffect))
			effectPool[newEffect.id] = newEffect
			newEffect.holder = src
			newEffect.owner = src.owner
			return 1

		return 0

	proc/AddRandomNewPoolEffect()
		var/list/filteredList = list()

		if (!bioEffectList || !length(bioEffectList))
			logTheThing(LOG_DEBUG, null, {"<b>Genetics:</b> Tried to add new random effect to pool for
			 [owner ? "\ref[owner] [owner.name]" : "*NULL*"], but bioEffectList is empty!"})
			return 0

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(!instance || HasEffect(T) || HasEffectInPool(T) || !instance.occur_in_genepools)
				continue

			filteredList.Add(instance)
			filteredList[instance] = instance.probability

		if(!filteredList.len)
			logTheThing(LOG_DEBUG, null, {"<b>Genetics:</b> Unable to get effects for new random effect for
			 [owner ? "\ref[owner] [owner.name]" : "*NULL*"]. (filteredList.len = [filteredList.len])"})
			return 0

		var/datum/bioEffect/selectedG = weighted_pick(filteredList)
		var/datum/bioEffect/selectedNew = selectedG.GetCopy()
		selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
		selectedNew.holder = src
		selectedNew.owner = src.owner
		effectPool[selectedNew.id] = selectedNew
		return 1

	proc/RemovePoolEffect(var/datum/bioEffect/E)
		if(!effectPool[E.id]) return 0
		effectPool.Remove(E.id)
		return 1

	proc/BuildEffectPool()
		var/list/filteredGood = new/list()
		var/list/filteredBad = new/list()
		var/list/filteredSecret = new/list()

		for(var/datum/bioEffect/BE in effectPool)
			qdel(BE)
		effectPool.Cut()

		if (!bioEffectList || !length(bioEffectList))
			logTheThing(LOG_DEBUG, null, {"<b>Genetics:</b> Tried to build effect pool for
			 [owner ? "\ref[owner] [owner.name]" : "*NULL*"], but bioEffectList is empty!"})

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(!instance || HasEffect(T) || !instance.occur_in_genepools) continue
			if(src.owner)
				if (src.owner.type in instance.mob_exclusion)
					continue
				if (instance.mob_exclusive && src.owner.type != instance.mob_exclusive)
					continue
			if(instance.secret)
				filteredSecret[instance] = instance.probability
			else
				if(instance.isBad)
					filteredBad[instance] = instance.probability
				else
					filteredGood[instance] = instance.probability

		if(!filteredGood.len || !length(filteredBad))
			logTheThing(LOG_DEBUG, null, {"<b>Genetics:</b> Unable to build effect pool for
			 [owner ? "\ref[owner] [owner.name]" : "*NULL*"]. (filteredGood.len = [filteredGood.len],
			  filteredBad.len = [filteredBad.len])"})
			return

		for(var/g=0, g<5, g++)
			var/datum/bioEffect/selectedG = weighted_pick(filteredGood)
			if(selectedG)
				var/datum/bioEffect/selectedNew = selectedG.GetCopy()
				selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
				selectedNew.holder = src
				selectedNew.owner = src.owner
				effectPool[selectedNew.id] = selectedNew
				filteredGood.Remove(selectedG)
			else
				break

		for(var/b=0, b<5, b++)
			var/datum/bioEffect/selectedB = weighted_pick(filteredBad)
			if(selectedB)
				var/datum/bioEffect/selectedNew = selectedB.GetCopy()
				selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
				selectedNew.holder = src
				selectedNew.owner = src.owner
				effectPool[selectedNew.id] = selectedNew
				filteredBad.Remove(selectedB)
			else
				break

		if (filteredSecret.len)
			var/datum/bioEffect/selectedS = weighted_pick(filteredSecret)
			var/datum/bioEffect/selectedNew = selectedS.GetCopy()
			selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
			selectedNew.holder = src
			selectedNew.owner = src.owner
			effectPool[selectedNew.id] = selectedNew
			filteredBad.Remove(selectedS)

		shuffle_list(effectPool)

	proc/OnLife(var/mult)
		var/datum/bioEffect/BE
		for(var/curr in effects)
			BE = effects[curr]
			if (BE)
				BE.OnLife(mult)
				if(BE.timeLeft != -1)
					BE.timeLeft -= 1*mult
					if(BE.timeLeft <= 0)
						if(BE.degrade_after && BE.degrade_to)
							AddEffect(BE.degrade_to, do_stability = 0)
						RemoveEffect(BE.id)
		return

	proc/OnMobDraw()
		var/datum/bioEffect/BE
		for(var/curr in effects)
			BE = effects[curr]
			if (BE) //Wire: Fix for: Cannot execute null.OnMobDraw()
				BE.OnMobDraw()
		return

	proc/CreateUid() //Creates a new uid and returns it.
		var/newUid = ""

		do
			for(var/i = 1 to 20)
				newUid += "[pick(numbersAndLetters)]"
		while(newUid in bioUids)

		return newUid

	proc/CopyOther(var/datum/bioHolder/toCopy, var/copyAppearance = 1, var/copyPool = 1, var/copyEffectBlocks = 0, var/copyActiveEffects = 1)
		//Copies the settings of another given holder. Used for syringes, the dna spread virus and such things.
		if(copyAppearance)
			mobAppearance.CopyOther(toCopy.mobAppearance)
			mobAppearance.UpdateMob()

			age = toCopy.age
			bloodType = toCopy.bloodType
			bloodColor = toCopy.bloodColor
			clone_generation = toCopy.clone_generation
			ownerName = toCopy.ownerName
			Uid = toCopy.Uid
			uid_hash = md5(Uid)
			build_fingerprints()

		if (copyPool)
			src.RemoveAllPoolEffects()
			for (var/id in toCopy.effectPool)
				AddNewPoolEffect(id)

		if(copyActiveEffects)
			src.RemoveAllEffects()
			var/datum/bioEffect/BE
			for(var/curr in toCopy.effects)
				BE = toCopy.effects[curr]
				if (!BE.can_copy)
					continue

				if(HasEffect(BE.id))
					var/datum/bioEffect/newCopy = GetEffect(BE.id)
					if(!newCopy) continue

					newCopy.timeLeft = BE.timeLeft
					var/oldpower = newCopy.power
					newCopy.power = BE.power
					newCopy.onPowerChange(oldpower, newCopy.power)
					newCopy.data = BE.data
				else
					var/datum/bioEffect/newCopy = AddEffect(BE.id, power = BE.power)
					if(!newCopy) continue

					newCopy.timeLeft = BE.timeLeft
					newCopy.data = BE.data
		return

	proc/StaggeredCopyOther(var/datum/bioHolder/toCopy, progress = 1)
		if (progress > 10)
			src.CopyOther(toCopy)
			return

		if (mobAppearance)
			mobAppearance.StaggeredCopyOther(toCopy.mobAppearance, progress)
			mobAppearance.UpdateMob()

		if (progress >= 5)
			bloodType = toCopy.bloodType

		age += (toCopy.age - age) / (11 - progress)

	proc/AddEffect(var/idToAdd, var/power = 0, var/timeleft = 0, var/do_stability = 1, var/magical = 0)
		//Adds an effect to this holder. Returns the newly created effect if succesful else 0.

		if(HasEffect(idToAdd))
			return 0

		var/datum/bioEffect/newEffect = bioEffectList[idToAdd]
		if(!newEffect) return 0

		newEffect = new newEffect.type

		if(istype(newEffect))
			if(newEffect.effect_group)
				for(var/datum/bioEffect/curr_id as anything in effects)
					var/datum/bioEffect/curr = effects[curr_id]
					if(curr.effect_group == newEffect.effect_group)
						RemoveEffect(curr.id)
						break

			if(power) newEffect.power = power
			if(timeleft) newEffect.timeLeft = timeleft
			if(magical)
				newEffect.curable_by_mutadone = 0
				newEffect.stability_loss = 0
				newEffect.can_scramble = 0
				newEffect.can_reclaim = 0
				newEffect.degrade_to = null
				newEffect.can_copy = 0

			effects[newEffect.id] = newEffect
			newEffect.owner = owner
			newEffect.holder = src
			if(owner)
				newEffect.OnAdd()
			if (do_stability)
				src.genetic_stability -= newEffect.stability_loss
				src.genetic_stability = max(0,src.genetic_stability)
				if(newEffect.degrade_to && !prob(lerp(clamp(src.genetic_stability, 0, 100), 100, 0.5)))
					newEffect.timeLeft = rand(20, 60)
					newEffect.degrade_after = TRUE
			if(owner && length(newEffect.msgGain) > 0)
				if (newEffect.isBad)
					boutput(owner, "<span class='alert'>[newEffect.msgGain]</span>")
				else
					boutput(owner, "<span class='notice'>[newEffect.msgGain]</span>")
			mobAppearance.UpdateMob()
			logTheThing(LOG_COMBAT, owner, "gains the [newEffect] mutation at [log_loc(owner)].")
			return newEffect

		return 0

	proc/AddEffectInstance(var/datum/bioEffect/BE,var/do_delay = 0,var/do_stability = 1)
		if (!istype(BE) || !owner || HasEffect(BE.id))
			return null

		if (do_delay && BE.add_delay > 0)
			sleep(BE.add_delay)

		src.AddEffectInstanceNoDelay(BE, do_stability)

	proc/AddEffectInstanceNoDelay(var/datum/bioEffect/BE,var/do_stability = 1)
		if (!istype(BE) || !owner || HasEffect(BE.id))
			return null

		if(BE.effect_group)
			for(var/datum/bioEffect/curr_id as anything in effects)
				var/datum/bioEffect/curr = effects[curr_id]
				if(curr.effect_group == BE.effect_group)
					RemoveEffect(curr.id)
					break

		effects[BE.id] = BE
		BE.owner = owner
		BE.holder = src
		BE.OnAdd()

		if (do_stability)
			src.genetic_stability -= BE.stability_loss
			src.genetic_stability = max(0,src.genetic_stability)

			if(BE.degrade_to && !prob(lerp(clamp(src.genetic_stability, 0, 100), 100, 0.5)))
				BE.timeLeft = rand(20, 60)
				BE.degrade_after = TRUE

		if(length(BE.msgGain) > 0)
			if (BE.isBad)
				boutput(owner, "<span class='alert'>[BE.msgGain]</span>")
			else
				boutput(owner, "<span class='notice'>[BE.msgGain]</span>")
		mobAppearance.UpdateMob()
		logTheThing(LOG_COMBAT, owner, "gains the [BE] mutation at [log_loc(owner)].")
		return BE

	proc/RemoveEffect(var/id)
		//Removes an effect from this holder. Returns 1 on success else 0.
		if (src.disposed)
			return 0
		if (!HasEffect(id))
			return 0

		var/datum/bioEffect/D = effects[id]
		if (D)
			D.OnRemove()
			if (!D.activated_from_pool)
				src.genetic_stability += D.stability_loss
				src.genetic_stability = max(0,src.genetic_stability)
			D.activated_from_pool = 0 //Fix for bug causing infinitely exploitable stability gain / loss

			if (owner && length(D.msgLose) > 0)
				if (D.isBad)
					boutput(owner, "<span class='notice'>[D.msgLose]</span>")
				else
					boutput(owner, "<span class='alert'>[D.msgLose]</span>")
			if (mobAppearance)
				mobAppearance.UpdateMob()
			logTheThing(LOG_COMBAT, owner, "loses the [D] mutation at [log_loc(owner)].")
			return effects.Remove(D.id)

		return 0

	proc/RemoveAllEffects(var/type = null)
		for(var/D as anything in effects)
			var/datum/bioEffect/BE = effects[D]
			if(BE && (isnull(type) || BE.effectType == type))
				RemoveEffect(BE.id)
				BE.owner = null
				BE.holder = null
				if(istype(BE, /datum/bioEffect/power))
					var/datum/bioEffect/power/BEP = BE
					BEP?.ability.owner = null
				//qdel(BE)
		return 1

	proc/RemoveAllPoolEffects(var/type = null)
		for(var/D as anything in effectPool)
			var/datum/bioEffect/BE = effectPool[D]
			if(BE && (isnull(type) || BE.effectType == type))
				effectPool.Remove(D)
				BE.owner = null
				BE.holder = null
				if(istype(BE, /datum/bioEffect/power))
					var/datum/bioEffect/power/BEP = BE
					BEP?.ability.owner = null
				//qdel(BE)
		return 1

	proc/HasAnyEffect(var/type = null)
		if(type)
			for(var/D as anything in effects)
				var/datum/bioEffect/BE = effects[D]
				if(BE && BE.effectType == type)
					return 1
		else
			return (effects.len ? 1 : 0)
		return 0

	proc/HasEffect(var/id)
		//Returns effect power if this holder has an effect with the given ID else 0.
		var/datum/bioEffect/B = effects[id]

		if(!B)
			.= 0
		else
			.= B.power

	proc/HasEffectInPool(var/id)
		return !isnull(effectPool[id])

	proc/HasEffectInEither(var/id)
		var/datum/bioEffect/B = effects[id]
		if(!B)
			B = effectPool[id]
		if (!B)
			return null
		else
			return 1

	proc/HasOneOfTheseEffects() //HasAnyEffect() was already taken :I
		var/list/temp = args & effects
		if(temp.len)
			var/datum/bioEffect/BE = effects[temp[1]]
			if(BE) return BE.power
		return 0

	proc/HasAllOfTheseEffects()
		var/tally = 0 //We cannot edit the args list directly, so just keep a count.
		for (var/datum/bioEffect/D as anything in effects)
			if (lowertext(D) in args)
				tally++

		return tally >= length(args)

	proc/GetASubtypeEffect(type)
		for(var/id as anything in effects)
			var/datum/bioEffect/BE = effects[id]
			if(istype(BE, type))
				return BE
		return null

	proc/GetEffect(var/id) //Returns the effect with the given ID if it exists else returns null.
		return effects[id]

	proc/GetEffectFromPool(var/id)
		return effectPool[id]

	proc/RandomEffect(var/type = "either", var/useProbability = 1, var/datum/dna_chromosome/toApply)
		//Adds a random effect to this holder. Argument controls which type. bad , good, either.
		var/list/filtered = new/list()

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(!instance || HasEffect(instance.id) || !instance.occur_in_genepools) continue
			switch(lowertext(type))
				if("good")
					if(instance.isBad)
						continue
				if("bad")
					if(!instance.isBad)
						continue
			filtered.Add(instance)
			filtered[instance] = instance.probability

		if(!filtered.len) return

		var/datum/bioEffect/E = null

		if(useProbability)
			E = weighted_pick(filtered)
		else
			E = pick(filtered)

		if (istype(toApply))
			toApply.apply(E)
			AddEffectInstance(E)
		else
			AddEffect(E.id)

		return E.id

	proc/DegradeRandomEffect()
		var/list/eligible_effects = list()
		var/datum/bioEffect/BE = null
		for (var/X as anything in effects)
			BE = effects[X]
			if (!BE.degrade_to) // doesn't turn into anything
				continue
			eligible_effects += BE

		if (!eligible_effects.len)
			// nothing to do
			return

		BE = pick(eligible_effects)
		AddEffect(BE.degrade_to, do_stability = 0)
		RemoveEffect(BE.id)

proc/GetBioeffectFromGlobalListByID(var/id)
	return bioEffectList[id]

proc/GetBioeffectResearchLevelFromGlobalListByID(var/id)
	if (!istext(id))
		return 0
	var/datum/bioEffect/BE = bioEffectList[id]

	if(istype(BE))
		. = BE.research_level
	else
		. = 0
