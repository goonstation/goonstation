// This file is full of spider brains. ew.

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
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/vomit_egg, list(holder, src))

/datum/aiTask/sequence/goalbased/critter/vomit_egg
	name = "clown spider vomit egg"
	weight = 1
	max_dist = 5
	distance_from_target = 0
	var/max_spiders = 4

/datum/aiTask/sequence/goalbased/critter/vomit_egg/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/vomit_egg, list(holder)))

/datum/aiTask/sequence/goalbased/critter/vomit_egg/precondition()
	var/mob/living/critter/spider/clownqueen/C = holder.owner
	var/datum/targetable/critter/vomitegg/egg = C.abilityHolder.getAbility(/datum/targetable/critter/vomitegg)
	if (!egg)
		egg = C.abilityHolder.getAbility(/datum/targetable/critter/vomitegg/cluwne)
	if (C.babies)
		for (var/datum/weakref/ref as anything in C.babies)
			if (ref.deref() == null)
				C.babies.Remove(ref)
	return !egg.disabled && (length(C.babies) < max_spiders)

/datum/aiTask/sequence/goalbased/critter/vomit_egg/get_targets()
	. = list()
	for(var/turf/T in view(max_dist, holder.owner))
		if(!is_blocked_turf(T))
			. += T

/datum/aiTask/succeedable/critter/vomit_egg //ew clownspiders are gross
	name = "clown spider vomit egg subtask"
	max_dist = 3
	var/has_started = FALSE

/datum/aiTask/succeedable/critter/vomit_egg/failed()
	var/mob/living/critter/C = holder.owner
	if (!C)
		return TRUE

/datum/aiTask/succeedable/critter/vomit_egg/evaluate()
	. = 1

/datum/aiTask/succeedable/critter/vomit_egg/on_tick()
	var/mob/living/critter/C = holder.owner
	var/datum/targetable/critter/vomitegg/egg = C.abilityHolder.getAbility(/datum/targetable/critter/vomitegg)
	if(!egg)
		egg = C.abilityHolder.getAbility(/datum/targetable/critter/vomitegg/cluwne)
	if(!has_started)
		for(var/turf/T in view(max_dist, holder.owner))
			if(!is_blocked_turf(T))
				egg.handleCast(T)
				src.has_started = TRUE
				break

/datum/aiTask/succeedable/critter/vomit_egg/succeeded()
	return src.has_started

/datum/aiTask/succeedable/critter/vomit_egg/on_reset()
	src.has_started = FALSE



/datum/aiHolder/tutorial_clown_spider_queen
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/tutorial_clown_spider_queen, list(src))

/datum/aiTask/prioritizer/critter/tutorial_clown_spider_queen/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))
