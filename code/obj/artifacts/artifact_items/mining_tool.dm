/obj/item/artifact/mining_tool
	name = "artifact mining tool"
	artifact = 1
	associated_datum = /datum/artifact/mining
	var/dig_power = 1
	var/extrahit = 0
	var/dig_sound = 'sound/effects/exlow.ogg'
	// mining.dm line 373

	New(var/loc, var/forceartiorigin)
		..()
		src.dig_power = rand(3,5) // It was 1-5, changed to 3-5 because what's the point of a mining artifact if it's crappier than stuff you can print roundstart?!
		if (prob(33))
			src.extrahit = rand(0,4) // extrahit isn't used anywhere. Victim of some ancient mining rework?
		src.dig_sound = pick('sound/effects/exlow.ogg','sound/effects/mag_magmisimpact.ogg','sound/impact_sounds/Energy_Hit_1.ogg')

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint))
			. += A.examine_hint

/datum/artifact/mining
	associated_object = /obj/item/artifact/mining_tool
	type_name = "Mining Tool"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 450
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	react_xray = list(12,80,95,5,"DENSE")
	examine_hint = "It seems to have a handle you're supposed to hold it by."
