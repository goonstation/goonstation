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
			boutput(src.holder.owner, "<span class='alert'><span class='alert'>You must be incorporeal to use this ability.</span></span>")
			return TRUE
		else
			return W.corporealize()
