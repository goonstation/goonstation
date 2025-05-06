ABSTRACT_TYPE(/datum/listen_module/effect)
/**
 *	Listen effect module datums handle all hearing effects associated with receiving a say message datum. They determine what
 *	happens to a message after the parent listen tree has finished processing it. Typically the final destination of say message
 *	datums.
 */
/datum/listen_module/effect
	id = "effect_base"

/datum/listen_module/effect/New(datum/listen_module_tree/parent)
	. = ..()

	src.parent_tree.request_enable()

/datum/listen_module/effect/disposing()
	src.parent_tree.unrequest_enable()

	. = ..()

/datum/listen_module/effect/process(datum/say_message/message)
	return
