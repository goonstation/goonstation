/datum/aiHolder/hippo
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/hippo, list(src))

/datum/aiTask/prioritizer/critter/hippo/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/find_water, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive/melee, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(src.holder, src))

/datum/aiTask/sequence/goalbased/critter/find_water
	weight = -10

/datum/aiTask/sequence/goalbased/critter/find_water/precondition()
	. = TRUE
	for(var/turf/water in range(src.holder.owner, 3))
		////unsure if there's a better way to find "water". we want unsimulated water tiles to be work cos terrainify stuff
		if(istype(water, /turf/unsimulated/floor/pool) || istype(water, /turf/simulated/floor/pool) \
				|| istype(water, /turf/simulated/floor/auto/water) || istype(water, /turf/unsimulated/floor/auto/water))
			return FALSE

/datum/aiTask/sequence/goalbased/critter/find_water/get_targets()
	. = ..()
	for(var/turf/water in range(src.holder.owner, 8))
		if(istype(water, /turf/unsimulated/floor/pool) || istype(water, /turf/simulated/floor/pool) \
				|| istype(water, /turf/simulated/floor/auto/water) || istype(water, /turf/unsimulated/floor/auto/water))
			. += water
