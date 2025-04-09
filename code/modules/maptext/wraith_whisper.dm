/image/maptext/wraith_whisper
	alpha = 180


/// A constructor proc for `/image/maptext/wraith_whisper`.
/proc/wraith_whisper_maptext(content, mob/whisperer)
	var/image/maptext/text = new /image/maptext/wraith_whisper
	text.maptext = "<span class='pixel c ol' style=\"text-shadow: 0 0 3px black; -dm-text-outline: 2px black;\">[content]</span>"
	global.oscillate_colors(text, list(dead_maptext_color(whisperer.name), "#c482d1"))

	return text


/// Displays the wraith whisper maptext to a specified target.
/proc/display_wraith_whisper_maptext(mob/target, mob/whisperer, content)
	if (!target.client)
		return

	target.maptext_manager ||= new /atom/movable/maptext_manager(target)
	target.maptext_manager.add_maptext(target.client, global.wraith_whisper_maptext(content, whisperer))
