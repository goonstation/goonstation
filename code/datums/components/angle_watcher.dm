TYPEINFO(/datum/component/angle_watcher)
	initialization_args = list(
		ARG_INFO("target", DATA_INPUT_REFPICKER, "The atom to watch.", null),
		ARG_INFO("animate_time", DATA_INPUT_NUM, "How long it takes to animate to the new angle.", 2 DECI SECONDS)
	)
/datum/component/angle_watcher
	var/atom/target = null
	var/animate_time = 2 DECI SECONDS
	var/matrix/base_transform = null

/datum/component/angle_watcher/Initialize(atom/target, animate_time = 2 DECI SECONDS)
	. = ..()
	if (. == COMPONENT_INCOMPATIBLE || !istype(target) || !isatom(src.parent))
		return COMPONENT_INCOMPATIBLE
	src.target = target
	src.animate_time = animate_time
	var/atom/aparent = src.parent
	src.base_transform = aparent.transform

/datum/component/angle_watcher/RegisterWithParent()
	RegisterSignal(src.target, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(watch))
	RegisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(watch))

/datum/component/angle_watcher/UnregisterFromParent()
	UnregisterSignal(src.target, XSIG_MOVABLE_TURF_CHANGED)
	UnregisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED)

/datum/component/angle_watcher/proc/watch()
	var/atom/aparent = src.parent //this is safe, we checked on init
	var/turf/here = get_turf(aparent)
	var/turf/there = get_turf(src.target)
	if(isnull(here) || isnull(there) || here.z != there.z || here == there)
		return
	var/angle = arctan(
		there.x - here.x,
		there.y - here.y
	)
	animate(aparent, transform=matrix(src.base_transform, 90 - angle, MATRIX_ROTATE), time=src.animate_time, flags=ANIMATION_PARALLEL)
