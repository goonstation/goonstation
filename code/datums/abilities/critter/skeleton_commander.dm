////////////////////////////////
// Skeleton commander abilities
////////////////////////////////
/datum/targetable/critter/skeleton_commander/rally
	name = "rally"
	desc = "rally"
	icon_state = "clown_spider_bite"
	cooldown = 10 SECOND
	targeted = 0
	//List of critters we can buff, same as the one the wraith portal has.
	var/list/critter_list = list(/obj/critter/shade,
	/obj/critter/crunched,
	/obj/critter/ancient_thing,
	/obj/critter/ancient_repairbot/security,
	/obj/critter/gunbot/drone/buzzdrone,
	/obj/critter/mechmonstrositycrawler,
	/obj/critter/bat/buff,
	/obj/critter/lion,
	/obj/critter/wraithskeleton,
	/obj/critter/spider/aggressive,
	/obj/critter/gunbot/heavy,
	/obj/critter/bear,
	/obj/critter/brullbar,
	/obj/critter/gunbot/drone)

	cast()
		if (..())
			return 1

		var/list/obj/critter/affected_critter = list()
		for (var/obj/critter/C in range(6, get_turf(holder.owner)))
			for (var/obj/O in critter_list)
				if (istype(C, O))
					C.health = C.health * 2 + 10
					affected_critter += C
					//Todo maybe add a damage/speed/seekrange buff, add a sound effect and maybe overlay
		SPAWN(25 SECOND)
			for (var/obj/critter/C in affected_critter)
				if (C.loc)
					C.health = C.health / 2



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
			new /obj/critter/wraithskeleton(T)//Todo animate a fade in
			boutput(holder.owner, "We summon a skeleton from the void")
		else
			boutput(holder.owner, "We cannot summon a skeleton here")
			return 1
