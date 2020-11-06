// basically just a c/p of devour with stuff renamed.  idk.

// -----------------------------------
// Envelope using an action as the timer
// -----------------------------------

/datum/action/bar/icon/envelopeAbility
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "critter_envelope"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	var/mob/living/target
	var/datum/targetable/critter/envelope/envelope

	New(Target, Envelope)
		target = Target
		envelope = Envelope
		..()

	onUpdate()
		..()

		if (get_dist(owner, target) > 1 || target == null || owner == null || !envelope || !envelope.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (get_dist(owner, target) > 1 || target == null || owner == null || !envelope || !envelope.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		for (var/mob/O in AIviewers(owner))
			O.show_message("<span class='combat'><B>[owner]</B> starts to envelop [target]!</span>", 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if (ownerMob && target && IN_RANGE(owner, target, 1) && envelope?.cooldowncheck())
			logTheThing("combat", target, ownerMob, "was enveloped by [constructTarget(ownerMob,"combat")] (mob) at [log_loc(ownerMob)].")
			for (var/mob/O in AIviewers(ownerMob))
				O.show_message("<span class='combat'><B>[ownerMob]</B> completely envelops [target]!</span>", 1)
			playsound(get_turf(ownerMob), "sound/impact_sounds/Slimy_Hit_4.ogg", 50, 1)
			ownerMob.health = ownerMob.max_health
			if (target == owner)
				boutput(owner, "<span class='success'>Good. Job.</span>")
			target.death()
			target.ghostize()
			if (iscarbon(target))
				for (var/obj/item/W in target)
					if (istype(W,/obj/item))
						target.u_equip(W)
						if (W)
							W.set_loc(target.loc)
							W.dropped(target)
							W.layer = initial(W.layer)
			envelope.actionFinishCooldown()
			qdel(target)

/datum/targetable/critter/envelope
	name = "Envelope"
	desc = "After a short delay, instantly envelope a mob. Both you and the target must stand still for this."
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
				boutput(holder.owner, __red("Nothing to envelope there."))
				return 1
		if (!istype(target, /mob/living))
			boutput(holder.owner, __red("Invalid target."))
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to envelope."))
			return 1
		actions.start(new/datum/action/bar/icon/envelopeAbility(target, src), holder.owner)
		return 0
