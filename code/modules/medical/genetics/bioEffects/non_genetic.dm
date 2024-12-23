ABSTRACT_TYPE(/datum/bioEffect/hidden)
/datum/bioEffect/hidden
	name = "Hidden bioeffect parent"
	desc = "You should not see this."
	id = "hidden"
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	curable_by_mutadone = 0
	can_reclaim = 0
	can_scramble = 0
	can_research = 0
	can_make_injector = 0
	reclaim_fail = 100
	acceptable_in_mutini = 0
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

/datum/bioEffect/hidden/robed
	name = "Robed"
	desc = "Subject can cast arcane spells without the use of magical robes or a staff."
	id = "robed"
	msgGain = "You feel the constraints of traditional sorcery falling from your mind."
	msgGain = "You feel once more bound by the laws of magic."
	can_copy = FALSE

/datum/bioEffect/hidden/husk
	name = "Husk"
	desc = "Subject appears to have been drained of all fluids."
	id = "husk"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	can_copy = 0

	OnMobDraw()
		if (..())
			return
		if(ishuman(owner))
			owner:body_standing:overlays += image('icons/mob/human.dmi', "husk")

	OnAdd()
		if (ishuman(owner))
			owner:set_body_icon_dirty()
		. = ..()

	OnRemove()
		. = ..()
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
		if (..())
			return
		if (ishuman(owner) && !owner:decomp_stage)
			if (isskeleton(owner))
				owner:body_standing:overlays += image('icons/mob/human_decomp.dmi', "decomp4")
			else
				owner:body_standing:overlays += image('icons/mob/human_decomp.dmi', "decomp1")

	OnAdd()
		if (ishuman(owner))
			owner:set_body_icon_dirty()
		. = ..()

	OnRemove()
		. = ..()
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
	effect_group = "mutantrace"
	isBad = 1
	can_copy = 0
	msgGain = "You begin to rot."
	msgLose = "You are no longer rotting."

	OnAdd()
		. = ..()
		owner.set_mutantrace(/datum/mutantrace/zombie)


	OnRemove()
		if (istype(owner:mutantrace, /datum/mutantrace/zombie))
			owner.set_mutantrace(null)
		. = ..()

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
	effect_group = "mutantrace"
	isBad = 1
	can_copy = 0
	msgGain = "You don't feel quite right."
	msgLose = "You feel normal again."
	var/outOfPod = 0 //Out of the cloning pod.
	var/timeInCryo = 0 // Time spent in a cryo tube

	OnAdd()
		..()
		owner.set_mutantrace(/datum/mutantrace/premature_clone)
		if (!istype(owner.loc, /obj/machinery/clonepod))
			boutput(owner, SPAN_ALERT("Your genes feel...disorderly."))
		return

	OnRemove()
		..()
		if (istype(owner:mutantrace, /datum/mutantrace/premature_clone))
			owner.set_mutantrace(null)
		return

	OnLife(var/mult)
		if(..()) return
		if(!istype(owner:mutantrace, /datum/mutantrace/premature_clone))
			holder.RemoveEffect(id)

		if (outOfPod)
			if (probmult(6))
				var/vomit_message = SPAN_ALERT("[owner.name] suddenly and violently vomits!")
				owner.vomit(0, null, vomit_message)

			else if (probmult(2) && !HAS_ATOM_PROPERTY(owner, PROP_MOB_CANNOT_VOMIT))
				owner.visible_message(SPAN_ALERT("[owner.name] vomits blood!"))
				playsound(owner.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				random_brute_damage(owner, rand(5,8))
				bleed(owner, rand(5,8), 5)

			if (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell))
				if (owner.bodytemperature < owner.base_body_temp - 80 && (owner.max_health - owner.health < 10))
					// cryoxadone checks for 100 under; this is a little higher to account
					// for the healing cryoxadone does (which increases temp), given that
					// premature clones randomly take damage.
					timeInCryo++

					if (timeInCryo == 1)
						boutput(owner, SPAN_NOTICE("You feel a little better."))
					else if (timeInCryo == 5)
						// Being in cryo long enough will help fix your messed-up genes.
						timeLeft = 1
			else
				timeInCryo = 0

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
	var/personalized_stink = null

	OnAdd()
		. = ..()
		holder.owner?.UpdateParticles(new/particles/stink_lines, "stink_lines", KEEP_APART | RESET_TRANSFORM)

	OnLife(var/mult)
		if(..()) return
		if (probmult(5))
			for(var/mob/living/carbon/C in view(3,get_turf(owner)))
				if (C == owner)
					continue
				if (ispug(C))
					boutput(C, SPAN_ALERT("Wow, [owner] sure [pick("stinks", "smells", "reeks")]!"), "stink_message")
				else
					boutput(C, SPAN_ALERT("[stinkStringHygiene(owner)]"), "stink_message")
	OnRemove()
		holder.owner?.ClearSpecificParticles("stink_lines")
		. = ..()

// Magnetic Random Event
ABSTRACT_TYPE(/datum/bioEffect/hidden/magnetic)
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
		SPAWN(time)
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
