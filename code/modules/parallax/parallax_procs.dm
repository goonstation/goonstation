/// Initialises `z_level_parallax_settings` by populating it with the default z-level parallax layers.
/proc/setup_z_level_parallax_settings()
	default_z_level_parallax_settings["[Z_LEVEL_STATION]"] = map_settings.parallax_layers

	var/parallax_layers = list()
	for (var/z_level in Z_LEVEL_NULL to Z_LEVEL_MINING)
		var/list/z_level_parallax_layers = default_z_level_parallax_settings["[z_level]"]
		parallax_layers["[z_level]"] = z_level_parallax_layers.Copy()

	z_level_parallax_settings = parallax_layers


/// Creates a new parallax layer of the specified type, or various layers should `parallax_layer_type_or_types` be a list, on the specified z-level for every client.
/proc/add_global_parallax_layer(parallax_layer_type_or_types, animation_time = 0, z_level = Z_LEVEL_STATION, list/layer_params)
	if (islist(parallax_layer_type_or_types))
		var/list/parallax_layers = parallax_layer_type_or_types
		parallax_layer_type_or_types = parallax_layers.Copy()

	for (var/client/client in clients)
		client.parallax_controller?.add_parallax_layer(parallax_layer_type_or_types, animation_time, z_level, layer_params)

	z_level_parallax_settings["[z_level]"] += parallax_layer_type_or_types


/// Removes all parallax layers of a specified type, or various types should `parallax_layer_type_or_types` be a list, not including children types, from a specified z-level for every client.
/proc/remove_global_parallax_layer(parallax_layer_type_or_types, animation_time = 0, z_level = Z_LEVEL_STATION)
	for (var/client/client in clients)
		client.parallax_controller?.remove_parallax_layer(parallax_layer_type_or_types, animation_time, z_level)

	z_level_parallax_settings["[z_level]"] -= parallax_layer_type_or_types


/// Removes all parallax layers from a specified z-level, or all parallax layers from all z-levels if one is not specified.
/proc/remove_all_parallax_layers(z_level)
	if (z_level)
		remove_global_parallax_layer(z_level_parallax_settings["[z_level]"], z_level = z_level)
		return

	for (var/z in Z_LEVEL_NULL to Z_LEVEL_MINING)
		remove_global_parallax_layer(z_level_parallax_settings["[z]"], z_level = z)


/// Restores a specified z-level's parallax layers to their default state, or all parallax layers from all z-levels if a z-level is not specified.
/proc/restore_parallax_layers_to_default(z_level)
	if (z_level)
		remove_all_parallax_layers(z_level)
		add_global_parallax_layer(default_z_level_parallax_settings["[z_level]"], z_level = z_level)
		return

	remove_all_parallax_layers()
	for (var/z in default_z_level_parallax_settings)
		add_global_parallax_layer(default_z_level_parallax_settings[z], z_level = z)

