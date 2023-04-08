/datum/targetable/slasher/take_control
	name = "Possess"
	desc = "Possess a target temporarily."
	icon_state = "slasher_possession"
	targeted = TRUE
	target_anything = TRUE
	cooldown = 3 MINUTES

	cast(atom/target)
		if (..())
			return TRUE

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/mob/living/carbon/human/slasher/W = src.holder.owner
			if(H?.traitHolder?.hasTrait("training_chaplain"))
				boutput(src.holder.owner, "<span class='alert'>You cannot possess a holy man!</span>")
				JOB_XP(H, "Chaplain", 2)
				return TRUE
			if(isdead(H))
				boutput(src.holder.owner, "<span class='alert'>You cannot possess a corpse.</span>")
				return TRUE
			if(H.client)
				boutput(src.holder.owner, "<b>You begin to possess [H].</b>")
				src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				return W.take_control(H)
			else
				boutput(src.holder.owner, "<b>The target must have a consciousness to be possessed.</b>")
				return TRUE
		else
			boutput(src.holder.owner, "<span class='alert'>You cannot possess a non-human.</span>")
			return TRUE
