TYPEINFO(/datum/component/proximity)
	initialization_args = list(
		ARG_INFO("enabled", DATA_INPUT_BOOL, "State of detection.", TRUE),
		ARG_INFO("enabled", DATA_INPUT_NUM, "Tiles out to detect.", 1)
	)
/datum/component/proximity
	var/enabled = TRUE
	var/range = 1
	VAR_PRIVATE/list/turf/listening_to //this feels really unclean but the other way involves a bunch of signals and it makes me :( -cringe

/datum/component/proximity/Initialize(enabled = TRUE, range = 1)
	..()
	if(!isatom(src.parent))
		return COMPONENT_INCOMPATIBLE

	src.enabled = enabled
	src.range = range
	src.listening_to = list()

/datum/component/proximity/RegisterWithParent()
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	if(ismovable(src.parent))
		RegisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(parent_moved))
	for(var/turf/T as anything in block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z))
		RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(Detect))
		src.listening_to += T

/datum/component/proximity/UnregisterFromParent()
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	UnregisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED)
	if(isnull(center))
		return //we got kabloowied or something
	for(var/turf/T as anything in src.listening_to)
		UnregisterSignal(T, COMSIG_ATOM_ENTERED)
		src.listening_to -= T

/datum/component/proximity/proc/parent_moved()
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	if(isnull(center))
		return //we got kabloowied or something
	for(var/turf/T as anything in src.listening_to)
		UnregisterSignal(T, COMSIG_ATOM_ENTERED)
		src.listening_to -= T
	for(var/turf/T as anything in block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z))
		RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(Detect))
		src.listening_to += T

/datum/component/proximity/proc/Detect(atom/owner, atom/movable/sensed_object)
	if(!src.enabled || src.parent == sensed_object)
		return

	var/atom/sensing_object = src.parent
	sensing_object.EnteredProximity(sensed_object)
