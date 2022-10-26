////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 aquatic mobcritter AIs, found in sealab

	-fish
	-etc

*/
////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/aiHolder/aquatic

////////////////////////////////////////////////////////////////////////////////////////////////////
//king crab
////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/aiHolder/aquatic/king_crab
	var/turf/get_away = null

/datum/aiHolder/aquatic/king_crab/New()
	..()
	default_task = get_instance(/datum/aiTask/crab_behavior, list(src))

/datum/aiTask/crab_behavior
	name = "crab behavior"
	var/datum/aiTask/next = null

/datum/aiTask/crab_behavior/New(parentHolder)
	..(parentHolder)

/datum/aiTask/crab_behavior/on_tick()
	var/mob/living/critter/aquatic/king_crab/K = holder.owner
	if(K.kill_them)
		K.emote("dance")
	else if(K.aquabreath_process.water_need)
		K.emote("scream")
	else
		step_rand(K, 0)

/datum/aiTask/crab_behavior/next_task()
	return next


////////////////////////////////////////////////////////////////////////////////////////////////////
//fish
////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/aiHolder/aquatic/fish
	var/sleeping = 0
	var/waking = 0
	var/datum/sea_hotspot/my_hotspot = null
	exclude_from_mobs_list = 1

/datum/aiHolder/aquatic/fish/New()
	..()
	task_cache += get_instance(/datum/aiTask/find_hotspot, list(src))
	task_cache += get_instance(/datum/aiTask/timed/wander/aquatic, list(src, task_cache[/datum/aiTask/find_hotspot]))
	default_task = get_instance(/datum/aiTask/sequence/hotspot_routine, list(src, task_cache[/datum/aiTask/timed/wander/aquatic]))

/datum/aiHolder/aquatic/fish/tick()
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

/datum/aiTask/sequence/hotspot_routine
	name = "hotspot routine"

/datum/aiTask/sequence/hotspot_routine/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/evaluate_hotspot, list(holder)))
	add_task(holder.get_instance(/datum/aiTask/succeedable/follow_hotspot, list(holder)))
	add_task(holder.get_instance(/datum/aiTask/succeedable/loaf_around, list(holder)))
	current_subtask = subtasks[subtask_index]

/datum/aiTask/succeedable/evaluate_hotspot
	name = "evaluate hotspot"

/datum/aiTask/succeedable/evaluate_hotspot/failed()
	var/datum/aiHolder/aquatic/fish/F = holder
	if (!F.my_hotspot || (GET_DIST(get_turf(holder.owner), F.my_hotspot.center.turf())) > 15)
		. = 1

/datum/aiTask/succeedable/evaluate_hotspot/succeeded()
	var/datum/aiHolder/aquatic/fish/F = holder
	if (F.my_hotspot && (GET_DIST(get_turf(holder.owner), F.my_hotspot.center.turf())) <= 15)
		. = 1

/datum/aiTask/succeedable/evaluate_hotspot/on_tick()
	step_rand(holder.owner, 0)

/datum/aiTask/succeedable/follow_hotspot
	name = "follow hotspot"
	max_fails = 60 // some extra room in case someone is bothering us
	var/distance = 1
	var/center_turf = null

/datum/aiTask/succeedable/follow_hotspot/failed()
	if(distance > 1)
		fails++
	. = (fails >= max_fails)

/datum/aiTask/succeedable/follow_hotspot/succeeded()
	if (distance <= 1)
		. = 1

/datum/aiTask/succeedable/follow_hotspot/on_tick()
	var/datum/aiHolder/aquatic/fish/F = holder
	center_turf = F.my_hotspot.center.turf()
	distance = GET_DIST(get_turf(holder.owner), center_turf)
	step_to(holder.owner, center_turf, distance - 1)

/datum/aiTask/succeedable/loaf_around
	name = "loaf around"
	max_fails = 60
	var/dir = 0

/datum/aiTask/succeedable/loaf_around/failed()
	fails++
	. = (fails >= max_fails)

/datum/aiTask/succeedable/loaf_around/succeeded()
	. = 0

/datum/aiTask/succeedable/loaf_around/on_tick()
	dir++
	if(prob(20))
		var/huh = rand(1,4)
		switch(huh)
			if(1)
				holder.owner.visible_message("<b>[holder.owner]</b> glubs.")
			if(2)
				holder.owner.emote("flip")
			if(3)
				holder.owner.emote("dance")
			if(4)
				holder.owner.visible_message("<b>[holder.owner]</b> blubs.")
	switch(dir)
		if(1 to 4)
			step(holder.owner, NORTH)
		if(5 to 8)
			step(holder.owner, EAST)
		if(9 to 12)
			step(holder.owner, SOUTH)
		if(13 to 16)
			step(holder.owner, WEST)
		if(17)
			dir = 0
			step_rand(holder.owner, 0)

/datum/aiTask/timed/wander/aquatic
	minimum_task_ticks = 60
	maximum_task_ticks = 80

/datum/aiTask/find_hotspot
	name = "find hotspot"

/datum/aiTask/find_hotspot/New(parentHolder)
	..(parentHolder)

/datum/aiTask/find_hotspot/on_tick()
	var/datum/aiHolder/aquatic/fish/F = holder
	var/current_distance = 15
	for (var/datum/sea_hotspot/SH in hotspot_controller.hotspot_groups)
		var/anticipated_distance = GET_DIST(get_turf(holder.owner), SH.center.turf())
		if (anticipated_distance < current_distance)
			F.my_hotspot = SH
			current_distance = anticipated_distance

/datum/aiTask/find_hotspot/next_task()
	. = holder.task_cache[/datum/aiTask/sequence/hotspot_routine]
