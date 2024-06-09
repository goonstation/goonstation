ABSTRACT_TYPE(/datum/say_prefix)
/**
 *	Say prefix datums handle any operations associated with a specific message prefix or prefixes. Messages with a prefix will
 *	attempt to use the prefix datum with the longest matching ID; a message with a prefix of ":lhtest" will attempt to use the
 *	":lh" prefix datum, and only if incompatible will use the ":" prefix datum.
 */
/datum/say_prefix
	/// The prefix ID that this prefix datum corresponds to. May be a list of prefixes.
	var/id = null

/// Whether this prefix is compatible with with provided message and speech tree.
/datum/say_prefix/proc/is_compatible_with(datum/say_message/message, datum/speech_module_tree/say_tree)
	. = FALSE

	if (ismob(message.message_origin))
		return TRUE

/// Process the message, applying prefix specific effects. This typically involves copying the message and sending it to an equipped module.
/datum/say_prefix/proc/process(datum/say_message/message, datum/speech_module_tree/say_tree)
	return message
