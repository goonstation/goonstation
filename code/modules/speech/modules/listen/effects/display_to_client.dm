/datum/listen_module/effect/display_to_client
	id = LISTEN_EFFECT_DISPLAY_TO_CLIENT

/datum/listen_module/effect/display_to_client/process(datum/say_message/message)
	boutput(src.parent_tree.listener_parent, message.format_for_output(src.parent_tree.listener_parent))
