ABSTRACT_TYPE(/datum/speech_module/output)
/**
 *	Speech output module datums modify say message datums passed to them from a speech module tree, then in turn pass the message
 *	to a say channel datum.
 */
/datum/speech_module/output
	id = "output_base"
	priority = SPEECH_OUTPUT_PRIORITY_DEFAULT
	/// The channel ID that this output module should pass say messages to.
	var/channel = "none"
	/// The say channel datum that this module should pass say messages to.
	var/datum/say_channel/say_channel
	/// The prefix module ID that this output module should add to the parent tree.
	var/speech_prefix = null

/datum/speech_module/output/New(datum/speech_module_tree/parent)
	. = ..()

	src.say_channel = global.SpeechManager.GetSayChannelInstance(src.channel)
	src.say_channel.RegisterOutput(src)

	if (src.speech_prefix)
		src.parent_tree.AddSpeechPrefix(src.speech_prefix)

/datum/speech_module/output/disposing()
	src.say_channel.UnregisterOutput(src)
	src.say_channel = null

	if (src.speech_prefix)
		src.parent_tree.RemoveSpeechPrefix(src.speech_prefix)

	. = ..()

/datum/speech_module/output/process(datum/say_message/message)
	PASS_MESSAGE_TO_SAY_CHANNEL(src.say_channel, message)
	return TRUE


ABSTRACT_TYPE(/datum/speech_module/output/bundled)
/**
 *	Bundled speech output module datums operate in a similar manner to ordinary speech outputs, however instead of sending a say
 *	message datum to an ordinary say channel, they pass it to a specific subchannel of a bundled say channel.
 */
/datum/speech_module/output/bundled
	var/subchannel = "none"

/datum/speech_module/output/bundled/New(datum/speech_module_tree/parent, subchannel)
	src.subchannel = subchannel

	. = ..()

/datum/speech_module/output/bundled/process(datum/say_message/message)
	PASS_MESSAGE_TO_SAY_CHANNEL(src.say_channel, message, src.subchannel)
	return TRUE
