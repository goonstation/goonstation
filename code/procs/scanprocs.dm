

/proc/scan_health(var/mob/M as mob, var/verbose_reagent_info = 0, var/disease_detection = 1, var/organ_scan = 0, var/visible = 0, syndicate = FALSE,
	admin = FALSE)
	if (!M)
		return SPAN_ALERT("ERROR: NO SUBJECT DETECTED")

	if (issilicon(M))
		return SPAN_ALERT("ERROR: INVALID DATA FROM SUBJECT")

	if(visible)
		animate_scanning(M, "#0AEFEF")

	var/death_state = M.stat
	if (M.bioHolder && M.bioHolder.HasEffect("dead_scan"))
		death_state = 2

	var/health_percent = round(100 * M.health / (M.max_health||1))

	var/colored_health
	if(M.max_health <= 0)
		colored_health = SPAN_ALERT("???")
	if (health_percent >= 51 && health_percent <= 100)
		colored_health = "<span style='color:#138015'>[health_percent]</span>"
	else if (health_percent >= 1 && health_percent <= 50)
		colored_health = "<span style='color:#CC7A1D'>[health_percent]</span>"
	else colored_health = SPAN_ALERT("[health_percent]")

	var/optimal_temp = M.base_body_temp
	var/body_temp_C = TO_CELSIUS(M.bodytemperature)
	body_temp_C = round(body_temp_C, body_temp_C < 1000 ? 0.01 : 1)
	var/body_temp_F = TO_FAHRENHEIT(M.bodytemperature)
	body_temp_F = round(body_temp_F, body_temp_F < 1000 ? 0.01 : 1)
	var/body_temp = "[body_temp_C]&deg;C ([body_temp_F]&deg;F)"
	var/colored_temp = ""
	if (M.bodytemperature >= (optimal_temp + 60))
		colored_temp = SPAN_ALERT("[body_temp]")
	else if (M.bodytemperature >= (optimal_temp + 30))
		colored_temp = "<span style='color:#CC7A1D'>[body_temp]</span>"
	else if (M.bodytemperature <= (optimal_temp - 60))
		colored_temp = SPAN_NOTICE("[body_temp]")
	else if (M.bodytemperature <= (optimal_temp - 30))
		colored_temp = "<span style='color:#1F75D1'>[body_temp]</span>"
	else
		colored_temp = "[body_temp]"

	var/oxy = round(M.get_oxygen_deprivation(), 0.01)
	var/tox = round(M.get_toxin_damage(), 0.01)
	var/burn = round(M.get_burn_damage(), 0.01)
	var/brute = round(M.get_brute_damage(), 0.01)

	// contained here in order to change them easier
	var/oxy_font = "<span style='color:#1F75D1'>"
	var/tox_font = "<span style='color:#138015'>"
	var/burn_font = "<span style='color:#CC7A1D'>"
	var/brute_font = "<span style='color:#E60E4E'>"

	var/oxy_data = "[oxy > 50 ? "<span class='alert'>" : "[oxy_font]"][oxy]</span>"
	var/tox_data = "[tox > 50 ? "<span class='alert'>" : "[tox_font]"][tox]</span>"
	var/burn_data = "[burn > 50 ? "<span class='alert'>" : "[burn_font]"][burn]</span>"
	var/brute_data = "[brute > 50 ? "<span class='alert'>" : "[brute_font]"][brute]</span>"

	var/rad_data = null
	var/nrad_data = null
	var/blood_data = null
	var/brain_data = null
	// var/heart_data = null		//Moving this to organ_data for now. -kyle
	var/reagent_data = null
	var/disease_data = null
	var/implant_data = null
	var/organ_data = null
	var/interesting_data = null

	var/isliving = isliving(M)
	var/ishuman = ishuman(M)

	if (isliving)
		var/mob/living/L = M

		if (blood_system && L.can_bleed)
			var/bp_col
			switch (L.blood_pressure["total"])
				if (-INFINITY to 299) // very low (70/50)
					bp_col = "red"
				if (300 to 414) // low (100/65)
					bp_col = "#CC7A1D"
				if (415 to 584) // normal (120/80)
					bp_col = "#138015"
				if (585 to 665) // high (140/90)
					bp_col = "#CC7A1D"
				if (666 to INFINITY) // very high (160/100)
					bp_col = "red"
			if (isdead(L))
				blood_data = "Blood Pressure: [SPAN_ALERT("NO PULSE")]"
			else
				blood_data = "Blood Pressure: <span style='color:[bp_col]'>[L.blood_pressure["rendered"]] ([L.blood_pressure["status"]])</span>"
			if (verbose_reagent_info)
				if (isvampire(L)) // Added a pair of vampire checks here (Convair880).
					blood_data += " | Blood level: <span style='color:#138015'>500 units</span>"
				else
					blood_data += " | Blood level: <span style='color:[bp_col]'>[L.blood_pressure["total"]] unit[s_es(L.blood_pressure["total"])]</span>"
					if (L.bleeding)
						blood_data += " | Blood loss: [SPAN_ALERT("[L.bleeding] unit[s_es(L.bleeding)]")]"
			else if (!isvampire(L))
				switch (L.bleeding)
					if (1 to 3)
						blood_data += " | [SPAN_ALERT("<B>Minor bleeding wounds detected</B>")]"
					if (4 to 6)
						blood_data += " | [SPAN_ALERT("<B>Bleeding wounds detected</B>")]"
					if (7 to INFINITY)
						blood_data += " | [SPAN_ALERT("<B>Major bleeding wounds detected</B>")]"


			var/bad_stuff = 0
			if (length(L.implant))
				var/list/implant_list = list()
				for (var/obj/item/implant/I in L.implant)
					if (istype(I, /obj/item/implant/projectile))
						bad_stuff++
						continue
					if (I.scan_category == IMPLANT_SCAN_CATEGORY_NOT_SHOWN)
						continue
					if (I.scan_category != IMPLANT_SCAN_CATEGORY_SYNDICATE)
						if (I.scan_category != IMPLANT_SCAN_CATEGORY_UNKNOWN)
							implant_list[capitalize(I.name)]++
						else
							implant_list["Unknown implant"]++
					else if (syndicate)
						implant_list[capitalize(I.name)]++

				if (length(implant_list))
					implant_data = "<span style='color:#2770BF'><b>Implants detected:</b></span>"
					for (var/implant in implant_list)
						implant_data += "<br><span style='color:#2770BF'>[implant_list[implant]]x [implant]</span>"

			if (ishuman)
				var/mob/living/carbon/human/H = L
				if(H.chest_item != null) // If item is in chest, add one
					bad_stuff ++
				if (bad_stuff)
					blood_data += " | [SPAN_ALERT("<B>Foreign object[s_es(bad_stuff)] detected</B>")]"
				if(H.chest_item != null) // State that large foreign object is located in chest
					blood_data += " | [SPAN_ALERT("<B>Sizable foreign object located below sternum</B>")]"
			else
				if (bad_stuff)
					blood_data += " | [SPAN_ALERT("<B>Foreign object[s_es(bad_stuff)] detected</B>")]"

		if (ishuman)
			var/mob/living/carbon/human/H = M

			if (H.get_organ("brain"))
				if (H.get_brain_damage() >= BRAIN_DAMAGE_LETHAL)
					brain_data = SPAN_ALERT("Subject is braindead.")
				else if (H.get_brain_damage() >= BRAIN_DAMAGE_SEVERE)
					brain_data = SPAN_ALERT("Severe brain damage detected. Subject unable to function.")
				else if (H.get_brain_damage() >= BRAIN_DAMAGE_MAJOR)
					brain_data = SPAN_ALERT("Major brain damage detected. Impaired functioning present.")
				else if (H.get_brain_damage() >= BRAIN_DAMAGE_MODERATE)
					brain_data = SPAN_ALERT("Moderate brain damage detected. Subject unable to function well.")
				else if (H.get_brain_damage() >= BRAIN_DAMAGE_MINOR)
					brain_data = SPAN_ALERT("Minor brain damage detected.")
				else if (H.get_brain_damage() > 0)
					brain_data = SPAN_ALERT("Brain synapse function may be disrupted.")
			else
				brain_data = SPAN_ALERT("Subject has no brain.")

			// if (!H.get_organ("heart"))
			// 	heart_data = SPAN_ALERT("Subject has no heart.")
			if (organ_scan)
				var/organ_data1 = null
				var/obfuscate = (disease_detection != 255 ? 1 : 0)		//this is so admin check_health verb see exact numbs, scanners don't. Can remove, not exactly necessary, but thought they might want it.

				organ_data1 += organ_health_scan("heart", H, obfuscate)
				// organ_data1 += organ_health_scan("brain", H, obfuscate) //Might want, might not. will be slightly more accurate than current brain damage scan

				organ_data1 += organ_health_scan("left_eye", H, obfuscate)
				organ_data1 += organ_health_scan("right_eye", H, obfuscate)

				organ_data1 += organ_health_scan("left_lung", H, obfuscate)
				organ_data1 += organ_health_scan("right_lung", H, obfuscate)

				organ_data1 += organ_health_scan("left_kidney", H, obfuscate)
				organ_data1 += organ_health_scan("right_kidney", H, obfuscate)
				organ_data1 += organ_health_scan("liver", H, obfuscate)
				organ_data1 += organ_health_scan("stomach", H, obfuscate)
				organ_data1 += organ_health_scan("intestines", H, obfuscate)
				organ_data1 += organ_health_scan("spleen", H, obfuscate)
				organ_data1 += organ_health_scan("pancreas", H, obfuscate)
				organ_data1 += organ_health_scan("appendix", H, obfuscate)
				if(H.organHolder.tail || H.mob_flags & SHOULD_HAVE_A_TAIL)
					organ_data1 += organ_health_scan("tail", H, obfuscate)

				//Don't give organ readings for Vamps.
				if (organ_data1 && !isvampire(H))
					organ_data = "<span style='color:purple'><b>Internal Injuries:</b></span>"
					organ_data += organ_data1
				else
					organ_data = "<span style='color:purple'><b>Scans indicate organs are in perfect health.</b></span>"
				//Joke in case there is no organHolder
				if (!H.organHolder)
					organ_data = SPAN_ALERT("Subject has no organs. Veeeerrrry curious.")
			else if (H.robotic_organs > 0)
				organ_data = "<span style='color:purple'><b>Unknown augmented organs detected.</b></span>"


	var/datum/statusEffect/simpledot/radiation/R = M.hasStatus("radiation")
	if (R?.stage)
		rad_data = "&emsp;[SPAN_ALERT("The subject is [R.howMuch]irradiated. Dose: [M.radiation_dose] Sv")]"

	for (var/datum/ailment_data/A in M.ailments)
		if (disease_detection >= A.detectability)
			disease_data += "<br>[A.scan_info()]"

	if (M.reagents)
		if (verbose_reagent_info)
			reagent_data = scan_reagents(M, show_temp = FALSE, medical = TRUE, admin = admin)
		else
			var/ephe_amt = M.reagents:get_reagent_amount("ephedrine")
			var/epi_amt = M.reagents:get_reagent_amount("epinephrine")
			var/atro_amt = M.reagents:get_reagent_amount("atropine")
			var/total_amt = ephe_amt + epi_amt + atro_amt
			if (total_amt)
				reagent_data = SPAN_NOTICE("Bloodstream Analysis located [total_amt] units of rejuvenation chemicals.")

	if (!ishuman) // vOv
		if (M.get_brain_damage() >= BRAIN_DAMAGE_LETHAL)
			brain_data = SPAN_ALERT("Subject is braindead.")
		else if (M.get_brain_damage() >= BRAIN_DAMAGE_MAJOR)
			brain_data = SPAN_ALERT("Severe brain damage detected. Subject likely unable to function well.")
		else if (M.get_brain_damage() >= BRAIN_DAMAGE_MINOR)
			brain_data = SPAN_ALERT("Significant brain damage detected. Subject may have had a concussion.")

	if (M.interesting)
		interesting_data += "<br>[SPAN_NOTICE("[M.interesting]")]"

	var/data = "--------------------------------<br>\
	Analyzing Results for [SPAN_NOTICE("[M]")]:<br>\
	&emsp; Overall Status: [death_state > 1 ? SPAN_ALERT("DEAD") : "[colored_health]% healthy"]<br>\
	&emsp; Damage Specifics: [oxy_data] - [tox_data] - [burn_data] - [brute_data]<br>\
	&emsp; Key: [oxy_font]Suffocation</span>/[tox_font]Toxin</span>/[burn_font]Burns</span>/[brute_font]Brute</span><br>\
	Body Temperature: [colored_temp]\
	[rad_data ? "<br>[rad_data]" : null]\
	[nrad_data ? "<br>[nrad_data]" : null]\
	[blood_data ? "<br>[blood_data]" : null]\
	[brain_data ? "<br>[brain_data]" : null]\
	[implant_data ? "<br>[implant_data]" : null]\
	[organ_data ? "<br>[organ_data]" : null]\
	[reagent_data ? "<br>[reagent_data]" : null]\
	[disease_data ? "[disease_data]" : null]\
	[interesting_data ? "<br><i>Historical analysis:</i>[SPAN_NOTICE(" [interesting_data]")]" : null]\
	"

	return data

	//KYLE-NOTE- Maybe use get_organ here. Didn't exist in 2016 when I wrote this.
//takes string input, for name in organholder.organ_list and checks if the organholder has anything
//obfuscate, if true then don't show the exact organ health amount. Minor damage, moderate damage, severe damage, critical damage
/proc/organ_health_scan(var/input, var/mob/living/carbon/human/H, var/obfuscate = 0)
	var/obj/item/organ/O = H.organHolder?.organ_list[input]
	if (istype(O))
		var/damage = O.get_damage()
		if (obfuscate)
			return obfuscate_organ_health(O)
		else
			if (damage > 0)
				return "<br><span style='color:[damage >= 65 ? "red" : "purple"]'><b>[input]</b> - [O.get_damage()]</span>"
			else
				return null

	else
		return "<br>[SPAN_ALERT("<b>[input]</b> - missing!")]"

//Using input here because it get's the organs name in an easy and clear way. using name or organ_name in obj/item/organ is not any better really
/proc/obfuscate_organ_health(var/obj/item/organ/O)
	if (!O)
		return null
	var/list/ret = list()
	var/damage = O.get_damage()
	if (damage >= O.max_damage)
		ret += "<br>[SPAN_ALERT("<b>[O.name]</b> - Dead")]"
	else if (damage >= O.max_damage*0.9)
		ret += "<br>[SPAN_ALERT("<b>[O.name]</b> - Critical")]"
	else if (damage >= O.max_damage*0.65)
		ret += "<br>[SPAN_ALERT("<b>[O.name]</b> - Significant")]"
	else if (damage >= O.max_damage*0.3)
		ret += "<br><span style='color:purple'><b>[O.name]</b> - Moderate</span>"
	else if (damage > 0)
		ret += "<br><span style='color:purple'><b>[O.name]</b> - Minor</span>"
	else if (O.robotic || O.unusual)
		ret += "<br><span style='color:purple'><b>[O.name]</b></span>"
	if (O.robotic)
		ret += "<span style='color:purple'> - Robotic organ detected</span>"
	else if (O.unusual)
		ret += "<span style='color:purple'> - Unknown organ detected</span>"
	return ret.Join()

/datum/genetic_prescan
	var/list/activeDna = null
	var/list/poolDna = null

	var/list/activeDnaKnown = null
	var/list/activeDnaUnknown = null
	var/list/poolDnaKnown = null
	var/list/poolDnaUnknown = null

	proc/generate_known_unknown(ignoreRestrictions = FALSE)
		if (ignoreRestrictions)
			src.activeDnaKnown = src.activeDna
			src.poolDnaKnown = src.poolDna
			return
		src.activeDnaKnown = list()
		src.activeDnaUnknown = list()
		src.poolDnaKnown = list()
		src.poolDnaUnknown = list()
		for (var/datum/bioEffect/BE in src.activeDna)
			var/datum/bioEffect/GBE = BE.get_global_instance()
			if (!GBE.scanner_visibility)
				continue
			if (GBE.secret && !genResearch.see_secret)
				continue
			if (GBE.research_level < EFFECT_RESEARCH_DONE)
				src.activeDnaUnknown += BE
				continue
			src.activeDnaKnown += BE
		for (var/datum/bioEffect/BE in src.poolDna)
			var/datum/bioEffect/GBE = BE.get_global_instance()
			if (!GBE.scanner_visibility)
				continue
			if (GBE.secret && !genResearch.see_secret)
				continue
			if (GBE.research_level < EFFECT_RESEARCH_DONE)
				src.poolDnaUnknown += BE
				continue
			src.poolDnaKnown += BE

/proc/scan_genetic(mob/M as mob, datum/genetic_prescan/prescan = null, visible = FALSE)
	if (!M)
		return "<b class='alert'>ERROR: NO SUBJECT DETECTED</b>"
	if (visible)
		animate_scanning(M, "#9eee80")
	if (!M.has_genetics())
		return "<b class='alert'>ERROR: UNABLE TO ANALYZE GENETIC STRUCTURE</b>"
	var/mob/living/carbon/human/H = M
	var/list/data = list()
	var/datum/bioHolder/BH = M.bioHolder
	data += "<b class='notice'>Genetic Stability: [BH.genetic_stability]</b>"
	var/datum/genetic_prescan/GP = prescan
	if (!GP)
		GP = new /datum/genetic_prescan
		GP.activeDna = list()
		GP.poolDna = list()
		for (var/bioEffectId in BH.effects)
			GP.activeDna += BH.GetEffect(bioEffectId)
		for (var/bioEffectId in BH.effectPool)
			GP.poolDna += BH.GetEffect(bioEffectId)
		GP.generate_known_unknown()
	data += "<b class='notice'>Potential Genetic Effects:</b>"
	for (var/datum/bioEffect/BE in GP.poolDnaKnown)
		data += BE.name
	if (length(GP.poolDnaUnknown))
		data += SPAN_ALERT("Unknown: [length(GP.poolDnaUnknown)]")
	else if (!length(GP.poolDnaKnown))
		data += "-- None --"
	data += "<b class='notice'>Active Genetic Effects:</b>"
	for (var/datum/bioEffect/BE in GP.activeDnaKnown)
		data += BE.name
	if (length(GP.activeDnaUnknown))
		data += SPAN_ALERT("Unknown: [length(GP.activeDnaUnknown)]")
	else if (!length(GP.activeDnaKnown))
		data += "-- None --"

	if(istype(H))
		if (length(H.cloner_defects.active_cloner_defects))
			data += "<b class='alert'>Detected Cloning-Related Defects:</b>"
			for(var/datum/cloner_defect/defect as anything in H.cloner_defects.active_cloner_defects)
				data += "<b class='alert'>[defect.name]</b>"
				data += "<i class='alert'>[defect.desc]</i>"
	return data.Join("<br>")

/// Returns the datacore general record, or null if none found
/proc/get_general_record(mob/living/carbon/human/H)
	if (!istype(H))
		return null
	var/patientname = H.name
	if (H:wear_id && H:wear_id:registered)
		patientname = H.wear_id:registered
	return data_core.general.find_record("name", patientname)

/proc/update_medical_record(var/mob/living/carbon/human/M)
	var/datum/db_record/E = get_general_record(M)
	if(!istype(E))
		return

	switch (M.stat)
		if (STAT_ALIVE)
			if (M.bioHolder && M.bioHolder.HasEffect("strong"))
				E["p_stat"] = "Very Active"
			else
				E["p_stat"] = "Active"
		if (STAT_UNCONSCIOUS)
			E["p_stat"] = "*Unconscious*"
		if (STAT_DEAD)
			E["p_stat"] = "*Deceased*"

	var/datum/db_record/R = data_core.medical.find_record("id", E["id"])
	if(!R)
		return

	R["bioHolder.bloodType"] = M.bioHolder.bloodType
	R["cdi"] = english_list(M.ailments, MEDREC_DISEASE_DEFAULT)
	if (M.ailments.len)
		R["cdi_d"] = "Diseases detected at [time2text(world.realtime,"hh:mm")]."
	else
		R["cdi_d"] = "No notes."

	record_cloner_defects(M)


/proc/scan_health_generate_text(var/mob/M)
	var/h_pct = M.max_health ? round(100 * M.health / M.max_health) : M.health
	if(M.max_health <= 0)
		h_pct = "???"
	var/oxy = round(M.get_oxygen_deprivation())
	var/tox = round(M.get_toxin_damage())
	var/burn = round(M.get_burn_damage())
	var/brute = round(M.get_brute_damage())

	return "<span class='ol c pixel'><span class='vga'>[h_pct]%</span>\n<span style='color: #40b0ff;'>[oxy]</span> - <span style='color: #33ff33;'>[tox]</span> - <span style='color: #ffee00;'>[burn]</span> - <span style='color: #ff6666;'>[brute]</span></span>"

/proc/scan_medrecord(var/obj/item/device/pda2/pda, var/mob/M as mob, var/visible = 0)
	if (!M)
		return SPAN_ALERT("ERROR: NO SUBJECT DETECTED")

	if (!ishuman(M))
		return SPAN_ALERT("ERROR: INVALID DATA FROM SUBJECT")

	if(visible)
		animate_scanning(M, "#0AEFEF")

	var/mob/living/carbon/human/H = M
	var/datum/db_record/GR = data_core.general.find_record("name", H.name)
	var/datum/db_record/MR = data_core.medical.find_record("name", H.name)
	if (!MR)
		return SPAN_ALERT("ERROR: NO RECORD FOUND")

	//Find medical records program
	var/list/programs = null
	for (var/obj/item/disk/data/mod in pda.contents)
		programs += mod.root.contents.Copy()
	var/datum/computer/file/pda_program/records/medical/record_prog = locate(/datum/computer/file/pda_program/records/medical) in programs
	if (!record_prog)
		return SPAN_ALERT("ERROR: NO MEDICAL RECORD FILE")
	pda.run_program(record_prog)
	record_prog.active1 = GR
	record_prog.active2 = MR
	record_prog.mode = 1
	pda.AttackSelf(usr)

/proc/scan_reagents(atom/A, show_temp = TRUE, visible = FALSE, medical = FALSE, admin = FALSE)
	if (!A)
		return SPAN_ALERT("ERROR: NO SUBJECT DETECTED")

	if(visible)
		animate_scanning(A, "#a92fda")

	var/data = null
	var/reagent_data = null
	var/datum/reagents/reagents = A.reagents

	if(istype(A, /obj/fluid))
		var/obj/fluid/F = A
		reagents = F.group.reagents
	else if (istype(A, /obj/item/assembly))
		var/obj/item/assembly/checked_assembly = A
		reagents = checked_assembly.get_first_component_reagents()
	else if (istype(A, /obj/machinery/clonepod))
		var/obj/machinery/clonepod/P = A
		if(P.occupant)
			reagents = P.occupant.reagents

	if (reagents)
		if (length(reagents.reagent_list))
			if("cloak_juice" in reagents.reagent_list)
				var/datum/reagent/cloaker = reagents.reagent_list["cloak_juice"]
				if(cloaker.volume >= 5)
					data = SPAN_ALERT("ERR: SPECTROSCOPIC ANALYSIS OF THIS SUBSTANCE IS NOT POSSIBLE.")
					return data
			if (!admin)
				SEND_SIGNAL(reagents, COMSIG_REAGENTS_ANALYZED, usr)

			var/reagents_length = length(reagents.reagent_list)
			data = "<b class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found in [A].</b>"

			for (var/current_id in reagents.reagent_list)
				var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
				var/show_OD = (medical && current_reagent.overdose != 0 && current_reagent.volume >= current_reagent.overdose)
				reagent_data += "<span [show_OD ? "class='alert'" : "class='notice'"]><br>&emsp;[current_reagent.name] - [current_reagent.volume][show_OD? " - OD!":""]</span>"
			data += "[reagent_data]"

			if (show_temp)
				data += "<br>[SPAN_NOTICE("Overall temperature: [reagents.total_temperature] K")]"
		else
			data = "<b class='notice'>No active chemical agents found in [A].</b>"
	else
		data = "<b class='notice'>No significant chemical agents found in [A].</b>"

	if (CHECK_LIQUID_CLICK(A))
		var/turf/T = get_turf(A)
		var/obj/fluid/liquid = T.active_liquid
		var/obj/fluid/airborne/gas = T.active_airborne_liquid
		if (liquid)
			data += "<br>[scan_reagents(liquid, show_temp, visible, medical, admin)]"
		if (gas)
			data += "<br>[scan_reagents(gas, show_temp, visible, medical, admin)]"

	return data

/proc/get_ethanol_equivalent(mob/user, datum/reagents/R)
	var/eth_eq = 0
	var/should_we_output = FALSE //looks bad if we output this when it's just ethanol in there
	if(!istype(R))
		return
	for (var/current_id in R.reagent_list)
		var/datum/reagent/current_reagent = R.reagent_list[current_id]
		if (istype(current_reagent, /datum/reagent/fooddrink/alcoholic))
			var/datum/reagent/fooddrink/alcoholic/alch_reagent = current_reagent
			eth_eq += alch_reagent.alch_strength * alch_reagent.volume
			should_we_output = TRUE
		if (current_reagent.id == "ethanol")
			eth_eq += current_reagent.volume
	if (should_we_output == FALSE)
		eth_eq = 0
	return eth_eq

/proc/scan_forensic(var/atom/A as turf|obj|mob, visible = FALSE)
	RETURN_TYPE(/datum/forensic_scan)
	if (istype(A, /obj/ability_button)) // STOP THAT
		return
	if (!A)
		return SPAN_ALERT("ERROR: NO SUBJECT DETECTED")

	if(visible)
		animate_scanning(A, "#b9d689")
	var/datum/forensic_scan/scan = new(A)
	return scan


// Made this a global proc instead of 10 or so instances of duplicate code spread across the codebase (Convair880).
/proc/scan_atmospheric(var/atom/A as turf|obj, var/pda_readout = 0, var/simple_output = 0, var/visible = 0, var/alert_output = 0)
	if (istype(A, /obj/ability_button))
		return
	if (!A)
		if (pda_readout == 1)
			return "Unable to obtain a reading."
		else if (simple_output == 1)
			return "(<b>Error:</b> <i>no source provided</i>)"
		else
			return SPAN_ALERT("Unable to obtain a reading.")

	if(visible)
		animate_scanning(A, "#00a0ff", alpha_hex = "32")

	var/datum/gas_mixture/check_me = A.return_air(direct = TRUE)
	var/pressure = null
	var/total_moles = null

	if (!check_me || !istype(check_me, /datum/gas_mixture/))
		if (pda_readout == 1)
			return "[A] does not contain any gas."
		else if (simple_output == 1)
			return "(<i>[A] has no gas holder</i>)"
		else
			return SPAN_ALERT("[A] does not contain any gas.")

	pressure = MIXTURE_PRESSURE(check_me)
	total_moles = TOTAL_MOLES(check_me)

	//DEBUG_MESSAGE("[A] contains: [pressure] kPa, [total_moles] moles.")

	var/data = ""

	if (total_moles > 0)
		if (pda_readout == 1) // Output goes into PDA interface, not the user's chatbox.
			data = "Air Pressure: [round(pressure, 0.1)] kPa<br>\
			Temperature: [round(check_me.temperature)] K<br>\
			[CONCENTRATION_REPORT(check_me, "<br>")]"

		else if (simple_output) // For the log_atmos() proc.
			data = "(<b>Pressure:</b> <i>[round(pressure, 0.1)] kPa</i>, <b>Temp:</b> <i>[round(check_me.temperature)] K</i>\
			, <b>Contents:</b> <i>[CONCENTRATION_REPORT(check_me, ", ")]</i>"

		else if (alert_output) // For the alert_atmos() proc.
			data = "(<b>Pressure:</b> <i>[round(pressure, 0.1)] kPa</i>, <b>Temp:</b> <i>[round(check_me.temperature)] K</i>\
			, <b>Contents:</b> <i>[SIMPLE_CONCENTRATION_REPORT(check_me, ", ")]</i>"

		else
			data = "--------------------------------<br>\
			[SPAN_NOTICE("Atmospheric analysis of <b>[A]</b>")]<br>\
			<br>\
			Pressure: [round(pressure, 0.1)] kPa<br>\
			Temperature: [round(check_me.temperature)] K<br>"
			//realistically bubbles should have a constantly changing volume based on their pressure but it doesn't really matter so let's just not report it
			if (!istype(A, /obj/bubble))
				data += "Volume: [check_me.volume] L<br>"
			data +=	"[SIMPLE_CONCENTRATION_REPORT(check_me, "<br>")]"

	else
		// Only used for "Atmospheric Scan" accessible through the PDA interface, which targets the turf
		// the PDA user is standing on. Everything else (i.e. clicking with the PDA on objects) goes in the chatbox.
		if (pda_readout == 1)
			data = "This area does not contain any gas."
		else if (simple_output == 1)
			data = "(<b>Contents:</b> <i>empty</i></b>)"
		else
			data = SPAN_ALERT("[A] does not contain any gas.")

	return data

// Yeah, another scan I made into a global proc (Convair880).
/proc/scan_plant(var/atom/A as turf|obj, var/mob/user as mob, var/visible = 0, var/show_gene_strain = TRUE)
	if (!A || !user || !ismob(user))
		return

	var/datum/plant/P = null
	var/datum/plantgenes/DNA = null

	if (istype(A, /obj/machinery/plantpot))
		var/obj/machinery/plantpot/PP = A
		if (!PP.current || PP.dead)
			return SPAN_ALERT("Cannot scan.")

		P = PP.current
		DNA = PP.plantgenes

	else if (istype(A, /obj/item/seed/))
		var/obj/item/seed/S = A
		if (S.isstrange || !S.planttype)
			return SPAN_ALERT("This seed has non-standard DNA and thus cannot be scanned.")

		P = S.planttype
		DNA = S.plantgenes

	else if (istype(A, /obj/item/reagent_containers/food/snacks/plant/))
		var/obj/item/reagent_containers/food/snacks/plant/F = A

		P = F.planttype
		DNA = F.plantgenes

	else if (istype(A, /mob/living/critter/plant))
		var/mob/living/critter/plant/F = A

		P = F.planttype
		DNA = F.plantgenes


	else if (istype(A, /obj/item/plant/tumbling_creeper))
		var/obj/item/plant/tumbling_creeper/handled_creeper = A

		P = handled_creeper.planttype
		DNA = handled_creeper.plantgenes

	else
		return

	if(visible)
		animate_scanning(A, "#70e800")

	if (!P || !istype(P, /datum/plant/) || !DNA || !istype(DNA, /datum/plantgenes/))
		return SPAN_ALERT("Cannot scan.")

	HYPgeneticanalysis(user, A, P, DNA, show_gene_strain) // Just use the existing proc.
	return

/proc/scan_secrecord(var/obj/item/device/pda2/pda, var/mob/M as mob, var/visible = 0)
	if (!M)
		return SPAN_ALERT("ERROR: NO SUBJECT DETECTED")

	if (!ishuman(M))
		return SPAN_ALERT("ERROR: INVALID DATA FROM SUBJECT")

	if(visible)
		animate_scanning(M, "#ef0a0a")

	var/mob/living/carbon/human/H = M
	var/datum/db_record/GR = data_core.general.find_record("name", H.name)
	var/datum/db_record/SR = data_core.security.find_record("name", H.name)
	if (!SR)
		return SPAN_ALERT("ERROR: NO RECORD FOUND")

	//Find security records program
	var/list/programs = null
	for (var/obj/item/disk/data/mod in pda.contents)
		programs += mod.root.contents.Copy()
	var/datum/computer/file/pda_program/records/security/record_prog = locate(/datum/computer/file/pda_program/records/security) in programs
	if (!record_prog)
		return SPAN_ALERT("ERROR: NO SECURITY RECORD FILE")
	pda.run_program(record_prog)
	record_prog.active1 = GR
	record_prog.active2 = SR
	record_prog.mode = 1
	pda.AttackSelf(usr)
