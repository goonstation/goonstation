// This file is full of spider brains. ew.

/datum/aiHolder/spider
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/spider, list(src))

/datum/aiTask/prioritizer/critter/spider/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))

//peaceful spider
/datum/aiHolder/spider_peaceful
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/spider_peaceful, list(src))

/datum/aiTask/prioritizer/critter/spider_peaceful/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))

/datum/aiHolder/clown_spider_queen
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/clown_spider_queen, list(src))

/datum/aiTask/prioritizer/critter/clown_spider_queen/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/succeedable/critter/vomit_egg, list(holder, src))

/datum/aiTask/succeedable/critter/vomit_egg //ew clownspiders are gross
	name = "clown spider vomit egg"
	var/has_started = FALSE
/datum/aiTask/succeedable/critter/vomit_egg/evaluate()
	. = 1

/datum/aiTask/succeedable/critter/vomit_egg/on_tick()
	var/mob/living/critter/C = holder.owner
	var/datum/targetable/critter/vomitegg/egg = C.abilityHolder.getAbility(/datum/targetable/critter/vomitegg)
	if(!egg)
		egg = C.abilityHolder.getAbility(/datum/targetable/critter/vomitegg/cluwne)
	if(!has_started)
		has_started = TRUE
		for(var/turf/T in getneighbours(get_turf(holder.owner)))
			if(!is_blocked_turf(T))
				egg.handleCast(T)
				break

/datum/aiTask/succeedable/critter/vomit_egg/succeeded()
	return has_started

/datum/aiTask/succeedable/critter/vomit_egg/on_reset()
	has_started = FALSE
