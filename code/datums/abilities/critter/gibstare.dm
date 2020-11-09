// ------------------------------------------------
// Martian psychic gib using an action as the timer
// ------------------------------------------------

/datum/action/bar/icon/gibstareAbility
	duration = 60
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "critter_devour"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	var/mob/living/target
	var/datum/targetable/critter/gibstare/gibstare

	New(Target, Gibstare)
		target = Target
		gibstare = Gibstare
		..()

	onUpdate()
		..()

		if(!(target in view(owner)) || target == null || owner == null || !gibstare || !gibstare.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(!(target in view(owner)) || target == null || owner == null || !gibstare || !gibstare.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner]</B> stares at [target]!</span>", 1)
		var/mob/ownerMob = owner
		playsound(ownerMob.loc, "sound/weapons/phaseroverload.ogg", 100, 1)
		boutput(target, "<span class='alert'>You feel a horrible pain in your head!</span>")
		target.changeStatus("stunned", 1 SECOND)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(ownerMob && target && (target in view(owner)) && gibstare?.cooldowncheck())
			logTheThing("combat", ownerMob, target, "gibs [constructTarget(target,"combat")] using martin gib stare.")
			for(var/mob/O in AIviewers(ownerMob))
				O.show_message("<span class='alert'><b>[target.name]'s</b> head explodes!</span>", 1)
			if (target == owner)
				boutput(owner, "<span class='success'>Good. Job.</span>")
			target.gib()
			gibstare.actionFinishCooldown()

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
				boutput(holder.owner, __red("Nothing to gib there."))
				return 1
		actions.start(new/datum/action/bar/icon/gibstareAbility(target, src), holder.owner)
		return 0
