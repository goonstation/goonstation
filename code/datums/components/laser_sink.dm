///Makes an object act as a laser sink - something that does stuff when hit by a laser.
///Parent objects register handlers for COMSIG_LASER_CONNECTED, COMSIG_LASER_DISCONNECTED, and COMSIG_LASER_TRAVERSE
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
	RegisterSignal(src.parent, COMSIG_LASER_INCIDENT, PROC_REF(on_laser_incident))
	RegisterSignal(src.parent, COMSIG_LASER_EXIDENT, PROC_REF(on_laser_exident))
	RegisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC, PROC_REF(on_parent_set_loc))

/datum/component/laser_sink/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_LASER_INCIDENT)
	UnregisterSignal(src.parent, COMSIG_LASER_EXIDENT)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC)

///Called when a laser hits this sink's parent. Forwards to the parent via COMSIG_LASER_CONNECTED to let it react and accept or reject.
/datum/component/laser_sink/proc/on_laser_incident(datum/source, obj/linked_laser/laser)
	if (laser in src.in_lasers)
		return
	// Cycle detection: if the incoming laser descends from an existing laser with the same
	// direction, it's looping back — block it. A different direction means a valid "both sides"
	// reflection (e.g. mirrors), which should be allowed.
	for (var/obj/linked_laser/existing in src.in_lasers)
		if (existing.dir == laser.dir && existing.emitter == laser.emitter)
			return COMPONENT_LASER_BLOCKED
	var/result = SEND_SIGNAL(src.parent, COMSIG_LASER_CONNECTED, laser)
	if (result & COMPONENT_LASER_BLOCKED)
		return COMPONENT_LASER_BLOCKED
	src.in_lasers += laser
	laser.sink = src

///Called when a laser stops hitting this sink's parent. Cleans up tracking and notifies the parent via COMSIG_LASER_DISCONNECTED.
/datum/component/laser_sink/proc/on_laser_exident(datum/source, obj/linked_laser/laser)
	if (!(laser in src.in_lasers))
		return
	src.exident(laser)

///"that's not a word" - 🤓
///Internal cleanup when a laser disconnects. Sends COMSIG_LASER_DISCONNECTED to the parent.
/datum/component/laser_sink/proc/exident(obj/linked_laser/laser)
	src.in_lasers -= laser
	laser.sink = null
	SEND_SIGNAL(src.parent, COMSIG_LASER_DISCONNECTED, laser)

///Should call traverse on all emitted laser segments with the proc passed through
/datum/component/laser_sink/proc/traverse(proc_to_call)
	SEND_SIGNAL(src.parent, COMSIG_LASER_TRAVERSE, proc_to_call)

/datum/component/laser_sink/proc/on_parent_set_loc(atom/movable/source, atom/old_loc)
	if (old_loc != source.loc)
		for (var/obj/linked_laser/laser in src.in_lasers)
			src.exident(laser)

/datum/component/laser_sink/disposing()
	for (var/obj/linked_laser/laser in src.in_lasers)
		src.exident(laser)
	. = ..()
