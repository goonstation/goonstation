/image/maptext/sap_power
	alpha = 180
	respect_maptext_preferences = FALSE


/// A constructor proc for `/image/maptext/sap_power`.
/proc/sap_power_maptext(content)
	var/image/maptext/text = new /image/maptext/sap_power
	text.maptext = "<span class='c ps2p sh' style=\"color: #e6e600;\">[content]</span>"

	return text


/// Displays power sapping maptext on a specified target to the sapper.
/proc/display_sap_power_maptext(atom/target, mob/recipient, content)
	target.maptext_manager ||= new /atom/movable/maptext_manager(target)

	if (!recipient.client)
		return

	target.maptext_manager.add_maptext(recipient.client, global.sap_power_maptext(content))
