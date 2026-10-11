/datum/db_manager_menu/station_budget

/datum/db_manager_menu/station_budget/load()
	var/text = ""

	text += "<br><center><b>Station Budget</b></center>"
	text += "<br><b>Payroll Budget</b>.." + num2text(round(global.wagesystem.budgets[BUDGET_CAT_PAYROLL]), 50) + CREDIT_SIGN
	text += "<br><b>Medical Budget</b>.." + num2text(round(global.wagesystem.budgets[BUDGET_CAT_DEPT_MEDICAL]), 50) + CREDIT_SIGN
	text += "<br><b>Supply Budget</b>..." + num2text(round(global.wagesystem.budgets[BUDGET_CAT_DEPT_SUPPLY]), 50) + CREDIT_SIGN
	text += "<br><b>Union Budget</b>...." + num2text(round(global.wagesystem.budgets[BUDGET_CAT_UNION]), 50) + CREDIT_SIGN

	text += "<br><br><center><b>Payroll Cycle Details</b></center>"
	text += "<br><b>Per-Cycle Stipend</b>.." + num2text(round(global.wagesystem.payroll_stipend), 50) + CREDIT_SIGN

	var/payroll = 0
	for (var/datum/db_record/R as anything in global.data_core.bank.records)
		payroll += R["wage"]

	text += "<br><b>Per-Cycle Cost</b>....." + "-" + num2text(round(payroll), 50) + CREDIT_SIGN

	var/surplus = round(global.wagesystem.payroll_stipend - payroll)
	if (surplus >= 0)
		text += "<br><b>Surplus Surplus</b>...." + "+" + num2text(round(surplus), 50) + CREDIT_SIGN
	else
		text += "<br><b>Surplus Deficit</b>...." + num2text(round(surplus), 50) + CREDIT_SIGN

	text += "<br><br><b>Commands:</b>"
	if (global.wagesystem.pay_active)
		text += "<br>(1) Suspend Payroll."
	else
		text += "<br>(1) Resume Payroll."

	text += "<br>(2) Transfer Funds Between Budgets."
	text += "<br>(3) Issue Staff Bonus."
	text += "<br>(0) Go Back."

	src.parent.print_text(text)

/datum/db_manager_menu/station_budget/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))

	switch (index_number)
		if (0)
			src.parent.switch_menu_to("main")

		if (1)
			if (ON_COOLDOWN(global, "payroll_status_change", 10 SECONDS))
				src.parent.print_text("<b>Error:</b> Nanotrasen policy forbids the modification station payroll status more than once every ten seconds!")
				return

			if (global.wagesystem.pay_active)
				global.wagesystem.pay_active = FALSE
				logTheThing(LOG_STATION, usr, "has suspended the station payroll.")
				global.command_alert("The payroll has been suspended until further notice. No further wages will be paid until the payroll is resumed.","Payroll Announcement", alert_origin = ALERT_STATION)

			else
				global.wagesystem.pay_active = TRUE
				logTheThing(LOG_STATION, usr, "has resumed the station payroll.")
				global.command_alert("The payroll has been resumed. Wages will now be paid into employee accounts normally.","Payroll Announcement", alert_origin = ALERT_STATION)

			src.parent.switch_menu_to("station_budget")

		if (2)
			src.parent.switch_menu_to("transfer_funds")

		if (3)
			src.parent.switch_menu_to("issue_bonus")
