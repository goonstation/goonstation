/image/maptext/message

/image/maptext/message/init(datum/say_message/message)
	var/maptext_css = ""
	for (var/key in message.maptext_css_values)
		maptext_css += "[key]: [message.maptext_css_values[key]]; "

	src.maptext = "<span class='pixel c ol' style=\"[maptext_css]\">[message.maptext_prefix][message.format_content_style_prefix][message.content][message.format_content_style_suffix][message.maptext_suffix]</span>"

	for (var/variable_name in message.maptext_variables)
		if (!issaved(src.vars[variable_name]))
			continue

		src.vars[variable_name] = message.maptext_variables[variable_name]

	var/animation_colours = length(message.maptext_animation_colours)
	if (animation_colours)
		for (var/i in 1 to animation_colours)
			if (message.maptext_animation_colours[i] != "start_colour")
				continue

			message.maptext_animation_colours[i] = message.maptext_css_values["color"]

		global.oscillate_colors(src, message.maptext_animation_colours)

	. = ..()
