// ability for gorillas that disorients non simians nearby and intimidates every nearby monkey into attacking the target
/datum/targetable/critter/roar
	name = "roar"
	desc = "Terrify your target and send all nearby monkeys to attack them"
	icon = "null"
	icon_state = "roar"
	target_anything = TRUE
	targeted = TRUE
	cooldown = 60 SECONDS

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living/carbon/human) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to roar at there."))
				return 1
		if (target == holder.owner)
			return 1
		var/mob/living/carbon/human/GT = target
		if (!istype(GT))
			boutput(holder.owner, SPAN_ALERT("Nothing to roar at there there."))
			return 1

		else

			var/obj/itemspecialeffect/screech/E = new /obj/itemspecialeffect/screech
			E.color = "#FFFFFF"
			E.setup(holder.owner.loc)
			playsound(holder.owner.loc, 'sound/voice/maneatersnarl.ogg', 70, TRUE)
			boutput(GT, SPAN_ALERT("You are overcome with fear!"))
			GT.apply_sonic_stun(0, 0, 40, 0, 50, 0, 0)

			for (var/mob/living/carbon/human/npc/monkey/ally in view(7, holder.owner.loc))
				ally.was_harmed(GT)

		return 0
