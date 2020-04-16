// A dummy parent type used for easily making components that are active when blocking with an item

/datum/component/itemblock
	var/list/signals = list()
	var/proctype // = .proc/pass

/datum/component/itemblock/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_BEGIN, .proc/on_block_begin)
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_END, .proc/on_block_end)


/datum/component/itemblock/proc/on_block_begin(datum/source, mob/user)
	RegisterSignal(user, signals, proctype, TRUE)

/datum/component/itemblock/proc/on_block_end(datum/source, mob/user)
	UnregisterSignal(user, signals)
