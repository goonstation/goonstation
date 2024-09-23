/image/maptext/gang_vandalism
	alpha = 180
	respect_maptext_preferences = FALSE


/// A constructor proc for `/image/maptext/gang_vandalism`.
/proc/gang_vandalism_maptext(content)
	var/image/maptext/text = new /image/maptext/gang_vandalism
	text.maptext = "<span class='pixel c ol' style=\"color: #e60000;\">[content]</span>"

	return text


/// Displays gang vandalism maptext on a specified target to all specified recipients.
/proc/display_gang_vandalism_maptext(atom/target, list/datum/mind/recipients, content)
	target.maptext_manager ||= new /atom/movable/maptext_manager(target)

	for (var/datum/mind/mind as anything in recipients)
		if (!mind.current.client)
			continue

		target.maptext_manager.add_maptext(mind.current.client, global.gang_vandalism_maptext(content))
