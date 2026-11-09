/datum/record_field/number/balance
	lower = 0
	upper = INFINITY

/datum/record_field/number/balance/get_display_value()
	return "[src.value]" + CREDIT_SIGN

/datum/record_field/number/balance/input_load(datum/db_manager_menu/field_input/menu)
	var/text = "Please enter amount to transfer from payroll budget (" + num2text(round(global.wagesystem.budgets[BUDGET_CAT_PAYROLL]), 50) + CREDIT_SIGN + ") to account:"
	menu.parent.print_text(text)

/datum/record_field/number/balance/input_text(datum/db_manager_menu/field_input/menu, text)
	var/command = global.text2num_safe(menu.parent.parse_string(text)[1])
	var/amount = round(command)

	if (amount == 0)
		return TRUE

	var/budget = global.wagesystem.budgets[BUDGET_CAT_PAYROLL]
	if (amount > budget)
		menu.parent.print_text("<b>Error:</b> Attempted to transfer [amount][CREDIT_SIGN] from payroll, but payroll budget is only [budget][CREDIT_SIGN].")
		return

	if (-amount > src.value)
		menu.parent.print_text("<b>Error:</b> Attempted to transfer [-amount][CREDIT_SIGN] from account, but account balance is only [src.value][CREDIT_SIGN].")
		return

	var/new_value = src.value + amount
	var/error = src.validate(new_value)
	if (istext(error))
		menu.parent.print_text("<b>Error:</b> [error]")
		return

	if (amount > 0)
		logTheThing(LOG_STATION, usr, "transferred [amount][CREDIT_SIGN] from payroll budget to [menu.record["name"]]'s account.")
	else
		logTheThing(LOG_STATION, usr, "transferred [-amount][CREDIT_SIGN] from [menu.record["name"]]'s account to payroll budget.")

	global.wagesystem.budgets[BUDGET_CAT_PAYROLL] -= amount
	src.set_value(new_value)
	return TRUE
