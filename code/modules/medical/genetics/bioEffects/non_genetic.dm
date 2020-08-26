/datum/bioEffect/hidden
	name = "Miner Training"
	desc = "Subject is trained in geological and metallurgical matters."
	id = "training_miner"
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	curable_by_mutadone = 0
	can_reclaim = 0
	can_scramble = 0
	can_research = 0
	can_make_injector = 0
	reclaim_fail = 100
	effectType = EFFECT_TYPE_POWER

	//Moved special job stuff (chaplain, medical) over to traits system.

/datum/bioEffect/hidden/arcaneshame
	// temporary debuff for when the wizard gets shaved
	name = "Wizard's Shame"
	desc = "Subject is suffering from Post Traumatic Shaving Disorder."
	id = "arcane_shame"
	msgGain = "You feel shameful. Also bald."
	msgLose = "Your shame fades. Now you feel only righteous anger!"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	can_copy = 0

/datum/bioEffect/hidden/arcanepower
	// Variant 1 = Half Spell Cooldown, Variant 2 = No Spell Cooldown
	// Only use variant 2 for debugging/horrible admin gimmicks ok
	name = "Arcane Power"
	desc = "Subject is imbued with an unknown power."
	id = "arcane_power"
	msgGain = "Your hair stands on end."
	msgLose = "The tingling in your skin fades."
	can_copy = 0

/datum/bioEffect/hidden/husk
	name = "Husk"
	desc = "Subject appears to have been drained of all fluids."
	id = "husk"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	can_copy = 0

	OnMobDraw()
		if(ishuman(owner))
			owner:body_standing:overlays += image('icons/mob/human.dmi', "husk")

	OnAdd()
		if (ishuman(owner))
			owner:set_body_icon_dirty()

	OnRemove()
		if (ishuman(owner))
			owner:set_body_icon_dirty()

/datum/bioEffect/hidden/eaten
	name = "Eaten"
	desc = "Subject appears to have been partially consumed."
	id = "eaten"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	can_copy = 0

	OnMobDraw()
		if (ishuman(owner) && !owner:decomp_stage)
			owner:body_standing:overlays += image('icons/mob/human_decomp.dmi', "decomp1")
		return

	OnAdd()
		if (ishuman(owner))
			owner:set_body_icon_dirty()

	OnRemove()
		if (ishuman(owner))
			owner:set_body_icon_dirty()

/datum/bioEffect/hidden/consumed
	name = "Consumed"
	desc = "Most of their flesh has been chewed off."
	id = "consumed"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0

/datum/bioEffect/hidden/zombie
	// Don't put this one in the standard mutantrace pool
	name = "Necrotic Degeneration"
	desc = "Subject's cellular structure is degenerating due to sub-lethal necrosis."
	id = "zombie"
	effectType = EFFECT_TYPE_MUTANTRACE
	isBad = 1
	can_copy = 0
	msgGain = "You begin to rot."
	msgLose = "You are no longer rotting."

	OnAdd()
		owner.set_mutantrace(/datum/mutantrace/zombie)
		return

	OnRemove()
		if (istype(owner:mutantrace, /datum/mutantrace/zombie))
			owner.set_mutantrace(null)
		return

	OnLife()
		if(..()) return
		if(!istype(owner:mutantrace, /datum/mutantrace/zombie))
			holder.RemoveEffect(id)
		return

/datum/bioEffect/hidden/premature_clone
	// Probably shouldn't put this one in either
	name = "Stunted Genetics"
	desc = "Genetic abnormalities possibly resulting from incomplete development in a cloning pod."
	id = "premature_clone"
	effectType = EFFECT_TYPE_MUTANTRACE
	isBad = 1
	can_copy = 0
	msgGain = "You don't feel quite right."
	msgLose = "You feel normal again."
	var/outOfPod = 0 //Out of the cloning pod.

	OnAdd()
		..()
		owner.set_mutantrace(/datum/mutantrace/premature_clone)
		if (!istype(owner.loc, /obj/machinery/clonepod))
			boutput(owner, "<span class='alert'>Your genes feel...disorderly.</span>")
		return

	OnRemove()
		..()
		if (istype(owner:mutantrace, /datum/mutantrace/premature_clone))
			owner.set_mutantrace(null)
		return

	OnLife()
		if(..()) return
		if(!istype(owner:mutantrace, /datum/mutantrace/premature_clone))
			holder.RemoveEffect(id)

		if (outOfPod)
			if (prob(6))
				owner.visible_message("<span class='alert'>[owner.name] suddenly and violently vomits!</span>")
				owner.vomit()

			else if (prob(2))
				owner.visible_message("<span class='alert'>[owner.name] vomits blood!</span>")
				playsound(owner.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				random_brute_damage(owner, rand(5,8))
				bleed(owner, rand(5,8), 5)

		else if (!istype(owner.loc, /obj/machinery/clonepod))
			outOfPod = 1

		return

/datum/bioEffect/hidden/sims_stinky
	name = "Poor Hygiene"
	desc = "This guy needs a shower, stat!"
	id = "sims_stinky"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	can_copy = 0
	curable_by_mutadone = 0
	occur_in_genepools = 0
	var/personalized_stink = "Wow, it stinks in here!"

	New()
		..()
		src.personalized_stink = stinkString()
		if (prob(5))
			src.variant = 2

	OnLife()
		if(..()) return
		if (prob(10))
			for(var/mob/living/carbon/C in view(6,get_turf(owner)))
				if (C == owner)
					continue
				if (src.variant == 2)
					boutput(C, "<span class='alert'>[src.personalized_stink]</span>")
				else
					boutput(C, "<span class='alert'>[stinkString()]</span>")

// Magnetic Random Event

/datum/bioEffect/hidden/magnetic
	name = "magnetic charge parent"
	desc = "This shouldn't be used."
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	can_copy = 0
	curable_by_mutadone = 0
	occur_in_genepools = 0
	var/active = 1

	var/max_charge = 10
	var/charge = 5

	proc/update_charge(var/amount)
		var/init_charge = src.charge
		src.charge += amount
		src.charge = clamp(src.charge,0,src.max_charge)
		if(src.charge != init_charge)
			src.update_overlay()
			return 1
		return 0

	proc/update_overlay()
		if(src.overlay_image)
			if(isliving(owner))
				src.overlay_image.alpha = charge/max_charge*255
				var/mob/living/L = owner
				L.UpdateOverlays(overlay_image, id)

	proc/deactivate(var/time)
		active = 0
		SPAWN_DBG(time)
			active = 1

/datum/bioEffect/hidden/magnetic/positive
	name = "Magnetic Charge +"
	desc = "This person is charged with a strong positive magnetic field."
	id = "magnets_pos"
	msgGain = "You notice odd red static sparking on your skin."

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "outline", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#FF0059"
		..()

/datum/bioEffect/hidden/magnetic/negative
	name = "Magnetic Charge -"
	desc = "This person is charged with a strong negative magnetic field."
	id = "magnets_neg"
	msgGain = "You notice odd blue static sparking on your skin."
	effectType = EFFECT_TYPE_DISABILITY

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "outline", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#007BFF"
		..()
