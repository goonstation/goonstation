TYPEINFO(/datum/component/proximity)
	initialization_args = list(
		ARG_INFO("enabled", DATA_INPUT_BOOL, "State of detection.", TRUE),
		ARG_INFO("enabled", DATA_INPUT_NUM, "Tiles out to detect.", 1)
	)
/datum/component/proximity
	var/enabled = TRUE
	var/range = 1

/datum/component/proximity/Initialize(enabled = TRUE, range = 1)
	..()
	if(!isatom(src.parent))
		return COMPONENT_INCOMPATIBLE

	src.enabled = enabled
	src.range = range

/datum/component/proximity/RegisterWithParent()
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	if(ismovable(src.parent))
		RegisterSignal(src.parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_parent_move))
		RegisterSignal(src.parent, COMSIG_MOVABLE_PRE_SET_LOC, PROC_REF(pre_parent_move))
		RegisterSignal(src.parent, COMSIG_MOVABLE_LOC_CHANGE_CANCELED, PROC_REF(parent_moved)) //we were gonna move but didnt? lets reregister then
		RegisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC, PROC_REF(parent_moved))
		RegisterSignal(src.parent, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))

	for(var/turf/T as anything in block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z))
		RegisterSignal(T, COMSIG_ATOM_CROSSED, PROC_REF(Detect))

/datum/component/proximity/UnregisterFromParent()
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_PRE_SET_LOC)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_LOC_CHANGE_CANCELED)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_SET_LOC)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_MOVED)
	if(isnull(center))
		return //we got kabloowied or something
	for(var/turf/T as anything in block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z))
		UnregisterSignal(T, COMSIG_ATOM_CROSSED)

/datum/component/proximity/proc/pre_parent_move()
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	for(var/turf/T as anything in block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z))
		UnregisterSignal(T, COMSIG_ATOM_CROSSED)

/datum/component/proximity/proc/parent_moved()
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	if(isnull(center))
		return //we got kabloowied or something
	for(var/turf/T as anything in block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z))
		RegisterSignal(T, COMSIG_ATOM_CROSSED, PROC_REF(Detect))

/datum/component/proximity/proc/Detect(atom/owner, atom/movable/sensed_object)
	if(!src.enabled || src.parent == sensed_object) //this should never happen but it never hurts to be safe
		return

	var/atom/sensing_object = src.parent
	sensing_object.EnteredProximity(sensed_object)
