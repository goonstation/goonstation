/datum/targetable/critter/mimic
	name = "Mimic Object"
	desc = "Disguise yourself as a target object."
	icon_state = "mimic"
	cooldown = 45 SECONDS
	targeted = TRUE
	target_anything = TRUE
	cooldown_after_action = TRUE

	cast(atom/target)
		if (..())
			return TRUE
		if (!isobj(target))
			boutput(holder.owner, SPAN_ALERT("You can't mimic this!"))
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("You must be adjacent to [target] to mimic it."))
			return TRUE
		var/datum/targetable/critter/stomach_retreat/stomach_abil = src.holder.getAbility(/datum/targetable/critter/stomach_retreat)
		if (stomach_abil?.inside)
			return TRUE
		var/mob/living/critter/mimic/user = holder.owner
		SETUP_GENERIC_PRIVATE_ACTIONBAR(user, target, 2 SECONDS, /datum/targetable/critter/mimic/proc/mimic, user, null, null, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION)
		boutput(holder.owner, SPAN_ALERT("You begin to mimic [target]..."))
		return FALSE

	proc/mimic(mob/user)
		var/mob/living/critter/mimic/parent = user
		var/datum/targetable/critter/mimic/abil = parent.getAbility(/datum/targetable/critter/mimic)
		abil.afterAction()
		parent.disguise_as(src)
		if (istype(parent, /mob/living/critter/mimic/antag_spawn))
			parent.setStatus("mimic_disguise", INFINITE_STATUS, parent.pixel_amount)

