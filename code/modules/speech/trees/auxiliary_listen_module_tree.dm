/**
 *	Auxiliary listen module tree datums handle adding and removing their own input and modifier modules to a specified target
 *	listen module tree, and transferring modules when the target changes. These are used as input module trees for datums that
 *	frequently change between atoms with their own trees, such as clients or minds.
 */
/datum/listen_module_tree/auxiliary
	var/datum/listen_module_tree/target_listen_tree

/datum/listen_module_tree/auxiliary/New(atom/parent, list/inputs = list(), list/modifiers = list(), list/languages = list(), datum/listen_module_tree/target_listen_tree)
	src.target_listen_tree = target_listen_tree
	. = ..()

/datum/listen_module_tree/auxiliary/disposing()
	src.update_target_listen_tree(null)
	. = ..()

/datum/listen_module_tree/auxiliary/process()
	return

/datum/listen_module_tree/auxiliary/flush_message_buffer()
	return

/datum/listen_module_tree/auxiliary/_AddListenInput(input_id, list/arguments = list(), count = 1)
	var/module_id = "[input_id][arguments["subchannel"]]"
	src.input_module_ids_with_subcount[module_id] += count
	src.target_listen_tree?._AddListenInput(input_id, arguments, count)
	return TRUE

/datum/listen_module_tree/auxiliary/RemoveListenInput(input_id, subchannel, count = 1)
	var/module_id = "[input_id][subchannel]"

	if (!src.input_module_ids_with_subcount[module_id])
		return FALSE

	src.input_module_ids_with_subcount[module_id] -= count
	src.target_listen_tree?.RemoveListenInput(input_id, subchannel, count)
	return TRUE

/datum/listen_module_tree/auxiliary/GetInputByID(input_id, subchannel)
	CRASH("Tried to call `GetInputByID()` on an auxiliary listen tree. You can't do that!")

/datum/listen_module_tree/auxiliary/GetInputsByChannel(channel_id)
	CRASH("Tried to call `GetInputsByChannel()` on an auxiliary listen tree. You can't do that!")

/datum/listen_module_tree/auxiliary/_AddListenModifier(modifier_id, list/arguments = list(), count = 1)
	src.listen_modifier_ids_with_subcount[modifier_id] += count
	src.target_listen_tree?._AddListenModifier(modifier_id, arguments, count)
	return TRUE

/datum/listen_module_tree/auxiliary/RemoveListenModifier(modifier_id, count = 1)
	if (!src.listen_modifier_ids_with_subcount[modifier_id])
		return FALSE

	src.listen_modifier_ids_with_subcount[modifier_id] -= count
	src.target_listen_tree?.RemoveListenModifier(modifier_id, count)
	return TRUE

/datum/listen_module_tree/auxiliary/GetModifierByID(modifier_id)
	CRASH("Tried to call `GetModifierByID()` on an auxiliary listen tree. You can't do that!")

/datum/listen_module_tree/auxiliary/AddKnownLanguage(language_id, count = 1)
	. = ..()
	if (!.)
		return

	src.target_listen_tree?.AddKnownLanguage(language_id, count)

/datum/listen_module_tree/auxiliary/RemoveKnownLanguage(language_id, count = 1)
	. = ..()
	if (!.)
		return

	src.target_listen_tree?.RemoveKnownLanguage(language_id, count)

/datum/listen_module_tree/auxiliary/proc/update_target_listen_tree(datum/listen_module_tree/listen_tree)
	if (src.target_listen_tree)
		for (var/input_id in src.input_module_ids_with_subcount)
			src.target_listen_tree.RemoveListenInput(input_id, count = src.input_module_ids_with_subcount[input_id])

		for (var/modifier_id in src.listen_modifier_ids_with_subcount)
			src.target_listen_tree.RemoveListenModifier(modifier_id, count = src.listen_modifier_ids_with_subcount[modifier_id])

		for (var/language_id in src.known_languages_by_id)
			src.target_listen_tree.RemoveKnownLanguage(language_id, count = src.known_language_ids_with_subcount[language_id])

		if (src.understands_all_languages)
			src.target_listen_tree.RemoveKnownLanguage(LANGUAGE_ALL)

		src.target_listen_tree.auxiliary_trees -= src

	src.target_listen_tree = listen_tree
	if (!src.target_listen_tree)
		return

	for (var/input_id in src.input_module_ids_with_subcount)
		src.target_listen_tree._AddListenInput(input_id, count = src.input_module_ids_with_subcount[input_id])

	for (var/modifier_id in src.listen_modifier_ids_with_subcount)
		src.target_listen_tree._AddListenModifier(modifier_id, count = src.listen_modifier_ids_with_subcount[modifier_id])

	for (var/language_id in src.known_languages_by_id)
		src.target_listen_tree.AddKnownLanguage(language_id, count = src.known_language_ids_with_subcount[language_id])

	if (src.understands_all_languages)
		src.target_listen_tree.AddKnownLanguage(LANGUAGE_ALL)

	src.target_listen_tree.auxiliary_trees += src
