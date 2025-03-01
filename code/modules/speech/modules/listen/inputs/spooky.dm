/datum/listen_module/input/spooky
	id = LISTEN_INPUT_GHOSTLY_WHISPER
	channel = SAY_CHANNEL_GHOSTLY_WHISPER

/datum/listen_module/input/spooky/process(datum/say_message/message)
	var/hear_nothing_chance = 90
	var/hear_message_chance = 5

	if (ismob(src.parent_tree.listener_parent))
		var/mob/hearer = src.parent_tree.listener_parent
		if (hearer.job == "Chaplain")
			hear_nothing_chance = 0
			hear_message_chance = 20

	if (prob(hear_nothing_chance))
		return

	if (prob(hear_message_chance))
		message.content = stutter(message.content)
	else
		message.content = "You hear muffled speech... but nothing is there..."

	. = ..()
