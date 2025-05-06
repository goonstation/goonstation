ABSTRACT_TYPE(/datum/message_modifier)
/**
 *	Message modifier datums permit sayflags to modify the say message datum that they are applied to. This is either performed
 *	prior to a message is sent to an output module, or as the message is being formatted for output after it has been received,
 *	depending on the subtype used.
 */
/datum/message_modifier
	/// The sayflag associated with this message modifier; it *MUST* be unique.
	var/sayflag = 0
	/// How far up the message modifier list this modifier should go. High values get processed before low values.
	var/priority = SAYFLAG_PRIORITY_DEFAULT

/// Handle all processing that pertains to the say pipeline. Return `null` to prevent the message being processed further, or a `/datum/say_message` instance to continue.
/datum/message_modifier/proc/process(datum/say_message/message)
	RETURN_TYPE(/datum/say_message)
	return message


ABSTRACT_TYPE(/datum/message_modifier/preprocessing)
/datum/message_modifier/preprocessing

ABSTRACT_TYPE(/datum/message_modifier/postprocessing)
/datum/message_modifier/postprocessing
