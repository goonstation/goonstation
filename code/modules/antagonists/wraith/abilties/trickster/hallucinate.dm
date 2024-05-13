/datum/targetable/wraithAbility/hallucinate
	name = "Hallucinate"
	icon_state = "terror"
	desc = "Induce terror inside a mortal's mind and cause them to subtly hallucinate."
	pointCost = 30
	targeted = TRUE
	cooldown = 45 SECONDS

	castcheck(atom/target)
		if (!ishuman(target))
			boutput(src.holder.owner, SPAN_ALERT("This ability can only affect humans."))
			return
		var/mob/living/carbon/human/H = target
		if (isdead(H))
			boutput(src.holder.owner, SPAN_ALERT("This ability can only affect living targets."))
			return
		return ..()

	cast(mob/living/carbon/human/target) // We typecast in the def here because castcheck() should ensure we only get human targets
		..()
		if (target.traitHolder.hasTrait("training_chaplain"))
			boutput(src.holder.owner, SPAN_ALERT("Despite your best efforts, [target] seems totally unaffected by your horrific visions!"))
		else
			boutput(src.holder.owner, SPAN_NOTICE("[target] begins to subtly hallucinate."))
			target.setStatus("terror", 45 SECONDS)
		src.holder.owner.playsound_local(src.holder.owner, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80)
		return CAST_ATTEMPT_SUCCESS
