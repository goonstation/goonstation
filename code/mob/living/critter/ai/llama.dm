/*
 * Copyright (C) 2025 Bartimeus
 * Copyright (C) 2010,2016,2020-2025 Goonstation Contributors
 * 
 * Contributed to the 35 Below Project, derived at least 25.8%
 * from code in Goonstation available through the terms of the
 * CreativeCommons BY-NC-SA 3.0 United States License ONLY.
 * Full terms available in the "LICENSE" file or at:
 * http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 */

/datum/aiHolder/llama
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/llama, list(src))

/datum/aiTask/prioritizer/critter/llama/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/spit_on_a_fool, list(holder, src))

/datum/aiTask/sequence/goalbased/critter/spit_on_a_fool
	name = "spit on a dude"
	weight = 1
	distance_from_target = 3
	max_dist = 5

/datum/aiTask/sequence/goalbased/critter/spit_on_a_fool/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/spit_on_a_fool, list(holder)))

/datum/aiTask/sequence/goalbased/critter/spit_on_a_fool/precondition()
	var/mob/living/critter/C = holder.owner
	if (!ON_COOLDOWN(C, "spit_attack", rand(20,30) SECONDS))
		return C.can_critter_attack()
	return FALSE

/datum/aiTask/sequence/goalbased/critter/spit_on_a_fool/get_targets()
	var/mob/living/critter/C = holder.owner
	return C.seek_target(src.max_dist)

/////////////// The aiTask/succeedable handles the behaviour to do when we're in range of the target

/datum/aiTask/succeedable/critter/spit_on_a_fool
	name = "ranged attack subtask"
	var/has_started = FALSE
	/// Maximum range to engage the target from
	var/max_range = 5
	/// Minimum range from the target
	var/min_range = 3

/datum/aiTask/succeedable/critter/spit_on_a_fool/failed()
	var/mob/living/critter/small_animal/llama/C = holder.owner
	var/mob/T = holder.target
	if(!has_started && !C.can_critter_attack()) //if we haven't started and can't attack, task fail.
		return TRUE
	if(!C || !T || BOUNDS_DIST(C, T) > src.max_range) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/critter/spit_on_a_fool/succeeded()
	var/mob/living/critter/small_animal/llama/C = holder.owner
	return has_started && C.can_critter_attack() //if we've started an attack, and can attack again, then hooray, we have completed this task

/datum/aiTask/succeedable/critter/spit_on_a_fool/on_tick()
	if(!has_started)
		var/mob/living/critter/small_animal/llama/C = holder.owner
		var/mob/T = holder.target
		if(C && T && BOUNDS_DIST(C, T) >= src.min_range)
			holder.owner.set_dir(get_dir(C, T))
			C.llamaspit(T)
			has_started = TRUE

/datum/aiTask/succeedable/critter/spit_on_a_fool/on_reset()
	has_started = FALSE

//--------------------------------------------------------------------------------------------------------------------------------------------------//
