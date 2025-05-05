/**
 *	Listen module tree datums handle applying the effects of languages and listen modifier modules to say message datums
 *	received by any listen input modules registered to itself. Processed messages are then stored in the message buffer
 *	before being sent to listen effect modules.
 */
/datum/listen_module_tree
	/// If disabled, this listen module tree will not receive any messages.
	var/enabled = FALSE
	/// The number of concurrent requests for this listen module tree to be enabled.
	var/enable_requests = 0
	/// The atom that should receive messages sent to this listen module tree.
	var/atom/listener_parent
	/// The atom that should act as the origin point for listening to messages.
	var/atom/listener_origin
	/// A list of all atoms that list this listen module tree as their listen tree, despite not being the true parent.
	VAR_PROTECTED/list/atom/secondary_parents
	/// A list of all auxiliary listen module trees with this listen module tree registered as a target.
	VAR_PROTECTED/list/datum/listen_module_tree/auxiliary/auxiliary_trees
	/// A list of all listen module trees that buffer messages processed by this listen module tree.
	VAR_PROTECTED/list/datum/listen_module_tree/message_importing_trees
	/// A list of all listen module trees that this listen module tree buffers processed messages from.
	VAR_PROTECTED/list/datum/listen_module_tree/message_exporting_trees
	/// A temporary buffer of all received messages that are to be outputted to the parent when the buffer is flushed.
	VAR_PROTECTED/list/datum/say_message/message_buffer
	/// An associative list of all signal recipients that may cause the message buffer to flush.
	VAR_PROTECTED/list/datum/signal_recipients

	/// An associative list of listen input module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/listen_input_ids_with_subcount
	/// An associative list of listen input modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/listen_module/input/listen_inputs_by_id
	/// An associative list of listen input modules, indexed by the module channel.
	VAR_PROTECTED/list/list/datum/listen_module/input/listen_inputs_by_channel

	/// An associative list of listen modifier module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/listen_modifier_ids_with_subcount
	/// An associative list of listen modifier modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/listen_module/modifier/listen_modifiers_by_id
	/// An associative list of listen modifier modules that overide say channel modifier preferences, indexed by the module ID.
	VAR_PROTECTED/list/datum/speech_module/modifier/persistent_listen_modifiers_by_id

	/// An associative list of listen effect module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/listen_effect_ids_with_subcount
	/// An associative list of listen effect modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/listen_module/effect/listen_effects_by_id

	/// An associative list of listen control module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/listen_control_ids_with_subcount
	/// An associative list of listen control modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/listen_module/control/listen_controls_by_id

	/// An associative list of language datum subscription counts, indexed by the language ID.
	VAR_PROTECTED/list/known_language_ids_with_subcount
	/// An associative list of language datums, indexed by the language ID.
	VAR_PROTECTED/list/datum/language/known_languages_by_id
	/// Whether this listen module tree is capable of understanding all languages.
	VAR_PROTECTED/understands_all_languages = FALSE

/datum/listen_module_tree/New(atom/parent, list/inputs = list(), list/modifiers = list(), list/effects = list(), list/controls = list(), list/languages = list())
	. = ..()

	src.listener_parent = parent
	src.listener_origin = parent
	src.secondary_parents = list()
	src.auxiliary_trees = list()
	src.message_importing_trees = list()
	src.message_exporting_trees = list()
	src.message_buffer = list()
	src.signal_recipients = list()

	src.listen_input_ids_with_subcount = list()
	src.listen_inputs_by_id = list()
	src.listen_inputs_by_channel = list()

	src.listen_modifier_ids_with_subcount = list()
	src.listen_modifiers_by_id = list()
	src.persistent_listen_modifiers_by_id = list()

	src.listen_effect_ids_with_subcount = list()
	src.listen_effects_by_id = list()

	src.listen_control_ids_with_subcount = list()
	src.listen_controls_by_id = list()

	src.known_language_ids_with_subcount = list()
	src.known_languages_by_id = list()

	for (var/input_id in inputs)
		src.AddListenInput(input_id)

	for (var/modifier_id in modifiers)
		src.AddListenModifier(modifier_id)

	for (var/effect_id in effects)
		src.AddListenEffect(effect_id)

	for (var/control_id in controls)
		src.AddListenControl(control_id)

	for (var/language_id in languages)
		src.AddKnownLanguage(language_id)

/datum/listen_module_tree/disposing()
	for (var/datum/signal_recipient as anything in src.signal_recipients)
		src.UnregisterSignal(signal_recipient, COMSIG_FLUSH_MESSAGE_BUFFER)

	for (var/datum/listen_module_tree/tree as anything in src.message_importing_trees)
		src.remove_message_importing_tree(tree)

	for (var/datum/listen_module_tree/tree as anything in src.message_exporting_trees)
		tree.remove_message_importing_tree(src)

	for (var/datum/listen_module_tree/auxiliary/auxiliary_tree as anything in src.auxiliary_trees)
		auxiliary_tree.update_target_listen_tree(null)

	for (var/control_id in src.listen_controls_by_id)
		qdel(src.listen_controls_by_id[control_id])

	for (var/effect_id in src.listen_effects_by_id)
		qdel(src.listen_effects_by_id[effect_id])

	src.persistent_listen_modifiers_by_id = null
	for (var/modifier_id in src.listen_modifiers_by_id)
		qdel(src.listen_modifiers_by_id[modifier_id])

	for (var/input_id in src.listen_inputs_by_id)
		qdel(src.listen_inputs_by_id[input_id])

	for (var/atom/A as anything in src.secondary_parents)
		A.listen_tree = null

	if (src.listener_parent)
		src.listener_parent.listen_tree = null
		src.listener_parent = null

	src.listener_origin = null
	src.secondary_parents = null
	src.auxiliary_trees = null
	src.message_importing_trees = null
	src.message_exporting_trees = null
	src.message_buffer = null
	src.signal_recipients = null

	src.listen_inputs_by_id = null
	src.listen_inputs_by_channel = null
	src.listen_modifiers_by_id = null
	src.listen_effects_by_id = null
	src.listen_controls_by_id = null

	. = ..()

/// Process the heard message, applying the effects of each listen modifier module.
/datum/listen_module_tree/proc/process(datum/say_message/message)
	if (!istype(message))
		CRASH("A non say message datum was passed to a listen module tree. This should never happen.")

	// If the say channel permits, apply the effects of all languages and modifiers, otherwise only apply modifiers that override say channel preferences.
	if (message.received_module.say_channel.affected_by_modifiers)
		if (src.understands_all_languages || src.known_languages_by_id[message.language.id])
			message = message.language.heard_understood(message)
		else
			message = message.language.heard_not_understood(message)

		if (!message)
			return

		for (var/modifier_id in src.listen_modifiers_by_id)
			message = src.listen_modifiers_by_id[modifier_id].process(message)
			// If the module consumed the message, no need to process any further.
			if (!message)
				return
	else
		for (var/modifier_id in src.persistent_listen_modifiers_by_id)
			message = src.persistent_listen_modifiers_by_id[modifier_id].process(message)
			// If the module consumed the message, no need to process any further.
			if (!message)
				return

	// Add a copy of the message to the message buffers of all importing listen module trees.
	if (!(message.flags & SAYFLAG_DO_NOT_PASS_TO_IMPORTING_TREES))
		for (var/datum/listen_module_tree/tree as anything in src.message_importing_trees)
			if (!tree.enabled)
				continue

			tree.add_message_to_buffer(message.Copy())

	src.add_message_to_buffer(message)

/// Adds a message to the message buffer, and registers the appropriate signals to the tree.
/datum/listen_module_tree/proc/add_message_to_buffer(datum/say_message/message)
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
		for (var/effect_id in src.listen_effects_by_id)
			src.listen_effects_by_id[effect_id].process(message)

		if (src.signal_recipients[message.signal_recipient])
			src.UnregisterSignal(message.signal_recipient, COMSIG_FLUSH_MESSAGE_BUFFER)
			src.signal_recipients -= message.signal_recipient

	src.message_buffer = list()

/// Enable this listen module tree, allowing it's modules to receive messages.
/datum/listen_module_tree/proc/enable()
	if (src.enabled)
		return

	src.enabled = TRUE
	for (var/input_id in src.listen_inputs_by_id)
		src.listen_inputs_by_id[input_id].enable()

/// Disable this listen module tree, disallowing it's modules to receive messages.
/datum/listen_module_tree/proc/disable()
	if (!src.enabled)
		return

	src.enabled = FALSE
	for (var/input_id in src.listen_inputs_by_id)
		src.listen_inputs_by_id[input_id].disable()

/// Add an enable request to this listen module tree.
/datum/listen_module_tree/proc/request_enable()
	src.enable_requests += 1

	if ((src.enable_requests > 0) && !src.enabled)
		src.enable()

/// Remove an enable request from this listen module tree.
/datum/listen_module_tree/proc/unrequest_enable()
	src.enable_requests -= 1

	if ((src.enable_requests <= 0) && src.enabled)
		src.disable()

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

	if (old_parent != new_parent)
		SEND_SIGNAL(src, COMSIG_LISTENER_PARENT_UPDATED, old_parent, new_parent)

	if (old_origin != new_origin)
		SEND_SIGNAL(src, COMSIG_LISTENER_ORIGIN_UPDATED, old_origin, new_origin)

/// Update this listen module tree's listener origin. This will cause parent to hear messages from the location of the new listener origin.
/datum/listen_module_tree/proc/update_listener_origin(atom/new_origin)
	var/atom/old_origin = src.listener_origin
	src.listener_origin = new_origin

	SEND_SIGNAL(src, COMSIG_LISTENER_ORIGIN_UPDATED, old_origin, new_origin)

/// Register a listen module tree to buffer messages processed by this listen module tree.
/datum/listen_module_tree/proc/add_message_importing_tree(datum/listen_module_tree/tree)
	if (src.message_importing_trees[tree] || (src == tree))
		return

	src.message_importing_trees[tree] = TRUE
	tree.message_exporting_trees[src] = TRUE

	src.request_enable()

/// Unregister a listen module tree from buffering messages processed by this listen module tree.
/datum/listen_module_tree/proc/remove_message_importing_tree(datum/listen_module_tree/tree)
	if (!src.message_importing_trees[tree] || (src == tree))
		return

	src.message_importing_trees -= tree
	tree.message_exporting_trees -= src

	src.unrequest_enable()

/// Adds a new listen input module to the tree. Returns a reference to the new input module on success.
/datum/listen_module_tree/proc/_AddListenInput(input_id, list/arguments = list(), count = 1)
	RETURN_TYPE(/datum/listen_module/input)

	var/module_id = "[input_id][arguments["subchannel"]]"
	src.listen_input_ids_with_subcount[module_id] += count
	if (src.listen_inputs_by_id[module_id])
		return src.listen_inputs_by_id[module_id]

	arguments["parent"] = src
	var/datum/listen_module/input/new_input = global.SpeechManager.GetInputInstance(input_id, arguments)
	if (!istype(new_input))
		return

	src.listen_inputs_by_id[module_id] = new_input
	src.listen_inputs_by_channel[new_input.channel] ||= list()
	src.listen_inputs_by_channel[new_input.channel] += new_input
	return new_input

/// Removes a listen input module from the tree. Returns TRUE on success, FALSE on failure.
/datum/listen_module_tree/proc/RemoveListenInput(input_id, subchannel, count = 1)
	var/module_id = "[input_id][subchannel]"
	if (!src.listen_inputs_by_id[module_id])
		return FALSE

	src.listen_input_ids_with_subcount[module_id] -= count
	if (!src.listen_input_ids_with_subcount[module_id])
		src.listen_inputs_by_channel[src.listen_inputs_by_id[module_id].channel] -= src.listen_inputs_by_id[module_id]
		qdel(src.listen_inputs_by_id[module_id])
		src.listen_inputs_by_id -= module_id

	return TRUE

/// Returns the listen input module that matches the specified ID.
/datum/listen_module_tree/proc/GetInputByID(input_id, subchannel)
	RETURN_TYPE(/datum/listen_module/input)
	return src.listen_inputs_by_id["[input_id][subchannel]"]

/// Returns a list of listen input modules that receive from the specified channel.
/datum/listen_module_tree/proc/GetInputsByChannel(channel_id)
	RETURN_TYPE(/list/datum/listen_module/input)
	return src.listen_inputs_by_channel[channel_id]

/// Adds a new listen modifier module to the tree. Returns a reference to the new modifier module on success.
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

/// Removes a listen modifier module from the tree. Returns TRUE on success, FALSE on failure.
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

/// Adds a new listen effect module to the tree. Returns a reference to the new effect module on success.
/datum/listen_module_tree/proc/_AddListenEffect(effect_id, list/arguments = list(), count = 1)
	RETURN_TYPE(/datum/listen_module/effect)

	src.listen_effect_ids_with_subcount[effect_id] += count
	if (src.listen_effects_by_id[effect_id])
		return src.listen_effects_by_id[effect_id]

	arguments["parent"] = src
	var/datum/listen_module/effect/new_effect = global.SpeechManager.GetListenEffectInstance(effect_id, arguments)
	if (!istype(new_effect))
		return

	src.listen_effects_by_id[effect_id] = new_effect
	return new_effect

/// Removes a listen effect module from the tree. Returns TRUE on success, FALSE on failure.
/datum/listen_module_tree/proc/RemoveListenEffect(effect_id, count = 1)
	if (!src.listen_effects_by_id[effect_id])
		return FALSE

	src.listen_effect_ids_with_subcount[effect_id] -= count
	if (!src.listen_effect_ids_with_subcount[effect_id])
		qdel(src.listen_effects_by_id[effect_id])
		src.listen_effects_by_id -= effect_id

	return TRUE

/// Returns the listen effect module that matches the specified ID.
/datum/listen_module_tree/proc/GetEffectByID(effect_id)
	RETURN_TYPE(/list/datum/listen_module/effect)
	return src.listen_effects_by_id[effect_id]

/// Adds a new listen control module to the tree. Returns a reference to the new control module on success.
/datum/listen_module_tree/proc/_AddListenControl(control_id, list/arguments = list(), count = 1)
	RETURN_TYPE(/datum/listen_module/control)

	src.listen_control_ids_with_subcount[control_id] += count
	if (src.listen_controls_by_id[control_id])
		return src.listen_controls_by_id[control_id]

	arguments["parent"] = src
	var/datum/listen_module/control/new_control = global.SpeechManager.GetListenControlInstance(control_id, arguments)
	if (!istype(new_control))
		return

	src.listen_controls_by_id[control_id] = new_control
	return new_control

/// Removes a listen control module from the tree. Returns TRUE on success, FALSE on failure.
/datum/listen_module_tree/proc/RemoveListenControl(control_id, count = 1)
	if (!src.listen_controls_by_id[control_id])
		return FALSE

	src.listen_control_ids_with_subcount[control_id] -= count
	if (!src.listen_control_ids_with_subcount[control_id])
		qdel(src.listen_controls_by_id[control_id])
		src.listen_controls_by_id -= control_id

	return TRUE

/// Returns the listen control module that matches the specified ID.
/datum/listen_module_tree/proc/GetControlByID(control_id)
	RETURN_TYPE(/list/datum/listen_module/control)
	return src.listen_controls_by_id[control_id]

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
