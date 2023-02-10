////////////////////////////////
// Resistances and Immunities //
////////////////////////////////
/datum/bioEffect/fireres
	name = "Fire Resistance"
	desc = "Shields the subject's cellular structure against high temperatures and flames."
	id = "fire_resist"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	blockCount = 3
	msgGain = "You feel cold."
	msgLose = "You feel warm."
	stability_loss = 10
	degrade_to = "aura_fire"
	icon_state  = "fire_res"
	effect_group = "thermal"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#FFA200"

		..()

/datum/bioEffect/coldres
	name = "Cold Resistance"
	desc = "Shields the subject's cellular structure against freezing temperatures and crystallization."
	id = "cold_resist"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	blockCount = 3
	msgGain = "You feel warm."
	msgLose = "You feel cold."
	stability_loss = 10
	// you feel warm because you're resisting the cold, stop changing these around! =(
	degrade_to = "shiny"
	icon_state  = "cold_res"
	effect_group = "thermal"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#009DFF"
		..()

/datum/bioEffect/thermalres
	name = "Thermal Resistance"
	desc = "Somewhat shields the subject's cellular structure against any harmful temperature exposure."
	id = "thermal_resist"
	effectType = EFFECT_TYPE_POWER
	blockCount = 3
	occur_in_genepools = 0
	stability_loss = 10
	var/image/overlay_image_two = null
	degrade_to = "thermal_vuln"
	icon_state  = "thermal_res"
	effect_group = "thermal"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
			overlay_image_two = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse-offset", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#FFA200"
			overlay_image_two.color = "#009DFF"
		..()
		if(overlay_image_two)
			var/mob/living/L = owner
			L.UpdateOverlays(overlay_image_two, id + "2")
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_HEATPROT, src.type, 50)
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_COLDPROT, src.type, 50)
		owner.temp_tolerance *= 10

	OnRemove()
		..()
		REMOVE_ATOM_PROPERTY(owner, PROP_MOB_HEATPROT, src.type)
		REMOVE_ATOM_PROPERTY(owner, PROP_MOB_COLDPROT, src.type)
		owner.temp_tolerance /= 10
		if(overlay_image_two)
			if(isliving(owner))
				var/mob/living/L = owner
				L.UpdateOverlays(null, id + "2")
		return

/datum/bioEffect/elecres
	name = "SMES Human"
	desc = "Protects the subject's cellular structure from electrical energy."
	id = "resist_electric"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	blockCount = 3
	blockGaps = 3
	stability_loss = 15
	msgGain = "Your hair stands on end."
	msgLose = "The tingling in your skin fades."
	degrade_to = "funky_limb"
	icon_state  = "elec_res"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "elec", layer = MOB_EFFECT_LAYER)
		..()
		if (istype(owner, /mob/living) && owner:organHolder && owner:organHolder:heart && owner:organHolder:heart:robotic)
			owner:organHolder:heart:broken = 1
			owner:contract_disease(/datum/ailment/malady/flatline,null,null,1)
			boutput(owner, "<span class='alert'>Something is wrong with your cyberheart, it stops beating!</span>")
		if(ismob(owner))
			if(src.power > 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_DISORIENT_RESIST_BODY, src, 40)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_DISORIENT_RESIST_BODY_MAX, src, 40)

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			if(oldval > 1)
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_DISORIENT_RESIST_BODY, src)
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_DISORIENT_RESIST_BODY_MAX, src)
			if(newval > 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_DISORIENT_RESIST_BODY, src, 40)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_DISORIENT_RESIST_BODY_MAX, src, 40)

	OnRemove()
		. = ..()
		if(ismob(owner))
			if(src.power > 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_DISORIENT_RESIST_BODY, src, 40)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_DISORIENT_RESIST_BODY_MAX, src, 40)

	heal
		id = "resist_electric_heal"
		occur_in_genepools = 0
		can_copy = 0
		acceptable_in_mutini = 0
		degrade_to = "resist_electric"

/datum/bioEffect/rad_resist
	name = "Radiation Resistance"
	desc = "Shields the subject's cellular structure against ionizing radiation."
	id = "rad_resist"
	effectType = EFFECT_TYPE_POWER
	blockCount = 2
	secret = 1
	stability_loss = 15
	degrade_to = "radioactive"
	icon_state  = "rad_res"
	effect_group = "rad"

	OnAdd()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			APPLY_ATOM_PROPERTY(M, PROP_MOB_RADPROT_INT, src, 75 * power)

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			APPLY_ATOM_PROPERTY(M, PROP_MOB_RADPROT_INT, src, 75 * newval)

	OnRemove()
		. = ..()
		if(ismob(owner))
			var/mob/M = owner
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_RADPROT_INT, src)

/datum/bioEffect/alcres
	name = "Alcohol Resistance"
	desc = "Strongly reinforces the subject's nervous system against alcoholic intoxication."
	id = "resist_alcohol"
	probability = 99
	stability_loss = 0
	effectType = EFFECT_TYPE_POWER
	msgGain = "You feel unusually sober."
	msgLose = "You feel like you could use a stiff drink."
	degrade_to = "drunk"
	icon_state  = "alc_res"

/datum/bioEffect/toxres
	name = "Toxic Resistance"
	desc = "Renders the subject's blood immune to toxification. This will not stop other effects of poisons from occurring, however."
	id = "resist_toxic"
	effectType = EFFECT_TYPE_POWER
	probability = 8
	blockCount = 4
	blockGaps = 5
	reclaim_mats = 40
	curable_by_mutadone = 0
	stability_loss = 30
	msgGain = "You feel refreshed and clean."
	msgLose = "You feel a bit grody."
	degrade_to = "toxification"
	icon_state  = "tox_res"
	effect_group = "tox"

	OnAdd()
		..()
		if (!ishuman(owner))
			return
		var/mob/living/carbon/human/H = owner
		H.toxloss = 0
		health_update_queue |= H

/datum/bioEffect/breathless
	name = "Anaerobic Metabolism"
	desc = "Allows the subject's body to generate its own oxygen internally, invalidating the need for respiration."
	id = "breathless"
	effectType = EFFECT_TYPE_POWER
	probability = 8
	blockCount = 4
	blockGaps = 2
	reclaim_mats = 40
	lockProb = 66
	lockedGaps = 3
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	stability_loss = 30
	msgGain = "Your lungs feel strangely empty."
	msgLose = "You start gasping for air."
	degrade_to = "mute"
	icon_state  = "breathless"

	OnAdd()
		..()
		if (!ishuman(owner))
			return
		var/mob/living/carbon/human/H = owner
		H.oxyloss = 0
		H.losebreath = 0
		if(ismob(owner))
			if(src.power == 1)
				APPLY_ATOM_PROPERTY(H, PROP_MOB_REBREATHING, src.type)
			else
				APPLY_ATOM_PROPERTY(H, PROP_MOB_BREATHLESS, src.type)
		health_update_queue |= H

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			if(oldval == 1)
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_REBREATHING, src.type)
			else
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_BREATHLESS, src.type)
			if(newval == 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_REBREATHING, src.type)
			else
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_BREATHLESS, src.type)

	OnRemove()
		. = ..()
		if(ismob(owner))
			REMOVE_ATOM_PROPERTY(owner, PROP_MOB_BREATHLESS, src.type)
			REMOVE_ATOM_PROPERTY(owner, PROP_MOB_REBREATHING, src.type)

/datum/bioEffect/breathless/contract
	name = "Airless Breathing"
	id = "breathless_contract"
	msgGain = ""
	msgLose = ""
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	stability_loss = 0
	power = 2

/datum/bioEffect/psychic_resist
	name = "Meta-Neural Enhancement"
	desc = "Boosts efficiency in sectors of the brain commonly associated with resisting meta-mental energies."
	id = "psy_resist"
	probability = 99
	stability_loss = 0
	effectType = EFFECT_TYPE_POWER
	msgGain = "Your mind feels closed."
	msgLose = "You feel oddly exposed."
	degrade_to = "screamer"

/////////////
// Healing //
/////////////

/datum/bioEffect/regenerator
	name = "Regeneration"
	desc = "Overcharges the subject's natural healing, enabling them to rapidly heal from any wound."
	id = "regenerator"
	effectType = EFFECT_TYPE_POWER
	probability = 8
	blockCount = 4
	blockGaps = 3
	reclaim_mats = 40
	lockProb = 66
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	stability_loss = 25
	msgGain = "Your skin feels tingly and shifty."
	msgLose = "Your skin tightens."
	var/heal_per_tick = 0.66
	var/regrow_prob = 250
	var/roundedmultremainder
	degrade_to = "mutagenic_field"
	icon_state  = "regen"
	effect_group = "regen"

	OnLife(var/mult)
		if(..()) return
		var/mob/living/L = owner
		L.HealDamage("All", heal_per_tick * mult * power, heal_per_tick * power)
		var/roundedmult = round(mult)
		roundedmultremainder += (mult % 1)
		if (roundedmultremainder >= 1)
			roundedmult += round(roundedmultremainder)
			roundedmultremainder = roundedmultremainder % 1
		for (roundedmult = roundedmult, roundedmult > 0, roundedmult --)
			if (rand(1, regrow_prob) <= power)
				if (ishuman(L))
					var/mob/living/carbon/human/H = L
					if (H.limbs)
						H.limbs.mend(1)

/datum/bioEffect/regenerator/super
	name = "Super Regeneration"
	desc = "Subject's cells are capable of repairing immense trauama at an unbelievably rapid rate."
	id = "regenerator_super"
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	stability_loss = 0 //necessary to prevent issues with existing mutants who sign the contract. We want the sleep to be their downfall, not their genes.
	msgGain = "You begin to feel your flesh mending back together. Grody."
	msgLose = "Your flesh stops mending itself together."
	heal_per_tick = 7 // decrease to 5 if extreme narcolepsy doesn't counterbalance this enough
	regrow_prob = 50 //increase to 100 if not counterbalanced

/datum/bioEffect/regenerator/wolf
	name = "Lupine Regeneration"
	desc = "Subject's cells are programmed to reshape itself into a canine form."
	id = "regenerator_wolf"
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	stability_loss = 0
	msgGain = "You feel oddly feral."
	msgLose = "You feel more comfortable in your own skin."
	heal_per_tick = 2
	regrow_prob = 50
	acceptable_in_mutini = 0 // fun is banned

	OnAdd()
		. = ..()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(!istype(H.mutantrace, /datum/mutantrace/werewolf))
				H.contract_disease(/datum/ailment/disease/lycanthropy,null,null,0) // awoo

/datum/bioEffect/detox
	name = "Natural Anti-Toxins"
	desc = "Enables the subject's bloodstream to purge foreign substances more rapidly."
	id = "detox"
	probability = 66
	blockCount = 2
	blockGaps = 4
	msgGain = "Your pulse seems to relax."
	msgLose = "Your pulse quickens."
	lockProb = 66
	lockedGaps = 3
	lockedDiff = 2
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	curable_by_mutadone = 0
	var/remove_per_tick = 3.3
	stability_loss = 10
	degrade_to = "toxification"
	icon_state  = "tox_res"

	OnAdd()
		. = ..()
		if(ismob(owner))
			APPLY_ATOM_PROPERTY(owner, PROP_MOB_CHEM_PURGE, src.type, remove_per_tick * power)

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			APPLY_ATOM_PROPERTY(owner, PROP_MOB_CHEM_PURGE, src.type, remove_per_tick * power)

	OnRemove()
		. = ..()
		if(ismob(owner))
			REMOVE_ATOM_PROPERTY(owner, PROP_MOB_CHEM_PURGE, src.type)

/////////////
// Stealth //
/////////////

/datum/bioEffect/examine_stopper
	name = "Meta-Neural Haze"
	desc = "Causes the subject's brain to emit waves that make the subject's body difficult to observe."
	id = "examine_stopper"
	effectType = EFFECT_TYPE_POWER
	secret = 1
	blockCount = 3
	blockGaps = 3
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("A","T")
	lockedTries = 6
	stability_loss = 5
	icon_state  = "haze"
	isBad = 1

/datum/bioEffect/dead_scan
	name = "Pseudonecrosis"
	desc = "Causes the subject's cells to mimic a death-like state."
	id = "dead_scan"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	stability_loss = 5
	icon_state  = "dead"
	isBad = 1

/datum/bioEffect/noir
	name = "Noir"
	desc = "The subject generates a light-defying aura, equalizing photons in such a way that make them look completely grayscale."
	id = "noir"
	probability = 99
	stability_loss = 0
	icon_state  = "noir"
	msgGain = "You feel chromatic pain."
	msgLose = "Colors around you begin returning to normal."

	OnAdd()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			animate_fade_grayscale(H, 5)

		if(ismob(owner))
			if(src.power > 1)
				owner.apply_color_matrix(COLOR_MATRIX_GRAYSCALE, COLOR_MATRIX_GRAYSCALE_LABEL)

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			if(oldval > 1)
				owner.remove_color_matrix(COLOR_MATRIX_GRAYSCALE_LABEL)
			if(newval > 1)
				owner.apply_color_matrix(COLOR_MATRIX_GRAYSCALE, COLOR_MATRIX_GRAYSCALE_LABEL)

	OnRemove()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			animate_fade_from_grayscale(H, 5)
		if(ismob(owner))
			if(src.power > 1)
				owner.remove_color_matrix(COLOR_MATRIX_GRAYSCALE_LABEL)

///////////////////
// General buffs //
///////////////////

/datum/bioEffect/strong
	name = "Musculature Enhancement"
	desc = "Enhances the subject's ability to build and retain heavy muscles."
	id = "strong"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	stability_loss = 5
	msgGain = "You feel buff!"
	msgLose = "You feel wimpy and weak."
	icon_state  = "strong"

	OnAdd()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			APPLY_MOVEMENT_MODIFIER(H, /datum/movement_modifier/hulkstrong, src.type)
			if(power > 1)
				APPLY_MOVEMENT_MODIFIER(H, /datum/movement_modifier/strong, src.type)

	onPowerChange(oldval, newval)
		. = ..()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(oldval > 1)
				REMOVE_MOVEMENT_MODIFIER(H, /datum/movement_modifier/strong, src.type)
			if(newval > 1)
				APPLY_MOVEMENT_MODIFIER(H, /datum/movement_modifier/strong, src.type)

	OnRemove()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			REMOVE_MOVEMENT_MODIFIER(H, /datum/movement_modifier/hulkstrong, src.type)

			if(src.power > 1)
				REMOVE_MOVEMENT_MODIFIER(H, /datum/movement_modifier/strong, src.type)

/datum/bioEffect/radio_brain
	name = "Meta-Neural Antenna"
	desc = "Enables the subject's brain to pick up radio signals."
	id = "radio_brain"
	effectType = EFFECT_TYPE_POWER
	probability = 33
	blockCount = 4
	blockGaps = 5
	reclaim_mats = 30
	msgGain = "You can hear weird chatter in your head."
	msgLose = "The weird noise in your head stops."
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 3
	lockedChars = list("G","C","A","T")
	lockedTries = 8
	stability_loss = 5
	degrade_to = "involuntary_teleporting"
	icon_state  = "radiobrain"

	OnAdd()
		radio_brains[owner] = power

	onPowerChange(oldval, newval)
		radio_brains[owner] = newval

	OnRemove()
		radio_brains -= owner

var/list/radio_brains = list()

/datum/bioEffect/hulk
	name = "Gamma Ray Exposure"
	desc = "Vastly enhances the subject's musculature. May cause severe melanocyte corruption."
	id = "hulk"
	effectType = EFFECT_TYPE_POWER
	probability = 33
	blockCount = 4
	blockGaps = 5
	reclaim_mats = 30
	msgGain = "You feel your muscles swell to an immense size."
	msgLose = "Your muscles shrink back down."
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 3
	lockedChars = list("G","C","A","T")
	lockedTries = 8
	stability_loss = 25
	degrade_to = "strong"
	icon_state  = "hulk"

	OnAdd()
		owner.unlock_medal("It's not easy being green", 1)
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			APPLY_MOVEMENT_MODIFIER(H, /datum/movement_modifier/hulkstrong, src.type)
			if(H?.bioHolder?.mobAppearance)
				var/datum/appearanceHolder/HAH = H.bioHolder.mobAppearance
				HAH.customization_first_color_original = HAH.customization_first_color
				HAH.customization_second_color_original = HAH.customization_second_color
				HAH.customization_third_color_original = HAH.customization_third_color
				HAH.s_tone_original = HAH.s_tone
				var/hulk_skin = "#4CBB17" // a striking kelly green
				if(prob(1)) // just the classics
					var/gray_af = rand(60, 150) // as consistent as the classics too
					hulk_skin = rgb(gray_af, gray_af, gray_af)
				HAH.customization_first_color = "#4F7942" // a pleasant fern green
				HAH.customization_second_color = "#3F704D" // a bold hunter green
				HAH.customization_third_color = "#0B6623" // a vibrant forest green
				HAH.s_tone = hulk_skin
			H.update_colorful_parts()
			H.set_body_icon_dirty()
		..()

	OnRemove()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H?.bioHolder?.mobAppearance) // colorize, but backwards
				var/datum/appearanceHolder/HAH = H.bioHolder.mobAppearance
				HAH.customization_first_color = HAH.customization_first_color_original
				HAH.customization_second_color = HAH.customization_second_color_original
				HAH.customization_third_color = HAH.customization_third_color_original
				HAH.s_tone = HAH.s_tone_original
				if(HAH.mob_appearance_flags & FIX_COLORS) // human -> hulk -> lizard -> nothulk is *bright*
					HAH.customization_first_color = fix_colors(HAH.customization_first_color)
					HAH.customization_second_color = fix_colors(HAH.customization_second_color)
					HAH.customization_third_color = fix_colors(HAH.customization_third_color)
			H.update_colorful_parts()
			H.set_body_icon_dirty()
			REMOVE_MOVEMENT_MODIFIER(H, /datum/movement_modifier/hulkstrong, src.type)

	OnLife(var/mult)
		if(..()) return
		var/mob/living/carbon/human/H = owner
		if (H.health <= 25 && src.power == 1)
			timeLeft = 1
			boutput(owner, "<span class='alert'>You suddenly feel very weak.</span>")
			H.changeStatus("weakened", 3 SECONDS)
			H.emote("collapse")

/datum/bioEffect/xray
	name = "X-Ray Vision"
	desc = "Enhances the subject's optic nerves, allowing them to see on x-ray wavelengths."
	id = "xray"
	effectType = EFFECT_TYPE_POWER
	probability = 33
	blockCount = 3
	blockGaps = 5
	reclaim_mats = 40
	msgGain = "You suddenly seem to be able to see through everything."
	msgLose = "Your vision fades back to normal."
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 3
	lockedChars = list("G","C","A","T")
	lockedTries = 8
	stability_loss = 20
	degrade_to = "bad_eyesight"
	icon_state  = "eye"

	OnAdd()
		. = ..()
		if(ismob(owner))
			if(power == 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION_WEAK, src)
			else
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION, src)

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			if(oldval == 1)
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION_WEAK, src)
			else
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION, src)

			if(newval == 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION_WEAK, src)
			else
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION, src)

	OnRemove()
		. = ..()
		if(ismob(owner))
			if(power == 1)
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION_WEAK, src)
			else
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_XRAYVISION, src)

/datum/bioEffect/nightvision
	name = "Night Vision"
	desc = "Enhances the subject's optic nerves, allowing them to see in the dark."
	id = "nightvision"
	effectType = EFFECT_TYPE_POWER
	probability = 33
	blockCount = 3
	blockGaps = 3
	reclaim_mats = 30
	msgGain = "Everything suddenly appears oddly lit."
	msgLose = "You blink and something seems to vanish."
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 3
	lockedChars = list("G","C","A","T")
	lockedTries = 8
	stability_loss = 15
	degrade_to = "bad_eyesight"
	icon_state  = "eye"

	OnAdd()
		. = ..()
		if(ismob(owner))
			if(power == 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION_WEAK, src)
			else
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION, src)

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			if(oldval == 1)
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION_WEAK, src)
			else
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION, src)

			if(newval == 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION_WEAK, src)
			else
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION, src)

	OnRemove()
		. = ..()
		if(ismob(owner))
			if(power == 1)
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION_WEAK, src)
			else
				REMOVE_ATOM_PROPERTY(owner, PROP_MOB_NIGHTVISION, src)

/datum/bioEffect/toxic_farts
	name = "High Decay Digestion"
	desc = "Causes the subject's digestion to create a significant amount of noxious gas."
	id = "toxic_farts"
	probability = 33
	blockCount = 2
	blockGaps = 4
	msgGain = "Your stomach grumbles unpleasantly."
	msgLose = "Your stomach stops acting up. Phew!"
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 3
	lockedChars = list("G","C","A","T")
	lockedTries = 8
	stability_loss = 10
	degrade_to = "stinky"
	icon_state  = "fart"

/datum/bioEffect/fitness_buff
	name = "Physically Fit"
	desc = "Causes the subject to be naturally more physically fit than the average spaceman."
	id = "fitness_buff"
	effectType = EFFECT_TYPE_POWER
	probability = 50
	blockCount = 2
	blockGaps = 3
	reclaim_mats = 30
	msgGain = "You feel slightly more energetic."
	msgLose = "You feel slightly less energetic."
	lockProb = 20
	lockedGaps = 1
	lockedDiff = 3
	lockedTries = 8
	stability_loss = -5
	icon_state  = "strong"
	effect_group = "fit"

	OnAdd()
		. = ..()
		if(ismob(owner))
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_STAMINA_REGEN_BONUS, "g-fitness-buff", 1.33 * power)
			src.owner.add_stam_mod_max("g-fitness-buff", 20 * power)

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_STAMINA_REGEN_BONUS, "g-fitness-buff", 1.33 * newval)
			src.owner.add_stam_mod_max("g-fitness-buff", 20 * newval)

	OnRemove()
		. = ..()
		if(ismob(owner))
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_STAMINA_REGEN_BONUS, "g-fitness-buff")
			src.owner.remove_stam_mod_max("g-fitness-buff")

/datum/bioEffect/blood_overdrive
	name = "Hemopoiesis Overdrive"
	desc = "Subject regenerates blood far faster than the average spaceman."
	id = "blood_overdrive"
	probability = 20
	effectType = EFFECT_TYPE_POWER
	msgGain = "You feel like being stabbed isn't such a big deal anymore."
	msgLose = "You are once again afraid of being stabbed."
	stability_loss = 5
	icon_state  = "blood_od"
	effect_group = "blood"

	OnLife(var/mult)

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner

			if (H.blood_volume < 500 && H.blood_volume > 0)
				H.blood_volume += 4*mult*power


///////////////////////////
// Disabled/Inaccessible //
///////////////////////////

/datum/bioEffect/telekinesis
	name = "Telekinesis"
	desc = "Enables the subject to project kinetic energy using certain thought patterns."
	id = "telekinesis"
	effectType = EFFECT_TYPE_POWER
	probability = 8
	blockCount = 5
	blockGaps = 5
	reclaim_mats = 40
	msgGain = "You feel your consciousness expand outwards."
	msgLose = "Your conciousness closes inwards."
	stability_loss = 30
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	acceptable_in_mutini = 0
	icon_state  = "tk"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "telekinesishead", layer = MOB_LAYER)
		..()

/datum/bioEffect/uncontrollable_cloak
	name = "Unstable Refraction"
	desc = "The subject will occasionally become invisible. The subject has no control or awareness of this occurring."
	id = "uncontrollable_cloak"
	effectType = EFFECT_TYPE_POWER
	occur_in_genepools = 0 // needs nerfing before it can be put back
	probability = 0 // formerly 66
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0

	blockCount = 3
	blockGaps = 3
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("A","T")
	lockedTries = 6
	var/active = 0
	stability_loss = 15
	icon_state  = "haze"

	OnLife(var/mult)
		if (probmult(20))
			src.active = !src.active
		if (src.active)
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src, INVIS_INFRA)
		else
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src)

	OnRemove()
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src)
		. = ..()
