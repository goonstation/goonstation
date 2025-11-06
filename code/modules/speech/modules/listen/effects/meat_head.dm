/datum/listen_module/effect/meat_head
	id = LISTEN_EFFECT_MEAT_HEAD

/datum/listen_module/effect/meat_head/process(datum/say_message/message)
	var/obj/critter/monster_door/meat_head/meat_head = src.parent_tree.listener_parent
	if (!istype(meat_head) || prob(80))
		return

	meat_head.update_meat_head_dialog(message.content)
