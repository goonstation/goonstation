var/datum/disease_controller/disease_controls

/datum/disease_controller
	var/list/standard_diseases = list()
	var/list/custom_diseases = list()

	New()
		..()
		for (var/X in typesof(/datum/ailment))
			if (X == /datum/ailment || X == /datum/ailment/disease || X == /datum/ailment/parasite || X == /datum/ailment/disability)
				continue
			var/datum/ailment/A = new X
			standard_diseases += A

/proc/get_disease_from_path(var/disease_path)
	if (!ispath(disease_path))
		logTheThing(LOG_DEBUG, null, "<b>Disease:</b> Attempt to find schematic with null path")
		return null
	if (!disease_controls.standard_diseases.len)
		logTheThing(LOG_DEBUG, null, "<b>Disease:</b> Cant find disease due to empty disease list")
		return null
	for (var/datum/ailment/A in disease_controls.standard_diseases)
		if (disease_path == A.type)
			return A
	logTheThing(LOG_DEBUG, null, "<b>Disease:</b> Disease \"[disease_path]\" not found")
	return null

/proc/get_disease_from_name(var/disease_name)
	if (!istext(disease_name))
		logTheThing(LOG_DEBUG, null, "<b>Disease:</b> Attempt to find disease with non-string")
		return null
	if (!disease_controls.standard_diseases.len && !length(disease_controls.custom_diseases))
		logTheThing(LOG_DEBUG, null, "<b>Disease:</b> Cant find schematic due to empty disease lists")
		return null
	for (var/datum/ailment/A in (disease_controls.standard_diseases + disease_controls.custom_diseases))
		if (disease_name == A.name)
			return A
	logTheThing(LOG_DEBUG, null, "<b>Disease:</b> Disease with name \"[disease_name]\" not found")
	return null
