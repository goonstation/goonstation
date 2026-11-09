/datum/component/extradimensional_prefab_entrance
	var/datum/callback/enter_callback = null

/datum/component/extradimensional_prefab_entrance/Initialize(datum/callback/enter_callback)
	. = ..()
	src.RegisterSignal(src.parent, COMSIG_EXTRADIMENSIONAL_PREFAB_ENTERED, PROC_REF(enter_extradimensional_prefab))
	src.enter_callback = enter_callback
	START_TRACKING

/datum/component/extradimensional_prefab_entrance/UnregisterFromParent()
	src.UnregisterSignal(src.parent, COMSIG_EXTRADIMENSIONAL_PREFAB_ENTERED)
	QDEL_NULL(src.enter_callback)
	STOP_TRACKING
	. = ..()

/datum/component/extradimensional_prefab_entrance/proc/enter_extradimensional_prefab(_, atom/movable/AM)
	src.enter_callback.Invoke(AM)
