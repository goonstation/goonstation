/obj/machinery/computer/operating
	name = "Operating Computer"
	density = 1
	anchored = 1
	icon = 'icons/obj/computer.dmi'
	icon_state = "operating"
	desc = "Shows information on a patient laying on an operating table."
	can_reconnect = TRUE
	circuit_type = /obj/item/circuitboard/operating

	var/mob/living/carbon/human/victim = null

	var/obj/machinery/optable/table = null
	id = 0
	var/list/victim_data[][] = list()
	var/datum/computer/file/genetics_scan/gene_scan = null
	var/const/history_max = 25

/obj/machinery/computer/operating/New()
	..()
	SPAWN(0.5 SECONDS)
		connection_scan()

/obj/machinery/computer/operating/connection_scan()
	src.table = locate(/obj/machinery/optable, orange(2,src))

/obj/machinery/computer/operating/attack_hand(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer")
		ui.open()

/obj/machinery/computer/operating/process()
	..()
	if (status & (BROKEN | NOPOWER))
		return
	if(src.table && (src.table.check_victim()))
		src.victim = src.table.victim
	else
		src.victim = null
		src.gene_scan = null
		src.victim_data = null
	if (src.victim)
		src.gene_scan = create_new_dna_sample_file(src.victim)
		src.victim_data += list(sample_victim())
		if (length(src.victim_data) > src.history_max)
			src.victim_data.Cut(1, 2) //drop the oldest entry
		use_power(500)


/obj/machinery/computer/operating/proc/sample_victim()
	. = list()
	.["brute"] = src.victim?.get_brute_damage()
	.["burn"] = src.victim?.get_burn_damage()
	.["toxin"] = src.victim?.get_toxin_damage()
	.["oxygen"] = src.victim?.get_oxygen_deprivation()

/obj/machinery/computer/operating/ui_data(mob/user)
	. = list()
	.["occupied"] = istype(src.victim)
	if(!src.victim)
		return
	var/datum/color/blood_color_value = new()
	blood_color_value.from_hex(DEFAULT_BLOOD_COLOR)
	if(src.victim.bioHolder.bloodColor != null) {
		blood_color_value.from_hex(src.victim.bioHolder.bloodColor)
	}

	var/datum/statusEffect/simpledot/radiation/R = src.victim.hasStatus("radiation")
	if (R?.stage)
		.["rad_stage"] = R.stage
		.["rad_dose"] = src.victim.radiation_dose
	else
		.["rad_stage"] = 0
		.["rad_dose"] = 0

	.["occupied"] = istype(src.victim)
	.["patient_name"] = src.victim.real_name
	.["victim_status"] = src.victim.stat

	.["body_temp"] = src.victim.bodytemperature
	.["optimal_temp"] = src.victim.base_body_temp

	.["victim_data"] = src.victim_data

	.["max_health"] = round(src.victim.max_health)
	.["health"] = round(src.victim.health)
	.["brute"] = round(src.victim.get_brute_damage())
	.["burn"] = round(src.victim.get_burn_damage())
	.["toxin"] = round(src.victim.get_toxin_damage())
	.["oxygen"] = round(src.victim.get_oxygen_deprivation())

	.["blood_pressure"] = src.victim.blood_pressure
	.["brain_damage"] = calc_brain_damage_severity(src.victim)
	.["organ_status"] = vitim_organ_health(src.victim)

	.["age"] = src.victim.bioHolder.age
	.["blood_type"] = src.victim.bioHolder.bloodType
	.["blood_color_name"] = get_nearest_color(blood_color_value)
	.["blood_color_value"] = blood_color_value.to_rgb()
	.["clone_generation"] = src.victim.bioHolder.clone_generation
	.["genetic_stability"] = src.victim.bioHolder.genetic_stability

	.["cloner_defects"] = 0
	if (src.victim.cloner_defects)
		var/datum/cloner_defect_holder/cloner_defects = src.victim.cloner_defects
		var/list/datum/cloner_defect/active_cloner_defects = cloner_defects.active_cloner_defects
		.["cloner_defects"] = length(active_cloner_defects)

	.["reagent_container"] = ui_describe_reagents(src.victim)


/obj/machinery/computer/operating/proc/vitim_organ_health(var/mob/living/carbon/human/H)
	var/list/organ_data = list()

	if (isvampire(H))
		return organ_data
	if (!H.organHolder)
		return organ_data

	var/list/organs_to_check = list("heart", "left_eye", "right_eye", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
	if(H.organHolder.tail || H.mob_flags & SHOULD_HAVE_A_TAIL)
		organs_to_check += "tail"

	for (var/organ_name in organs_to_check)
		var/obj/item/organ/O = H.get_organ(organ_name)
		var/dmg_calc = null
		var/special = null
		if (O == 0 || !O)
			dmg_calc = "Missing"
		else
			if (O.robotic)
				special = "Cybernetic"
			if (O.unusual)
				special = "Unusual"
			if (O.synthetic)
				special = "Synthetic"
			dmg_calc = calc_organ_damage_severity(O)

		organ_data += list(list(
			"organ_name" = organ_name,
			"organ_state" = dmg_calc,
			"special" = special,
		))

	return organ_data

/obj/machinery/computer/operating/proc/calc_brain_damage_severity(var/mob/living/carbon/human/H)
	var/brain = H.get_organ("brain")
	if (brain == 0)
		return "Missing"
	var/brain_damage = H.get_brain_damage()
	if(brain_damage >= 100)
		return "Braindead"
	if(brain_damage >= 60)
		return "Severe"
	if(brain_damage >= 10)
		return "Significant"
	return "Okay"

/obj/machinery/computer/operating/proc/calc_organ_damage_severity(var/obj/item/organ/O)
	var/damage = O.get_damage()
	if (damage >= O.max_damage)
		return "Dead"
	if (damage >= O.max_damage*0.9)
		return "Critical"
	if (damage >= O.max_damage*0.65)
		return "Significant"
	if (damage >= O.max_damage*0.3)
		return "Moderate"
	if (damage > 0)
		return "Minor"
	return "Okay"
