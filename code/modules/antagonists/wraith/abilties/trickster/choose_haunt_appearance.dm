/datum/targetable/wraithAbility/choose_haunt_appearance
	name = "Choose haunt appearance"
	icon_state = "choose_appearance"
	targeted = 1
	pointCost = 0

	cast(atom/target)
		if (..())
			return 1

		if(istype(holder.owner, /mob/living/intangible/wraith/wraith_trickster))
			var/mob/living/intangible/wraith/wraith_trickster/W = holder.owner
			if ((istype(target, /mob/living/carbon/human/)))
				var/mob/living/carbon/human/H = target
				boutput(holder.owner, "We steal [H]'s appearance for ourselves.")
				W.copied_appearance = H.appearance
				W.copied_appearance.transform.Turn(H.rest_mult * -90)	//Find a way to make transform rotate.
				W.copied_desc = H.get_desc()
				W.copied_name = H.name
				W.copied_real_name = H.real_name
				return 0
			else if (W.copied_appearance != null)
				W.copied_appearance = null
				W.copied_desc = null
				W.copied_name = null
				W.copied_real_name = null
				boutput(holder.owner, "We discard our disguise.")
			else
				boutput(holder.owner, "We cannot copy this appearance.")
		return 1
