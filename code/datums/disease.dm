/datum/ailment
	// all the vars that don't change/are defaults go in here - these will be in a central list for referencing
	var/name = "ailment"
	var/scantype = "Ailment"			// what type this shows up as on scanners
	/// flags for determining how this ailment is cured
	var/cure_flags = CURE_UNKNOWN
	/// description for the cure that appears in medical scanners, etc. if null, presets based on the cure flags
	var/cure_desc = null
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
	var/can_be_asymptomatic = TRUE

	///If we need a specific ailment_data type
	var/datum/ailment_data/strain_type = /datum/ailment_data

	//MALstrainY STUFF ONLY
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

	///Return a default instance of our ailment_data type with all the vars copied in the awful way they have to be
	proc/setup_strain()
		RETURN_TYPE(/datum/ailment_data)
		var/datum/ailment_data/strain = new src.strain_type
		strain.name = src.name
		strain.stage_prob = src.stage_prob
		strain.reagentcure = src.reagentcure
		strain.recureprob = src.recureprob
		strain.detectability = src.detectability
		strain.cure_flags = src.cure_flags
		strain.cure_desc = src.cure_desc
		strain.spread = src.spread
		strain.info = src.info
		strain.resistance_prob = src.resistance_prob
		strain.temperature_cure = src.temperature_cure
		return strain

/datum/ailment/parasite
	name = "Parasite"
	scantype = "Parasite"
	cure_flags = CURE_SURGERY
	strain_type = /datum/ailment_data/parasite

/datum/ailment/disability
	name = "Disability"
	scantype = "Disability"
	cure_flags = CURE_UNKNOWN

/datum/ailment/disease
	name = "Disease"
	scantype = "Virus"
	cure_flags = CURE_UNKNOWN
	strain_type = /datum/ailment_data/disease
	var/virulence = 100
	var/develop_resist = 0
	var/associated_reagent = null // associated reagent, duh

	setup_strain()
		var/datum/ailment_data/disease/strain = ..()
		if (prob(5) && src.can_be_asymptomatic)
			strain.state = "Asymptomatic"
			// carrier - will spread it but won't suffer from it
		strain.virulence = src.virulence
		strain.develop_resist = src.develop_resist
		return strain

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
	/// flags for determining how this ailment is cured
	var/cure_flags = CURE_UNKNOWN
	/// description for the cure that appears in medical scanners, etc. if null, presets based on the cure flags
	var/cure_desc = null
	var/spread = "Unknown" 					// how does this disease transmit itself around?
	var/info = null							// info related to the thing to show on health scanners
	var/stage = 1							// what stage the disease is currently at
	var/state = "Active"					// what is this disease currently doing
	var/stage_prob = 5						// how likely is this disease to advance to the next stage
	var/list/reagentcure = list()			// list of reagents that can cure this disease (see above for details on associations in this list)
	var/recureprob = 8						// probability per tick that the reagent will cure the disease
	var/temperature_cure = 406				// this temp or higher will cure the disease
	var/resistance_prob = 0					// how likely this disease is to grant immunity once cured

	proc/copy_other(datum/ailment_data/other)
		SHOULD_CALL_PARENT(TRUE)
		src.master = other.master
		src.name = other.name
		src.scantype = other.scantype
		src.detectability = other.detectability
		src.cure_flags = other.cure_flags
		src.cure_desc = other.cure_desc
		src.spread = other.spread
		src.info = other.info
		//leaving out stage and state
		src.stage_prob = other.stage_prob
		src.reagentcure = other.reagentcure.Copy()
		src.recureprob = other.recureprob
		src.temperature_cure = other.temperature_cure
		src.resistance_prob = other.resistance_prob
		//phew

	disposing()
		if (affected_mob)
			if (affected_mob.ailments)
				affected_mob.ailments -= src
			if (!length(affected_mob.ailments))
				affected_mob.delStatus("active_ailments")
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
				text += SPAN_NOTICE("[src.state] ")
		text += "[src.scantype ? src.scantype : src.master.scantype]:"

		text += " [src.name ? src.name : src.master.name]</b> <small>(Stage [src.stage]/[src.master.max_stages])<br>"
		if (src.info)
			text += "Info: [src.info]<br>"
		if (istype(src.master,/datum/ailment/disease) && src.spread)
			text += "Spread: [src.spread]<br>"
		var/cure_method = "Suggested Remedy: "
		if (src.cure_flags & CURE_INCURABLE)
			cure_method = "Infection is incurable. Suggest quarantine measures."
		else if (src.cure_flags & CURE_UNKNOWN)
			cure_method = "No suggested remedies."
		else if (src.cure_flags & CURE_CUSTOM)
			cure_method += src.cure_desc
		else
			var/list/cures = list()
			if (src.cure_flags & CURE_TIME)
				cures += "Self-curing"
			if (src.cure_flags & CURE_ELEC_SHOCK)
				cures += "Electric shock"
			if (src.cure_flags & CURE_ANTIBIOTICS)
				cures += "Antibiotics"
			if (src.cure_flags & CURE_SURGERY)
				cures += "Surgery"
			if (src.cure_flags & CURE_SLEEP)
				cures += "Sleep"
			if (src.cure_flags & CURE_HEART_TRANSPLANT)
				cures += "Heart transplant"

			if (length(cures) == 1)
				cure_method += cures[1]
			else if (length(cures) == 2)
				cure_method += "[cures[1]] or [cures[2]]"
			else
				for (var/i in 1 to (length(cures) - 1))
					cure_method += cures[i] + ", "
				cure_method += " or [cures[length(cures)]]"
		text += cure_method
		text += "</small></span>"
		return text

	proc/on_infection()
		master.on_infection(affected_mob, src)
		if (!affected_mob.ailment_immune && (src in affected_mob.ailments))
			affected_mob.setStatus("active_ailments", INFINITE_STATUS)
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

	copy_other(datum/ailment_data/disease/other)
		..()
		src.virulence = other.virulence
		src.develop_resist = other.develop_resist
		src.strain_data = other.strain_data.Copy() //hopefully this is good enough?

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
		if (!(src.cure_flags & CURE_INCURABLE))
			if ((src.cure_flags & CURE_SLEEP) && affected_mob.sleeping && probmult(33))
				state = "Remissive"
				return 1

			else if ((src.cure_flags & CURE_TIME) && probmult(5))
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

	copy_other(datum/ailment_data/addiction/other)
		..()
		src.associated_reagent = other.associated_reagent
		src.withdrawal_duration = other.withdrawal_duration
		src.max_severity = other.max_severity

	New()
		..()
		master = get_disease_from_path(/datum/ailment/addiction)

/datum/ailment_data/parasite
	var/was_setup = 0
	var/surgery_prob = 50
	var/mob/living/critter/changeling/headspider/source = null // for headspiders
	var/stealth_asymptomatic = 0

	copy_other(datum/ailment_data/parasite/other)
		..()
		src.surgery_prob = other.surgery_prob
		src.stealth_asymptomatic = other.stealth_asymptomatic

	proc/setup()
		src.stage_prob = master.stage_prob
		src.cure_flags = master.cure_flags
		src.was_setup = 1

	stage_act(var/mult)
		if (!affected_mob)
			return

		if (!istype(master, /datum/ailment/))
			affected_mob.cure_disease(src)
			return

		if (istype(master, /datum/ailment/parasite/headspider) && !ismind(source?.mind))
			affected_mob.cure_disease(src)
			return

		if (!was_setup)
			src.setup()

		if (stage > master.max_stages)
			stage = master.max_stages

		if (probmult(stage_prob) && stage < master.max_stages)
			stage++


		if(!stealth_asymptomatic)
			master.stage_act(affected_mob,src,mult)

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
				if (!H.mutantrace.human_compatible)
					mob_type = capitalize(H.mutantrace.name)
				else
					mob_type = "Human"
			if (!A.affected_species.Find(mob_type))
				return 0

		if (isdead(src) && !istype(A,/datum/ailment/parasite))
			return 0

		if (istype(A,/datum/ailment/disease/))
			var/datum/ailment/disease/D = A
			resist_prob = 100 - (((100 - resist_prob) / 100) * D.virulence)

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

	var/datum/ailment/ailment = null
	if (strain && istype(strain.master,/datum/ailment/))
		ailment = strain.master
	else if (ailment_name)
		ailment = get_disease_from_name(ailment_name)
	else
		ailment = get_disease_from_path(ailment_path)

	if (!istype(ailment,/datum/ailment/))
		// can't find shit, captain!
		return null

	var/count = 0
	for (var/datum/ailment_data/D in src.ailments)
		if (D.master == ailment)
			count++

	if (count >= ailment.max_stacks)
		return null

	if (ischangeling(src) || isvampire(src) || isvampiricthrall(src) || iszombie(src) || src.nodamage)
		//Vampires, thralls, zombies and changelings are immune to disease, as are the godmoded.
		//This is here rather than in the resistance check proc because otherwise certain things could bypass the
		//hard immunity these folks are supposed to have
		return null

	if (!bypass_resistance && !src.disease_resistance_check(null,ailment.name))
		return null

	logTheThing(LOG_COMBAT, src, " gained the [ailment_name] ([ailment_path]) disease.")

	if (!strain) //no strain, set one up
		strain = ailment.setup_strain()

	src.ailments += strain
	strain.master = ailment
	strain.affected_mob = src
	strain.on_infection()

	return strain

/mob/living/proc/viral_transmission(var/mob/living/target, var/spread_type, var/two_way = 0)
	if (!src || !target || !istext(spread_type))
		return

	if (!src.ailments || !length(src.ailments))
		return

	for (var/datum/ailment_data/disease/strain in src.ailments)
		if (strain.spread == spread_type)
			var/datum/ailment_data/new_data = new strain.type()
			new_data.copy_other(strain)
			target.contract_disease(null,null,new_data,0)

	if (two_way)
		for (var/datum/ailment_data/disease/strain in target.ailments)
			if (strain.spread == spread_type)
				var/datum/ailment_data/new_data = new strain.type()
				new_data.copy_other(strain)
				src.contract_disease(null,null,new_data,0)

	return

/mob/living/proc/cure_disease(var/datum/ailment_data/strain)
	if (!istype(strain) || !strain.master)
		return 0

	if (prob(strain.resistance_prob))
		src.resistances += strain.master.type
	if (src.ailments) //ZeWaka: Fix for null.ailments
		src.ailments -= strain
	strain.master.on_remove(src,strain)
	qdel(strain)
	return 1

/mob/living/proc/cure_disease_by_path(var/ailment_path)
	for (var/datum/ailment_data/strain in src.ailments)
		if (!strain.master)
			continue
		if (strain.master.type == ailment_path)
			if (prob(strain.resistance_prob))
				src.resistances += strain.master.type
			src.ailments -= strain
			strain.master.on_remove(src,strain)
			qdel(strain)
			return 1
	return 0

/mob/living/proc/find_ailment_by_type(var/ailment_path)
	if (!ispath(ailment_path))
		return null

	for (var/datum/ailment_data/strain in src.ailments)
		if (strain.master && strain.master.type == ailment_path)
			return strain

	return null

/mob/living/proc/find_ailment_by_name(var/ailment_name,var/base_ailments_only = 0)
	if (!istext(ailment_name))
		return null

	for (var/datum/ailment_data/strain in src.ailments)
		if (strain.name == ailment_name && !base_ailments_only)
			return strain
		if (strain.master && strain.master.name == ailment_name)
			return strain

	return null

/mob/living/proc/Virus_ShockCure(var/probcure = 50)
	src.changeStatus("defibbed", (12 * (probcure * 0.1)) SECONDS) // also makes it *slightly* harder to shitsec someone to death
	for (var/datum/ailment_data/V in src.ailments)
		if ((V.cure_flags & CURE_ELEC_SHOCK) && prob(probcure))
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
			boutput(src, SPAN_ALERT("Your cyberheart spasms violently!"))
			random_brute_damage(src, numHigh)
		if (prob(numHigh))
			boutput(src, SPAN_ALERT("Your cyberheart shocks you painfully!"))
			random_burn_damage(src, numHigh)
		if (prob(numMid))
			boutput(src, SPAN_ALERT("Your cyberheart lurches awkwardly!"))
			src.contract_disease(/datum/ailment/malady/heartfailure, null, null, 1)
		if (prob(numMid))
			boutput(src, SPAN_ALERT("<B>Your cyberheart stops beating!</B>"))
			src.contract_disease(/datum/ailment/malady/flatline, null, null, 1)
		if (prob(numLow))
			boutput(src, SPAN_ALERT("<B>Your cyberheart shuts down!</B>"))
			src.organHolder.heart.breakme()
			src.contract_disease(/datum/ailment/malady/flatline, null, null, 1)
	else if (src.organHolder.heart && src.organHolder.heart.robotic && !src.organHolder.heart.emagged && !src.organHolder.heart.broken)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "heart_shock", 1)
		src.add_stam_mod_max("heart_shock", 10)
		SPAWN(9000)
			REMOVE_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "heart_shock")
			src.remove_stam_mod_max("heart_shock")
		if (prob(numMid))
			boutput(src, SPAN_ALERT("Your cyberheart spasms violently!"))
			random_brute_damage(src, numMid)
		if (prob(numMid))
			boutput(src, SPAN_ALERT("Your cyberheart shocks you painfully!"))
			random_burn_damage(src, numMid)
		if (prob(numLow))
			boutput(src, SPAN_ALERT("Your cyberheart lurches awkwardly!"))
			src.contract_disease(/datum/ailment/malady/heartfailure, null, null, 1)
