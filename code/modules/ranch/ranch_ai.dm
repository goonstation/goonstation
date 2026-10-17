// SHARED RANCH AI

// Eat
// Flee Shitter
// Fight Shitter

/datum/aiTask/sequence/goalbased/eat
	name = "eat"
	weight = HUNGER_PRIORITY
	max_dist = 10
	var/eat_bodies = FALSE

/datum/aiTask/sequence/goalbased/eat/New(parentHolder, transTask)
	..(parentHolder, transTask)
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	src.eat_bodies = C.eat_dead_mobs
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
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(src.precondition())
		if(get_best_target(get_targets()))
			// Don't starve to death chasing after things
			return (C.hunger > RANCH_HUNGER_STARVING) ? STARVING_PRIORITY : HUNGER_PRIORITY

/datum/aiTask/sequence/goalbased/eat/get_targets()
	. = list()
	for(var/obj/decal/cleanable/ranch_feed/feed in view(max_dist, holder.owner))
		. += feed
	if(!src.eat_bodies)
		return
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(ranch_critter.stage == RANCH_STAGE_CHILD)
		return
	for(var/mob/living/L in view(max_dist, holder.owner))
		if(isalive(L))
			continue
		if(GET_COOLDOWN(L, "corpse_eating"))
			continue
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.decomp_stage == DECOMP_STAGE_SKELETONIZED)
				continue
		else if(isunconscious(L)) // Kill critters before eating them
			continue
		if(istype(L, ranch_critter.species_type)) // Cannibalism prevention
			continue
		. += L

/datum/aiTask/succeedable/eat
	max_fails = 3
	var/eat_bodies = FALSE

	New(parentHolder)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
		src.eat_bodies = ranch_critter.eat_dead_mobs

	failed()
		if(src.eat_bodies && actions.hasAction(holder.owner, /datum/action/bar/corpse_eating))
			return FALSE
		return ..()

	succeeded()
		. = 0
		if(src.eat_bodies && actions.hasAction(holder.owner, /datum/action/bar/corpse_eating))
			return FALSE
		if (holder.owner.abilityHolder && !holder.owner.equipped())
			var/datum/targetable/critter/eat_feed/EF = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/eat_feed)
			if(EF)
				. = !EF.cast(holder.target)
			if(!. && src.eat_bodies)
				var/datum/targetable/critter/eat_bodies/ED = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/eat_bodies)
				if(ED)
					. = !ED.cast(holder.target)

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

	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(!istype(ranch_critter))
		return 1

	var/turf/T = get_turf(target)
	if(get_dist(T, ranch_critter) < 2)
		var/obj/decal/cleanable/ranch_feed/feed = locate(/obj/decal/cleanable/ranch_feed) in T
		if(feed)
			playsound(ranch_critter.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			ranch_critter.visible_message(SPAN_NOTICE("[ranch_critter] eats [feed]!"))
			ranch_critter.ranch_eating(feed)
			qdel(feed)
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

		var/mob/living/critter/small_animal/ranch_base/ranch_critter = owncritter
		if(!messaged)
			if(prob(10))
				if(istype(ranch_critter))
					ranch_critter.visible_message(SPAN_ALERT("[ranch_critter] cries out in fear!"))
					ranch_critter.gossip()
					messaged = 1

		holder.move_away(holder.target,target_range)
		if(istype(ranch_critter))
			ranch_critter.change_happiness(-20)

	..()

/datum/aiTask/timed/targeted/flee_shitter/on_reset()
	..()
	holder.target = null
	holder.stop_move()
	messaged = 0

/datum/aiTask/timed/targeted/flee_shitter/get_targets()
	. = list()
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(istype(ranch_critter))
		for(var/mob/M in ranch_critter.shit_list)
			if(get_dist(M, ranch_critter) <= target_range)
				if(M in view(target_range, ranch_critter))
					if(isalive(M))
						. += M

/datum/aiTask/timed/targeted/flee_shitter/evaluate() // evaluate the current environment and assign priority to switching to this task
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(istype(ranch_critter))
		for(var/mob/M in ranch_critter.shit_list)
			if(get_dist(M, ranch_critter) < target_range)
				if(M in view(target_range, ranch_critter))
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
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	. = 0
	if(istype(ranch_critter))
		if(ranch_critter.stage > 0)
			. = 1

/datum/aiTask/timed/targeted/fight_shitter/frustration_check()
	.= 0
	if (!IN_RANGE(holder.owner, holder.target, target_range))
		return 1

	if (ismob(holder.target))
		var/mob/M = holder.target
		. = !(holder.target && isalive(M))
	else
		. = !(holder.target)

/datum/aiTask/timed/targeted/fight_shitter/evaluate()
	..()
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(istype(ranch_critter))
		if(ranch_critter.hyperaggressive)
			for(var/mob/M in view(target_range, ranch_critter))
				if(isalive(M))
					if(!(M in ranch_critter.my_friends))
						if(!istype(M, ranch_critter.species_type))
							return precondition() * FIGHT_PRIORITY
		for(var/mob/M in ranch_critter.shit_list)
			if(IN_RANGE(M, ranch_critter, target_range))
				if(M in view(target_range, ranch_critter))
					if(isalive(M))
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
				var/mob/living/critter/small_animal/ranch_base/ranch_critter = owncritter
				if(istype(ranch_critter))
					ranch_critter.visible_message(SPAN_ALERT("[ranch_critter] cries out in anger!"))
					ranch_critter.gossip()
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

			var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
			if(prob(15) && holder.owner.abilityHolder)
				if(istype(ranch_critter))
					var/datum/targetable/ability_attack = ranch_critter.attack_ability
					if (ability_attack)
						ability_attack.cast(get_turf(M))
			else
				var/list/params = list()
				params["left"] = 1
				params["ai"] = 1
				owncritter.hand_attack(M, params)
				if(istype(ranch_critter))
					if(ranch_critter.hyperaggressive)
						ranch_critter.change_happiness(10)
		var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
		if(istype(ranch_critter))
			if(!ranch_critter.hyperaggressive)
				ranch_critter.change_happiness(-20)

	..()

/datum/aiTask/timed/targeted/fight_shitter/get_targets()
	. = list()
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(istype(ranch_critter))
		if(ranch_critter.hyperaggressive)
			for(var/mob/M in view(target_range, ranch_critter))
				if(!isalive(M))
					continue
				if(M in ranch_critter.my_friends)
					continue
				if(!istype(M, ranch_critter.species_type))
					. += M
			return
		for(var/mob/M in ranch_critter.shit_list)
			if(IN_RANGE(M, ranch_critter,target_range))
				if(M in view(target_range, ranch_critter))
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
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	. = 0
	if(istype(ranch_critter))
		if(ranch_critter.stage < 1)
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
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(istype(ranch_critter))
		if(ranch_critter.impressionable)
			if(target in ranch_critter.my_friends)
				. += 10000
		else if (ranch_critter.parent == target)
			. += 10000

/datum/aiTask/timed/targeted/follow_momma/evaluate()
	..()
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(istype(ranch_critter))
		for(var/mob/M in view(target_range, ranch_critter))
			if(!isdead(M))
				if(ranch_critter.impressionable)
					if(M in ranch_critter.my_friends)
						return precondition() * FOLLOW_PRIORITY
					else if(istype(M, ranch_critter.species_type))
						var/mob/living/critter/small_animal/ranch_base/R = M
						if(istype(R))
							if(R.stage > 0)
								return precondition() * FOLLOW_PRIORITY
				else if (ranch_critter.parent && (M == ranch_critter.parent))
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

	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(!(holder.target in ranch_critter.my_friends) && !(ranch_critter.parent && (holder.target == ranch_critter.parent)))
		if(ranch_critter.impressionable)
			if(length(ranch_critter.my_friends) > 0)
				for(var/mob/friend in ranch_critter.my_friends)
					if(IN_RANGE(friend, ranch_critter, target_range))
						holder.target = null
		else if(ranch_critter.parent)
			if(IN_RANGE(ranch_critter.parent, ranch_critter, target_range))
				holder.target = null

	..()

/datum/aiTask/timed/targeted/follow_momma/get_targets()
	. = list()
	var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
	if(istype(ranch_critter))
		for(var/mob/M in view(target_range, ranch_critter))
			if(!isdead(M))
				if(ranch_critter.impressionable)
					if(M in ranch_critter.my_friends)
						. += M
					else if(istype(M, ranch_critter.species_type))
						var/mob/living/critter/small_animal/ranch_base/R = M
						if(istype(R))
							if(R.stage > 0)
								. += M
				else if (ranch_critter.parent && (M == ranch_critter.parent))
					. += M

/datum/aiTask/timed/targeted/follow_momma/on_reset()
	..()
	holder.target = null
	holder.stop_move()

/datum/targetable/critter/eat_bodies
	name = "Eat Dead"
	desc = "Eat dead bodies"
	cooldown = 5 SECONDS
	start_on_cooldown = 0
	icon_state = "template"
	targeted = 1
	target_anything = 1
	var/is_eating = FALSE

	cast(atom/target)
		if (..())
			return 1
		if(src.is_eating)
			if(!actions.hasAction(holder.owner, /datum/action/bar/corpse_eating))
				src.is_eating = FALSE
				return 0
			return 1

		var/mob/living/critter/small_animal/ranch_base/ranch_critter = holder.owner
		if(!istype(ranch_critter))
			return 1
		var/turf/T = get_turf(target)
		if(get_dist(T, ranch_critter) < 2)
			var/mob/living/L = locate(/mob/living) in T
			if(!isalive(L) && !GET_COOLDOWN(L, "corpse_eating"))
				var/duration = 6 SECONDS
				if(ishuman(L))
					duration = 4 SECONDS // Humans have limbs and organs that take a while to eat
				if(ranch_critter.hunger > RANCH_HUNGER_STARVING)
					duration /= 2
				actions.start(new/datum/action/bar/corpse_eating(L, duration), ranch_critter)
				src.is_eating = TRUE
				return 1
		. = 1

/datum/action/bar/corpse_eating
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 8 SECONDS
	var/mob/living/target = null

	New(var/mob/living/target, var/duration_i)
		..()
		if (duration_i)
			duration = duration_i
		src.target = target
		OVERRIDE_COOLDOWN(target, "corpse_eating", src.duration) // Prevent multiple raptors from going after the same body

	onUpdate()
		..()
		var/mob/living/critter/small_animal/ranch_base/ranch_critter = src.owner
		if(QDELETED(src.target) || !IN_RANGE(ranch_critter, src.target, 1))
			ranch_critter.canmove = TRUE
			OVERRIDE_COOLDOWN(target, "corpse_eating", 0)
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		var/mob/living/critter/small_animal/ranch_base/ranch_critter = src.owner
		ranch_critter.canmove = FALSE
		ranch_critter.visible_message(SPAN_ALERT("[src.owner] starts eating \the [src.target]!"), SPAN_NOTICE("You start eating the [src.target]!"))

	onEnd()
		..()
		var/mob/living/critter/small_animal/ranch_base/ranch_critter = src.owner
		if(ranch_critter && src.target)
			ranch_critter.canmove = TRUE
			playsound(ranch_critter.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			eat_target(ranch_critter)
			ranch_critter.ranch_eating(src.target, 5, 40, FALSE)

	proc/eat_target(var/mob/living/critter/small_animal/ranch_base/ranch_critter)
		if(!ishuman(target))
			ranch_critter.visible_message(SPAN_ALERT("[src.owner] ate \the [src.target]!"), SPAN_NOTICE("You ate \the [src.target]."))
			src.target.unequip_all()
			qdel(src.target)
			return
		var/mob/living/carbon/human/H = src.target
		if(H.limbs)
			// Eat limbs first.
			var/list/obj/item/parts/limb_list = H.limbs.get_limbs_all()
			while(length(limb_list) > 0)
				var/obj/item/parts/limb = pick(limb_list)
				limb_list -= limb
				if(!isrobolimb(limb))
					ranch_critter.visible_message(SPAN_ALERT("[src.owner] ate [src.target]'s [limb]!"), SPAN_NOTICE("You ate [src.target]'s [limb]."))
					limb.delete()
					return

		if(H.organHolder)
			// Now eat their organs.
			var/list/organ_list = H.organHolder.get_organs_all()
			while(length(organ_list) > 0)
				var/organ = pick(organ_list)
				organ_list -= organ
				if(istype(organ, /obj/item/organ))
					var/obj/item/organ/O = organ
					if(O.organ_holder_name == "chest" || O.organ_holder_name == "head" || O.organ_holder_name == "brain")
						continue
					if(!O.robotic)
						ranch_critter.visible_message(SPAN_ALERT("[src.owner] ate [src.target]'s [O]!"), SPAN_NOTICE("You ate [src.target]'s [O]."))
						H.organHolder.drop_organ(O, H.loc)
						qdel(O)
						return
				else if(istype(organ, /obj/item/clothing/head/butt))
					var/obj/item/clothing/head/butt/butt = organ
					if(!butt.is_robotic)
						ranch_critter.visible_message(SPAN_ALERT("[src.owner] ate [src.target]'s [butt]!"), SPAN_NOTICE("You ate [src.target]'s [butt]."))
						H.organHolder.drop_organ(butt, H.loc)
						qdel(butt)
						return

		H.skeletonize()
		ranch_critter.visible_message(SPAN_ALERT("[src.owner] finished eating \the [H]!"), SPAN_NOTICE("You finished eating \the [H]."))

