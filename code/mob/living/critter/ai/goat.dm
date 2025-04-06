/*
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 3.6%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/datum/aiHolder/goat
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/goat, list(src))

/datum/aiTask/prioritizer/critter/goat/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/to_other_goat, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))

//--------------------------------------------------------------------------------------------------------------------------------------------------//
// keep close to other goats
// Modified from capybara behavior but mostly the same
/datum/aiTask/sequence/goalbased/to_other_goat
	weight = -10 //high value so it always keeps close

/datum/aiTask/sequence/goalbased/to_other_goat/precondition()
	. = TRUE
	for(var/mob/living/critter/small_animal/goat/goat in range(src.holder.owner, 3))
		if (src.holder.owner != goat && !isdead(goat))
			return FALSE

/datum/aiTask/sequence/goalbased/to_other_goat/get_targets()
	. = ..()
	for(var/mob/living/critter/small_animal/goat/goat in range(src.holder.owner, 8))
		if (src.holder.owner != goat && !isdead(goat))
			. += goat
