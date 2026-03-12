ABSTRACT_TYPE(/datum/listen_module/modifier)
/**
 *	Listen modifier module datums exist to modify and format say message datums passed to them by a listen module tree.
 */
/datum/listen_module/modifier
	id = "modifier_base"
	priority = LISTEN_MODIFIER_PRIORITY_DEFAULT
	/// Whether this listen modifier module should respect the say channel's `affected_by_modifiers` variable.
	var/override_say_channel_modifier_preference = FALSE
