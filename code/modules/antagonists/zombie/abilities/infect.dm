/datum/targetable/zombie/infect
	name = "Infect"
	desc = "After a short delay, infect a human. If they are dead or very damaged, they will become a zombie instantly; otherwise, they will succumb gradually unless treated quickly."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "critter_bite"
	cooldown = 20 SECONDS
	cooldown_after_action = TRUE
	disabled = FALSE
	targeted = TRUE
	target_anything = TRUE

	castcheck(atom/target)
		return !src.disabled

	cast(atom/target)
		if (..())
			return TRUE
		if (src.holder.owner == target)
			boutput(src.holder.owner, SPAN_ALERT("You try to give yourself a zombie infection."))
			boutput(src.holder.owner, SPAN_ALERT("But you're already totally sick."))
			return TRUE
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/) in target
			if (!target)
				boutput(src.holder.owner, SPAN_ALERT("Nothing to zombify there."))
				return TRUE
		if (!ishuman(target))
			boutput(src.holder.owner, SPAN_ALERT("Invalid target."))
			return TRUE
		if (BOUNDS_DIST(src.holder.owner, target) > 0)
			boutput(src.holder.owner, SPAN_ALERT("That is too far away to zombify."))
			return TRUE
		var/mob/living/carbon/human/H = target
		if (istype(H.mutantrace, /datum/mutantrace/zombie))
			boutput(src.holder.owner, SPAN_ALERT("You can't infect another zombie!"))
			return TRUE
		src.holder.owner.set_dir(get_dir(src.holder.owner, target))
		actions.start(new/datum/action/bar/icon/infect_ability(target, src), src.holder.owner)
		return

/datum/action/bar/icon/infect_ability
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "zomb_over"
	var/mob/living/target
	var/datum/targetable/zombie/infect/zombify

	New(Target, Zombify)
		src.target = Target
		src.zombify = Zombify
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(src.owner, src.target) > 0 || src.target == null || src.owner == null || src.target == owner || !src.zombify || !src.zombify.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(src.owner, src.target) > 0 || src.target == null || src.owner == null || src.target == owner || !src.zombify || !src.zombify.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return
		src.zombify.disabled = TRUE
		src.owner.tri_message(src.target,
			SPAN_ALERT("<b>[src.owner]</b> attempts to gnaw into [src.target]!"),
			SPAN_ALERT("You start trying to gnaw into [src.target]!"),
			SPAN_ALERT(SPAN_BOLD("[src.owner] is trying to [pick("gnaw on you like a dog bone", "sink [his_or_her(src.owner)] teeth into you", "bite you")]!!!"))
		)

	onInterrupt()
		src.zombify.disabled = FALSE
		src.owner.tri_message(src.target,
			SPAN_ALERT("<b>[src.owner]</b> gnashes [his_or_her(src.owner)] teeth in frustration!"),
			SPAN_ALERT("[src.target != null ? "Your attempt to infect [src.target] was" : "You were"] interrupted!"),
			SPAN_ALERT(SPAN_BOLD("[src.owner] was unable to bite you!"))
		)
		..()

	onEnd()
		..()
		var/mob/ownerMob = src.owner
		if(!ownerMob || !src.target || (BOUNDS_DIST(ownerMob , src.target) > 0) || !src.zombify?.cooldowncheck())
			return
		var/insta_convert
		if(isdead(src.target) || src.target.health <= -100) //If basically dead, instaconvert.
			insta_convert = TRUE
			src.target.set_mutantrace(/datum/mutantrace/zombie/can_infect)
			if (src.target.ghost?.mind && !src.target.mind.get_player()?.dnr) // if they have dnr set don't bother shoving them back in their body (Shamelessly ripped from SR code. Fight me.)
				src.target.ghost.show_text(SPAN_ALERT("<B>You feel yourself being dragged out of the afterlife!</B>"))
				src.target.ghost.mind.transfer_to(src.target)
		logTheThing(LOG_COMBAT, ownerMob, "zombifies [constructTarget(src.target,"combat")].")
		playsound(ownerMob, 'sound/impact_sounds/Flesh_Crush_1.ogg', 50, FALSE)
		src.owner.tri_message(src.target,
			SPAN_ALERT("<b>[src.owner]</b> [pick("bites [src.target] as hard as [he_or_she(src.owner)] can", "sinks [his_or_her(src.owner)] teeth deep into [src.target]")]!!!"),
			SPAN_ALERT("You successfully [insta_convert ? "turn [src.target] into a zombie" : "infect [src.target]"]!"),
			SPAN_ALERT(SPAN_BOLD("<font size=+2>[src.owner] sinks [his_or_her(src.owner)] teeth deep into your flesh! OH GOD!!!</font>"))
		)
		ownerMob.health = ownerMob.max_health
		src.target.TakeDamageAccountArmor("head", 30, 0, 0, DAMAGE_CRUSH)
		src.target.changeStatus("stunned", 4 SECONDS)
		src.target.contract_disease(/datum/ailment/disease/necrotic_degeneration/can_infect_more, null, null, 1) // path, name, strain, bypass resist
		src.zombify.disabled = FALSE
		src.zombify.afterAction()

