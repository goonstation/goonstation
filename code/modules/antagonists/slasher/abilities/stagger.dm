/datum/targetable/slasher/stagger
	name = "Stagger Area"
	desc = "Stagger everyone in a four tile radius of you for a short duration."
	icon_state = "stagger_group"
	targeted = FALSE
	cooldown = 35 SECONDS

	cast()
		if(..())
			return TRUE
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.staggerNearby()
