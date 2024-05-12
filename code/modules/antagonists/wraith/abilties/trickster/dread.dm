/datum/targetable/wraithAbility/dread
	name = "Creeping Dread"
	icon_state = "dread"
	desc = "Instill a fear of the dark in a human's mind, causing terror and heart attacks if they do not stay in the light."
	pointCost = 80
	targeted = TRUE
	cooldown = 1 MINUTE

	cast(mob/target)
		if (..())
			return TRUE

		if (ishuman(target) && !isdead(target))
			var/mob/living/carbon/human/H = target
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, SPAN_ALERT("This one does not fear what lurks in the dark. Your effort is wasted."))
				return
			boutput(holder.owner, SPAN_NOTICE("You curse this being with a creeping feeling of dread."))
			H.setStatus("creeping_dread", 30 SECONDS)
			holder.owner.playsound_local(holder.owner, "sound/voice/wraith/wraithspook[pick("1","2")].ogg", 60)
			return

		return TRUE
