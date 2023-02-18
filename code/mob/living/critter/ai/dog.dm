/datum/aiHolder/dog
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/dog, list(src))

/datum/aiTask/prioritizer/critter/dog/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))

// Go fetch!
/datum/aiTask/sequence/goalbased/critter/dog/fetch
	name = "fetching"
	weight = 10
	max_dist = 7
	ai_turbo = TRUE

/datum/aiTask/sequence/goalbased/critter/dog/fetch/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/dog/fetch, list(holder)))

/datum/aiTask/sequence/goalbased/critter/dog/fetch/get_targets()
	var/mob/living/critter/small_animal/dog/the_dog = holder.owner
	return list(the_dog.fetch_item)

//Fetch subtask, pick up the item
/datum/aiTask/succeedable/critter/dog/fetch
	name = "fetch subtask"
	var/is_complete = FALSE

/datum/aiTask/succeedable/critter/dog/fetch/failed()
	var/mob/living/critter/C = holder.owner
	var/obj/item/I = holder.target
	if(!C || !I || BOUNDS_DIST(I, C) > 0 || !istype(I.loc, /turf)) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/critter/dog/fetch/succeeded()
	return is_complete

/datum/aiTask/succeedable/critter/dog/fetch/on_tick()
	if(!is_complete)
		holder.stop_move()
		var/mob/living/critter/C = holder.owner
		var/obj/item/I = holder.target
		if(C && I && BOUNDS_DIST(C, I) == 0 && istype(I.loc, /turf))
			C.set_dir(get_dir(C, I))
			if(C.set_hand(1))
				C.drop_item()
				C.hand_attack(I)
				if (prob(20))
					holder.owner.visible_message("<span class='notice'>[holder.owner] begins to chew on [holder.target]!</span>")
				else
					holder.owner.visible_message("<span class='notice'>[holder.owner] picks up [holder.target]!</span>")
					holder.priority_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/dog/fetch_back, list(holder, holder.default_task))
			is_complete = TRUE

/datum/aiTask/succeedable/critter/dog/fetch/on_reset()
	is_complete = FALSE

// C'mere boy!
/datum/aiTask/sequence/goalbased/critter/dog/fetch_back
	name = "fetching back"
	weight = 10
	max_dist = 7
	ai_turbo = TRUE

/datum/aiTask/sequence/goalbased/critter/dog/fetch_back/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/dog/fetch_back, list(holder)))

/datum/aiTask/sequence/goalbased/critter/dog/fetch_back/get_targets()
	var/mob/living/critter/small_animal/dog/the_dog = holder.owner
	var/mob/living/playmate = the_dog.fetch_playmate
	if (playmate && get_dist(the_dog, playmate) < max_dist)
		var/obj/item/the_item = the_dog.fetch_item
		//If the item is too tiny, you cannot clearly see it in the dog's mouth
		var/seen_item = "something"
		if (the_item.w_class > W_CLASS_TINY)
			seen_item = the_item
		the_dog.visible_message("<span class='notice'>[the_dog] begins happily running towards [playmate] with [seen_item] in their mouth, wagging their tail furiously!</span>")
		return list(the_dog.fetch_playmate)
	else
		return list()

//Fetch subtask, pick up the item
/datum/aiTask/succeedable/critter/dog/fetch_back
	name = "fetch back subtask"
	var/is_complete = FALSE

/datum/aiTask/succeedable/critter/dog/fetch_back/failed()
	var/mob/living/critter/C = holder.owner
	var/mob/living/M = holder.target
	if(!C || !M || BOUNDS_DIST(M, C) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/critter/dog/fetch_back/succeeded()
	return is_complete

/datum/aiTask/succeedable/critter/dog/fetch_back/on_tick()
	if(!is_complete)
		holder.stop_move()
		var/mob/living/critter/C = holder.owner
		var/mob/living/M = holder.target
		if(C && M && BOUNDS_DIST(C, M) == 0)
			C.set_dir(get_dir(C, M))
			if(C.set_hand(1))
				C.drop_item()
				C.visible_message("<span class='notice'>[C] drops what they have in their mouth in front of [M]. [pick("It's positively COVERED in dog saliva.", "[C] wags their tail happily.", "Good dog!")]</span>")
			is_complete = TRUE

/datum/aiTask/succeedable/critter/dog/fetch_back/on_reset()
	is_complete = FALSE

