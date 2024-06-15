/**
 *	Auxiliary speech module tree datums handle adding and removing their own output and modifier modules to a specified target
 *	output module tree, and transferring modules when the target changes. These are used as output module trees for datums that
 *	frequently change between atoms with their own trees, such as clients or minds.
 */
/datum/speech_module_tree/auxiliary
	var/datum/speech_module_tree/target_speech_tree

/datum/speech_module_tree/auxiliary/New(atom/parent, list/modifiers = list(), list/outputs = list(), datum/speech_module_tree/target_speech_tree)
	src.target_speech_tree = target_speech_tree
	. = ..()

/datum/speech_module_tree/auxiliary/disposing()
	src.update_target_speech_tree(null)
	src.target_speech_tree = null
	. = ..()

/datum/speech_module_tree/auxiliary/process()
	return

/datum/speech_module_tree/auxiliary/AddOutput(output_id)
	src.target_speech_tree?.AddOutput(output_id)
	. = ..()

/datum/speech_module_tree/auxiliary/RemoveOutput(output_id)
	src.target_speech_tree?.RemoveOutput(output_id)
	. = ..()

/datum/speech_module_tree/auxiliary/AddModifier(modifier_id)
	src.target_speech_tree?.AddModifier(modifier_id)
	. = ..()

/datum/speech_module_tree/auxiliary/RemoveModifier(modifier_id)
	src.target_speech_tree?.RemoveModifier(modifier_id)
	. = ..()

/datum/speech_module_tree/auxiliary/proc/update_target_speech_tree(datum/speech_module_tree/speech_tree)
	if (src.target_speech_tree)
		for (var/output_id in src.output_module_ids_with_subcount)
			src.target_speech_tree.RemoveOutput(output_id, src.output_module_ids_with_subcount[output_id])

		for (var/modifier_id in src.speech_modifier_ids_with_subcount)
			src.target_speech_tree.RemoveModifier(modifier_id, src.speech_modifier_ids_with_subcount[modifier_id])

	src.target_speech_tree = speech_tree
	if (!src.target_speech_tree)
		return

	for (var/output_id in src.output_module_ids_with_subcount)
		src.target_speech_tree.AddOutput(output_id, src.output_module_ids_with_subcount[output_id])

	for (var/modifier_id in src.speech_modifier_ids_with_subcount)
		src.target_speech_tree.AddModifier(modifier_id, src.speech_modifier_ids_with_subcount[modifier_id])
