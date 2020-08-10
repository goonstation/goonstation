
// This file is designed to hold all the core tgui assets we need to possibly send to people.

/// Group for tgui assets
/datum/asset/group/base_tgui
	subassets = list(
		/datum/asset/basic/tgui,
		/datum/asset/basic/fontawesome
	)

/// Common tgui assets
/datum/asset/basic/tgui_common
	local_assets = list(
		"tgui-common.chunk.js",
	)

	init()
		. = ..()
		url_map = list(
			"tgui/tgui-common.chunk.js" = "[resource("tgui/tgui-common.chunk.js")]",
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
		"all.min.css",
		"fa-regular-400.eot",
		"fa-regular-400.woff",
		"fa-solid-900.eot",
		"fa-solid-900.woff"
	)

	url_map = list(
		"all.min.css" = "http://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.14.0/css/all.min.css"
	)
