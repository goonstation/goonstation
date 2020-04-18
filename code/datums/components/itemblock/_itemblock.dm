// A dummy parent type used for easily making components that are active when blocking with an item

/datum/component/itemblock
	var/list/signals = list()
	var/proctype // = .proc/pass
	var/bonus = 0
	var/mobtype = /mob/living


/datum/component/itemblock/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_BEGIN, .proc/on_block_begin)
	RegisterSignal(parent, COMSIG_ITEM_BLOCK_END, .proc/on_block_end)
	var/obj/item/I = src.parent
	if(istype(I) && bonus)
		I.setProperty("block_bonus", 1)

/datum/component/itemblock/proc/on_block_begin(obj/item/I, mob/user)
	if(istype(user, mobtype))
		RegisterSignal(user, signals, proctype, TRUE)
	else
		UnregisterSignal(user, signals)
	if(bonus)
		I.setProperty("block_bonus", 0)

/datum/component/itemblock/proc/on_block_end(obj/item/I, mob/user)
	UnregisterSignal(user, signals)
	if(bonus)
		I.setProperty("block_bonus", 1)
