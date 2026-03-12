/datum/listen_module/modifier/mob_modifiers
	id = LISTEN_MODIFIER_MOB_MODIFIERS
	priority = LISTEN_MODIFIER_PRIORITY_VERY_HIGH

/datum/listen_module/modifier/mob_modifiers/process(datum/say_message/message)
	. = message

	if (!ismob(src.parent_tree.listener_parent))
		return

	var/mob/mob_listener = src.parent_tree.listener_parent

	if (!mob_listener.hearing_check(TRUE))
		return NO_MESSAGE

	if ((isunconscious(mob_listener) || mob_listener.sleeping || mob_listener.getStatusDuration("unconscious")) && prob(20))
		boutput(mob_listener, "<i>... You can almost hear something ...</i>")
		return NO_MESSAGE
