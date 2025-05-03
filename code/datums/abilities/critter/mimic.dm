/datum/targetable/critter/mimic
	name = "Mimic Object"
	desc = "Disguise yourself as a target object."
	icon_state = "mimic"
	cooldown = 45 SECONDS
	targeted = TRUE
	target_anything = TRUE
	cooldown_after_action = TRUE
	var/d_target = null

	cast(atom/target)
		if (..())
			return TRUE
		if (!isobj(target))
			boutput(holder.owner, SPAN_ALERT("You can't mimic this!"))
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("You must be adjacent to [target] to mimic it."))
			return TRUE
		d_target = target
		var/mob/living/critter/mimic/parent = holder.owner
		actions.start(new/datum/action/bar/private/mimic(src.holder.owner, target, holder), parent)
		boutput(holder.owner, SPAN_ALERT("You begin to mimic [target]..."))
		return FALSE

/datum/action/bar/private/mimic
	duration = 2 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	var/datum/targetable/critter/mimic/mimic
	var/obj/HH
	var/mob/living/critter/mimic/M

	New(user,target,Mimic)
		HH = target
		mimic = Mimic
		M = user
		..()

	onEnd()
		..()
		var/mob/living/critter/mimic/M = src.owner
		var/datum/targetable/critter/mimic/abil = M.getAbility(/datum/targetable/critter/mimic)
		abil.afterAction()
		M.setStatus("mimic_disguise", INFINITE_STATUS)
		M.disguise_as(HH)

	onInterrupt()
		..()
		var/mob/living/critter/M = owner
		boutput(M, SPAN_ALERT("Your transformation was interrupted!"))

