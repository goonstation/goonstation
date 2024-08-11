TYPEINFO(/datum/component/proximity)
	initialization_args = list(
		ARG_INFO("enabled", DATA_INPUT_BOOL, "State of detection.", TRUE)
	)
/datum/component/proximity
	var/enabled = TRUE

/datum/component/proximity/Initialize(enabled = TRUE)
	..()
	if(!isatom(src.parent))
		return COMPONENT_INCOMPATIBLE

	src.enabled = enabled

/datum/component/proximity/RegisterWithParent()
	var/atom/A = src.parent
	if(ismovable(src.parent))
		RegisterSignal(src.parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_parent_move))
		RegisterSignal(src.parent, COMSIG_MOVABLE_PRE_SET_LOC, PROC_REF(pre_parent_move))
		RegisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC, PROC_REF(parent_moved))
		RegisterSignal(src.parent, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))

	for(var/turf/T as anything in block(A.x-1, A.y-1, A.z, A.x+1, A.y+1, A.z))
		RegisterSignal(T, COMSIG_ATOM_CROSSED, PROC_REF(Detect))

/datum/component/proximity/UnregisterFromParent()
	var/atom/A = src.parent
	UnregisterSignal(src.parent, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_PRE_SET_LOC)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_MOVED)
	for(var/turf/T as anything in block(A.x-1, A.y-1, A.z, A.x+1, A.y+1, A.z))
		UnregisterSignal(T, COMSIG_ATOM_CROSSED)

/datum/component/proximity/proc/pre_parent_move()
	var/atom/A = src.parent
	for(var/turf/T as anything in block(A.x-1, A.y-1, A.z, A.x+1, A.y+1, A.z))
		UnregisterSignal(T, COMSIG_ATOM_CROSSED)

/datum/component/proximity/proc/parent_moved()
	var/atom/A = src.parent
	for(var/turf/T as anything in block(A.x-1, A.y-1, A.z, A.x+1, A.y+1, A.z))
		RegisterSignal(T, COMSIG_ATOM_CROSSED, PROC_REF(Detect))

/datum/component/proximity/proc/Detect(atom/owner, atom/movable/sensed_object)
	if(!src.enabled || src.parent == sensed_object) //this should never happen but it never hurts to be safe
		return

	var/atom/sensing_object = src.parent
	sensing_object.HasProximity(sensed_object)
