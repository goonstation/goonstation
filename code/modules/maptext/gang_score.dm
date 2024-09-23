/image/maptext/gang_score
	alpha = 180
	respect_maptext_preferences = FALSE


/// A constructor proc for `/image/maptext/gang_score`.
/proc/gang_score_maptext(amount)
	var/image/maptext/text = new /image/maptext/gang_score
	text.maptext = "<span class='pixel c ol' style=\"color: #08be4e;\">+[amount]</span>"

	return text


/// Displays gang score maptext on a specified target to all specified recipients.
/proc/display_gang_score_maptext(atom/target, list/datum/mind/recipients, amount)
	target.maptext_manager ||= new /atom/movable/maptext_manager(target)

	for (var/datum/mind/mind as anything in recipients)
		if (!mind.current.client)
			continue

		target.maptext_manager.add_maptext(mind.current.client, global.gang_score_maptext(amount))
