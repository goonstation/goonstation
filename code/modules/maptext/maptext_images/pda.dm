/image/maptext/pda
	layer = HUD_LAYER_OVER

/image/maptext/pda/init(text_message, dest)
	src.maptext = "<span class='pixel c ol' style='color:#C2BEBE'>([dest]) [text_message]</span>"
	src.alpha = 200

	. = ..()
