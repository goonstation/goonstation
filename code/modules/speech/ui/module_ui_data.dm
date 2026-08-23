/// Returns a list of props for the different variables that this module should display in the module tree UI.
/datum/speech_module/proc/get_ui_variables()
	return list()


/datum/speech_module/output/get_ui_variables()
	. = ..()

	var/list/priority_var = list()
	priority_var["name"] = "Priority"
	priority_var["tooltip"] = "If multiple outputs with the same channel exist, messages are sent to the module with the highest priority."
	priority_var["value_type"] = "value"
	priority_var["value"] = VAR_VALUE_DATA(src.priority)
	. += list(priority_var)

	var/list/channel_var = list()
	channel_var["name"] = "Channel"
	channel_var["tooltip"] = "The say channel that this module should pass say messages to."
	channel_var["value_type"] = "reference"
	channel_var["value"] = VAR_REFERENCE_DATA(src.say_channel.channel_id, "View Variables", "view_variables", list("ref" = ref(src.say_channel)))
	. += list(channel_var)


/datum/speech_module/modifier/get_ui_variables()
	. = ..()

	var/list/priority_var = list()
	priority_var["name"] = "Priority"
	priority_var["tooltip"] = "Higher priority modifier modules are applied to the message first."
	priority_var["value_type"] = "value"
	priority_var["value"] = VAR_VALUE_DATA(src.priority)
	. += list(priority_var)

	var/list/override_var = list()
	override_var["name"] = "Override Channel"
	override_var["tooltip"] = "Whether this modifier module should respect the say channel's affected_by_modifiers variable."
	override_var["value_type"] = "toggleable"
	override_var["value"] = VAR_TOGGLEABLE_DATA(src.override_say_channel_modifier_preference, "toggle_override_channel", list("ref" = ref(src)))
	. += list(override_var)


/datum/speech_module/prefix/get_ui_variables()
	. = ..()

	var/list/prefix_id_var = list()
	prefix_id_var["name"] = "Prefix"
	prefix_id_var["tooltip"] = "The message prefix that enabled this module's behaviour."
	prefix_id_var["value_type"] = "value"
	prefix_id_var["value"] = VAR_VALUE_DATA(src.prefix_id)
	. += list(prefix_id_var)


/// Returns a list of props for the different variables that this module should display in the module tree UI.
/datum/listen_module/proc/get_ui_variables()
	return list()


/datum/listen_module/input/get_ui_variables()
	. = ..()

	var/list/priority_var = list()
	priority_var["name"] = "Priority"
	priority_var["tooltip"] = "If multiple messages are received with the same message ID, the message received from the input module with the highest priority is heard."
	priority_var["value_type"] = "value"
	priority_var["value"] = VAR_VALUE_DATA(src.priority)
	. += list(priority_var)

	var/list/enabled_var = list()
	enabled_var["name"] = "Enabled"
	enabled_var["tooltip"] = "Whether this listen module may receive messages."
	enabled_var["value_type"] = "toggleable"
	enabled_var["value"] = VAR_TOGGLEABLE_DATA(src.enabled, "toggle_module_enabled", list("ref" = ref(src)))
	. += list(enabled_var)

	var/list/channel_var = list()
	channel_var["name"] = "Channel"
	channel_var["tooltip"] = "The say channel that this module is currently listening on."
	channel_var["value_type"] = "reference"
	channel_var["value"] = VAR_REFERENCE_DATA(src.say_channel.channel_id, "View Variables", "view_variables", list("ref" = ref(src.say_channel)))
	. += list(channel_var)


/datum/listen_module/modifier/get_ui_variables()
	. = ..()

	var/list/priority_var = list()
	priority_var["name"] = "Priority"
	priority_var["tooltip"] = "Higher priority modifier modules are applied to the message first."
	priority_var["value_type"] = "value"
	priority_var["value"] = VAR_VALUE_DATA(src.priority)
	. += list(priority_var)

	var/list/override_var = list()
	override_var["name"] = "Override Channel"
	override_var["tooltip"] = "Whether this modifier module should respect the say channel's affected_by_modifiers variable."
	override_var["value_type"] = "toggleable"
	override_var["value"] = VAR_TOGGLEABLE_DATA(src.override_say_channel_modifier_preference, "toggle_override_channel", list("ref" = ref(src)))
	. += list(override_var)
