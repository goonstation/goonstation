/datum/bioEffect/glowy
	name = "Glowy"
	desc = "Endows the subject with bioluminescent skin. Color and intensity may vary by subject."
	id = "glowy"
	probability = 99
	effectType = EFFECT_TYPE_POWER
	blockCount = 3
	blockGaps = 1
	msgGain = "Your skin begins to glow softly."
	msgLose = "Your glow fades away."

	OnAdd()
		..()
		owner.add_sm_light("glowy", list(rand(25,255), rand(25,255), rand(25,255), 150))

	OnRemove()
		..()
		owner.add_sm_light("glowy", list(rand(25,255), rand(25,255), rand(25,255), 150))

/datum/bioEffect/horns
	name = "Cranial Keratin Formation"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	id = "horns"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	msgGain = "A pair of horns erupt from your head."
	msgLose = "Your horns crumble away into nothing."

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "horns", layer = MOB_LAYER)
		..()

/datum/bioEffect/horns/evil //this is just for /proc/soulcheck
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	id = "demon_horns"

/datum/bioEffect/particles
	name = "Dermal Glitter"
	desc = "Causes the subject's skin to shine and gleam."
	id = "shiny"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	msgGain = "Your skin looks all blinged out."
	msgLose = "Your skin fades to a more normal state."
	var/system_path = /datum/particleSystem/sparkles

	OnAdd()
		if (!particleMaster.CheckSystemExists(system_path, owner))
			particleMaster.SpawnSystem(new system_path(owner))

	OnRemove()
		if (!particleMaster.CheckSystemExists(system_path, owner))
			particleMaster.RemoveSystem(system_path, owner)

/datum/bioEffect/color_changer
	name = "Melanin Suppressor"
	desc = "Shuts down all melanin production in the subject's body."
	id = "albinism"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	isBad = 1
	var/eye_color_to_use = "#FF0000"
	var/color_to_use = "#FFFFFF"
	var/skintone_to_use = "#FFFFFF"
	var/holder_eyes = null
	var/holder_hair = null
	var/holder_det1 = null
	var/holder_det2 = null
	var/holder_skin = null

	OnAdd()
		if (!ishuman(owner))
			return

		var/mob/living/carbon/human/H = owner
		if (!H.bioHolder)
			return
		var/datum/bioHolder/B = H.bioHolder
		if (!B.mobAppearance)
			return
		var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
		holder_eyes = AH.e_color
		holder_hair = AH.customization_first_color
		holder_det1 = AH.customization_second_color
		holder_det2 = AH.customization_third_color
		holder_skin = AH.s_tone
		AH.e_color = eye_color_to_use
		AH.s_tone = skintone_to_use
		AH.customization_first_color = color_to_use
		AH.customization_second_color = color_to_use
		AH.customization_third_color = color_to_use
		H.update_face()
		H.update_body()

	OnRemove()
		if (!ishuman(owner))
			return

		var/mob/living/carbon/human/H = owner
		if (!H.bioHolder)
			return
		var/datum/bioHolder/B = H.bioHolder
		if (!B.mobAppearance)
			return
		var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
		AH.e_color = holder_eyes
		AH.s_tone = holder_skin
		AH.customization_first_color = holder_hair
		AH.customization_second_color = holder_det1
		AH.customization_third_color = holder_det2
		H.update_face()
		H.update_body()

/datum/bioEffect/color_changer/black
	name = "Melanin Stimulator"
	desc = "Overstimulates the subject's melanin glands."
	id = "melanism"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	isBad = 1
	eye_color_to_use = "#572E0B"
	color_to_use = "#000000"
	skintone_to_use = "#000000"

/datum/bioEffect/stinky
	name = "Apocrine Enhancement"
	desc = "Increases the amount of natural body substances produced from the subject's apocrine glands."
	id = "stinky"
	probability = 99
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel sweaty."
	msgLose = "You feel much more hygenic."
	var/personalized_stink = "Wow, it stinks in here!"

	New()
		..()
		src.personalized_stink = stinkString()
		if (prob(5))
			src.variant = 2

	OnLife()
		if(..()) return
		if (owner.reagents.has_reagent("menthol"))
			return
		else if (prob(10))
			for(var/mob/living/carbon/C in view(6,get_turf(owner)))
				if (C == owner)
					continue
				if (src.variant == 2)
					boutput(C, "<span class='alert'>[src.personalized_stink]</span>")
				else
					boutput(C, "<span class='alert'>[stinkString()]</span>")

/datum/bioEffect/drunk
	name = "Ethanol Production"
	desc = "Encourages growth of ethanol-producing symbiotic fungus in the subject's body."
	id = "drunk"
	isBad = 1
	msgGain = "You feel drunk!"
	msgLose = "You feel sober."
	probability = 99
	var/reagent_to_add = "ethanol"
	var/reagent_threshold = 80
	var/add_per_tick = 1

	OnLife()
		if(..()) return
		var/mob/living/L = owner
		if (isdead(L))
			return
		if (L.reagents && L.reagents.get_reagent_amount(reagent_to_add) < reagent_threshold)
			L.reagents.add_reagent(reagent_to_add,add_per_tick)

/datum/bioEffect/drunk/bee
	name = "Bee Production"
	desc = "Encourages growth of bees in the subject's body."
	id = "drunk_bee"
	isBad = 0
	msgGain = "Your stomach buzzes!"
	msgLose = "The buzzing in your stomach stops."
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	reagent_to_add = "bee"
	reagent_threshold = 40
	add_per_tick = 1.2

/datum/bioEffect/drunk/pentetic
	name = "Pentetic Acid Production"
	desc = "This mutation somehow causes the subject's body to manufacture a potent chellating agent. How exactly it functions is completely unknown."
	id = "drunk_pentetic"
	msgGain = "You feel detoxified."
	msgLose = "You feel toxic."
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	reagent_to_add = "penteticacid"
	reagent_threshold = 40
	add_per_tick = 4

/datum/bioEffect/drunk/random
	name = "Chemical Production Modification"
	desc = {"This mutation somehow irreversibly alters the subject's body to function as an organic chemical factory, mass producing large quantities of seemingly random chemicals. The mechanism for this modification is currently unknown to medical and genetic science."}
	id = "drunk_random"
	msgGain = "You begin to sense an odd chemical taste in your mouth."
	msgLose = "The chemical taste in your mouth fades."
	occur_in_genepools = 1 //this is going to be very goddamn rare and very fucking difficult to unlock.
	mob_exclusive = /mob/living/carbon/human/
	probability = 1
	blockCount = 5
	can_research = 0
	lockProb = 100
	blockGaps = 0
	lockedGaps = 10
	lockedDiff = 6
	lockedChars = list("G","C","A","T","U")
	lockedTries = 10
	curable_by_mutadone = 0
	can_scramble = 0
	can_reclaim = 0
	reagent_to_add = "honey"
	reagent_threshold = 500 //it never stops
	add_per_tick = 5 //even more difficult to remove without calomel or hunchback

	New()
		..()
		if (all_functional_reagent_ids.len > 1)
			reagent_to_add = pick(all_functional_reagent_ids - list("big_bang_precursor", "big_bang", "nitrotri_parent", "nitrotri_wet", "nitrotri_dry"))
		else
			reagent_to_add = "water"

/datum/bioEffect/drunk/random/unstable
	name = "Unstable Chemical Production Modification"
	desc = {"This mutation somehow irreversibly alters the subject's body to function as an organic chemical factory, mass producing large quantities of seemingly random chemicals. The mechanism for this modification is currently unknown to medical and genetic science."}
	id = "drunk_random_unstable"
	probability = 0.25
	var/change_prob = 25
	add_per_tick = 7

	OnLife()
		if (prob(src.change_prob) && all_functional_reagent_ids.len > 1)
			reagent_to_add = pick(all_functional_reagent_ids)
		..()

/datum/bioEffect/bee
	name = "Apidae Metabolism"
	desc = {"Human worker clone batch #92 may contain inactive space bee DNA.
	If you do not have the authorization level to know that SS13 is staffed with clones, please forget this entire message."}
	id = "bee"
	msgGain = "You feel buzzed!"
	msgLose = "You lose your buzz."
	probability = 99

/datum/bioEffect/chime_snaps
	name = "Dactyl Crystallization"
	desc = "The subject's digits crystallize and, when struck together, emit a pleasant noise."
	id = "chime_snaps"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	msgGain = "Your fingers and toes turn transparent and crystalline."
	msgLose = "Your fingers and toes return to normal."

/datum/bioEffect/aura
	name = "Dermal Glow"
	desc = "Causes the subject's skin to emit faint light patterns."
	id = "aura"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	msgGain = "You start to emit a pulsing glow."
	msgLose = "The glow in your skin fades."
	var/ovl_sprite = null
	var/color_hex = null

	New()
		..()
		ovl_sprite = pick("aurapulse","aurapulse-fast","aurapulse-slow","aurapulse-offset")
		color_hex = random_color()

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = ovl_sprite, layer = MOB_LIMB_LAYER)
			overlay_image.color = color_hex
		..()

/datum/bioEffect/chronal_additive_inversement
	name = "Chronal Additive Inversement"
	desc = "Causes the subject's age to become its additive inverse...somehow."
	id = "chronal_additive_inversement"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	blockCount = 3
	blockGaps = 3
	msgGain = "You feel as if you're impossibly young."
	msgLose = "You feel like you're your own age again."
	stability_loss = 10

	OnAdd()
		holder.age = (0 - holder.age)
		..()
	OnRemove()
		holder.age = (0 - holder.age)
		..()

/datum/bioEffect/temporal_displacement
	name = "Temporal Displacement"
	desc = "The subject becomes displaced in time, aging them at random."
	id = "temporal_displacement"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	blockCount = 3
	blockGaps = 3
	msgGain = "You feel like you're growing younger - no wait, older?"
	msgLose = "You feel like you're aging normally again."
	stability_loss = 10
	OnLife()
		..()
		if (prob(33))
			holder.age = rand(-80, 80)


//////////////////////
// Combination Only //
//////////////////////

/datum/bioEffect/fire_aura
	name = "Blazing Aura"
	desc = "Causes the subject's skin to emit harmless false fire."
	id = "aura_fire"
	effectType = EFFECT_TYPE_POWER
	occur_in_genepools = 0
	msgGain = "You burst into flames!"
	msgLose = "Your skin stops emitting fire."
	var/ovl_sprite = null
	var/color_hex = null

	New()
		..()
		color_hex = random_color()

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "fireaura", layer = MOB_LIMB_LAYER)
			overlay_image.color = color_hex
		..()

/datum/bioEffect/fire_aura/evil //this is just for /proc/soulcheck
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	id = "hell_fire"
