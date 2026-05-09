// ability for gorillas that disorients non simians nearby and intimidates every nearby monkey into attacking the target
/datum/targetable/critter/roar
	name = "Roar"
	desc = "Terrify your target and send all nearby monkeys to attack them"
	icon_state = "roar"
	target_anything = TRUE
	targeted = TRUE
	cooldown = 60 SECONDS

	cast(atom/target)
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/carbon/human) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to roar at there."))
				return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (target == holder.owner)
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/mob/living/carbon/human/victim = target
		if (!istype(victim))
			boutput(holder.owner, SPAN_ALERT("Nothing to roar at there there."))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE

		else

			var/obj/itemspecialeffect/screech/roar_effect = new /obj/itemspecialeffect/screech
			roar_effect.color = "#ce0c0c"
			roar_effect.setup(holder.owner.loc)
			playsound(holder.owner.loc, 'sound/voice/maneatersnarl.ogg', 70, TRUE)
			boutput(victim, SPAN_ALERT("You are overcome with fear!"))
			victim.apply_sonic_stun(0, 0, 40, 0, 50, 0, 0)

			for (var/mob/living/carbon/human/npc/monkey/ally in view(7, holder.owner.loc))
				ally.was_harmed(victim)

		return CAST_ATTEMPT_SUCCESS
