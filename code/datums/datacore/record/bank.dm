/datum/db_record/personnel/bank
	fields = alist(
		"id"			= new /datum/record_field/string("ID", "000000", @"[a-f0-9]{6}"),
		"name"			= new /datum/record_field/string("Name", "New Record"),
		"pda_net_id"	= new /datum/record_field/string("PDA NetID"),
		"wage"			= new /datum/record_field/number/wage("Wage", 0),
		"current_money"	= new /datum/record_field/number/balance("Balance", 0),
		"unionized"		= new /datum/record_field/choice("Unionised", "No", list("Yes", "No")),
		"notes"			= new /datum/record_field/string("Important Notes", "No notes."),
	)

/datum/db_record/personnel/bank/disposing()
	global.wagesystem.budgets[BUDGET_CAT_PAYROLL] += src["current_money"]
	src["current_money"] = 0
	. = ..()

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
