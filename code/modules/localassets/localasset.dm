
// Contains asset-sending code that I can't rip from TG but I can write my own shitty implementation
//             (dear god please make this better (delivery caching/noop, css spritesheets anyone??))
//
// Static local assets are sent only when the CDN is disabled.
// Generated JSON assets use local delivery even when static assets use the CDN.

// Basic caching of asset datums, let's not create a bunch of these.
var/global/list/global_asset_datum_list = list()

/// Base asset type
ABSTRACT_TYPE(/datum/asset)
/datum/asset
	/// Initialize during TGUI setup.
	var/early = FALSE

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
	/// Resource filenames for local delivery.
	var/local_assets = list()
	/// Browser asset path -> URL.
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
			var/datum/asset/A = get_assets(asset)
			. += A.get_associated_urls()

/// Generated JSON delivered locally
ABSTRACT_TYPE(/datum/asset/json)
/datum/asset/json
	/// Filename without the .json suffix.
	var/name
	var/json_resource

	init()
		. = ..()
		if (!src.name)
			CRASH("Missing name for JSON asset [src.type]")
		var/cache_path = "data/[src.name].json"
		var/write_error = rustg_file_write(json_encode(src.generate()), cache_path)
		if (write_error)
			fdel(cache_path)
			CRASH("Unable to write JSON asset [src.type]: [write_error]")
		src.json_resource = fcopy_rsc(cache_path)
		fdel(cache_path)
		if (!src.json_resource)
			CRASH("Unable to cache JSON asset [src.type]")

	deliver(client/C)
		C << browse_rsc(src.json_resource, "[src.name].json")
		return TRUE

	get_associated_urls()
		return list("[src.name].json" = "[src.name].json")

	/// JSON-serializable asset data.
	proc/generate()
		CRASH("Missing generate() implementation for JSON asset [src.type]")

/// Asset singleton for the requested type.
/proc/get_assets(asset)
	. = global_asset_datum_list[asset] || new asset()

/// Sends the list of asset files to client if they're needed
/proc/send_assets(client/C, list/assetlist)
	if (cdn)
		message_coders("ZeWaka/Assets: I made a huge fuckup somewhere and assets are being sent with cdn enabled!!")
		return
	C.loadResourcesFromList(assetlist)
