/datum/targetable/slasher/blood_trail
	name = "Blood Trail"
	desc = "Begin trailing blood behind you, to spook those who reside on station."
	icon_state = "trail_blood"
	targeted = FALSE
	cooldown = 5 SECONDS

	cast()
		if(..())
			return TRUE

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.blood_trail()
