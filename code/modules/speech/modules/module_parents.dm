ABSTRACT_TYPE(/datum/speech_module)
/**
 *	Speech module datums serve as a parent type for speech outputs and speech modifiers, which exist to modify and format say
 *	message datums passed to them from a speech module tree.
 */
/datum/speech_module
	/// ID string for cache lookups. This is what this module is called, and it *MUST* be unique.
	var/id = "abstract_base"
	/// How far up the tree this module should go. High values get processed before low values.
	var/priority = 0

/// Process the message, applying module specific effects. Return `null` to prevent the message being processed further, or a `/datum/say_message` instance to continue.
/datum/speech_module/proc/process(datum/say_message/message)
	return message


ABSTRACT_TYPE(/datum/listen_module)
/**
 *	Listen module datums serve as a parent type for listen inputs and listen modifiers, which exist to modify and format say
 *	message datums passed to them from a say channel or listen module tree respectively.
 */
/datum/listen_module
	/// ID string for cache lookups. This is what this module is called, and it *MUST* be unique.
	var/id = "abstract_base"
	/// How far up the tree this module should go. High values get processed before low values.
	var/priority = 0
	/// The listen tree that this module belongs to.
	var/datum/listen_module_tree/parent_tree
	/// Whether this module can be removed by its parent listen tree - this is used to prevent ordinary listen trees from removing modules added by auxiliary listen trees.
	var/can_be_removed_by_parent_tree = TRUE

/datum/listen_module/New(datum/listen_module_tree/parent)
	. = ..()
	if (!istype(parent))
		CRASH("Tried to instantiate a listen module without a parent listen tree. You can't do that!")

	src.parent_tree = parent

/datum/listen_module/disposing()
	src.parent_tree = null

	. = ..()

/// Process the message, applying module specific effects. Return `null` to prevent the message being processed further, or a `/datum/say_message` instance to continue.
/datum/listen_module/proc/process(datum/say_message/message)
	return message
