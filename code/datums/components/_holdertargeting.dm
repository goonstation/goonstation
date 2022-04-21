// A dummy parent type used for easily making components that target an item's holder rather than the item itself.
/datum/component/holdertargeting
	var/list/signals = list()
	var/proctype // = .proc/pass
	var/mobtype = /mob/living
	var/mob/current_user
	var/keep_while_on_mob = FALSE

TYPEINFO(/datum/component/holdertargeting)
	initialization_args = list()

/datum/component/holdertargeting/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/on_pickup)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_dropped)

/datum/component/holdertargeting/proc/on_pickup(datum/source, mob/user)
	if(istype(user, mobtype))
		RegisterSignal(user, signals, proctype, TRUE)
		current_user = user
	else
		UnregisterSignal(user, signals)
		current_user = null

/datum/component/holdertargeting/proc/on_dropped(datum/source, mob/user)
	var/obj/item/I = src.parent
	if (!src.keep_while_on_mob || I.loc != user)
		UnregisterSignal(user, signals)
	current_user = null

/datum/component/holdertargeting/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED))
	if(current_user)
		UnregisterSignal(current_user, signals)
		current_user = null
	. = ..()
