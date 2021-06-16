// -----------------------------------
// Devour using an action as the timer
// -----------------------------------

/datum/action/bar/icon/devourAbility
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "critter_devour"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	var/mob/living/target
	var/datum/targetable/critter/devour/devour

	New(Target, Devour)
		target = Target
		devour = Devour
		..()

	onUpdate()
		..()

		if(get_dist(owner, target) > 1 || target == null || owner == null || !devour || !devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null || !devour || !devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner] attempts to devour [target]!</B></span>", 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(ownerMob && target && IN_RANGE(owner, target, 1) && devour?.cooldowncheck())
			logTheThing("combat", ownerMob, target, "devours [constructTarget(target,"combat")].")
			for(var/mob/O in AIviewers(ownerMob))
				O.show_message("<span class='alert'><B>[owner] devours [target]!</B></span>", 1)
			playsound(get_turf(ownerMob), "sound/voice/burp_alien.ogg", 50, 0)
			ownerMob.health = ownerMob.max_health
			if (target == owner)
				boutput(owner, "<span class='success'>Good. Job.</span>")
			target.remove()
			devour.actionFinishCooldown()

/datum/targetable/critter/devour
	name = "Devour"
	desc = "After a short delay, instantly devour a mob. Both you and the target must stand still for this."
	cooldown = 0
	var/actual_cooldown = 200
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
				boutput(holder.owner, __red("Nothing to devour there."))
				return 1
		if (!isliving(target))
			boutput(holder.owner, __red("Invalid target."))
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to devour."))
			return 1
		actions.start(new/datum/action/bar/icon/devourAbility(target, src), holder.owner)
		return 0
