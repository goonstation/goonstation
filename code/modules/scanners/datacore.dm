// Contents
// Get General record global proc
// Get/update medical record global proc
// get security record global proc


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
