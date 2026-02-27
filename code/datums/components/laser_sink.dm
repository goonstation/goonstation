///Makes an object act as a laser sink - something that does stuff when hit by a laser.
///Parent objects register handlers for COMSIG_LASER_INCIDENT, COMSIG_LASER_EXIDENT, and COMSIG_LASER_TRAVERSE
///to implement type-specific behavior.
/datum/component/laser_sink
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	///All lasers currently connected to this sink.
	var/list/in_lasers = null

/datum/component/laser_sink/Initialize()
	. = ..()
	if (!isobj(src.parent))
		return COMPONENT_INCOMPATIBLE
	src.in_lasers = list()

/datum/component/laser_sink/RegisterWithParent()
	RegisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC, PROC_REF(on_parent_set_loc))

/datum/component/laser_sink/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC)

///When a laser hits this sink, return TRUE on successful connection
/datum/component/laser_sink/proc/incident(obj/linked_laser/laser)
	var/result = SEND_SIGNAL(src.parent, COMSIG_LASER_INCIDENT, laser)
	if (result & COMPONENT_LASER_BLOCKED)
		return FALSE
	src.in_lasers += laser
	return TRUE

///"that's not a word" - 🤓
///When a laser stops hitting this sink
/datum/component/laser_sink/proc/exident(obj/linked_laser/laser)
	src.in_lasers -= laser
	SEND_SIGNAL(src.parent, COMSIG_LASER_EXIDENT, laser)

///Should call traverse on all emitted laser segments with the proc passed through
/datum/component/laser_sink/proc/traverse(proc_to_call)
	SEND_SIGNAL(src.parent, COMSIG_LASER_TRAVERSE, proc_to_call)

/datum/component/laser_sink/proc/on_parent_set_loc(atom/movable/source, atom/old_loc)
	if (old_loc != source.loc)
		for (var/obj/linked_laser/laser in src.in_lasers.Copy())
			src.exident(laser)

/datum/component/laser_sink/disposing()
	for (var/obj/linked_laser/laser in src.in_lasers.Copy())
		src.exident(laser)
	. = ..()
