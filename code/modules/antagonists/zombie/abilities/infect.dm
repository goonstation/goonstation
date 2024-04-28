/datum/targetable/zombie/infect
	name = "Infect"
	desc = "After a short delay, infect a human. If they are damaged enough or dead this will convert them instantly."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "critter_bite"
	cooldown = 200
	cooldown_after_action = TRUE
	disabled = FALSE
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return 1
		if (disabled)
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to zombify there."))
				return 1
		if (!ishuman(target))
			boutput(holder.owner, SPAN_ALERT("Invalid target."))
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to zombify."))
			return 1
		var/mob/living/carbon/human/H = target
		if (istype(H.mutantrace, /datum/mutantrace/zombie))
			boutput(holder.owner, SPAN_ALERT("You can't infect another zombie!"))
			return 1
		actions.start(new/datum/action/bar/icon/infect_ability(target, src), holder.owner)
		return 0

/datum/action/bar/icon/infect_ability
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "zomb_over"
	var/mob/living/target
	var/datum/targetable/zombie/infect/zombify

	New(Target, Zombify)
		target = Target
		zombify = Zombify
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target == owner || !zombify || !zombify.cooldowncheck())
			zombify.disabled = FALSE
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target == owner || !zombify || !zombify.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return
		zombify.disabled = TRUE
		owner.visible_message(SPAN_ALERT("<B>[owner] attempts to gnaw into [target]!</B>"))

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(!ownerMob || !target || (BOUNDS_DIST(ownerMob , target) > 0) || !zombify?.cooldowncheck())
			return
		if(isdead(target) || target.health <= -100) //If basically dead, instaconvert.
			target.set_mutantrace(/datum/mutantrace/zombie/can_infect)
			if (target.ghost?.mind && !target.mind.get_player()?.dnr) // if they have dnr set don't bother shoving them back in their body (Shamelessly ripped from SR code. Fight me.)
				target.ghost.show_text(SPAN_ALERT("<B>You feel yourself being dragged out of the afterlife!</B>"))
				target.ghost.mind.transfer_to(target)
		logTheThing(LOG_COMBAT, ownerMob, "zombifies [constructTarget(target,"combat")].")
		playsound(ownerMob, 'sound/impact_sounds/Flesh_Crush_1.ogg', 50, FALSE)
		ownerMob.visible_message(SPAN_ALERT("<B>[ownerMob ] successfully infected [target]!</B>"))
		ownerMob.health = ownerMob.max_health
		target.TakeDamageAccountArmor("head", 30, 0, 0, DAMAGE_CRUSH)
		target.changeStatus("stunned", 4 SECONDS)
		target.contract_disease(/datum/ailment/disease/necrotic_degeneration/can_infect_more, null, null, 1) // path, name, strain, bypass resist
		zombify.disabled = FALSE
		zombify.afterAction()
