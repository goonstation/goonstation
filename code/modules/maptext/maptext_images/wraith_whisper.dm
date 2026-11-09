/image/maptext/wraith_whisper
	alpha = 180

/image/maptext/wraith_whisper/init(content, mob/whisperer)
	src.maptext = "<span class='pixel c ol' style=\"text-shadow: 0 0 3px black; -dm-text-outline: 2px black;\">[content]</span>"
	global.oscillate_colors(src, list(dead_maptext_color(whisperer.name), "#c482d1"))
	. = ..()
