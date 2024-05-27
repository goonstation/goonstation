/image/maptext/alert
	alpha = 215
	respect_maptext_preferences = FALSE


/// A constructor proc for `/image/maptext/alert`.
/proc/alert_maptext(content, alert_colour)
	var/image/maptext/text = new /image/maptext/alert
	text.maptext = "<span class='pixel c ol' style=\"color: [alert_colour]; font-size: 6px;\">[content]</span>"

	return text


/// Displays alert maptext on a specified target atom to a all clients that the target is visible to.
/proc/display_alert_maptext(atom/target, content, alert_colour)
	target.maptext_manager ||= new /atom/movable/maptext_manager(target)

	for (var/mob/M as anything in hearers(target))
		if (!M.client)
			continue

		target.maptext_manager.add_maptext(M.client, global.alert_maptext(content, alert_colour))
