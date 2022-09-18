/datum/ailment
	// all the vars that don't change/are defaults go in here - these will be in a central list for referencing
	var/name = "ailment"
	var/scantype = "Ailment"			// what type this shows up as on scanners
	var/cure = "Unknown"				// how do we get rid of it
	var/spread = "Unknown"				// how does it spread
	var/info = null						// info related to the thing to show on health scanners
	var/print_name = null				// printed name for health scanners
	var/max_stages = 0					// how many stages the disease has overall
	var/stage_prob = 5					// % chance per tick it'll advance a stage
	var/list/affected_species = list()	// what kind of mobs does this disease affect
	var/tmp/DNA = null					// no fuckin idea
	var/list/reagentcure = list()		// which reagents cure this disease...
	// these can be: a list of reagent strings - ex: list("reag1", "reag2") - in which case recureprob is used for them
	// or a list of strings with numbers associated with them - ex: list("reag1"=5, "reag2"=10) - which will use the associated number to determine % chance to cure
	// or a list of strings with lists associated with them - ex: list("reag1"=list(1,10), "reag2"=list(1,1)) - which will use both numbers to determine chance to cure, in case 1% chance isn't low enough for you!
	// or any combination of the above!
	var/recureprob = 8					// ...and how likely % they are per tick to do so (unless a number or list is associated with the reagent as above)
	var/temperature_cure = 406			// bodytemperature >= this will purge the infection
	var/detectability = 0				// detectors must >= this to pick up the disease
	var/resistance_prob = 0				// how likely this disease is to grant immunity once cured
	var/max_stacks = 1					// how many times at once you can have this ailment

	//MALADY STUFF ONLY
	var/min_advance_ticks = 0//delay the evolution of stuff like shock if it rolls badly for us
	var/tickcount = 0
	//IM SORRY

	proc/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
		if (QDELETED(affected_mob) || !D)
			return 1
		return 0

	proc/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/D)
		disposed = 1 // set to avoid bizarre interactions (such as surgerizing out a single disease multiple times)
		return

	proc/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/D)
		return

	// This is still subject to serious change. For now it's mostly a mockup.
	// Determines things that may happen during a surgery for different ailments
	// requiring a surgeon's intervention. Currently used for the parasites.
	// Returns a true value if the surgery was successful.
	proc/surgery(var/mob/living/surgeon, var/mob/living/affected_mob, var/datum/ailment_data/D)
		return 1

/datum/ailment/parasite
	name = "Parasite"
	scantype = "Parasite"
	cure = "Surgery"

/datum/ailment/disability
	name = "Disability"
	scantype = "Disability"
	cure = "Unknown"

/datum/ailment/disease
	name = "Disease"
	scantype = "Virus"
	cure = "Unknown"
	var/virulence = 100
	var/develop_resist = 0
	var/associated_reagent = null // associated reagent, duh


// IMPLEMENT PROPER CURE PROC

/datum/ailment_data
	// these will be the local thing on mobs that does all the effecting, and they store unique vars so we can still
	// have unique strains of disease and whatnot
	/////////////////////////////////////////////////////////////////////////
	var/datum/ailment/master = null			// we reference back to the ailment itself to get effects and static vars
	var/tmp/mob/living/affected_mob = null	// the poor sod suffering from the disease
	var/name = null							// an override - uses the base disease name if null - if not, it uses this
	var/scantype = null						// same as above but for scantype
	var/detectability = 0					// scans must >= this to detect the disease
	var/cure = "Unknown"					// how do we get rid of it
	var/spread = "Unknown" 					// how does this disease transmit itself around?
	var/info = null							// info related to the thing to show on health scanners
	var/stage = 1							// what stage the disease is currently at
	var/state = "Active"					// what is this disease currently doing
	var/stage_prob = 5						// how likely is this disease to advance to the next stage
	var/list/reagentcure = list()			// list of reagents that can cure this disease (see above for details on associations in this list)
	var/recureprob = 8						// probability per tick that the reagent will cure the disease
	var/temperature_cure = 406				// this temp or higher will cure the disease
	var/resistance_prob = 0					// how likely this disease is to grant immunity once cured

	disposing()
		if (affected_mob)
			if (affected_mob.ailments)
				affected_mob.ailments -= src
			affected_mob = null

		master = null
		reagentcure = null

		..()

	proc/stage_act(var/mult)
		if (!affected_mob || disposed)
			return 1

		if (!istype(master,/datum/ailment/))
			affected_mob.cure_disease(src)
			return 1

		if (stage > master.max_stages)
			stage = master.max_stages

		if (probmult(stage_prob) && stage < master.max_stages)
			stage++

		master.stage_act(affected_mob, src, mult)

		return 0

	proc/scan_info()
		var/text = "<span class='alert'><b>"
		if (istype(src.master,/datum/ailment/disease) || istype(src.master,/datum/ailment/malady))
			if (src.state == "Active" || src.state == "Acute")
				text += "[src.state] "
			else
				text += "<span class='notice'>[src.state] </span>"
		text += "[src.scantype ? src.scantype : src.master.scantype]:"

		text += " [src.name ? src.name : src.master.name]</b> <small>(Stage [src.stage]/[src.master.max_stages])<br>"
		if (src.info)
			text += "Info: [src.info]<br>"
		if (istype(src.master,/datum/ailment/disease) && src.spread)
			text += "Spread: [src.spread]<br>"
		if (src.cure == "Incurable")
			text += "Infection is incurable. Suggest quarantine measures."
		else if (src.cure == "Unknown")
			text += "No suggested remedies."
		else
			text += "Suggested Remedy: [src.cure]"
		text += "</small></span>"
		return text

	proc/on_infection()
		master.on_infection(affected_mob, src)
		return

	proc/surgery(var/mob/living/surgeon, var/mob/living/affected_mob)
		if (master && istype(master, /datum/ailment))
			return master.surgery(surgeon, affected_mob, src)
		return 1

/datum/ailment_data/disease
	var/virulence = 100    // how likely is this disease to spread
	var/develop_resist = 0 // can you develop a resistance to this?
	var/cycles = 0         // does this disease have a cyclical nature? if so, how many cycles have elapsed?
	var/list/strain_data = list()  // Used for Rhinovirus, basically arbitrary data storage

	stage_act(var/mult)
		if (!affected_mob || disposed)
			return 1

		if (!istype(master,/datum/ailment/))
			affected_mob.ailments -= src
			qdel(src)
			return 1

		if (stage > master.max_stages)
			stage = master.max_stages

		if (stage < 1) // if it's less than one just get rid of it, goddamn
			affected_mob.cure_disease(src)
			return 1

		var/advance_prob = stage_prob
		if (state == "Acute")
			advance_prob *= 2

		if (probmult(advance_prob))
			if (state == "Remissive")
				stage--
				if (stage < 1)
					affected_mob.cure_disease(src)
				return 1
			else if (stage < master.max_stages)
				stage++

		// Common cures
		if (cure != "Incurable")
			if (cure == "Sleep" && affected_mob.sleeping && probmult(33))
				state = "Remissive"
				return 1

			else if (cure == "Self-Curing" && probmult(5))
				state = "Remissive"
				return 1

			else if (cure == "Beatings" && affected_mob.get_brute_damage() >= 40)
				state = "Remissive"
				return 1

			else if (cure == "Burnings" && (affected_mob.get_burn_damage() >= 40 || affected_mob.getStatusDuration("burning")))
				state = "Remissive"
				return 1

			else if (affected_mob.bodytemperature >= temperature_cure)
				state = "Remissive"
				return 1

			if (reagentcure.len && affected_mob.reagents)
				for (var/current_id in affected_mob.reagents.reagent_list)
					if (reagentcure.Find(current_id))
						var/we_are_cured = 0
						var/reagcure_prob = reagentcure[current_id]
						if (isnum(reagcure_prob))
							if (probmult(reagcure_prob))
								we_are_cured = 1
						else if (probmult(recureprob))
							we_are_cured = 1
						if (we_are_cured)
							state = "Remissive"
							return 1

		if (state == "Asymptomatic" || state == "Dormant")
			return 1

		SPAWN(rand(1,5))
			// vary it up a bit so the processing doesnt look quite as transparent
			if (master)
				master.stage_act(affected_mob, src, mult)

		return 0

	disposing()
		strain_data = null
		..()

/datum/ailment_data/addiction
	var/associated_reagent = null
	var/last_reagent_dose = 0
	var/withdrawal_duration = 4800
	var/max_severity = "HIGH"

	New()
		..()
		master = get_disease_from_path(/datum/ailment/addiction)

/datum/ailment_data/parasite
	var/was_setup = 0
	var/surgery_prob = 50

	var/source = null // for headspiders
	var/stealth_asymptomatic = 0
	proc/setup()
		src.stage_prob = master.stage_prob
		src.cure = master.cure
		src.was_setup = 1

	stage_act(var/mult)
		if (!affected_mob)
			return

		if (!istype(master, /datum/ailment/))
			affected_mob.cure_disease(src)
			return

		if (istype(master, /datum/ailment/parasite/headspider) && !ismind(source))
			affected_mob.cure_disease(src)
			return

		if (!was_setup)
			src.setup()

		if (stage > master.max_stages)
			stage = master.max_stages

		if (probmult(stage_prob) && stage < master.max_stages)
			stage++


		if(!stealth_asymptomatic)
			master.stage_act(affected_mob,src,mult,source)

		return

/mob/living/proc/disease_resistance_check(var/ailment_path, var/ailment_name)
	if (!src)
		return 0

	var/resist_prob = 0

	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		resist_prob = H.get_disease_protection(ailment_path, ailment_name)
	else
		for (var/obj/item/C as anything in src.get_equipped_items())
			resist_prob += C.getProperty("viralprot")

	if (ispath(ailment_path) || istext(ailment_name))
		var/datum/ailment/A = null
		if (ailment_name)
			A = get_disease_from_name(ailment_name)
		else
			A = get_disease_from_path(ailment_path)

		if (!istype(A,/datum/ailment/))
			return 0

		if (src.resistances.Find(A.type))
			return 0

		if (A.affected_species.len)
			var/mob_type = null
			if (ismonkey(src))
				mob_type = "Monkey"
			else if (ishuman(src))
				var/mob/living/carbon/human/H = src
				if (H.mutantrace && !H.mutantrace.human_compatible)
					mob_type = capitalize(H.mutantrace.name)
				else
					mob_type = "Human"
			if (!A.affected_species.Find(mob_type))
				return 0

		if (isdead(src) && !istype(A,/datum/ailment/parasite))
			return 0

		if (istype(A,/datum/ailment/disease/))
			var/datum/ailment/disease/D = A
			resist_prob -= D.virulence

	if (prob(resist_prob))
		return 0
	else
		return 1 // you caught the virus! do you want to give the captured virus a nickname? virus has been recorded in lurgydex

/// Contract the specified disease.
/// @param ailment_path Path of the ailment to add. If both ailment_path and ailment_name are passed, this is used.
/// @param ailment_name Name of the ailment to add. This is not cosmetic; the ailment type is retrieved via this name.
/// @param strain Instance of the ailment to add. Used to transfer an existing ailment to a person (such as in the case of a diseased organ transplant)
/// @param bypass_resistance If disease resistance should be bypassed while adding a disease.
/mob/living/proc/contract_disease(var/ailment_path, var/ailment_name, var/datum/ailment_data/disease/strain, bypass_resistance = FALSE)
	if (!src)
		return null
	if (!ailment_path && !ailment_name && !(istype(strain,/datum/ailment_data/disease) || istype(strain,/datum/ailment_data/malady))) // maladies use strain to transfer specific instances of their selves via organ transplant/etc
		return null

	var/datum/ailment/A = null
	if (strain && istype(strain.master,/datum/ailment/))
		A = strain.master
	else if (ailment_name)
		A = get_disease_from_name(ailment_name)
	else
		A = get_disease_from_path(ailment_path)

	if (!istype(A,/datum/ailment/))
		// can't find shit, captain!
		return null

	var/count = 0
	for (var/datum/ailment_data/D in src.ailments)
		if (D.master == A)
			count++

	if (count >= A.max_stacks)
		return null

	if (ischangeling(src) || isvampire(src) || isvampiricthrall(src) || iszombie(src) || src.nodamage)
		//Vampires, thralls, zombies and changelings are immune to disease, as are the godmoded.
		//This is here rather than in the resistance check proc because otherwise certain things could bypass the
		//hard immunity these folks are supposed to have
		return null

	if (!bypass_resistance && !src.disease_resistance_check(null,A.name))
		return null

	if (istype(A, /datum/ailment/disease/))
		var/datum/ailment/disease/D = A
		var/datum/ailment_data/disease/AD = new /datum/ailment_data/disease
		if (istype(strain,/datum/ailment_data/disease/))
			if (strain.name)
				AD.name = strain.name
			else
				AD.name = D.name
			AD.stage_prob = strain.stage_prob
			AD.reagentcure = strain.reagentcure
			AD.recureprob = strain.recureprob
			AD.virulence = strain.virulence
			AD.detectability = strain.detectability
			AD.develop_resist = strain.develop_resist
			AD.cure = strain.cure
			AD.spread = strain.spread
			AD.info = strain.info
			AD.resistance_prob = strain.resistance_prob
			AD.temperature_cure = strain.temperature_cure
			AD.strain_data = strain.strain_data.Copy()
		else
			AD.name = D.name
			AD.stage_prob = D.stage_prob
			AD.reagentcure = D.reagentcure
			AD.recureprob = D.recureprob
			AD.virulence = D.virulence
			AD.detectability = D.detectability
			AD.develop_resist = D.develop_resist
			AD.cure = D.cure
			AD.spread = D.spread
			AD.info = D.info
			AD.resistance_prob = D.resistance_prob
			AD.temperature_cure = D.temperature_cure

		src.ailments += AD
		AD.master = A
		AD.affected_mob = src
		AD.on_infection()

		if (prob(5))
			AD.state = "Asymptomatic"
			// carrier - will spread it but won't suffer from it
		return AD

	else if (istype(A, /datum/ailment/malady))
		var/datum/ailment/malady/M = A
		var/datum/ailment_data/malady/AD = new /datum/ailment_data/malady
		if (istype(strain,/datum/ailment_data/malady))
			if (strain.name)
				AD.name = strain.name
			else
				AD.name = M.name
			AD.stage_prob = strain.stage_prob
			AD.reagentcure = strain.reagentcure
			AD.recureprob = strain.recureprob
			AD.detectability = strain.detectability
			AD.cure = strain.cure
			AD.spread = strain.spread
			AD.info = strain.info
			AD.resistance_prob = strain.resistance_prob
			AD.temperature_cure = strain.temperature_cure
		else
			AD.name = M.name
			AD.stage_prob = M.stage_prob
			AD.reagentcure = M.reagentcure
			AD.recureprob = M.recureprob
			AD.detectability = M.detectability
			AD.cure = M.cure
			AD.spread = M.spread
			AD.info = M.info
			AD.resistance_prob = M.resistance_prob
			AD.temperature_cure = M.temperature_cure
		src.ailments += AD
		AD.master = A
		AD.affected_mob = src
		AD.on_infection()
		return AD

	else if (istype(A, /datum/ailment/parasite))
		var/datum/ailment_data/parasite/AD = new /datum/ailment_data/parasite
		AD.name = A.name
		AD.stage_prob = A.stage_prob
		AD.cure = A.cure
		AD.reagentcure = A.reagentcure
		AD.recureprob = A.recureprob
		AD.master = A

		AD.master = A
		AD.affected_mob = src
		src.ailments += AD

		return AD

	else
		var/datum/ailment_data/AD = new /datum/ailment_data
		AD.name = A.name
		AD.stage_prob = A.stage_prob
		AD.cure = A.cure
		AD.reagentcure = A.reagentcure
		AD.recureprob = A.recureprob
		AD.master = A

		AD.master = A
		AD.affected_mob = src
		src.ailments += AD

		return AD

/mob/living/proc/viral_transmission(var/mob/living/target, var/spread_type, var/two_way = 0)
	if (!src || !target || !istext(spread_type))
		return

	if (!src.ailments || !length(src.ailments))
		return

	for (var/datum/ailment_data/disease/AD in src.ailments)
		if (AD.spread == spread_type)
			target.contract_disease(null,null,AD,0)

	if (two_way)
		for (var/datum/ailment_data/disease/AD in target.ailments)
			if (AD.spread == spread_type)
				src.contract_disease(null,null,AD,0)

	return

/mob/living/proc/cure_disease(var/datum/ailment_data/AD)
	if (!istype(AD) || !AD.master)
		return 0

	if (prob(AD.resistance_prob))
		src.resistances += AD.master.type
	if (src.ailments) //ZeWaka: Fix for null.ailments
		src.ailments -= AD
	AD.master.on_remove(src,AD)
	qdel(AD)
	return 1

/mob/living/proc/cure_disease_by_path(var/ailment_path)
	for (var/datum/ailment_data/AD in src.ailments)
		if (!AD.master)
			continue
		if (AD.master.type == ailment_path)
			if (prob(AD.resistance_prob))
				src.resistances += AD.master.type
			src.ailments -= AD
			AD.master.on_remove(src,AD)
			qdel(AD)
			return 1
	return 0

/mob/living/proc/find_ailment_by_type(var/ailment_path)
	if (!ispath(ailment_path))
		return null

	for (var/datum/ailment_data/AD in src.ailments)
		if (AD.master && AD.master.type == ailment_path)
			return AD

	return null

/mob/living/proc/find_ailment_by_name(var/ailment_name,var/base_ailments_only = 0)
	if (!istext(ailment_name))
		return null

	for (var/datum/ailment_data/AD in src.ailments)
		if (AD.name == ailment_name && !base_ailments_only)
			return AD
		if (AD.master && AD.master.name == ailment_name)
			return AD

	return null

/mob/living/proc/Virus_ShockCure(var/probcure = 50)
	src.changeStatus("defibbed", (12 * (probcure * 0.1)) SECONDS) // also makes it *slightly* harder to shitsec someone to death
	for (var/datum/ailment_data/V in src.ailments)
		if (V.cure == "Electric Shock" && prob(probcure))
			src.cure_disease(V)

/mob/living/proc/shock_cyberheart(var/shockInput)
	return

/mob/living/carbon/human/shock_cyberheart(var/shockInput)
	if (!src.organHolder)
		return
	var/numHigh = round((1 * shockInput) / 5)
	var/numMid = round((1 * shockInput) / 10)
	var/numLow = round((1 * shockInput) / 20)
	if (src.organHolder.heart && src.organHolder.heart.robotic && src.organHolder.heart.emagged && !src.organHolder.heart.broken)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "heart_shock", 5)
		src.add_stam_mod_max("heart_shock", 20)
		SPAWN(9000)
			REMOVE_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "heart_shock")
			src.remove_stam_mod_max("heart_shock")
		if (prob(numHigh))
			boutput(src, "<span class='alert'>Your cyberheart spasms violently!</span>")
			random_brute_damage(src, numHigh)
		if (prob(numHigh))
			boutput(src, "<span class='alert'>Your cyberheart shocks you painfully!</span>")
			random_burn_damage(src, numHigh)
		if (prob(numMid))
			boutput(src, "<span class='alert'>Your cyberheart lurches awkwardly!</span>")
			src.contract_disease(/datum/ailment/malady/heartfailure, null, null, 1)
		if (prob(numMid))
			boutput(src, "<span class='alert'><B>Your cyberheart stops beating!</B></span>")
			src.contract_disease(/datum/ailment/malady/flatline, null, null, 1)
		if (prob(numLow))
			boutput(src, "<span class='alert'><B>Your cyberheart shuts down!</B></span>")
			src.organHolder.heart.breakme()
			src.contract_disease(/datum/ailment/malady/flatline, null, null, 1)
	else if (src.organHolder.heart && src.organHolder.heart.robotic && !src.organHolder.heart.emagged && !src.organHolder.heart.broken)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "heart_shock", 1)
		src.add_stam_mod_max("heart_shock", 10)
		SPAWN(9000)
			REMOVE_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "heart_shock")
			src.remove_stam_mod_max("heart_shock")
		if (prob(numMid))
			boutput(src, "<span class='alert'>Your cyberheart spasms violently!</span>")
			random_brute_damage(src, numMid)
		if (prob(numMid))
			boutput(src, "<span class='alert'>Your cyberheart shocks you painfully!</span>")
			random_burn_damage(src, numMid)
		if (prob(numLow))
			boutput(src, "<span class='alert'>Your cyberheart lurches awkwardly!</span>")
			src.contract_disease(/datum/ailment/malady/heartfailure, null, null, 1)
