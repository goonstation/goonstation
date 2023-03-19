/datum/targetable/flockmindAbility/deconstruct
	name = "Mark for Deconstruction"
	desc = "Mark an existing flock structure for deconstruction, refunding some resources."
	icon_state = "destroystructure"
	cooldown = 0.1 SECONDS

/datum/targetable/flockmindAbility/deconstruct/cast(atom/target)
	if(..())
		return TRUE
	if(HAS_ATOM_PROPERTY(target,PROP_ATOM_FLOCK_THING))
		if (isflockdeconimmune(target)) // ghost structure on click opens tgui window
			return TRUE
		if (!src.tutorial_check(FLOCK_ACTION_MARK_DECONSTRUCT, target))
			return TRUE
		var/mob/living/intangible/flock/F = holder.owner
		F.flock.toggleDeconstructionFlag(target)
		return FALSE
	return TRUE
