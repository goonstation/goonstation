/datum/component/wearertargeting/unarmedblock/reflect_gloves/on_block_begin(mob/living/carbon/source, obj/item/grab/block/B)
	B.setProperty("reflection", 1)
	B.AddComponent(/datum/component/holdertargeting/baseball_bat_reflect)

