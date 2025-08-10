/datum/listen_module_tree/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/listen_module_tree/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/listen_module_tree/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SpeechModuleTree")
		ui.open()

/datum/listen_module_tree/ui_data(mob/user)
	var/list/module_tree_props = list()
	src.get_tree_data(module_tree_props)

	module_tree_props["module_sections"] = list()
	LISTEN_MODULE_SECTION_DATA(module_tree_props["module_sections"], src.listen_input_ids_with_subcount, src.listen_inputs_by_id, "add_input_module", "remove_input_module", "Inputs")
	LISTEN_MODULE_SECTION_DATA(module_tree_props["module_sections"], src.listen_modifier_ids_with_subcount, src.listen_modifiers_by_id, "add_modifier_module", "remove_modifier_module", "Modifiers")
	LISTEN_MODULE_SECTION_DATA(module_tree_props["module_sections"], src.listen_effect_ids_with_subcount, src.listen_effects_by_id, "add_effect_module", "remove_effect_module", "Effects")
	LISTEN_MODULE_SECTION_DATA(module_tree_props["module_sections"], src.listen_control_ids_with_subcount, src.listen_controls_by_id, "add_control_module", "remove_control_module", "Controls")
	LISTEN_MODULE_SECTION_DATA(module_tree_props["module_sections"], src.known_language_ids_with_subcount, src.known_languages_by_id, "add_known_language", "remove_known_language", "Languages")

	return module_tree_props

/datum/listen_module_tree/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (. || !ui.user)
		return

	switch (action)
		if ("view_module_tree")
			var/datum/listen_module_tree/tree = locate(params["ref"])
			tree?.ui_interact(ui.user)

		if ("view_variables")
			var/datum/D = locate(params["ref"])
			if (!D)
				return

			ui.user.client.debug_variables(D)

		if ("toggle_module_enabled")
			var/datum/listen_module/input/input = locate(params["ref"])
			if (!istype(input))
				return

			if (input.enabled)
				input.disable()
			else
				input.enable()

		if ("toggle_override_channel")
			var/datum/listen_module/modifier/modifier = locate(params["ref"])
			if (!istype(modifier))
				return

			if (modifier.override_say_channel_modifier_preference)
				modifier.override_say_channel_modifier_preference = FALSE
				src.persistent_listen_modifiers_by_id -= modifier.id

			else
				modifier.override_say_channel_modifier_preference = TRUE
				src.persistent_listen_modifiers_by_id[modifier.id] = modifier
				sortList(src.persistent_listen_modifiers_by_id, GLOBAL_PROC_REF(cmp_say_modules), TRUE)

		if ("add_input_module")
			var/module_id = tgui_input_list(ui.user, "Select a listen input module ID:", "Module Selection", global.SpeechManager.listen_input_cache)
			if (!module_id)
				return

			src.AddListenInput(module_id)

		if ("add_modifier_module")
			var/module_id = tgui_input_list(ui.user, "Select a listen modifier module ID:", "Module Selection", global.SpeechManager.listen_modifier_cache)
			if (!module_id)
				return

			src.AddListenModifier(module_id)

		if ("add_effect_module")
			var/module_id = tgui_input_list(ui.user, "Select a listen effect module ID:", "Module Selection", global.SpeechManager.listen_effect_cache)
			if (!module_id)
				return

			src.AddListenEffect(module_id)

		if ("add_control_module")
			var/module_id = tgui_input_list(ui.user, "Select a listen control module ID:", "Module Selection", global.SpeechManager.listen_control_cache)
			if (!module_id)
				return

			src.AddListenControl(module_id)

		if ("add_known_language")
			var/module_id = tgui_input_list(ui.user, "Select a listen control module ID:", "Module Selection", global.SpeechManager.language_cache)
			if (!module_id)
				return

			src.AddKnownLanguage(module_id)

		if ("remove_input_module")
			var/module_id = params["module_id"]
			if (!module_id)
				return

			src.RemoveListenInput(module_id)

		if ("remove_modifier_module")
			var/module_id = params["module_id"]
			if (!module_id)
				return

			src.RemoveListenModifier(module_id)

		if ("remove_effect_module")
			var/module_id = params["module_id"]
			if (!module_id)
				return

			src.RemoveListenEffect(module_id)

		if ("remove_control_module")
			var/module_id = params["module_id"]
			if (!module_id)
				return

			src.RemoveListenControl(module_id)

		if ("remove_known_language")
			var/module_id = params["module_id"]
			if (!module_id)
				return

			src.RemoveKnownLanguage(module_id)

		if ("edit_listener_parent")
			var/atom/new_parent = locate(tgui_input_text(ui.user, "Atom reference of the new parent:", "Edit Listener Parent"))
			if (!istype(new_parent))
				return

			var/migrate_origin = tgui_alert(usr, "Migrate the listener origin?", "Edit Listener Parent", list("Yes", "No", "Cancel"))
			if (migrate_origin == "Cancel")
				return

			var/atom/origin = null
			if (migrate_origin == "Yes")
				origin = new_parent
			else
				origin = src.listener_origin

			src.migrate_listen_tree(new_parent, origin)

		if ("edit_listener_origin")
			var/atom/new_origin = locate(tgui_input_text(ui.user, "Atom reference of the new origin:", "Edit Listener Origin"))
			if (!istype(new_origin))
				return

			src.update_listener_origin(new_origin)

		if ("edit_auxiliary_trees")
			var/datum/listen_module_tree/auxiliary/tree = src.edit_module_tree_list(ui.user, src.auxiliary_trees)
			if (!tree)
				return

			if (istype(tree))
				tree.update_target_listen_tree(null)

			else if (tree == "add_tree")
				tree = locate(tgui_input_text(ui.user, "Atom reference of the target tree:", "Edit Module Tree List", "\[0x21******\]", 12))
				if (!istype(tree))
					return

				tree.update_target_listen_tree(src)

		if ("edit_importing_trees")
			var/datum/listen_module_tree/tree = src.edit_module_tree_list(ui.user, src.message_importing_trees)
			if (!tree)
				return

			if (istype(tree))
				src.remove_message_importing_tree(tree)

			else if (tree == "add_tree")
				tree = locate(tgui_input_text(ui.user, "Atom reference of the target tree:", "Edit Module Tree List", "\[0x21******\]", 12))
				if (!istype(tree))
					return

				src.add_message_importing_tree(tree)

		if ("edit_exporting_trees")
			var/datum/listen_module_tree/tree = src.edit_module_tree_list(ui.user, src.message_exporting_trees)
			if (!tree)
				return

			if (istype(tree))
				tree.remove_message_importing_tree(src)

			else if (tree == "add_tree")
				tree = locate(tgui_input_text(ui.user, "Atom reference of the target tree:", "Edit Module Tree List", "\[0x21******\]", 12))
				if (!istype(tree))
					return

				tree.add_message_importing_tree(src)

/// Returns a reference to the listen module tree to remove, or the "add_tree" string.
/datum/listen_module_tree/proc/edit_module_tree_list(mob/user, list/datum/listen_module_tree/trees)
	var/list/formatted_tree_list = list("+ Add" = "add_tree")
	for (var/datum/listen_module_tree/tree as anything in trees)
		formatted_tree_list[tree.get_name()] = tree

	return formatted_tree_list[tgui_input_list(user, "Add a new tree or remove an existing one:", "Edit Module Tree List", formatted_tree_list)]

/// Returns the number of subscriptions to the module made by auxiliary trees.
/datum/listen_module_tree/proc/get_auxiliary_count(module_id, type)
	. = 0

	switch (type)
		if ("Inputs")
			for (var/datum/listen_module_tree/auxiliary/tree as anything in src.auxiliary_trees)
				. += tree.GetInputSubcount(combined_id = module_id)
		if ("Modifiers")
			for (var/datum/listen_module_tree/auxiliary/tree as anything in src.auxiliary_trees)
				. += tree.GetModifierSubcount(module_id)
		if ("Effects")
			for (var/datum/listen_module_tree/auxiliary/tree as anything in src.auxiliary_trees)
				. += tree.GetEffectSubcount(module_id)
		if ("Controls")
			for (var/datum/listen_module_tree/auxiliary/tree as anything in src.auxiliary_trees)
				. += tree.GetControlSubcount(module_id)
		if ("Languages")
			for (var/datum/listen_module_tree/auxiliary/tree as anything in src.auxiliary_trees)
				. += tree.GetKnownLanguageSubcount(module_id)

/// Returns the name that this tree should use for links.
/datum/listen_module_tree/proc/get_name()
	return "[src.listener_parent.name] (Tree: \ref[src])"

/// Adds the relevant module tree data to the passed module tree props lists.
/datum/listen_module_tree/proc/get_tree_data(list/module_tree_props)
	module_tree_props["title"] = "Listen Module Tree \ref[src]"
	module_tree_props["info"] = "Listen module tree datums handle applying the effects of languages and listen modifier modules to say message datums received by any listen input modules registered to itself. Processed messages are then stored in the message buffer before being sent to listen effect modules."
	module_tree_props["atom_ref"] = ref(src)

	// Enable Requests variable.
	var/list/requests_var = list()
	requests_var["name"] = "Enable Requests"
	requests_var["tooltip"] = "Enable requests are the number of concurrent requests for this listen module tree to be enabled."
	requests_var["value_type"] = "value"
	requests_var["value"] = VAR_VALUE_DATA(src.enable_requests)

	// Listener Parent variable.
	var/list/parent_var = list()
	parent_var["name"] = "Listener Parent"
	parent_var["tooltip"] = "The listener parent is the atom that should receive messages sent to this listen module tree."
	parent_var["edit_action"] = "edit_listener_parent"
	parent_var["edit_tooltip"] = "Edit Listener Parent"

	if (src.listener_parent)
		parent_var["value_type"] = "reference"
		parent_var["value"] = VAR_REFERENCE_DATA(src.listener_parent.name, "View Variables", "view_variables", list("ref" = ref(src.listener_parent)))
	else
		parent_var["value_type"] = "value"
		parent_var["value"] = VAR_VALUE_DATA("None")

	// Listener Origin variable.
	var/list/origin_var = new()
	origin_var["name"] = "Listener Origin"
	origin_var["tooltip"] = "The listener origin is the atom that should act as the origin point for listening to messages."
	origin_var["edit_action"] = "edit_listener_origin"
	origin_var["edit_tooltip"] = "Edit Listener Origin"

	if (src.listener_origin)
		origin_var["value_type"] = "reference"
		origin_var["value"] = VAR_REFERENCE_DATA(src.listener_origin.name, "View Variables", "view_variables", list("ref" = ref(src.listener_origin)))
	else
		origin_var["value_type"] = "value"
		origin_var["value"] = VAR_VALUE_DATA("None")

	module_tree_props["variables"] = list(requests_var, parent_var, origin_var)

	// Auxiliary, Importing, and Exporting Trees.
	LISTEN_TREE_REFERENCE_DATA(module_tree_props["variables"], src.auxiliary_trees, "Auxiliary Trees", "edit_auxiliary_trees", "Auxiliary trees are listen module trees that only carry registered module IDs and counts; these IDs and counts are then projected onto the target listen module tree: this tree.")
	LISTEN_TREE_REFERENCE_DATA(module_tree_props["variables"], src.message_importing_trees, "Importing Trees", "edit_importing_trees", "Importing trees are listen module trees that copy messages received by this tree directly into their own message buffer.")
	LISTEN_TREE_REFERENCE_DATA(module_tree_props["variables"], src.message_exporting_trees, "Exporting Trees", "edit_exporting_trees", "Exporting trees are listen module trees that copy their received messages directly into this tree's message buffer.")


/datum/listen_module_tree/auxiliary/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (. || !ui.user)
		return

	switch (action)
		if ("edit_target_tree")
			var/datum/listen_module_tree/tree = locate(tgui_input_text(ui.user, "Atom reference of the target tree:", "Edit Target Tree", "\[0x21******\]", 12))
			if (!istype(tree))
				return

			src.update_target_listen_tree(tree)

/datum/listen_module_tree/auxiliary/get_name()
	return "[src.display_name] (Tree: \ref[src])"

/datum/listen_module_tree/auxiliary/get_tree_data(list/module_tree_props)
	module_tree_props["title"] = "Auxiliary Listen Module Tree \ref[src]"
	module_tree_props["info"] = "Auxiliary listen module tree datums handle adding and removing their own modules to a specified target listen module tree, and transferring modules when the target changes. These are used as listen module trees for datums that frequently change between atoms with their own trees, such as clients or minds. They do not hold instances of modules themselves, only IDs and counts."
	module_tree_props["atom_ref"] = ref(src)

	// Target Tree variable.
	var/list/target_tree_props = list()
	target_tree_props["name"] = "Target Tree"
	target_tree_props["tooltip"] = "The target tree is the listen module tree that this tree should add and remove its modules to and from."
	target_tree_props["value_type"] = "reference"
	target_tree_props["value"] = VAR_REFERENCE_DATA(src.target_listen_tree.get_name(), "Open Module Tree Editor", "view_module_tree", list("ref" = ref(src.target_listen_tree)))
	target_tree_props["edit_action"] = "edit_target_tree"
	target_tree_props["edit_tooltip"] = "Edit Target Tree"

	module_tree_props["variables"] = list(target_tree_props)

	// Auxiliary Trees.
	LISTEN_TREE_REFERENCE_DATA(module_tree_props["variables"], src.auxiliary_trees, "Auxiliary Trees", "edit_auxiliary_trees", "Auxiliary trees are listen module trees that only carry registered module IDs and counts; these IDs and counts are then projected onto the target listen module tree: this tree.")
