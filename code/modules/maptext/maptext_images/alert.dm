/image/maptext/alert
	alpha = 215
	respect_maptext_preferences = FALSE

/image/maptext/alert/init(content, alert_colour)
	src.maptext = "<span class='pixel c ol' style=\"color: [alert_colour]; font-size: 6px;\">[content]</span>"
	. = ..()
