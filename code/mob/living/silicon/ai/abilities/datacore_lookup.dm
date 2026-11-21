ABSTRACT_TYPE(/datum/targetable/ai/program/datacore_lookup)
/datum/targetable/ai/program/datacore_lookup
	name = "Records Check"
	desc = "Look up records on your PDA."
	targeted = TRUE
	var/record_type = "Security"
	var/program_typepath = /datum/computer/file/pda_program/records/security

/datum/targetable/ai/program/datacore_lookup/cast(atom/target)
	. = ..()
	if (.)
		return .

	if (!ismob(src.holder.owner)) // ???
		return CAST_ATTEMPT_FAIL_CAST_FAILURE

	var/mob/M = src.holder.owner
	var/list/obj/item/device/pda2/PDAs = M.get_visible_pdas()
	if (!PDAs || length(PDAs) == 0)
		return CAST_ATTEMPT_FAIL_CAST_FAILURE

	var/obj/item/device/pda2/record_pda = null
	var/datum/computer/file/pda_program/records/record_prog = null
	for (var/obj/item/device/pda2/PDA in PDAs)
		var/list/programs = null
		for (var/obj/item/disk/data/mod in PDA.contents)
			programs += mod.root.contents.Copy()
		record_prog = locate(program_typepath) in programs
		if (istype(record_prog))
			record_pda = PDA
			break

	if (!record_pda)
		boutput(M, SPAN_ALERT("ERROR: No [record_type] records program in PDA!"))
		return CAST_ATTEMPT_FAIL_DO_COOLDOWN

	var/visibleName = target.name
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H.face_visible())
			visibleName = H.real_name

	var/datum/db_record/personnel/general/gen_record = global.data_core.get_general_record(visibleName)
	var/datum/db_record/personnel/secondary_record = src.get_secondary_record(visibleName)

	if (!istype(gen_record))
		boutput(M, SPAN_ALERT("ERROR: Missing general record for [visibleName]!"))
		return CAST_ATTEMPT_FAIL_DO_COOLDOWN

	if (!istype(secondary_record))
		boutput(M, SPAN_ALERT("ERROR: Missing [record_type] Record  for [visibleName]!"))
		return CAST_ATTEMPT_FAIL_DO_COOLDOWN

	record_pda.run_program(record_prog)
	record_prog.active1 = gen_record
	record_prog.active2 = secondary_record
	record_prog.mode = 1
	record_pda.AttackSelf(usr)

/datum/targetable/ai/program/datacore_lookup/proc/get_secondary_record(given_name)
	return global.data_core.get_security_record(given_name)

/datum/targetable/ai/program/datacore_lookup/security
	name = "Security Records Check"
	desc = "Look up security records on your PDA."
	icon_state = "rec_sec"
	record_type = "Security"
	program_typepath = /datum/computer/file/pda_program/records/security

	get_secondary_record(given_name)
		return global.data_core.get_security_record(given_name)

/datum/targetable/ai/program/datacore_lookup/medical
	name = "Medical Records Check"
	desc = "Look up medical records on your PDA."
	icon_state = "rec_med"
	record_type = "Medical"
	program_typepath = /datum/computer/file/pda_program/records/medical

	get_secondary_record(given_name)
		return global.data_core.get_medical_record(given_name)

/datum/targetable/ai/program/datacore_lookup/bank
	name = "Bank Records Check"
	desc = "Look up bank records on your PDA."
	icon_state = "rec_bank"
	record_type = "Bank"
	program_typepath = /datum/computer/file/pda_program/records/bank

	get_secondary_record(given_name)
		return global.data_core.get_bank_record(given_name)
