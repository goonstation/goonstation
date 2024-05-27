/datum/say_channel/delimited/local/equipped
	channel_id = SAY_CHANNEL_EQUIPPED

/datum/say_channel/delimited/local/equipped/GetAtomListeners(datum/say_message/message)
	return range(0, message.speaker)
