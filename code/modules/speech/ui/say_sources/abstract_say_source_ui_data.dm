/// Returns a list of props for the different variables that this say source should display in the abstract say sources UI.
/atom/movable/abstract_say_source/proc/get_ui_data(datum/abstract_say_sources_panel/panel)
	src.ensure_speech_tree()

	var/list/name_var = list()
	name_var["name"] = "Name"
	name_var["tooltip"] = "The display name of this say source."
	name_var["value_type"] = "value"
	name_var["value"] = VAR_VALUE_DATA(src.name)
	name_var["edit_action"] = list("edit_name", list("ref" = ref(src)))
	name_var["edit_tooltip"] = "Edit Name"

	var/list/speech_tree_var = list()
	speech_tree_var["name"] = "Speech Tree"
	speech_tree_var["tooltip"] = "This say source's speech module tree. If you want to edit speech variables, edit this."
	speech_tree_var["value_type"] = "reference"
	speech_tree_var["value"] = VAR_REFERENCE_DATA(src.speech_tree.get_name(), "Open Module Tree Editor", "view_module_tree", list("ref" = ref(src.speech_tree)))

	var/list/say_verb_var = list()
	say_verb_var["name"] = "Say Verb"
	say_verb_var["tooltip"] = "The default say verb for standard spoken phrases. Also acts as a fallback verb if contextual verbs are `null`."
	say_verb_var["value_type"] = "reference_list"
	say_verb_var["value"] = VAR_REFERENCE_LIST_DATA(src.format_verb_var("speech_verb_say"))
	say_verb_var["edit_action"] = list("edit_verbs_as_list", list("ref" = ref(src), "variable" = "speech_verb_say"))
	say_verb_var["edit_tooltip"] = "Edit Say Verbs As List"

	var/list/ask_verb_var = list()
	ask_verb_var["name"] = "Ask Verb"
	ask_verb_var["tooltip"] = "The default say verb for spoken phrases ending in a question mark."
	ask_verb_var["value_type"] = "reference_list"
	ask_verb_var["value"] = VAR_REFERENCE_LIST_DATA(src.format_verb_var("speech_verb_ask"))
	ask_verb_var["edit_action"] = list("edit_verbs_as_list", list("ref" = ref(src), "variable" = "speech_verb_ask"))
	ask_verb_var["edit_tooltip"] = "Edit Ask Verbs As List"

	var/list/exclaim_verb_var = list()
	exclaim_verb_var["name"] = "Exclaim Verb"
	exclaim_verb_var["tooltip"] = "The default say verb for spoken phrases ending in an exclaimation mark."
	exclaim_verb_var["value_type"] = "reference_list"
	exclaim_verb_var["value"] = VAR_REFERENCE_LIST_DATA(src.format_verb_var("speech_verb_exclaim"))
	exclaim_verb_var["edit_action"] = list("edit_verbs_as_list", list("ref" = ref(src), "variable" = "speech_verb_exclaim"))
	exclaim_verb_var["edit_tooltip"] = "Edit Exclaim Verbs As List"

	var/list/stammer_verb_var = list()
	stammer_verb_var["name"] = "Stammer Verb"
	stammer_verb_var["tooltip"] = "The default say verb for stammered phrases."
	stammer_verb_var["value_type"] = "reference_list"
	stammer_verb_var["value"] = VAR_REFERENCE_LIST_DATA(src.format_verb_var("speech_verb_stammer"))
	stammer_verb_var["edit_action"] = list("edit_verbs_as_list", list("ref" = ref(src), "variable" = "speech_verb_stammer"))
	stammer_verb_var["edit_tooltip"] = "Edit Stammer Verbs As List"

	var/list/gasp_verb_var = list()
	gasp_verb_var["name"] = "Gasp Verb"
	gasp_verb_var["tooltip"] = "The default say verb for gasped phrases."
	gasp_verb_var["value_type"] = "reference_list"
	gasp_verb_var["value"] = VAR_REFERENCE_LIST_DATA(src.format_verb_var("speech_verb_gasp"))
	gasp_verb_var["edit_action"] = list("edit_verbs_as_list", list("ref" = ref(src), "variable" = "speech_verb_gasp"))
	gasp_verb_var["edit_tooltip"] = "Edit Gasp Verbs As List"

	. = list()
	.["internal_name"] = src.internal_name
	.["admin_created"] = src.admin_created
	.["atom_ref"] = ref(src)
	.["atom_variables"] = list(name_var, speech_tree_var)
	.["verb_variables"] = list(say_verb_var, ask_verb_var, exclaim_verb_var, stammer_verb_var, gasp_verb_var)

/atom/movable/abstract_say_source/proc/format_verb_var(verb_var_name)
	var/verb_var = src.vars[verb_var_name]
	var/list/verb_list = list()
	if (isnull(verb_var))
		verb_list += "null"
	else if (istext(verb_var))
		verb_list += "\"[verb_var]\""
	else if (islist(verb_var))
		for (var/speech_verb as anything in verb_var)
			verb_list += "\"[speech_verb]\""

	. = list()
	for (var/i in 1 to length(verb_list))
		. += list(VAR_REFERENCE_DATA(verb_list[i], "Edit Verb", "edit_verb", list("ref" = ref(src), "variable" = verb_var_name, "index" = i)))


#define FORMAT(X) (isnull(X) ? "null" : "\"[X]\"")

/atom/movable/abstract_say_source/radio/get_ui_data(datum/abstract_say_sources_panel/panel)
	. = ..()

	var/list/prefix_var = list()
	prefix_var["name"] = "Radio Prefix"
	prefix_var["tooltip"] = "This is the speech prefix automatically appended to every message spoken by this say source."
	prefix_var["value_type"] = "value"
	prefix_var["value"] = VAR_VALUE_DATA(src.radio_prefix)
	prefix_var["edit_action"] = list("edit_radio_prefix", list("ref" = ref(src)))
	prefix_var["edit_tooltip"] = "Edit Radio Prefix"

	var/list/radio_var = list()
	radio_var["name"] = "Radio"
	radio_var["tooltip"] = "The radio that this abstract say source should direct messages to."
	radio_var["value_type"] = "reference"
	radio_var["value"] = VAR_REFERENCE_DATA(src.radio.name, "View Radio Variables", "view_variables", list("ref" = ref(src.radio)))
	radio_var["edit_action"] = list("edit_radio", list("ref" = ref(src)))
	radio_var["edit_tooltip"] = "Edit Radio"

	var/list/frequency_var = list()
	frequency_var["name"] = "Frequency"
	frequency_var["tooltip"] = "The frequency of the primary channel of the radio."
	frequency_var["value_type"] = "value"
	frequency_var["value"] = VAR_VALUE_DATA(src.default_frequency)
	frequency_var["edit_action"] = list("edit_radio_default_frequency", list("ref" = ref(src)))
	frequency_var["edit_tooltip"] = "Edit Radio Default Frequency"

	var/list/chat_class_var = list()
	chat_class_var["name"] = "Chat Class"
	chat_class_var["tooltip"] = "The CSS class that should be used for messages sent over the primary channel of the radio."
	chat_class_var["value_type"] = "dropdown"
	chat_class_var["value"] = VAR_DROPDOWN(TRUE, FORMAT(src.radio_chat_class), panel.radio_chat_class_choices, "edit_radio_chat_class", list("ref" = ref(src)))

	var/list/icon_var = list()
	icon_var["name"] = "Radio Icon"
	icon_var["tooltip"] = "If set, this is radio icon that the radio should display on sent messages."
	icon_var["value_type"] = "dropdown"
	icon_var["value"] = VAR_DROPDOWN(TRUE, FORMAT(src.radio_icon), panel.radio_icon_choices, "edit_radio_icon", list("ref" = ref(src)))

	var/list/icon_tooltip_var = list()
	icon_tooltip_var["name"] = "Icon Tooltip"
	icon_tooltip_var["tooltip"] = "If set, the tooltip that the radio icon of the radio should use. `null` will result in the radio name being used. \"\" will result in no tooltip."
	icon_tooltip_var["value_type"] = "value"
	icon_tooltip_var["value"] = VAR_VALUE_DATA(FORMAT(src.radio_icon_tooltip))
	icon_tooltip_var["edit_action"] = list("edit_radio_icon_tooltip", list("ref" = ref(src)))
	icon_tooltip_var["edit_tooltip"] = "Edit Radio Icon Tooltip"

	.["atom_variables"] += list(prefix_var, radio_var, frequency_var, chat_class_var, icon_var, icon_tooltip_var)

#undef FORMAT
