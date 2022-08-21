var/datum/manufacturing_controller/manuf_controls

/datum/manufacturing_controller
	var/list/manufacturing_units = list()
	var/list/normal_schematics = list()
	var/list/custom_schematics = list()

	proc/set_up()
		for (var/M in concrete_typesof(/datum/manufacture, FALSE))
			var/datum/manufacture/man = new M
			if(!man.disposed)
				src.normal_schematics += man
		for_by_tcl(M, /obj/machinery/manufacturer)
			src.manufacturing_units += M
			M.set_up_schematics()

/proc/get_schematic_from_path(var/schematic_path)
	if (!ispath(schematic_path))
		logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Attempt to find schematic with null path")
		return null
	if (!manuf_controls.normal_schematics.len)
		logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Cant find schematic due to empty schematic list")
		return null
	for (var/datum/manufacture/M in manuf_controls.normal_schematics)
		if (schematic_path == M.type)
			return M
	logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Schematic \"[schematic_path]\" not found")
	return null

/proc/get_schematic_from_name(var/schematic_name)
	if (!istext(schematic_name))
		logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Attempt to find schematic with non-string")
		return null
	if (!manuf_controls.normal_schematics.len && !length(manuf_controls.custom_schematics))
		logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Cant find schematic due to empty schematic lists")
		return null
	for (var/datum/manufacture/M in (manuf_controls.normal_schematics + manuf_controls.custom_schematics))
		if (schematic_name == M.name)
			return M
	logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Schematic with name \"[schematic_name]\" not found")
	return null

/proc/get_schematic_from_name_in_custom(var/schematic_name)
	if (!istext(schematic_name))
		logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Attempt to find schematic with non-string")
		return null
	if (!manuf_controls.custom_schematics.len)
		logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Cant find schematic due to empty schematic lists")
		return null
	for (var/datum/manufacture/M in manuf_controls.custom_schematics)
		if (schematic_name == M.name)
			return M
	logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Schematic with name \"[schematic_name]\" not found")
	return null

/proc/get_schematic_from_path_in_custom(var/schematic_path)
	if (!ispath(schematic_path))
		logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Attempt to find schematic with null path")
		return null
	if (!length(manuf_controls.custom_schematics))
		logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Cant find schematic due to empty schematic list")
		return null
	for (var/datum/manufacture/mechanics/M in manuf_controls.custom_schematics)
		if (schematic_path == M.frame_path)
			return M
	logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> Schematic \"[schematic_path]\" not found")
	return null
