/datum/targetable/wraithAbility/raiseSkeleton
	name = "Raise Skeleton"
	icon_state = "skeleton"
	desc = "Raise a skeletonized dead body or fill a locker with an indurable skeletal servant."
	targeted = 1
	target_anything = 1
	pointCost = 100
	cooldown = 1 MINUTE

	cast(atom/T)
		if (..())
			return 1

		//If you targeted a turf for some reason, find a corpse on it
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/target in T)
				if (isdead(target) && target.decomp_stage == DECOMP_STAGE_SKELETONIZED)
					T = target
					break
			//Or a locker
			for (var/obj/storage/closet/target in T)
				T = target
				break
			//Or a secure locker
			for (var/obj/storage/secure/closet/target in T)
				T = target
				break

		if (ishuman(T))
			var/mob/living/carbon/human/H = T
			if (!isdead(H) || H.decomp_stage != DECOMP_STAGE_SKELETONIZED)
				boutput(usr, "<span class='alert'>That body refuses to submit its skeleton to your will.</span>")
				return 1
			var/personname = H.real_name
			var/mob/living/critter/skeleton/wraith/S = new /mob/living/critter/skeleton/wraith(get_turf(T))
			S.name = "[personname]'s skeleton"
			S.health_burn = 15
			S.health_brute = 15
			H.gib()
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithraise[rand(1, 3)].ogg", 80, 0)
			return 0
		if (isobj(T))
			if (istype(T, /obj/storage/closet) || istype(T, /obj/storage/secure/closet))
				var/obj/storage/C = T
				for (var/mob/living/critter/skeleton/wraith/S in C)
					boutput(holder.owner, "That container is already rattling, you can't summon a skeleton in there!")
					return 1
				if (C.open)
					C.close()
				var/mob/living/critter/skeleton/wraith/S = new /mob/living/critter/skeleton/wraith(C)
				S.name = "Locker skeleton"
				S.health_burn = 10
				S.health_brute = 10
				S.icon = 'icons/misc/critter.dmi'
				S.icon_state = "skeleton"
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithraise[rand(1, 3)].ogg", 80, 0)
				return 0
			else
				boutput(usr, "<span class='alert'>You can't summon a skeleton there!</span>")
				return 1
		else
			boutput(usr, "<span class='alert'>There are no skeletonized corpses here to raise!</span>")
			return 1
