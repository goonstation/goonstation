/particles/var/static/list/particles_variable_names = list("width", "height", "count", "spawning", "bound1", "bound2", "gravity", "gradient", "transform", "lifespan", "fade", "fadein",
		"color", "color_change", "position", "velocity", "scale", "grow", "rotation", "spin", "friction", "drift", "icon")

/// Prompts user to save the properties of the particle set object this proc is attached to into a file to load in the future.
/// Unless dont_serialize_icon is set, also serializes the icon in the file, otherwise only saves the particle properties.
/particles/proc/particleset_serialize_dialog(var/dont_serialize_icon = 0)
	var/datum/sandbox/sandbox = new /datum/sandbox()
	var/fname = "adventure/PARTICOOL_TEMP_SAVE_[usr.client.ckey].sav"
	var/savefile/saveFile = new /savefile()

	saveFile["DM_VERSION"] << DM_VERSION
	saveFile["DM_BUILD"] << DM_BUILD

	for(var/variable in particles_variable_names)
		if(istype(src.vars[variable], /generator/))
			var/generator/generator = src.vars[variable]
			UNLINT(saveFile[variable] << "[generator._binobj]")
		else if(variable == "icon")
			if (dont_serialize_icon)
				continue
			icon_serializer(saveFile, "particool_icon", sandbox, src.icon, src.icon_state)
		else
			saveFile[variable] << src.vars[variable]
	if (fexists(fname))
		fdel(fname)
	var/target = file(fname)
	saveFile.ExportText("/", target)
	boutput(usr, SPAN_NOTICE("Saving finished."))
	usr << ftp(target)

/// Prompts user to select a file to which a particle set was earlier serialized, to load it into the particle set object this proc is attached to.
/particles/proc/particleset_deserialize_file(var/target)
	if (!target)
		return
	var/fname = "adventure/PARTICOOL_TEMP_SAVE_[usr.client.ckey].sav"
	if (fexists(fname))
		fdel(fname)
	var/savefile/saveFile = new /savefile(fname)
	saveFile.ImportText("/", file2text(target))
	if (!saveFile)
		boutput(usr, SPAN_ALERT("Import failed."))
		return

	var/value
	for (var/variable in particles_variable_names)
		if (variable == "icon")
			saveFile["particool_icon.icon"] >> value
			if(value == null) // no icon was saved
				continue
			var/datum/sandbox/sandbox = new /datum/sandbox()
			var/datum/iconDeserializerData/IDS = icon_deserializer(saveFile, "particool_icon", sandbox, null, null, grab_file_reference_from_rsc_cache = 1)
			src.icon = IDS.icon
			src.icon_state = IDS.icon_state
		else
			saveFile[variable] >> value
			if(value == null)
				if(variable == "lifespan")
					value = 50 // seems to be the default lifespan value
				else if(variable == "grow")
					value = list(0,0)
				else if(variable == "scale")
					value = list(1,1)
				else if(variable == "color")
					value = "#FFFFFF"
				else
					value = 0 // "null" is ignored by particles and just continues its previous operation, this explicitly zeroes the setting
			if (findtext(value,"generator") == 0) // plain regular value
				src.vars[variable] = value
			else // generators - manual handling
				src.vars[variable] = binobj_to_generator(value)

	// clean up the file after using it
	if (fexists(fname))
		fdel(fname)

/// Particle sets contain a "_binobj" variable, which exposes some of its properties, as the /particles/ "datum" is otherwise just a wrapper wih nothing relevant in it.
/// This proc extracts data from a given _binobj value and creates a generator with the same properties.
proc/binobj_to_generator(var/binobj)
	var/parsedText = copytext(binobj, 11, length(binobj)) // "generator("box", list(0,0,0), list(0,0,0), UNIFORM_RAND)" -> "box", list(0,0,0), list(0,0,0), UNIFORM_RAND

	var/generatorType
	var/randomDistributionType
	var/A
	var/B

	if(findtext(parsedText,"list")==0)  // example: "generator(\"num\", -2, 2, UNIFORM_RAND)" -> here parsed: "num", -2.54, 2.2, UNIFORM\_RAND
		var/split_text = splittext(parsedText, ",")
		generatorType = split_text[1]
		A = split_text[2]
		B = split_text[3]
		randomDistributionType = split_text[4]
	else
		var/regex/valuesExtractRegex = regex(@"\s+[A-Za-z0-9]+\([^)]*\),\s+[a-zA-Z]+\([^)]*\),\s+")
		valuesExtractRegex.Find(parsedText)
		var/valuesText = trimtext(valuesExtractRegex.match)
		parsedText = replacetext(parsedText, valuesExtractRegex, "")

		var/list/generatorTypeAndRandomDistribution = splittext(parsedText, ",")
		generatorType = generatorTypeAndRandomDistribution[1]
		randomDistributionType = generatorTypeAndRandomDistribution[2]

		var/separatingIndex = findtext(valuesText, "),")
		A = copytext(valuesText, 6, separatingIndex)
		B = copytext(valuesText, separatingIndex + 8, length(valuesText) - 1)

	// extracted values
	generatorType = replacetext(generatorType, "\"", "")
	randomDistributionType = trimtext(randomDistributionType)
	A = trimtext(A)
	if (findtext(A,",") != 0) // dealing with a comma separated list
		var/list/l = list()
		var/list/split_values = splittext(A, ",")
		for(var/i = 1 to length(split_values))
			l.Add(text2num_safe(trimtext(split_values[i])))
		A = l
	else
		A = text2num_safe(A)
	B = trimtext(B)
	if (findtext(B,",") != 0) // dealing with a comma separated list
		var/list/l = list()
		var/list/split_values = splittext(B, ",")
		for(var/i = 1 to length(split_values))
			l.Add(text2num_safe(trimtext(split_values[i])))
		B = l
	else
		B = text2num_safe(B)

	return generator(generatorType, A, B, randomDistributionType)




