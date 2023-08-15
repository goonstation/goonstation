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
	RegisterSignal(src.target, COMSIG_MOVABLE_MOVED, PROC_REF(watch))
	RegisterSignal(src.parent, COMSIG_MOVABLE_MOVED, PROC_REF(watch))

/datum/component/watcher/UnregisterFromParent()
	UnregisterSignal(src.target, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src.parent, COMSIG_MOVABLE_MOVED)

/datum/component/watcher/proc/watch()
	var/atom/aparent = src.parent //this is safe, we checked on init
	aparent.set_dir(get_dir(src.parent, src.target))
