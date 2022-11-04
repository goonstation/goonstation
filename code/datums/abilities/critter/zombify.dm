// -----------------------------------
// Devour using an action as the timer
// -----------------------------------

/datum/action/bar/icon/zombifyAbility
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "critter_devour"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "zomb_over"
	var/mob/living/target
	var/datum/targetable/critter/zombify/zombify

	New(Target, Zombify)
		target = Target
		zombify = Zombify
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target == owner || !zombify || !zombify.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target == owner || !zombify || !zombify.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner] attempts to gnaw into [target]!</B></span>", 1)

	onEnd()
		..()
		var/mob/ownerMob = owner

		if(isdead(target) || target.health <= -100) //If basically dead, instaconvert.
			target.set_mutantrace(/datum/mutantrace/zombie/can_infect)
			if (target.ghost?.mind && !(target.mind && target.mind.dnr)) // if they have dnr set don't bother shoving them back in their body (Shamelessly ripped from SR code. Fight me.)
				target.ghost.show_text("<span class='alert'><B>You feel yourself being dragged out of the afterlife!</B></span>")
				target.ghost.mind.transfer_to(target)
		if(owner && ownerMob && target && (BOUNDS_DIST(owner, target) == 0) && zombify?.cooldowncheck())

			logTheThing(LOG_COMBAT, ownerMob, "zombifies [constructTarget(target,"combat")].")
			for(var/mob/O in AIviewers(ownerMob))
				O.show_message("<span class='alert'><B>[owner] successfully infected [target]!</B></span>", 1)
			playsound(ownerMob, 'sound/impact_sounds/Flesh_Crush_1.ogg', 50, 0)
			ownerMob.health = ownerMob.max_health

			target.TakeDamageAccountArmor("head", 30, 0, 0, DAMAGE_CRUSH)
			target.changeStatus("stunned", 4 SECONDS)
			target.contract_disease(/datum/ailment/disease/necrotic_degeneration/can_infect_more, null, null, 1) // path, name, strain, bypass resist

			zombify.actionFinishCooldown()

/datum/targetable/critter/zombify
	name = "Zombify"
	desc = "After a short delay, instantly convert a human into a zombie."
	icon_state = "critter_bite"
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
			target = locate(/mob/living/) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to zombify there.</span>")
				return 1
		if (!ishuman(target))
			boutput(holder.owner, "<span class='alert'>Invalid target.</span>")
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to zombify.</span>")
			return 1
		var/mob/living/carbon/human/H = target
		if (istype(H.mutantrace, /datum/mutantrace/zombie))
			boutput(holder.owner, "<span class='alert'>You can't infect another zombie!</span>")
			return 1
		actions.start(new/datum/action/bar/icon/zombifyAbility(target, src), holder.owner)
		return 0
