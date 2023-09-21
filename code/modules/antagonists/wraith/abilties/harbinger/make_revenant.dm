/datum/targetable/wraithAbility/makeRevenant
	name = "Raise Revenant"
	icon_state = "revenant"
	desc = "Take control of an intact corpse as a powerful Revenant! You will not be able to absorb this corpse later. As a revenant, you gain increased point generation, but your revenant abilities cost much more points than normal."
	targeted = 1
	target_anything = 1
	pointCost = 1000
	cooldown = 5 MINUTES

	cast(atom/T)
		if (..())
			return 1

		if (src.holder.owner.density)
			boutput(usr, "<span class='alert'>You cannot force your consciousness into a body while corporeal.</span>")
			return 1

		//If you targeted a turf for some reason, find a corpse on it
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/target in T.contents)
				if (isdead(target) && target:decomp_stage != DECOMP_STAGE_SKELETONIZED)
					T = target
					break

		if (ishuman(T))
			var/mob/living/intangible/wraith/W = holder.owner
			. = W.makeRevenant(T)		//return 0
			if(!.)
				playsound(W.loc, 'sound/voice/wraith/reventer.ogg', 80, 0)
			return
		else
			boutput(usr, "<span class='alert'>There are no corpses here to possess!</span>")
			return 1
