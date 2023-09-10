/datum/targetable/wraithAbility/hallucinate
	name = "Hallucinate"
	icon_state = "terror"
	desc = "Induce terror inside a mortal's mind and make them hallucinate."
	pointCost = 30
	targeted = 1
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='notice'>Despite your best efforts, that creature seems totally unnaffected by your horrific visions.</span>")
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.setStatus("terror", 45 SECONDS)
			boutput(holder.owner, "We terrorize [H]")
			return 0
		else
			return 1
