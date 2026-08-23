/image/maptext/appraisal
	alpha = 180
	respect_maptext_preferences = FALSE
	// Many of the artefacts are upside down and stuff, it makes text a bit hard to read!
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA | PIXEL_SCALE

/image/maptext/appraisal/init(sell_value)
	if (sell_value <= 0)
		src.maptext = "<span class='pixel c ol' style=\"color: #bbbbbb;\">No value</span>"
	else
		src.maptext = "<span class='pixel c ol'>[round(sell_value)][CREDIT_SIGN]</span>"

	. = ..()
