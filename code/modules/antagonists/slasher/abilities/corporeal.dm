/datum/targetable/slasher/corporeal
	name = "Corporealize"
	desc = "Manifest your being, allowing you to interact with the world."
	icon_state = "corporealize"
	targeted = FALSE
	cooldown = 20 SECONDS

	cast()
		if(..())
			return TRUE

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		if(!W.hasStatus("incorporeal"))
			boutput(src.holder.owner, SPAN_ALERT("[SPAN_ALERT("You must be incorporeal to use this ability.")]"))
			return TRUE
		else
			return W.corporealize()
