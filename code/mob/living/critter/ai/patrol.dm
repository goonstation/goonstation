/datum/aiHolder/patroller
	New()
		..()
		default_task = get_instance(/datum/aiTask/sequence/patrol, list(src))

/datum/aiTask/sequence/patrol
	name = "patrolling"
	distance_from_target = 0
	max_dist = 0
	var/targeting_subtask = /datum/aiTask/succeedable/patrol_target_locate/global_cannabis

	New(parentHolder, transTask)
		. = ..()
		add_task(src.holder.get_instance(src.targeting_subtask, list(holder)))
		var/datum/aiTask/succeedable/move/movesubtask = holder.get_instance(/datum/aiTask/succeedable/move, list(holder))
		if(istype(movesubtask))
			movesubtask.max_path_dist = 150
		add_task(movesubtask)

	next_task()
		. = ..()
		if (length(holder.priority_tasks)) //consume priority tasks first
			var/datum/aiTask/priority_task = holder.priority_tasks[1]
			holder.priority_tasks -= priority_task
			return priority_task

	on_tick()
		if(src.holder.target && istype(subtasks[subtask_index], /datum/aiTask/succeedable/move)) // MOVE TASK
			// make sure we both set our target and move to our target correctly
			var/datum/aiTask/succeedable/move/M = subtasks[subtask_index]
			if(M && !M.move_target)
				M.distance_from_target = src.distance_from_target
				M.move_target = get_turf(src.holder.target)
		. = ..()

/datum/aiTask/succeedable/patrol_target_locate
	max_dist = 120
	max_fails = 3

	switched_to()
		. = ..()
		src.holder.target = null

	succeeded()
		var/distance = GET_DIST(get_turf(src.holder.owner), get_turf(src.target))
		if(distance > 1 && distance <= src.max_dist)
			src.holder.target = get_turf(src.target)

		if(src.holder.target)
			return 1

	on_reset()
		. = ..()
		src.target = null

/// magically hunt down a weed
/datum/aiTask/succeedable/patrol_target_locate/global_cannabis/on_tick()
	. = ..()
	src.target = pick(by_cat[TR_CAT_CANNABIS_OBJ_ITEMS])

/// securitron patrol pattern
/datum/aiHolder/patroller/packet_based
	var/net_id
	var/next_patrol_id
	var/atom/nearest_beacon
	var/nearest_beacon_id
	var/nearest_dist

	New()
		. = ..()

		default_task = get_instance(/datum/aiTask/sequence/patrol/packet_based, list(src))

		src.net_id = generate_net_id(src.owner)

		src.owner.AddComponent(
			/datum/component/packet_connected/radio, \
			"ai_beacon",\
			FREQ_NAVBEACON, \
			src.net_id, \
			null, \
			FALSE, \
			null, \
			FALSE \
		)
		RegisterSignal(src.owner, COMSIG_MOVABLE_RECEIVE_PACKET, PROC_REF(ai_receive_signal))

	disposing()
		qdel(get_radio_connection_by_id(src.owner, "ai_beacon"))
		UnregisterSignal(src.owner, COMSIG_MOVABLE_RECEIVE_PACKET)
		..()

	proc/ai_receive_signal(mob/attached, datum/signal/signal)
		if(!src.enabled || ismob(src.target)) // this ai is off or fighting
			return

		if(signal.data["auth_code"] != netpass_security) // commanding the bot requires netpass_security
			return

		if(signal.data["address_1"] != src.net_id) // commanding the bot to change destinations requires directly addressing it
			return

		if(!signal.data["beacon"] || !signal.data["patrol"] || !signal.data["next_patrol"])
			return

		if(!src.next_patrol_id) // we have not yet found a beacon
			var/dist = GET_DIST(get_turf(src.owner),get_turf(signal.source))
			if(nearest_beacon) // try to find a better beacon
				if(dist < nearest_dist)
					src.nearest_beacon = signal.source
					src.nearest_beacon_id = signal.data["beacon"]
					src.nearest_dist = dist
				return
			else // start the 1 second countdown to assigning best found beacon as target
				src.nearest_beacon = signal.source
				src.nearest_beacon_id = signal.data["beacon"]
				src.nearest_dist = dist
				SPAWN(1 SECOND) // nav beacons have a decisecond delay before responding
					src.target = src.nearest_beacon
					src.next_patrol_id = src.nearest_beacon_id
					src.nearest_beacon = null
					src.nearest_beacon_id = null
					src.nearest_dist = null

		else if(signal.data["beacon"] == src.next_patrol_id) // destination reached, or nerd successful
			src.target = signal.source
			src.next_patrol_id = signal.data["next_patrol"]

/datum/aiTask/sequence/patrol/packet_based
	targeting_subtask = /datum/aiTask/succeedable/patrol_target_locate/packet_based

/datum/aiTask/succeedable/patrol_target_locate/packet_based
	max_fails = 5 // very generous
	var/packet_sent = FALSE

/datum/aiTask/succeedable/patrol_target_locate/packet_based
	on_reset()
		. = ..()
		packet_sent = FALSE

	on_tick()
		. = ..()
		if(!src.packet_sent && istype(src.holder,/datum/aiHolder/patroller/packet_based))
			var/datum/aiHolder/patroller/packet_based/packet_holder = src.holder
			var/datum/signal/signal = get_free_signal()
			signal.source = src.holder.owner
			signal.data["sender"] = packet_holder.net_id
			if(packet_holder.next_patrol_id)
				signal.data["findbeacon"] = packet_holder.next_patrol_id
			else
				signal.data["findbeacon"] = "patrol"
			SEND_SIGNAL(src.holder.owner, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "ai_beacon")
			src.packet_sent = TRUE
