TYPEINFO(/datum/component/watcher)
	initialization_args = list(
		ARG_INFO("target", DATA_INPUT_REFPICKER, "The atom to watch.", null)
	)
/datum/component/watcher
	var/atom/target = null

/datum/component/watcher/Initialize(atom/target)
	. = ..()
	if (. == COMPONENT_INCOMPATIBLE || !istype(target) || !isatom(src.parent))
		return COMPONENT_INCOMPATIBLE
	src.target = target

/datum/component/watcher/RegisterWithParent()
	RegisterSignal(src.target, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(watch))
	RegisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(watch))

/datum/component/watcher/UnregisterFromParent()
	UnregisterSignal(src.target, XSIG_MOVABLE_TURF_CHANGED)
	UnregisterSignal(src.parent, XSIG_MOVABLE_TURF_CHANGED)

/datum/component/watcher/proc/watch()
	var/atom/aparent = src.parent //this is safe, we checked on init
	aparent.set_dir(get_dir(get_turf(src.parent), get_turf(src.target)))
