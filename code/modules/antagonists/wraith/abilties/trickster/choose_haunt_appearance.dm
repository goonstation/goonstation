/datum/targetable/wraithAbility/choose_haunt_appearance
	name = "Choose Haunt Appearance"
	desc = "Pick a human to copy the appearance of. Use on a nonhuman to discard the current disguise."
	icon_state = "choose_appearance"
	pointCost = 0

	cast(atom/target)
		. = ..()
		var/mob/living/intangible/wraith/wraith_trickster/W = holder.owner
		if (istype(target, /mob/living/carbon/human/))
			var/mob/living/carbon/human/H = target
			boutput(holder.owner, "<span class='success'>We steal [H]'s appearance for ourselves.</span>")
			W.copied_appearance = H.appearance
			W.copied_appearance.transform.Turn(H.rest_mult * -90)	//Find a way to make transform rotate.
			W.copied_desc = H.get_desc()
			W.copied_name = H.name
			W.copied_real_name = H.real_name
			W.copied_pronouns = he_or_she(H)
			return FALSE
		else if (W.copied_appearance != null)
			W.copied_appearance = null
			W.copied_desc = null
			W.copied_name = null
			W.copied_real_name = null
			W.copied_pronouns = null
			boutput(holder.owner, "<span class='alert'>We discard our disguise.</span>")
		else
			boutput(holder.owner, "<span class='alert'>We cannot copy this appearance.</span>")
