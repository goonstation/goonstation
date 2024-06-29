/datum/targetable/wraithAbility/choose_haunt_appearance
	name = "Choose Haunt Appearance"
	desc = "Copy the appearance of a human. When haunting, you will use the copied appearance in exact detail."
	icon_state = "choose_appearance"
	targeted = TRUE
	pointCost = 0

	cast(atom/target)
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/mob/living/intangible/wraith/wraith_trickster/W = src.holder.owner
		if (!istype(W))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if ((istype(target, /mob/living/carbon/human/)))
			var/mob/living/carbon/human/H = target
			boutput(src.holder.owner, SPAN_NOTICE("You steal [H]'s appearance for yourself."))
			W.copied_appearance = H.appearance
			W.copied_appearance.transform.Turn(H.rest_mult * -90)	//Find a way to make transform rotate.
			W.copied_desc = H.get_desc()
			W.copied_name = H.name
			W.copied_real_name = H.real_name
			W.copied_pronouns = he_or_she(H)
			W.copied_footstep_sound = H.shoes ? H.shoes.step_sound : (H.mutantrace && H.mutantrace.step_override ? H.mutantrace.step_override : "step_barefoot")
			W.copied_voice = H.voice_type
		else if (W.copied_appearance != null)
			W.copied_appearance = null
			W.copied_desc = null
			W.copied_name = null
			W.copied_real_name = null
			W.copied_pronouns = null
			W.copied_footstep_sound = null
			W.copied_voice = null
			boutput(src.holder.owner, SPAN_NOTICE("You discard your disguise."))
		else
			boutput(src.holder.owner, SPAN_ALERT("You cannot copy this appearance."))
		return CAST_ATTEMPT_SUCCESS
