// Contents
// Health scan global procs
// Handheld health analyzer & upgrade chips
// Floor health scanner & wall readout

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

/// Generates text for the health readout that hovers above the scanned mob
/proc/scan_health_generate_text(var/mob/M)
	var/h_pct = M.max_health ? round(100 * M.health / M.max_health) : M.health
	if(M.max_health <= 0)
		h_pct = "???"
	var/oxy = round(M.get_oxygen_deprivation())
	var/tox = round(M.get_toxin_damage())
	var/burn = round(M.get_burn_damage())
	var/brute = round(M.get_brute_damage())

	return "<span class='ol c pixel'><span class='vga'>[h_pct]%</span>\n<span style='color: #40b0ff;'>[oxy]</span> - <span style='color: #33ff33;'>[tox]</span> - <span style='color: #ffee00;'>[burn]</span> - <span style='color: #ff6666;'>[brute]</span></span>"

TYPEINFO(/obj/item/device/analyzer/healthanalyzer)
	mats = 5

/obj/item/device/analyzer/healthanalyzer
	name = "health analyzer"
	icon_state = "health-no_up"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "healthanalyzer-no_up" // someone made this sprite and then this was never changed to it for some reason???
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	var/disease_detection = 1
	var/reagent_upgrade = 0
	var/reagent_scan = 0
	var/organ_upgrade = 0
	var/organ_scan = 0
	var/image/scanner_status
	hide_attack = ATTACK_PARTIALLY_HIDDEN

	New()
		..()
		scanner_status = image('icons/obj/items/device.dmi', icon_state = "health_over-basic")
		AddOverlays(scanner_status, "status")
		RegisterSignal(src, COMSIG_ITEM_ON_OWNER_DEATH, PROC_REF(assembly_on_wearer_death))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_building))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION, PROC_REF(assembly_building))
		// Health-analyser + assembly-applier -> health-analyser/Applier-Assembly
		src.AddComponent(/datum/component/assembly/trigger_applier_assembly)

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ON_OWNER_DEATH)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_ON_TARGET_ADDITION)
		..()

/// ----------- Assembly-Related Procs -----------

	assembly_get_part_help_message(var/dist, var/mob/shown_user, var/obj/item/assembly/parent_assembly)
		return " You can add this to a armor vest in order to craft a suicide bomb vest."

	proc/assembly_on_wearer_death(var/affected_analyser, var/mob/dying_mob)
		if (src.master && istype(src.master, /obj/item/assembly))
			var/obj/item/assembly/triggering_assembly = src.master
			if (dying_mob.suiciding && prob(60)) // no suiciding
				dying_mob.visible_message(SPAN_ALERT("<b>[dying_mob]'s [src.master.name] clicks softly, but nothing happens.</b>"))
				return
			//we give our potential victims a time of 3 seconds to react and flee
			triggering_assembly.last_armer = dying_mob
			dying_mob.visible_message(SPAN_ALERT("<B>With [him_or_her(dying_mob)] last breath, the [triggering_assembly.name] on them is set off!</B>"),\
			SPAN_ALERT("<B>With your last breath, you trigger the [src.master.name]!</B>"))
			logTheThing(LOG_BOMBING, dying_mob, "initiated a health-analyser on a [triggering_assembly.name] at [log_loc(src.master)].")
			playsound(get_turf(dying_mob), 'sound/machines/twobeep.ogg', 40, TRUE)
			SPAWN(3 SECONDS)
				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.data["message"] = "ACTIVATE"
				src.master.receive_signal(signal)

	proc/assembly_building(var/manipulated_mousetrap, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
		//since we have a lot of icon states for health analysers, but they have no effect, we take a single one
		parent_assembly.trigger_icon_prefix = "health-scanner"
		//health-analyser-assembly + armor vest -> suicide vest
		parent_assembly.AddComponent(/datum/component/assembly, list(/obj/item/clothing/suit/armor/vest), TYPE_PROC_REF(/obj/item/assembly, create_suicide_vest), TRUE)

/// ----------------------------------------------

	attack_self(mob/user as mob)
		if (!src.reagent_upgrade && !src.organ_upgrade)
			boutput(user, SPAN_ALERT("No upgrades detected!"))

		else if (src.reagent_upgrade && src.organ_upgrade)
			if (src.reagent_scan && src.organ_scan)				//if both active, make both off
				src.reagent_scan = 0
				src.organ_scan = 0
				scanner_status.icon_state = "health_over-basic"
				AddOverlays(scanner_status, "status")
				boutput(user, SPAN_ALERT("All upgrades disabled."))

			else if (!src.reagent_scan && !src.organ_scan)		//if both inactive, turn reagent on
				src.reagent_scan = 1
				src.organ_scan = 0
				scanner_status.icon_state = "health_over-reagent"
				AddOverlays(scanner_status, "status")
				boutput(user, SPAN_ALERT("Reagent scanner enabled."))

			else if (src.reagent_scan)							//if reagent active, turn reagent off, turn organ on
				src.reagent_scan = 0
				src.organ_scan = 1
				scanner_status.icon_state = "health_over-organ"
				AddOverlays(scanner_status, "status")
				boutput(user, SPAN_ALERT("Reagent scanner disabled. Organ scanner enabled."))

			else if (src.organ_scan)							//if organ active, turn BOTH on
				src.reagent_scan = 1
				src.organ_scan = 1
				scanner_status.icon_state = "health_over-both"
				AddOverlays(scanner_status, "status")
				boutput(user, SPAN_ALERT("All upgrades enabled."))

		else if (src.reagent_upgrade)
			src.reagent_scan = !(src.reagent_scan)
			scanner_status.icon_state = !reagent_scan ? "health_over-basic" : "health_over-reagent"
			AddOverlays(scanner_status, "status")
			boutput(user, SPAN_NOTICE("Reagent scanner [src.reagent_scan ? "enabled" : "disabled"]."))
		else if (src.organ_upgrade)
			src.organ_scan = !(src.organ_scan)
			scanner_status.icon_state = !organ_scan ? "health_over-basic" : "health_over-organ"
			AddOverlays(scanner_status, "status")
			boutput(user, SPAN_NOTICE("Organ scanner [src.organ_scan ? "enabled" : "disabled"]."))

	attackby(obj/item/W, mob/user)
		addUpgrade(W, user, src.reagent_upgrade)
		..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if ((user.bioHolder.HasEffect("clumsy") || user.get_brain_damage() >= BRAIN_DAMAGE_MAJOR) && prob(50))
			user.visible_message(SPAN_ALERT("<b>[user]</b> slips and drops [src]'s sensors on the floor!"))
			user.show_message("Analyzing Results for [SPAN_NOTICE("The floor:<br>&emsp; Overall Status: Healthy")]", 1)
			user.show_message("&emsp; Damage Specifics: <font color='#1F75D1'>[0]</font> - <font color='#138015'>[0]</font> - <font color='#CC7A1D'>[0]</font> - <font color='red'>[0]</font>", 1)
			user.show_message("&emsp; Key: <font color='#1F75D1'>Suffocation</font>/<font color='#138015'>Toxin</font>/<font color='#CC7A1D'>Burns</font>/<font color='red'>Brute</font>", 1)
			user.show_message(SPAN_NOTICE("Body Temperature: ???"), 1)
			JOB_XP(user, "Clown", 1)
			return

		user.visible_message(SPAN_ALERT("<b>[user]</b> has analyzed [target]'s vitals."),\
		SPAN_ALERT("You have analyzed [target]'s vitals."))
		playsound(src.loc , 'sound/items/med_scanner.ogg', 20, 0)
		boutput(user, scan_health(target, src.reagent_scan, src.disease_detection, src.organ_scan, visible = 1))

		DISPLAY_MAPTEXT(target, list(user), MAPTEXT_MOB_RECIPIENTS_WITH_OBSERVERS, /image/maptext/health, target)
		update_medical_record(target)

		if (isdead(target))
			user.unlock_medal("He's dead, Jim", 1)
		return

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (istype(A, /obj/machinery/clonepod))
			var/obj/machinery/clonepod/P = A
			if(P.occupant)
				user.visible_message(SPAN_ALERT("<b>[user]</b> has analyzed [P.occupant]'s vitals."),\
					SPAN_ALERT("You have analyzed [P.occupant]'s vitals."))
				boutput(user, scan_health(P.occupant, src.reagent_scan, src.disease_detection, src.organ_scan))
				update_medical_record(P.occupant)
				return
		..()



/obj/item/device/analyzer/healthanalyzer/upgraded
	icon_state = "health"
	reagent_upgrade = 1
	reagent_scan = 1
	organ_upgrade = 1
	organ_scan = 1

	New()
		..()
		scanner_status.icon_state = "health_over-both"
		AddOverlays(scanner_status, "status")

/obj/item/device/analyzer/healthanalyzer/vr
	icon = 'icons/effects/VR.dmi'

TYPEINFO(/obj/item/device/analyzer/healthanalyzer_upgrade)
	mats = 2

/obj/item/device/analyzer/healthanalyzer_upgrade
	name = "health analyzer upgrade"
	desc = "A small upgrade card that allows standard health analyzers to detect reagents present in the patient, and ProDoc Healthgoggles to scan patients' health from a distance."
	icon_state = "health_upgr"
	flags = TABLEPASS | CONDUCT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10

TYPEINFO(/obj/item/device/analyzer/healthanalyzer_organ_upgrade)
	mats = 2

/obj/item/device/analyzer/healthanalyzer_organ_upgrade
	name = "health analyzer organ scan upgrade"
	desc = "A small upgrade card that allows standard health analyzers to detect the health of induvidual organs in the patient."
	icon_state = "organ_health_upgr"
	flags = TABLEPASS | CONDUCT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10


TYPEINFO(/obj/health_scanner)
	mats = list("conductive" = 5,
				"crystal" = 2)
/obj/health_scanner
	icon = 'icons/obj/items/device.dmi'
	anchored = ANCHORED
	var/id = 0.0 // who are we?
	var/partner_range = 3 // how far away should we look?
	var/find_in_range = 1

	New()
		..()
		SPAWN(0.5 SECONDS)
			src.find_partners(src.find_in_range)
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	attackby(obj/item/W, mob/user)
		if (ispulsingtool(W))
			var/new_id = input(user, "Please enter new ID", src.name, src.id) as null|text
			if (!new_id || new_id == src.id)
				return
			src.id = new_id
			boutput(user, "You change [src]'s ID to [new_id].")
			src.find_partners()
		else
			return ..()

	proc/find_partners(var/in_range = 0)
		return // dummy proc that the scanner and screen will define themselves

/obj/health_scanner/wall
	name = "health status screen"
	desc = "A screen that shows health information received from connected floor scanners."
	icon_state = "wallscan1"
	var/list/partners // who do we know?
	var/examine_range = (SQUARE_TILE_WIDTH - 1) / 2 // from how far away can people examine the screen

	New()
		src.partners = list()
		..()

	get_desc(dist)
		if (dist > src.examine_range && !issilicon(usr))
			. += "<br>It's too far away to see what it says.[prob(10) ? " Who decided the text should be <i>that</i> small?!" : null]"
		else
			if (!src.partners || !length(src.partners))
				return . += "<font color='red'>ERROR: NO CONNECTED SCANNERS</font>"
			var/data = null
			for (var/obj/health_scanner/floor/my_partner in src.partners)
				data += my_partner.scan(ignore_cooldown = TRUE)
			if (data)
				. += "<br>It says:<br>[data]"
			else
				. += "<br>It says:<br><font color='red'>ERROR: NO SUBJECT(S) DETECTED</font>"

	attack_hand(mob/user)
		return user.examine_verb(src)

	attack_ai(mob/user)
		return user.examine_verb(src)

	find_partners(var/in_range = 0)
		if (in_range)
			for (var/obj/health_scanner/floor/possible_partner in orange(src.partner_range, src))
				src.add_partner(possible_partner)
		else
			for (var/obj/health_scanner/floor/possible_partner in by_type[/obj/health_scanner])
				LAGCHECK(LAG_LOW)
				if (possible_partner.id == src.id)
					src.add_partner(possible_partner)

	proc/add_partner(obj/health_scanner/floor/F)
		src.partners |= F

/obj/health_scanner/floor
	name = "health scanner"
	desc = "An in-floor health scanner that sends its data to connected status screens."
	icon_state = "floorscan1"
	plane = PLANE_FLOOR
	var/time_between_scans = 3 SECONDS

	New()
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)
		AddComponent(/datum/component/mechanics_holder)

	find_partners(var/in_range = 0)
		if (in_range)
			for (var/obj/health_scanner/wall/possible_partner in orange(src.partner_range, src))
				possible_partner.add_partner(src)
		else
			for (var/obj/health_scanner/wall/possible_partner in by_type[/obj/health_scanner])
				LAGCHECK(LAG_LOW)
				if (possible_partner.id == src.id)
					possible_partner.add_partner(src)

	Crossed(atom/movable/AM)
		..()
		if (ishuman(AM))
			boutput(AM, src.scan(TRUE))

	proc/scan(var/alert = FALSE, ignore_cooldown = FALSE)
		var/data = null
		if (!ignore_cooldown && ON_COOLDOWN(src, "scan_cooldown", time_between_scans))
			data += "<font color='red'>ERROR: SCANNER ON COOLDOWN</font>"
		else
			for (var/mob/living/carbon/human/H in get_turf(src))
				data += "[scan_health(H, 0, 0, 0, 1)]"
				DISPLAY_MAPTEXT(H, list(H), MAPTEXT_MOB_RECIPIENTS_WITH_OBSERVERS, /image/maptext/health, H)
				if (alert && H.health < 0)
					src.crit_alert(H)

				// signal stuff
				// this all ends up running twice because it's in scan_health too,
				// but not broken out in a way that we need
				var/health_percent = round(100 * H.health / (H.max_health||1))
				var/oxy = round(H.get_oxygen_deprivation())
				var/tox = round(H.get_toxin_damage())
				var/burn = round(H.get_burn_damage())
				var/brute = round(H.get_brute_damage())
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "health=[health_percent]&oxy=[oxy]&tox=[tox]&burn=[burn]&brute=[brute]")

			playsound(src.loc, 'sound/machines/scan2.ogg', 30, 0)
		return data

	proc/crit_alert(var/mob/living/carbon/human/H)
		var/datum/signal/new_signal = get_free_signal()
		new_signal.data = list("command"="text_message", "sender_name"="HEALTH-MAILBOT", "sender"="00000000", "address_1"="00000000", "group"=list(MGD_MEDICAL, MGA_MEDCRIT), "message"="CRIT ALERT: [H] in [get_area(src)].")
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, new_signal, null, "pda")


