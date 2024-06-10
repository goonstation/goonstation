
// Contains asset-sending code that I can't rip from TG but I can write my own shitty implementation
//             (dear god please make this better (delivery caching/noop, css spritesheets anyone??))
//
// Should not be used when cdn is enabled.

// Basic caching of asset datums, let's not create a bunch of these.
var/global/list/global_asset_datum_list = list()

/// Base asset type
ABSTRACT_TYPE(/datum/asset)
/datum/asset

/datum/asset/proc/init()

/datum/asset/proc/deliver(client)

/datum/asset/proc/get_associated_urls()
	return list()

/datum/asset/New()
	..()
	global_asset_datum_list[src.type] = src
	init()

/// Basic assets
ABSTRACT_TYPE(/datum/asset/basic)
/datum/asset/basic
	/// List of entries with form "filename" (gets shit into cache)
	var/local_assets = list()
	/// List of entries with form "browserasset-path" = "url"
	var/url_map = list()

	deliver(client)
		. = send_assets(client, local_assets)

	get_associated_urls()
		. = url_map

/// For grouping multiple assets together
ABSTRACT_TYPE(/datum/asset/group)
/datum/asset/group
	var/list/subassets = list()

	init()
		for (var/asset in subassets)
			get_assets(asset)

	deliver(client)
		for (var/asset in subassets)
			var/datum/asset/ass = get_assets(asset)
			. = ass.deliver(client) || .

	get_associated_urls()
		. = list()
		for(var/asset in subassets)
			var/datum/asset/A = get_assets(type)
			. += A.get_associated_urls()

/// Returns either the already-created asset or creates a new one and returns it
/proc/get_assets(asset)
	. = global_asset_datum_list[asset] || new asset()

/// Sends the list of asset files to client if they're needed
/proc/send_assets(client/C, list/assetlist)
	if (cdn)
		message_coders("ZeWaka/Assets: I made a huge fuckup somewhere and assets are being sent with cdn enabled!!")
		return
	C.loadResourcesFromList(assetlist)
