/image/maptext/wraith_whisper
	alpha = 180

/image/maptext/wraith_whisper/init(content, mob/whisperer)
	src.maptext = "<span class='pixel c ol' style=\"text-shadow: 0 0 3px black; -dm-text-outline: 2px black;\">[content]</span>"
	global.oscillate_colors(src, list(dead_maptext_color(whisperer.name), "#c482d1"))
	. = ..()


/// Displays the wraith whisper maptext to a specified target.
/proc/display_wraith_whisper_maptext(mob/target, mob/whisperer, content)
	if (!target.client)
		return

	target.maptext_manager ||= new /atom/movable/maptext_manager(target)
	target.maptext_manager.add_maptext(target.client, NEW_MAPTEXT(/image/maptext/wraith_whisper, content, whisperer))
