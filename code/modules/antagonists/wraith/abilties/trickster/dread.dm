/datum/targetable/wraithAbility/dread
	name = "Creeping Dread"
	icon_state = "dread"
	desc = "Instill a fear of the dark in a human's mind, causing terror and heart attacks if they do not stay in the light."
	pointCost = 80
	targeted = TRUE
	cooldown = 1 MINUTE

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
			boutput(src.holder.owner, SPAN_ALERT("This one does not fear what lurks in the dark. Your effort is wasted."))
		else
			boutput(src.holder.owner, SPAN_NOTICE("You curse this being with a creeping feeling of dread."))
			H.setStatus("creeping_dread", 30 SECONDS)
		src.holder.owner.playsound_local(src.holder.owner, "sound/voice/wraith/wraithspook[pick("1","2")].ogg", 60)
		return CAST_ATTEMPT_SUCCESS
