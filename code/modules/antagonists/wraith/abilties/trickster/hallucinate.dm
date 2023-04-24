/datum/targetable/wraithAbility/hallucinate
	name = "Hallucinate"
	icon_state = "terror"
	desc = "Induce terror inside a mortal's mind and make them hallucinate."
	pointCost = 30
	target_anything = FALSE
	cooldown = 45 SECONDS

	cast(mob/living/target)
		. = ..()
		src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
		target.setStatus("terror", 45 SECONDS)
		boutput(holder.owner, "<span class='hint'>We terrorize [target].</span>")

	castcheck(mob/living/target)
		. = ..()
		if (target.traitHolder.hasTrait("training_chaplain"))
			boutput(holder.owner, "<span class='alert'>Despite your best efforts, \
										that creature seems totally unnaffected by your horrific visions.</span>")
			return FALSE
