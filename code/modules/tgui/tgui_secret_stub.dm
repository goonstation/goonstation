/// Returns the canonical chunk filename for a secret interface.
/proc/tgui_secret_chunk_filename(interface_name)
	if (!interface_name)
		return null
	var/hash = copytext(md5(interface_name), 1, 12+1)
	return "secret-[hash].bundle.js"

/// Delivers the lazy-loaded bundle for a secret interface if it exists.
/proc/tgui_send_secret_interface_assets(client/C, interface_name, datum/tgui_window/window)
	if (!C || !window || !interface_name)
		return FALSE

	var/chunk_filename = tgui_secret_chunk_filename(interface_name)
	if (!chunk_filename)
		return FALSE

	var/local_path = "browserassets/src/tgui/[chunk_filename]"

	if (!cdn && !fexists(local_path))
		return FALSE

	var/datum/asset/basic/tgui_secret_chunk/chunk_asset = new(chunk_filename)
	window.send_asset(chunk_asset)
	return TRUE

