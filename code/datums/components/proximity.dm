TYPEINFO(/datum/component/proximity)
	initialization_args = list(
		ARG_INFO("enabled", DATA_INPUT_BOOL, "State of detection.", TRUE),
		ARG_INFO("range", DATA_INPUT_NUM, "Tiles out to detect.", 1),
		ARG_INFO("turfonly", DATA_INPUT_BOOL, "Whether to only detect when on a turf. Always false on turfs.", TRUE)
	)
/datum/component/proximity
	/// Are we currectly detecting movement?
	VAR_PRIVATE/enabled = TRUE
	/// Tiles out to detect.
	VAR_PRIVATE/range = 1
	/// Do we only detect if we are on a turf?
	VAR_PRIVATE/turfonly = TRUE
	/// Turfs we are currently listening to.
	VAR_PRIVATE/list/turf/listening_to = null //this feels really unclean but the other way involves a bunch of signals and it makes me :( -cringe

/datum/component/proximity/Initialize(enabled = TRUE, range = 1, turfonly = TRUE)
	..()
	if(!isatom(src.parent))
		return COMPONENT_INCOMPATIBLE

	src.enabled = enabled
	src.range = range
	src.turfonly = isturf(src.parent) ? FALSE : turfonly

/datum/component/proximity/RegisterWithParent()
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	if(!src.enabled)
		return
	if(ismovable(src.parent))
		RegisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(parent_moved))
		RegisterSignal(src.parent, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(parent_moved))
	if(src.turfonly && !isturf(istype(A.loc, /obj/item/assembly) ? A.loc.loc : A.loc)) //assemblies are very mean and stuff
		return
	src.listening_to = block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z)
	for(var/turf/T as anything in src.listening_to)
		RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(Detect))

/datum/component/proximity/UnregisterFromParent()
	UnregisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED)
	UnregisterSignal(src.parent, XSIG_OUTERMOST_MOVABLE_CHANGED)
	for(var/turf/T as anything in src.listening_to)
		UnregisterSignal(T, COMSIG_ATOM_ENTERED)
	src.listening_to?.len = 0

/// Update if our parent move into or out of a movable or onto a turf.
/datum/component/proximity/proc/parent_moved()
	var/atom/A = src.parent
	for(var/turf/T as anything in src.listening_to)
		UnregisterSignal(T, COMSIG_ATOM_ENTERED)
	src.listening_to?.len = 0

	var/turf/center = get_turf(A)
	if(isnull(center))
		return //we got kabloowied or something
	if(src.turfonly && !isturf(istype(A.loc, /obj/item/assembly) ? A.loc.loc : A.loc)) //assemblies are very mean and stuff
		return
	src.listening_to = block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z)
	for(var/turf/T as anything in src.listening_to)
		RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(Detect))

/// Sets whether or not we are detecting.
/datum/component/proximity/proc/set_detection(state)
	src.enabled = state
	if(src.enabled)
		var/atom/A = src.parent
		if(ismovable(src.parent))
			RegisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(parent_moved))
			RegisterSignal(src.parent, XSIG_OUTERMOST_MOVABLE_CHANGED, PROC_REF(parent_moved))
		if(src.turfonly && !isturf(istype(A.loc, /obj/item/assembly) ? A.loc.loc : A.loc)) //assemblies are very mean and stuff
			return
		var/turf/center = get_turf(A)
		src.listening_to = block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z)
		for(var/turf/T as anything in src.listening_to)
			RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(Detect))
	else
		UnregisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED)
		UnregisterSignal(src.parent, XSIG_OUTERMOST_MOVABLE_CHANGED)
		for(var/turf/T as anything in src.listening_to)
			UnregisterSignal(T, COMSIG_ATOM_ENTERED)
		src.listening_to?.len = 0

/// Set our range of detection to num.
/datum/component/proximity/proc/set_range(num)
	if(num == src.range)
		return
	src.range = num
	if(!src.enabled)
		return
	for(var/turf/T as anything in src.listening_to)
		UnregisterSignal(T, COMSIG_ATOM_ENTERED)
	src.listening_to?.len = 0
	var/atom/A = src.parent
	var/turf/center = get_turf(A)
	if(src.turfonly && !isturf(istype(A.loc, /obj/item/assembly) ? A.loc.loc : A.loc)) //assemblies are very mean and stuff
		return
	src.listening_to = block(center.x-range, center.y-range, center.z, center.x+range, center.y+range, center.z)
	for(var/turf/T as anything in src.listening_to)
		RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(Detect))

/// Called when something crosses our range of detection.
/datum/component/proximity/proc/Detect(atom/owner, atom/movable/sensed_object)
	if(src.parent == sensed_object)
		return
	if (!src.parent) //I guess we're disposed or something??
		return
	var/atom/sensing_object = src.parent
	sensing_object.EnteredProximity(sensed_object)
