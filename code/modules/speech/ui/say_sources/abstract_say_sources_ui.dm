/datum/abstract_say_sources_panel
	var/alist/radio_chat_class_lookup = null
	var/alist/radio_icon_lookup = null
	var/list/radio_chat_class_choices = null
	var/list/radio_icon_choices = null

/datum/abstract_say_sources_panel/New()
	. = ..()

	src.radio_chat_class_lookup = alist("null" = null)
	src.radio_chat_class_choices = list("null")
	for (var/chat_class as anything in RADIO.CSS._get_namespace_constants())
		var/key = "\"[chat_class]\""
		src.radio_chat_class_lookup[key] = chat_class
		src.radio_chat_class_choices += key

	src.radio_icon_lookup = alist("null" = null)
	src.radio_icon_choices = list("null")
	var/regex/filename_regex = regex(@"(?<=\/)\w*(?=\.)", "g")
	for (var/filepath as anything in global.recursive_flist("browserassets/src/images/radio_icons/", FALSE))
		filename_regex.Find(filepath)
		var/key = "\"[filename_regex.match]\""
		src.radio_icon_lookup[key] = filename_regex.match
		src.radio_icon_choices += key

/datum/abstract_say_sources_panel/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/abstract_say_sources_panel/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/abstract_say_sources_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AbstractSaySources")
		ui.open()

/datum/abstract_say_sources_panel/ui_data(mob/user)
	. = list()
	.["info"] = "Abstract say sources are a method to send say message datums over a channel without a tangible speaker atom. They exist in nullspace, and are typically used as sources for announcement messages. Note: hover over the names of variables for a brief explanation of their purpose."
	.["say_sources"] = list()

	for_by_tcl(say_source, /atom/movable/abstract_say_source)
		.["say_sources"] += list(say_source.get_ui_data(src))

/datum/abstract_say_sources_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (. || !ui.user)
		return

	switch (action)
		if ("add_say_source")
			var/atom/movable/abstract_say_source/say_source = null
			switch (global.tgui_alert(ui.user, "Radio source or ordinary source?", "Create New Say Source", list("Radio", "Ordinary")))
				if ("Radio")
					say_source = new /atom/movable/abstract_say_source/radio()
				if ("Ordinary")
					say_source = new /atom/movable/abstract_say_source()
				else
					return

			say_source.admin_created = TRUE

			if (global.tgui_alert(ui.user, "Use standard human verbs?", "Create New Say Source", list("Yes", "No")) == "Yes")
				say_source.speech_verb_say = /mob/living/carbon/human::speech_verb_say
				say_source.speech_verb_ask = /mob/living/carbon/human::speech_verb_ask
				say_source.speech_verb_exclaim = /mob/living/carbon/human::speech_verb_exclaim
				say_source.speech_verb_stammer = /mob/living/carbon/human::speech_verb_stammer
				say_source.speech_verb_gasp = /mob/living/carbon/human::speech_verb_gasp

		if ("remove_say_source")
			var/atom/movable/abstract_say_source/say_source = locate(params["ref"])
			if (!istype(say_source) || !say_source.admin_created)
				return

			qdel(say_source)

		if ("rename_say_source")
			var/atom/movable/abstract_say_source/say_source = locate(params["ref"])
			if (!istype(say_source) || !say_source.admin_created)
				return

			var/new_name = global.tgui_input_text(ui.user, "Edit internal name:", "Edit Internal Name", say_source.internal_name)
			if (isnull(new_name))
				return

			say_source.internal_name = new_name

		if ("view_module_tree")
			var/datum/speech_module_tree/tree = locate(params["ref"])
			if (istype(tree))
				tree.ui_interact(ui.user)

		if ("view_variables")
			var/datum/D = locate(params["ref"])
			if (istype(D))
				ui.user.client.debug_variables(D)

		if ("force_say")
			var/atom/movable/abstract_say_source/say_source = locate(params["ref"])
			if (istype(say_source))
				ui.user.client.cmd_say(say_source)

		if ("edit_name")
			var/atom/movable/abstract_say_source/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/new_name = global.tgui_input_text(ui.user, "New name:", "New Name")
			if (isnull(new_name))
				return

			say_source.name = new_name

		if ("edit_verb")
			var/atom/movable/abstract_say_source/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/verb_var_name = params["variable"]
			var/i = params["index"]
			if (!verb_var_name || !i)
				return

			var/verb_var = say_source.vars[verb_var_name]
			var/new_verb = global.tgui_input_text(ui.user, "Edit verb:", "Edit Verb", verb_var)
			if (isnull(new_verb))
				return

			if (!new_verb && (global.tgui_alert(ui.user, "Empty string or null?", "Edit Verb", list("\"\"", "null")) == "null"))
				new_verb = null

			// If the verb variable isn't a list, write to it directly.
			if (!islist(verb_var))
				say_source.vars[verb_var_name] = new_verb
			// If the new verb isn't null, write to the list.
			else if (!isnull(new_verb))
				say_source.vars[verb_var_name][i] = new_verb
			// If the list is greater than one element, remove the element to be nulled.
			else if (length(verb_var) > 1)
				say_source.vars[verb_var_name]:Cut(i, i + 1)
			// Otherwise null the single-element list.
			else
				say_source.vars[verb_var_name] = null

		if ("edit_verbs_as_list")
			var/atom/movable/abstract_say_source/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/verb_var_name = params["variable"]
			if (!verb_var_name)
				return

			var/verb_var = say_source.vars[verb_var_name]

			var/list/formatted_verb_list = list("+ Add" = -1)
			var/list/verbs_list = verb_var ? list() + verb_var : list()
			for (var/i in 1 to length(verbs_list))
				formatted_verb_list["\"[verbs_list[i]]\""] = i

			var/i = formatted_verb_list[global.tgui_input_list(ui.user, "Add a new verb or remove an existing one:", "Edit Verb List", formatted_verb_list, capitalize = FALSE)]
			if (!i)
				return

			if (i == -1)
				var/new_verb = global.tgui_input_text(ui.user, "New verb:", "New Verb")
				if (isnull(new_verb))
					return

				if (!new_verb && (global.tgui_alert(ui.user, "Empty string or null?", "New Verb", list("\"\"", "null")) == "null"))
					new_verb = null

				// If the verb variable is null, write to it directly.
				if (isnull(verb_var))
					say_source.vars[verb_var_name] = new_verb
				// If the verb variable is a string, turn it into a list.
				else if (istext(verb_var))
					say_source.vars[verb_var_name] = list(verb_var, new_verb)
				// If the verb variable is a list, add an element to it.
				else if (islist(verb_var))
					say_source.vars[verb_var_name] += new_verb

			else
				if (islist(verb_var) && (length(verb_var) > 1))
					say_source.vars[verb_var_name]:Cut(i, i + 1)
				else
					say_source.vars[verb_var_name] = null

		if ("edit_radio_prefix")
			var/atom/movable/abstract_say_source/radio/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/new_prefix = global.tgui_input_text(ui.user, "Edit radio prefix:", "Edit Radio Prefix", say_source.radio_prefix)
			if (isnull(new_prefix))
				return

			say_source.radio_prefix = new_prefix

		if ("edit_radio")
			var/atom/movable/abstract_say_source/radio/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/new_radio_type = global.get_one_match(global.tgui_input_text(usr, "Radio type:", "Radio Type"), /obj/item/device/radio)
			if (!ispath(new_radio_type, /obj/item/device/radio))
				return

			say_source.radio_type = new_radio_type
			say_source.create_radio()
			say_source.default_frequency = say_source.radio.frequency
			say_source.radio_chat_class = say_source.radio.chat_class
			say_source.radio_icon = say_source.radio.icon_override
			say_source.radio_icon_tooltip = say_source.radio.icon_tooltip

		if ("edit_radio_default_frequency")
			var/atom/movable/abstract_say_source/radio/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/new_frequency = global.tgui_input_number(ui.user, "Edit radio frequency:", "Edit Radio Frequency", say_source.default_frequency, max_value = 9999)
			if (isnull(new_frequency))
				return

			say_source.default_frequency = new_frequency
			say_source.radio.set_frequency(say_source.default_frequency)

		if ("edit_radio_chat_class")
			var/atom/movable/abstract_say_source/radio/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/new_class = params["value"]
			if (isnull(new_class))
				return

			new_class = src.radio_chat_class_lookup[new_class]
			say_source.radio_chat_class = new_class
			say_source.radio.chat_class = say_source.radio_chat_class

		if ("edit_radio_icon")
			var/atom/movable/abstract_say_source/radio/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/new_icon = params["value"]
			if (isnull(new_icon))
				return

			new_icon = src.radio_icon_lookup[new_icon]
			say_source.radio_icon = new_icon
			say_source.radio.icon_override = say_source.radio_icon

		if ("edit_radio_icon_tooltip")
			var/atom/movable/abstract_say_source/radio/say_source = locate(params["ref"])
			if (!istype(say_source))
				return

			var/new_tooltip = global.tgui_input_text(ui.user, "Edit radio icon:", "Edit Radio Icon", say_source.radio_icon_tooltip)
			if (isnull(new_tooltip))
				return

			if (!new_tooltip && (global.tgui_alert(ui.user, "Empty string or null?", "Edit Radio Icon", list("\"\"", "null")) == "null"))
				new_tooltip = null

			say_source.radio_icon_tooltip = new_tooltip
			say_source.radio.icon_tooltip = say_source.radio_icon_tooltip
