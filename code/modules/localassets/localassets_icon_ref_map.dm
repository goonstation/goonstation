/// Public DMI paths mapped to BYOND resource references for tgui-core's DmIcon.
/datum/asset/json/icon_ref_map
	name = "icon_ref_map"
	early = TRUE

	/// Scan cached DMI files, including those loaded during world initialization.
	/// Generated icons have no stable path for server-side lookup.
	generate()
		var/list/icon_refs = list()
		var/resource_id = -1
		while (TRUE)
			resource_id++
			var/resource_ref = "\[0xc[num2text(resource_id, 6, 16)]\]"
			var/resource = locate(resource_ref)
			if (isnull(resource))
				break
			if (!isfile(resource) || !isicon(resource))
				continue
			var/icon_path = "[resource]"
			// Runtime-loaded secret DMIs must not be republished by this scan.
			if (is_public_tgui_icon_path(icon_path))
				icon_refs[icon_path] = resource_ref
		return icon_refs

/// Exclude runtime-loaded secret DMIs from the public icon map.
/proc/is_public_tgui_icon_path(icon_path)
	if (!is_valid_dmi_file(icon_path))
		return FALSE
	var/normalized_path = replacetext(icon_path, "\\", "/")
	return !findtext("/[normalized_path]", "/+secret/")

/proc/is_valid_dmi_file(icon_path)
	if(!istext(icon_path) || !length(icon_path))
		return FALSE

	var/is_in_icon_folder = findtextEx(icon_path, "icons/")
	var/is_dmi_file = findtextEx(icon_path, ".dmi")

	if(is_in_icon_folder && is_dmi_file)
		return TRUE
	return FALSE
