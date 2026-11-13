/datum/db_record/personnel/bank

/datum/db_record/personnel/bank/build_fields()
	return alist(
		BUILD_FIELD("id",				/datum/record_field/string,			"ID", "000000", @"[a-f0-9]{6}"),
		BUILD_FIELD("pda_net_id",		/datum/record_field/string,			"PDA NetID"),
		BUILD_FIELD("wage",				/datum/record_field/number/wage,	"Wage", 0),
		BUILD_FIELD("current_money",	/datum/record_field/number/balance,	"Balance", 0),
		BUILD_FIELD("unionized",		/datum/record_field/choice,			"Unionised", "No", list("Yes", "No")),
		BUILD_FIELD("notes",			/datum/record_field/string,			"Important Notes", "No notes."),
	)

/datum/db_record/personnel/bank/disposing()
	global.wagesystem.budgets[BUDGET_CAT_PAYROLL] += src["current_money"]
	src["current_money"] = 0
	. = ..()

/datum/db_record/personnel/bank/init_from_human(mob/living/carbon/human/H)
	var/obj/item/device/pda2/pda = locate() in H
	var/datum/job/J = global.find_job_in_controller_by_string(H.job || H.mind.assigned_role)

	src["id"] = H.datacore_id
	src["pda_net_id"] = pda?.net_id
	src["wage"] = round(J?.wages)
	src["current_money"] = 100

	if (H.traitHolder?.hasTrait("unionized") && !((J?.job_category == JOB_COMMAND) || istype(J, /datum/job/special/random/vip)))
		src["unionized"] = "Yes"

		var/extra = round(src["wage"] * UNIONIZED_PAY_MULT)
		src["wage"] += extra
		global.wagesystem.union_stipend += extra

	global.wagesystem.payroll_stipend += src["wage"] * 1.1

/datum/db_record/personnel/bank/update_from_scan(mob/living/carbon/human/H)
	src["pda_net_id"] = astype(H.wear_id, /obj/item/device/pda2)?.net_id
