// Chickens

//FOLLOWING STOLEN FROM FLOCK: Base Thinking

// CHICKEN AI

// Lay Egg
// Hatch Egg

/datum/aiHolder/chicken
	exclude_from_mobs_list = 1

/datum/aiHolder/chicken/New()
	..()

/datum/aiTask/prioritizer/chicken
	name = "base thinking (should never see this)"

/datum/aiTask/prioritizer/chicken/New()
	..()

/datum/aiTask/prioritizer/chicken/on_tick()
	if(isdead(holder.owner))
		holder.enabled = 0
		walk(holder.owner, 0) // STOP RUNNING AROUND YOU'RE SUPPOSED TO BE DEAD

/datum/aiTask/prioritizer/chicken/on_reset()
	..()
	holder.target = null
	holder.stop_move()

//Hen Ai holder

/datum/aiHolder/chicken/hen

/datum/aiHolder/chicken/hen/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/chicken/hen, list(src))

/datum/aiTask/prioritizer/chicken/hen
	name = "thinking (hen)"

/datum/aiTask/prioritizer/chicken/hen/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/eat, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/follow_momma, list(holder,src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/lay_egg, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/flee_shitter,list(holder, src))

/datum/aiTask/prioritizer/chicken/hen/on_reset()
	..()
	holder.stop_move()
	holder.target = null
	if(holder.owner)
		holder.owner.set_a_intent(INTENT_HELP)

//Aggressive Hen holder

/datum/aiHolder/chicken/hen/aggressive
	New()
		. = ..()
		default_task = get_instance(/datum/aiTask/prioritizer/chicken/hen/aggressive, list(src))

/datum/aiTask/prioritizer/chicken/hen/aggressive/New()
	. = ..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/fight_shitter,list(holder, src))

//Rooster AI Holder

/datum/aiHolder/chicken/rooster

/datum/aiHolder/chicken/rooster/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/chicken/rooster, list(src))

/datum/aiTask/prioritizer/chicken/rooster
	name = "thinking (rooster)"

/datum/aiTask/prioritizer/chicken/rooster/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/eat, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/follow_momma, list(holder,src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/hatch_egg, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/flee_shitter,list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/fight_shitter,list(holder, src))

/datum/aiTask/prioritizer/chicken/rooster/on_reset()
	..()
	holder.stop_move()
	holder.target = null
	if(holder.owner)
		holder.owner.set_a_intent(INTENT_HELP)

// Lay Egg

/datum/aiTask/sequence/goalbased/lay_egg
	name = "lay_egg"
	weight = EGG_PRIORITY
	max_dist = 10
	distance_from_target = 0

/datum/aiTask/sequence/goalbased/lay_egg/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/lay_egg, list(holder)))

/datum/aiTask/sequence/goalbased/lay_egg/precondition()
	. = 0
	var/mob/living/critter/small_animal/ranch_base/chicken/C = holder.owner
	if(!C.egg_timer && C.stage == 1)
		var/chance_egg = max(clamp(C.happiness,0,100) - clamp(((C.hunger-25)*2),0,100),20)
		if(prob(chance_egg) || (C.egg_pity_count >= C.egg_pity_limit))
			. = 1
		else
			C.egg_timer = C.egg_cooldown
			C.egg_pity_count++

/datum/aiTask/sequence/goalbased/lay_egg/evaluate()
	. = 0
	if(src.precondition())
		if(get_best_target(get_targets()))
			return EGG_PRIORITY

/datum/aiTask/sequence/goalbased/lay_egg/get_targets()
	. = list()
	for(var/obj/chicken_nesting_box/B in view(max_dist, holder.owner))
		. += B

/datum/aiTask/sequence/goalbased/lay_egg/on_reset()
	..()
	holder.target = null
	holder.stop_move()

/datum/aiTask/succeedable/lay_egg
	max_fails = 1

	succeeded()
		. = 0
		if (holder.owner.abilityHolder)
			var/datum/targetable/critter/lay_egg/LE = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/lay_egg)
			if (LE)
				. = LE.cast(get_turf(holder.owner))
				. = !.

/datum/targetable/critter/lay_egg
	name = "Lay Egg"
	desc = "Lay egg is TRUE"
	cooldown = 10 SECONDS
	start_on_cooldown = 1
	icon_state = "template"
	targeted = 1
	target_anything = 1


/datum/targetable/critter/lay_egg/cast(atom/target)
	if (..())
		return 1

	var/mob/living/critter/small_animal/ranch_base/chicken/C = holder.owner
	if(!istype(C))
		return 1

	var/turf/T = null
	if(target)
		T = get_turf(target)
	else
		T = get_turf(src)
	if(get_dist(T,C) == 0)

		var/eggs = 0

		if(C.ai)
			if(length(T.contents) > 52) // 50 + chicken + box
				C.visible_message(SPAN_NOTICE("[C] looks incredibly frustrated at the mess of things in their nesting box!"))
				C.egg_timer = C.egg_cooldown*10
				return 1

			if(length(T.contents) > 13) //can't possible have 12 eggs if not (13 + chicken + box)
				for(var/obj/item/reagent_containers/food/snacks/ingredient/egg/E in T)
					eggs++
					if(eggs >= 12)
						C.visible_message(SPAN_NOTICE("[C] looks incredibly frustrated at the number of eggs in their nesting box!"))
						C.egg_timer = C.egg_cooldown*10
						return 1

		C.lay_egg()
		return 0
	. = 1

// Hatch Egg

/datum/aiTask/sequence/goalbased/hatch_egg
	name = "hatch_egg"
	weight = EGG_PRIORITY
	max_dist = 10
	distance_from_target = 0

/datum/aiTask/sequence/goalbased/hatch_egg/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/hatch_egg, list(holder)))


/datum/aiTask/sequence/goalbased/hatch_egg/evaluate()
	. = 0
	if(src.precondition())
		if(get_best_target(get_targets()))
			return EGG_PRIORITY

/datum/aiTask/sequence/goalbased/hatch_egg/precondition()
	. = 0
	var/mob/living/critter/small_animal/ranch_base/chicken/C = holder.owner
	if(!C.egg_timer && C.stage == 1)
		var/chance_egg = max(clamp(C.happiness,0,100) - clamp(((C.hunger-25)*2),0,100),20)
		if(prob(chance_egg) || (C.egg_pity_count >= C.egg_pity_limit))
			. = 1
		else
			C.egg_timer = C.egg_cooldown
			C.egg_pity_count++

/datum/aiTask/sequence/goalbased/hatch_egg/get_targets()
	. = list()
	for(var/obj/chicken_nesting_box/B in view(max_dist, holder.owner))
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/E = locate(/obj/item/reagent_containers/food/snacks/ingredient/egg) in get_turf(B)
		if(E)
			. += B

/datum/aiTask/sequence/goalbased/hatch_egg/on_reset()
	..()
	holder.target = null
	holder.stop_move()


/datum/aiTask/succeedable/hatch_egg
	max_fails = 5
	var/has_started = 0

	failed()
		var/mob/living/critter/small_animal/ranch_base/chicken/C = holder.owner
		if(!C)
			return 1
		if(!isalive(C))
			return 1
		var/obj/chicken_nesting_box/N = locate(/obj/chicken_nesting_box) in get_turf(C)
		if(!N)
			return 1

	succeeded()
		. = (!actions.hasAction(holder.owner, /datum/action/bar/hatch_egg)) // for whatever reason, the required action has stopped

	on_tick()
		if(!has_started)
			if (holder.owner.abilityHolder)
				var/datum/targetable/critter/hatch_egg/HE = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/hatch_egg)
				if (HE)
					has_started = 1
					HE.cast(get_turf(holder.owner))

	on_reset()
		..()
		holder.target = null
		holder.stop_move()
		has_started = 0

/datum/targetable/critter/hatch_egg
	name = "Hatch Egg"
	desc = "Hatch egg is TRUE"
	cooldown = 60 SECONDS
	start_on_cooldown = 1
	icon_state = "template"
	targeted = 1
	target_anything = 1

/datum/targetable/critter/hatch_egg/cast(atom/target)
	if (..())
		return 1

	var/mob/living/critter/small_animal/ranch_base/chicken/C = holder.owner
	if(!istype(C))
		return 1

	var/turf/T = null
	if(target)
		T = get_turf(target)
	else
		T = get_turf(src)
	if(get_dist(T,C) == 0)

		var/eggs = 0

		if(C.ai)
			if(length(T.contents) > 52) // 50 + chicken + box
				C.visible_message(SPAN_NOTICE("[C] looks incredibly frustrated at the mess of things in their nesting box!"))
				C.egg_timer = C.egg_cooldown
				C.change_happiness(-abs((C.happiness/10)))
				return 1

			if(length(T.contents) > 13) //can't possible have 12 eggs if not (13 + chicken + box)
				for(var/obj/item/reagent_containers/food/snacks/ingredient/egg/E in T)
					eggs++
					if(eggs >= 12)
						C.visible_message(SPAN_NOTICE("[C] looks incredibly frustrated at the number of eggs in their nesting box!"))
						C.egg_timer = C.egg_cooldown
						C.change_happiness(-abs((C.happiness/10)))
						return 1

		actions.start(new/datum/action/bar/hatch_egg(), C)
		return 0
	. = 1

/datum/action/bar/hatch_egg
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 80


	New(var/duration_i)
		..()
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		var/mob/living/critter/small_animal/ranch_base/chicken/C = owner
		var/obj/chicken_nesting_box/N = locate(/obj/chicken_nesting_box) in get_turf(C)
		var/obj/item/reagent_containers/food/snacks/ingredient/egg/E = locate(/obj/item/reagent_containers/food/snacks/ingredient/egg) in get_turf(C)
		if(!N || !E)
			C.canmove = 1
			interrupt(INTERRUPT_ALWAYS)
	onStart()
		..()
		var/mob/living/critter/small_animal/ranch_base/chicken/C = owner
		C?.canmove = 0
		boutput(owner, SPAN_NOTICE("You warm up the eggs in the nesting box; stay cozy!"))

	onEnd()
		..()
		var/mob/living/critter/small_animal/ranch_base/chicken/C = owner
		if(C)
			C.canmove = 1
			C.visible_message(SPAN_ALERT("[owner] hatches the eggs in the nesting box!"), SPAN_NOTICE("You hatch the eggs in the nesting box."))
			var/left = 6
			for(var/obj/item/reagent_containers/food/snacks/ingredient/egg/E in get_turf(C))
				if(istype(E,/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken) && !E.infertile)
					var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/CE = E
					var/datum/chicken_egg_props/egg_props = null
					if(C.special_hatch(CE))
						var/prop_type = C.special_hatch(CE)
						egg_props = new prop_type
						egg_props.happiness_value = CE.chicken_egg_props.happiness_value
						CE.chicken_egg_props = egg_props
					else if(prob(50)) // dads
						var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/temp = new C.egg_type
						temp.chicken_egg_props.happiness_value += CE.chicken_egg_props.happiness_value // add on existing eggs happiness
						temp.chicken_egg_props.happiness_value += C.happiness / 3 // add on hatching rooster's happiness
						CE.chicken_egg_props = temp.chicken_egg_props
						qdel(temp)
				E.hatch_c()
				C.egg_pity_count = 0
				C.egg_timer += C.egg_cooldown
				left--
				if(!left)
					break
