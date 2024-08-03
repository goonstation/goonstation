/**
 *	Listen module tree datums handle applying the effects of modifier listen modules to say message datums received by
 *	the parent atom from an input listen module. All say message datums will be processed here prior to being passed to
 *	the `/atom/proc/hear()` proc.
 */
/datum/listen_module_tree
	/// The atom that should receive messages sent to this listen module tree.
	var/atom/listener_parent
	/// The atom that should act as the origin point for listening to messages.
	var/atom/listener_origin
	/// A list of all atoms that list this listen module tree as their listen tree, despite not being the true parent.
	VAR_PROTECTED/list/atom/secondary_parents
	/// A list of all auxiliary listen module trees with this listen module tree registered as a target.
	VAR_PROTECTED/list/datum/listen_module_tree/auxiliary/auxiliary_trees
	/// A temporary buffer of all received messages that are to be outputted to the parent when the buffer is flushed.
	VAR_PROTECTED/list/datum/say_message/message_buffer
	/// An associative list of all signal recipients that may cause the message buffer to flush.
	VAR_PROTECTED/list/datum/signal_recipients

	/// An associative list of input listen module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/input_module_ids_with_subcount
	/// An associative list of input listen modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/listen_module/input/input_modules_by_id
	/// An associative list of input listen modules, indexed by the module channel.
	VAR_PROTECTED/list/list/datum/listen_module/input/input_modules_by_channel

	/// An associative list of modifier listen module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/listen_modifier_ids_with_subcount
	/// An associative list of modifier listen modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/listen_module/modifier/listen_modifiers_by_id
	/// An associative list of modifier listen modules that overide say channel modifier preferences, indexed by the module ID.
	VAR_PROTECTED/list/datum/speech_module/modifier/persistent_listen_modifiers_by_id

	/// An associative list of language datum subscription counts, indexed by the language ID.
	VAR_PROTECTED/list/known_language_ids_with_subcount
	/// An associative list of language datums, indexed by the language ID.
	VAR_PROTECTED/list/datum/language/known_languages_by_id
	/// Whether this listen module tree is capable of understanding all languages.
	VAR_PROTECTED/understands_all_languages = FALSE

/datum/listen_module_tree/New(atom/parent, list/inputs = list(), list/modifiers = list(), list/languages = list())
	. = ..()

	src.listener_parent = parent
	src.listener_origin = parent
	src.secondary_parents = list()
	src.auxiliary_trees = list()
	src.message_buffer = list()
	src.signal_recipients = list()

	src.input_module_ids_with_subcount = list()
	src.input_modules_by_id = list()
	src.input_modules_by_channel = list()

	src.listen_modifier_ids_with_subcount = list()
	src.listen_modifiers_by_id = list()
	src.persistent_listen_modifiers_by_id = list()

	src.known_language_ids_with_subcount = list()
	src.known_languages_by_id = list()

	for (var/input_id in inputs)
		src.AddListenInput(input_id)

	for (var/modifier_id in modifiers)
		src.AddListenModifier(modifier_id)

	for (var/language_id in languages)
		src.AddKnownLanguage(language_id)

/datum/listen_module_tree/disposing()
	for (var/datum/signal_recipient as anything in src.signal_recipients)
		src.UnregisterSignal(signal_recipient, COMSIG_FLUSH_MESSAGE_BUFFER)

	src.signal_recipients = null

	for (var/datum/listen_module_tree/auxiliary/auxiliary_tree as anything in src.auxiliary_trees)
		auxiliary_tree.update_target_listen_tree(null)

	src.auxiliary_trees = null

	for (var/input_id in src.input_modules_by_id)
		qdel(src.input_modules_by_id[input_id])

	src.persistent_listen_modifiers_by_id = null
	for (var/modifier_id in src.listen_modifiers_by_id)
		qdel(src.listen_modifiers_by_id[modifier_id])

	for (var/atom/A as anything in src.secondary_parents)
		A.listen_tree = null

	if (src.listener_parent)
		src.listener_parent.listen_tree = null
		src.listener_parent = null

	src.secondary_parents = null
	src.message_buffer = null
	src.signal_recipients = null
	src.input_modules_by_id = null
	src.listen_modifiers_by_id = null
	src.input_modules_by_channel = null
	src.listener_origin = null

	. = ..()

/// Process the heard message, applying the effects of each listen modifier module.
/datum/listen_module_tree/proc/process(datum/say_message/message)
	if (!istype(message))
		CRASH("A non say_message thing was passed to a listen_module_tree. This should never happen.")

	// If the say channel permits, apply the effects of all languages and modifiers, otherwise only apply modifiers that override say channel preferences.
	if (message.received_module.say_channel.affected_by_modifiers)
		if (src.understands_all_languages || src.known_languages_by_id[message.language.id])
			message = message.language.heard_understood(message)
		else
			message = message.language.heard_not_understood(message)

		if (QDELETED(message))
			return

		for (var/modifier_id in src.listen_modifiers_by_id)
			message = src.listen_modifiers_by_id[modifier_id].process(message)
			// If the module consumed the message, no need to process any further.
			if (QDELETED(message))
				return
	else
		for (var/modifier_id in src.persistent_listen_modifiers_by_id)
			message = src.persistent_listen_modifiers_by_id[modifier_id].process(message)
			// If the module consumed the message, no need to process any further.
			if (QDELETED(message))
				return

	// If a message of this ID already exists in the buffer, do not buffer the new message unless it was heard by a higher priority module.
	if (src.message_buffer[message.id] && (message.received_module.priority <= src.message_buffer[message.id].received_module.priority))
		return

	src.message_buffer[message.id] = message

	if (!src.signal_recipients[message.signal_recipient])
		src.signal_recipients[message.signal_recipient] = TRUE
		src.RegisterSignal(message.signal_recipient, COMSIG_FLUSH_MESSAGE_BUFFER, PROC_REF(flush_message_buffer))

/// Outputs all messages stored in the message buffer to the listener parent.
/datum/listen_module_tree/proc/flush_message_buffer()
	for (var/id in src.message_buffer)
		var/datum/say_message/message = src.message_buffer[id]
		src.listener_parent.hear(message)

		if (src.signal_recipients[message.signal_recipient])
			src.UnregisterSignal(message.signal_recipient, COMSIG_FLUSH_MESSAGE_BUFFER)
			src.signal_recipients -= message.signal_recipient

	src.message_buffer = list()

/// Migrates this listen module tree to a new speaker parent and origin.
/datum/listen_module_tree/proc/migrate_listen_tree(atom/new_parent, atom/new_origin, preserve_old_reference = FALSE)
	var/atom/old_parent = src.listener_parent
	var/atom/old_origin = src.listener_origin
	src.listener_parent = new_parent
	src.listener_origin = new_origin

	if (preserve_old_reference)
		src.secondary_parents += old_parent
	else
		old_parent.listen_tree = null

	if (new_parent.listen_tree != src)
		qdel(new_parent.listen_tree)

	new_parent.listen_tree = src
	src.secondary_parents -= new_parent

	if (old_origin != new_origin)
		SEND_SIGNAL(src, COMSIG_LISTENER_ORIGIN_UPDATED, old_origin, new_origin)

/// Update this listen module tree's listener origin. This will cause parent to hear messages from the location of the new listener origin.
/datum/listen_module_tree/proc/update_listener_origin(atom/new_origin)
	var/atom/old_origin = src.listener_origin
	src.listener_origin = new_origin

	SEND_SIGNAL(src, COMSIG_LISTENER_ORIGIN_UPDATED, old_origin, new_origin)

/// Adds a new input module to the tree. Returns a reference to the new input module on success.
/datum/listen_module_tree/proc/_AddListenInput(input_id, list/arguments = list(), count = 1)
	RETURN_TYPE(/datum/listen_module/input)

	var/module_id = "[input_id][arguments["subchannel"]]"
	src.input_module_ids_with_subcount[module_id] += count
	if (src.input_modules_by_id[module_id])
		return src.input_modules_by_id[module_id]

	arguments["parent"] = src
	var/datum/listen_module/input/new_input = global.SpeechManager.GetInputInstance(input_id, arguments)
	if (!istype(new_input))
		return

	src.input_modules_by_id[module_id] = new_input
	src.input_modules_by_channel[new_input.channel] ||= list()
	src.input_modules_by_channel[new_input.channel] += new_input
	return new_input

/// Removes an input from the tree. Returns TRUE on success, FALSE on failure.
/datum/listen_module_tree/proc/RemoveListenInput(input_id, subchannel, count = 1)
	var/module_id = "[input_id][subchannel]"
	if (!src.input_modules_by_id[module_id])
		return FALSE

	src.input_module_ids_with_subcount[module_id] -= count
	if (!src.input_module_ids_with_subcount[module_id])
		src.input_modules_by_channel[src.input_modules_by_id[module_id].channel] -= src.input_modules_by_id[module_id]
		qdel(src.input_modules_by_id[module_id])
		src.input_modules_by_id -= module_id

	return TRUE

/// Returns the input module that matches the specified ID.
/datum/listen_module_tree/proc/GetInputByID(input_id, subchannel)
	RETURN_TYPE(/datum/listen_module/input)
	return src.input_modules_by_id["[input_id][subchannel]"]

/// Returns a list of output modules that output to the specified channel.
/datum/listen_module_tree/proc/GetInputsByChannel(channel_id)
	RETURN_TYPE(/list/datum/listen_module/input)
	return src.input_modules_by_channel[channel_id]

/// Adds a new modifier module to the tree. Returns a reference to the new modifier module on success.
/datum/listen_module_tree/proc/_AddListenModifier(modifier_id, list/arguments = list(), count = 1)
	RETURN_TYPE(/datum/listen_module/modifier)

	src.listen_modifier_ids_with_subcount[modifier_id] += count
	if (src.listen_modifiers_by_id[modifier_id])
		return src.listen_modifiers_by_id[modifier_id]

	arguments["parent"] = src
	var/datum/listen_module/modifier/new_modifier = global.SpeechManager.GetListenModifierInstance(modifier_id, arguments)
	if (!istype(new_modifier))
		return

	src.listen_modifiers_by_id[modifier_id] = new_modifier
	sortList(src.listen_modifiers_by_id, GLOBAL_PROC_REF(cmp_say_modules), TRUE)

	if (new_modifier.override_say_channel_modifier_preference)
		src.persistent_listen_modifiers_by_id[modifier_id] = new_modifier
		sortList(src.persistent_listen_modifiers_by_id, GLOBAL_PROC_REF(cmp_say_modules), TRUE)

	return new_modifier

/// Removes a modifier from the tree. Returns TRUE on success, FALSE on failure.
/datum/listen_module_tree/proc/RemoveListenModifier(modifier_id, count = 1)
	if (!src.listen_modifiers_by_id[modifier_id])
		return FALSE

	src.listen_modifier_ids_with_subcount[modifier_id] -= count
	if (!src.listen_modifier_ids_with_subcount[modifier_id])
		qdel(src.listen_modifiers_by_id[modifier_id])
		src.listen_modifiers_by_id -= modifier_id
		src.persistent_listen_modifiers_by_id -= modifier_id

	return TRUE

/// Returns the listen modifier module that matches the specified ID.
/datum/listen_module_tree/proc/GetModifierByID(modifier_id)
	RETURN_TYPE(/list/datum/listen_module/modifier)
	return src.listen_modifiers_by_id[modifier_id]

/// Adds a known language to this listen tree. Known languages allow messages to be understood. Returns TRUE on success, FALSE on failure.
/datum/listen_module_tree/proc/AddKnownLanguage(language_id, count = 1)
	if (language_id == LANGUAGE_ALL)
		return src.AddLanguageAllSubcount(count)

	src.known_language_ids_with_subcount[language_id] += count
	if (src.known_languages_by_id[language_id])
		return TRUE

	var/datum/language/language = global.SpeechManager.GetLanguageInstance(language_id)
	if (!istype(language))
		return FALSE

	src.known_languages_by_id[language_id] = language
	return TRUE

/// Removes a known language from this listen tree. Known languages allow messages to be understood. Returns TRUE on success, FALSE on failure.
/datum/listen_module_tree/proc/RemoveKnownLanguage(language_id, count = 1)
	if (language_id == LANGUAGE_ALL)
		return src.RemoveLanguageAllSubcount(count)

	if (!src.known_languages_by_id[language_id])
		return FALSE

	src.known_language_ids_with_subcount[language_id] -= count
	if (!src.known_language_ids_with_subcount[language_id])
		src.known_languages_by_id -= language_id

	return TRUE

/// Adds a count from the `LANGUAGE_ALL` subcount, and enables `understands_all_languages`.
/datum/listen_module_tree/proc/AddLanguageAllSubcount(count = 1)
	src.known_language_ids_with_subcount[LANGUAGE_ALL] += count
	src.understands_all_languages = TRUE
	return TRUE

/// Removes a count from the `LANGUAGE_ALL` subcount, and disables `understands_all_languages` if no counts remain.
/datum/listen_module_tree/proc/RemoveLanguageAllSubcount(count = 1)
	if (!src.understands_all_languages)
		return FALSE

	src.known_language_ids_with_subcount[LANGUAGE_ALL] -= count
	if (!src.known_language_ids_with_subcount[LANGUAGE_ALL])
		src.understands_all_languages = FALSE

	return TRUE
