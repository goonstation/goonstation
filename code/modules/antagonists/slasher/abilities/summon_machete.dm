/datum/targetable/slasher/summon_machete
	name = "Summon Machete"
	desc = "Summon your machete to your active hand."
	icon_state = "summon_machete"
	targeted = FALSE
	cooldown = 15 SECONDS

	cast()
		if(..())
			return TRUE
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		return W.summon_machete()
