/*
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 * 
 * Contributed to the 35 Below Project, derived at least 3.9%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/datum/aiHolder/seal_baby
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/seal_baby, list(src))

/datum/aiTask/prioritizer/critter/seal_baby/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/to_seal_adult, list(holder, src))
//--------------------------------------------------------------------------------------------------------------------------------------------------//
// keep close to an adult seal
// Modified from capybara behavior but mostly the same
/datum/aiTask/sequence/goalbased/to_seal_adult
	weight = -10 //high value so it always keeps close

/datum/aiTask/sequence/goalbased/to_seal_adult/precondition()
	. = TRUE
	for(var/mob/living/critter/small_animal/seal_arctic/adult/adult in range(src.holder.owner, 3))
		return FALSE

/datum/aiTask/sequence/goalbased/to_seal_adult/get_targets()
	. = ..()
	for(var/mob/living/critter/small_animal/seal_arctic/adult/adult in range(src.holder.owner, 8))
		. += adult

/datum/aiHolder/seal_adult
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/seal_adult, list(src))

/datum/aiTask/prioritizer/critter/seal_adult/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/to_seal_leader, list(holder, src))
//--------------------------------------------------------------------------------------------------------------------------------------------------//
// keep close to an adult seal
// Modified from capybara behavior but mostly the same
/datum/aiTask/sequence/goalbased/to_seal_leader
	weight = -10 //high value so it always keeps close

/datum/aiTask/sequence/goalbased/to_seal_leader/precondition()
	. = TRUE
	for(var/mob/living/critter/small_animal/seal_arctic/adult/matriarch/adult in range(src.holder.owner, 3))
		if (!isdead(adult))
			return FALSE

/datum/aiTask/sequence/goalbased/to_seal_leader/get_targets()
	. = ..()
	for(var/mob/living/critter/small_animal/seal_arctic/adult/matriarch/adult in range(src.holder.owner, 8))
		if (!isdead(adult))
			. += adult
