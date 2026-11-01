/datum/db_manager_menu/transfer_funds
	VAR_PRIVATE/transfer_from = null
	VAR_PRIVATE/transfer_to = null
	VAR_PRIVATE/static/list/budgets = list(
		BUDGET_CAT_PAYROLL		= "Payroll",
		BUDGET_CAT_DEPT_MEDICAL	= "Medical",
		BUDGET_CAT_DEPT_SUPPLY	= "Supply",
		BUDGET_CAT_UNION		= "Union",
	)

/datum/db_manager_menu/transfer_funds/load(transfer_from, transfer_to)
	src.transfer_from = transfer_from
	src.transfer_to = transfer_to

	var/text = ""

	text += "<b>Transferring From:</b> "
	if (src.transfer_from)
		text += src.budgets[src.transfer_from] + " (" + num2text(round(global.wagesystem.budgets[src.transfer_from]), 50) + CREDIT_SIGN + ")"

	text += "<br><b>Transferring To:</b>   "
	if (src.transfer_to)
		text += src.budgets[src.transfer_to] + " (" + num2text(round(global.wagesystem.budgets[src.transfer_to]), 50) + CREDIT_SIGN + ")"

	if (!src.transfer_from)
		text += "<br><br>Select budget to transfer FROM:"
		for (var/i in 1 to length(src.budgets))
			text += "<br>    ([i]) [src.budgets[src.budgets[i]]]"

		text += "<br>    (0) Back<br>"

	else if (!src.transfer_to)
		text += "<br><br>Select budget to transfer TO:"
		for (var/i in 1 to length(src.budgets))
			text += "<br>    ([i]) [src.budgets[src.budgets[i]]]"

		text += "<br>    (0) Back<br>"

	else
		text += "<br><br>Input how much money to transfer. Enter '0' to return."

	src.parent.print_text(text)

/datum/db_manager_menu/transfer_funds/unload()
	src.transfer_from = null
	src.transfer_to = null

/datum/db_manager_menu/transfer_funds/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(command)

	if (index_number == 0)
		if (!src.transfer_from)
			src.parent.switch_menu_to("station_budget")
		else if (!src.transfer_to)
			src.parent.switch_menu_to("transfer_funds")
		else
			src.parent.switch_menu_to("transfer_funds", src.transfer_from)

		return

	if (src.transfer_from && src.transfer_to)
		if (index_number < 0)
			src.parent.print_text("<b>Error:</b> You must choose a positive number to transfer.")
			return

		var/amount = min(index_number, global.wagesystem.budgets[src.transfer_from])

		global.wagesystem.budgets[src.transfer_from] -= amount
		global.wagesystem.budgets[src.transfer_to] += amount
		logTheThing(LOG_STATION, usr, "has transferred [amount][CREDIT_SIGN] from the [src.budgets[src.transfer_from]] budget to the [src.budgets[src.transfer_to]] budget.")

		src.parent.print_text("<br>[amount][CREDIT_SIGN] transferred from [src.budgets[src.transfer_from]] to [src.budgets[src.transfer_to]].")
		src.wait(2 SECONDS)
		src.parent.switch_menu_to("station_budget")
		return

	index_number = max(index_number, 0)
	if (index_number > length(src.budgets))
		src.parent.print_text("<b>Error:</b> Invalid choice.")
		return

	var/choice = src.budgets[index_number]
	if (!src.transfer_from)
		src.parent.switch_menu_to("transfer_funds", choice)
	else if (choice == src.transfer_from)
		src.parent.print_text("<b>Error:</b> You can't transfer a budget into itself.")
	else
		src.parent.switch_menu_to("transfer_funds", src.transfer_from, choice)
