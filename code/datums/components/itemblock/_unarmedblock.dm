/datum/component/wearertargeting/unarmedblock
	mobtype = /mob/living/carbon
	var/obj/item/grab/block/affectedBlock //we will only be working on one block at a time. This helps us keep track

	on_equip(datum/source, mob/equipper, slot)
		SHOULD_CALL_PARENT(0)
		. = 0
		if((slot in valid_slots) && istype(equipper, mobtype))
			. = 1
			RegisterSignal(equipper, COMSIG_UNARMED_BLOCK_BEGIN, .proc/on_block_begin, TRUE)
			RegisterSignal(equipper, COMSIG_UNARMED_BLOCK_END, .proc/on_block_end, TRUE)
			var/obj/item/grab/block/B
			if(istype(equipper.l_hand, /obj/item/grab/block))
				B = equipper.l_hand
			else if(istype(equipper.r_hand, /obj/item/grab/block))
				B = equipper.r_hand
			if(B)
				on_block_begin(equipper, B)
		else
			UnregisterSignal(equipper, COMSIG_UNARMED_BLOCK_BEGIN)
			UnregisterSignal(equipper, COMSIG_UNARMED_BLOCK_END)


	on_unequip(datum/source, mob/user)
		SHOULD_CALL_PARENT(0)
		UnregisterSignal(user, COMSIG_UNARMED_BLOCK_BEGIN)
		if(affectedBlock)
			on_block_end(user, affectedBlock)
		UnregisterSignal(user, COMSIG_UNARMED_BLOCK_END)


/datum/component/wearertargeting/unarmedblock/proc/on_block_begin(var/mob/living/carbon/source, var/obj/item/grab/block/B)
	if(affectedBlock)
		on_block_end(source, affectedBlock)
	affectedBlock = B
	RegisterSignal(source, signals, proctype, TRUE)
	SHOULD_CALL_PARENT(1)

//Must clean up anything you're doing to the block in here - this also gets called when the item is unequipped, so that we unmodify our block
/datum/component/wearertargeting/unarmedblock/proc/on_block_end(var/mob/living/carbon/source, var/obj/item/grab/block/B)
	if(affectedBlock)
		affectedBlock = null
	UnregisterSignal(source, signals)
	SHOULD_CALL_PARENT(1)
