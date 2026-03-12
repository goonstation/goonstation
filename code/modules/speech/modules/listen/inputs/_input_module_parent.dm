ABSTRACT_TYPE(/datum/listen_module/input)
/**
 *	Listen input module datums modify say message datums passed to them from the say channel that they are subscribed to, then
 *	in turn pass the message to their parent listen module tree for further processing.
 */
/datum/listen_module/input
	id = "input_base"
	priority = LISTEN_INPUT_PRIORITY_DEFAULT
	/// If disabled, this listen module will not receive any messages.
	var/enabled = FALSE
	/// The channel ID that this listen module should listen on.
	var/channel = "none"
	/// The say channel datum that this module is currently listening on.
	var/datum/say_channel/say_channel
	/// Whether this listen module should ignore line of sight checks performed during message dissemination.
	var/ignore_line_of_sight_checks = FALSE

/datum/listen_module/input/New(datum/listen_module_tree/parent)
	. = ..()

	if (src.parent_tree.enabled)
		src.enabled = TRUE

	src.say_channel = global.SpeechManager.GetSayChannelInstance(src.channel)
	if (src.enabled)
		src.say_channel.RegisterInput(src)

/datum/listen_module/input/disposing()
	if (src.enabled)
		src.say_channel.UnregisterInput(src)

	src.say_channel = null

	. = ..()

/datum/listen_module/input/process(datum/say_message/message)
	message.received_module = src
	src.parent_tree.process(message)

/// Enable this listen module, allowing it to receive messages.
/datum/listen_module/input/proc/enable()
	if (src.enabled)
		return

	src.enabled = TRUE
	src.say_channel.RegisterInput(src)

/// Disable this listen module, disallowing it to receive messages.
/datum/listen_module/input/proc/disable()
	if (!src.enabled)
		return

	src.enabled = FALSE
	src.say_channel.UnregisterInput(src)


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
