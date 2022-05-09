/datum/targetable/critter/skeleton_commander/rally
	name = "rally"
	desc = "rally"
	icon_state = "clown_spider_bite"
	cooldown = 10 SECOND
	targeted = 0

	cast()
		if (..())
			return 1

		//Get list of stuff you can buff
		//Look for them
		//Buff them

/datum/targetable/critter/skeleton_commander/summon_lesser_skeleton
	name = "summon lesser skeleton"
	desc = "rally"
	icon_state = "clown_spider_bite"
	cooldown = 10 SECOND
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1
		var/turf/T = get_turf(target)
		if (isturf(T))
			new /obj/critter/wraithskeleton(T)
			boutput(holder.owner, "Make skeleton")
