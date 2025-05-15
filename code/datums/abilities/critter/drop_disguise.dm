/datum/targetable/critter/drop_disguise
	name = "Drop Disguise"
	desc = "Shed your skin and return to your base form."
	icon_state = "drop_disguise"
	cooldown = 3 SECONDS
	targeted = 0

	cast()
		if (..())
			return TRUE
		var/mob/living/critter/mimic/user = holder.owner
		SETUP_GENERIC_PRIVATE_ACTIONBAR(user, target, 2 SECONDS, /datum/targetable/critter/mimic/proc/drop, user, null, null, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION)
		boutput(holder.owner, SPAN_ALERT("You begin to shed your skin..."))
		return FALSE

	proc/drop(mob/user)
		var/mob/living/critter/mimic/parent = user
		var/datum/targetable/critter/mimic/abil = parent.getAbility(/datum/targetable/critter/mimic)
		abil.afterAction()
		parent.disguise_as(src, TRUE)
		parent.setStatus("mimic_disguise", INFINITE_STATUS, parent.pixel_amount)
