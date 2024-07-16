/datum/say_prefix/deadchat
	id = ":d"

/datum/say_prefix/deadchat/is_compatible_with(datum/say_message/message, datum/speech_module_tree/say_tree)
	return ismob(message.speaker) && inafterlife(message.speaker)

/datum/say_prefix/deadchat/process(datum/say_message/message, datum/speech_module_tree/say_tree)
	var/list/datum/speech_module/output/output_modules = say_tree.GetOutputByChannel(SAY_CHANNEL_DEAD)
	if (!length(output_modules))
		return

	output_modules[1].process(message.Copy())
	qdel(message)
