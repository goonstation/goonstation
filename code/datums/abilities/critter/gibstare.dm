// ------------------------------------------------
// Martian psychic gib using an action as the timer
// ------------------------------------------------

/datum/action/bar/icon/gibstareAbility
	duration = 6 SECONDS
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	var/mob/living/target
	var/datum/targetable/critter/gibstare/ability
	var/max_range

	New(Target, Gibstare, new_duration, new_max_range = 10)
		target = Target
		ability = Gibstare
		if(new_duration)
			duration = new_duration
		max_range = new_max_range
		..()


	onStart()
		..()
		owner.visible_message(SPAN_ALERT("<B>[owner]</B> stares at [target]!"))
		playsound(owner.loc, 'sound/effects/mindkill.ogg', 50, 1)
		boutput(target, SPAN_ALERT("You feel a horrible pain in your head!"))
		target.changeStatus("stunned", 1 SECOND)
		ability.disabled = TRUE

	onEnd()
		..()
		logTheThing(LOG_COMBAT, owner, "gibs [constructTarget(target,"combat")] using Martian gib stare.")
		if (target == owner)
			boutput(owner, SPAN_SUCCESS("Good. Job."))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.head_explosion()
		else
			target.gib()
		ability.disabled = FALSE
		ability?.actionFinishCooldown()

	canRunCheck(in_start)
		. = ..()
		var/mob/M = owner
		if(isdead(M) || !(target in view(owner)) || !IN_RANGE(owner, target, max_range) || target == null || owner == null || (ability && !ability.cooldowncheck()))
			interrupt(INTERRUPT_ALWAYS)
			ability.disabled = FALSE

/datum/targetable/critter/gibstare
	name = "Psychic Stare"
	desc = "After a medium delay, instantly gib a mob. You must stand still for this and maintain vision of the target."
	cooldown = 0
	var/actual_cooldown = 600
	disabled = FALSE
	targeted = TRUE
	target_anything = TRUE

	proc/actionFinishCooldown()
		cooldown = actual_cooldown
		doCooldown()
		cooldown = initial(cooldown)

	cast(atom/target)
		if (..())
			return 1
		if (disabled)
			return
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to gib there."))
				return 1
		actions.start(new/datum/action/bar/icon/gibstareAbility(target, src), holder.owner)
		return 0
