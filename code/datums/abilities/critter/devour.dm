// -----------------------------------
// Devour using an action as the timer
// -----------------------------------

/datum/action/bar/icon/devourAbility
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "critter_devour"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "maneater_munch"
	var/mob/living/target
	var/datum/targetable/critter/devour/devour

	New(Target, Devour)
		target = Target
		devour = Devour
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour || !devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour || !devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner] attempts to devour [target]!</B></span>", 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(ownerMob && target && (BOUNDS_DIST(owner, target) == 0) && devour?.cooldowncheck())
			logTheThing(LOG_COMBAT, ownerMob, "devours [constructTarget(target,"combat")].")
			for(var/mob/O in AIviewers(ownerMob))
				O.show_message("<span class='alert'><B>[owner] devours [target]!</B></span>", 1)
			playsound(ownerMob, 'sound/voice/burp_alien.ogg', 50, 0)
			ownerMob.health = ownerMob.max_health
			if (target == owner)
				boutput(owner, "<span class='success'>Good. Job.</span>")
			target.remove()
			devour.actionFinishCooldown()

/datum/targetable/critter/devour
	name = "Devour"
	desc = "After a short delay, instantly devour a mob. Both you and the target must stand still for this."
	cooldown = 0
	icon_state = "maneater_munch"
	var/actual_cooldown = 200 // fuck off
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
				boutput(holder.owner, "<span class='alert'>Nothing to devour there.</span>")
				return 1
		if (!isliving(target))
			boutput(holder.owner, "<span class='alert'>Invalid target.</span>")
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to devour.</span>")
			return 1
		actions.start(new/datum/action/bar/icon/devourAbility(target, src), holder.owner)
		return 0
