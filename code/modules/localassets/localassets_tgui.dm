
// This file is designed to hold all the core tgui assets we need to possibly send to people.

/// Group for tgui assets
/datum/asset/group/base_tgui
	subassets = list(
		/datum/asset/basic/tgui,
		/datum/asset/basic/fontawesome,
		/datum/asset/basic/anton_font
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
			"tgui/tgui-panel.bundle.js"		= "[resource("tgui/tgui-panel.bundle.js")]",
			"tgui/tgui-panel.bundle.css"	= "[resource("tgui/tgui-panel.bundle.css")]"
		)

/// Fontawesome assets
/datum/asset/basic/fontawesome
	local_assets = list(
		"fa-all.min.css",
		"fa-regular-400.woff2",
		"fa-solid-900.woff2"
	)

	init()
		. = ..()
		url_map = list(
			"fa-regular-400.woff2"	= "[resource("vendor/fonts/fa-regular-400.woff2")]",
			"fa-solid-900.woff2"	= "[resource("vendor/fonts/fa-solid-900.woff2")]",
			"fa-all.min.css"		= "[resource("vendor/css/tgui/fa-all.min.css")]",
		)

/// Anton text font for paper time/name stamps
/datum/asset/basic/anton_font
	local_assets = list(
		"anton.min.css",
		"anton-regular.woff2"
	)

	init()
		. = ..()
		url_map = list(
			"anton-regular.woff2"	= "[resource("css/fonts/anton-regular.woff2")]",
			"anton.min.css"		= "[resource("vendor/css/tgui/anton.min.css")]",
		)
