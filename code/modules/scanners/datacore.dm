// Contents
// Get General record global proc
// Get/update medical record global proc
// get security record global proc


/proc/update_medical_record(var/mob/living/carbon/human/M)
	if (!istype(M))
		return

	var/patientname = M.name
	if (M:wear_id && M:wear_id:registered)
		patientname = M.wear_id:registered

	var/datum/db_record/personnel/general/E = global.data_core.get_general_record(patientname)
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

	var/datum/db_record/personnel/medical/R = global.data_core.get_medical_record(patientname)
	if(!R)
		return

	R["blood_type"] = M.bioHolder.bloodType
	R["cdi"] = english_list(M.ailments, "No diseases have been diagnosed at the moment.")
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
	var/datum/db_record/personnel/general/GR = global.data_core.get_general_record(H.name)
	var/datum/db_record/personnel/medical/MR = global.data_core.get_medical_record(H.name)
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
	var/datum/db_record/personnel/general/GR = global.data_core.get_general_record(H.name)
	var/datum/db_record/personnel/security/SR = global.data_core.get_security_record(H.name)
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
