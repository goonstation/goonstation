/datum/component/wearertargeting/unarmedblock/concussive
	var/hitcounter = 0

/datum/component/wearertargeting/unarmedblock/concussive/on_equip(datum/source, mob/equipper, slot)
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_SPECIAL_POST, .proc/used_special)


/datum/component/wearertargeting/unarmedblock/concussive/on_block_begin(mob/living/carbon/source, obj/item/grab/block/B)
	. = ..()
	RegisterSignal(B, COMSIG_BLOCK_BLOCKED, .proc/blocked_hit)
	hitcounter = 0



/datum/component/wearertargeting/unarmedblock/concussive/on_block_end(mob/living/carbon/source, obj/item/grab/block/B)
	. = ..()
	UnregisterSignal(B, COMSIG_BLOCK_BLOCKED)
	if(hitcounter > 3)
		SPAWN_DBG(1 DECI SECOND)
			used_special(parent, null)


/datum/component/wearertargeting/unarmedblock/concussive/proc/blocked_hit(obj/item/grab/block/B)
	var/obj/item/clothing/gloves/concussive/conc = parent
	if(hitcounter++ == 3)
		conc.setSpecialOverride(/datum/item_special/slam/no_item_attack, true)
		playsound(get_turf(conc), "sound/items/miningtool_on.ogg", 20, 1, 0, 1.3)

/datum/component/wearertargeting/unarmedblock/concussive/proc/used_special(obj/item/clothing/gloves/concussive/conc, mob/user)
	if(hitcounter > 3)
		conc.setSpecialOverride(null, 0)
		hitcounter = 0
		playsound(get_turf(conc), "sound/items/miningtool_off.ogg", 20, 1, 0, 1.3)
