ABSTRACT_TYPE(/datum/shared_input_format_module)
/**
 *	Shared input format modules correspond to a listen input module, and handle all shared processing for it. Prior to passing a
 *	say message datum to individual inputs, a say channel will group inputs by type, and apply shared processing defined in a
 *	shared input format module once, if it exists. This mitigates the need for input modules to perform redundant processing.
 */
/datum/shared_input_format_module
	/// ID string for cache lookups. This should correspond to the listen input module that shared processing and formatting should be performed for.
	var/id = "input_base"

/// Applies shared processing and formatting to the message.
/datum/shared_input_format_module/proc/process(datum/say_message/message)
	RETURN_TYPE(/datum/say_message)
	return message
