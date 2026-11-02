/// Resolve declared icons for both compiled resources and runtime-loaded type defaults.
/// Return a cache reference for browser image refs and comparisons with atom.icon.
/proc/get_initial_icon(datum/icon_source)
	var/atom/atom_source = icon_source
	var/default_icon = initial(atom_source.icon)
	if (default_icon && !istext(default_icon))
		return default_icon
	if (!default_icon && (ispath(icon_source, /atom) || istype(icon_source, /atom)))
		var/typeinfo/atom/icon_metadata = get_type_typeinfo(ispath(icon_source) ? icon_source : icon_source.type)
		default_icon = icon_metadata.icon
	if (default_icon)
		// Keep cache entries so repeated lookups avoid importing the filesystem file again.
		var/static/list/icon_resources = list()
		var/icon_resource = icon_resources[default_icon]
		if (!icon_resource)
			icon_resource = fcopy_rsc(default_icon)
			if (!isicon(icon_resource))
				CRASH("Unable to load runtime icon [default_icon]")
			icon_resources[default_icon] = icon_resource
		return icon_resource

/// String-valued icon defaults belong to shared type metadata
/typeinfo/atom
	var/icon = null
