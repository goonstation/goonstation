/image/maptext/wraith_whisper
	alpha = 180

/// A constructor proc for `/image/maptext/wraith_whisper`.
/proc/wraith_maptext(content, mob/whisperer)
	var/image/maptext/text = new /image/maptext/alert
	text.maptext = "<span style='text-shadow: 0 0 3px black; -dm-text-outline: 2px black;'>[content]</span>"
	oscillate_colors(text, list(dead_maptext_color(whisperer.name), "#c482d1"))
	return text

/// Displays the wraith whisper maptext to a specified client
/proc/wraith_whisper_maptext(message, mob/maptext_recipient, mob/whisperer)
	if (!maptext_recipient.client)
		return

	var/image/maptext/wraith_whisper/text = new /image/maptext/wraith_whisper
	text.maptext = global.wraith_maptext(message, whisperer)

	maptext_recipient.maptext_manager ||= new /atom/movable/maptext_manager(maptext_recipient)
	maptext_recipient.maptext_manager.add_maptext(maptext_recipient.client, text)
