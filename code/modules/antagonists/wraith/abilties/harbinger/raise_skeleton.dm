/datum/targetable/wraithAbility/raiseSkeleton
	name = "Raise Skeleton"
	icon_state = "skeleton"
	desc = "Raise a skeletonized dead body or fill a locker with an indurable skeletal servant."
	pointCost = 100
	cooldown = 1 MINUTE

	cast(atom/target)
		//If you targeted a turf for some reason, find a corpse on it
		if (istype(target, /turf))
			for (var/mob/living/carbon/human/H in target)
				if (isdead(H) && H.decomp_stage == DECOMP_STAGE_SKELETONIZED)
					target = H
					break
			//Or a locker
			if (!target)
				target = locate(/obj/storage/closet) in target
			//Or a secure locker
			if (!target)
				target = locate(/obj/storage/secure/closet/) in target

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (!isdead(H) || H.decomp_stage != DECOMP_STAGE_SKELETONIZED)
				boutput(src.holder.owner, "<span class='alert'>That body refuses to submit its skeleton to your will.</span>")
				return TRUE
			var/personname = H.real_name
			var/mob/living/critter/skeleton/wraith/skele = new /mob/living/critter/skeleton/wraith(get_turf(target))
			skele.name = "[personname]'s skeleton"
			skele.health_burn = 15
			skele.health_brute = 15
			H.gib()
			src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/wraith/wraithraise[rand(1, 3)].ogg", 80, 0)
		else if (isobj(target))
			if (istype(target, /obj/storage/closet) || istype(target, /obj/storage/secure/closet))
				var/obj/storage/C = target
				if (locate(/mob/living/critter/skeleton/wraith) in target)
					boutput(holder.owner, "That container is already rattling, you can't summon a skeleton in there!")
					return TRUE
				if (C.open)
					C.close()
				var/mob/living/critter/skeleton/wraith/S = new /mob/living/critter/skeleton/wraith(C)
				S.name = "Locker skeleton"
				S.health_burn = 10
				S.health_brute = 10
				S.icon = 'icons/misc/critter.dmi'
				S.icon_state = "skeleton"
				src.holder.owner.playsound_local(src.holder.owner.loc, "sound/voice/wraith/wraithraise[rand(1, 3)].ogg", 80, 0)
			else
				boutput(src.holder.owner, "<span class='alert'>You can't summon a skeleton there!</span>")
				return TRUE
		else
			boutput(src.holder.owner, "<span class='alert'>There are no skeletonized corpses here to raise!</span>")
			return TRUE

	castcheck(atom/target)
		. = ..()
		if (ismob(target) && !ishuman(target))
			boutput(src.holder.owner, "<span class=alert>We need a human skeleton to raise...</span>")
			return FALSE
