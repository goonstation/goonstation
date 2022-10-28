

/proc/scan_health(var/mob/M as mob, var/verbose_reagent_info = 0, var/disease_detection = 1, var/organ_scan = 0, var/visible = 0, syndicate = FALSE)
	if (!M)
		return "<span class='alert'>ERROR: NO SUBJECT DETECTED</span>"

	if (issilicon(M))
		return "<span class='alert'>ERROR: INVALID DATA FROM SUBJECT</span>"

	if(visible)
		animate_scanning(M, "#0AEFEF")

	var/death_state = M.stat
	if (M.bioHolder && M.bioHolder.HasEffect("dead_scan"))
		death_state = 2

	var/health_percent = round(100 * M.health / M.max_health)

	var/colored_health
	if(M.max_health <= 0)
		colored_health = "<span class='alert'>???</span>"
	if (health_percent >= 51 && health_percent <= 100)
		colored_health = "<span style='color:#138015'>[health_percent]</span>"
	else if (health_percent >= 1 && health_percent <= 50)
		colored_health = "<span style='color:#CC7A1D'>[health_percent]</span>"
	else colored_health = "<span class='alert'>[health_percent]</span>"

	var/optimal_temp = M.base_body_temp
	var/body_temp_C = round(M.bodytemperature - T0C, M.bodytemperature - T0C < 1000 ? 0.01 : 1)
	var/body_temp_F = round(M.bodytemperature * 1.8 - T0F, M.bodytemperature * 1.8 - T0F < 1000 ? 0.01 : 1)
	var/body_temp = "[body_temp_C]&deg;C ([body_temp_F]&deg;F)"
	var/colored_temp = ""
	if (M.bodytemperature >= (optimal_temp + 60))
		colored_temp = "<span class='alert'>[body_temp]</span>"
	else if (M.bodytemperature >= (optimal_temp + 30))
		colored_temp = "<span style='color:#CC7A1D'>[body_temp]</span>"
	else if (M.bodytemperature <= (optimal_temp - 60))
		colored_temp = "<span class='notice'>[body_temp]</span>"
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
	var/pathogen_data = null
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
				blood_data = "Blood Pressure: <span class='alert'>NO PULSE</span>"
			else
				blood_data = "Blood Pressure: <span style='color:[bp_col]'>[L.blood_pressure["rendered"]] ([L.blood_pressure["status"]])</span>"
			if (verbose_reagent_info)
				if (isvampire(L)) // Added a pair of vampire checks here (Convair880).
					blood_data += " | Blood level: <span style='color:#138015'>500 units</span>"
				else
					blood_data += " | Blood level: <span style='color:[bp_col]'>[L.blood_pressure["total"]] unit[s_es(L.blood_pressure["total"])]</span>"
					if (L.bleeding)
						blood_data += " | Blood loss: <span class='alert'>[L.bleeding] unit[s_es(L.bleeding)]</span>"
			else if (!isvampire(L))
				switch (L.bleeding)
					if (1 to 3)
						blood_data += " | <span class='alert'><B>Minor bleeding wounds detected</B></span>"
					if (4 to 6)
						blood_data += " | <span class='alert'><B>Bleeding wounds detected</B></span>"
					if (7 to INFINITY)
						blood_data += " | <span class='alert'><B>Major bleeding wounds detected</B></span>"


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
					blood_data += " | <span class='alert'><B>Foreign object[s_es(bad_stuff)] detected</B></span>"
				if(H.chest_item != null) // State that large foreign object is located in chest
					blood_data += " | <span class='alert'><B>Sizable foreign object located below sternum</B></span>"
			else
				if (bad_stuff)
					blood_data += " | <span class='alert'><B>Foreign object[s_es(bad_stuff)] detected</B></span>"

		if (ishuman)
			var/mob/living/carbon/human/H = M
			if (H.pathogens.len)
				pathogen_data = "<span class='alert'>Scans indicate the presence of [H.pathogens.len > 1 ? "[H.pathogens.len] " : null]pathogenic bodies.</span>"
				for (var/uid in H.pathogens)
					var/datum/pathogen/P = H.pathogens[uid]
					pathogen_data += "<br>&emsp;<span class='alert'>Strain [P.name] seems to be in stage [P.stage]. Suggested suppressant: [P.suppressant.therapy].</span>."
					if (P.in_remission)
						pathogen_data += "<br>&emsp;&emsp;<span class='alert'>It appears to be in remission.</span>."

			if (H.get_organ("brain"))
				if (H.get_brain_damage() >= 100)
					brain_data = "<span class='alert'>Subject is braindead.</span>"
				else if (H.get_brain_damage() >= 60)
					brain_data = "<span class='alert'>Severe brain damage detected. Subject likely unable to function well.</span>"
				else if (H.get_brain_damage() >= 10)
					brain_data = "<span class='alert'>Significant brain damage detected. Subject may have had a concussion.</span>"
			else
				brain_data = "<span class='alert'>Subject has no brain.</span>"

			// if (!H.get_organ("heart"))
			// 	heart_data = "<span class='alert'>Subject has no heart.</span>"
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
					organ_data = "<span class='alert'>Subject has no organs. Veeeerrrry curious.</span>"


	var/datum/statusEffect/simpledot/radiation/R = M.hasStatus("radiation")
	if (R?.stage)
		rad_data = "&emsp;<span class='alert'>The subject is [R.howMuch]irradiated. Dose: [M.radiation_dose] Sv</span>"

	for (var/datum/ailment_data/A in M.ailments)
		if (disease_detection >= A.detectability)
			disease_data += "<br>[A.scan_info()]"

	if (M.reagents)
		if (verbose_reagent_info)
			reagent_data = scan_reagents(M, 0, 0, 0, 1)
		else
			var/ephe_amt = M.reagents:get_reagent_amount("ephedrine")
			var/epi_amt = M.reagents:get_reagent_amount("epinephrine")
			var/atro_amt = M.reagents:get_reagent_amount("atropine")
			var/total_amt = ephe_amt + epi_amt + atro_amt
			if (total_amt)
				reagent_data = "<span class='notice'>Bloodstream Analysis located [total_amt] units of rejuvenation chemicals.</span>"

	if (!ishuman) // vOv
		if (M.get_brain_damage() >= 100)
			brain_data = "<span class='alert'>Subject is braindead.</span>"
		else if (M.get_brain_damage() >= 60)
			brain_data = "<span class='alert'>Severe brain damage detected. Subject likely unable to function well.</span>"
		else if (M.get_brain_damage() >= 10)
			brain_data = "<span class='alert'>Significant brain damage detected. Subject may have had a concussion.</span>"

	if (M.interesting)
		interesting_data += "<br><span class='notice'>[M.interesting]</span>"

	var/data = "--------------------------------<br>\
	Analyzing Results for <span class='notice'>[M]</span>:<br>\
	&emsp; Overall Status: [death_state > 1 ? "<span class='alert'>DEAD</span>" : "[colored_health]% healthy"]<br>\
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
	[pathogen_data ? "<br>[pathogen_data]" : null]\
	[disease_data ? "[disease_data]" : null]\
	[interesting_data ? "<br><i>Historical analysis:</i><span class='notice'> [interesting_data]</span>" : null]\
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
		return "<br><span style='color:purple'><b>[input]</b> - missing!</span>"

//Using input here because it get's the organs name in an easy and clear way. using name or organ_name in obj/item/organ is not any better really
/proc/obfuscate_organ_health(var/obj/item/organ/O)
	if (!O)
		return null
	var/list/ret = list()
	var/damage = O.get_damage()
	if (damage >= O.max_damage)
		ret += "<br><span class='alert'><b>[O.name]</b> - Dead</span>"
	else if (damage >= O.max_damage*0.9)
		ret += "<br><span class='alert'><b>[O.name]</b> - Critical</span>"
	else if (damage >= O.max_damage*0.65)
		ret += "<br><span class='alert'><b>[O.name]</b> - Significant</span>"
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
		return "<span class='alert'>ERROR: NO SUBJECT DETECTED</span>"
	if (visible)
		animate_scanning(M, "#9eee80")
	if (!ishuman(M))
		return "<span class='alert'>ERROR: UNABLE TO ANALYZE GENETIC STRUCTURE</span>"
	var/list/data = list()
	var/datum/bioHolder/BH = M.bioHolder
	data += "<span class='notice'>Genetic Stability: [BH.genetic_stability]</span>"
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
	data += "<span class='notice'>Potential Genetic Effects:</span>"
	for (var/datum/bioEffect/BE in GP.poolDnaKnown)
		data += BE.name
	if (length(GP.poolDnaUnknown))
		data += "<span class='alert'>Unknown: [length(GP.poolDnaUnknown)]</span>"
	else if (!length(GP.poolDnaKnown))
		data += "-- None --"
	data += "<span class='notice'>Active Genetic Effects:</span>"
	for (var/datum/bioEffect/BE in GP.activeDnaKnown)
		data += BE.name
	if (length(GP.activeDnaUnknown))
		data += "<span class='alert'>Unknown: [length(GP.activeDnaUnknown)]</span>"
	else if (!length(GP.activeDnaKnown))
		data += "-- None --"
	return data.Join("<br>")

/proc/update_medical_record(var/mob/living/carbon/human/M)
	if (!M || !ishuman(M))
		return

	var/patientname = M.name
	if (M:wear_id && M:wear_id:registered)
		patientname = M.wear_id:registered

	var/datum/db_record/E = data_core.general.find_record("name", patientname)
	if(E)
		switch (M.stat)
			if (0)
				if (M.bioHolder && M.bioHolder.HasEffect("strong"))
					E["p_stat"] = "Very Active"
				else
					E["p_stat"] = "Active"
			if (1)
				E["p_stat"] = "*Unconscious*"
			if (2)
				E["p_stat"] = "*Deceased*"
		var/datum/db_record/R = data_core.medical.find_record("id", E["id"])
		if(R)
			R["bioHolder.bloodType"] = M.bioHolder.bloodType
			R["cdi"] = english_list(M.ailments, "No diseases have been diagnosed at the moment.")
			if (M.ailments.len)
				R["cdi_d"] = "Diseases detected at [time2text(world.realtime,"hh:mm")]."
			else
				R["cdi_d"] = "No notes."
	return

/proc/scan_health_generate_text(var/mob/M)
	var/h_pct = M.max_health ? round(100 * M.health / M.max_health) : M.health
	if(M.max_health <= 0)
		h_pct = "???"
	var/oxy = round(M.get_oxygen_deprivation())
	var/tox = round(M.get_toxin_damage())
	var/burn = round(M.get_burn_damage())
	var/brute = round(M.get_brute_damage())

	return "<span class='ol c pixel'><span class='vga'>[h_pct]%</span>\n<span style='color: #40b0ff;'>[oxy]</span> - <span style='color: #33ff33;'>[tox]</span> - <span style='color: #ffee00;'>[burn]</span> - <span style='color: #ff6666;'>[brute]</span></span>"


// output a health pop-up overhead thing to the client
/proc/scan_health_overhead(var/mob/M as mob, var/mob/C as mob) // M is who we're scanning, C is who to give the overhead to
	if (C.client && !C.client.preferences?.flying_chat_hidden)

		var/image/chat_maptext/chat_text = null
		var/popup_text = scan_health_generate_text(M)

		chat_text = make_chat_maptext(M, popup_text, force = 1)
		if(chat_text)
			chat_text.measure(C.client)
			for(var/image/chat_maptext/I in C.chat_text.lines)
				if(I != chat_text)
					I.bump_up(chat_text.measured_height)
			chat_text.show_to(C.client)

/proc/scan_medrecord(var/obj/item/device/pda2/pda, var/mob/M as mob, var/visible = 0)
	if (!M)
		return "<span class='alert'>ERROR: NO SUBJECT DETECTED</span>"

	if (!ishuman(M))
		return "<span class='alert'>ERROR: INVALID DATA FROM SUBJECT</span>"

	if(visible)
		animate_scanning(M, "#0AEFEF")

	var/mob/living/carbon/human/H = M
	var/datum/db_record/GR = data_core.general.find_record("name", H.name)
	var/datum/db_record/MR = data_core.medical.find_record("name", H.name)
	if (!MR)
		return "<span class='alert'>ERROR: NO RECORD FOUND</span>"

	//Find medical records program
	var/list/programs = null
	for (var/obj/item/disk/data/mod in pda.contents)
		programs += mod.root.contents.Copy()
	var/datum/computer/file/pda_program/records/medical/record_prog = locate(/datum/computer/file/pda_program/records/medical) in programs
	if (!record_prog)
		return "<span class='alert'>ERROR: NO MEDICAL RECORD FILE</span>"
	pda.run_program(record_prog)
	record_prog.active1 = GR
	record_prog.active2 = MR
	record_prog.mode = 1
	pda.AttackSelf(usr)

/proc/scan_reagents(var/atom/A as turf|obj|mob, var/show_temp = 1, var/single_line = 0, var/visible = 0, var/medical = 0)
	if (!A)
		return "<span class='alert'>ERROR: NO SUBJECT DETECTED</span>"

	if(visible)
		animate_scanning(A, "#a92fda")

	var/data = null
	var/reagent_data = null
	var/datum/reagents/reagents = A.reagents

	if(istype(A, /obj/fluid))
		var/obj/fluid/F = A
		reagents = F.group.reagents
	else if (istype(A, /obj/machinery/clonepod))
		var/obj/machinery/clonepod/P = A
		if(P.occupant)
			reagents = P.occupant.reagents

	if (reagents)
		if (reagents.reagent_list.len > 0)
			if("cloak_juice" in reagents.reagent_list)
				var/datum/reagent/cloaker = reagents.reagent_list["cloak_juice"]
				if(cloaker.volume >= 5)
					data = "<span class='alert'>ERR: SPECTROSCOPIC ANALYSIS OF THIS SUBSTANCE IS NOT POSSIBLE.</span>"
					return data

			var/reagents_length = length(reagents.reagent_list)
			data = "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found in [A].</span>"

			for (var/current_id in reagents.reagent_list)
				var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
				var/show_OD = (medical && current_reagent.overdose != 0 && current_reagent.volume >= current_reagent.overdose)
				if (single_line)
					reagent_data += "<span [show_OD ? "class='alert'" : "class='notice'"]>[current_reagent] ([current_reagent.volume])[show_OD? " - OD!":""]</span>,"
				else
					reagent_data += "<span [show_OD ? "class='alert'" : "class='notice'"]><br>&emsp;[current_reagent.name] - [current_reagent.volume][show_OD? " - OD!":""]</span>"
			if (single_line)
				data += "[copytext(reagent_data, 1, -1)]"
			else
				data += "[reagent_data]"

			if (show_temp)
				data += "<br><span class='notice'>Overall temperature: [reagents.total_temperature - T0C]&deg;C ([reagents.total_temperature * 1.8 - T0F]&deg;F)</span>"
		else
			data = "<span class='notice'>No active chemical agents found in [A].</span>"
	else
		data = "<span class='notice'>No significant chemical agents found in [A].</span>"

	return data

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
		return "<span class='alert'>ERROR: NO SUBJECT DETECTED</span>"

	if(visible)
		animate_scanning(A, "#b9d689")

	if (ishuman(A))
		var/mob/living/carbon/human/H = A

		if (!isnull(H.gloves))
			var/obj/item/clothing/gloves/WG = H.gloves
			if (WG.glove_ID)
				glove_data += "[WG.glove_ID] (<span class='notice'>[H]'s worn [WG.name]</span>)"
			if (!WG.hide_prints)
				fingerprint_data += "<br><span class='notice'>[H]'s fingerprints:</span> [H.bioHolder.fingerprints]"
			else
				fingerprint_data += "<br><span class='notice'>Unable to scan [H]'s fingerprints.</span>"
		else
			fingerprint_data += "<br><span class='notice'>[H]'s fingerprints:</span> [H.bioHolder.fingerprints]"

		if (H.gunshot_residue) // Left by firing a kinetic gun.
			forensic_data += "<br><span class='notice'>Gunshot residue found.</span>"

		if (H.implant && H.implant.len > 0)
			var/wounds = null
			for (var/obj/item/implant/I in H.implant)
				if (istype(I, /obj/item/implant/projectile))
					wounds ++
			if (wounds)
				forensic_data += "<br><span class='notice'>[wounds] gunshot [wounds == 1 ? "wound" : "wounds"] detected.</span>"

		if (H.fingerprints) // Left by grabbing or pulling people.
			var/list/FFP = H:fingerprints
			for(var/i in FFP)
				fingerprint_data += "<br><span class='notice'>Foreign fingerprint on [H]:</span> [i]"

		if (H.bioHolder.Uid) // For quick reference. Also, attacking somebody only makes their clothes bloody, not the mob (think naked dudes).
			blood_data += "<br><span class='notice'>[H]'s blood DNA:</span> [H.bioHolder.Uid]"

		if (H.blood_DNA && isnull(H.gloves)) // Don't magically detect blood through worn gloves.
			var/list/BH = params2list(H:blood_DNA)
			for(var/i in BH)
				blood_data += "<br><span class='notice'>Blood on [H]'s hands:</span> [i]"

		var/list/gear_to_check = list(H.head, H.wear_mask, H.w_uniform, H.wear_suit, H.belt, H.gloves, H.back)
		for (var/obj/item/check in gear_to_check)
			if (check)
				var/list/BC
				if (check.blood_DNA)
					BC = params2list(check.blood_DNA)
					for(var/i in BC)
						blood_data += "<br><span class='notice'>Blood on worn [check.name]:</span> [i]"
				/*var/trace_blood = check.get_forensic_trace("bDNA")
				if (trace_blood)
					BC = params2list(trace_blood)
					for (var/i in BC)
						blood_data += "<br><span class='notice'>Blood trace on worn [check.name]:</span> [i]"
				*/

		if (H.r_hand && H.r_hand.blood_DNA)
			var/list/BIR = params2list(H.r_hand.blood_DNA)
			for(var/i in BIR)
				blood_data += "<br><span class='notice'>Blood on held [H.r_hand.name]:</span> [i]"

		if (H.l_hand && H.l_hand.blood_DNA)
			var/list/BIL = params2list(H.l_hand.blood_DNA)
			for(var/i in BIL)
				blood_data += "<br><span class='notice'>Blood on held [H.l_hand.name]:</span> [i]"

	else

		if (istype(A, /obj/item/parts/human_parts))
			var/obj/item/parts/human_parts/H = A
			if (H.original_DNA)
				blood_data += "<br><span class='notice'>[H]'s blood DNA:</span> [H.original_DNA]"
			if (istype(H, /obj/item/parts/human_parts/arm)) // has fringerpints
				fingerprint_data += "<br><span class='notice'>[H]'s fingerprints:</span> [H.original_fprints]"

		else if (istype(A, /obj/item/organ))
			var/obj/item/organ/O = A
			if (O.donor_DNA)
				blood_data += "<br><span class='notice'>[O]'s blood DNA:</span> [O.donor_DNA]"

		else if (istype(A, /obj/item/clothing/head/butt))
			var/obj/item/clothing/head/butt/B = A
			if (B.donor_DNA)
				blood_data += "<br><span class='notice'>[B]'s blood DNA:</span> [B.donor_DNA]"

		else if (isobj(A) && A.reagents && A.is_open_container() && A.reagents.has_reagent("blood"))
			var/datum/reagent/blood/B = A.reagents.reagent_list["blood"]
			if (B && istype(B.data, /datum/bioHolder))
				var/datum/bioHolder/BH = B.data
				if (BH.Uid)
					blood_data += "<br><span class='notice'>Blood DNA inside [A]:</span> [BH.Uid]"

		if (A.interesting)
			if (istype(A, /obj))
				interesting_data += "<br><span class='notice'>[A.interesting]</span>"
			if (istype(A, /turf))
				interesting_data += "<br><span class='notice'>There seems to be more to [A] than meets the eye.</span>"

//		if (!A.fingerprints)
			/*var/list/FP = params2list(A.get_forensic_trace("fprints"))
			if (FP)
				for (var/i in FP)
					fingerprint_data += "<br><span class='notice'>[i]</span>"
			else
				*///fingerprint_data += "<br><span class='notice'>Unable to locate any fingerprints.</span>"
//		else
		if (A.fingerprints)
			var/list/FP = A:fingerprints
			for(var/i in FP)
				fingerprint_data += "<br><span class='notice'>[i]</span>"

//		if (!A.blood_DNA)
			/*var/list/DNA = params2list(A.get_forensic_trace("bDNA"))
			if (DNA)
				for (var/i in DNA)
					blood_data += "<br><span class='notice'>[i]</span>"
			else
				*///blood_data += "<br><span class='notice'>Unable to locate any blood traces.</span>"
//		else
		if (A.blood_DNA)
			var/list/DNA = params2list(A:blood_DNA)
			for(var/i in DNA)
				blood_data += "<br><span class='notice'>[i]</span>"

		if (isitem(A))
			var/obj/item/I = A
			if(I.get_contraband())
				contraband_data = "<span class='alert'>(CONTRABAND: LEVEL [I.get_contraband()])</span>"

		if (istype(A, /obj/item/clothing/gloves))
			var/obj/item/clothing/gloves/G = A
			if (G.glove_ID)
				glove_data += "[G.glove_ID] [G.material_prints ? "([G.material_prints])" : null]"

		if (istype(A, /obj/item/casing/))
			var/obj/item/casing/C = A
			if(C.forensic_ID)
				forensic_data += "<br><span class='notice'>Forensic profile of [C]:</span> [C.forensic_ID]"

		if (istype(A, /obj/item/implant/projectile))
			var/obj/item/implant/projectile/P = A
			if(P.forensic_ID)
				forensic_data += "<br><span class='notice'>Forensic profile of [P]:</span> [P.forensic_ID]"

		if (istype(A, /obj/item/gun))
			var/obj/item/gun/G = A
			if(G.forensic_ID)
				forensic_data += "<br><span class='notice'>Forensic profile of [G]:</span> [G.forensic_ID]"

		if (istype(A, /turf/simulated/wall))
			var/turf/simulated/wall/W = A
			if (W.forensic_impacts && islist(W.forensic_impacts) && length(W.forensic_impacts))
				for(var/i in W.forensic_impacts)
					forensic_data += "<br><span class='notice'>Forensic signature found:</span> [i]"

	if (!fingerprint_data) // Just in case, we'd always want to have a readout for these.
		fingerprint_data = "<br><span class='notice'>Unable to locate any fingerprints.</span>"

	if (!blood_data)
		blood_data = "<br><span class='notice'>Unable to locate any blood traces.</span>"

	// This was the least enjoyable part of the entire exercise. Formatting is nothing but a chore.
	var/data = "--------------------------------<br>\
	<span class='notice'>Forensic analysis of <b>[A]</b></span> [contraband_data ? "[contraband_data]" : null]<br>\
	<br>\
	<i>Isolated fingerprints:</i>[fingerprint_data]<br>\
	<br>\
	<i>Isolated blood samples:</i>[blood_data]<br>\
	[forensic_data ? "<br><i>Additional forensic data:</i>[forensic_data]<br>" : null]\
	[glove_data ? "<br><i>Material analysis:</i><span class='notice'> [glove_data]</span>" : null]\
	[interesting_data ? "<br><i>Energy signature analysis:</i><span class='notice'> [interesting_data]</span>" : null]\
	"

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
			return "<span class='alert'>Unable to obtain a reading.</span>"

	if(visible)
		animate_scanning(A, "#00a0ff", alpha_hex = "32")

	var/datum/gas_mixture/check_me = null
	var/pressure = null
	var/total_moles = null

	if (hasvar(A, "air_contents"))
		check_me = A:air_contents // Not pretty, but should be okay here.
	if (isturf(A))
		check_me = A.return_air()
	if (istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = A
		check_me = P.return_air()
	if (istype(A, /obj/item/assembly/time_bomb))
		var/obj/item/assembly/time_bomb/TB = A
		if (TB.part3)
			check_me = TB.part3.air_contents
	if (istype(A, /obj/item/assembly/radio_bomb))
		var/obj/item/assembly/radio_bomb/RB = A
		if (RB.part3)
			check_me = RB.part3.air_contents
	if (istype(A, /obj/item/assembly/proximity_bomb))
		var/obj/item/assembly/proximity_bomb/PB = A
		if (PB.part3)
			check_me = PB.part3.air_contents
	if (istype(A, /obj/item/gun/flamethrower/assembled/))
		var/obj/item/gun/flamethrower/assembled/FT = A
		if (FT.gastank)
			check_me = FT.gastank.air_contents

	if (!check_me || !istype(check_me, /datum/gas_mixture/))
		if (pda_readout == 1)
			return "[A] does not contain any gas."
		else if (simple_output == 1)
			return "(<i>[A] has no gas holder</i>)"
		else
			return "<span class='alert'>[A] does not contain any gas.</span>"

	pressure = MIXTURE_PRESSURE(check_me)
	total_moles = TOTAL_MOLES(check_me)

	//DEBUG_MESSAGE("[A] contains: [pressure] kPa, [total_moles] moles.")

	var/data = ""

	if (total_moles > 0)
		if (pda_readout == 1) // Output goes into PDA interface, not the user's chatbox.
			data = "Air Pressure: [round(pressure, 0.1)] kPa<br>\
			[CONCENTRATION_REPORT(check_me, "<br>")]\
			Temperature: [round(check_me.temperature - T0C)]&deg;C<br>"

		else if (simple_output) // For the log_atmos() proc.
			data = "(<b>Pressure:</b> <i>[round(pressure, 0.1)] kPa</i>, <b>Temp:</b> <i>[round(check_me.temperature - T0C)]&deg;C</i>\
			, <b>Contents:</b> <i>[CONCENTRATION_REPORT(check_me, ", ")]</i>"

		else if (alert_output) // For the alert_atmos() proc.
			data = "(<b>Pressure:</b> <i>[round(pressure, 0.1)] kPa</i>, <b>Temp:</b> <i>[round(check_me.temperature - T0C)]&deg;C</i>\
			, <b>Contents:</b> <i>[SIMPLE_CONCENTRATION_REPORT(check_me, ", ")]</i>"

		else
			data = "--------------------------------<br>\
			<span class='notice'>Atmospheric analysis of <b>[A]</b></span><br>\
			<br>\
			Pressure: [round(pressure, 0.1)] kPa<br>\
			[CONCENTRATION_REPORT(check_me, "<br>")]\
			Temperature: [round(check_me.temperature - T0C)]&deg;C<br>"

	else
		// Only used for "Atmospheric Scan" accessible through the PDA interface, which targets the turf
		// the PDA user is standing on. Everything else (i.e. clicking with the PDA on objects) goes in the chatbox.
		if (pda_readout == 1)
			data = "This area does not contain any gas."
		else if (simple_output == 1)
			data = "(<b>Contents:</b> <i>empty</i></b>)"
		else
			data = "<span class='alert'>[A] does not contain any gas.</span>"

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
			return "<span class='alert'>Cannot scan.</span>"

		P = PP.current
		DNA = PP.plantgenes

	else if (istype(A, /obj/item/seed/))
		var/obj/item/seed/S = A
		if (S.isstrange || !S.planttype)
			return "<span class='alert'>This seed has non-standard DNA and thus cannot be scanned.</span>"

		P = S.planttype
		DNA = S.plantgenes

	else if (istype(A, /obj/item/reagent_containers/food/snacks/plant/))
		var/obj/item/reagent_containers/food/snacks/plant/F = A

		P = F.planttype
		DNA = F.plantgenes

	else
		return

	if(visible)
		animate_scanning(A, "#70e800")

	if (!P || !istype(P, /datum/plant/) || !DNA || !istype(DNA, /datum/plantgenes/))
		return "<span class='alert'>Cannot scan.</span>"

	HYPgeneticanalysis(user, A, P, DNA) // Just use the existing proc.
	return

/proc/scan_secrecord(var/obj/item/device/pda2/pda, var/mob/M as mob, var/visible = 0)
	if (!M)
		return "<span class='alert'>ERROR: NO SUBJECT DETECTED</span>"

	if (!ishuman(M))
		return "<span class='alert'>ERROR: INVALID DATA FROM SUBJECT</span>"

	if(visible)
		animate_scanning(M, "#ef0a0a")

	var/mob/living/carbon/human/H = M
	var/datum/db_record/GR = data_core.general.find_record("name", H.name)
	var/datum/db_record/SR = data_core.security.find_record("name", H.name)
	if (!SR)
		return "<span class='alert'>ERROR: NO RECORD FOUND</span>"

	//Find security records program
	var/list/programs = null
	for (var/obj/item/disk/data/mod in pda.contents)
		programs += mod.root.contents.Copy()
	var/datum/computer/file/pda_program/records/security/record_prog = locate(/datum/computer/file/pda_program/records/security) in programs
	if (!record_prog)
		return "<span class='alert'>ERROR: NO SECURITY RECORD FILE</span>"
	pda.run_program(record_prog)
	record_prog.active1 = GR
	record_prog.active2 = SR
	record_prog.mode = 1
	pda.AttackSelf(usr)
