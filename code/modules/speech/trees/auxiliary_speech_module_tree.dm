/**
 *	Auxiliary speech module tree datums handle adding and removing their own output and modifier modules to a specified target
 *	output module tree, and transferring modules when the target changes. These are used as output module trees for datums that
 *	frequently change between atoms with their own trees, such as clients or minds.
 */
/datum/speech_module_tree/auxiliary
	var/datum/speech_module_tree/target_speech_tree

/datum/speech_module_tree/auxiliary/New(atom/parent, list/outputs = list(), list/modifiers = list(), list/prefixes = list(), datum/speech_module_tree/target_speech_tree)
	src.target_speech_tree = target_speech_tree
	. = ..()

/datum/speech_module_tree/auxiliary/disposing()
	src.update_target_speech_tree(null)
	. = ..()

/datum/speech_module_tree/auxiliary/process()
	return

/datum/speech_module_tree/auxiliary/_AddSpeechOutput(output_id, arguments, count)
	src.target_speech_tree?._AddSpeechOutput(output_id, arguments, count)
	. = ..()

/datum/speech_module_tree/auxiliary/RemoveSpeechOutput(output_id, subchannel, count)
	src.target_speech_tree?.RemoveSpeechOutput(output_id, subchannel, count)
	. = ..()

/datum/speech_module_tree/auxiliary/_AddSpeechModifier(modifier_id, arguments, count)
	src.target_speech_tree?._AddSpeechModifier(modifier_id, arguments, count)
	. = ..()

/datum/speech_module_tree/auxiliary/RemoveSpeechModifier(modifier_id, count)
	src.target_speech_tree?.RemoveSpeechModifier(modifier_id, count)
	. = ..()

/datum/speech_module_tree/auxiliary/_AddSpeechPrefix(prefix_id, arguments, count)
	src.target_speech_tree?._AddSpeechPrefix(prefix_id, arguments, count)
	. = ..()

/datum/speech_module_tree/auxiliary/RemoveSpeechPrefix(prefix_id, count)
	src.target_speech_tree?.RemoveSpeechPrefix(prefix_id, count)
	. = ..()

/datum/speech_module_tree/auxiliary/proc/update_target_speech_tree(datum/speech_module_tree/speech_tree)
	if (src.target_speech_tree)
		for (var/output_id in src.output_module_ids_with_subcount)
			src.target_speech_tree.RemoveSpeechOutput(output_id, count = src.output_module_ids_with_subcount[output_id])

		for (var/modifier_id in src.speech_modifier_ids_with_subcount)
			src.target_speech_tree.RemoveSpeechModifier(modifier_id, count = src.speech_modifier_ids_with_subcount[modifier_id])

		for (var/prefix_id in src.speech_prefix_ids_with_subcount)
			src.target_speech_tree.RemoveSpeechPrefix(prefix_id, count = src.speech_prefix_ids_with_subcount[prefix_id])

		src.target_speech_tree.auxiliary_trees -= src

	src.target_speech_tree = speech_tree
	if (!src.target_speech_tree)
		return

	for (var/output_id in src.output_module_ids_with_subcount)
		src.target_speech_tree._AddSpeechOutput(output_id, count = src.output_module_ids_with_subcount[output_id])

	for (var/modifier_id in src.speech_modifier_ids_with_subcount)
		src.target_speech_tree._AddSpeechModifier(modifier_id, count = src.speech_modifier_ids_with_subcount[modifier_id])

	for (var/prefix_id in src.speech_prefix_ids_with_subcount)
		src.target_speech_tree._AddSpeechPrefix(prefix_id, count = src.speech_prefix_ids_with_subcount[prefix_id])

	src.target_speech_tree.auxiliary_trees += src
