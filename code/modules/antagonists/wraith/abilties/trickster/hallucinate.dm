/datum/targetable/wraithAbility/hallucinate
	name = "Hallucinate"
	icon_state = "terror"
	desc = "Induce terror inside a mortal's mind and cause them to subtly hallucinate."
	pointCost = 30
	targeted = TRUE
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return TRUE

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, SPAN_ALERT("Despite your best efforts, [H] seems totally unaffected by your horrific visions!"))
			else
				boutput(holder.owner, SPAN_NOTICE("[H] begins to subtly hallucinate."))
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80)
			H.setStatus("terror", 45 SECONDS)
			return
		return TRUE
