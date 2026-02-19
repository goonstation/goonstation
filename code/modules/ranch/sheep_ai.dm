// SHEEP


/datum/aiHolder/sheep
	exclude_from_mobs_list = 1

/datum/aiHolder/sheep/New()
	..()

/datum/aiTask/prioritizer/sheep
	name = "base thinking (should never see this)"

/datum/aiTask/prioritizer/sheep/New()
	..()

/datum/aiTask/prioritizer/sheep/on_tick()
	if(isdead(holder.owner))
		holder.enabled = 0
		walk(holder.owner, 0) // STOP RUNNING AROUND YOU'RE SUPPOSED TO BE DEAD

/datum/aiTask/prioritizer/sheep/on_reset()
	..()
	holder.target = null
	holder.stop_move()

/datum/aiTask/sequence/goalbased/eat
	name = "eat"
	weight = HUNGER_PRIORITY
	max_dist = 10

//Ewe Ai holder

/datum/aiHolder/sheep/ewe

/datum/aiHolder/sheep/ewe/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/sheep/ewe, list(src))

/datum/aiTask/prioritizer/sheep/ewe
	name = "thinking (ewe)"

/datum/aiTask/prioritizer/sheep/ewe/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/eat, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/flee_shitter,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/fight_shitter,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/seek_mate,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/follow_mate,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/follow_momma, list(holder,src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/create_child, list(holder,src))

/datum/aiTask/prioritizer/sheep/ewe/on_reset()
	..()
	holder.stop_move()
	holder.target = null
	if(holder.owner)
		holder.owner.set_a_intent(INTENT_HELP)

//RamAI Holder

/datum/aiHolder/sheep/ram

/datum/aiHolder/sheep/ram/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/sheep/ram, list(src))

/datum/aiTask/prioritizer/sheep/ram
	name = "thinking (ram)"

/datum/aiTask/prioritizer/sheep/ram/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/eat, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/flee_shitter,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/fight_shitter,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/seek_mate,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/follow_mate,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/follow_momma, list(holder,src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/create_child, list(holder,src))

/datum/aiTask/prioritizer/sheep/ram/on_reset()
	..()
	holder.stop_move()
	holder.target = null
	if(holder.owner)
		holder.owner.set_a_intent(INTENT_HELP)

// Seek Mate

/datum/aiTask/sequence/goalbased/seek_mate
	name = "seek_mate"
	weight = EGG_PRIORITY
	max_dist = 10

/datum/aiTask/sequence/goalbased/seek_mate/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/seek_mate, list(holder)))

/datum/aiTask/sequence/goalbased/seek_mate/precondition()
	. = 0
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(C.stage != RANCH_STAGE_ADULT)
		. = 0
	else if(C.mate)
		. = 0
	else if(C.happiness >= 30)
		if(C.hunger < 20)
			. = 1

/datum/aiTask/sequence/goalbased/seek_mate/evaluate()
	. = 0
	if(src.precondition())
		if(get_best_target(get_targets()))
			return EGG_PRIORITY

/datum/aiTask/sequence/goalbased/seek_mate/get_targets()
	. = list()
	..()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		for(var/mob/living/critter/small_animal/ranch_base/R in view(max_dist,C))
			if(R != C)
				if(!isdead(R))
					if(isnull(R.mate))
						if(istype(R,C.species_type))
							if(R.stage == RANCH_STAGE_ADULT)
								if ((R.gender_preference & RANCH_PREFERENCE_SAME) && (C.gender_preference & RANCH_PREFERENCE_SAME) && (R.is_masc == C.is_masc))
									. += R
								else if ((R.gender_preference & RANCH_PREFERENCE_DIFF) && (C.gender_preference & RANCH_PREFERENCE_DIFF) && (R.is_masc != C.is_masc))
									. += R

/datum/aiTask/succeedable/seek_mate
	max_fails = 3

	succeeded()
		. = 0
		if (holder.owner.abilityHolder && !holder.owner.equipped())
			var/datum/targetable/critter/seek_mate/SM = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/seek_mate)
			if (SM)

				. = SM.cast(holder.target)
				. = !.

/datum/aiTask/sequence/goalbased/seek_mate/on_reset()
	..()
	holder.stop_move()
	holder.target = null

/datum/targetable/critter/seek_mate
	name = "Propose Pair Bond"
	desc = "Propose Pair Bond"
	cooldown = 3 SECONDS
	start_on_cooldown = 0
	icon_state = "template"
	targeted = 1
	target_anything = 1

/datum/targetable/critter/seek_mate/cast(atom/target)
	if (..())
		return 1

	var/mob/living/critter/small_animal/ranch_base/R = holder.owner
	if(!istype(R))
		return 1

	var/mob/living/critter/small_animal/ranch_base/T = target
	if(!istype(T))
		if(!istype(T,R.species_type))
			return 1

	if(get_dist(T,R) < 2)

		actions.start(new/datum/action/bar/seek_mate(T), R)
		return 0
	. = 1

/datum/action/bar/seek_mate
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 60
	var/mob/living/critter/small_animal/ranch_base/target = null


	New(var/atom/A)
		..()
		if(A)
			target = A

	onUpdate()
		..()
		var/mob/living/critter/small_animal/ranch_base/R = owner
		var/mob/living/critter/small_animal/ranch_base/T = target
		if(!T || !R)
			interrupt(INTERRUPT_ALWAYS)
		if(get_dist(target,owner) >= 2)
			interrupt(INTERRUPT_ALWAYS)
		if(T.mate || R.mate)
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		var/mob/living/critter/small_animal/ranch_base/R = owner
		var/mob/living/critter/small_animal/ranch_base/T = target
		if(!T || !R)
			interrupt(INTERRUPT_ALWAYS)
		else
			R.use_stunned_icon = FALSE
			T.use_stunned_icon = FALSE
			APPLY_ATOM_PROPERTY(R, PROP_MOB_CANTMOVE, "SHEEP_PARTNER")
			APPLY_ATOM_PROPERTY(T, PROP_MOB_CANTMOVE, "SHEEP_PARTNER")
			if(T.is_npc && T.ai && T.ai.enabled)
				T.ai.enabled = FALSE
				T.ai.interrupt()

			boutput(owner, SPAN_NOTICE("You ask them if they want to be pair-bonded, let's see what they say!"))

	onInterrupt(flag)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/R = owner
		var/mob/living/critter/small_animal/ranch_base/T = target
		REMOVE_ATOM_PROPERTY(T, PROP_MOB_CANTMOVE, "SHEEP_PARTNER")
		REMOVE_ATOM_PROPERTY(R, PROP_MOB_CANTMOVE, "SHEEP_PARTNER")
		if(T?.is_npc && T?.ai && !T?.ai.enabled)
			T?.ai.enabled = TRUE
			T?.ai.interrupt()

	onEnd()
		..()
		var/mob/living/critter/small_animal/ranch_base/R = owner
		var/mob/living/critter/small_animal/ranch_base/T = target
		if(T && R)
			if(T.hunger > 20)
				R.visible_message(SPAN_ALERT("[T] looks too hungry to pay any attention to [R]! [R] looks embarrassed."), SPAN_NOTICE("They said no because they were too hungry."))
				R.change_happiness(-10)
			else if(T.happiness < 30)
				R.visible_message(SPAN_ALERT("[T] looks too unhappy to pay any attention to [R]! [R] looks embarrassed."), SPAN_NOTICE("They said no because they were too unhappy."))
				R.change_happiness(-10)
			else if (R.mate)
				R.visible_message(SPAN_ALERT("[T] looks confused at [R]. [R] looks embarrassed."), SPAN_NOTICE("They said no because you already have a partner."))
				R.change_happiness(-10)
			else if (T.mate)
				R.visible_message(SPAN_ALERT("[T] looks apologetic at [R]. [R] looks embarrassed."), SPAN_NOTICE("They said no because they already have a partner."))
				R.change_happiness(-10)
			else
				R.visible_message(SPAN_NOTICE("[R] looks sheepishly at [T]! [T] looks baashfull!"), SPAN_NOTICE("They said yes!"))
				R.mate = T
				T.mate = R
				R.change_happiness(10)
				T.change_happiness(10)
				var/share_happiness = (R.happiness + T.happiness)/2
				R.happiness = share_happiness
				T.happiness = share_happiness
			R.use_stunned_icon = TRUE
			T.use_stunned_icon = TRUE
			REMOVE_ATOM_PROPERTY(T, PROP_MOB_CANTMOVE, "SHEEP_PARTNER")
			REMOVE_ATOM_PROPERTY(R, PROP_MOB_CANTMOVE, "SHEEP_PARTNER")
			if(T.is_npc && T.ai && !T.ai.enabled)
				T.ai.enabled = TRUE
				T.ai.interrupt()


// Follow Mate

/datum/aiTask/timed/targeted/follow_mate
	name = "follow mate"
	minimum_task_ticks = 10
	maximum_task_ticks = 10
	target_range = FLEE_DISTANCE + 1
	frustration_threshold = 3
	var/last_seek


/datum/aiTask/timed/targeted/follow_mate/proc/precondition()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	. = 0
	if(isalive(C))
		. = 1

/datum/aiTask/timed/targeted/follow_mate/frustration_check()
	.= 0
	if (!IN_RANGE(holder.owner, holder.target, target_range))
		return 1

	if (ismob(holder.target))
		var/mob/M = holder.target
		. = !(holder.target && !isdead(M))
	else
		. = !(holder.target)

/datum/aiTask/timed/targeted/follow_mate/evaluate()
	..()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		for(var/mob/M in view(target_range,C))
			if(!isdead(M))
				if(C.mate == M)
					if(get_dist(C,M) > target_range/2)
						return precondition() * FOLLOW_PRIORITY
	. = 0

/datum/aiTask/timed/targeted/follow_mate/on_tick()
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

	..()

/datum/aiTask/timed/targeted/follow_mate/get_targets()
	. = list()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		for(var/mob/M in view(target_range,C))
			if(!isdead(M))
				if(C.mate == M)
					. += M

/datum/aiTask/timed/targeted/follow_mate/on_reset()
	..()
	holder.target = null
	holder.stop_move()

// Have Woohoo

/datum/aiTask/sequence/goalbased/create_child
	name = "Create Child"
	weight = EGG_PRIORITY
	max_dist = FLEE_DISTANCE
	distance_from_target = 0

/datum/aiTask/sequence/goalbased/create_child/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/create_child, list(holder)))

/datum/aiTask/sequence/goalbased/create_child/precondition()
	. = 0
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(C)
		if(!C.mate)
			. = 0
		else if(!isalive(C.mate))
			. = 0
		else if (get_dist(C.mate,C) > FLEE_DISTANCE)
			. = 0
		else if (C.baby || C.mate.baby)
			. = 0
		else if (C.happiness < 50 || C.mate.happiness < 50)
			. = 0
		else if (C.stage != RANCH_STAGE_ADULT || C.mate.stage != RANCH_STAGE_ADULT)
			. = 0
		else
			. = 1

/datum/aiTask/sequence/goalbased/create_child/evaluate()
	. = 0
	if(src.precondition())
		if(get_best_target(get_targets()))
			return EGG_PRIORITY

/datum/aiTask/sequence/goalbased/create_child/get_targets()
	. = list()
	..()
	var/mob/living/critter/small_animal/ranch_base/C = holder.owner
	if(istype(C))
		for(var/mob/M in view(max_dist,C))
			if(!isdead(M))
				if(C.mate == M)
					. += M

/datum/aiTask/sequence/goalbased/create_child/on_reset()
	..()
	holder.target = null
	holder.stop_move()

/datum/aiTask/succeedable/create_child
	max_fails = 3

	succeeded()
		. = 0
		if (holder.owner.abilityHolder && !holder.owner.equipped())
			var/datum/targetable/critter/create_child/CC = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/create_child)
			if (CC)
				var/mob/living/critter/small_animal/ranch_base/R = holder.owner
				. = CC.cast(R?.mate)
				. = !.

/datum/targetable/critter/create_child
	name = "Create Child"
	desc = "The miracle of life"
	cooldown = 60 SECONDS
	start_on_cooldown = 0
	icon_state = "template"
	targeted = 1
	target_anything = 1


/datum/targetable/critter/create_child/cast(atom/target)
	if (..())
		return 1

	var/mob/living/critter/small_animal/ranch_base/R = holder.owner
	if(!istype(R))
		return 1

	var/mob/living/critter/small_animal/ranch_base/T = target
	if(T != R.mate)
		return 1

	if(get_dist(T,R) < 2)
		actions.start(new/datum/action/bar/create_child(T), R)
		return 0
	. = 1

/datum/action/bar/create_child
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 60
	var/mob/living/critter/small_animal/ranch_base/target = null


	New(var/atom/A)
		..()
		if(A)
			target = A

	onUpdate()
		..()
		var/mob/living/critter/small_animal/ranch_base/R = owner
		var/mob/living/critter/small_animal/ranch_base/T = target
		if(!T || !R)
			interrupt(INTERRUPT_ALWAYS)
		if(get_dist(T,R) >= 2)
			interrupt(INTERRUPT_ALWAYS)

	onInterrupt(flag)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/R = owner
		var/mob/living/critter/small_animal/ranch_base/T = target
		R?.use_stunned_icon = TRUE
		T?.use_stunned_icon = TRUE
		REMOVE_ATOM_PROPERTY(T, PROP_MOB_CANTMOVE, "SHEEP_MATE")
		REMOVE_ATOM_PROPERTY(R, PROP_MOB_CANTMOVE, "SHEEP_MATE")
		if(T?.is_npc && T?.ai && !T?.ai.enabled)
			T.ai.enabled = TRUE
			T.ai.interrupt()

	onStart()
		..()
		var/mob/living/critter/small_animal/ranch_base/R = owner
		var/mob/living/critter/small_animal/ranch_base/T = target
		if(!T || !R)
			interrupt(INTERRUPT_ALWAYS)
		else
			R.use_stunned_icon = FALSE
			T.use_stunned_icon = FALSE
			APPLY_ATOM_PROPERTY(R, PROP_MOB_CANTMOVE, "SHEEP_MATE")
			APPLY_ATOM_PROPERTY(T, PROP_MOB_CANTMOVE, "SHEEP_MATE")
			if(T.is_npc && T.ai && T.ai.enabled)
				T.ai.enabled = FALSE
				T.ai.interrupt()

			boutput(owner, SPAN_NOTICE("You show them the paperwork to order a new baby from the stork, let's see what they say!"))

	onEnd()
		..()
		var/mob/living/critter/small_animal/ranch_base/R = owner
		var/mob/living/critter/small_animal/ranch_base/T = target
		if(T && R)
			if(T.hunger > 20)
				R.visible_message(SPAN_ALERT("[T] looks too hungry to pay any attention to [R]! [R] looks embarrassed."), SPAN_NOTICE("They said no because they were too hungry."))
				R.change_happiness(-10)
			else if(T.happiness < 30)
				R.visible_message(SPAN_ALERT("[T] looks too unhappy to pay any attention to [R]! [R] looks embarrassed."), SPAN_NOTICE("They said no because they were too unhappy."))
				R.change_happiness(-10)
			else if (R.baby)
				R.visible_message(SPAN_ALERT("[T] looks confused at [R]. [R] looks embarrassed."), SPAN_NOTICE("They said no because you already have a child."))
				R.change_happiness(-10)
			else if (T.baby)
				R.visible_message(SPAN_ALERT("[T] looks apologetic at [R]. [R] looks embarrassed."), SPAN_NOTICE("They said no because they already have a child."))
				R.change_happiness(-10)
			else
				R.change_happiness(10)
				T.change_happiness(10)
				var/share_happiness = (R.happiness + T.happiness)/2
				R.happiness = share_happiness
				T.happiness = share_happiness
				R.create_child(T)
			R.use_stunned_icon = TRUE
			T.use_stunned_icon = TRUE
			REMOVE_ATOM_PROPERTY(T, PROP_MOB_CANTMOVE, "SHEEP_MATE")
			REMOVE_ATOM_PROPERTY(R, PROP_MOB_CANTMOVE, "SHEEP_MATE")
			if(T.is_npc && T.ai && !T.ai.enabled)
				T.ai.enabled = TRUE
				T.ai.interrupt()
