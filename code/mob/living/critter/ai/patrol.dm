/datum/aiHolder/patroller
	var/atom/patrol_target
	var/atom/next_patrol_target
	var/patrol_id
	var/next_patrol_id

	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/patroller, list(src))

/datum/aiTask/prioritizer/critter/patroller/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/patrol, list(holder, src))

/datum/aiTask/sequence/patrol
	name = "patrolling"
	distance_from_target = 0
	max_dist = 0
	var/datum/aiHolder/patroller/pat_holder
	var/targeting_subtask = /datum/aiTask/succeedable/patrol_target_locate/global_cannabis

	New(parentHolder, transTask)
		. = ..()
		src.pat_holder = holder
		add_task(src.holder.get_instance(src.targeting_subtask, list(holder)))
		var/datum/aiTask/succeedable/move/movesubtask = holder.get_instance(/datum/aiTask/succeedable/move, list(holder))
		if(istype(movesubtask))
			movesubtask.max_path_dist = 150
		add_task(movesubtask)

	get_targets()
		return list(src.pat_holder.next_patrol_target)

	switched_to()
		src.pat_holder.patrol_target = pat_holder.next_patrol_target
		src.pat_holder.next_patrol_target = null
		. = ..()

	on_tick()
		if (!src.holder.target)
			src.holder.target = src.target

		if(istype(subtasks[subtask_index], /datum/aiTask/succeedable/move)) // MOVE TASK
			// make sure we both set our target and move to our target correctly
			var/datum/aiTask/succeedable/move/M = subtasks[subtask_index]
			if(M && !M.move_target)
				M.distance_from_target = src.distance_from_target
				M.move_target = get_turf(holder.target)
		. = ..()

/datum/aiHolder/patroller/packet_based
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/patroller/packet_based, list(src))

/datum/aiTask/prioritizer/critter/patroller/packet_based/New()
	..()
	//transition_tasks += holder.get_instance(/datum/aiTask/sequence/patrol/packet_based, list(holder, src))

/datum/aiTask/succeedable/patrol_target_locate
	max_dist = 150
	max_fails = 3
	var/atom/potential_target
	var/datum/aiHolder/patroller/pat_holder

	New(parentHolder)
		. = ..()
		src.pat_holder = src.holder

	succeeded()
		if(src.potential_target)
			var/distance = GET_DIST(get_turf(src.holder.owner), get_turf(src.potential_target))
			if(distance > 1 && distance <= src.max_dist)
				src.pat_holder.next_patrol_target = src.potential_target
				src.holder.target = get_turf(src.potential_target)
				return 1
		return 0

	on_reset()
		. = ..()
		src.potential_target = null

/// magically hunt down a weed
/datum/aiTask/succeedable/patrol_target_locate/global_cannabis/on_tick()
	. = ..()
	src.potential_target = pick(by_cat[TR_CAT_CANNABIS_OBJ_ITEMS])
