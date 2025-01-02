//----------------------------------------------------------------------------------
// Trilobite
//----------------------------------------------------------------------------------

/datum/aiHolder/trilobite
	exclude_from_mobs_list = 1

/datum/aiHolder/trilobite/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/critter/trilobite, list(src))

/datum/aiTask/prioritizer/critter/trilobite/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/bury_ability, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/escape_vehicles, list(holder, src))

/datum/aiTask/timed/bury_ability
	name = "bury"
	minimum_task_ticks = 1
	maximum_task_ticks = 10
	weight = 5

/datum/aiTask/timed/bury_ability/evaluate()
	var/mob/living/critter/C = holder.owner
	return weight * (length(C.seek_target()) == 0)

/datum/aiTask/timed/bury_ability/tick()
	..()
	if(istype(holder.owner.loc, /obj/overlay/tile_effect/cracks/))
		return

	if (holder.owner.abilityHolder && !holder.owner.equipped())
		var/datum/targetable/critter/bury_hide/BH = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/bury_hide)
		if (BH)
			BH.cast(get_turf(holder.owner))

/datum/aiTask/timed/targeted/escape_vehicles
	name = "escape"
	minimum_task_ticks = 1
	maximum_task_ticks = 4
	target_range = 7
	frustration_threshold = 10
	weight = 11 //one more than attack
	var/last_seek = 0


/datum/aiTask/timed/targeted/escape_vehicles/frustration_check()
	. = 0
	if (IN_RANGE(holder.owner, holder.target, target_range/2))
		. = 1

/datum/aiTask/timed/targeted/escape_vehicles/on_tick()
	if (HAS_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE))
		return

	if(!holder.target)
		if (world.time > last_seek + 4 SECONDS)
			last_seek = world.time
			var/list/possible = get_targets()
			if (possible.len)
				holder.target = pick(possible)
	if(holder.target)
		holder.move_away(holder.target,target_range)

	..()

/datum/aiTask/timed/targeted/escape_vehicles/get_targets()
	. = list()
	if(holder.owner)
		for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
			var/atom/A = atom
			if (IN_RANGE(holder.owner, A, target_range))
				. += A

//----------------------------------------------------------------------------------
// Spike (Hallucigenia)
//----------------------------------------------------------------------------------

/datum/aiHolder/spike
	exclude_from_mobs_list = 1

/datum/aiHolder/spike/New()
	..()
	default_task = get_instance(/datum/aiTask/timed/targeted/flee_and_shoot, list(src))

/datum/aiHolder/spike/was_harmed(obj/item/W, mob/M)
	switch_to(get_instance(/datum/aiTask/timed/targeted/flee_and_shoot, list(src)))
	current_task.reset()

/datum/aiTask/timed/targeted/flee_and_shoot
	name = "attack"
	minimum_task_ticks = 7
	maximum_task_ticks = 20
	weight = 15
	target_range = 7
	frustration_threshold = 3
	var/last_seek

/datum/aiTask/timed/targeted/flee_and_shoot/frustration_check()
	.= 0
	if (!IN_RANGE(holder.owner, holder.target, target_range))
		return 1

	if (ismob(holder.target))
		var/mob/M = holder.target
		. = !(holder.target && isalive(M))
	else
		. = !(holder.target)

/datum/aiTask/timed/targeted/flee_and_shoot/on_tick()
	var/mob/living/critter/owncritter = holder.owner
	if (HAS_ATOM_PROPERTY(owncritter, PROP_MOB_CANTMOVE))
		return

	if(!holder.target && world.time > last_seek + 5 SECONDS)
		last_seek = world.time
		var/list/possible = get_targets()
		if (possible.len)
			holder.target = pick(possible)
		if (!holder.target)
			holder.wait()

	if(holder.target && holder.target.z == owncritter.z)
		if (ismob(holder.target))
			var/mob/living/M = holder.target
			if(!isalive(M))
				holder.target = null
				holder.target = get_best_target(get_targets())
				if(!holder.target)
					return ..() // try again next tick

		var/dist = GET_DIST(owncritter, holder.target)
		if (dist > target_range)
			holder.target = null
			return ..()

		holder.move_away(holder.target,target_range)

		owncritter.set_a_intent(INTENT_HARM)

		owncritter.set_dir(get_dir(owncritter, holder.target))

		var/list/params = list()
		params["left"] = 1
		params["ai"] = 1
		owncritter.hand_range_attack(holder.target, params)

	..()

/datum/aiTask/timed/targeted/flee_and_shoot/get_targets()
	. = list()
	if(holder.owner)
		for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
			var/atom/A = atom
			if (IN_RANGE(holder.owner, A, 6))
				. += A
		for(var/mob/living/M in view(target_range, holder.owner))
			if(isalive(M) && !ismobcritter(M))
				. += M



//----------------------------------------------------------------------------------
// Pikaia
//----------------------------------------------------------------------------------

/datum/aiHolder/pikaia
	exclude_from_mobs_list = 1

/datum/aiHolder/pikaia/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/critter/pikaia, list(src))

/datum/aiTask/prioritizer/critter/pikaia/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/bury_ability, list(holder, src))

