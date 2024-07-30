/**
 *	Language datums are responsible for modifying say message datums depending on whether they have been understood by the listener.
 *	The listen module tree of the listener determines whether a message has been understood, then passes it to the respective proc
 *	on the langauge datum of the langauge that the message was sent in.
 */
/datum/language
	/// ID string for cache lookups. This is what this language datum is called, and it *MUST* be unique.
	var/id = ""

/// Processes a say message datum that has been understood by the listener, typically not altering it.
/datum/language/proc/heard_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	RETURN_TYPE(/datum/say_message)
	return message

/// Processes a say message datum that has not been understood by the listener, typically either deleting it, or turning its content to gibberish.
/datum/language/proc/heard_not_understood(datum/say_message/message, datum/listen_module_tree/listen_tree)
	RETURN_TYPE(/datum/say_message)

	message.speaker_to_display = message.voice_ident
	return message
