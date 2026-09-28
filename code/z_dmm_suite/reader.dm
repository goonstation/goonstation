#define DMM_MODEL_AREA 1
#define DMM_MODEL_ATOM 2
#define DMM_MODEL_TURF 3
#define DMM_MODEL_UNDERLAY 4

//-- Reader for loading DMM files at runtime -----------------------------------
/datum/loadedProperties
	var/info = ""
	var/sourceX = 0
	var/sourceY = 0
	var/sourceZ = 0
	var/maxX = 0
	var/maxY = 0
	var/maxZ = 0

dmm_suite
	var/flags
	var/list/area_cache

	var/quote = "\""
	var/regex/comma_delim = new(@"[\s\r\n]*,[\r\n][\s\r\n]*")
	var/regex/semicolon_delim = new(@"[\s\r\n]*;[\s\r\n]*")
	var/regex/key_value_regex = new(@"^[\s\r\n]*([^=]*?)[\s\r\n]*=[\s\r\n]*(.*?)[\s\r\n]*$")

	/*-- read_map ------------------------------------
	Generates map instances based on provided DMM formatted text. If coordinates
	are provided, the map will start loading at those coordinates. Otherwise, any
	coordinates saved with the map will be used. Otherwise, coordinates will
	default to (1, 1, world.maxz+1)
	*/
dmm_suite/read_map(dmm_text as text, coordX as num, coordY as num, coordZ as num, tag as text, flags as num)
	UNTIL(!air_master?.is_busy, 0)
	src.flags = flags
	if(flags & DMM_BESPOKE_AREAS)
		src.area_cache = list()
	var/datum/loadedProperties/props = new()
	props.sourceX = coordX
	props.sourceY = coordY
	props.sourceZ = coordZ
	props.info = tag
	// Split Key/Model list into lines
	var/key_len
	var/list/grid_models[0]
	var/startGridPos = findtext(dmm_text, "\n\n(1,1,") // Safe because \n not allowed in strings in dmm
	var/startData = findtext(dmm_text, "\"")
	var/linesText = copytext(dmm_text, startData + 1, startGridPos)
	var/list/modelLines = splittext(linesText, regex("\n\""))
	for(var/modelLine in modelLines) // "aa" = (/path{key = value; key = value},/path,/path)
		var/endQuote = findtext(modelLine, quote, 2, 0)
		if(endQuote <= 1)
			continue
		var/modelKey = copytext(modelLine, 1, endQuote)
		if(isnull(key_len))
			key_len = length(modelKey)
		var/modelsStart = findtextEx(modelLine, "/") // Skip key and first three characters: "aa" = (
		var/modelContents = copytext(modelLine, modelsStart, length(modelLine)) // Skip last character: )
		grid_models[modelKey] = modelContents
		LAGCHECK_IF_LIVE(LAG_HIGH)
	// Retrieve Comments, Determine map position (if not specified)
	var/commentModel = modelLines[1] // The comment key will always be first.
	var/bracketPos = findtextEx(commentModel, "}")
	commentModel = copytext(commentModel, findtextEx(commentModel, "=")+3, bracketPos) // Skip opening bracket
	var/commentPathText = "[/obj/dmm_suite/comment]"
	if(copytext(commentModel, 1, length(commentPathText)+1) == commentPathText)
		var/attributesText = copytext(commentModel, length(commentPathText)+2, -1) // Skip closing bracket
		var/list/paddedAttributes = splittext(attributesText, semicolon_delim) // "Key = Value"
		for(var/paddedAttribute in paddedAttributes)
			var/equalPos = findtextEx(paddedAttribute, "=")
			var/attributeKey = copytext(paddedAttribute, 1, equalPos-1)
			var/attributeValue = copytext(paddedAttribute, equalPos+3, -1) // Skip quotes
			switch(attributeKey)
				if("coordinates")
					var/list/coords = splittext(attributeValue, comma_delim)
					if(!coordX) coordX = text2num(coords[1])
					if(!coordY) coordY = text2num(coords[2])
					if(!coordZ) coordZ = text2num(coords[3])
	if(!coordX) coordX = 1
	if(!coordY) coordY = 1
	if(!coordZ) coordZ = world.maxz+1
	// Parse each model once.
	var/list/parsed_models = list()
	for(var/modelKey in grid_models)
		parsed_models[modelKey] = parse_model(grid_models[modelKey])
		LAGCHECK_IF_LIVE(LAG_HIGH)
	var/gridText = copytext(dmm_text, startGridPos)
	var/list/gridYLines = list()
	var/list/coordShifts = list()
	var/maxZFound = 1
	var/regex/grid = regex(@{"\(([0-9]*),([0-9]*),([0-9]*)\) = \{"\n((?:\l*\n)*)"\}"}, "g")
	while(grid.Find(gridText))
		var/list/yReversed = text2list(copytext(grid.group[4], 1, -1), "\n")
		var/list/yLines = list()
		for(var/posY = yReversed.len to 1 step -1)
			yLines.Add(yReversed[posY])
		gridYLines.Add(list(yLines))
		coordShifts.Add(list(list(text2num(grid.group[1]), text2num(grid.group[2]), text2num(grid.group[3]))))
		maxZFound = max(maxZFound, coordShifts[coordShifts.len][3])
	// Create all Atoms at map location, from model key
	if((coordZ+maxZFound-1) > world.maxz)
		world.setMaxZ(coordZ+maxZFound-1)
	for(var/posZ = 1 to gridYLines.len)
		var/list/yLines = gridYLines[posZ]
		var/gridCoordX = coordShifts[posZ][1] + coordX - 1
		var/gridCoordY = coordShifts[posZ][2] + coordY - 1
		var/gridCoordZ = coordShifts[posZ][3] + coordZ - 1
		var/yMax = yLines.len+gridCoordY-1
		if(world.maxy < yMax)
			world.maxy = yMax
			logTheThing(LOG_DEBUG, null, "[tag] caused map resize (Y) during prefab placement")
		var/exampleLine = yLines[1]
		var/xMax = length(exampleLine)/key_len+gridCoordX-1
		if(world.maxx < xMax)
			world.maxx = xMax
			logTheThing(LOG_DEBUG, null, "[tag] caused map resize (X) during prefab placement")

		props.maxX = max(props.maxX, xMax)
		props.maxY = max(props.maxY, yMax)
		props.maxZ = max(props.maxZ, gridCoordZ)

		if((flags & (DMM_OVERWRITE_OBJS | DMM_OVERWRITE_MOBS)) && posZ == 1) // do this only once so we don't delete our own stuff if it's big!!!
			for(var/internalPosZ = 1 to gridYLines.len)
				var/igridCoordX = coordShifts[internalPosZ][1] + coordX - 1
				var/igridCoordY = coordShifts[internalPosZ][2] + coordY - 1
				var/igridCoordZ = coordShifts[internalPosZ][3] + coordZ - 1
				var/list/internalYLines = gridYLines[internalPosZ]
				for(var/posY = 1 to internalYLines.len)
					var/yLine = internalYLines[posY]
					for(var/posX = 1 to length(yLine)/key_len)
						var/turf/T = locate(posX + igridCoordX - 1, posY+igridCoordY - 1, igridCoordZ)
						for(var/x in T)
							if(isobj(x) && flags & DMM_OVERWRITE_OBJS && !istype(x, /obj/overlay))
								qdel(x)
							else if(ismob(x) && flags & DMM_OVERWRITE_MOBS)
								qdel(x)
							LAGCHECK(LAG_MED)

		for(var/posY = 1 to yLines.len)
			var/yLine = yLines[posY]
			for(var/posX = 1 to length(yLine)/key_len)
				var/keyPos = ((posX-1)*key_len)+1
				var/modelKey = copytext(yLine, keyPos, keyPos+key_len)
				parse_grid(parsed_models[modelKey], posX + gridCoordX - 1, posY + gridCoordY - 1, gridCoordZ)
			LAGCHECK_IF_LIVE(LAG_HIGH)
		LAGCHECK_IF_LIVE(LAG_HIGH)
	return props

//-- Supplemental Methods ------------------------------------------------------


dmm_suite/proc/parse_model(models as text)
	// Decode quoted values and attributes once per unique grid model.
	var/list/originalStrings = list()
	var/regex/noStrings = regex(@{"(["])(?:(?=(\\?))\2(.|\n))*?\1"})
	var/stringIndex = 1
	var/found
	do
		found = noStrings.Find(models, noStrings.next)
		if(found)
			var/indexText = {""[stringIndex]""}
			stringIndex++
			var/match = copytext(noStrings.match, 2, -1) // Strip quotes
			models = noStrings.Replace(models, indexText, found)
			originalStrings[indexText] = match
	while(found)
	var/list/areas = list()
	var/list/objects = list()
	var/list/turfs = list()
	for(var/atomModel in splittext(models, comma_delim))
		var/bracketPos = findtext(atomModel, "{")
		var/atomPath = text2path(copytext(atomModel, 1, bracketPos))
		if(!atomPath)
			stack_trace("Attempted to load invalid type [copytext(atomModel, 1, bracketPos)]!")
		var/list/attributes
		if(bracketPos)
			attributes = list()
			var/attributesText = copytext(atomModel, bracketPos+1, -1)
			var/list/paddedAttributes = splittext(attributesText, semicolon_delim)
			for(var/paddedAttribute in paddedAttributes)
				key_value_regex.Find(paddedAttribute)
				// Must be read before loadAttribute(), it re-uses key_value_regex and would clobber the groups.
				var/attributeKey = key_value_regex.group[1]
				var/attributeValue = key_value_regex.group[2]
				attributes[attributeKey] = loadAttribute(attributeValue, originalStrings)
		var/list/modelPart = list(atomPath, attributes)
		if(ispath(atomPath, /area))
			areas.Add(list(modelPart))
		else if(ispath(atomPath, /turf))
			turfs.Insert(1, list(modelPart))
		else
			objects.Add(list(modelPart))
	return list(areas, objects, turfs)

dmm_suite/proc/parse_grid(list/model, xcrd, ycrd, zcrd)
	/* Instantiates a cached model at one coordinate. */
	var/turf/location = locate(xcrd, ycrd, zcrd)
	for(var/list/modelPart in model[1])
		loadModel(modelPart[1], modelPart[2], location, DMM_MODEL_AREA)
	for(var/list/modelPart in model[2])
		loadModel(modelPart[1], modelPart[2], location, DMM_MODEL_ATOM)
	var/list/turfs = model[3]
	if(!turfs.len) return
	var/turf/topTurf = loadModel(turfs[1][1], turfs[1][2], location, DMM_MODEL_TURF)
	for(var/turfIndex = 2 to turfs.len)
		var/mutable_appearance/underlay = new(turfs[turfIndex][1])
		loadModel(underlay, turfs[turfIndex][2], location, DMM_MODEL_UNDERLAY)
		topTurf.underlays.Add(underlay)
		#ifdef CI_RUNTIME_CHECKING
		if(!istype(topTurf, /turf/simulated/floor/airless/plating/catwalk))
			CRASH("Duplicate turf at [xcrd],[ycrd],[zcrd] | [debug_id]")
		#endif

dmm_suite/proc/loadModel(atomPath, list/attributes, turf/location, modelKind)
	if(modelKind == DMM_MODEL_AREA)
		if(atomPath == /area/dmm_suite/clear_area)
			return
	else if(modelKind == DMM_MODEL_TURF)
		if(atomPath == /turf/dmm_suite/clear_turf)
			return
		if((flags & DMM_LOAD_SPACE) && ispath(atomPath, /turf/space)) return //Dont load space

	var/dmm_suite/preloader/preloader
	if(length(attributes))
		var/list/attributesMirror = attributes
		for(var/attributeName in attributes)
			var/value = attributes[attributeName]
			if(islist(value))
				if(attributesMirror == attributes)
					attributesMirror = attributes.Copy()
				attributesMirror[attributeName] = semi_deep_copy(value)
		preloader = new(location, attributesMirror)

	if(modelKind == DMM_MODEL_AREA)
		if(src.flags & DMM_BESPOKE_AREAS)
			if(!(atomPath in src.area_cache))
				src.area_cache[atomPath] = new atomPath
			var/area/ar = src.area_cache[atomPath]
			ar.contents += location
		else
			new atomPath(location)
		if(preloader)
			location.dmm_preloader = null
		return

	if(modelKind == DMM_MODEL_UNDERLAY)
		if(preloader)
			preloader.load(atomPath)
		return atomPath

	var/atom/instance
	if(modelKind == DMM_MODEL_TURF)
		location.RL_Cleanup()
		location.RL_Reset()
		instance = location.ReplaceWith(atomPath, keep_old_material = 0, handle_air = 0, handle_dir = 0, force = 1)
		if(instance) // I hate that we made it so ReplaceWith can return null, it sucks so much
			instance.set_dir(initial(instance.dir))
		else
			location.set_dir(initial(location.dir))
	else if(atomPath)
		instance = new atomPath(location)

	// Handle cases where Atom/New was redifined without calling Super()
	if(preloader && instance && !instance.disposed) // Atom could delete itself in New()
		preloader.load(instance)
	return instance

dmm_suite/proc/loadAttribute(value, list/strings)
	// Check for typepath
	if(copytext(value, 1, 2) == "/")
		return text2path(value)
	//Check for string
	if(copytext(value, 1, 2) == "\"")
		return strings[value]
	//Check for number
	var/num = text2num(value)
	if(isnum(num))
		return num
	//Check for file
	else if(copytext(value,1,2) == "'")
		return get_cached_file(copytext(value,2,length(value)))
		// return file(copytext(value,2,length(value)))
	else if(startswith(value, "list("))
		value = copytext(value, 6, -1)
		var/list/list_values = splittext(value, ",")
		// todo associations
		// also todo , in strings
		. = list()
		for(var/list_value in list_values)
			var/key_str = list_value
			var/val_str = null
			if(findtext(key_str, "="))
				key_value_regex.Find(key_str)
				key_str = key_value_regex.group[1]
				val_str = key_value_regex.group[2]
				var/val = isnull(val_str) ? null : loadAttribute(trimtext(val_str), strings)
				.[loadAttribute(trimtext(key_str), strings)] = val
			else
				. += loadAttribute(trimtext(key_str), strings)


//-- Preloading ----------------------------------------------------------------

turf/var/dmm_suite/preloader/dmm_preloader

/atom/New(newLoc)
	if(isturf(newLoc))
		var/turf/T = newLoc
		var/dmm_suite/preloader/preloader = T.dmm_preloader
		if(preloader)
			T.dmm_preloader = null
			preloader.load(src)
	. = ..()

/dmm_suite/preloader
	parent_type = /datum
	var/list/attributes

	New(turf/loadLocation, list/_attributes)
		loadLocation.dmm_preloader = src
		attributes = _attributes
		. = ..()
	proc/load(atom/newAtom)
		var/list/attributesMirror = attributes // apparently this is faster
		for(var/attributeName in attributesMirror)
			newAtom.vars[attributeName] = attributesMirror[attributeName]

#undef DMM_MODEL_AREA
#undef DMM_MODEL_ATOM
#undef DMM_MODEL_TURF
#undef DMM_MODEL_UNDERLAY
