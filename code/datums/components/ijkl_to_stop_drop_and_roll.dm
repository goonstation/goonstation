ABSTRACT_TYPE(datum/component/filtered_accumulator_trigger)
datum/component/filtered_accumulator_trigger
	var/list/timestamps = new/list()
	var/list/valid_inputs
	var/count_required_to_trigger = 10
	var/required_time_interval = 10 SECONDS
	var/index_in_list = 0

/datum/component/filtered_accumulator_trigger/Initialize()
	timestamps.len = count_required_to_trigger
	..()

/datum/component/filtered_accumulator_trigger/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_ATOM_DIR_CHANGED), .proc/receive_input)
	return  //No need to ..()

/datum/component/mechanics_holder/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_DIR_CHANGED))
	return  //No need to ..()

/datum/component/filtered_accumulator_trigger/proc/receive_input(var/comsig_target, var/input)
	if(!(input in valid_inputs))
		return
	if(!precondition())
		return
	log_timestamp()
	if(trigger_condition())
		on_trigger()

/datum/component/filtered_accumulator_trigger/proc/log_timestamp()
	timestamps[index_in_list + 1] = world.time //"+ 1" because of goddamned 1-count lists
	index_in_list = ++index_in_list % count_required_to_trigger

/datum/component/filtered_accumulator_trigger/proc/trigger_condition()
	. = FALSE
	var/oldest_timestamp = world.time
	for(var/timestamp in timestamps)
		if(isnull(timestamp))
			return
		oldest_timestamp = min(timestamp, oldest_timestamp)
	if(oldest_timestamp >= world.time - required_time_interval)
		return TRUE

/datum/component/filtered_accumulator_trigger/proc/on_trigger()
	return

/datum/component/filtered_accumulator_trigger/proc/precondition()
	return TRUE




/datum/component/filtered_accumulator_trigger/ijkl_to_stop_drop_and_roll
	count_required_to_trigger = 5
	required_time_interval = 2 SECONDS
	valid_inputs = list(NORTH, SOUTH, EAST, WEST)

/datum/component/filtered_accumulator_trigger/ijkl_to_stop_drop_and_roll/precondition()
	. = FALSE
	var/mob/living/L = parent
	if(!istype(L))
		return
	if (L.getStatusDuration("burning"))// && L.hasStatus("resting"))
		if (!actions.hasAction(L, "fire_roll"))
			return TRUE //No need to ..()

/datum/component/filtered_accumulator_trigger/ijkl_to_stop_drop_and_roll/on_trigger()
	var/mob/living/L = parent
	if(!istype(L))
		return
	//fire_roll checks these conditions itself during on_update(),
	//but more performant to check now than after action creation.
	if (L.getStatusDuration("burning"))// && L.hasStatus("resting"))
		if (!actions.hasAction(L, "fire_roll"))
			actions.start(new/datum/action/fire_roll(), L)
	return  //No need to ..()
