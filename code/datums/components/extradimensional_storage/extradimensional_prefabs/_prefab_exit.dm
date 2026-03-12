/datum/component/extradimensional_prefab_exit
	var/datum/callback/exit_callback = null

/datum/component/extradimensional_prefab_exit/Initialize(datum/callback/exit_callback)
	. = ..()
	src.RegisterSignal(src.parent, COMSIG_EXTRADIMENSIONAL_PREFAB_EXIT, PROC_REF(exit_extradimensional_prefab))
	src.exit_callback = exit_callback
	START_TRACKING

/datum/component/extradimensional_prefab_exit/UnregisterFromParent()
	src.UnregisterSignal(src.parent, COMSIG_EXTRADIMENSIONAL_PREFAB_EXIT)
	QDEL_NULL(src.exit_callback)
	STOP_TRACKING
	. = ..()

/datum/component/extradimensional_prefab_exit/proc/exit_extradimensional_prefab(_, atom/movable/AM, atom/old_loc)
	SEND_SIGNAL(src, COMSIG_EXTRADIMENSIONAL_PREFAB_EXIT, AM, old_loc)
