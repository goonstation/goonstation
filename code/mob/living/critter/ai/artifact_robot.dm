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
	add_task(holder.get_instance(/datum/aiTask/succeedable/actionbar/wall_smash, list(holder)))

/datum/aiTask/sequence/goalbased/wall_smash/get_targets()
	var/list/result = list()
	for(var/turf/simulated/wall/W in view(src.max_dist, src.holder.owner))
		result += W
	for(var/obj/structure/girder/G in view(src.max_dist, src.holder.owner))
		result += G
	return result

//subtask for the wall smashing
/datum/aiTask/succeedable/actionbar/wall_smash
	name = "wall smash subtask"
	duration = 5 SECONDS
	callback_proc = PROC_REF(smash_wall_or_girder)
	action_icon = 'icons/ui/actions.dmi'
	action_icon_state = "decon"
	end_message = null
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION

/datum/aiTask/succeedable/actionbar/wall_smash/failed()
	.=..() //did actionbar fail
	if(. || !holder.owner || !holder.target || BOUNDS_DIST(holder.owner, holder.target) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/actionbar/wall_smash/succeeded()
	.=..() //did actionbar succeed
	return . && !istype(holder.target, /turf/simulated/wall) && !istype(holder.target, /obj/structure/girder)

/datum/aiTask/succeedable/actionbar/wall_smash/proc/smash_wall_or_girder(var/mob/owner, var/target)
	var/turf/simulated/wall/W = target
	if(istype(W))
		W.dismantle_wall()
	else
		var/obj/structure/girder/G = holder.target
		if(istype(G))
			qdel(G) //I guess girders don't have a deconstruct proc?

/datum/aiTask/succeedable/actionbar/wall_smash/before_action_start()
	playsound(holder.owner, pick(list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')), 50, TRUE)

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
	max_dist = 5
	score_by_distance_only = FALSE

/datum/aiTask/sequence/goalbased/floor_place/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/actionbar/floor_place, list(holder)))

/datum/aiTask/sequence/goalbased/floor_place/score_target(atom/target)
	. = ..() //score based on distance
	//add a random modifier to each score so we don't just always pick the closest tile
	. += rand(-50,50)

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
/datum/aiTask/succeedable/actionbar/floor_place
	name = "floor place subtask"
	duration = 2 SECONDS
	callback_proc = PROC_REF(place_floor)
	action_icon = 'icons/ui/actions.dmi'
	action_icon_state = "working"
	end_message = null
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION

/datum/aiTask/succeedable/actionbar/floor_place/failed()
	.=..() //did actionbar fail
	if(. || !holder.owner || !holder.target || BOUNDS_DIST(holder.owner, holder.target) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/actionbar/floor_place/succeeded()
	.=..() //did actionbar succeed
	if(.)
		var/mob/living/critter/robotic/artifact/robit = holder.owner
		var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
		if(istype(art_datum))
			return istype(holder.owner.loc, art_datum.floor_type)
	return FALSE

/datum/aiTask/succeedable/actionbar/floor_place/proc/place_floor(var/mob/living/critter/robotic/artifact/owner, var/turf/target)
	if(istype(owner) && istype(target))
		var/datum/artifact/robot/art_datum = owner.parent_artifact?.artifact
		if(istype(art_datum))
			playsound(owner, 'sound/machines/click.ogg', 50, TRUE)
			target.ReplaceWith(art_datum.floor_type)


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
	add_task(holder.get_instance(/datum/aiTask/succeedable/actionbar/wall_place, list(holder)))

/datum/aiTask/sequence/goalbased/wall_place/get_targets()
	. = ..()
	var/list/turf/results = list()
	for(var/turf/T in view(src.max_dist, src.holder.owner))
		if(istype(T, /turf/space) || istype(T, /turf/simulated/wall))
			continue
		results += T
	return results

//subtask for the wall placing
/datum/aiTask/succeedable/actionbar/wall_place
	name = "wall place subtask"
	duration = 3 SECONDS
	callback_proc = PROC_REF(place_wall)
	action_icon = 'icons/ui/actions.dmi'
	action_icon_state = "working"
	end_message = null
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION

/datum/aiTask/succeedable/actionbar/wall_place/failed()
	.=..() //did actionbar fail
	if(. || !holder.owner || !holder.target || BOUNDS_DIST(holder.owner, holder.target) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/actionbar/wall_place/succeeded()
	.=..() //did actionbar succeed
	if(.)
		var/mob/living/critter/robotic/artifact/robit = holder.owner
		var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
		if(istype(art_datum))
			return istype(holder.owner.loc, art_datum.wall_type)
	return FALSE

/datum/aiTask/succeedable/actionbar/wall_place/before_action_start()
	playsound(holder.owner, 'sound/items/Ratchet.ogg', 50, TRUE)


/datum/aiTask/succeedable/actionbar/wall_place/proc/place_wall(var/mob/living/critter/robotic/artifact/owner, var/turf/target)
	if(istype(owner) && istype(target))
		var/datum/artifact/robot/art_datum = owner.parent_artifact?.artifact
		if(istype(art_datum))
			target.ReplaceWith(art_datum.wall_type)

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// recycler

/datum/aiHolder/artifact_recycler
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/artifact_recycler, list(src))

/datum/aiTask/prioritizer/artifact_recycler/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/short, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/recycle_random_object, list(src.holder, src))

/datum/aiTask/sequence/goalbased/recycle_random_object
	name = "recycling objects"
	weight = 1
	distance_from_target = 0
	max_dist = 7

/datum/aiTask/sequence/goalbased/recycle_random_object/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/actionbar/recycle_random_object, list(holder)))

/datum/aiTask/sequence/goalbased/recycle_random_object/get_targets()
	. = ..()
	var/list/obj/item/results = list()
	var/mob/living/critter/robotic/artifact/robit = holder.owner
	var/datum/artifact/robot/art_datum = robit.parent_artifact.artifact
	if(!istype(art_datum))
		return
	for(var/obj/item/O in view(src.max_dist, src.holder.owner))
		if(!istype(O, art_datum.item_type) && istype(O.loc, /turf) && !O.anchored)
			results += O
	return results

//subtask for picking up item
/datum/aiTask/succeedable/actionbar/recycle_random_object
	name = "recycle object subtask"
	duration = 3 SECONDS
	callback_proc = PROC_REF(produce_object)
	action_icon = 'icons/effects/effects.dmi'
	action_icon_state = "gears"
	end_message = null
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION

/datum/aiTask/succeedable/actionbar/recycle_random_object/failed()
	.=..() //did actionbar fail
	if(.)
		//drop the item if the task failed
		var/obj/item/pickup = holder.target
		if(istype(pickup))
			pickup.set_loc(get_turf(holder.owner))
			holder.owner.visible_message(SPAN_NOTICE("[holder.owner] drops \the [pickup] on the floor"))
		return TRUE

/datum/aiTask/succeedable/actionbar/recycle_random_object/before_action_start()
	//pick up the item
	var/obj/item/pickup = holder.target
	if(istype(pickup))
		holder.owner.put_in_hand(pickup)
		pickup.set_loc(holder.owner)
		holder.owner.visible_message(SPAN_NOTICE("[holder.owner] pulls \the [pickup] into itself"))
	playsound(holder.owner, 'sound/items/mining_drill.ogg', 40, TRUE, 0, 0.8)

/datum/aiTask/succeedable/actionbar/recycle_random_object/proc/produce_object(var/mob/living/critter/robotic/artifact/owner, var/obj/item/target)
	if(istype(owner) && istype(target))
		var/datum/artifact/robot/art_datum = owner.parent_artifact?.artifact
		if(istype(art_datum))
			art_datum.absorbed_item_health += target.health*target.amount
			if(art_datum.absorbed_item_health >= art_datum.item_cost)
				var/obj/item/thing = new art_datum.item_type(get_turf(owner)) //spawn item on turf
				holder.owner.visible_message(SPAN_NOTICE("[holder.owner] drops \a [thing] on the floor"))
				art_datum.absorbed_item_health = 0
			qdel(target) //delete the recycled one
