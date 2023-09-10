/datum/targetable/slasher/incorporeal
	name = "Incorporealize"
	desc = "Become a ghost, capable of moving through walls."
	icon_state = "incorporealize"
	targeted = FALSE
	cooldown = 20 SECONDS

	cast()
		if(..())
			return TRUE

		var/mob/living/carbon/human/slasher/W = src.holder.owner
		if(W.hasStatus("incorporeal"))
			boutput(src.holder.owner, "<span class='alert'><span class='alert'>You must be corporeal to use this ability.</span></span>")
			return TRUE
		else
			if(src.holder.owner.client)
				for (var/mob/living/L in view(src.holder.owner.client.view, src.holder.owner))
					if (isalive(L) && L.sight_check(1) && L.ckey != src.holder.owner.ckey)
						boutput(src.holder.owner, "<span class='alert'><span class='alert'>You can only use that when nobody can see you!</span></span>")
						return TRUE
		return W.incorporealize()
