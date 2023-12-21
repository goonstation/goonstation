/datum/aiHolder/capybara
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/capybara, list(src))

/datum/aiHolder/capybaby
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/capybara/baby, list(src))


/datum/aiTask/prioritizer/critter/capybara/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/sitting, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))


/datum/aiTask/prioritizer/critter/capybara/baby/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/to_capy_adult, list(holder, src))
//--------------------------------------------------------------------------------------------------------------------------------------------------//
// keep close to an adult capy
/datum/aiTask/sequence/goalbased/to_capy_adult
	weight = -10 //high value so it always keeps close

/datum/aiTask/sequence/goalbased/to_capy_adult/precondition()
	. = TRUE
	for(var/mob/living/critter/small_animal/capybara/adult in range(src.holder.owner, 3))
		if(!istype(adult, /mob/living/critter/small_animal/capybara/baby))
			return FALSE

/datum/aiTask/sequence/goalbased/to_capy_adult/get_targets()
	. = ..()
	for(var/mob/living/critter/small_animal/capybara/adult in range(src.holder.owner, 8))
		if(!istype(adult, /mob/living/critter/small_animal/capybara/baby))
			. += adult


