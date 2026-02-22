ABSTRACT_TYPE(/datum/speech_module/modifier)
/**
 *	Speech modifier module datums exist to modify and format say message datums passed to them by a speech module tree.
 */
/datum/speech_module/modifier
	id = "modifier_base"
	priority = SPEECH_MODIFIER_PRIORITY_DEFAULT
	/// Whether this speech modifier module should respect the say channel's `affected_by_modifiers` variable.
	var/override_say_channel_modifier_preference = FALSE
