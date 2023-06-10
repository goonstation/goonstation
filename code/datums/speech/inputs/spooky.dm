TYPEINFO(/datum/listen_module/input/spooky)
	id = "spooky"
/datum/listen_module/input/spooky
	id = "spooky"
	channel = SAY_CHANNEL_DEAD

	process(datum/say_message/message)
		if(get_turf(src.parent_tree.parent) != get_turf(message.speaker))
			return null

		var/hear_nothing_chance = 90
		var/hear_message_chance = 5
		if(ismob(src.parent_tree.parent))
			var/mob/hearer = src.parent_tree.parent
			if (hearer.job == "Chaplain")
				hear_nothing_chance = 0
				hear_message_chance = 20

		if(prob(hear_nothing_chance))
			return null
		else if(prob(hear_message_chance))
			message.content = stutter(message.content)
		else
			message.content = "You hear muffled speech... but nothing is there..."
		. = ..()

	format(datum/say_message/message)
		//spooky messages don't show who sent them, just the content
		return "<span class='game'><i>[message.content]</i></span>"
