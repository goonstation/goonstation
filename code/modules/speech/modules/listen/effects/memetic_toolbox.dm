/datum/listen_module/effect/memetic_toolbox
	id = LISTEN_EFFECT_MEMETIC_TOOLBOX

/datum/listen_module/effect/memetic_toolbox/process(datum/say_message/message)
	var/obj/item/storage/toolbox/memetic/toolbox = src.parent_tree.listener_parent
	if (!istype(toolbox) || (toolbox.loc != message.speaker))
		return

	for (var/datum/ailment_data/A in toolbox.servantlinks)
		var/mob/living/M = A.affected_mob
		if (!M || (M == message.speaker))
			continue

		boutput(M, "<i><b><font color=blue face=Tempus Sans ITC>[message.content]</font></b></i>")
