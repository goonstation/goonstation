/// Returns secret interface info (token + optional chunk filename) from the private mapping file.
/proc/tgui_get_secret_interface_info(interface_name)
	if (!interface_name)
		return null

	var/mapping_file = "+secret/tgui/secret-mapping.json"
	if (!fexists(mapping_file))
		return null

	var/mapping_json = file2text(mapping_file)
	if (!mapping_json)
		return null

	var/list/mapping = json_decode(mapping_json)
	if (!mapping || !istype(mapping))
		return null

	var/list/info = mapping[interface_name]
	if (!info || !istype(info))
		return null

	return info

/// Delivers the lazy-loaded bundle for a secret interface if it exists.
/proc/tgui_send_secret_interface_assets(client/C, interface_name, datum/tgui_window/window)
	if (!C || !window || !interface_name)
		return FALSE

	var/list/info = tgui_get_secret_interface_info(interface_name)
	if (!info)
		return FALSE

	var/token = info["token"]
	if (!token)
		// Legacy support
		token = info["uuid"]

	if (!token)
		return FALSE

	var/chunk_filename = info["chunk"]
	if (!chunk_filename)
		chunk_filename = "secret-[token].bundle.js"

	var/local_path = "browserassets/src/tgui/[chunk_filename]"

	if (!cdn && !fexists(local_path))
		return FALSE

	var/datum/asset/basic/tgui_secret_chunk/chunk_asset = new(chunk_filename)
	window.send_asset(chunk_asset)

	// Inform the client which opaque token to use for this interface name.
	window.send_message(
		"secret/interface",
		list("name" = interface_name, "token" = token, "chunk" = chunk_filename),
	)
	return TRUE

