/**
 *	Maptext images are special subtypes of images without an icon with the sole purpose of displaying maptext to a single client.
 *	As a result of being an image, each subtype requires a special constructor proc in lieu of `New()`; this is a result of BYOND
 *	treating an argument passed to an image's `New()` as an argument for `image()`. This has been clarified by Lummox as intended
 *	behaviour.
 */
/image/maptext
	icon = null
	appearance_flags = PIXEL_SCALE
	plane = PLANE_HUD
	layer = HUD_LAYER_UNDER_1
	alpha = 255
	maptext_x = -64
	maptext_y = 34
	maptext_width = 160
	maptext_height = 48
	/// Whether this maptext image should respect the client's flying chat preferences.
	var/respect_maptext_preferences = TRUE


/// A constructor proc for `/image/maptext`.
/proc/message_maptext(datum/say_message/message)
	var/maptext_css = ""
	for (var/key in message.maptext_css_values)
		maptext_css += "[key]: [message.maptext_css_values[key]]; "

	var/image/maptext/text = new /image/maptext
	text.maptext = "<span class='pixel c ol' style=\"[maptext_css]\">[message.maptext_prefix][message.format_content_style_prefix][message.content][message.format_content_style_suffix][message.maptext_suffix]</span>"

	for (var/variable_name in message.maptext_variables)
		if (!issaved(text.vars[variable_name]))
			continue

		text.vars[variable_name] = message.maptext_variables[variable_name]

	var/animation_colours = length(message.maptext_animation_colours)
	if (animation_colours)
		for (var/i in 1 to animation_colours)
			if (message.maptext_animation_colours[i] != "start_colour")
				continue

			message.maptext_animation_colours[i] = message.maptext_css_values["color"]

		global.oscillate_colors(text, message.maptext_animation_colours)

	return text
