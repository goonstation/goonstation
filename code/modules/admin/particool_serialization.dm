/particles/proc/particool_serialize()
	boutput(world, "start2")

	var/datum/sandbox/sandbox = new /datum/sandbox()
	var/fname = "particool_temp_saves/PARTICOOL_TEMP_SAVE_[usr.client.ckey].sav"
	//if (fexists(fname))
	//	fdel(fname)
	var/savefile/saveFile = new /savefile()

	var/variables_list = list("width", "height", "count", "spawning", "bound1", "bound2", "gravity", "gradient", "transform", "lifespan", "fade", "fadein",
		"color", "color_change", "position", "velocity", "scale", "grow", "rotation", "spin", "friction", "drift", "icon", "icon_state")

	for(var/variable in variables_list)
		if(istype(src.vars[variable], /generator/))
			var/generator/generator = src.vars[variable]
			UNLINT(saveFile[variable] << "[generator._binobj]")
		else if(isicon(src.vars[variable]))
			icon_serializer(saveFile, "particool_icon", sandbox, src.icon, src.icon_state)
		else
			saveFile[variable] << src.vars[variable]


	if (fexists(fname))
		fdel(fname)
	var/target = file(fname)
	saveFile.ExportText("/", target)
	boutput(usr, "<span class='notice'>Saving finished.</span>")
	usr << ftp(target)



//lifespan = "generator(\"num\", 0, 0, UNIFORM_RAND)"
//position = "generator(\"box\", list(0,0,0), list(0,0,0), UNIFORM_RAND)"
// generator("box", list(-2,-2,0), list(2,2.3,0), UNIFORM_RAND)
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
		var/valuesText = trim(valuesExtractRegex.match)
		parsedText = replacetext(parsedText, valuesExtractRegex, "")

		var/list/generatorTypeAndRandomDistribution = splittext(parsedText, ",")
		generatorType = generatorTypeAndRandomDistribution[1]
		randomDistributionType = generatorTypeAndRandomDistribution[2]

		var/separatingIndex = findtext(valuesText, "),")
		A = copytext(valuesText, 6, separatingIndex)
		B = copytext(valuesText, separatingIndex + 8, length(valuesText) - 1)

	generatorType = replacetext(generatorType, "\"", "")
	randomDistributionType = trim(randomDistributionType)
	A = trim(A)
	B = trim(B)
	world << "generatorType: [generatorType]"
	world << "randomDistributionType: [randomDistributionType]"
	world << "A: [A]"
	world << "B: [B]"







/*
	var/regex/preliminary_regex = regex(@"\([^)]*\),\s+[a-zA-Z]+\([^)]*\),\s+[a-zA-Z]+_[a-zA-Z]+")

	var/test = "generator(\"box\", list(0,0,0), list(0,0,0), UNIFORM_RAND)"
	world.log << "original [test]"

	preliminary_regex.Find(test)
	var/matchedText = preliminary_regex.match // "generator("box", list(0,0,0), list(0,0,0), UNIFORM_RAND)" -> "box", list(0,0,0), list(0,0,0), UNIFORM_RAND)
*/

/*
	var/list/splitParsed = splittext(parsed, ",")
	for(var/part in splitParsed)
		world.log << "[part]"
*/



/*
	saveFile["width"] << src.width
	saveFile["height"] << src.height
	saveFile["count"] << src.count
	saveFile["spawning"] << src.spawning
	saveFile["bound1"] << src.bound1
	saveFile["bound2"] << src.bound2
	saveFile["gravity"] << src.gravity
	saveFile["gradient"] << src.gradient
	saveFile["transform"] << src.transform
	if(istype(src.lifespan, /generator/))
		var/generator/generator = src.lifespan
		saveFile["lifespan"] << "[generator._binobj]"
	else
		saveFile["lifespan"] << src.lifespan
	if(istype(src.fade, /generator/))
		var/generator/generator = src.fade
		saveFile["fade"] << "[generator._binobj]"
	else
		saveFile["fade"] << src.lifespan
	if(istype(src.fadein, /generator/))
		var/generator/generator = src.fadein
		saveFile["fadein"] << "[generator._binobj]"
	else
		saveFile["fadein"] << src.fadein
	icon_serializer(saveFile, "particool_icon", sandbox, src.icon, src.icon_state)
	saveFile["color"] << src.color
	saveFile["color_change"] << src.color_change
	if(istype(src.position, /generator/))
		var/generator/generator = src.position
		saveFile["position"] << "[generator._binobj]"
	else
		saveFile["position"] << src.position
	saveFile["velocity"] << src.velocity
	saveFile["scale"] << src.scale
	saveFile["grow"] << src.grow
	saveFile["rotation"] << src.rotation
	saveFile["spin"] << src.spin
	saveFile["friction"] << src.friction
	saveFile["drift"] << src.drift

	if (fexists(fname))
		fdel(fname)
	var/target = file(fname)
	saveFile.ExportText("/", target)
	boutput(usr, "<span class='notice'>Saving finished.</span>")
	usr << ftp(target)
*/





