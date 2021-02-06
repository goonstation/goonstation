////////////////////////////////////////////////////////////////////////////////////////////////////
/*

Generic AI holder for mobs that normally dont have AI, but should in certain situations
Also shuts down if there's a client in it

Also contains strugglecode for when a mob is wrapped in a critter-shell and held by something

*/
////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/aiHolder/generic_ai
	inhibit_while_inhabited = 1

/datum/aiHolder/generic_ai/New()
	..()

/datum/aiHolder/generic_ai/tick()
	if(isdead(owner))
		enabled = 0
		walk(owner,0)
	if (!enabled)
		return
	if(sleeping > 0)
		sleeping--
		return
	else if(waking > 0)
		waking--
	else
		var/stay_awake = 0
		for(var/mob/living/M in view(7, owner))
			if(M.client)
				stay_awake = 1
				waking = 15
				enabled = 1
				break
		if(!stay_awake)
			sleeping = 15
			enabled = 0
	if(!istype(owner.loc, /turf/space/fluid) || owner.z != 1) // fuck finding hotspots when we're in an aquarium or some other zlevel
		step_rand(owner, 0)
		return
	..()

/// Generic violent hold-struggle task manager
/datum/aiTask/prioritizer/struggle_violent
	name = "struggling"

/datum/aiTask/prioritizer/struggle_violent/New(parentHolder, transTask)
	..(parentHolder, transTask)
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/held_random/cute_action, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/held_random/scream, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/held_random/disarm_struggle, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/held_random/harm_struggle, list(holder, src))


/datum/aiTask/prioritizer/struggle_violent/on_tick()
	if(!istype(holder?.owner?.metaholder))
		src.die()
	. = ..()


/// Held mob does something
/datum/aiTask/timed/targeted/held_random
	name = "doing something"
	target_range = 1
	/// An object the mob intends to mess with
	var/atom/target_2

/// Randomly cycle through these things
/datum/aiTask/timed/targeted/held_random/evaluate()
	return precondition() * rand(1,1000)

/datum/aiTask/timed/targeted/held_random/proc/precondition()
	. = istype(holder.metaholder)

/datum/aiTask/timed/targeted/held_random/get_best_target(var/list/targets)
	. = null
	var/best_score = -1.#INF
	if(length(targets))
		for(var/atom/A in targets)
			var/score = src.score_target(A)
			if(score > best_score)
				best_score = score
				. = A
	holder.target = .

/datum/aiTask/timed/targeted/held_random/get_targets()
	. = list()
	if(holder.owner)
		for_by_tcl(cute_target, /mob)
			if (IN_RANGE_TURF(holder.owner, cute_target, target_range) && cute_target != holder.owner && isalive(cute_target))
				. += cute_target

datum/aiTask/timed/targeted/held_random/get_storage_targets()
	. = list()
	if(holder.owner)
		var/mob/living/critter = holder.owner
		if(istype(critter.metaholder.loc, /obj/item/storage))
			var/obj/item/storage/bag = src.metaholder.loc
				. = bag.get_all_contents()
				for(var/atom/A as() in bag_contents) // remove the critter and its shell
					if(istype(A, /obj/item/critter_shell) || A == critter || A == src.target_2)
						. -= A

/datum/aiTask/timed/targeted/held_random/score_target(var/atom/target)
	if(target)
		return rand(1,10) // oh just pick something
	. = 0

/datum/aiTask/timed/targeted/held_random/frustration_check()
	.= 0
	if (holder)
		if (!IN_RANGE_TURF(holder.owner, holder.target, target_range))
			return 1

		if (ismob(holder.target))
			var/mob/M = holder.target
			. = !(holder.target && isalive(M))
		else
			. = !(holder.target)

/datum/aiTask/timed/targeted/held_random/on_tick()
	if(!istype(holder?.owner?.metaholder))
		src.die()
	. = ..()


/// Held mob does something cute
/datum/aiTask/timed/targeted/held_random/cute_action
	name = "doing something cute"

/datum/aiTask/timed/targeted/held_random/on_tick()
	. = ..()
	var/mob/living/critter/owncritter = holder.owner
	var/turf/T = get_turf(owncritter)
	switch(owncritter.get_metaholder_holder())
		if("storage")
			playsound(T, "sound/items/pickup_[max(min(owncritter.w_class,3),1)].ogg", 56, vary=0.2)
			playsound(T, "sound/musical_instruments/Vuvuzela_1.ogg", 100, 1)
			hit_twitch(owncritter.metaholder.loc)
			attack_twitch(owncritter.metaholder)
		if("mob")
			var/list/targets = src.get_targets() + "idiot"
			playsound(T, "sound/musical_instruments/airhorn_1.ogg", 100, 1)
			T.visible_message("[owncritter] does something cute, [pick(targets)]")
	. = ..()

/// scream
/datum/aiTask/timed/targeted/held_random/scream
	name = "screaming"

/datum/aiTask/timed/targeted/held_random/scream/on_tick()
	. = ..()
	var/mob/living/critter/owncritter = holder.owner
	owncritter.emote("scream")
	..()

/// do a disarm-intent struggle
/datum/aiTask/timed/targeted/held_random/disarm_struggle
	name = "wiggling around"

/datum/aiTask/timed/targeted/held_random/disarm_struggle/on_tick()
	. = ..()
	var/mob/living/critter/owncritter = holder.owner
	owncritter.a_intent = INTENT_DISARM
	owncritter.hud?.update_intent()
	owncritter.hud?.update_hands()
	owncritter.struggle()
	..()

/// do a harm-intent struggle
/datum/aiTask/timed/targeted/held_random/harm_struggle
	name = "wiggling around"

/datum/aiTask/timed/targeted/held_random/harm_struggle/on_tick()
	. = ..()
	var/mob/living/critter/owncritter = holder.owner
	owncritter.a_intent = INTENT_HARM
	owncritter.hud?.update_intent()
	owncritter.hud?.update_hands()
	owncritter.struggle()
	..()

