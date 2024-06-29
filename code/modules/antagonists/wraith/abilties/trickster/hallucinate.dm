/datum/targetable/wraithAbility/hallucinate
	name = "Hallucinate"
	icon_state = "terror"
	desc = "Induce terror inside a mortal's mind and cause them to subtly hallucinate."
	pointCost = 30
	targeted = TRUE
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (!ishuman(target))
			boutput(src.holder.owner, SPAN_ALERT("This ability can only affect humans."))
			return
		var/mob/living/carbon/human/H = target
		if (isdead(H))
			boutput(src.holder.owner, SPAN_ALERT("This ability can only affect living targets."))
			return
		if (H.traitHolder.hasTrait("training_chaplain"))
			boutput(src.holder.owner, SPAN_ALERT("Despite your best efforts, [H] seems totally unaffected by your horrific visions!"))
		else
			boutput(src.holder.owner, SPAN_NOTICE("[H] begins to subtly hallucinate."))
			H.setStatus("terror", 45 SECONDS)
		src.holder.owner.playsound_local(src.holder.owner, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80)
		return CAST_ATTEMPT_SUCCESS
