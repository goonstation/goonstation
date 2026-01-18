// |GOONSTATION-ADD| This whole secret interface handling file

/// Returns secret interface id from the private mapping file.
/proc/tgui_get_secret_interface_id(interface_name)
	var/static/list/secret_mappings = null
	if (!secret_mappings)
		var/mapping_file = "+secret/tgui/secret-mapping.json"
		if (!fexists(mapping_file))
			return null

		var/mapping_json = file2text(mapping_file)
		if (!mapping_json)
			return null

		var/list/mappings = json_decode(mapping_json)
		if (!istype(mappings))
			return null

		secret_mappings = mappings

	. = secret_mappings[interface_name]
	if (!.)
		log_tgui(usr, "<b>TGUI/ZeWaka</b>: Secret interface not found for " + interface_name)
		return null

	return .

// todo: redo these to just use ui_assets() helper wrapper

/// Delivers the lazy-loaded bundle for a secret interface
/proc/tgui_send_secret_interface_assets(client/C, interface_name, datum/tgui_window/window)
	if (!C || !window || !interface_name)
		return FALSE

	var/id = tgui_get_secret_interface_id(interface_name)
	if (!id)
		return FALSE

	var/datum/asset/basic/tgui_secret_chunk/chunk_asset = new(id)
	window.send_asset(chunk_asset)

	// Inform the client which opaque token to use for this interface name.
	window.send_message(
		"secret/interface",
		list("name" = interface_name, "token" = id),
	)
	return TRUE

