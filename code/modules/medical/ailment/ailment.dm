ABSTRACT_TYPE(/datum/ailment)
/// This is the singleton version of the ailment that defines the default behavior. Changing vars here affect *all* ailments of that type.
/datum/ailment
	/// Name of the ailment
	var/name = "ailment"
	/// The type of ailment that shows on scanners
	var/scantype = "Ailment"
	/// bitflags for determining how this ailment is cured
	var/cure_flags = CURE_UNKNOWN
	/// description for the cure that appears in medical scanners, etc. if null, presets based on the cure flags
	var/cure_desc = null
	/// How is this ailment spread?
	var/spread = AILMENT_SPREAD_UNKNOWN
	/// Miscelaneous additional information to show on health scanners
	var/info = null
	/// how many stages the disease has
	var/max_stages = 0
	/// Probability of advancing stage per tick
	var/stage_advance_prob = 5
	// what kind of mobs does this disease affect
	var/list/affected_species = list()

	/// A key-value list of reagents that cure this ailment, in the form of "reagent_id"=probability i.e. list("robotussin"=25,"spaceacillin"=100)
	var/list/reagentcure = list()

	/// If the ailment can be cured by high body temperature, the required temperature to cure the ailment
	var/high_temeprature_cure = null
	/// If the ailment can be cured by low body temperature, the required temperature to cure the ailment
	var/low_temeprature_cure = null

	/// Probability of getting resistance to the ailment on cure
	var/resistance_prob = 0

	// how many times at once you can have this ailment
	var/max_stacks = 1

	/// Can the ailment manifest as asymptomatic (you can spread it, but do not have the effects)
	var/can_be_asymptomatic = TRUE

	///If we need a specific ailment_data type
	var/datum/ailment_data/strain_type = /datum/ailment_data

	/// Minimum amount of time between stage advancement
	var/advance_time_minimum
	/// Maximum amount of time between stage advancement
	var/advance_time_maximum

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
		strain.stage_advance_prob = src.stage_advance_prob
		strain.reagentcure = src.reagentcure
		strain.cure_flags = src.cure_flags
		strain.cure_desc = src.cure_desc
		strain.spread = src.spread
		strain.info = src.info
		strain.resistance_prob = src.resistance_prob
		strain.high_temeprature_cure = src.high_temeprature_cure
		strain.low_temeprature_cure = src.low_temeprature_cure
		return strain

/// This is the actual ailment datum created that the mob holds onto
/datum/ailment_data
	var/datum/ailment/master = null			// we reference back to the ailment itself to get effects and static vars
	var/tmp/mob/living/affected_mob = null	// the poor sod suffering from the disease

	// copied from master ailment datum initially, but can be altered without messing up the parent datum

	/// Name of the ailment
	var/name = null
	/// The type of ailment that shows on scanners
	var/scantype = null
	/// bitflags for determining how this ailment is cured
	var/cure_flags = CURE_UNKNOWN
	/// description for the cure that appears in medical scanners, etc. if null, presets based on the cure flags
	var/cure_desc = null
	/// How is this ailment spread?
	var/spread = AILMENT_SPREAD_UNKNOWN
	/// Miscelaneous additional information to show on health scanners
	var/info = null
	/// If the ailment can be cured by high body temperature, the required temperature to cure the ailment
	var/high_temeprature_cure = null
	/// If the ailment can be cured by low body temperature, the required temperature to cure the ailment
	var/low_temeprature_cure = null
	/// A key-value list of reagents that cure this ailment, in the form of "reagent_id"=probability i.e. list("robotussin"=25,"spaceacillin"=100)
	var/list/reagentcure = list()
	/// Probability of getting resistance to the ailment on cure
	var/resistance_prob = 0

	// State only needed on the active ailment instance itself

	/// The current stage of the ailment
	var/stage = 1
	/// Current active state
	var/state = AILMENT_STATE_ACTIVE
	/// Probabilty of advancing to the next stage
	var/stage_advance_prob = 5
	/// time stamp since the last time the disease changed stages, or initial infection if stage 1
	var/last_stage_change_time

	proc/copy_other(datum/ailment_data/other)
		SHOULD_CALL_PARENT(TRUE)
		src.master = other.master
		src.name = other.name
		src.scantype = other.scantype
		src.cure_flags = other.cure_flags
		src.cure_desc = other.cure_desc
		src.spread = other.spread
		src.info = other.info
		//leaving out stage and state
		src.stage_advance_prob = other.stage_advance_prob
		src.reagentcure = other.reagentcure.Copy()
		src.high_temeprature_cure = other.high_temeprature_cure
		src.low_temeprature_cure = other.low_temeprature_cure
		src.resistance_prob = other.resistance_prob

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
		if (!src.affected_mob || src.disposed)
			return 1

		if (!istype(master, /datum/ailment/))
			src.affected_mob.cure_disease(src)
			return 1

		if (src.stage < 1)
			src.affected_mob.cure_disease(src)
			return 1

		if (src.stage > master.max_stages)
			src.stage = master.max_stages

		var/advance_prob = src.stage_advance_prob

		if (src.state == AILMENT_STATE_REMISSIVE)
			if (probmult(advance_prob))
				src.remiss_stage()
				return 1
		else
			if (src.state == AILMENT_STATE_ACUTE)
				advance_prob *= 2
			if (src.stage < master.max_stages)
				if (master.advance_time_minimum && TIME < (src.last_stage_change_time + master.advance_time_minimum))
					// no-op
				else if (master.advance_time_maximum && TIME > (src.last_stage_change_time + master.advance_time_maximum))
					src.advance_stage()
				else if (probmult(advance_prob))
					src.advance_stage()

		if (!(src.cure_flags & CURE_INCURABLE))
			if ((src.cure_flags & CURE_SLEEP) && affected_mob.sleeping && probmult(33))
				src.state = AILMENT_STATE_REMISSIVE
				return 1

			if ((src.cure_flags & CURE_TIME) && probmult(5))
				src.state = AILMENT_STATE_REMISSIVE
				return 1

			if ((src.cure_flags & CURE_HIGH_TEMPERATURE) && src.high_temeprature_cure && src.affected_mob.bodytemperature >= src.high_temeprature_cure)
				src.state = AILMENT_STATE_REMISSIVE
				return 1

			if ((src.cure_flags & CURE_LOW_TEMEPRATURE) && src.low_temeprature_cure && src.affected_mob.bodytemperature <= src.low_temeprature_cure)
				src.state = AILMENT_STATE_REMISSIVE
				return 1

			if ((src.cure_flags & CURE_MEDICINE) && src.reagentcure.len && affected_mob.reagents)
				for (var/current_id in affected_mob.reagents.reagent_list)
					if (reagentcure.Find(current_id))
						if (probmult(reagentcure[current_id]))
							src.state = AILMENT_STATE_REMISSIVE
							return 1

		if (src.state == AILMENT_STATE_DORMANT || src.state == AILMENT_STATE_ASYMPTOMATIC)
			return 1

		SPAWN(rand(1,5)) // vary so it's not exactly on tick borders; feels more natural
			master?.stage_act(affected_mob, src, mult)

		return 0

	proc/advance_stage()
		src.stage++
		src.last_stage_change_time = TIME

	proc/remiss_stage()
		src.stage--
		src.last_stage_change_time = TIME
		if (src.stage < 1)
			affected_mob.cure_disease(src)

	proc/scan_info()
		var/text = ""
		switch (src.state)
			if(AILMENT_STATE_ACUTE)
				text += SPAN_ALERT(SPAN_BOLD("Acute"))
			if(AILMENT_STATE_ACTIVE)
				text += SPAN_ALERT("Active")
			if(AILMENT_STATE_REMISSIVE)
				text += SPAN_NOTICE("Remissive")
			if(AILMENT_STATE_ASYMPTOMATIC)
				text += SPAN_NOTICE("Asymptomatic")
			if(AILMENT_STATE_DORMANT)
				text += SPAN_SUBTLE("Dormant")

		text += " [src.scantype ? src.scantype : src.master.scantype]:"

		text += " [SPAN_BOLD("[src.name ? src.name : src.master.name]")]"
		text += " <small>(Stage [src.stage]/[src.master.max_stages])<br>"
		if (src.info)
			text += "Info: [src.info]<br>"
		switch(src.spread)
			if (AILMENT_SPREAD_UNKNOWN)
				text += "Spread: Unknown<br>"
			if (AILMENT_SPREAD_AIRBORNE)
				text += "Spread: Airborne<br>"
			if (AILMENT_SPREAD_NONCONTAGIOUS)
				text += "Spread: Non-Contagious<br>"
			if (AILMENT_SPREAD_SALIVA)
				text += "Spread: Saliva<br>"
		var/cure_method = "Suggested Remedies: "
		if (src.cure_flags & CURE_INCURABLE)
			cure_method = "No known cure. Suggest quarantine measures."
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
			if (src.cure_flags & CURE_SLEEP)
				cures += "Sleep"
			if (src.cure_flags & CURE_SURGERY)
				cures += "Surgery"
			if (src.cure_flags & CURE_ORGAN_REPLACEMENT)
				cures += "Replacement of organ"
			if (src.cure_flags & CURE_HIGH_TEMPERATURE)
				cures += "High body temperature"
			if (src.cure_flags & CURE_LOW_TEMEPRATURE)
				cures += "Low body temperature"
			// more likely to have a cure_desc detailing their cures, so add them last
			if (src.cure_flags & CURE_MEDICINE)
				cures += "Antibiotics"

			cure_method += english_list(cures, "No suggested remedies.", " or ")
			if (src.cure_desc)
				cure_method += " ([src.cure_desc])"

		text += cure_method
		text += "</small>"
		return SPAN_ALERT(text)

	proc/on_infection()
		master.on_infection(affected_mob, src)
		if (!affected_mob.ailment_immune && (src in affected_mob.ailments))
			affected_mob.setStatus("active_ailments", INFINITE_STATUS)
		return

	proc/surgery(var/mob/living/surgeon, var/mob/living/affected_mob)
		if (master && istype(master, /datum/ailment))
			return master.surgery(surgeon, affected_mob, src)
		return 1

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
