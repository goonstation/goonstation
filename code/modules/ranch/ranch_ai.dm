// SHARED RANCH AI

// Eat
// Flee Shitter
// Fight Shitter

/datum/aiTask/sequence/goalbased/eat
	name = "eat"
	weight = HUNGER_PRIORITY
	max_dist = 10

/datum/aiTask/sequence/goalbased/eat/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/eat, list(holder)))

/datum/aiTask/sequence/goalbased/eat/precondition()
	. = 0
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(C.hunger > 20)
		. = 1
	else if (C.hunger > 10 && prob(50))
		. = 1

/datum/aiTask/sequence/goalbased/eat/evaluate()
	. = 0
	if(src.precondition())
		if(get_best_target(get_targets()))
			return HUNGER_PRIORITY

/datum/aiTask/sequence/goalbased/eat/get_targets()
	. = list()
	for(var/obj/decal/cleanable/ranch_feed/F in view(max_dist, holder.owner))
		. += F

/datum/aiTask/succeedable/eat
	max_fails = 3

	succeeded()
		. = 0
		if (holder.owner.abilityHolder && !holder.owner.equipped())
			var/datum/targetable/critter/eat_feed/EF = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/eat_feed)
			if (EF)
				. = EF.cast(holder.target)
				. = !.

/datum/aiTask/sequence/goalbased/eat/on_reset()
	..()
	holder.stop_move()
	holder.target = null

/datum/targetable/critter/eat_feed
	name = "Eat Feed"
	desc = "Eat some Feed"
	cooldown = 3 SECONDS
	start_on_cooldown = 0
	icon_state = "template"
	targeted = 1
	target_anything = 1

/datum/targetable/critter/eat_feed/cast(atom/target)
	if (..())
		return 1

	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(!istype(C))
		return 1

	var/turf/T = get_turf(target)
	if(get_dist(T,C) < 2)
		var/obj/decal/cleanable/ranch_feed/F = locate(/obj/decal/cleanable/ranch_feed) in T
		if(F)
			playsound(C.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			C.visible_message(SPAN_NOTICE("[C] eats [F]!"))
			C.on_eat_feed(F)
			qdel(F)
			return 0
	. = 1

// Flee Shitter

/datum/aiTask/timed/targeted/flee_shitter
	name = "flee shitter"
	minimum_task_ticks = 7
	maximum_task_ticks = 20
	target_range = FLEE_DISTANCE
	frustration_threshold = 3
	var/last_seek
	var/messaged = 0

/datum/aiTask/timed/targeted/flee_shitter/frustration_check()
	.= 0
	if (!IN_RANGE(holder.owner, holder.target, target_range))
		return 1

	if (ismob(holder.target))
		var/mob/M = holder.target
		. = !(holder.target && isalive(M))
	else
		. = !(holder.target)

/datum/aiTask/timed/targeted/flee_shitter/on_tick()
	var/mob/living/critter/owncritter = holder.owner
	if (HAS_ATOM_PROPERTY(owncritter, PROP_MOB_CANTMOVE))
		return

	if(length(holder.owner.grabbed_by) > 1)
		holder.owner.resist()

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

		var/dist = get_dist(owncritter, holder.target)
		if (dist > target_range)
			holder.target = null
			return ..()

		if(!messaged)
			if(prob(10))
				var/mob/living/critter/small_animal/ranch_base/C = owncritter
				if(istype(C))
					C.visible_message(SPAN_ALERT("[C] cries out in fear!"))
					C.gossip()
					messaged = 1

		holder.move_away(holder.target,target_range)
		var/mob/living/critter/small_animal/ranch_base/C = owncritter
		if(istype(C))
			C.change_happiness(-20)

	..()

/datum/aiTask/timed/targeted/flee_shitter/on_reset()
	..()
	holder.target = null
	holder.stop_move()
	messaged = 0

/datum/aiTask/timed/targeted/flee_shitter/get_targets()
	. = list()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		for(var/mob/M in C.shit_list)
			if(get_dist(M,C) <= target_range)
				if(M in view(target_range,C))
					if(isalive(M))
						. += M

/datum/aiTask/timed/targeted/flee_shitter/evaluate() // evaluate the current environment and assign priority to switching to this task
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		for(var/mob/M in C.shit_list)
			if(get_dist(M,C) < target_range)
				if(M in view(target_range,C))
					if(isalive(M))
						return FLEE_PRIORITY
	. = 0

// Fight Shitter

/datum/aiTask/timed/targeted/fight_shitter
	name = "approach and attack"
	minimum_task_ticks = 7
	maximum_task_ticks = 20
	target_range = FLEE_DISTANCE + 1
	frustration_threshold = 3
	var/last_seek
	var/messaged = 0


/datum/aiTask/timed/targeted/fight_shitter/proc/precondition()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	. = 0
	if(istype(C))
		if(C.stage > 0)
			. = 1

/datum/aiTask/timed/targeted/fight_shitter/frustration_check()
	.= 0
	if (!IN_RANGE(holder.owner, holder.target, target_range))
		return 1

	if (ismob(holder.target))
		var/mob/M = holder.target
		. = !(holder.target && !isdead(M))
	else
		. = !(holder.target)

/datum/aiTask/timed/targeted/fight_shitter/evaluate()
	..()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		if(C.hyperaggressive)
			for(var/mob/M in view(target_range,C))
				if(!isdead(M))
					if(!(M in C.my_friends))
						if(!istype(M,C.species_type))
							return precondition() * FIGHT_PRIORITY
		for(var/mob/M in C.shit_list)
			if(IN_RANGE(M,C,target_range))
				if(M in view(target_range,C))
					if(!isdead(M))
						return precondition() * FIGHT_PRIORITY
	. = 0

/datum/aiTask/timed/targeted/fight_shitter/on_tick()
	var/mob/living/critter/owncritter = holder.owner
	if (HAS_ATOM_PROPERTY(owncritter, PROP_MOB_CANTMOVE))
		return

	if(length(holder.owner.grabbed_by) > 1)
		holder.owner.resist()

	if(!holder.target)
		if (world.time > last_seek + 4 SECONDS)
			last_seek = world.time
			var/list/possible = get_targets()
			if (possible.len)
				holder.target = pick(possible)
	if(holder.target && holder.target.z == owncritter.z)
		var/mob/living/M = holder.target
		if(!isalive(M))
			holder.target = null
			holder.target = get_best_target(get_targets())
			if(!holder.target)
				return ..() // try again next tick
			else
				M = holder.target

		if(!messaged)
			if(prob(10))
				var/mob/living/critter/small_animal/ranch_base/C = owncritter
				if(istype(C))
					C.visible_message(SPAN_ALERT("[C] cries out in anger!"))
					C.gossip()
					messaged = 1

		var/dist = get_dist(owncritter, M)
		if (dist > 1)
			holder.move_to(M,1)
		else
			if(prob(66))
				var/step = get_dir(holder.owner,M)
				var/sidestep = turn(step, prob(50) ? 45 : -45)
				holder.owner.move_dir = sidestep
				holder.owner.process_move()

		if (dist <= 1)
			if (M.equipped())
				owncritter.set_a_intent(prob(66) ? INTENT_DISARM : INTENT_HARM)
			else
				owncritter.set_a_intent(INTENT_HARM)

			owncritter.hud.update_intent()
			owncritter.dir = get_dir(owncritter, M)

			if(prob(15) && holder.owner.abilityHolder)
				var/mob/living/critter/small_animal/ranch_base/C = holder.owner
				if(istype(C))
					var/datum/targetable/P = C.attack_ability
					if (P)
						P.cast(get_turf(M))
			else
				var/list/params = list()
				params["left"] = 1
				params["ai"] = 1
				owncritter.hand_attack(M, params)
				var/mob/living/critter/small_animal/ranch_base/C = owncritter
				if(istype(C))
					if(C.hyperaggressive)
						C.change_happiness(10)

		var/mob/living/critter/small_animal/ranch_base/C = owncritter
		if(istype(C))
			if(!C.hyperaggressive)
				C.change_happiness(-20)

	..()

/datum/aiTask/timed/targeted/fight_shitter/get_targets()
	. = list()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		if(C.hyperaggressive)
			for(var/mob/M in view(target_range,C))
				if(!isdead(M))
					if(!(M in C.my_friends))
						if(!istype(M,C.species_type))
							. += M
			return
		for(var/mob/M in C.shit_list)
			if(IN_RANGE(M,C,target_range))
				if(M in view(target_range,C))
					if(isalive(M))
						. += M

/datum/aiTask/timed/targeted/fight_shitter/on_reset()
	..()
	holder.target = null
	holder.stop_move()
	messaged = 0

// Follow Momma

/datum/aiTask/timed/targeted/follow_momma
	name = "follow"
	minimum_task_ticks = 10000
	maximum_task_ticks = 10000
	target_range = FLEE_DISTANCE + 1
	frustration_threshold = 3
	var/last_seek


/datum/aiTask/timed/targeted/follow_momma/proc/precondition()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	. = 0
	if(istype(C))
		if(C.stage < 1)
			. = 1

/datum/aiTask/timed/targeted/follow_momma/frustration_check()
	.= 0
	if (!IN_RANGE(holder.owner, holder.target, target_range))
		return 1

	if (ismob(holder.target))
		var/mob/M = holder.target
		. = !(holder.target && !isdead(M))
	else
		. = !(holder.target)

/datum/aiTask/timed/targeted/follow_momma/score_by_distance_only = FALSE
/datum/aiTask/timed/targeted/follow_momma/score_target(atom/target)
	. = ..()
	// I feel like this should instead be done via get_targets()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		if(C.impressionable)
			if(target in C.my_friends)
				. += 10000
		else if (C.parent == target)
			. += 10000

/datum/aiTask/timed/targeted/follow_momma/evaluate()
	..()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		for(var/mob/M in view(target_range,C))
			if(!isdead(M))
				if(C.impressionable)
					if(M in C.my_friends)
						return precondition() * FOLLOW_PRIORITY
					else if(istype(M,C.species_type))
						var/mob/living/critter/small_animal/ranch_base/R = M
						if(istype(R))
							if(R.stage > 0)
								return precondition() * FOLLOW_PRIORITY
				else if (C.parent && (M == C.parent))
					return precondition() * FOLLOW_PRIORITY

	. = 0

/datum/aiTask/timed/targeted/follow_momma/on_tick()
	var/mob/living/critter/owncritter = holder.owner
	if (HAS_ATOM_PROPERTY(owncritter, PROP_MOB_CANTMOVE))
		return

	if(length(holder.owner.grabbed_by) > 1)
		holder.owner.resist()

	if(!holder.target)
		if (world.time > last_seek + 4 SECONDS)
			last_seek = world.time
			var/list/possible = get_targets()
			if (possible.len)
				holder.target = pick(possible)
	if(holder.target && holder.target.z == owncritter.z)
		var/mob/living/M = holder.target
		if(!isalive(M))
			holder.target = null
			holder.target = get_best_target(get_targets())
			if(!holder.target)
				return ..() // try again next tick
			else
				M = holder.target

		var/dist = get_dist(owncritter, M)
		if (dist > 1)
			holder.move_to(M,1)
		else
			if(prob(66))
				var/step = get_dir(holder.owner,M)
				var/sidestep = turn(step, prob(50) ? 45 : -45)
				holder.owner.move_dir = sidestep
				holder.owner.process_move()

	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(!(holder.target in C.my_friends) && !(C.parent && (holder.target == C.parent)))
		if(C.impressionable)
			if(length(C.my_friends) > 0)
				for(var/mob/friend in C.my_friends)
					if(IN_RANGE(friend,C,target_range))
						holder.target = null
		else if(C.parent)
			if(IN_RANGE(C.parent,C,target_range))
				holder.target = null

	..()

/datum/aiTask/timed/targeted/follow_momma/get_targets()
	. = list()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		for(var/mob/M in view(target_range,C))
			if(!isdead(M))
				if(C.impressionable)
					if(M in C.my_friends)
						. += M
					else if(istype(M,C.species_type))
						var/mob/living/critter/small_animal/ranch_base/R = M
						if(istype(R))
							if(R.stage > 0)
								. += M
				else if (C.parent && (M == C.parent))
					. += M

/datum/aiTask/timed/targeted/follow_momma/on_reset()
	..()
	holder.target = null
	holder.stop_move()
