
// This file is designed to hold all the core tgui assets we need to possibly send to people.

/// Group for tgui assets
/datum/asset/group/base_tgui
	subassets = list(
		/datum/asset/basic/tgui,
		/datum/asset/basic/fontawesome
	)

/// Normal base window tgui assets
/datum/asset/basic/tgui
	local_assets = list(
		"tgui.bundle.js",
		"tgui.bundle.css"
	)

	init()
		. = ..()
		url_map = list(
			"tgui/tgui.bundle.js" = "[resource("tgui/tgui.bundle.js")]",
			"tgui/tgui.bundle.css" = "[resource("tgui/tgui.bundle.css")]"
		)

/// tgui panel specific assets
/datum/asset/basic/tgui_panel
	local_assets = list(
		"tgui-panel.bundle.js",
		"tgui-panel.bundle.css"
	)

	init()
		. = ..()
		url_map = list(
			"tgui/tgui-panel.bundle.js" = "[resource("tgui/tgui-panel.bundle.js")]",
			"tgui/tgui-panel.bundle.css" = "[resource("tgui/tgui-panel.bundle.css")]"
		)

/// Fontawesome assets
/datum/asset/basic/fontawesome
	local_assets = list(
		"fa-all.min.css",
		"fa-regular-400.eot",
		"fa-regular-400.ttf",
		"fa-solid-900.eot",
		"fa-solid-900.ttf"
	)

	init()
		. = ..()
		url_map = list(
			"fa-regular-400.eot"	= "[resource("css/fonts/fa-regular-400.eot")]",
			"fa-regular-400.ttf"	= "[resource("css/fonts/fa-regular-400.ttf")]",
			"fa-solid-900.eot"		= "[resource("css/fonts/fa-solid-900.eot")]",
			"fa-solid-900.ttf"		= "[resource("css/fonts/fa-solid-900.ttf")]",
			"fa-all.min.css"		= "[resource("css/tgui/fa-all.min.css")]",
		)
