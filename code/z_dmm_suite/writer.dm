

//-- Writer for saving DMM files at runtime ------------------------------------

dmm_suite
	var/save_comment = 1
	var/static/list/map_save_var_blacklist = list("flags", "luminosity", "net_id", "host_id", "glide_size", "screen_loc")

	/*-- write_map -----------------------------------
	Generates DMM map text from a region represented by turfs on two opposite
	corners of a 3D block. Generated map text is ready to be saved to file or
	read into another position on the map.
	*/
	write_map(turf/turf1, turf/turf2, flags as num)
		//Check for valid turfs.
		if(!isturf(turf1) || !isturf(turf2))
			CRASH("Invalid arguments supplied to proc write_map, arguments were not turfs.")
		var/turf/lowCorner  = locate(min(turf1.x,turf2.x), min(turf1.y,turf2.y), min(turf1.z,turf2.z))
		var/turf/highCorner = locate(max(turf1.x,turf2.x), max(turf1.y,turf2.y), max(turf1.z,turf2.z))
		var/startZ = lowCorner.z
		var/startY = lowCorner.y
		var/startX = lowCorner.x
		var/endZ   = highCorner.z
		var/endY   = highCorner.y
		var/endX   = highCorner.x
		var/depth  = (endZ - startZ)+1 // Include first tile, x = 1
		var/height = (endY - startY)+1
		var/width  = (endX - startX)+1
		// Create dmm_suite comments to store in map file
		if(src.save_comment)
			var/obj/dmm_suite/comment/mapComment = new(locate(startX, startY, startZ))
			mapComment.coordinates = "[startX],[startY],[startZ]"
			mapComment.dimensions = "[width],[height],[depth]"
		// Identify all unique grid cells
		// Store template number for each grid cells
		var/list/templates = list()
		var/list/templateBuffer = new(width*height*depth)
		for(var/posZ = 0 to depth-1)
			for(var/posY = 0 to height-1)
				for(var/posX = 0 to width-1)
					var/turf/saveTurf = locate(startX+posX, startY+posY, startZ+posZ)
					var/testTemplate = makeTemplate(saveTurf, flags)
					var/templateNumber = templates.Find(testTemplate)
					if(!templateNumber)
						templates.Add(testTemplate)
						templateNumber = length(templates)
					var/compoundIndex = 1 + (posX) + (posY*width) + (posZ*width*height)
					templateBuffer[compoundIndex] = templateNumber
		// Compile List of Keys mapped to Models
		return writeDimensions(startX, startY, startZ, width, height, depth, templates, templateBuffer)

	/*-- write_cube ----------------------------------
	Generates DMM map text from a region defined by the supplied coordinates
	and dimensions. Generated map text is ready to be saved	to file or read
	into another position on the map.
	*/
	write_cube(startX as num, startY as num, startZ as num, width as num, height as num, depth as num, flags as num)
		// Ensure that cube is within boundries of current map
		if(
			min(startX, startY, startZ) < 1 || \
			startX + width -1 > world.maxx  || \
			startY + height-1 > world.maxy  || \
			startZ + depth -1 > world.maxz  || \
			startX > world.maxx             || \
			startY > world.maxy             || \
			startZ > world.maxz                \
		) CRASH("Dimensions outside valid range")
		// Create dmm_suite comments to store in map file
		var/obj/dmm_suite/comment/mapComment = new(locate(startX, startY, startZ))
		mapComment.coordinates = "[startX],[startY],[startZ]"
		mapComment.dimensions = "[width],[height],[depth]"
		// Identify all unique grid cells
		// Store template number for each grid cells
		var/list/templates = list()
		var/list/templateBuffer = new(width*height*depth)
		for(var/posZ = 0 to depth-1)
			for(var/posY = 0 to height-1)
				for(var/posX = 0 to width-1)
					var/turf/saveTurf = locate(startX+posX, startY+posY, startZ+posZ)
					var/testTemplate = makeTemplate(saveTurf, flags)
					var/templateNumber = templates.Find(testTemplate)
					if(!templateNumber)
						templates.Add(testTemplate)
						templateNumber = length(templates)
					var/compoundIndex = 1 + (posX) + (posY*width) + (posZ*width*height)
					templateBuffer[compoundIndex] = templateNumber
		// Compile List of Keys mapped to Models
		return writeDimensions(startX, startY, startZ, width, height, depth, templates, templateBuffer)

	/*-- write_area ----------------------------------
	Generates DMM map text from an /area instance. Instance can be irregularly
	shape and non-contiguous.  Generated map text is ready to be saved to file
	or read into another position on the map.
	*/
	write_area(area/save_area, flags as num)
		// Cancel out if the area isn't on the map
		var/list/atom/save_area_contents = save_area.contents.Copy()
		if(!(locate(/turf) in save_area_contents))
			return FALSE
		//
		var/startZ = save_area.z
		var/startY = save_area.y
		var/startX = save_area.x
		var/endZ = 0
		var/endY = 0
		var/endX = 0
		for(var/turf/containedTurf in save_area_contents)
			if(     containedTurf.z >   endZ)   endZ = containedTurf.z
			else if(containedTurf.z < startZ) startZ = containedTurf.z
			if(     containedTurf.y >   endY)   endY = containedTurf.y
			else if(containedTurf.y < startY) startY = containedTurf.y
			if(     containedTurf.x >   endX)   endX = containedTurf.x
			else if(containedTurf.x < startX) startX = containedTurf.x
		var/depth  = (endZ - startZ)+1 // Include first tile, x = 1
		var/height = (endY - startY)+1
		var/width  = (endX - startX)+1
		// Create empty cell model
		var/emptyCellModel = "[/turf/dmm_suite/clear_turf],[/area/dmm_suite/clear_area]"
		// Identify all unique grid cells
		// Store template number for each grid cells
		var/list/templates = list("-", emptyCellModel)
		var/emptyCellIndex = templates.Find(emptyCellModel) // Magic numbers already bit me here once. Don't be tempted!
		var/list/templateBuffer = new(width*height*depth)
		for(var/posZ = 0 to depth-1)
			for(var/posY = 0 to height-1)
				for(var/posX = 0 to width-1)
					var /turf/saveTurf = locate(startX+posX, startY+posY, startZ+posZ)
					// Skip out if turf isn't in save area
					if(saveTurf.loc != save_area)
						var/compoundIndex = 1 + (posX) + (posY*width) + (posZ*width*height)
						templateBuffer[compoundIndex] = emptyCellIndex
						continue
					//
					var/testTemplate = makeTemplate(saveTurf, flags)
					var/templateNumber = templates.Find(testTemplate)
					if(!templateNumber)
						templates.Add(testTemplate)
						templateNumber = length(templates)
					var compoundIndex = 1 + (posX) + (posY*width) + (posZ*width*height)
					templateBuffer[compoundIndex] = templateNumber
		// Create dmm_suite comments to store in map file
		if(src.save_comment)
			var/obj/dmm_suite/comment/mapComment = new(locate(startX, startY, startZ))
			mapComment.coordinates = "[startX],[startY],[startZ]"
			mapComment.dimensions = "[width],[height],[depth]"
			var/firstSaveIndex = templateBuffer[1]
			var/firstTemplate = templates[firstSaveIndex]
			var/commentTemplate  = "[mapComment.type][checkAttributes(mapComment)],[firstTemplate]"
			templates[1] = commentTemplate
			templateBuffer[1] = 1
		// Compile List of Keys mapped to Models
		return writeDimensions(startX, startY, startZ, width, height, depth, templates, templateBuffer)


//-- Text Generating Functions -------------------------------------------------

dmm_suite/proc

	/*-- writeDimensions -----------------------------
	Generates DMM map text representing a rectangular region defined
	by the provided arguments. Generated map text is ready to be saved
	to file or read into another position on the map.
	*/
	writeDimensions(startX, startY, startZ, width, height, depth, list/templates, list/templateBuffer)
		var/list/dmmText = list("//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE\n")
		// Compile List of Keys mapped to Models
		var keyLength = round/*floor*/(
			1 + log(
				letterDigits.len, max(1, templates.len-1)
			)
		)
		var/list/keys[templates.len]
		for(var/keyPos = 1 to templates.len)
			keys[keyPos] = computeKeyIndex(keyPos, keyLength)
			dmmText += {""[keys[keyPos]]" = (\n[templates[keyPos]])\n"}
		// Compile Level Grid Text
		for(var/posZ = 0 to depth-1)
			for(var/posX = 0 to width-1)
				dmmText += "\n([posX + 1],1,[posZ+1]) = {\"\n"
				var/list/joinGrid = list() // Joining a list is faster than generating strings
				for(var/posY = height-1 to 0 step -1)
					var/compoundIndex = 1 + (posX) + (posY*width) + (posZ*width*height)
					var/keyNumber = templateBuffer[compoundIndex]
					var/tempKey = keys[keyNumber]
					joinGrid.Add(tempKey)
					sleep(-1)
				dmmText += {"[list2text(joinGrid, "\n")]\n\"}"}
				sleep(-1)
		//
		return jointext(dmmText, "")

	/*-- makeTemplate --------------------------------
	Generates a DMM model string from all contents of
	a map location. Return value is of the form:
		/mob{name = "value"; name2 = 2},/etc,/turf,/turf,/area
	*/
	makeTemplate(turf/model as turf, flags as num)
		// Add Obj Templates
		var objTemplate = ""
		if(!(flags & DMM_IGNORE_OBJS))
			for(var/obj/O in model.contents)
				if(O.loc != model) continue
				if(istype(O, /obj/overlay) || !(flags & DMM_IGNORE_OVERLAYS)) continue
				if(istype(O, /obj/particle)) continue
				objTemplate += "[O.type][checkAttributes(O)],\n"
		// Add Mob
		var mobTemplate = ""
		for(var/mob/M in model.contents)
			if(M.loc != model) continue
			if(M.client)
				if(!(flags & DMM_IGNORE_PLAYERS))
					mobTemplate += "[M.type][checkAttributes(M)],\n"
			else
				if(!(flags & DMM_IGNORE_NPCS))
					mobTemplate += "[M.type][checkAttributes(M)],\n"
		// Add Turf Template
		var/skip_area = 0
		var turfTemplate = ""
		if(!(flags & DMM_IGNORE_TURFS))
			for(var/appearance in model.underlays)
				var /mutable_appearance/underlay = new(appearance)
				turfTemplate = "[/turf/dmm_suite/underlay][checkAttributes(underlay)],\n[turfTemplate]"
			if(istype(model, /turf/space))
				if(flags & DMM_IGNORE_SPACE)
					skip_area = 1
					turfTemplate += "[/turf/dmm_suite/clear_turf],\n"
				else
					turfTemplate += "[model.type],\n"
			else
				turfTemplate += "[model.type][checkAttributes(model)],\n"
		else
			turfTemplate = "[/turf/dmm_suite/clear_turf],\n"
		// Add Area Template
		var areaTemplate = ""
		if(!(flags & DMM_IGNORE_AREAS) && !skip_area)
			var /area/mArea = model.loc
			areaTemplate = "[mArea.type][checkAttributes(mArea)]"
		else
			areaTemplate = "[/area/dmm_suite/clear_area]"
		//
		var template = "[objTemplate][mobTemplate][turfTemplate][areaTemplate]"
		return template

	/*-- checkAttributes -----------------------------
	Generates a DMM string from all the attributes of
	a given atom. Return value is of the form:
		{name = "value"; name2 = 2}
	*/
	checkAttributes(atom/A, underlay, force_vars)
		var attributesText = ""
		var saving = FALSE
		for(var/V in A.vars)
			sleep(-1)
			// If the Variable isn't changed, or is marked as non-saving
			if((!issaved(A.vars[V]) || A.vars[V] == initial(A.vars[V]) || copytext(V, 1, 4) == "RL_" || (V in map_save_var_blacklist)) && \
				!(force_vars && (V in force_vars)))
				continue
			// Format different types of values
			if(istext(A.vars[V])) // Text
				if(saving) attributesText += ";\n\t"
				var/val = replacetext(A.vars[V], {"""}, {"\\""}) // escape quotes
				val = replacetext(val, "\n", "\\n")
				attributesText += {"[V] = "[val]""}
			else if(isnum(A.vars[V]) || ispath(A.vars[V])) // Numbers & Type Paths
				if(saving) attributesText += ";\n\t"
				attributesText += {"[V] = [A.vars[V]]"}
			else if(isicon(A.vars[V]) || isfile(A.vars[V])) // Icons & Files
				var filePath = "[A.vars[V]]"
				if(!length(filePath)) continue // Bail on dynamic icons
				if(saving) attributesText += ";\n\t"
				attributesText += {"[V] = '[A.vars[V]]'"}
			else // Otherwise, Bail
				continue
			// Add to Attributes
			saving = TRUE
		//
		if(!saving)
			return
		return "{\n\t[attributesText]\n\t}"

	/*-- computeKeyIndex -----------------------------
	Generates a DMM model index string of given length
	and given index value. Return value is of the form:
		aHc
	*/
	computeKeyIndex(keyIndex, keyLength)
		var key = ""
		var workingDigit = keyIndex-1
		for(var/digitPos = keyLength to 1 step -1)
			var placeValue = round/*floor*/(workingDigit/(letterDigits.len**(digitPos-1)))
			workingDigit-=placeValue*(letterDigits.len**(digitPos-1))
			key += letterDigits[placeValue+1]
		return key
dmm_suite/var
	list/letterDigits = list(
		"a","b","c","d","e",
		"f","g","h","i","j",
		"k","l","m","n","o",
		"p","q","r","s","t",
		"u","v","w","x","y",
		"z",
		"A","B","C","D","E",
		"F","G","H","I","J",
		"K","L","M","N","O",
		"P","Q","R","S","T",
		"U","V","W","X","Y",
		"Z"
	)

//-- Supplemental Writing Objects ----------------------------------------------

// for saving an area as a prefab

dmm_suite/prefab_saving
	save_comment = 0
	var/unsimulate = 0
	var/static/list/unsimulate_reskinning_vars = list("icon", "icon_state", "opacity", "name", "desc", "pixel_x", "pixel_y", "layer", "plane")
	var/static/list/unsimulate_mild_reskinning_vars = list("icon", "icon_state")

dmm_suite/prefab_saving/unsimulate
	unsimulate = 1

dmm_suite/prefab_saving/makeTemplate(turf/model as turf, flags as num)
	// Add Obj Templates
	var objTemplate = ""
	if(!(flags & DMM_IGNORE_OBJS))
		for(var/obj/O in model.contents)
			if(O.loc != model) continue
			if(istype(O, /obj/overlay) || !(flags & DMM_IGNORE_OVERLAYS)) continue
			objTemplate += "[O.type][checkAttributes(O)],"
	// Add Mob
	var mobTemplate = ""
	for(var/mob/M in model.contents)
		if(M.loc != model) continue
		if(M.client)
			if(!(flags & DMM_IGNORE_PLAYERS))
				mobTemplate += "[M.type][checkAttributes(M)],"
		else
			if(!(flags & DMM_IGNORE_NPCS))
				mobTemplate += "[M.type][checkAttributes(M)],"
	// Add Turf Template
	var/empty_area = 0
	var/turfTemplate = ""
	if(!(flags & DMM_IGNORE_TURFS))
		for(var/appearance in model.underlays)
			var/mutable_appearance/underlay = new(appearance)
			turfTemplate = "[/turf/dmm_suite/underlay][checkAttributes(underlay)],[turfTemplate]"
		if(istype(model, /turf/space))
			empty_area = 1
			turfTemplate += "[/turf/variableTurf/clear],"
		else if(istype(model, /turf/simulated/wall/auto/asteroid))
			empty_area = 1
			turfTemplate += "[/turf/variableTurf/wall],"
		else if(istype(model, /turf/simulated/floor/plating/airless/asteroid))
			empty_area = 1
			turfTemplate += "[/turf/variableTurf/floor],"
		else if(src.unsimulate && istype(model, /turf/simulated))
			var/new_path_str = replacetext("[model.type]", "simulated", "unsimulated")
			var/new_type = text2path(new_path_str)
			if(isnull(new_type))
				new_type = model.density ? /turf/unsimulated/wall : /turf/unsimulated/floor
				turfTemplate += "[new_type][checkAttributes(model, force_vars=unsimulate_reskinning_vars)],"
			else
				turfTemplate += "[new_type][checkAttributes(model, force_vars=unsimulate_mild_reskinning_vars)],"
		else
			turfTemplate += "[model.type][checkAttributes(model)],"
	else
		turfTemplate = "[/turf/dmm_suite/clear_turf],"
	// Add Area Template
	var/areaTemplate = ""
	if(empty_area)
		areaTemplate = "/area/allowGenerate"
	else if(!(flags & DMM_IGNORE_AREAS))
		var/area/mArea = model.loc
		areaTemplate = "[mArea.type][checkAttributes(mArea)]"
	else
		areaTemplate = "[/area/noGenerate]"
	//
	var/template = "[objTemplate][mobTemplate][turfTemplate][areaTemplate]"
	return template
