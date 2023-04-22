/datum/targetable/wraithAbility/makeRevenant
	name = "Raise Revenant"
	icon_state = "revenant"
	desc = "Take control of an intact corpse as a powerful Revenant! You will not be able to absorb this corpse later. \
				As a revenant, you gain increased point generation, but your revenant abilities cost much more points than normal."
	pointCost = 1000
	cooldown = 5 MINUTES

	cast(atom/target)
		. = ..()
		//If you targeted a turf for some reason, find a corpse on it
		if (istype(target, /turf))
			for (var/mob/living/carbon/human/H in target.contents)
				if (isdead(H) && H.decomp_stage < DECOMP_STAGE_SKELETONIZED)
					target = H
					break

		if (ishuman(target))
			var/mob/living/intangible/wraith/W = src.holder.owner
			. = W.makeRevenant(target)
			if(!.)
				playsound(W.loc, 'sound/voice/wraith/reventer.ogg', 80, 0)
		else
			boutput(src.holder.owner, "<span class='alert'>There are no corpses here to possess!</span>")
			return TRUE

	castcheck(atom/target)
		. = ..()
		if (src.holder.owner.density)
			boutput(src.holder.owner, "<span class='alert'>You cannot force your consciousness into a body while corporeal.</span>")
			return FALSE
