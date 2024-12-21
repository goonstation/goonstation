/image/maptext/health
	respect_maptext_preferences = FALSE


/// Displays the health maptext of a specified scan recipient to a specified maptext recipient's client.
/proc/display_health_maptext(mob/scan_recipient, mob/maptext_recipient)
	if (!maptext_recipient.client)
		return

	var/image/maptext/health/text = new /image/maptext/health
	text.maptext = global.scan_health_generate_text(scan_recipient)

	scan_recipient.maptext_manager ||= new /atom/movable/maptext_manager(scan_recipient)
	scan_recipient.maptext_manager.add_maptext(maptext_recipient.client, text)
