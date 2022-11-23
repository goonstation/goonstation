/datum/targetable/brain_slug/neural_detection
	name = "Neural detection"
	desc = "Use your neural detection to expand your vision and detect brainwaves of living beings for a short moment."
	icon_state = "neural_detection"
	cooldown = 30 SECONDS
	targeted = 0
	var/active = FALSE

	cast()
		if (istype(holder, /datum/abilityHolder/brain_slug))
			src.pointCost = 5
		if (!active)
			active = TRUE
			var/mob/living/M = src.holder.owner
			APPLY_ATOM_PROPERTY(M, PROP_MOB_XRAYVISION, src)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTSPRINT, src)
			SPAWN(30 SECONDS)
				if (M)
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_XRAYVISION, src)
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTSPRINT, src)
			return FALSE
