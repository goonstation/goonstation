/datum/targetable/slasher/regenerate
	name = "Regenerate"
	desc = "Regenerate your body, and remove all restraints."
	icon_state = "regenerate"
	targeted = FALSE
	cooldown = 75 SECONDS

	cast()
		if(..())
			return TRUE

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.regenerate()
