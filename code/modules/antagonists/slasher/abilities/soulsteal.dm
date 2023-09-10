/datum/targetable/slasher/soulsteal
	name = "Soul Steal"
	desc = "Steal a corpse's soul, increasing the power of your machete."
	icon_state = "soul_steal"
	targeted = TRUE
	cooldown = 15 SECONDS

	cast(atom/target)
		if(..())
			return TRUE
		var/mob/living/carbon/human/slasher/W = src.holder.owner
		var/mob/living/carbon/human/M = target
		if(M?.traitHolder?.hasTrait("training_chaplain"))
			boutput(src.holder.owner, "<span class='alert'>You cannot claim the soul of a holy man!</span>")
			JOB_XP(src.holder.owner, "Chaplain", 2)
			return TRUE
		if(isdead(M))
			if(ishuman(M) && M.hasStatus("soulstolen"))
				if (BOUNDS_DIST(W, M) > 0)
					boutput(src.holder.owner, "<span class='alert'>You must be closer in order to steal [M]'s soul.</span>")
					return TRUE
				else
					return W.soulStealSetup(M, TRUE)
			else if(ishuman(M) && (M.mind && M.mind.soul >= 100))
				if (BOUNDS_DIST(W, M) > 0)
					boutput(src.holder.owner, "<span class='alert'>You must be closer in order to steal [M]'s soul.</span>")
					return TRUE
				else
					return W.soulStealSetup(M, FALSE)
			else
				boutput(src.holder.owner, "<span class='alert'>[M]'s soul is inadequate for your purposes.</span>")
				return TRUE
		else
			boutput(src.holder.owner, "<span class='alert'>Your target must be dead in order to steal their soul.</span>")
			return TRUE
