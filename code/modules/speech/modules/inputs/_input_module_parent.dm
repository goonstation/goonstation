ABSTRACT_TYPE(/datum/listen_module/input)
/**
 *	Listen module input datums modify say message datums passed to them from the say channel that they are subscribed to, then
 *	in turn pass the message to their parent listen module tree for further processing.
 */
/datum/listen_module/input
	id = "input_base"
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

/// Changes the channel this listen module should be registered to and re-registers it.
/datum/listen_module/input/proc/ChangeChannel(new_channel)
	src.say_channel.UnregisterInput(src)
	src.say_channel = null
	src.parent_tree.input_modules_by_channel[src.channel] -= src

	src.channel = new_channel
	src.say_channel = global.SpeechManager.GetSayChannelInstance(src.channel)
	src.say_channel.RegisterInput(src)
	src.parent_tree.input_modules_by_channel[src.channel] ||= list()
	src.parent_tree.input_modules_by_channel[src.channel] += src

/// Applies listener-specific formatting to the message. Shared input format modules handle general fomatting.
/datum/listen_module/input/proc/format(datum/say_message/message)
	return


ABSTRACT_TYPE(/datum/listen_module/input/bundled)
/**
 *	Bundled listen module input datums operate in a similar manner to ordinary listen inputs, however instead of receiving every
 *	message passed over an ordinary say channel, they are subscribed to specific subchannel of a bundled say channel.
 */
/datum/listen_module/input/bundled
	var/subchannel = "none"

/// Changes the subchannel this listen module should be registered to and re-registers it.
/datum/listen_module/input/bundled/proc/ChangeSubchannel(new_subchannel)
	src.say_channel.UnregisterInput(src)
	src.subchannel = new_subchannel
	src.say_channel.RegisterInput(src)
