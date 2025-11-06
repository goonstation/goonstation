ABSTRACT_TYPE(/datum/speech_module/prefix)
/**
 *	Speech prefix modules handle any operations associated with a specific message prefix or prefixes. Messages with a prefix
 *	will attempt to use the prefix module with the longest matching ID; a message with a prefix of ":lhtest" will attempt to
 *	use the ":lh" prefix module, and only if incompatible will use the ":" prefix module.
 */
/datum/speech_module/prefix
	id = "prefix_base"
	priority = SPEECH_PREFIX_PRIORITY_DEFAULT
	/// The prefix ID that this prefix module corresponds to.
	var/prefix_id = null

/// Returns an associative list of channel names, indexed by prefix.
/datum/speech_module/prefix/proc/get_prefix_choices()
	RETURN_TYPE(/list)
	return


ABSTRACT_TYPE(/datum/speech_module/prefix/premodifier)
/**
 *	Premodifier prefix modules handle prefix operations that should occur prior to module processing effects.
 */
/datum/speech_module/prefix/premodifier


ABSTRACT_TYPE(/datum/speech_module/prefix/postmodifier)
/**
 *	Postmodifier prefix modules handle prefix operations that should occur after module processing effects.
 */
/datum/speech_module/prefix/postmodifier


ABSTRACT_TYPE(/datum/speech_module/prefix/premodifier/channel)
/**
 *	Channel prefix modules are modules that handle prefixes that attempt to divert a message from its original say channel to
 *	another say channel.
 */
/datum/speech_module/prefix/premodifier/channel
	id = "channel_prefix_base"
	/// The channel ID that this channel prefix module should divert say messages to.
	var/channel_id = null

/datum/speech_module/prefix/premodifier/channel/process(datum/say_message/message)
	. = message
	message.output_module_channel = src.channel_id
	message.output_module_override = null
