/datum/component/wearertargeting/unarmedblock
	mobtype = /mob/living/carbon

	on_equip(datum/source, mob/equipper, slot)
		SHOULD_CALL_PARENT(0)
		SHOULD_NOT_OVERRIDE(1)
		if((slot in valid_slots) && istype(equipper, mobtype))
			RegisterSignal(equipper, COMSIG_UNARMED_BLOCK_BEGIN, .proc/on_block_begin, TRUE)
			RegisterSignal(equipper, COMSIG_UNARMED_BLOCK_END, .proc/on_block_end, TRUE)
		else
			UnregisterSignal(equipper, COMSIG_UNARMED_BLOCK_BEGIN)
			UnregisterSignal(equipper, COMSIG_UNARMED_BLOCK_END)


	on_unequip(datum/source, mob/user)
		SHOULD_CALL_PARENT(0)
		SHOULD_NOT_OVERRIDE(1)
		UnregisterSignal(user, COMSIG_UNARMED_BLOCK_BEGIN)
		UnregisterSignal(user, COMSIG_UNARMED_BLOCK_END)


/datum/component/wearertargeting/unarmedblock/proc/on_block_begin(var/mob/living/carbon/source, var/obj/item/grab/block/B)
	RegisterSignal(source, signals, proctype, TRUE)
	SHOULD_CALL_PARENT(1)

/datum/component/wearertargeting/unarmedblock/proc/on_block_end(var/mob/living/carbon/source, var/obj/item/grab/block/B)
	UnregisterSignal(source, signals)
	SHOULD_CALL_PARENT(1)
