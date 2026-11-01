/image/maptext/curse_denied
	alpha = 180

/image/maptext/curse_denied/init(content)
	src.maptext = "<span class='pixel c ol' style=\"color: black; text-shadow: 0 0 3px white; -dm-text-outline: 2px white;\">[content]</span>"
	. = ..()
