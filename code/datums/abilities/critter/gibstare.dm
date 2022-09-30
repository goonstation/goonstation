// ------------------------------------------------
// Martian psychic gib using an action as the timer
// ------------------------------------------------

/datum/action/bar/icon/gibstareAbility
	duration = 6 SECONDS
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "critter_devour"
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

	onUpdate()
		if(istype(owner, /obj/critter))
			var/obj/critter/ownerCritter = owner
			if (!ownerCritter.alive)
				interrupt(INTERRUPT_ALWAYS)
				return
		if(!(target in view(owner)) || !IN_RANGE(owner, target, max_range) || target == null || owner == null || (ability && !ability.cooldowncheck()))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(!(target in view(owner)) || target == null || owner == null || (ability && !ability.cooldowncheck()))
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner]</B> stares at [target]!</span>", 1)
		playsound(owner.loc, 'sound/effects/mindkill.ogg', 50, 1)
		boutput(target, "<span class='alert'>You feel a horrible pain in your head!</span>")
		target.changeStatus("stunned", 1 SECOND)

	onEnd()
		..()
		if(istype(owner, /obj/critter))
			var/obj/critter/ownerCritter = owner
			if (!ownerCritter.alive)
				interrupt(INTERRUPT_ALWAYS)
				return
		if(owner && target && (target in view(owner)) && IN_RANGE(owner, target, max_range) && (!ability || ability.cooldowncheck()))
			logTheThing(LOG_COMBAT, owner, "gibs [constructTarget(target,"combat")] using Martian gib stare.")
			for(var/mob/O in AIviewers(owner))
				O.show_message("<span class='alert'><b>[target.name]'s</b> head explodes!</span>", 1)
			if (target == owner)
				boutput(owner, "<span class='success'>Good. Job.</span>")
			target.gib()
			ability?.actionFinishCooldown()

/datum/targetable/critter/gibstare
	name = "Psychic Stare"
	desc = "After a medium delay, instantly devour a mob. You must stand still for this and maintain vision of the target."
	cooldown = 0
	var/actual_cooldown = 600
	targeted = 1
	target_anything = 1

	proc/actionFinishCooldown()
		cooldown = actual_cooldown
		doCooldown()
		cooldown = initial(cooldown)

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to gib there.</span>")
				return 1
		actions.start(new/datum/action/bar/icon/gibstareAbility(target, src), holder.owner)
		return 0
