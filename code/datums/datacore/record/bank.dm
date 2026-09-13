/datum/db_record/personnel/bank
	fields = list(
		"id"			= null,
		"name"			= null,
		"pda_net_id"	= null,
		"wage"			= 0,
		"current_money"	= 0,
		"unionized"		= "No",
		"notes"			= "No notes.",
	)

/datum/db_record/personnel/bank/init_from_human(mob/living/carbon/human/H)
	var/obj/item/device/pda2/pda = locate() in H
	var/datum/job/J = global.find_job_in_controller_by_string(H.job || H.mind.assigned_role)

	src["id"] = H.datacore_id
	src["name"] = H.real_name
	src["pda_net_id"] = pda?.net_id
	src["wage"] = round(J?.wages)
	src["current_money"] = 100

	if (H.traitHolder?.hasTrait("unionized") && !((J?.job_category == JOB_COMMAND) || istype(J, /datum/job/special/random/vip)))
		src["unionized"] = "Yes"

		var/extra = round(src["wage"] * UNIONIZED_PAY_MULT)
		src["wage"] += extra
		global.wagesystem.union_stipend += extra

	global.wagesystem.payroll_stipend += src["wage"] * 1.1
