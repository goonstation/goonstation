var/datum/geneticsResearchManager/genResearch = new()

/datum/geneticsResearchManager
	var/researchMaterial = 100
	var/max_material = 100
	var/max_save_slots = 0
	var/lock_breakers = 0
	var/cost_discount = 0 // decimal value for how much is taken off the cost
	var/time_discount = 0 // same but for time to research
	var/mut_research_cost = 20 // how much it costs to research mutations
	var/mut_research_time = 600
	var/mutations_researched = 0
	var/injector_cost = 30
	var/genebooth_cost = 30
	var/debug_mode = 0
	var/see_secret = 0
	var/emitter_radiation = 75
	var/equipment_cooldown_multiplier = 1
	var/list/datum/geneticsResearchEntry/currentResearch = new/list()
	var/list/researchTree = new/list()
	var/list/researchTreeTiered = new/list()
	var/list/combinationrecipes = new/list()
	var/list/obj/machinery/clonepod/clonepods = new/list()

	var/lastTick = 0

	proc/setup()
		researchTree = childrentypesof(/datum/geneticsResearchEntry) - /datum/geneticsResearchEntry/mutation

		for(var/entry in researchTree)
			researchTree[entry] = new entry()
			var/datum/geneticsResearchEntry/newEntry = researchTree[entry]

			var/tier = newEntry.tier

			if(researchTreeTiered["[tier]"] == null)
				researchTreeTiered["[tier]"] = new/list()

			researchTreeTiered["[tier]"] += newEntry

		combinationrecipes = childrentypesof(/datum/geneticsrecipe)
		for (var/X in combinationrecipes)
			var/datum/geneticsrecipe/GR = new X (src)
			combinationrecipes += GR
			combinationrecipes -= X
		//I could just change this quietly, but this.
		//THIS FUCKING ABOMINATION stays here as a memory of someone's shame.
		//researchTreeTiered = bubblesort(researchTreeTiered)
		sortList(researchTreeTiered, /proc/cmp_text_asc)
		return

	proc/isResearched(var/type)
		. = FALSE
		if(src.debug_mode)
			return TRUE
		if(type in researchTree)
			var/datum/geneticsResearchEntry/E = researchTree[type]
			if(E.isResearched == 1)
				. = TRUE

	proc/progress()
		//var/tickDiff = 0
		//if(!lastTick) lastTick = world.time
		//tickDiff = (world.time - lastTick)
		lastTick = world.time

		if(researchMaterial < max_material)
			 //This is only temporary to regenerate points while this isnt finished yet.
			researchMaterial += checkMaterialGenerationRate()

		for(var/datum/geneticsResearchEntry/entry as anything in currentResearch)
			entry.onTick()
			if(entry.finishTime <= lastTick)
				entry.isResearched = 1
				entry.onFinish()
				currentResearch.Remove(entry)
		return

	proc/addResearch(var/datum/D)
		if(istype(D, /datum/bioEffect))
			var/datum/geneticsResearchEntry/mutation/M = new()

			var/final_cost = src.mut_research_cost
			if (genResearch.cost_discount)
				final_cost -= round(final_cost * genResearch.cost_discount)

			if(!src.debug_mode)
				if(final_cost > researchMaterial)
					return 0
				else
					researchMaterial -= final_cost

			var/datum/bioEffect/BE = D
			M.mutation_id = BE.id
			M.name = "Mutation Research"
			M.desc = "Analysis of a potential mutation."

			M.researchTime = src.mut_research_time
			var/research_time = M.researchTime
			if (genResearch.time_discount)
				research_time *= (1 - genResearch.time_discount)
			if (src.debug_mode)
				research_time = 0
			M.finishTime = world.time + research_time

			currentResearch.Add(M)
			M.isResearched = -1
			M.onBegin()
			return 1

		else if(istype(D, /datum/geneticsResearchEntry))
			var/datum/geneticsResearchEntry/R = D

			var/final_cost = R.researchCost
			if (genResearch.cost_discount)
				final_cost -= round(final_cost * genResearch.cost_discount)

			if(!src.debug_mode)
				if(final_cost > researchMaterial || R.isResearched)
					return 0
				else
					researchMaterial -= final_cost

			var/research_time = R.researchTime
			if (genResearch.time_discount)
				research_time *= (1 - genResearch.time_discount)
			if (src.debug_mode)
				research_time = 0
			R.finishTime = world.time + research_time

			currentResearch.Add(D)
			R.isResearched = -1
			R.onBegin()
			return 1
		return 0


	proc/checkClonepodBonus()
		. = 0
		for(var/obj/machinery/clonepod/CP as anything in src.clonepods)
			if(CP.operating_nominally())
				.++

	proc/checkMaterialGenerationRate()
		. = 1 + min(checkClonepodBonus(), 2)
		if( ( . + researchMaterial) >= max_material)
			. = max_material - researchMaterial

	proc/checkCooldownBonus()
		return genResearch.equipment_cooldown_multiplier - (min(genResearch.checkClonepodBonus(), 2) * 0.05)

/datum/geneticsResearchEntry
	var/name = "HERF" //Name of the research entry
	var/desc = "DERF" //Description
	var/finishTime = 0 //Internal. No need to mess with this.
	var/researchTime = 0 //How long this takes to research in 1/10ths of a second.
	var/tier = 0 //Tier of research. Tier 0 does not show up in the available research - this is intentional. It is used for "hidden" research.
	var/list/requiredResearch = list() // You need to research everything in this list before this one will show up
	var/list/requiredMutRes = list() // Need to have researched these mutations first - list of requisite IDs.
	var/requiredTotalMutRes = 0 // Need to have researched this many mutations total
	var/isResearched = 0 //Has this been researched? I.e. are we done with it? 0 = not researched, 1 = researched, -1 = currently researching.
	var/researchCost = 10 //Cost in research materials for this entry.
	var/hidden = 0 // Is this one accessible by players?
	var/htmlIcon = null

	// Note: Parent should be called LAST to ensure any updates are forwarded as static data where applicable
	proc/onFinish()
		SHOULD_CALL_PARENT(TRUE)
		for_by_tcl(computer, /obj/machinery/computer/genetics)
			for (var/datum/tgui/ui as anything in tgui_process.get_uis(computer))
				computer.update_static_data(null, ui)

	proc/onBegin()
		return

	proc/onTick()
		return

	proc/meetsRequirements()
		if(src.isResearched == 1 || src.isResearched == -1)
			return 0

		if(genResearch.debug_mode)
			return 1

		if(src.hidden)
			return 0

		for(var/X as anything in src.requiredResearch) // Have we got the prerequisite researches?
			if(!genResearch.isResearched(X))
				return 0

		var/datum/bioEffect/BE
		for (var/X as anything in src.requiredMutRes)
			BE = GetBioeffectFromGlobalListByID(X)
			if (!BE)
				return 0
			if (BE.research_level < EFFECT_RESEARCH_DONE)
				return 0

		if (genResearch.mutations_researched < src.requiredTotalMutRes)
			// Do we have the neccecary # of muts researched?
			return 0

		return 1

/datum/geneticsResearchEntry/mutation
	var/mutation_id = null
	var/datum/bioEffect/global_instance = null

	onBegin()
		global_instance = GetBioeffectFromGlobalListByID(mutation_id)
		global_instance.research_finish_time = world.time + researchTime
		global_instance.research_level = max(global_instance.research_level, EFFECT_RESEARCH_IN_PROGRESS)
		return

	onFinish()
		if (global_instance.research_level < EFFECT_RESEARCH_DONE)
			global_instance.research_level = max(global_instance.research_level, EFFECT_RESEARCH_DONE)
			genResearch.mutations_researched++
		..()

// TIER ONE
// researchTime = 600 is one minute, keep that in mind

/datum/geneticsResearchEntry/rademitter
	name = "Radiation Emitters"
	desc = {"Installs Radiation Emitters in the scanner.<br>
	This allows you to reroll the pool of potential mutations of a person.<br>
	Obviously, this will cause severe radiation poisoning that will have to be treated."}
	researchTime = 900
	researchCost = 80
	tier = 1

/datum/geneticsResearchEntry/checker
	name = "Gene Sequence Checker"
	desc = "Installs analysers in the scanner that allow users to check how many base pairs are stable."
	researchTime = 900
	researchCost = 50
	tier = 1

/datum/geneticsResearchEntry/improvedmutres
	name = "Advanced Mutation Research"
	desc = "Halves the base cost and time of researching a mutation, and enables the ability to see secret mutations."
	researchTime = 900
	researchCost = 50
	requiredTotalMutRes = 20
	tier = 1

	onFinish()
		genResearch.mut_research_cost = 10
		genResearch.mut_research_time = 450
		genResearch.see_secret = 1
		..()

/datum/geneticsResearchEntry/improvedcooldowns
	name = "Biotic Cooling Mechanisms"
	desc = "Applies genetic research to halve the cooldown times for all equipment."
	researchTime = 900
	researchCost = 150
	requiredMutRes = list("fire_resist", "cold_resist", "resist_electric")
	tier = 1

	onFinish()
		genResearch.equipment_cooldown_multiplier -= 0.5
		..()

/datum/geneticsResearchEntry/genebooth
	name = "Gene Booth"
	desc = "Allows you to sell unlocked mutations through a public Gene Booth."
	researchTime = 600
	researchCost = 50
	tier = 1

// Rewards for unlocking Complex DNA

/datum/geneticsResearchEntry/fqresearch_complex
	name = "Complex DNA Research Efficiency"
	desc = "Research costs and time decrease by 15%."
	researchTime = 1200
	researchCost = 50
	tier = 1
	requiredMutRes = list("early_secret_access")

	onFinish()
		genResearch.cost_discount += 0.15
		genResearch.time_discount += 0.15
		..()

/datum/geneticsResearchEntry/complex_saver
	name = "Complex DNA Mutation Storage"
	desc = "Adds five saving slots for storing mutations."
	researchTime = 1200
	researchCost = 50
	tier = 1
	requiredMutRes = list("early_secret_access")

	onFinish()
		genResearch.max_save_slots += 5
		..()

/datum/geneticsResearchEntry/complex_max_materials
	name = "Complex Material Storage"
	desc = "Increases maximum materials storage by 50."
	researchTime = 1200
	researchCost = 50
	tier = 1
	requiredMutRes = list("early_secret_access")

	onFinish()
		genResearch.max_material += 50
		..()

// TIER TWO

/datum/geneticsResearchEntry/reclaimer
	name = "DNA Reclaimer"
	desc = "Allows unwanted genes to be converted into research materials. It has a two minute cooldown and has a chance to fail depending on what gene is being reclaimed."
	researchTime = 1200
	researchCost = 100
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/checker)

/datum/geneticsResearchEntry/injector
	name = "DNA Injectors"
	desc = "Allows the manufacture of syringes that can insert researched genes into other subjects. Syringes cost 40 materials to manufacture."
	researchTime = 1200
	researchCost = 120
	requiredTotalMutRes = 20
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/checker)

/datum/geneticsResearchEntry/rad_dampers
	name = "Radiation Dampeners"
	desc = "Reduces the amount of harmful radiation caused by Radiation Emitters."
	researchTime = 1800
	researchCost = 80
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/rademitter)

	onFinish()
		genResearch.emitter_radiation -= 45
		..()

/datum/geneticsResearchEntry/rad_coolant
	name = "Emitter Coolant System"
	desc = "Reduces the amount of time required for Radiation Emitters to cool down."
	researchTime = 1800
	researchCost = 120
	tier = 2
	requiredResearch = list(/datum/geneticsResearchEntry/rademitter)

// TIER THREE

/datum/geneticsResearchEntry/saver
	name = "Mutation Storage"
	desc = "Allows up to three active researched mutations to be removed from subjects and stored in genetics equipment."
	researchTime = 3000
	researchCost = 100
	tier = 3
	requiredResearch = list(/datum/geneticsResearchEntry/reclaimer)

	onFinish()
		genResearch.max_save_slots += 3
		..()

/datum/geneticsResearchEntry/rad_precision
	name = "Precision Radiation Emitters"
	desc = {"Upgrades the Radiation Emitters in the scanner so they can target single genes at a time.<br>
	The gene must have been researched first. Doing this has a shorter cooldown than regular emitters."}
	researchTime = 3000
	researchCost = 150
	tier = 3
	requiredResearch = list(/datum/geneticsResearchEntry/rad_dampers,/datum/geneticsResearchEntry/rad_coolant)

/datum/geneticsResearchEntry/extra_max_materials
	name = "Improved Material Storage"
	desc = "Increases maximum materials storage by 50."
	researchTime = 3000
	researchCost = 125
	tier = 3
	requiredResearch = list(/datum/geneticsResearchEntry/reclaimer)

	onFinish()
		genResearch.max_material += 50
		..()

/datum/geneticsResearchEntry/bio_rad_dampers
	name = "Biotic Radiation Dampeners"
	desc = "Applies genetic research to completely eliminate all harmful radiation from the emitters."
	researchTime = 2500
	researchCost = 100
	tier = 3
	requiredResearch = list(/datum/geneticsResearchEntry/rad_dampers)
	requiredMutRes = list("rad_resist","radioactive")

	onFinish()
		genResearch.emitter_radiation -= 30
		..()

// TIER FOUR

/datum/geneticsResearchEntry/saver_slots
	name = "Expanded Mutation Storage"
	desc = "Adds two additional saving slots for mutations."
	researchTime = 4500
	researchCost = 120
	tier = 4
	requiredResearch = list(/datum/geneticsResearchEntry/saver)

	onFinish()
		genResearch.max_save_slots += 2
		..()

///////////////////////////////////
// Things related to DNA samples //
///////////////////////////////////

/proc/create_new_dna_sample_file(var/mob/living/carbon/C)
	if (!istype(C))
		return null
	if (!istype(C.bioHolder))
		return null

	var/datum/computer/file/genetics_scan/scan = new /datum/computer/file/genetics_scan()
	scan.subject_name = C.real_name
	scan.subject_uID = C.bioHolder.Uid
	scan.subject_stability = C.bioHolder.genetic_stability
	scan.scanned_at = TIME

	scan.dna_active = list()
	scan.dna_pool = list()

	for (var/bioEffectId in C.bioHolder.effects)
		var/datum/bioEffect/BE = C.bioHolder.GetEffect(bioEffectId)
		var/datum/bioEffect/scannedBE = new BE.type(scan)
		// copy necessary information
		// currently only name, for chromosome presence
		scannedBE.name = BE.name
		scan.dna_active += scannedBE
	for (var/bioEffectId in C.bioHolder.effectPool)
		var/datum/bioEffect/BE = C.bioHolder.GetEffectFromPool(bioEffectId)
		var/datum/bioEffect/scannedBE = new BE.type(scan)
		scannedBE.dnaBlocks.blockList = BE.dnaBlocks.blockList
		scannedBE.dnaBlocks.blockListCurr = BE.dnaBlocks.blockListCurr
		scan.dna_pool += scannedBE

	return scan
