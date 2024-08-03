ABSTRACT_TYPE(/datum/listen_module/input)
/**
 *	Listen input module datums modify say message datums passed to them from the say channel that they are subscribed to, then
 *	in turn pass the message to their parent listen module tree for further processing.
 */
/datum/listen_module/input
	id = "input_base"
	priority = LISTEN_INPUT_PRIORITY_DEFAULT
	/// The channel ID that this listen module should listen on.
	var/channel = "none"
	/// The say channel datum that this module is currently listening on.
	var/datum/say_channel/say_channel

/datum/listen_module/input/New(datum/listen_module_tree/parent)
	. = ..()

	src.say_channel = global.SpeechManager.GetSayChannelInstance(src.channel)
	src.say_channel.RegisterInput(src)

/datum/listen_module/input/disposing()
	src.say_channel.UnregisterInput(src)
	src.say_channel = null

	. = ..()

/datum/listen_module/input/process(datum/say_message/message)
	message.received_module = src
	src.parent_tree.process(message)


ABSTRACT_TYPE(/datum/listen_module/input/bundled)
/**
 *	Bundled listen input module datums operate in a similar manner to ordinary listen inputs, however instead of receiving every
 *	message passed over an ordinary say channel, they are subscribed to specific subchannel of a bundled say channel.
 */
/datum/listen_module/input/bundled
	var/subchannel = "none"

/datum/listen_module/input/bundled/New(datum/listen_module_tree/parent, subchannel)
	src.subchannel = subchannel

	. = ..()
