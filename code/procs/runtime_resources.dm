/// Load icons from the server's filesystem without compiling them into the RSC.
/proc/get_runtime_icon(icon_path)
	var/static/list/runtime_icons = list()
	if (!runtime_icons[icon_path])
		var/icon_resource = fcopy_rsc(file(icon_path))
		if (!isicon(icon_resource))
			CRASH("Unable to load runtime icon [icon_path]")
		runtime_icons[icon_path] = icon_resource
	return runtime_icons[icon_path]

/// Resolve declared icons for both compiled resources and runtime-loaded type defaults.
/// Resolve string defaults from the existing TYPEINFO metadata.
/proc/get_initial_icon(datum/icon_source)
	var/atom/atom_source = icon_source
	var/default_icon = initial(atom_source.icon)
	if (default_icon)
		return istext(default_icon) ? get_runtime_icon(default_icon) : default_icon
	if (ispath(icon_source, /atom) || istype(icon_source, /atom))
		var/typeinfo/atom/icon_metadata = get_type_typeinfo(ispath(icon_source) ? icon_source : icon_source.type)
		if (icon_metadata.icon)
			return get_runtime_icon(icon_metadata.icon)

/// String-valued icon defaults belong to shared type metadata
/typeinfo/atom
	var/icon = null
