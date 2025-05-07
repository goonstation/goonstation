/**
 *	Auxiliary speech module tree datums handle adding and removing their own modules to a specified target speech module
 *	tree, and transferring modules when the target changes. These are used as speech module trees for datums that
 *	frequently change between atoms with their own trees, such as clients or minds.
 */
/datum/speech_module_tree/auxiliary
	/// The name that this auxiliary speech module tree should display on the admin UI.
	var/display_name = "Aux"
	/// The speech module tree that this auxiliary speech module tree should add and remove its modules to and from.
	var/datum/speech_module_tree/target_speech_tree

/datum/speech_module_tree/auxiliary/New(atom/parent, list/outputs = list(), list/modifiers = list(), list/prefixes = list(), datum/speech_module_tree/target_speech_tree, display_name)
	src.display_name = display_name

	. = ..()
	src.update_target_speech_tree(target_speech_tree)

/datum/speech_module_tree/auxiliary/disposing()
	src.update_target_speech_tree(null)
	. = ..()

/datum/speech_module_tree/auxiliary/process()
	return

/datum/speech_module_tree/auxiliary/_AddSpeechOutput(output_id, list/arguments = list(), count = 1)
	var/module_id = "[output_id][arguments["subchannel"]]"
	src.speech_output_ids_with_subcount[module_id] += count
	src.target_speech_tree?._AddSpeechOutput(output_id, arguments, count)
	return TRUE

/datum/speech_module_tree/auxiliary/RemoveSpeechOutput(output_id, subchannel, count = 1)
	var/module_id = "[output_id][subchannel]"

	if (!src.speech_output_ids_with_subcount[module_id])
		return FALSE

	src.speech_output_ids_with_subcount[module_id] -= count
	if (!src.speech_output_ids_with_subcount[module_id])
		src.speech_output_ids_with_subcount -= module_id

	src.target_speech_tree?.RemoveSpeechOutput(output_id, subchannel, count)
	return TRUE

/datum/speech_module_tree/auxiliary/GetOutputByID(output_id, subchannel)
	CRASH("Tried to call `GetOutputByID()` on an auxiliary speech tree. You can't do that!")

/datum/speech_module_tree/auxiliary/GetOutputsByChannel(channel_id)
	CRASH("Tried to call `GetOutputsByChannel()` on an auxiliary speech tree. You can't do that!")

/datum/speech_module_tree/auxiliary/_AddSpeechModifier(modifier_id, list/arguments = list(), count = 1)
	src.speech_modifier_ids_with_subcount[modifier_id] += count
	src.target_speech_tree?._AddSpeechModifier(modifier_id, arguments, count)
	return TRUE

/datum/speech_module_tree/auxiliary/RemoveSpeechModifier(modifier_id, count = 1)
	if (!src.speech_modifier_ids_with_subcount[modifier_id])
		return FALSE

	src.speech_modifier_ids_with_subcount[modifier_id] -= count
	if (!src.speech_modifier_ids_with_subcount[modifier_id])
		src.speech_modifier_ids_with_subcount -= modifier_id

	src.target_speech_tree?.RemoveSpeechModifier(modifier_id, count)
	return TRUE

/datum/speech_module_tree/auxiliary/GetModifierByID(modifier_id)
	CRASH("Tried to call `GetModifierByID()` on an auxiliary speech tree. You can't do that!")

/datum/speech_module_tree/auxiliary/_AddSpeechPrefix(prefix_id, list/arguments = list(), count = 1)
	src.speech_prefix_ids_with_subcount[prefix_id] += count
	src.target_speech_tree?._AddSpeechPrefix(prefix_id, arguments, count)
	return TRUE

/datum/speech_module_tree/auxiliary/RemoveSpeechPrefix(prefix_id, count = 1)
	if (!src.speech_prefix_ids_with_subcount[prefix_id])
		return FALSE

	src.speech_prefix_ids_with_subcount[prefix_id] -= count
	if (!src.speech_prefix_ids_with_subcount[prefix_id])
		src.speech_prefix_ids_with_subcount -= prefix_id

	src.target_speech_tree?.RemoveSpeechPrefix(prefix_id, count)
	return TRUE

/datum/speech_module_tree/auxiliary/GetPrefixByID(prefix_id)
	CRASH("Tried to call `GetPrefixByID()` on an auxiliary speech tree. You can't do that!")

/datum/speech_module_tree/auxiliary/GetAllPrefixes()
	CRASH("Tried to call `GetAllPrefixes()` on an auxiliary speech tree. You can't do that!")

/datum/speech_module_tree/auxiliary/proc/update_target_speech_tree(datum/speech_module_tree/speech_tree)
	if (src.target_speech_tree)
		for (var/output_id in src.speech_output_ids_with_subcount)
			src.target_speech_tree.RemoveSpeechOutput(output_id, count = src.speech_output_ids_with_subcount[output_id])

		for (var/modifier_id in src.speech_modifier_ids_with_subcount)
			src.target_speech_tree.RemoveSpeechModifier(modifier_id, count = src.speech_modifier_ids_with_subcount[modifier_id])

		for (var/prefix_id in src.speech_prefix_ids_with_subcount)
			src.target_speech_tree.RemoveSpeechPrefix(prefix_id, count = src.speech_prefix_ids_with_subcount[prefix_id])

		src.target_speech_tree.auxiliary_trees -= src

	src.target_speech_tree = speech_tree
	if (!src.target_speech_tree)
		return

	for (var/output_id in src.speech_output_ids_with_subcount)
		src.target_speech_tree._AddSpeechOutput(output_id, count = src.speech_output_ids_with_subcount[output_id])

	for (var/modifier_id in src.speech_modifier_ids_with_subcount)
		src.target_speech_tree._AddSpeechModifier(modifier_id, count = src.speech_modifier_ids_with_subcount[modifier_id])

	for (var/prefix_id in src.speech_prefix_ids_with_subcount)
		src.target_speech_tree._AddSpeechPrefix(prefix_id, count = src.speech_prefix_ids_with_subcount[prefix_id])

	src.target_speech_tree.auxiliary_trees += src
