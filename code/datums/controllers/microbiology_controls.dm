var/datum/microbiology_controller/microbio_controls

/datum/microbiology_controller

	var/list/pathogen_affected_reagents = list("blood", "pathogen", "bloodc")
	var/next_uid = 1

	var/list/cultures = list()
	var/list/effects = list()
	var/list/cures = list()
	//var/list/path_to_evil = list()

	New()	//Initialize effect and cure paths.
		..()
		for (var/X in concrete_typesof(/datum/microbe))
			if (!(X in cultures))
				var/datum/microbe/A = new X
				cultures += A

		for (var/X in concrete_typesof(/datum/microbioeffects))
			var/datum/microbioeffects/E = new X
			effects += E

		for (var/X in concrete_typesof(/datum/suppressant))
			var/datum/suppressant/C = new X
			cures += C

	proc/rerendermicrobes()
		for (var/X in concrete_typesof(/datum/microbe))
			if (!(X in cultures))
				var/datum/microbe/A = new X
				cultures += A

	proc/updatemicrobe(var/datum/microbe/P, var/mob/M, var/selection, var/newname = "Optional", var/reportaccuracy = 0)
		if (!(P) || !(selection))
			return
		if (selection == "infected")
			P.infected += M
			P.infectioncount--
			for (var/mob/living/carbon/human/H in P.infected)
				updatesubdata(H,P)
			return
		if (selection == "cured")
			P.infected -= M
			P.immune += M
			if (!(P.infected))	//If the disease is extinct skip the for loops
				return
			for (var/mob/living/carbon/human/H in P.infected)
				updatesubdata(H,P)
			return
		if (selection == "rename")
			P.print_name = newname
			if (!(P.infected))	//If the disease is extinct skip the for loops
				return
			for (var/mob/living/carbon/human/H in P.infected)
				updatesubdata(H,P)
			return
		if (selection == "researched")
			P.reported = 1
			if (reportaccuracy)
				P.curereported = 1
			if (!(P.infected))	//If the disease is extinct/has no hosts skip the for loops
				return
			for (var/mob/living/carbon/human/H in P.infected)
				updatesubdata(H,P)
			return

	proc/updatesubdata(var/mob/living/carbon/human/H, var/datum/microbe/P)
		if (!H.microbes.len)	//If the listed mob does not have any microbes return early
			return
		for (var/uid in H.microbes)
			if (P.name == H.microbes[uid].master.name)
				H.microbes[uid].master = P

	proc/get_microbe_from_path(var/microbe_path)
		rerendermicrobes()
		if (!ispath(microbe_path))
			logTheThing("debug", null, null, "<b>Microbiology:</b> Attempt to find schematic with null path")
			return null
		if (!microbio_controls.cultures.len)
			logTheThing("debug", null, null, "<b>Microbiology:</b> Cant find disease due to empty disease list")
			return null
		for (var/datum/microbe/A in microbio_controls.cultures)
			if (microbe_path == A.type)
				return A
		logTheThing("debug", null, null, "<b>Microbiology:</b> Disease \"[microbe_path]\" not found")
		return null

	proc/get_microbe_from_name(var/microbe_name)
		rerendermicrobes()
		if (!istext(microbe_name))
			logTheThing("debug", null, null, "<b>Microbiology:</b> Attempt to find disease with non-string")
			return null
		if (!microbio_controls.cultures.len)
			logTheThing("debug", null, null, "<b>Microbiology:</b> Cant find schematic due to empty disease lists")
			return null
		for (var/datum/microbe/A in microbio_controls.cultures)
			if (microbe_name == A.name)
				return A
		logTheThing("debug", null, null, "<b>Microbiology:</b> Disease with name \"[microbe_name]\" not found")
		return null

	proc/get_microbioeffect_from_path(var/effect_path)
		if (!ispath(effect_path))
			logTheThing("debug", null, null, "<b>Microbiology:</b> Attempt to find effect schematic with null path")
			return null
		if (!microbio_controls.effects.len)
			logTheThing("debug", null, null, "<b>Microbiology:</b> Cant find effect due to empty effect list")
			return null
		for (var/datum/microbe/A in microbio_controls.effects)
			if (effect_path == A.type)
				return A
		logTheThing("debug", null, null, "<b>Microbiology:</b> Effect \"[effect_path]\" not found")
		return null

	proc/get_microbioeffect_from_name(var/effect_name)
		if (!istext(effect_name))
			logTheThing("debug", null, null, "<b>Microbiology:</b> Attempt to find effect with non-string")
			return null
		if (!microbio_controls.effects.len)
			logTheThing("debug", null, null, "<b>Microbiology:</b> Cant find effect due to empty effect lists")
			return null
		for (var/datum/microbe/A in microbio_controls.effects)
			if (effect_name == A.name)
				return A
		logTheThing("debug", null, null, "<b>Microbiology:</b> Effect with name \"[effect_name]\" not found")
		return null

	proc/get_suppressant_from_path(var/suppressant_path)
		if (!ispath(suppressant_path))
			logTheThing("debug", null, null, "<b>Microbiology:</b> Attempt to find effect schematic with null path")
			return null
		if (!microbio_controls.cures.len)
			logTheThing("debug", null, null, "<b>Microbiology:</b> Cant find effect due to empty effect list")
			return null
		for (var/datum/suppressant/A in microbio_controls.cures)
			if (suppressant_path == A.type)
				return A
		logTheThing("debug", null, null, "<b>Microbiology:</b> Effect \"[suppressant_path]\" not found")
		return null

	proc/get_suppressant_from_name(var/suppressant_name)
		if (!istext(suppressant_name))
			logTheThing("debug", null, null, "<b>Microbiology:</b> Attempt to find effect with non-string")
			return null
		if (!microbio_controls.cures.len)
			logTheThing("debug", null, null, "<b>Microbiology:</b> Cant find effect due to empty effect lists")
			return null
		for (var/datum/suppressant/A in microbio_controls.cures)
			if (suppressant_name == A.name)
				return A
		logTheThing("debug", null, null, "<b>Microbiology:</b> Effect with name \"[suppressant_name]\" not found")
		return null
