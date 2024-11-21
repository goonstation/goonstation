///////////////////////////////////////////////////////////////////////////////////////////////////////////
// wallsmasher

/datum/aiHolder/artifact_wallsmasher
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/artifact_wallsmasher, list(src))

/datum/aiTask/prioritizer/artifact_wallsmasher/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/wall_smash, list(src.holder, src))

/datum/aiTask/sequence/goalbased/wall_smash
	name = "smashing walls"
	weight = 1
	distance_from_target = 1
	max_dist = 7

/datum/aiTask/sequence/goalbased/wall_smash/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/wall_smash, list(holder)))

/datum/aiTask/sequence/goalbased/wall_smash/get_targets()
	. = ..()
	var/list/turf/walls = list()
	for(var/turf/simulated/wall/W in view(src.max_dist, src.holder.owner))
		walls += W
	return walls

//subtask for the wall smashing
/datum/aiTask/succeedable/wall_smash
	name = "wall smash subtask"
	var/has_started = FALSE

/datum/aiTask/succeedable/wall_smash/failed()
	if(!holder.owner || !holder.target || BOUNDS_DIST(holder.owner, holder.target) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/wall_smash/succeeded()
	return !istype(holder.target, /turf/simulated/wall)

/datum/aiTask/succeedable/wall_smash/on_tick()
	if(!has_started)
		if(holder.owner && istype(holder.target, /turf/simulated/wall) && BOUNDS_DIST(holder.owner, holder.target) == 0)
			holder.owner.set_dir(get_dir(holder.owner, holder.target))
			var/turf/simulated/wall/W = holder.target
			W.dismantle_wall()
			has_started = TRUE

/datum/aiTask/succeedable/wall_smash/on_reset()
	has_started = FALSE

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// floor builder

/datum/aiHolder/artifact_floorplacer
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/artifact_floorplacer, list(src))

/datum/aiTask/prioritizer/artifact_floorplacer/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/floor_place, list(src.holder, src))

/datum/aiTask/sequence/goalbased/floor_place
	name = "placing floors"
	weight = 1
	distance_from_target = 0
	max_dist = 7

/datum/aiTask/sequence/goalbased/floor_place/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/floor_place, list(holder)))

/datum/aiTask/sequence/goalbased/floor_place/get_targets()
	. = ..()
	var/list/turf/results = list()
	var/mob/living/critter/robotic/artifact/robit = holder.owner
	var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
	if(!istype(art_datum))
		return results
	for(var/turf/T in view(src.max_dist, src.holder.owner))
		if(istype(T, /turf/simulated/wall))
			continue
		if(istype(T, art_datum.floor_type))
			continue
		results += T
	return results

//subtask for the floor placing
/datum/aiTask/succeedable/floor_place
	name = "floor place subtask"
	var/has_started = FALSE

/datum/aiTask/succeedable/floor_place/failed()
	var/mob/living/critter/robotic/artifact/robit = holder.owner
	var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
	if(!istype(art_datum))
		return TRUE
	if(!holder.owner || !istype(holder.owner.loc, art_datum.floor_type) || BOUNDS_DIST(holder.owner, holder.target) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/floor_place/succeeded()
	var/mob/living/critter/robotic/artifact/robit = holder.owner
	var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
	if(istype(art_datum))
		return istype(holder.owner.loc, art_datum.floor_type)
	return FALSE

/datum/aiTask/succeedable/floor_place/on_tick()
	if(!has_started)
		if(holder.owner && BOUNDS_DIST(holder.owner, holder.target) == 0)
			holder.owner.set_dir(get_dir(holder.owner, holder.target))
			var/turf/floor = holder.target
			var/mob/living/critter/robotic/artifact/robit = holder.owner
			var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
			if(istype(art_datum))
				floor.ReplaceWith(art_datum.floor_type)
			has_started = TRUE

/datum/aiTask/succeedable/floor_place/on_reset()
	has_started = FALSE

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// wall builder

/datum/aiHolder/artifact_wallplacer
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/artifact_wallplacer, list(src))

/datum/aiTask/prioritizer/artifact_wallplacer/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/wall_place, list(src.holder, src))

/datum/aiTask/sequence/goalbased/wall_place
	name = "placing walls"
	weight = 1
	distance_from_target = 0
	max_dist = 7

/datum/aiTask/sequence/goalbased/wall_place/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/wall_place, list(holder)))

/datum/aiTask/sequence/goalbased/wall_place/get_targets()
	. = ..()
	var/list/turf/results = list()
	for(var/turf/T in view(src.max_dist, src.holder.owner))
		if(istype(T, /turf/space) || istype(T, /turf/simulated/wall))
			continue
		results += T
	return results

//subtask for the wall placing
/datum/aiTask/succeedable/wall_place
	name = "wall place subtask"
	var/has_started = FALSE

/datum/aiTask/succeedable/wall_place/failed()
	var/mob/living/critter/robotic/artifact/robit = holder.owner
	var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
	if(!istype(art_datum))
		return TRUE
	if(!holder.owner || !istype(holder.owner.loc, art_datum.floor_type) || BOUNDS_DIST(holder.owner, holder.target) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/wall_place/succeeded()
	var/mob/living/critter/robotic/artifact/robit = holder.owner
	var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
	if(istype(art_datum))
		return istype(holder.owner.loc, art_datum.wall_type)
	return FALSE

/datum/aiTask/succeedable/wall_place/on_tick()
	if(!has_started)
		if(holder.owner && BOUNDS_DIST(holder.owner, holder.target) == 0)
			holder.owner.set_dir(get_dir(holder.owner, holder.target))
			var/turf/floor = holder.target
			var/mob/living/critter/robotic/artifact/robit = holder.owner
			var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
			if(istype(art_datum))
				floor.ReplaceWith(art_datum.wall_type)
			has_started = TRUE

/datum/aiTask/succeedable/wall_place/on_reset()
	has_started = FALSE
