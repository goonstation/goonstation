/datum/speech_module_tree/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/speech_module_tree/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/speech_module_tree/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ModuleTree")
		ui.open()

/datum/speech_module_tree/ui_data(mob/user)
	var/list/module_tree_props = list()
	src.get_tree_data(module_tree_props)

	module_tree_props["module_sections"] = list()
	SPEECH_MODULE_SECTION_DATA(module_tree_props["module_sections"], src.speech_output_ids_with_subcount, src.speech_outputs_by_id, "add_output_module", "remove_output_module", "Outputs")
	SPEECH_MODULE_SECTION_DATA(module_tree_props["module_sections"], src.speech_modifier_ids_with_subcount, src.speech_modifiers_by_id, "add_modifier_module", "remove_modifier_module", "Modifiers")
	SPEECH_MODULE_SECTION_DATA(module_tree_props["module_sections"], src.speech_prefix_ids_with_subcount, src.speech_prefixes_by_id, "add_prefix_module", "remove_prefix_module", "Prefixes")

	return module_tree_props

/datum/speech_module_tree/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (. || !ui.user)
		return

	switch (action)
		if ("view_module_tree")
			var/datum/speech_module_tree/tree = locate(params["ref"])
			tree?.ui_interact(ui.user)

		if ("view_variables")
			var/datum/D = locate(params["ref"])
			if (!D)
				return

			ui.user.client.debug_variables(D)

		if ("toggle_override_channel")
			var/datum/speech_module/modifier/modifier = locate(params["ref"])
			if (!istype(modifier))
				return

			if (modifier.override_say_channel_modifier_preference)
				modifier.override_say_channel_modifier_preference = FALSE
				src.persistent_speech_modifiers_by_id -= modifier.id

			else
				modifier.override_say_channel_modifier_preference = TRUE
				src.persistent_speech_modifiers_by_id[modifier.id] = modifier
				sortList(src.persistent_speech_modifiers_by_id, GLOBAL_PROC_REF(cmp_say_modules), TRUE)

		if ("add_output_module")
			var/module_id = tgui_input_list(ui.user, "Select a speech output module ID:", "Module Selection", global.SpeechManager.speech_output_cache)
			if (!module_id)
				return

			src.AddSpeechOutput(module_id)

		if ("add_modifier_module")
			var/module_id = tgui_input_list(ui.user, "Select a speech modifier module ID:", "Module Selection", global.SpeechManager.speech_modifier_cache)
			if (!module_id)
				return

			src.AddSpeechModifier(module_id)

		if ("add_prefix_module")
			var/module_id = tgui_input_list(ui.user, "Select a speech prefix module ID:", "Module Selection", global.SpeechManager.speech_prefix_cache)
			if (!module_id)
				return

			src.AddSpeechPrefix(module_id)

		if ("remove_output_module")
			var/module_id = params["module_id"]
			if (!module_id)
				return

			src.RemoveSpeechOutput(module_id)

		if ("remove_modifier_module")
			var/module_id = params["module_id"]
			if (!module_id)
				return

			src.RemoveSpeechModifier(module_id)

		if ("remove_prefix_module")
			var/module_id = params["module_id"]
			if (!module_id)
				return

			src.RemoveSpeechPrefix(module_id)

		if ("edit_speaker_parent")
			var/atom/new_parent = locate(tgui_input_text(ui.user, "Atom reference of the new parent:", "Edit Speaker Parent"))
			if (!istype(new_parent))
				return

			var/migrate_origin = tgui_alert(usr, "Migrate the speaker origin?", "Edit Speaker Parent", list("Yes", "No", "Cancel"))
			if (migrate_origin == "Cancel")
				return

			var/atom/origin = null
			if (migrate_origin == "Yes")
				origin = new_parent
			else
				origin = src.speaker_origin

			src.migrate_speech_tree(new_parent, origin)

		if ("edit_speaker_origin")
			var/atom/new_origin = locate(tgui_input_text(ui.user, "Atom reference of the new origin:", "Edit Speaker Origin"))
			if (!istype(new_origin))
				return

			src.update_speaker_origin(new_origin)

		if ("edit_default_channel")
			var/channel_id = tgui_input_list(ui.user, "Select a say channel ID:", "Say Channel Selection", global.SpeechManager.say_channel_cache)
			if (!channel_id)
				return

			src.speaker_parent.default_speech_output_channel = channel_id

		if ("edit_say_language")
			var/language_id = tgui_input_list(ui.user, "Select a language ID:", "Language Selection", global.SpeechManager.language_cache)
			if (!language_id)
				return

			src.speaker_parent.say_language = language_id

		if ("edit_auxiliary_trees")
			var/datum/speech_module_tree/auxiliary/tree = src.edit_module_tree_list(ui.user, src.auxiliary_trees)
			if (!tree)
				return

			if (istype(tree))
				tree.update_target_speech_tree(null)

			else if (tree == "add_tree")
				tree = locate(tgui_input_text(ui.user, "Atom reference of the target tree:", "Edit Module Tree List", "\[0x21******\]", 12))
				if (!istype(tree))
					return

				tree.update_target_speech_tree(src)

/// Returns a reference to the speech module tree to remove, or the "add_tree" string.
/datum/speech_module_tree/proc/edit_module_tree_list(mob/user, list/datum/speech_module_tree/trees)
	var/list/formatted_tree_list = list("+ Add" = "add_tree")
	for (var/datum/speech_module_tree/tree as anything in trees)
		formatted_tree_list[tree.get_name()] = tree

	return formatted_tree_list[tgui_input_list(user, "Add a new tree or remove an existing one:", "Edit Module Tree List", formatted_tree_list)]

/// Returns the number of subscriptions to the module made by auxiliary trees.
/datum/speech_module_tree/proc/get_auxiliary_count(module_id, type)
	. = 0

	switch (type)
		if ("Outputs")
			for (var/datum/speech_module_tree/auxiliary/tree as anything in src.auxiliary_trees)
				. += tree.GetOutputSubcount(combined_id = module_id)
		if ("Modifiers")
			for (var/datum/speech_module_tree/auxiliary/tree as anything in src.auxiliary_trees)
				. += tree.GetModifierSubcount(module_id)
		if ("Prefixes")
			for (var/datum/speech_module_tree/auxiliary/tree as anything in src.auxiliary_trees)
				. += tree.GetPrefixSubcount(module_id)

/// Returns the name that this tree should use for links.
/datum/speech_module_tree/proc/get_name()
	return "[src.speaker_parent.name] (Tree: \ref[src])"

/// Adds the relevant module tree data to the passed module tree props lists.
/datum/speech_module_tree/proc/get_tree_data(list/module_tree_props)
	module_tree_props["title"] = "Speech Module Tree \ref[src]"
	module_tree_props["info"] = "Speech module tree datums handle applying the effects of speech prefix, modifier, and output modules to say message datums sent by the parent atom. All say message datums will be processed here prior to being passed to the appropriate say channel by a speech output module."
	module_tree_props["atom_ref"] = ref(src)

	// Speaker Parent variable.
	var/list/parent_var = list()
	parent_var["name"] = "Speaker Parent"
	parent_var["tooltip"] = "The speaker parent is the owner of this speech module tree. Their speech is handled by this tree."
	parent_var["edit_action"] = "edit_speaker_parent"
	parent_var["edit_tooltip"] = "Edit Speaker Parent"

	if (src.speaker_parent)
		parent_var["value_type"] = "reference"
		parent_var["value"] = VAR_REFERENCE_DATA(src.speaker_parent.name, "View Variables", "view_variables", list("ref" = ref(src.speaker_parent)))
	else
		parent_var["value_type"] = "value"
		parent_var["value"] = VAR_VALUE_DATA("None")

	// Speaker Origin variable.
	var/list/origin_var = new()
	origin_var["name"] = "Speaker Origin"
	origin_var["tooltip"] = "The speaker origin is the atom that should act as the origin point for sending messages from this speech module tree."
	origin_var["edit_action"] = "edit_speaker_origin"
	origin_var["edit_tooltip"] = "Edit Speaker Origin"

	if (src.speaker_origin)
		origin_var["value_type"] = "reference"
		origin_var["value"] = VAR_REFERENCE_DATA(src.speaker_origin.name, "View Variables", "view_variables", list("ref" = ref(src.speaker_origin)))
	else
		origin_var["value_type"] = "value"
		origin_var["value"] = VAR_VALUE_DATA("None")

	var/list/default_channel_var = list()
	default_channel_var["name"] = "Default Channel"
	default_channel_var["tooltip"] = "The default channel is the say channel that the speaker parent will attempt to send any unprefixed message to."
	default_channel_var["value_type"] = "reference"
	default_channel_var["value"] = VAR_REFERENCE_DATA(src.speaker_parent.default_speech_output_channel, "View Variables", "view_variables", list("ref" = ref(global.SpeechManager.GetSayChannelInstance(src.speaker_parent.default_speech_output_channel))))
	default_channel_var["edit_action"] = "edit_default_channel"
	default_channel_var["edit_tooltip"] = "Edit Default Channel"

	var/list/say_language_var = list()
	say_language_var["name"] = "Say Language"
	say_language_var["tooltip"] = "The say language is the default language for messages to be sent in."
	say_language_var["value_type"] = "reference"
	say_language_var["value"] = VAR_REFERENCE_DATA(src.speaker_parent.say_language, "View Variables", "view_variables", list("ref" = ref(global.SpeechManager.GetLanguageInstance(src.speaker_parent.say_language))))
	say_language_var["edit_action"] = "edit_say_language"
	say_language_var["edit_tooltip"] = "Edit Say Language"

	module_tree_props["variables"] = list(parent_var, origin_var, default_channel_var, say_language_var)

	// Auxiliary Trees.
	SPEECH_TREE_REFERENCE_DATA(module_tree_props["variables"], src.auxiliary_trees, "Auxiliary Trees", "edit_auxiliary_trees", "Auxiliary trees are speech module trees that only carry registered module IDs and counts; these IDs and counts are then projected onto the target speech module tree: this tree.")


/datum/speech_module_tree/auxiliary/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (. || !ui.user)
		return

	switch (action)
		if ("edit_target_tree")
			var/datum/speech_module_tree/tree = locate(tgui_input_text(ui.user, "Atom reference of the target tree:", "Edit Target Tree", "\[0x21******\]", 12))
			if (!istype(tree))
				return

			src.update_target_speech_tree(tree)

/datum/speech_module_tree/auxiliary/get_name()
	return "[src.display_name] (Tree: \ref[src])"

/datum/speech_module_tree/auxiliary/get_tree_data(list/module_tree_props)
	module_tree_props["title"] = "Auxiliary Speech Module Tree \ref[src]"
	module_tree_props["info"] = "Auxiliary speech module tree datums handle adding and removing their own modules to a specified target speech module tree, and transferring modules when the target changes. These are used as speech module trees for datums that frequently change between atoms with their own trees, such as clients or minds. They do not hold instances of modules themselves, only IDs and counts."
	module_tree_props["atom_ref"] = ref(src)

	// Target Tree variable.
	var/list/target_tree_props = list()
	target_tree_props["name"] = "Target Tree"
	target_tree_props["tooltip"] = "The target tree is the speech module tree that this tree should add and remove its modules to and from."
	target_tree_props["value_type"] = "reference"
	target_tree_props["value"] = VAR_REFERENCE_DATA(src.target_speech_tree.get_name(), "Open Module Tree Editor", "view_module_tree", list("ref" = ref(src.target_speech_tree)))
	target_tree_props["edit_action"] = "edit_target_tree"
	target_tree_props["edit_tooltip"] = "Edit Target Tree"

	module_tree_props["variables"] = list(target_tree_props)

	// Auxiliary Trees.
	SPEECH_TREE_REFERENCE_DATA(module_tree_props["variables"], src.auxiliary_trees, "Auxiliary Trees", "edit_auxiliary_trees", "Auxiliary trees are speech module trees that only carry registered module IDs and counts; these IDs and counts are then projected onto the target speech module tree: this tree.")
