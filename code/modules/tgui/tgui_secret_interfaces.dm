/**
 * @file |GOONSTATION-ADD| Secret interface handling for rspack builds
 * @copyright 2026 ZeWaka
 * @license MIT
 */

/// Returns the secret interface id from the secret mapping file.
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
		//log_tgui(usr, "<b>TGUI/ZeWaka</b>: Secret interface not found for " + interface_name)
		return null
	return .
