// A dummy parent type used for easily making components that target an item's holder rather than the item itself.

/datum/component/holdertargeting
	var/list/signals = list()
	var/proctype // = .proc/pass
	var/mobtype = /mob/living

/datum/component/holdertargeting/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/on_pickup)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_dropped)

/datum/component/holdertargeting/proc/on_pickup(datum/source, mob/user)
	if(istype(user, mobtype))
		RegisterSignal(user, signals, proctype, TRUE)
	else
		UnregisterSignal(user, signals)

/datum/component/holdertargeting/proc/on_dropped(datum/source, mob/user)
	UnregisterSignal(user, signals)
