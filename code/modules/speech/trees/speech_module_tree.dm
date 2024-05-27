/**
 *	Speech module tree datums handle applying the effects of accent, modifier, and output speech modules to say message
 *	datums sent by the parent atom. All say message datums will be processed here prior to being passed to the speech
 *	manager to be disseminated to input listen modules.
 */
/datum/speech_module_tree
	var/list/output_module_ids_with_subcount
	var/list/datum/speech_module/output/output_modules_by_id
	var/list/speech_modifier_ids_with_subcount
	var/list/datum/speech_module/modifier/speech_modifiers_by_id
	var/atom/parent

/datum/speech_module_tree/New(atom/parent, list/modifiers = list(), list/outputs = list())
	. = ..()

	src.parent = parent

	src.output_module_ids_with_subcount = list()
	src.output_modules_by_id = list()
	for (var/output_id in outputs)
		src.AddOutput(output_id)

	src.speech_modifier_ids_with_subcount = list()
	src.speech_modifiers_by_id = list()
	for (var/modifier_id in modifiers)
		src.AddModifier(modifier_id)

/datum/speech_module_tree/disposing()
	for (var/output_id in src.output_modules_by_id)
		qdel(src.output_modules_by_id[output_id])

	for (var/modifier_id in src.speech_modifiers_by_id)
		qdel(src.speech_modifiers_by_id[modifier_id])

	src.output_modules_by_id = null
	src.speech_modifiers_by_id = null
	src.parent = null

	. = ..()

/// Process the message, applying the effects of each accent, speech, and output module.
/datum/speech_module_tree/proc/process(datum/say_message/message)
	if (!istype(message))
		CRASH("A non say_message thing was passed to a speech_module_tree. This should never happen.")

	var/list/datum/speech_module/output/output_modules = src.GetOutputByChannel(message.output_module_channel)
	if (!length(output_modules))
		return

	// If the say channel permits, apply modifier module message manipulation.
	if (global.SpeechManager.GetSayChannelInstance(message.output_module_channel).affected_by_modifiers)
		for (var/modifier_id in src.speech_modifiers_by_id)
			message = src.speech_modifiers_by_id[modifier_id].process(message)
			// If the module consumed the message, no need to process any further.
			if (QDELETED(message))
				return

	// Apply sayflag message manipulation.
	global.SpeechManager.ApplyMessageModifierPreprocessing(message)
	message.output_module_channel = null

	// Disseminate to output modules.
	var/suppress_say_sound = TRUE
	var/suppress_speech_bubble = TRUE
	for (var/datum/speech_module/output/output_module as anything in output_modules)
		if (!output_module.process(message.Copy()))
			continue

		suppress_say_sound &&= output_module.say_channel.suppress_say_sound
		suppress_speech_bubble &&= output_module.say_channel.suppress_speech_bubble

	// Handle say sounds and speech bubbles.
	if (!suppress_say_sound)
		message.process_say_sound()
	if (!suppress_speech_bubble)
		message.process_speech_bubble()

/// Adds a new output module to the tree. Returns a reference to the new output module on success.
/datum/speech_module_tree/proc/AddOutput(output_id, count = 1)
	RETURN_TYPE(/datum/speech_module/output)

	src.output_module_ids_with_subcount[output_id] += count
	if (src.output_modules_by_id[output_id])
		return src.output_modules_by_id[output_id]

	var/datum/speech_module/output/new_output = global.SpeechManager.GetOutputInstance(output_id, src)
	if (!istype(new_output))
		return

	src.output_modules_by_id[output_id] = new_output
	return new_output

/// Removes an output module from the tree. Returns TRUE on success, FALSE on failure.
/datum/speech_module_tree/proc/RemoveOutput(output_id, count = 1)
	if (!src.output_modules_by_id[output_id])
		return FALSE

	src.output_module_ids_with_subcount[output_id] -= count
	if (!src.output_module_ids_with_subcount[output_id])
		qdel(src.output_modules_by_id[output_id])
		src.output_modules_by_id -= output_id

	return TRUE

/// Returns the output module that matches the specified ID.
/datum/speech_module_tree/proc/GetOutputByID(output_id)
	RETURN_TYPE(/datum/speech_module/output)
	return src.output_modules_by_id[output_id]

/// Returns a list of output modules that output to the specified channel.
/datum/speech_module_tree/proc/GetOutputByChannel(channel_id)
	RETURN_TYPE(/list/datum/speech_module/output)
	. = list()

	for (var/output_id as anything in src.output_modules_by_id)
		if (src.output_modules_by_id[output_id].channel == channel_id)
			. += src.output_modules_by_id[output_id]

/// Adds a new modifier module to the tree. Returns a reference to the new modifier module on success.
/datum/speech_module_tree/proc/AddModifier(modifier_id, count = 1)
	RETURN_TYPE(/datum/speech_module/modifier)

	src.speech_modifier_ids_with_subcount[modifier_id] += count
	if (src.speech_modifiers_by_id[modifier_id])
		return src.speech_modifiers_by_id[modifier_id]

	var/datum/speech_module/modifier/new_modifier = global.SpeechManager.GetSpeechModifierInstance(modifier_id)
	if (!istype(new_modifier))
		return

	src.speech_modifiers_by_id[modifier_id] = new_modifier
	sortList(src.speech_modifiers_by_id, GLOBAL_PROC_REF(cmp_say_modules), TRUE)
	return new_modifier

/// Removes a modifier from the tree. Returns TRUE on success, FALSE on failure.
/datum/speech_module_tree/proc/RemoveModifier(modifier_id, count = 1)
	if (!src.speech_modifiers_by_id[modifier_id])
		return FALSE

	src.speech_modifier_ids_with_subcount[modifier_id] -= count
	if (!src.speech_modifier_ids_with_subcount[modifier_id])
		qdel(src.speech_modifiers_by_id[modifier_id])
		src.speech_modifiers_by_id -= modifier_id

	return TRUE

/// Returns the speech modifier module that matches the specified ID.
/datum/speech_module_tree/proc/GetModifierByID(modifier_id)
	RETURN_TYPE(/datum/speech_module/modifier)
	return src.speech_modifiers_by_id[modifier_id]
