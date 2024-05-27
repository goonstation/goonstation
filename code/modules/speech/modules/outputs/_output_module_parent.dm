ABSTRACT_TYPE(/datum/speech_module/output)
/**
 *	Speech module output datums modify say message datums passed to them from a speech module tree, then in turn pass the message
 *	to a say channel datum.
 */
/datum/speech_module/output
	id = "output_base"
	/// The channel ID that this output module should pass say messages to.
	var/channel = "none"
	/// The say channel datum that this module should pass say messages to.
	var/datum/say_channel/say_channel
	/// The speech tree that this module belongs to.
	var/datum/speech_module_tree/parent_tree

/datum/speech_module/output/New(datum/speech_module_tree/parent)
	. = ..()
	if (!istype(parent))
		CRASH("Tried to instantiate a listen input without a parent listen tree. You can't do that!")

	src.parent_tree = parent
	src.say_channel = global.SpeechManager.GetSayChannelInstance(src.channel)

/datum/speech_module/output/disposing()
	src.parent_tree = null
	src.say_channel = null

	. = ..()

/datum/speech_module/output/process(datum/say_message/message)
	if (!length(message.atom_listeners_override))
		src.say_channel.PassToChannel(message)
	else
		src.say_channel.PassToOverriddenAtomListeners(message)

	return TRUE


ABSTRACT_TYPE(/datum/speech_module/output/bundled)
/**
 *	Bundled speech module output datums operate in a similar manner to ordinary speech outputs, however instead of sending a say
 *	message datum to an ordinary say channel, they pass it to a specific subchannel of a bundled say channel.
 */
/datum/speech_module/output/bundled
	var/subchannel = "none"

/datum/speech_module/output/bundled/process(datum/say_message/message)
	if (!length(message.atom_listeners_override))
		src.say_channel.PassToChannel(message, src.subchannel)
	else
		src.say_channel.PassToOverriddenAtomListeners(message)

	return TRUE
