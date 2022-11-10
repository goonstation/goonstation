

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

	/*-- read_map ------------------------------------
	Generates map instances based on provided DMM formatted text. If coordinates
	are provided, the map will start loading at those coordinates. Otherwise, any
	coordinates saved with the map will be used. Otherwise, coordinates will
	default to (1, 1, world.maxz+1)
	*/
	read_map(dmm_text as text, coordX as num, coordY as num, coordZ as num, tag as text, flags as num)
		UNTIL(!air_master?.is_busy)
		src.flags = flags
		if(flags & DMM_BESPOKE_AREAS)
			src.area_cache = list()
		var/datum/loadedProperties/props = new()
		props.sourceX = coordX
		props.sourceY = coordY
		props.sourceZ = coordZ
		props.info = tag
		// Split Key/Model list into lines
		var key_len
		var /list/grid_models[0]
		var startGridPos = findtext(dmm_text, "\n\n(1,1,") // Safe because \n not allowed in strings in dmm
		var startData = findtext(dmm_text, "\"")
		var linesText = copytext(dmm_text, startData + 1, startGridPos)
		var /list/modelLines = splittext(linesText, regex(@{"\n\""}))
		for(var/modelLine in modelLines) // "aa" = (/path{key = value; key = value},/path,/path)\n
			var endQuote = findtext(modelLine, quote, 2, 0)
			if(endQuote <= 1)
				continue
			var modelKey = copytext(modelLine, 1, endQuote)
			if(isnull(key_len))
				key_len = length(modelKey)
			var modelsStart = findtextEx(modelLine, "/") // Skip key and first three characters: "aa" = (
			var modelContents = copytext(modelLine, modelsStart, length(modelLine)) // Skip last character: )
			grid_models[modelKey] = modelContents
			sleep(-1)
		// Retrieve Comments, Determine map position (if not specified)
		var commentModel = modelLines[1] // The comment key will always be first.
		var bracketPos = findtextEx(commentModel, "}")
		commentModel = copytext(commentModel, findtextEx(commentModel, "=")+3, bracketPos) // Skip opening bracket
		var commentPathText = "[/obj/dmm_suite/comment]"
		if(copytext(commentModel, 1, length(commentPathText)+1) == commentPathText)
			var attributesText = copytext(commentModel, length(commentPathText)+2, -1) // Skip closing bracket
			var /list/paddedAttributes = splittext(attributesText, semicolon_delim) // "Key = Value"
			for(var/paddedAttribute in paddedAttributes)
				var equalPos = findtextEx(paddedAttribute, "=")
				var attributeKey = copytext(paddedAttribute, 1, equalPos-1)
				var attributeValue = copytext(paddedAttribute, equalPos+3, -1) // Skip quotes
				switch(attributeKey)
					if("coordinates")
						var /list/coords = splittext(attributeValue, comma_delim)
						if(!coordX) coordX = text2num(coords[1])
						if(!coordY)	coordY = text2num(coords[2])
						if(!coordZ) coordZ = text2num(coords[3])
		if(!coordX) coordX = 1
		if(!coordY) coordY = 1
		if(!coordZ) coordZ = world.maxz+1
		// Store quoted portions of text in text_strings, and replaces them with an index to that list.
		var gridText = copytext(dmm_text, startGridPos)
		var /list/gridLevels = list()
		var /regex/grid = regex(@{"\(([0-9]*),([0-9]*),([0-9]*)\) = \{"\n((?:\l*\n)*)"\}"}, "g")
		var /list/coordShifts = list()
		var/maxZFound = 1
		while(grid.Find(gridText))
			gridLevels.Add(copytext(grid.group[4], 1, -1)) // Strip last \n
			coordShifts.Add(list(list(grid.group[1], grid.group[2], grid.group[3])))
			maxZFound = max(maxZFound, text2num(grid.group[3]))
		// Create all Atoms at map location, from model key
		if ((coordZ+maxZFound-1) > world.maxz)
			world.setMaxZ(coordZ+maxZFound-1)
		for(var/posZ = 1 to gridLevels.len)
			var zGrid = gridLevels[posZ]
			// Reverse Y coordinate
			var /list/yReversed = text2list(zGrid, "\n")
			var /list/yLines = list()
			for(var/posY = yReversed.len to 1 step -1)
				yLines.Add(yReversed[posY])
			//
			var yMax = yLines.len+(coordY-1)
			if(world.maxy < yMax)
				world.maxy = yMax
				logTheThing(LOG_DEBUG, null, "[tag] caused map resize (Y) during prefab placement")
			var exampleLine = pick(yLines)
			var xMax = length(exampleLine)/key_len+(coordX-1)
			if(world.maxx < xMax)
				world.maxx = xMax
				logTheThing(LOG_DEBUG, null, "[tag] caused map resize (X) during prefab placement")

			props.maxX = max(length(exampleLine)/key_len, gridLevels.len)+(coordX-1)
			props.maxY = yMax
			props.maxZ = coordZ

			var/gridCoordX = text2num(coordShifts[posZ][1]) + coordX - 1
			var/gridCoordY = text2num(coordShifts[posZ][2])  + coordY - 1
			var/gridCoordZ = text2num(coordShifts[posZ][3])  + coordZ - 1

			if(flags && posZ == 1) // do this only once so we don't delete our own stuff if it's big!!!
				for(var/internalPosZ = 1 to gridLevels.len)
					var/igridCoordX = text2num(coordShifts[internalPosZ][1]) + coordX - 1
					var/igridCoordY = text2num(coordShifts[internalPosZ][2])  + coordY - 1
					var/igridCoordZ = text2num(coordShifts[internalPosZ][3])  + coordZ - 1
					for(var/posY = 1 to yLines.len)
						var yLine = yLines[posY]
						for(var/posX = 1 to length(yLine)/key_len)
							var/turf/T = locate(posX + igridCoordX - 1, posY+igridCoordY - 1, igridCoordZ)
							for(var/x in T)
								if(istype(x, /obj) && flags & DMM_OVERWRITE_OBJS && !istype(x, /obj/overlay))
									qdel(x)
								else if(istype(x, /mob) && flags & DMM_OVERWRITE_MOBS)
									qdel(x)
								LAGCHECK(LAG_MED)

			for(var/posY = 1 to yLines.len)
				var yLine = yLines[posY]
				for(var/posX = 1 to length(yLine)/key_len)
					var keyPos = ((posX-1)*key_len)+1
					var modelKey = copytext(yLine, keyPos, keyPos+key_len)
					parse_grid(
						grid_models[modelKey], posX + gridCoordX - 1, posY + gridCoordY - 1, gridCoordZ
					)
				sleep(-1)
			sleep(-1)
		//
		return props

	/*-- load_map ------------------------------------
	Deprecated. Use read_map instead.
	*/
	load_map(dmm_file as file, z_offset as num)
		if(!z_offset) z_offset = world.maxz+1
		var dmmText = file2text(dmm_file)
		return read_map(dmmText, 1, 1, z_offset)


//-- Supplemental Methods ------------------------------------------------------

	var
		quote = "\""
		regex/comma_delim = new(@"[\s\r\n]*,[\r\n][\s\r\n]*")
		regex/semicolon_delim = new(@"[\s\r\n]*;[\s\r\n]*")
		regex/key_value_regex = new(@"^[\s\r\n]*([^=]*?)[\s\r\n]*=[\s\r\n]*(.*?)[\s\r\n]*$")

	proc
		parse_grid(models as text, xcrd, ycrd, zcrd)
			/* Method parse_grid() - Accepts a text string containing a comma separated list
				of type paths of the same construction as those contained in a .dmm file, and
				instantiates them.*/
			// Store quoted portions of text in text_strings, and replace them with an index to that list.
			var/list/originalStrings = list()
			var/regex/noStrings = regex(@{"(["])(?:(?=(\\?))\2(.|\n))*?\1"})
			var/stringIndex = 1
			var/found
			do
				found = noStrings.Find(models, noStrings.next)
				if(found)
					var indexText = {""[stringIndex]""}
					stringIndex++
					var match = copytext(noStrings.match, 2, -1) // Strip quotes
					models = noStrings.Replace(models, indexText, found)
					originalStrings[indexText] = (match)
			while(found)
			// Identify each object's data, instantiate it, & reconstitues its fields.
			var /list/turfStackTypes = list()
			var /list/turfStackAttributes = list()
			for(var/areaDone = 0 to 1)
				for(var/atomModel in splittext(models, comma_delim))
					var bracketPos = findtext(atomModel, "{")
					var atomPath = text2path(copytext(atomModel, 1, bracketPos))
					var /list/attributes
					if(bracketPos)
						attributes = new()
						var attributesText = copytext(atomModel, bracketPos+1, -1)
						var /list/paddedAttributes = splittext(attributesText, semicolon_delim) // "Key = Value"
						for(var/paddedAttribute in paddedAttributes)
							key_value_regex.Find(paddedAttribute)
							attributes[key_value_regex.group[1]] = key_value_regex.group[2]
					// load areas first
					if(!areaDone)
						if(ispath(atomPath, /area))
							loadModel(atomPath, attributes, originalStrings, xcrd, ycrd, zcrd)
					else if(!ispath(atomPath, /turf))
						loadModel(atomPath, attributes, originalStrings, xcrd, ycrd, zcrd)
					else
						turfStackTypes.Insert(1, atomPath)
						turfStackAttributes.Insert(1, null)
						turfStackAttributes[1] = attributes
			// Layer all turf appearances into final turf
			if(!turfStackTypes.len) return
			var /turf/topTurf = loadModel(turfStackTypes[1], turfStackAttributes[1], originalStrings, xcrd, ycrd, zcrd)
			for(var/turfIndex = 2 to turfStackTypes.len)
				var /mutable_appearance/underlay = new(turfStackTypes[turfIndex])
				loadModel(underlay, turfStackAttributes[turfIndex], originalStrings, xcrd, ycrd, zcrd)
				topTurf.underlays.Add(underlay)

		loadModel(atomPath, list/attributes, list/strings, xcrd, ycrd, zcrd)
			// Cancel if atomPath is a placeholder (DMM_IGNORE flags used to write file)
			if(ispath(atomPath, /turf/dmm_suite/clear_turf) || ispath(atomPath, /area/dmm_suite/clear_area))
				return
			if((flags & DMM_LOAD_SPACE) && ispath(atomPath, /turf/space)) return //Dont load space
			// Parse all attributes and create preloader
			var /list/attributesMirror = list()
			var /turf/location = locate(xcrd, ycrd, zcrd)
			for(var/attributeName in attributes)
				attributesMirror[attributeName] = loadAttribute(attributes[attributeName], strings)
			var /dmm_suite/preloader/preloader = new(location, attributesMirror)
			// Begin Instanciation
			// Handle Areas (not created every time)
			var /atom/instance
			if(ispath(atomPath, /area))
				if(src.flags & DMM_BESPOKE_AREAS)
					if(!(atomPath in src.area_cache))
						src.area_cache[atomPath] = new atomPath
					var/area/ar = src.area_cache[atomPath]
					ar.contents += locate(xcrd, ycrd, zcrd)
				else
					new atomPath(locate(xcrd, ycrd, zcrd))
				location.dmm_preloader = null
			// Handle Underlay Turfs
			else if(istype(atomPath, /mutable_appearance))
				instance = atomPath // Skip to preloader manual loading.
				preloader.load(instance)
			// Handle Turfs & Movable Atoms
			else
				if(ispath(atomPath, /turf))
					//instance = new atomPath(location)
					instance = location.ReplaceWith(atomPath, keep_old_material = 0, handle_air = 0, handle_dir = 0, force = 1)
					instance.set_dir(initial(instance.dir))
				else
					if (atomPath)
						instance = new atomPath(location)
			// Handle cases where Atom/New was redifined without calling Super()
			if(preloader && instance && !instance.disposed) // Atom could delete itself in New()
				preloader.load(instance)
			//
			return instance

		loadAttribute(value, list/strings)
			// Check for typepath
			if(copytext(value, 1, 2) == "/")
				return text2path(value)
			//Check for string
			if(copytext(value, 1, 2) == "\"")
				return strings[value]
			//Check for number
			var num = text2num(value)
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
						var/val = isnull(val_str) ? null : loadAttribute(trim(val_str), strings)
						.[loadAttribute(trim(key_str), strings)] = val
					else
						. += loadAttribute(trim(key_str), strings)


//-- Preloading ----------------------------------------------------------------

turf
	var
		dmm_suite/preloader/dmm_preloader

atom/New(turf/newLoc)
    if(isturf(newLoc))
        var /dmm_suite/preloader/preloader = newLoc.dmm_preloader
        if(preloader)
            newLoc.dmm_preloader = null
            preloader.load(src)
    . = ..()

dmm_suite
	preloader
		parent_type = /datum
		var
			list/attributes
		New(turf/loadLocation, list/_attributes)
			loadLocation.dmm_preloader = src
			attributes = _attributes
			. = ..()
		proc
			load(atom/newAtom)
				var /list/attributesMirror = attributes // apparently this is faster
				for(var/attributeName in attributesMirror)
					newAtom.vars[attributeName] = attributesMirror[attributeName]
