/image/maptext/pda
	layer = HUD_LAYER_OVER
// TODO: Alert version?

/image/maptext/pda/init(text_message)
	src.maptext = "<span class='pixel c ol'>[text_message]</span>"

	. = ..()
