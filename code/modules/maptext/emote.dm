/image/maptext/emote
	alpha = 140


/// A constructor proc for `/image/maptext/emote`.
/proc/emote_maptext(content)
	var/image/maptext/text = new /image/maptext/emote
	text.maptext = "<span class='pixel c ol' style=\"color: #C2BEBE;\">[content]</span>"

	return text


/// Displays emote maptext on a specified target atom to a specified list of clients.
/proc/display_emote_maptext(atom/target, list/client/clients, content)
	target.maptext_manager ||= new /atom/movable/maptext_manager(target)

	for (var/client/client as anything in clients)
		target.maptext_manager.add_maptext(client, global.emote_maptext(content))
