/**
 *	Speech module tree datums handle applying the effects of speech prefix, modifier, and output modules to say message
 *	datums sent by the parent atom. All say message datums will be processed here prior to being passed to the appropriate
 *	say channel by a speech output module.
 */
/datum/speech_module_tree
	/// The owner of this speech module tree.
	var/atom/speaker_parent
	/// The atom that should act as the origin point for sending messages from this speech module tree.
	var/atom/speaker_origin
	/// A list of all atoms that list this speech module tree as their speech tree, despite not being the true parent.
	VAR_PROTECTED/list/atom/secondary_parents
	/// A list of all auxiliary speech module trees with this speech module tree registered as a target.
	VAR_PROTECTED/list/datum/speech_module_tree/auxiliary/auxiliary_trees

	/// An associative list of speech output module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/speech_output_ids_with_subcount
	/// An associative list of speech output modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/speech_module/output/speech_outputs_by_id
	/// An associative list of speech output modules, indexed by the module channel. Additionally, each sublist of modules is sorted by priority.
	VAR_PROTECTED/list/datum/speech_module/output/speech_outputs_by_channel

	/// An associative list of speech modifier module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/speech_modifier_ids_with_subcount
	/// An associative list of speech modifier modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/speech_module/modifier/speech_modifiers_by_id
	/// An associative list of speech modifier modules that overide say channel modifier preferences, indexed by the module ID.
	VAR_PROTECTED/list/datum/speech_module/modifier/persistent_speech_modifiers_by_id

	/// An associative list of speech prefix module subscription counts, indexed by the module ID.
	VAR_PROTECTED/list/speech_prefix_ids_with_subcount
	/// A list of speech prefix modules, sorted by priority.
	VAR_PROTECTED/list/datum/speech_module/prefix/speech_prefixes
	/// An associative list of speech prefix modules, indexed by the module ID.
	VAR_PROTECTED/list/datum/speech_module/prefix/speech_prefixes_by_id
	/// An associative list of speech prefix modules that should be processed before modifiers, indexed by the prefix ID or IDs.
	VAR_PROTECTED/list/datum/speech_module/prefix/premodifier/premodifier_speech_prefixes_by_prefix_id
	/// An associative list of speech prefix modules that should be processed after modifiers, indexed by the prefix ID or IDs.
	VAR_PROTECTED/list/datum/speech_module/prefix/postmodifier/postmodifier_speech_prefixes_by_prefix_id

/datum/speech_module_tree/New(atom/parent, list/outputs = list(), list/modifiers = list(), list/prefixes = list())
	. = ..()

	src.speaker_parent = parent
	src.speaker_origin = parent
	src.secondary_parents = list()
	src.auxiliary_trees = list()

	src.speech_output_ids_with_subcount = list()
	src.speech_outputs_by_id = list()
	src.speech_outputs_by_channel = list()

	src.speech_modifier_ids_with_subcount = list()
	src.speech_modifiers_by_id = list()
	src.persistent_speech_modifiers_by_id = list()

	src.speech_prefix_ids_with_subcount = list()
	src.speech_prefixes = list()
	src.speech_prefixes_by_id = list()
	src.premodifier_speech_prefixes_by_prefix_id = list()
	src.postmodifier_speech_prefixes_by_prefix_id = list()

	for (var/output_id in outputs)
		src.AddSpeechOutput(output_id)

	for (var/modifier_id in modifiers)
		src.AddSpeechModifier(modifier_id)

	for (var/prefix_id in prefixes)
		src.AddSpeechPrefix(prefix_id)

/datum/speech_module_tree/disposing()
	for (var/datum/speech_module_tree/auxiliary/auxiliary_tree as anything in src.auxiliary_trees)
		auxiliary_tree.update_target_speech_tree(null)

	for (var/prefix_id in src.speech_prefixes_by_id)
		qdel(src.speech_modifiers_by_id[prefix_id])

	for (var/modifier_id in src.speech_modifiers_by_id)
		qdel(src.speech_modifiers_by_id[modifier_id])

	for (var/output_id in src.speech_outputs_by_id)
		qdel(src.speech_outputs_by_id[output_id])

	for (var/atom/A as anything in src.secondary_parents)
		A.speech_tree = null

	if (src.speaker_parent)
		src.speaker_parent.speech_tree = null
		src.speaker_parent = null

	src.speaker_origin = null
	src.secondary_parents = null
	src.auxiliary_trees = null

	src.speech_outputs_by_id = null
	src.speech_outputs_by_channel = null
	src.speech_modifiers_by_id = null
	src.persistent_speech_modifiers_by_id = null
	src.speech_prefixes = null
	src.speech_prefixes_by_id = null
	src.premodifier_speech_prefixes_by_prefix_id = null
	src.postmodifier_speech_prefixes_by_prefix_id = null

	. = ..()

/// Process the message, applying the effects of each accent, speech, and output module.
/datum/speech_module_tree/proc/process(datum/say_message/message)
	if (!istype(message))
		CRASH("A non say message datum was passed to a speech module tree. This should never happen.")

	// Apply the effects of any applicable premodifier speech prefix.
	if (message.prefix && !(message.flags & SAYFLAG_PREFIX_PROCESSED))
		message = src.process_prefix(message, src.premodifier_speech_prefixes_by_prefix_id)

	// Get the output modules that this message should be passed to.
	var/list/datum/speech_module/output/output_modules
	if (message.output_module_override)
		var/datum/speech_module/output/output_override = src.GetOutputByID(message.output_module_override)
		if (output_override)
			output_modules = list(output_override)
	else
		output_modules = src.GetOutputsByChannel(message.output_module_channel)

	if (!length(output_modules))
		return

	// If the say channel permits, apply the effects of all modifiers, otherwise only those that override say channel preferences.
	var/was_uncool = global.phrase_log.is_uncool(message.content)
	if (global.SpeechManager.GetSayChannelInstance(message.output_module_channel).affected_by_modifiers)
		for (var/modifier_id in src.speech_modifiers_by_id)
			message = src.speech_modifiers_by_id[modifier_id].process(message)
			// If the module consumed the message, no need to process any further.
			if (!message)
				return
	else
		for (var/modifier_id in src.persistent_speech_modifiers_by_id)
			message = src.persistent_speech_modifiers_by_id[modifier_id].process(message)
			// If the module consumed the message, no need to process any further.
			if (!message)
				return

	// If a combination of message modifiers caused the message's content to become uncool, log the modifier combination and garble the uncool words.
	if (!was_uncool && global.phrase_log.is_uncool(message.content))
		var/list/modifier_ids
		if (global.SpeechManager.GetSayChannelInstance(message.output_module_channel).affected_by_modifiers)
			modifier_ids = src.speech_modifiers_by_id.Copy()
		else
			modifier_ids = src.persistent_speech_modifiers_by_id.Copy()

		logTheThing(LOG_ADMIN, message.speaker, "[message.speaker] tried to say \"[message.original_content]\" but it was garbled into \"[message.content]\", which is uncool by the following effects: [jointext(modifier_ids, ", ")]. The uncool words were garbled.")
		message.content = replacetext(message.content, global.phrase_log.uncool_words, pick("urr", "blargh", "der", "hurr", "pllt"))

	// Apply sayflag message manipulation.
	global.SpeechManager.ApplyMessageModifierPreprocessing(message)

	// If flagged with `SAYFLAG_DO_NOT_OUTPUT`, return the message to the caller without passing it to an output module.
	. = message
	if (message.flags & SAYFLAG_DO_NOT_OUTPUT)
		return

	message.signal_recipient = message

	// Apply the effects of any applicable postmodifier speech prefix.
	if (message.prefix && !(message.flags & SAYFLAG_PREFIX_PROCESSED))
		message = src.process_prefix(message, src.postmodifier_speech_prefixes_by_prefix_id)

	// Attempt to use the highest priority module as an output, defaulting to the next highest priority on failure.
	message.output_module_channel = null
	for (var/datum/speech_module/output/output_module as anything in output_modules)
		if (!CAN_PASS_MESSAGE_TO_SAY_CHANNEL(output_module.say_channel, message))
			boutput(src.speaker_parent, output_module.say_channel.disabled_message)
			continue

		var/datum/say_message/module_message = message.Copy()
		if (!output_module.process(module_message))
			continue

		// Handle say sounds and speech bubbles.
		if (!output_module.say_channel.suppress_say_sound)
			module_message.process_say_sound()
		if (!output_module.say_channel.suppress_speech_bubble)
			module_message.process_speech_bubble()

		break

	SEND_SIGNAL(message, COMSIG_FLUSH_MESSAGE_BUFFER)

/// Attempt to locate an applicable prefix module from the provided prefix module cache, and apply its affects to a say message.
/datum/speech_module_tree/proc/process_prefix(datum/say_message/message, list/datum/speech_module/prefix/module_cache)
	. = message

	var/prefix_id = message.prefix
	var/datum/speech_module/prefix/prefix_module

	// Attempt to locate a speech prefix module ID on this tree that matches the prefix ID, with each iteration using a shorter prefix ID.
	while (length(prefix_id))
		prefix_id = global.SpeechManager.TruncatePrefix(prefix_id)
		prefix_module = module_cache[prefix_id]

		if (prefix_module)
			break

		prefix_id = copytext(prefix_id, 1, length(prefix_id))

	if (!prefix_module)
		return

	// Process the message.
	message.flags |= SAYFLAG_PREFIX_PROCESSED
	message = prefix_module.process(message)

/// Migrates this speech module tree to a new speaker parent and origin.
/datum/speech_module_tree/proc/migrate_speech_tree(atom/new_parent, atom/new_origin, preserve_old_reference = FALSE)
	var/atom/old_parent = src.speaker_parent
	var/atom/old_origin = src.speaker_origin
	src.speaker_parent = new_parent
	src.speaker_origin = new_origin

	if (preserve_old_reference)
		src.secondary_parents += old_parent
	else
		old_parent.speech_tree = null

	if (new_parent.speech_tree != src)
		qdel(new_parent.speech_tree)

	new_parent.speech_tree = src
	src.secondary_parents -= new_parent

	if (old_origin != new_origin)
		SEND_SIGNAL(src, COMSIG_SPEAKER_ORIGIN_UPDATED, old_origin, new_origin)

/// Update this speech module tree's speaker origin. This will cause spoken messages to appear to originate fom the new speaker origin.
/datum/speech_module_tree/proc/update_speaker_origin(atom/new_origin)
	var/atom/old_origin = src.speaker_origin
	src.speaker_origin = new_origin

	SEND_SIGNAL(src, COMSIG_SPEAKER_ORIGIN_UPDATED, old_origin, new_origin)

/// Adds a new speech output module to the tree. Returns a reference to the new output module on success.
/datum/speech_module_tree/proc/_AddSpeechOutput(output_id, list/arguments = list(), count = 1)
	RETURN_TYPE(/datum/speech_module/output)

	var/module_id = "[output_id][arguments["subchannel"]]"
	src.speech_output_ids_with_subcount[module_id] += count
	if (src.speech_outputs_by_id[module_id])
		return src.speech_outputs_by_id[module_id]

	arguments["parent"] = src
	var/datum/speech_module/output/new_output = global.SpeechManager.GetOutputInstance(output_id, arguments)
	if (!istype(new_output))
		return

	src.speech_outputs_by_id[module_id] = new_output
	src.speech_outputs_by_channel[new_output.channel] ||= list()
	src.speech_outputs_by_channel[new_output.channel] += new_output
	sortList(src.speech_outputs_by_channel[new_output.channel], GLOBAL_PROC_REF(cmp_say_modules))
	return new_output

/// Removes a speech output module from the tree. Returns TRUE on success, FALSE on failure.
/datum/speech_module_tree/proc/RemoveSpeechOutput(output_id, subchannel, count = 1)
	var/module_id = "[output_id][subchannel]"
	if (!src.speech_outputs_by_id[module_id])
		return FALSE

	src.speech_output_ids_with_subcount[module_id] -= count
	if (!src.speech_output_ids_with_subcount[module_id])
		src.speech_outputs_by_channel[src.speech_outputs_by_id[module_id].channel] -= src.speech_outputs_by_id[module_id]
		qdel(src.speech_outputs_by_id[module_id])
		src.speech_outputs_by_id -= module_id

	return TRUE

/// Returns the speech output module that matches the specified ID.
/datum/speech_module_tree/proc/GetOutputByID(output_id, subchannel)
	RETURN_TYPE(/datum/speech_module/output)
	return src.speech_outputs_by_id["[output_id][subchannel]"]

/// Returns a list of speech output modules that output to the specified channel.
/datum/speech_module_tree/proc/GetOutputsByChannel(channel_id)
	RETURN_TYPE(/list/datum/speech_module/output)
	return src.speech_outputs_by_channel[channel_id]

/// Adds a new speech modifier module to the tree. Returns a reference to the new modifier module on success.
/datum/speech_module_tree/proc/_AddSpeechModifier(modifier_id, list/arguments = list(), count = 1)
	RETURN_TYPE(/datum/speech_module/modifier)

	src.speech_modifier_ids_with_subcount[modifier_id] += count
	if (src.speech_modifiers_by_id[modifier_id])
		return src.speech_modifiers_by_id[modifier_id]

	arguments["parent"] = src
	var/datum/speech_module/modifier/new_modifier = global.SpeechManager.GetSpeechModifierInstance(modifier_id, arguments)
	if (!istype(new_modifier))
		return

	src.speech_modifiers_by_id[modifier_id] = new_modifier
	sortList(src.speech_modifiers_by_id, GLOBAL_PROC_REF(cmp_say_modules), TRUE)

	if (new_modifier.override_say_channel_modifier_preference)
		src.persistent_speech_modifiers_by_id[modifier_id] = new_modifier
		sortList(src.persistent_speech_modifiers_by_id, GLOBAL_PROC_REF(cmp_say_modules), TRUE)

	return new_modifier

/// Removes a speech modifier module from the tree. Returns TRUE on success, FALSE on failure.
/datum/speech_module_tree/proc/RemoveSpeechModifier(modifier_id, count = 1)
	if (!src.speech_modifiers_by_id[modifier_id])
		return FALSE

	src.speech_modifier_ids_with_subcount[modifier_id] -= count
	if (!src.speech_modifier_ids_with_subcount[modifier_id])
		qdel(src.speech_modifiers_by_id[modifier_id])
		src.speech_modifiers_by_id -= modifier_id
		src.persistent_speech_modifiers_by_id -= modifier_id

	return TRUE

/// Returns the speech modifier module that matches the specified ID.
/datum/speech_module_tree/proc/GetModifierByID(modifier_id)
	RETURN_TYPE(/datum/speech_module/modifier)
	return src.speech_modifiers_by_id[modifier_id]

/// Adds a new speech prefix module to the tree. Returns a reference to the new prefix module on success.
/datum/speech_module_tree/proc/_AddSpeechPrefix(prefix_id, list/arguments = list(), count = 1)
	RETURN_TYPE(/datum/speech_module/prefix)

	src.speech_prefix_ids_with_subcount[prefix_id] += count
	if (src.speech_prefixes_by_id[prefix_id])
		return src.speech_prefixes_by_id[prefix_id]

	arguments["parent"] = src
	var/datum/speech_module/prefix/new_prefix = global.SpeechManager.GetSpeechPrefixInstance(prefix_id, arguments)
	if (!istype(new_prefix))
		return

	src.speech_prefixes += new_prefix
	src.speech_prefixes_by_id[prefix_id] = new_prefix
	sortList(src.speech_prefixes, GLOBAL_PROC_REF(cmp_say_modules))

	if (istype(new_prefix, /datum/speech_module/prefix/premodifier))
		src.premodifier_speech_prefixes_by_prefix_id[new_prefix.prefix_id] = new_prefix
	else
		src.postmodifier_speech_prefixes_by_prefix_id[new_prefix.prefix_id] = new_prefix

	return new_prefix

/// Removes a speech prefix module from the tree. Returns TRUE on success, FALSE on failure.
/datum/speech_module_tree/proc/RemoveSpeechPrefix(prefix_id, count = 1)
	if (!src.speech_prefixes_by_id[prefix_id])
		return FALSE

	src.speech_prefix_ids_with_subcount[prefix_id] -= count
	if (!src.speech_prefix_ids_with_subcount[prefix_id])
		var/datum/speech_module/prefix/prefix_module = src.speech_prefixes_by_id[prefix_id]
		src.speech_prefixes -= prefix_module
		src.premodifier_speech_prefixes_by_prefix_id -= prefix_module.prefix_id
		src.postmodifier_speech_prefixes_by_prefix_id -= prefix_module.prefix_id

		qdel(prefix_module)
		src.speech_prefixes_by_id -= prefix_id

	return TRUE

/// Returns the speech prefix module that matches the specified ID.
/datum/speech_module_tree/proc/GetPrefixByID(prefix_id)
	RETURN_TYPE(/datum/speech_module/prefix)
	return src.speech_prefixes_by_id[prefix_id]

/// Returns all speech prefix modules on this speech tree.
/datum/speech_module_tree/proc/GetAllPrefixes()
	RETURN_TYPE(/list/datum/speech_module/prefix)
	return src.speech_prefixes
