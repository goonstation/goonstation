/// Cache of icons for the browser output
var/global/savefile/iconCache = new /savefile("data/iconCache.sav")

/**
 * Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
 * exporting it as text, and then parsing the base64 from that.
 * (This relies on byond automatically storing icons in savefiles as base64)
 */
/proc/icon2base64(icon, iconKey = "misc")
	if (!isicon(icon)) return 0

	iconCache[iconKey] << icon
	iconCache[iconKey + "_ts"] << world.time
	var/iconData = iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return copytext(partial[2], 3, -5)

/// Gets the icon of an object to put in html
/proc/bicon(obj)

	var/baseData
	if (isicon(obj))
		baseData = icon2base64(obj)
		return "<img style='position: relative; left: -1px; bottom: -3px;' class='icon misc' src='data:image/png;base64,[baseData]' />"

	var/icon_f = null // icon [file]
	var/icon_s = null // icon_state
	if (ispath(obj))
		// avoid creating objects, just get the icon and state
		var/atom/what = obj
		icon_f = initial(what.icon)
		icon_s = initial(what.icon_state)
	else if (obj)
		// we got an object so use its icon and state
		icon_f = obj:icon
		icon_s = obj:icon_state

	if (icon_f)
		//Hash the darn dmi path and state
		var/iconKey = md5("[icon_f][icon_s]")
		var/iconData

		//See if key already exists in savefile
		var/iconTimestamp
		iconCache["[iconKey]_ts"] >> iconTimestamp
		iconData = iconCache.ExportText(iconKey)
		if (iconData && iconTimestamp && (world.time - iconTimestamp) < 1 WEEK)
			//It does! Ok, parse out the base64
			var/list/partial = splittext(iconData, "{")

			if (length(partial) < 2)
				logTheThing(LOG_DEBUG, null, "Got invalid savefile data for: [obj]")
				return

			baseData = copytext(partial[2], 3, -5)
		else
			//It doesn't exist! Create the icon
			var/icon/icon = icon(file(icon_f), icon_s, SOUTH, 1)

			if (!icon)
				logTheThing(LOG_DEBUG, null, "Unable to create output icon for: [obj]")
				return

			baseData = icon2base64(icon, iconKey)

		return "<img style='position: relative; left: -1px; bottom: -3px;' class='icon' src='data:image/png;base64,[baseData]' />"
