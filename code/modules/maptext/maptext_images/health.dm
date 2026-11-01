/image/maptext/health
	respect_maptext_preferences = FALSE

/image/maptext/health/init(mob/scan_recipient)
	src.maptext = global.scan_health_generate_text(scan_recipient)
	. = ..()
