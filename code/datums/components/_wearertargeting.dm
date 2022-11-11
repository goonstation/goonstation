// A dummy parent type used for easily making components that target an item's wearer rather than the item itself.

TYPEINFO(/datum/component/wearertargeting)
	initialization_args = list(
		ARG_INFO("valid_slots", DATA_INPUT_LIST_BUILD, "List of wear slots that the component should function in \[1-19\]")
	)

/datum/component/wearertargeting
	var/list/valid_slots = list()
	var/list/signals = list()
	var/proctype // = .proc/pass
	var/mobtype = /mob/living
	var/mob/current_user

/datum/component/wearertargeting/Initialize(_valid_slots)
	SHOULD_CALL_PARENT(1)
	..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if (islist(_valid_slots))
		src.valid_slots = _valid_slots
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, .proc/on_unequip)

/datum/component/wearertargeting/proc/on_equip(datum/source, mob/equipper, slot)
	SHOULD_CALL_PARENT(1)
	if((slot in valid_slots) && istype(equipper, mobtype))
		RegisterSignal(equipper, signals, proctype, TRUE)
		current_user = equipper
	else
		UnregisterSignal(equipper, signals)
		current_user = null

/datum/component/wearertargeting/proc/on_unequip(datum/source, mob/user)
	SHOULD_CALL_PARENT(1)
	UnregisterSignal(user, signals)
	current_user = null

/datum/component/wearertargeting/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED))
	if(current_user)
		UnregisterSignal(current_user, signals)
		current_user = null
	. = ..()
