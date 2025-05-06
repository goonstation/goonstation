#define VAR_VALUE_DATA(VALUE) list("value" = VALUE)
#define VAR_TOGGLEABLE_DATA(VALUE, ACTION, ARGUMENTS) list("value" = VALUE, "action" = ACTION, "arguments" = ARGUMENTS)
#define VAR_REFERENCE_DATA(TITLE, TOOLTIP, ACTION, ARGUMENTS) list("title" = TITLE, "tooltip" = TOOLTIP, "action" = ACTION, "arguments" = ARGUMENTS)

#define SPEECH_TREE_REFERENCE_DATA(WRITE_TO, READ_FROM, NAME, EDIT_ACTION, TOOLTIP) TREE_REFERENCE_DATA(/datum/speech_module_tree, WRITE_TO, READ_FROM, NAME, EDIT_ACTION, TOOLTIP)
#define LISTEN_TREE_REFERENCE_DATA(WRITE_TO, READ_FROM, NAME, EDIT_ACTION, TOOLTIP) TREE_REFERENCE_DATA(/datum/listen_module_tree, WRITE_TO, READ_FROM, NAME, EDIT_ACTION, TOOLTIP)

#define SPEECH_MODULE_SECTION_DATA(WRITE_TO, READ_FROM, MODULES, ADD_ACTION, REMOVE_ACTION, TITLE) MODULE_SECTION_DATA(/datum/speech_module, WRITE_TO, READ_FROM, MODULES, ADD_ACTION, REMOVE_ACTION, TITLE)
#define LISTEN_MODULE_SECTION_DATA(WRITE_TO, READ_FROM, MODULES, ADD_ACTION, REMOVE_ACTION, TITLE) MODULE_SECTION_DATA(/datum/listen_module, WRITE_TO, READ_FROM, MODULES, ADD_ACTION, REMOVE_ACTION, TITLE)

#define TREE_REFERENCE_DATA(TYPE, WRITE_TO, READ_FROM, NAME, EDIT_ACTION, TOOLTIP) \
	if (WRITE_TO) { \
		var/list/_TREES = list(); \
		_TREES["variable_list"] = list(); \
		for (var##TYPE/_TREE as anything in READ_FROM) { \
			_TREES["variable_list"] += list(VAR_REFERENCE_DATA(_TREE.get_name(), "Open Module Tree Editor", "view_module_tree", list("ref" = ref(_TREE)))); \
		} \
		var/list/_TREE_PROPS = list(); \
		_TREE_PROPS["name"] = NAME; \
		_TREE_PROPS["tooltip"] = TOOLTIP; \
		_TREE_PROPS["value_type"] = "reference_list"; \
		_TREE_PROPS["value"] = _TREES; \
		_TREE_PROPS["edit_action"] = EDIT_ACTION; \
		_TREE_PROPS["edit_tooltip"] = "Edit As List"; \
		WRITE_TO += list(_TREE_PROPS); \
	}

#define MODULE_SECTION_DATA(TYPE, WRITE_TO, READ_FROM, MODULES, ADD_ACTION, REMOVE_ACTION, TITLE) \
	if (WRITE_TO) { \
		var/list/_SECTION_PROPS = list(); \
		_SECTION_PROPS["title"] = TITLE; \
		_SECTION_PROPS["add_action"] = ADD_ACTION; \
		_SECTION_PROPS["modules"] = list(); \
		\
		for (var/_ID as anything in READ_FROM) { \
			var/list/_MODULE_PROPS = list(); \
			_MODULE_PROPS["id"] = _ID; \
			_MODULE_PROPS["auxiliary"] = (READ_FROM[_ID] == src.get_auxiliary_count(_ID, TITLE)); \
			_MODULE_PROPS["remove_action"] = REMOVE_ACTION; \
			\
			var/list/_COUNT = list(); \
			_COUNT["name"] = "Count"; \
			_COUNT["tooltip"] = "The count is the number of times that this module ID has been registered to this tree."; \
			_COUNT["value_type"] = "value"; \
			_COUNT["value"] = VAR_VALUE_DATA(READ_FROM[_ID]); \
			_MODULE_PROPS["module_variables"] = list(_COUNT); \
			\
			var##TYPE/_MODULE = MODULES[_ID]; \
			if (_MODULE) { \
				_MODULE_PROPS["atom_ref"] = ref(_MODULE); \
				if (istype(_MODULE)) { \
					_MODULE_PROPS["module_variables"] += _MODULE.get_ui_variables(); \
				} \
			} \
			_SECTION_PROPS["modules"] += list(_MODULE_PROPS); \
		} \
		WRITE_TO += list(_SECTION_PROPS); \
	}
