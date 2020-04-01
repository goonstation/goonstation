// A dummy parent type used for easily making components that target an item's wearer rather than the item itself.

/datum/component/wearertargeting
	var/list/valid_slots = list()
	var/list/signals = list()
	var/proctype // = .proc/pass
	var/mobtype = /mob/living

/datum/component/wearertargeting/Initialize(_valid_slots)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if (islist(_valid_slots))
		src.valid_slots = _valid_slots
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, .proc/on_unequip)

/datum/component/wearertargeting/proc/on_equip(datum/source, mob/equipper, slot)
	if((slot in valid_slots) && istype(equipper, mobtype))
		RegisterSignal(equipper, signals, proctype, TRUE)
	else
		UnregisterSignal(equipper, signals)

/datum/component/wearertargeting/proc/on_unequip(datum/source, mob/user)
	UnregisterSignal(user, signals)
