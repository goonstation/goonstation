/datum/component/wearertargeting/unarmedblock/unarmed_bonus_block
	var/types = list()

/datum/component/wearertargeting/unarmedblock/unarmed_bonus_block/Initialize(_valid_slots, list/types)
	. = ..()
	src.types = types

/datum/component/wearertargeting/unarmedblock/unarmed_bonus_block/on_block_begin(mob/living/carbon/source, obj/item/grab/block/B)
	RegisterSignal(B, COMSIG_BLOCK_BLOCKED, PROC_REF(apply_bonus))
	. = ..()
	for(var/type in types)
		B.setProperty("I_block_[type]", 1)

/datum/component/wearertargeting/unarmedblock/unarmed_bonus_block/on_block_end(mob/living/carbon/source, obj/item/grab/block/B)
	UnregisterSignal(B, COMSIG_BLOCK_BLOCKED)
	. = ..()

/datum/component/wearertargeting/unarmedblock/unarmed_bonus_block/proc/apply_bonus(obj/item/grab/block/B, type, list/ret)
	if(isnum(src.types[DAMAGE_TYPE_TO_STRING(type)]))
		ret[1] += src.types[DAMAGE_TYPE_TO_STRING(type)]
