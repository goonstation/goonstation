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
	probability = 33
	blockCount = 3
	blockGaps = 3
	stability_loss = 15
	msgGain = "Your hair stands on end."
	msgLose = "The tingling in your skin fades."
	degrade_to = "funky_limb"
	icon_state  = "elec_res"
	effect_group = "elec"

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "elec", layer = MOB_EFFECT_LAYER)
		..()
		if (istype(owner, /mob/living) && owner:organHolder && owner:organHolder:heart && owner:organHolder:heart:robotic)
			owner:organHolder:heart:broken = 1
			owner:contract_disease(/datum/ailment/malady/flatline,null,null,1)
			boutput(owner, SPAN_ALERT("Something is wrong with your cyberheart, it stops beating!"))
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
		if (!ishuman(owner)) // applies to critters too, check toxin.dm
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
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.oxyloss = 0
			H.losebreath = 0
		if(ismob(owner))
			if(src.power == 1)
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_REBREATHING, src.type)
			else
				APPLY_ATOM_PROPERTY(owner, PROP_MOB_BREATHLESS, src.type)
		health_update_queue |= owner

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
	desc = "Subject's cells are capable of repairing immense trauma at an unbelievably rapid rate."
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
		animate_fade_grayscale(owner, 5)

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
		animate_fade_from_grayscale(owner, 5)
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
	var/current_module = null

	OnAdd()
		src.onPowerChange(0, src.power)

		. = ..()

	onPowerChange(oldval, newval)
		if (src.owner && src.current_module)
			src.owner.ensure_listen_tree().RemoveListenInput(src.current_module)

		switch (newval)
			if (1)
				src.current_module = LISTEN_INPUT_RADIO_GLOBAL_DEFAULT_ONLY
			if (2)
				src.current_module = LISTEN_INPUT_RADIO_GLOBAL_UNPROTECTED_ONLY
			else
				src.current_module = LISTEN_INPUT_RADIO_GLOBAL

		if (src.owner)
			src.owner.listen_tree.AddListenInput(src.current_module)

	OnRemove()
		if (!src.owner || !src.current_module)
			return

		src.owner.ensure_listen_tree().RemoveListenInput(src.current_module)

		. = ..()


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
	var/visible = TRUE
	var/hulk_skin = "#4CBB17" // a striking kelly green

	OnAdd()
		owner.unlock_medal("It's not easy being green", 1)
		APPLY_MOVEMENT_MODIFIER(owner, /datum/movement_modifier/hulkstrong, src.type)
		if (ishuman(owner) && src.visible)
			var/mob/living/carbon/human/H = owner
			if(H?.bioHolder?.mobAppearance)
				var/datum/appearanceHolder/HAH = H.bioHolder.mobAppearance
				HAH.customizations["hair_bottom"].color_original = HAH.customizations["hair_bottom"].color
				HAH.customizations["hair_middle"].color_original = HAH.customizations["hair_middle"].color
				HAH.customizations["hair_top"].color_original = HAH.customizations["hair_top"].color
				HAH.s_tone_original = HAH.s_tone
				if(prob(1)) // just the classics
					var/gray_af = rand(60, 150) // as consistent as the classics too
					hulk_skin = rgb(gray_af, gray_af, gray_af)
				HAH.customizations["hair_bottom"].color = "#4F7942" // a pleasant fern green
				HAH.customizations["hair_middle"].color = "#3F704D" // a bold hunter green
				HAH.customizations["hair_top"].color = "#0B6623" // a vibrant forest green
				HAH.s_tone = hulk_skin
			H.update_colorful_parts()
			H.set_body_icon_dirty()
		..()

	OnRemove()
		. = ..()
		REMOVE_MOVEMENT_MODIFIER(owner, /datum/movement_modifier/hulkstrong, src.type)
		if (ishuman(owner) && src.visible)
			var/mob/living/carbon/human/H = owner
			if(H?.bioHolder?.mobAppearance) // colorize, but backwards
				var/datum/appearanceHolder/HAH = H.bioHolder.mobAppearance
				HAH.customizations["hair_bottom"].color = HAH.customizations["hair_bottom"].color_original
				HAH.customizations["hair_middle"].color = HAH.customizations["hair_middle"].color_original
				HAH.customizations["hair_top"].color = HAH.customizations["hair_top"].color_original
				HAH.s_tone = HAH.s_tone_original
				if(HAH.mob_appearance_flags & FIX_COLORS) // human -> hulk -> lizard -> nothulk is *bright*
					HAH.customizations["hair_bottom"].color = fix_colors(HAH.customizations["hair_bottom"].color)
					HAH.customizations["hair_middle"].color = fix_colors(HAH.customizations["hair_middle"].color)
					HAH.customizations["hair_top"].color = fix_colors(HAH.customizations["hair_top"].color)
			H.update_colorful_parts()
			H.set_body_icon_dirty()

	OnLife(var/mult)
		if(..()) return
		var/mob/living/carbon/human/H = owner

		if (ishuman(owner) && src.visible && prob(33)) //whatever
			if(H?.bioHolder?.mobAppearance)
				var/datum/appearanceHolder/HAH = H.bioHolder.mobAppearance
				HAH.customizations["hair_bottom"].color = "#4F7942" // a pleasant fern green
				HAH.customizations["hair_middle"].color = "#3F704D" // a bold hunter green
				HAH.customizations["hair_top"].color = "#0B6623" // a vibrant forest green
				HAH.s_tone = hulk_skin
				HAH.UpdateMob()

		if (H.health <= 25 && src.power == 1)
			timeLeft = 1
			boutput(owner, SPAN_ALERT("You suddenly feel very weak."))
			H.changeStatus("knockdown", 3 SECONDS)
			H.emote("collapse")

/datum/bioEffect/hulk/hidden
	name = "Hidden Gamma Ray Exposure"
	id = "hulk_hidden"
	visible = FALSE
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0

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
	effect_group = "vision"

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
	stability_loss = 5
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
		if (..())
			return
		if (isliving(owner))
			var/mob/living/L = owner

			if (L.blood_volume < initial(L.blood_volume) && L.blood_volume > 0)
				L.blood_volume += 4*mult*power

///////////////////////////
// Critters              //
///////////////////////////

/datum/bioEffect/claws
	name = "Manusclavis felidunguus"
	desc = "Subject arms change into a more animalistic form over time."
	id = "claws"
	occur_in_genepools = 0
	effectType = EFFECT_TYPE_POWER
	msgGain = "Your arms start to feel strange and clumsy."
	msgLose = "You once again feel comfortable with your arms."
	stability_loss = 15
	icon_state  = "blood_od"
	effect_group = "blood"
	var/left_arm_path = /obj/item/parts/human_parts/arm/left/claw/critter
	var/right_arm_path = /obj/item/parts/human_parts/arm/right/claw/critter

	OnLife(var/mult)
		if (..())
			return
		if (ishuman(owner))
			var/mob/living/carbon/human/M = owner

			if(M.limbs?.r_arm && !M.limbs.r_arm.limb_is_unnatural && !M.limbs.r_arm.limb_is_transplanted)
				if (!istype(M.limbs.r_arm, right_arm_path))
					M.limbs.replace_with("r_arm", right_arm_path, M, 0)

			if(M.limbs?.l_arm && !M.limbs.l_arm.limb_is_unnatural && !M.limbs.l_arm.limb_is_transplanted)
				if (!istype(M.limbs.l_arm, left_arm_path))
					M.limbs.replace_with("l_arm", left_arm_path, M, 0)

/datum/bioEffect/claws/pincer
	name = "Manuschela Crustaceaformis"
	desc = "Subject's arm changes into a pincer."
	id = "claws_pincer"
	msgGain = "You feel like your arms are oddly firm."
	msgLose = "You are once again feel comfortable with your arms."

	left_arm_path = /obj/item/parts/human_parts/arm/left/claw/critter/pincer
	right_arm_path = /obj/item/parts/human_parts/arm/right/claw/critter/pincer

/obj/item/parts/human_parts/arm/left/claw/critter
	limb_type = /datum/limb/small_critter/strong

/obj/item/parts/human_parts/arm/right/claw/critter
	limb_type = /datum/limb/small_critter/strong

/obj/item/parts/human_parts/arm/left/claw/critter/pincer
	limb_type = /datum/limb/small_critter/pincers

/obj/item/parts/human_parts/arm/right/claw/critter/pincer
	limb_type = /datum/limb/small_critter/pincers

/datum/bioEffect/carapace
	name = "Chitinoarmis Durescutis "
	desc = "Subject skin develops into a hardened carapace."
	id = "carapace"
	occur_in_genepools = 0
	effectType = EFFECT_TYPE_POWER
	msgGain = "You feel your skin harden."
	msgLose = "You feel your skin become soft and supple."
	stability_loss = 10
	icon_state  = "aura"
	effect_group = "blood"

	OnAdd()
		. = ..()
		if(ismob(owner))
			APPLY_ATOM_PROPERTY(owner, PROP_MOB_MELEEPROT_HEAD, src.type, 2 * power)
			APPLY_ATOM_PROPERTY(owner, PROP_MOB_MELEEPROT_BODY, src.type, 2 * power)

	onPowerChange(oldval, newval)
		. = ..()
		if(ismob(owner))
			APPLY_ATOM_PROPERTY(owner, PROP_MOB_MELEEPROT_HEAD, src.type, 2 * newval)
			APPLY_ATOM_PROPERTY(owner, PROP_MOB_MELEEPROT_BODY, src.type, 2 * newval)

	OnRemove()
		. = ..()
		if(ismob(owner))
			REMOVE_ATOM_PROPERTY(owner, PROP_MOB_MELEEPROT_HEAD, src.type)
			REMOVE_ATOM_PROPERTY(owner, PROP_MOB_MELEEPROT_BODY, src.type)

/datum/bioEffect/slither
	name = "Lateral Undulation"
	desc = "Subject muscles develop the ability to perform a serpentine locomation."
	id = "slither"
	occur_in_genepools = 0
	effectType = EFFECT_TYPE_POWER
	msgGain = "You feel like you could propel yourself on your belly with a good wiggle."
	msgLose = "You feel like moving around on your belly is a silly thing to do."
	stability_loss = 15

	OnAdd()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			APPLY_MOVEMENT_MODIFIER(H, /datum/movement_modifier/slither, src.type)

	OnRemove()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			REMOVE_MOVEMENT_MODIFIER(H, /datum/movement_modifier/slither, src.type)

/datum/bioEffect/food_stores
	name = "Lipid Stores"
	desc = "Subject gains the ability to improve the nourishment available from their lipid stores."
	id = "camel_fat"
	probability = 10
	effectType = EFFECT_TYPE_POWER
	msgGain = "You feel like you can store away some food and drink for later."
	msgLose = "You feel a little more lean than you did before."
	stability_loss = 5
	mob_exclusion = list(/mob/living/carbon/human)
	var/food_stored = 0
	var/food_max = 50
	var/store_above_perc = 80
	var/use_below_perc = 30
	var/lost_perc = 70

	OnLife(var/mult)
		if (..())
			return
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner

			if(food_max < 50)
				// Extra available to lets store some...
				if(H.sims.getValue("Thirst") > store_above_perc)
					var/absorb = 0.0909
					H.sims.affectMotive("Thirst", -absorb)
					food_stored += absorb * (lost_perc / 100)
				if(H.sims.getValue("Hunger") > store_above_perc)
					var/absorb = 0.078
					H.sims.affectMotive("Hunger", -absorb)
					food_stored += absorb * (lost_perc/ 100)

			if(food_stored > 0)
				// See if we can feed the need
				if(H.sims.getValue("Thirst") < use_below_perc)
					var/absorb = 0.0909
					H.sims.affectMotive("Thirst", -absorb)
					food_stored -= absorb

				if(H.sims.getValue("Hunger") < use_below_perc)
					var/absorb = 0.078
					H.sims.affectMotive("Hunger", -absorb)
					food_stored -= absorb


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
		if (..())
			return
		if (probmult(20))
			src.active = !src.active
		if (src.active)
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src, INVIS_MESON)
		else
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src)

	OnRemove()
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src)
		. = ..()

// hair_override gene
/datum/bioEffect/hair_growth
	name = "Androgen Booster"
	desc = "A boost of androgens causes a subject to sprout hair, even if they are normally incapable of it."
	id = "hair_growth"
	msgGain = "Your scalp itches."
	msgLose = "Your scalp stops itching."
	occur_in_genepools = 0 // this shouldn't be available outside of admin shenanigans
	probability = 0
	scanner_visibility = 0 // nor should it be visible
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	acceptable_in_mutini = 0
	curable_by_mutadone = FALSE
	effectType = EFFECT_TYPE_POWER

	OnAdd()
		if (ishuman(owner))
			var/mob/living/carbon/human/M = owner
			if (M.AH_we_spawned_with)
				M.bioHolder.mobAppearance.customizations["hair_bottom"].color 	= fix_colors(M.AH_we_spawned_with.customizations["hair_bottom"].color)
				M.bioHolder.mobAppearance.customizations["hair_middle"].color 	= fix_colors(M.AH_we_spawned_with.customizations["hair_middle"].color)
				M.bioHolder.mobAppearance.customizations["hair_top"].color 	= fix_colors(M.AH_we_spawned_with.customizations["hair_top"].color)
				M.bioHolder.mobAppearance.customizations["hair_bottom"].style 			= M.AH_we_spawned_with.customizations["hair_bottom"].style
				M.bioHolder.mobAppearance.customizations["hair_middle"].style 			= M.AH_we_spawned_with.customizations["hair_middle"].style
				M.bioHolder.mobAppearance.customizations["hair_top"].style 			= M.AH_we_spawned_with.customizations["hair_top"].style

			M.hair_override = 1
			M.bioHolder.mobAppearance.UpdateMob()
			M.update_colorful_parts()
		. = ..()

	OnRemove()
		. = ..()
		if (!.)
			return
		if (ishuman(owner))
			var/mob/living/carbon/human/M = owner

			M.hair_override = 0
			M.bioHolder.mobAppearance.UpdateMob()
			M.update_colorful_parts()

/datum/bioEffect/skitter
	id = "skitter"
	name = "Insectoid locomotion"
	desc = "The subject is capable of skittering across the floor like a bug."
	occur_in_genepools = 0

	OnAdd()
		RegisterSignal(src.owner, COMSIG_MOB_SPRINT, PROC_REF(on_sprint))
		. = ..()

	proc/on_sprint()
		set waitfor = FALSE
		if (!src.owner.lying || is_incapacitated(src.owner) || length(src.owner.grabbed_by))
			return
		if (!isturf(src.owner.loc))
			return
		var/turf/T = get_turf(src.owner)
		if (!istype(T) || T.throw_unlimited)
			return
		if (ON_COOLDOWN(src.owner, "skitter", 7 SECONDS))
			return
		src.owner.visible_message(SPAN_ALERT("[src.owner] skitters away!"))
		playsound(src.owner, 'sound/voice/animal/bugchitter.ogg', 80, TRUE)
		src.owner.flags |= TABLEPASS
		src.owner.layer = OBJ_LAYER-0.2
		var/initial_glide = src.owner.glide_size
		APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_CANTMOVE, src) //stop them from rolling out from under the table
		var/stop_delay = 0
		for (var/i in 1 to 4)
			src.owner.glide_size = (32 / 1) * world.tick_lag
			step(src.owner, src.owner.dir)
			if (locate(/obj/table) in src.owner.loc)
				stop_delay = 1 SECOND
				break
			sleep(0.1 SECONDS)
		src.owner.glide_size = initial_glide
		src.owner.flags &= ~TABLEPASS
		if (locate(/obj/table) in src.owner.loc)
			src.owner.setStatus("undertable", INFINITE_STATUS)
		else
			src.owner.layer = initial(src.owner.layer)
		sleep(stop_delay)
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_CANTMOVE, src)

	OnRemove()
		UnregisterSignal(src.owner, COMSIG_MOB_SPRINT)
		. = ..()

/datum/bioEffect/plasma_metabolism
	id = "plasma_metabolism"
	name = "Plasma metabolism"
	desc = "The subject's body is capable of metabolising solid and liquid forms of plasma into electric charge."
	occur_in_genepools = FALSE
	effectType = EFFECT_TYPE_POWER
	msgGain = "You feel a sudden hunger for plasma..."
	msgLose = "Your hunger for purple recedes."
	effect_group = "elec"
	///Absorbed plasma material
	VAR_PRIVATE/material = 0
	///Separate counter between burps
	VAR_PRIVATE/burp_counter = 0
	///Stored to keep UpdateOverlays calls to a minimum
	VAR_PRIVATE/eye_state = -1

	OnLife(mult)
		. = ..()
		//if we haven't absorbed plasma in a while, drain a little bit
		if (!GET_COOLDOWN(src.owner, "plasma_absorb") && src.material < 10)
			src.material = max(0, src.material - 0.5)
			src.update_eyes()
			return
		src.do_madness()
		//too little or too often
		if (src.material < 10 || GET_COOLDOWN(src.owner, "plasma_electricity"))
			return
		//a little bit random
		if (prob(20))
			return
		ON_COOLDOWN(src.owner, "plasma_electricity", 7 SECONDS)
		src.material -= 5
		src.update_eyes()
		var/obj/item/found_item = null
		if (prob(15)) //most of the time we try to ground into an item, sometimes it misses
			boutput(src.owner, SPAN_ALERT("Electricty arcs wildly from your fingers!"))
			elecflash(src.owner, 0, 2, exclude_center = FALSE)
			arcFlash(src.owner, pick(view(3, src.owner)), 5000)
			return
		for (var/obj/item/item in src.owner)
			//ammo type power cell or holder (welcome to comsig hell)
			if ((SEND_SIGNAL(item, COMSIG_CELL_CAN_CHARGE) & CELL_CHARGEABLE))
				//is it full?
				var/list/ret = list()
				if ((SEND_SIGNAL(item, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST) && (ret["charge"] >= ret["max_charge"]))
					continue
				SEND_SIGNAL(item, COMSIG_CELL_CHARGE, 20)
				found_item = item
				break
			if (istype(item, /obj/item/cell))
				var/obj/item/cell/cell = item
				if (cell.charge >= cell.maxcharge)
					continue
				cell.give(1000)
				found_item = cell
				break
		if (found_item)
			boutput(src.owner, SPAN_NOTICE("Your [found_item.name] sparks quietly!"))
			playsound(src.owner.loc, "sparks", 50, 1)
		else
			boutput(src.owner, SPAN_ALERT("With nowhere to ground itself, electricity arcs from your fingers!"))
			elecflash(src.owner, 0, 2, exclude_center = FALSE)

	///Disclaimer: may or may not be a rock
	proc/absorb_tasty_rock(obj/item/rock)
		if (ishuman(src.owner))
			var/mob/living/carbon/human/human = src.owner
			human.sims.affectMotive("Hunger", rock.w_class * 3)
		src.gain_material(rock.w_class * 10)
		qdel(rock)

	proc/absorb_liquid_plasma(amount)
		if (ishuman(src.owner))
			var/mob/living/carbon/human/human = src.owner
			human.sims.affectMotive("Thirst", amount)
		src.gain_material(amount)

	proc/gain_material(amount)
		src.material += amount
		src.burp_counter += amount
		ON_COOLDOWN(src.owner, "plasma_absorb", 10 SECONDS)
		if (src.burp_counter > 20 && !ON_COOLDOWN(src.owner, "plasma_burp", 5 SECONDS))
			src.burp_counter = 0
			src.owner.emote("burp")
			var/turf/T = get_turf(src.owner)
			if (T)
				var/datum/gas_mixture/plasma_burp = new()
				plasma_burp.toxins = 8
				plasma_burp.temperature = T20C
				T.assume_air(plasma_burp)
		src.update_eyes()

	proc/update_eyes()
		if (!ishuman(src.owner)) //no standard way to get critter eye position
			return
		var/new_eye_state
		switch (src.material)
			if (1 to 20)
				new_eye_state = 1
			if (15 to INFINITY)
				new_eye_state = 2
			else
				new_eye_state = 0
		if (src.eye_state != new_eye_state)
			src.eye_state = new_eye_state
			if (src.eye_state == 0)
				src.owner.ClearSpecificOverlays("plasma_eyes")
				src.owner.remove_color_matrix(COLOR_MATRIX_PLASMA_MADNESS_LABEL, 1 SECOND)
			else
				src.owner.apply_color_matrix(COLOR_MATRIX_PLASMA_MADNESS, COLOR_MATRIX_PLASMA_MADNESS_LABEL, 1 SECOND)
				var/mutable_appearance/eye_overlay = mutable_appearance('icons/effects/genetics.dmi', "plasma_eyes_[src.eye_state]")
				eye_overlay.plane = PLANE_SELFILLUM
				src.owner.UpdateOverlays(eye_overlay, "plasma_eyes")

	proc/do_madness()
		if (src.eye_state >= 2 && prob(10))
			src.owner.AddComponent(\
				/datum/component/hallucination/random_image_override,\
				timeout = 20,\
				image_list = list(\
					image('icons/turf/floors.dmi', "void")\
				),\
				target_list = list(/turf/simulated/floor, /turf/unsimulated/floor),\
			)
		if (src.eye_state >= 1)
			if (prob(5))
				src.owner.playsound_local_not_inworld('sound/ambience/spooky/Void_Calls.ogg', 50, 1)
			if (prob(20))
				var/speech_id = pick(global.sounds_speak)
				src.owner.playsound_local_not_inworld(global.sounds_speak[speech_id], rand(20, 60), 0.01)

	OnRemove()
		src.owner.ClearSpecificOverlays("plasma_eyes")
		src.owner.remove_color_matrix(COLOR_MATRIX_PLASMA_MADNESS_LABEL, 1 SECOND)
		. = ..()
