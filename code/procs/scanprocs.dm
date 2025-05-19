

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
					if (I.scan_category == "not_shown")
						continue
					if (I.scan_category != "syndicate")
						if (I.scan_category != "unknown")
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
				if (H.get_brain_damage() >= 100)
					brain_data = SPAN_ALERT("Subject is braindead.")
				else if (H.get_brain_damage() >= 60)
					brain_data = SPAN_ALERT("Severe brain damage detected. Subject likely unable to function well.")
				else if (H.get_brain_damage() >= 10)
					brain_data = SPAN_ALERT("Significant brain damage detected. Subject may have had a concussion.")
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
		if (M.get_brain_damage() >= 100)
			brain_data = SPAN_ALERT("Subject is braindead.")
		else if (M.get_brain_damage() >= 60)
			brain_data = SPAN_ALERT("Severe brain damage detected. Subject likely unable to function well.")
		else if (M.get_brain_damage() >= 10)
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
	var/obj/item/organ/O = H.organHolder.organ_list[input]
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

// Should make it easier to maintain the detective's scanner and PDA program (Convair880).
/proc/scan_forensic(var/atom/A as turf|obj|mob, visible = 0)
	if (istype(A, /obj/ability_button)) // STOP THAT
		return
	var/fingerprint_data = null
	var/blood_data = null
	var/forensic_data = null
	var/glove_data = null
	var/contraband_data = null
	var/interesting_data = null

	if (!A)
		return SPAN_ALERT("ERROR: NO SUBJECT DETECTED")

	if(visible)
		animate_scanning(A, "#b9d689")

	if (ishuman(A))
		var/mob/living/carbon/human/H = A

		if (!isnull(H.gloves))
			var/obj/item/clothing/gloves/WG = H.gloves
			if (WG.glove_ID && !(WG.no_prints))
				glove_data += "[WG.glove_ID] ([SPAN_NOTICE("[H]'s worn [WG.name]")])"
			if (!WG.hide_prints)
				fingerprint_data += "<br>[SPAN_NOTICE("[H]'s fingerprints:")] [H.bioHolder.fingerprints]"
			else
				fingerprint_data += "<br>[SPAN_NOTICE("Unable to scan [H]'s fingerprints.")]"
		else
			fingerprint_data += "<br>[SPAN_NOTICE("[H]'s fingerprints:")] [H.bioHolder.fingerprints]"

		if (H.gunshot_residue) // Left by firing a kinetic gun.
			forensic_data += "<br>[SPAN_NOTICE("Gunshot residue found.")]"

		if (H.implant && length(H.implant) > 0)
			var/wounds = null
			for (var/obj/item/implant/I in H.implant)
				if (istype(I, /obj/item/implant/projectile))
					wounds ++
			if (wounds)
				forensic_data += "<br>[SPAN_NOTICE("[wounds] gunshot [wounds == 1 ? "wound" : "wounds"] detected.")]"

		if (H.fingerprints) // Left by grabbing or pulling people.
			var/list/FFP = H:fingerprints
			for(var/i in FFP)
				fingerprint_data += "<br>[SPAN_NOTICE("Foreign fingerprint on [H]:")] [i]"

		if (H.bioHolder.Uid) // For quick reference. Also, attacking somebody only makes their clothes bloody, not the mob (think naked dudes).
			blood_data += "<br>[SPAN_NOTICE("[H]'s blood DNA:")] [H.bioHolder.Uid]"

		if (H.blood_DNA && isnull(H.gloves)) // Don't magically detect blood through worn gloves.
			var/list/BH = params2list(H:blood_DNA)
			for(var/i in BH)
				blood_data += "<br>[SPAN_NOTICE("Blood on [H]'s hands:")] [i]"

		var/list/gear_to_check = list(H.head, H.wear_mask, H.w_uniform, H.wear_suit, H.belt, H.gloves, H.back)
		for (var/obj/item/check in gear_to_check)
			if (check)
				var/list/BC
				if (check.blood_DNA)
					BC = params2list(check.blood_DNA)
					for(var/i in BC)
						blood_data += "<br>[SPAN_NOTICE("Blood on worn [check.name]:")] [i]"
				/*var/trace_blood = check.get_forensic_trace("bDNA")
				if (trace_blood)
					BC = params2list(trace_blood)
					for (var/i in BC)
						blood_data += "<br>[SPAN_NOTICE("Blood trace on worn [check.name]:")] [i]"
				*/

		if (H.r_hand && H.r_hand.blood_DNA)
			var/list/BIR = params2list(H.r_hand.blood_DNA)
			for(var/i in BIR)
				blood_data += "<br>[SPAN_NOTICE("Blood on held [H.r_hand.name]:")] [i]"

		if (H.l_hand && H.l_hand.blood_DNA)
			var/list/BIL = params2list(H.l_hand.blood_DNA)
			for(var/i in BIL)
				blood_data += "<br>[SPAN_NOTICE("Blood on held [H.l_hand.name]:")] [i]"

	else

		if (istype(A, /obj/item/parts/human_parts))
			var/obj/item/parts/human_parts/H = A
			if (H.original_DNA)
				blood_data += "<br>[SPAN_NOTICE("[H]'s blood DNA:")] [H.original_DNA]"
			if (istype(H, /obj/item/parts/human_parts/arm)) // has fringerpints
				fingerprint_data += "<br>[SPAN_NOTICE("[H]'s fingerprints:")] [H.original_fprints]"

		else if (istype(A, /obj/item/organ))
			var/obj/item/organ/O = A
			if (O.donor_DNA)
				blood_data += "<br>[SPAN_NOTICE("[O]'s blood DNA:")] [O.donor_DNA]"

		else if (istype(A, /obj/item/clothing/head/butt))
			var/obj/item/clothing/head/butt/B = A
			if (B.donor_DNA)
				blood_data += "<br>[SPAN_NOTICE("[B]'s blood DNA:")] [B.donor_DNA]"

		else if (isobj(A) && A.reagents && A.is_open_container() && A.reagents.has_reagent("blood"))
			var/datum/reagent/blood/B = A.reagents.reagent_list["blood"]
			if (B && istype(B.data, /datum/bioHolder))
				var/datum/bioHolder/BH = B.data
				if (BH.Uid)
					blood_data += "<br>[SPAN_NOTICE("Blood DNA inside [A]:")] [BH.Uid]"

		if (A.interesting)
			if (istype(A, /obj))
				interesting_data += "<br>[SPAN_NOTICE("[A.interesting]")]"
			if (istype(A, /turf))
				interesting_data += "<br>[SPAN_NOTICE("There seems to be more to [A] than meets the eye.")]"

//		if (!A.fingerprints)
			/*var/list/FP = params2list(A.get_forensic_trace("fprints"))
			if (FP)
				for (var/i in FP)
					fingerprint_data += "<br>[SPAN_NOTICE("[i]")]"
			else
				*///fingerprint_data += "<br>[SPAN_NOTICE("Unable to locate any fingerprints.")]"
//		else
		if (A.fingerprints)
			var/list/FP = A:fingerprints
			for(var/i in FP)
				fingerprint_data += "<br>[SPAN_NOTICE("[i]")]"

//		if (!A.blood_DNA)
			/*var/list/DNA = params2list(A.get_forensic_trace("bDNA"))
			if (DNA)
				for (var/i in DNA)
					blood_data += "<br>[SPAN_NOTICE("[i]")]"
			else
				*///blood_data += "<br>[SPAN_NOTICE("Unable to locate any blood traces.")]"
//		else
		if (A.blood_DNA)
			var/list/DNA = params2list(A:blood_DNA)
			for(var/i in DNA)
				blood_data += "<br>[SPAN_NOTICE("[i]")]"

		if (isitem(A))
			var/obj/item/I = A
			var/contra = GET_ATOM_PROPERTY(I,PROP_MOVABLE_VISIBLE_CONTRABAND) + GET_ATOM_PROPERTY(I,PROP_MOVABLE_VISIBLE_GUNS)
			if (contra)
				contraband_data = SPAN_ALERT("(CONTRABAND: LEVEL [contra])")

		if (istype(A, /obj/item/clothing/gloves))
			var/obj/item/clothing/gloves/G = A
			if (G.glove_ID)
				glove_data += "[G.glove_ID] [G.material_prints ? "([G.material_prints])" : null]"

		if (istype(A, /obj))
			var/obj/O = A
			if(O.forensic_ID)
				forensic_data += "<br>[SPAN_NOTICE("Forensic profile of [O]:")] [O.forensic_ID]"

		if (istype(A, /turf/simulated/wall))
			var/turf/simulated/wall/W = A
			if (W.forensic_impacts && islist(W.forensic_impacts) && length(W.forensic_impacts))
				for(var/i in W.forensic_impacts)
					forensic_data += "<br>[SPAN_NOTICE("Forensic signature found:")] [i]"

	if (!fingerprint_data) // Just in case, we'd always want to have a readout for these.
		fingerprint_data = "<br>[SPAN_NOTICE("Unable to locate any fingerprints.")]"

	if (!blood_data)
		blood_data = "<br>[SPAN_NOTICE("Unable to locate any blood traces.")]"

	// This was the least enjoyable part of the entire exercise. Formatting is nothing but a chore.
	var/data = "--------------------------------<br>\
	[SPAN_NOTICE("Forensic analysis of <b>[A]</b>")] [contraband_data ? "[contraband_data]" : null]<br>\
	<br>\
	<i>Isolated fingerprints:</i>[fingerprint_data]<br>\
	<br>\
	<i>Isolated blood samples:</i>[blood_data]<br>\
	[forensic_data ? "<br><i>Additional forensic data:</i>[forensic_data]<br>" : null]\
	[glove_data ? "<br><i>Material analysis:</i>[SPAN_NOTICE(" [glove_data]")]" : null]\
	[interesting_data ? "<br><i>Energy signature analysis:</i>[SPAN_NOTICE(" [interesting_data]")]" : null]\
	"

	if (CHECK_LIQUID_CLICK(A))
		var/turf/T = get_turf(A)
		if (T.active_liquid)
			data += scan_forensic(T.active_liquid, visible)
		if (T.active_airborne_liquid)
			data += scan_forensic(T.active_airborne_liquid, visible)

	return data

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
/proc/scan_plant(var/atom/A as turf|obj, var/mob/user as mob, var/visible = 0)
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

	HYPgeneticanalysis(user, A, P, DNA) // Just use the existing proc.
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
