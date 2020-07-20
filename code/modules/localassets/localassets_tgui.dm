
// This file is designed to hold all the tgui assets we need to possibly send to people.

/// Group for tgui assets
/datum/asset/group/base_tgui
	subassets = list(
		/datum/asset/basic/tgui,
		/datum/asset/basic/fontawesome
	)

/// Base tgui assets
/datum/asset/basic/tgui
	local_assets = list(
		"tgui/packages/tgui/public/.tmp/tgui.bundle.js",
		"tgui/packages/tgui/public/.tmp/tgui.bundle.css"
	)

	init()
		. = ..()
		url_map = list(
			"js/tgui/tgui.bundle.js" = "[grabResource("js/tgui/tgui.bundle.js")]",
			"css/tgui/tgui.bundle.css" = "[grabResource("css/tgui/tgui.bundle.css")]"
		)

/// Fontawesome assets
/datum/asset/basic/fontawesome
	cdn_only = TRUE

	url_map = list(
		"all.min.css" = "http://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.14.0/css/all.min.css"
	)
