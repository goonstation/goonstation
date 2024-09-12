/datum/aiHolder/patroller
	var/datum/aiTask/default_task_type = /datum/aiTask/patrol

/datum/aiHolder/patroller/New()
	..()
	default_task = get_instance(src.default_task_type, list(src))

/// move between targets found with targeting_instance, interrupting to combat_interrupt if seek_target on owner finds a combat target
/datum/aiTask/patrol
	name = "patrolling"
	distance_from_target = 0
	max_dist = 7
	var/combat_subtask_type = /datum/aiTask/sequence/goalbased/critter/attack/fixed_target
	var/targeting_subtask_type = /datum/aiTask/succeedable/patrol_target_locate/global_cannabis
	var/datum/aiTask/succeedable/move/move_subtask
	var/datum/aiTask/sequence/goalbased/critter/attack/fixed_target/combat_subtask
	var/datum/aiTask/succeedable/targeting_subtask

/datum/aiTask/patrol/New(parentHolder, transTask)
	. = ..()
	src.move_subtask = src.holder.get_instance(/datum/aiTask/succeedable/move, list(holder))
	if(istype(src.move_subtask))
		src.move_subtask.max_path_dist = 150
	src.combat_subtask = src.holder.get_instance(src.combat_subtask_type, list(src.holder, src, null))
	src.targeting_subtask = src.holder.get_instance(src.targeting_subtask_type, list(src.holder, src))

/datum/aiTask/patrol/on_tick()
	if(GET_COOLDOWN(src.holder.owner, "HALT_FOR_INTERACTION"))
		return

	if(!ismobcritter(src.holder.owner))
		return

	var/mob/living/critter/C = src.holder.owner
	var/mob/living/combat_target
	if(src.holder.target && isliving(src.holder.target) && C.valid_target(src.holder.target))
		combat_target = src.holder.target
	else
		var/list/mob/living/potential_targets = C.seek_target(src.max_dist)
		if(length(potential_targets) >= 1)
			combat_target = src.get_best_target(potential_targets)

	if(combat_target) // interrupt into combat_interrupt_type
		if(src.combat_subtask.precondition())
			src.holder.stop_move()
			src.combat_subtask.fixed_target = combat_target
			src.holder.interrupt_to_task(src.combat_subtask)
			return

	if(src.holder.target) // MOVE TASK
		// make sure we both set our target and move to our target correctly
		if(src.move_subtask)
			src.move_subtask.distance_from_target = src.distance_from_target
			src.move_subtask.move_target = get_turf(src.holder.target)
			src.move_subtask.on_tick()
			if(src.move_subtask.succeeded())
				src.holder.target = null

	if(!src.holder.target)
		src.targeting_subtask.on_tick()

	. = ..()

/datum/aiTask/succeedable/patrol_target_locate
	max_dist = 120
	max_fails = 3

/datum/aiTask/succeedable/patrol_target_locate/succeeded()
	var/distance = GET_DIST(get_turf(src.holder.owner), get_turf(src.target))
	if(distance <= src.max_dist)
		src.holder.target = get_turf(src.target)

	if(src.holder.target)
		return 1

/datum/aiTask/succeedable/patrol_target_locate/on_reset()
	. = ..()
	src.target = null

/// magically hunt down a weed on our z level
/datum/aiTask/succeedable/patrol_target_locate/global_cannabis/on_tick()
	. = ..()
	for(var/obj/item/X in by_cat[TR_CAT_CANNABIS_OBJ_ITEMS])
		var/obj/item/plant/herb/cannabis/C = X
		if (istype(C) && C.z == holder.owner.z)
			src.holder.target = C
			break

/// packet based patrol pattern
/datum/aiHolder/patroller/packet_based
	default_task_type = /datum/aiTask/patrol/packet_based

/datum/aiTask/patrol/packet_based
	var/net_id
	var/next_patrol_id
	var/atom/nearest_beacon
	var/nearest_beacon_id
	var/nearest_dist
	targeting_subtask_type = /datum/aiTask/succeedable/patrol_target_locate/packet_based

/datum/aiTask/patrol/packet_based/New()
	. = ..()

	src.net_id = generate_net_id(src.holder.owner)

	src.holder.owner.AddComponent(
		/datum/component/packet_connected/radio, \
		"ai_beacon",\
		FREQ_NAVBEACON, \
		src.net_id, \
		null, \
		FALSE, \
		null, \
		FALSE \
	)
	RegisterSignal(src.holder.owner, COMSIG_MOVABLE_RECEIVE_PACKET, PROC_REF(ai_receive_signal))

	var/datum/aiTask/succeedable/patrol_target_locate/packet_based/packet_targeting_subtask = src.targeting_subtask
	packet_targeting_subtask.packet_holder = src

/datum/aiTask/patrol/packet_based/disposing()
	src.targeting_subtask.disposing()
	..()

/datum/aiTask/patrol/packet_based/disposing()
	UnregisterSignal(src.holder.owner, COMSIG_MOVABLE_RECEIVE_PACKET)
	..()

/datum/aiTask/patrol/packet_based/proc/ai_receive_signal(mob/attached, datum/signal/signal, transmission_method, range, connection_id)
	if(!src.holder.enabled) // this ai is off
		return

	var/mob/living/critter/C = src.holder.owner
	if(isliving(src.combat_subtask.fixed_target) && C.valid_target(src.combat_subtask.fixed_target)) // we are in a chase or something
		return

	if(connection_id == "ai_beacon")
		src.nav_beacon_signal(signal)

/datum/aiTask/patrol/packet_based/proc/nav_beacon_signal(datum/signal/signal)
	if(signal.data["address_1"] != src.net_id) // commanding the bot requires directly addressing it
		return

	if(signal.data["auth_code"] != netpass_security) // commanding the bot requires netpass_security
		return

	if(!signal.data["beacon"] || !signal.data["patrol"] || !signal.data["next_patrol"])
		return

	if(!src.next_patrol_id) // we have not yet found a beacon
		var/dist = GET_DIST(get_turf(src.holder.owner),get_turf(signal.source))
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
			SPAWN(3 DECI SECONDS) // nav beacons have a decisecond delay before responding
				src.holder.target = src.nearest_beacon
				src.next_patrol_id = src.nearest_beacon_id
				src.nearest_beacon = null
				src.nearest_beacon_id = null
				src.nearest_dist = null

	else if(signal.data["beacon"] == src.next_patrol_id) // destination reached, or nerd successful
		src.holder.target = signal.source
		src.next_patrol_id = signal.data["next_patrol"]

/datum/aiTask/succeedable/patrol_target_locate/packet_based
	var/datum/aiTask/patrol/packet_based/packet_holder

/datum/aiTask/succeedable/patrol_target_locate/packet_based/on_tick()
	. = ..()
	if(istype(src.packet_holder))
		var/datum/signal/signal = get_free_signal()
		signal.source = src.holder.owner
		signal.data["sender"] = src.packet_holder.net_id
		if(src.packet_holder.next_patrol_id)
			signal.data["findbeacon"] = src.packet_holder.next_patrol_id
		else
			signal.data["findbeacon"] = "patrol"
		SEND_SIGNAL(src.holder.owner, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, "ai_beacon")

/// and lastly, the actual securitron attack task
/datum/aiHolder/patroller/packet_based/securitron
	default_task_type = /datum/aiTask/patrol/packet_based/securitron
	var/is_detaining = FALSE

/datum/aiTask/patrol/packet_based/securitron
	combat_subtask_type = /datum/aiTask/sequence/goalbased/critter/attack/fixed_target/securitron

/datum/aiTask/sequence/goalbased/critter/attack/fixed_target/securitron
	name = "apprehending perp"
	max_dist = 40

/datum/aiTask/sequence/goalbased/critter/attack/fixed_target/securitron/on_tick()
	if(GET_COOLDOWN(src.holder.owner, "HALT_FOR_INTERACTION"))
		return
	. = ..()
	if(src.fixed_target && isliving(src.fixed_target))
		var/mob/living/L = src.fixed_target
		if (istype(src.holder,/datum/aiHolder/patroller/packet_based/securitron))
			var/datum/aiHolder/patroller/packet_based/securitron/securitron_ai = src.holder
			if(securitron_ai.is_detaining)
				return
		if (ishuman(L))
			if(!L.hasStatus("handcuffed"))
				return
		else if (!is_incapacitated(L))
			return
		OVERRIDE_COOLDOWN(src.holder.owner, "HALT_FOR_INTERACTION", 0)
		src.holder.target = null
		src.transition_task = src.holder.default_task
		src.fixed_target = null
		src.holder.interrupt_to_task(src.holder.default_task)
