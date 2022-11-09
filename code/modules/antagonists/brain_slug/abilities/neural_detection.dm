/datum/targetable/brain_slug/neural_detection
	name = "Neural detection"
	desc = "Slow yourself down to open your senses and expand your vision."
	icon_state = "neural_detection"
	cooldown = 2 SECONDS
	targeted = 0
	var/active = FALSE

	cast()
		active = !active
		if (!istype(holder.owner, /mob/living/carbon/human) && !istype(holder.owner, /mob/living/critter/small_animal)) return TRUE
		var/mob/living/carbon/human/temp_human = null
		var/mob/living/critter/small_animal/temp_animal = null
		if (istype(holder.owner, /mob/living/carbon/human))
			temp_human = holder.owner
		if (istype(holder.owner, /mob/living/critter/small_animal))
			temp_animal = holder.owner
		if (active)
			APPLY_ATOM_PROPERTY(src.holder.owner, PROP_MOB_XRAYVISION, src)
			APPLY_ATOM_PROPERTY(src.holder.owner, PROP_MOB_CANTSPRINT, src)
			if (temp_human) temp_human.slug_vision = TRUE
			if (temp_animal) temp_animal.slug_vision = TRUE
		else
			REMOVE_ATOM_PROPERTY(src.holder.owner, PROP_MOB_XRAYVISION, src)
			REMOVE_ATOM_PROPERTY(src.holder.owner, PROP_MOB_CANTSPRINT, src)
			if (temp_human) temp_human.slug_vision = FALSE
			if (temp_animal) temp_animal.slug_vision = FALSE
		return FALSE

	disposing()
		REMOVE_ATOM_PROPERTY(src.holder.owner, PROP_MOB_XRAYVISION, src)
		REMOVE_ATOM_PROPERTY(src.holder.owner, PROP_MOB_CANTSPRINT, src)
		. = ..()
