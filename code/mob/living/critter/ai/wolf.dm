/*
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 *
 * Contributed to the 35 Below Project, derived at least 7.1%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/datum/aiHolder/wolf
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/wolf, list(src))

/datum/aiTask/prioritizer/critter/wolf/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/to_other_wolf, list(holder, src))

//--------------------------------------------------------------------------------------------------------------------------------------------------//
// keep close to other wolves
// Modified from capybara behavior but mostly the same
/datum/aiTask/sequence/goalbased/to_other_wolf
	weight = -10 //high value so it always keeps close

/datum/aiTask/sequence/goalbased/to_other_wolf/precondition()
	. = TRUE
	for(var/mob/living/critter/small_animal/wolf/wolf in range(src.holder.owner, 3))
		if (src.holder.owner != wolf && !isdead(wolf))
			return FALSE

/datum/aiTask/sequence/goalbased/to_other_wolf/get_targets()
	. = ..()
	for(var/mob/living/critter/small_animal/wolf/wolf in range(src.holder.owner, 8))
		if (src.holder.owner != wolf && !isdead(wolf))
			. += wolf
