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
	weight = 16 //one more than attack
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
// Spike
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







/datum/aiHolder/pikaia
	exclude_from_mobs_list = 1

/datum/aiHolder/pikaia/New()
	..()
/*	var/datum/aiTask/timed/targeted/trilobite/D = get_instance(/datum/aiTask/timed/targeted/pikaia, list(src))
	var/datum/aiTask/timed/B = get_instance(/datum/aiTask/timed/bury_ability, list(src))
	D.transition_task = B
	B.transition_task = D
	default_task = D */

/datum/aiTask/timed/bury_ability
	name = "bury"
	minimum_task_ticks = 1
	maximum_task_ticks = 1

	tick()
		..()
		if (holder.owner.abilityHolder)
			var/datum/targetable/critter/bury_hide/BH = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/bury_hide)
			BH.cast(get_turf(holder.owner))

/datum/aiTask/timed/targeted/pikaia
	name = "attack"
	minimum_task_ticks = 7
	maximum_task_ticks = 26
	weight = 15
	target_range = 8
	frustration_threshold = 5
	var/last_seek = 0


/datum/aiTask/timed/targeted/pikaia/proc/precondition()
	. = 1

/datum/aiTask/timed/targeted/pikaia/frustration_check()
	.= 0
	if (!IN_RANGE(holder.owner, holder.target, target_range))
		return 1

	if (ismob(holder.target))
		var/mob/M = holder.target
		. = !(holder.target && isalive(M))
	else
		. = !(holder.target)

/datum/aiTask/timed/targeted/pikaia/evaluate()
	return precondition() * weight * score_target(get_best_target(get_targets()))

/datum/aiTask/timed/targeted/pikaia/on_tick()
	var/mob/living/critter/owncritter = holder.owner
	if (HAS_ATOM_PROPERTY(owncritter, PROP_MOB_CANTMOVE) || !isalive(owncritter))
		return

	if(!holder.target)
		if (world.time > last_seek + 4 SECONDS)
			last_seek = world.time
			var/list/possible = get_targets()
			if (possible.len)
				holder.target = pick(possible)
	if(holder.target && holder.target.z == owncritter.z)
		var/dist = GET_DIST(owncritter, holder.target)
		if (dist >= 1)
			if (prob(80))
				holder.move_to(holder.target,0)
			else
				holder.move_circ(holder.target)
		else
			holder.stop_move()

		if (ismob(holder.target))
			var/mob/living/M = holder.target
			if(!isalive(M))
				holder.target = null
				holder.target = get_best_target(get_targets())
				if(!holder.target)
					return ..() // try again next tick
			if (dist <= 1)
				owncritter.set_a_intent(INTENT_GRAB)
				owncritter.set_dir(get_dir(owncritter, M))

				var/list/params = list()
				params["left"] = 1

				if (!owncritter.equipped())
					owncritter.hand_attack(M, params)
				else
					var/obj/item/grab/G = owncritter.equipped()
					if (istype(G))
						if (G.affecting == null || G.assailant == null || G.disposed) //ugly safety
							owncritter.drop_item()

						if (G.state <= GRAB_PASSIVE)
							G.AttackSelf(owncritter)
						else
							owncritter.emote("flip")
							holder.move_away(holder.target,1)
					else
						owncritter.drop_item()
		else
			holder.move_circ(holder.target,target_range+8)

	..()

/datum/aiTask/timed/targeted/pikaia/get_targets()
	. = list()
	if(holder.owner)
		for (var/atom in by_cat[TR_CAT_PODS_AND_CRUISERS])
			var/atom/A = atom
			if (IN_RANGE(holder.owner, A, 6))
				. += A

		for(var/mob/living/M in view(target_range, holder.owner))
			if(isalive(M) && !ismobcritter(M))
				. += M
