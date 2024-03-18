#define MAX_WAGES 10000
#define SHIPPING_BUDGET "Shipping"
#define PAYROLL_BUDGET "Payroll"
#define MEDICAL_BUDGET "Medical Research"

/obj/machinery/computer/bank_data
	name = "bank records"
	icon_state = "databank"
	req_access = list(access_heads)
	flags = TGUI_INTERACTIVE
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	circuit_type = /obj/item/circuitboard/bank_data

	var/obj/item/card/id/card = null
	var/authenticated = FALSE
	var/failedLogin = FALSE
	var/authenticatedAs = ""
	var/payroll_rate_limit_time = 0 //for preventing coammand message spam

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/card/id))
			if (!src.card)
				boutput(user, SPAN_NOTICE("You insert [I] into the authentication card slot."))
				user.drop_item()
				I.set_loc(src)
				src.card = I
				tgui_process.update_uis(src)
			else
				boutput(user, SPAN_NOTICE("There is already a card inserted."))

		else
			..()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "BankingComputer")
			ui.open()

	ui_act(action, list/params)
		. = ..()

		if (.)
			return

		var/doKeyboardSound = TRUE

		switch (action)
			if ("card_insertion")
				if (src.card)
					usr.put_in_hand_or_drop(src.card)
					src.card = null
				else
					var/obj/item/card/id/id_card = usr.equipped()

					if (istype(id_card))
						src.card = id_card
						usr.drop_item()
						id_card.set_loc(src)
				. = TRUE
				doKeyboardSound = FALSE

			if ("login")
				src.failedLogin = FALSE
				if (!src.authenticated)
					if (src.card)
						if (check_access(src.card))
							src.authenticated = TRUE
						else
							src.failedLogin = TRUE
					else if(issilicon(usr) || isAIeye(usr))
						src.authenticated = TRUE
				else
					src.authenticated = FALSE

				if (src.authenticated)
					src.authenticatedAs = src.card.registered
				. = TRUE

			if ("togglePayroll")
				if(world.time >= src.payroll_rate_limit_time)
					src.payroll_rate_limit_time = world.time + (10 SECONDS)
				else
					boutput(usr, SPAN_ALERT("Nanotrasen policy forbids the modification station payroll status more than once every ten seconds!"))
					return
				if (wagesystem.pay_active)
					wagesystem.pay_active = 0
					logTheThing(LOG_STATION, usr, "suspends the station payroll.")
					command_alert("The payroll has been suspended until further notice. No further wages will be paid until the payroll is resumed.","Payroll Announcement", alert_origin = ALERT_STATION)
				else
					wagesystem.pay_active = 1
					logTheThing(LOG_STATION, usr, "resumes the station payroll.")
					command_alert("The payroll has been resumed. Wages will now be paid into employee accounts normally.","Payroll Announcement", alert_origin = ALERT_STATION)

				doKeyboardSound = FALSE
				playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, -15)
				. = TRUE

			if ("transfer")
				handle_transfer(params)
				. = TRUE
			if ("edit_wage")
				var/id = params["id"]

				var/record = data_core.bank.find_record("id", id)
				if (record)
					var/newWage = tgui_input_number(usr, "Choose new wage", "Modify Wage", 0, MAX_WAGES, 0)
					if (newWage != null)
						logTheThing(LOG_STATION, usr, "sets <b>[record["name"]]</b>'s wage to [newWage][CREDIT_SIGN].")
						record["wage"] = newWage
				. = TRUE

		if (doKeyboardSound)
			playsound(src.loc, "keyboard", 50, 1, -15)

	proc/handle_transfer(params)
		if (!params)
			return

		var/fromType = params["fromType"]
		var/toType = params["toType"]
		var/fromId = params["fromId"]
		var/toId = params["toId"]

		if (!fromId || !fromType || !toId || !toType)
			return

		switch (fromType)
			if ("crew")
				var/maxWidthdrawable = get_crew_account_balance(fromId)
				var/amount = get_amount_to_transfer(maxWidthdrawable)
				if (!amount)
					return

				switch (toType)
					if ("crew")
						if (!get_crew_account_exists(toId))
							return

						modify_crew_account(fromId, -amount)
						modify_crew_account(toId, amount)
						logTheThing(
							LOG_STATION,
							usr,
							"transfers [amount][CREDIT_SIGN] to <b>[get_crew_account_name(toId)]</b>'s account from <b>[get_crew_account_name(fromId)]</b>'s account.")

					if ("budget")
						if (!get_budget_exists(toId))
							return

						modify_crew_account(fromId, -amount)
						modify_budget_balance(toId, amount)
						logTheThing(
							LOG_STATION,
							usr,
							"transfers [amount][CREDIT_SIGN] to <b>[toId] Budget</b> from <b>[get_crew_account_name(fromId)]</b>'s account.")

			if ("budget")
				var/maxWidthdrawable = get_budget_balance(fromId)
				var/amount = get_amount_to_transfer(maxWidthdrawable)
				if (!amount)
					return

				switch (toType)
					if ("crew")
						if (!get_crew_account_exists(toId))
							return

						modify_budget_balance(fromId, -amount)
						modify_crew_account(toId, amount)
						logTheThing(
							LOG_STATION,
							usr,
							"transfers [amount][CREDIT_SIGN] to <b>[get_crew_account_name(toId)]</b>'s account from <b>[fromId] Budget</b>.")

					if ("budget")
						if (!get_budget_exists(toId))
							return

						modify_budget_balance(fromId, -amount)
						modify_budget_balance(toId, amount)
						logTheThing(
							LOG_STATION,
							usr,
							"transfers [amount][CREDIT_SIGN] to <b>[toId] Budget</b> from <b>[fromId] Budget</b>.")



	proc/get_amount_to_transfer(max)
		. = tgui_input_number(
			usr,
			"Please select amount to transfer",
			"Transfer Amount",
			0,
			max,
			0)

	proc/modify_crew_account(id, amount)
		. = FALSE
		var/record = data_core.bank.find_record("id", id)
		if (record)
			record["current_money"] += amount
			. = TRUE

	proc/modify_budget_balance(budget_name, amount)
		. = TRUE

		switch (budget_name)
			if (SHIPPING_BUDGET)
				wagesystem.shipping_budget += amount

			if (MEDICAL_BUDGET)
				wagesystem.research_budget += amount

			if (PAYROLL_BUDGET)
				wagesystem.station_budget += amount
		. = FALSE

	proc/get_crew_account_balance(id)
		. = -1
		var/record = data_core.bank.find_record("id", id)
		if (record)
			. = record["current_money"]

	proc/get_crew_account_exists(id)
		var/record = data_core.bank.find_record("id", id)
		. = (record != null)

	proc/get_budget_exists(budget)
		return (budget in list(PAYROLL_BUDGET, SHIPPING_BUDGET, MEDICAL_BUDGET))

	proc/get_budget_balance(budget_name)
		. = -1

		switch (budget_name)
			if (SHIPPING_BUDGET)
				. = wagesystem.shipping_budget

			if (MEDICAL_BUDGET)
				. = wagesystem.research_budget

			if (PAYROLL_BUDGET)
				. = wagesystem.station_budget

	proc/get_crew_account_name(id)
		var record = data_core.bank.find_record("id", id)
		if (record)
			return record["name"]

	proc/gather_budget_info()
		var/list/shipping = list()
		shipping["name"] = SHIPPING_BUDGET
		shipping["amount"] = wagesystem.shipping_budget

		var/list/research = list()
		research["name"] = MEDICAL_BUDGET
		research["amount"] = wagesystem.research_budget

		var/list/payroll = list()
		payroll["name"] = PAYROLL_BUDGET
		payroll["amount"] = wagesystem.station_budget
		var/list/budgets = list(shipping, research, payroll)

		. = budgets

	ui_data(mob/user)
		var/list/data = new()
		data["authenticated"] = src.authenticated
		data["loggedInName"] = src.authenticatedAs
		data["cardInserted"] = src.card != null
		data["cardName"] = src.card?.name
		data["budgets"] = gather_budget_info()
		data["failedLogin"] = src.failedLogin

		if (src.authenticated)
			var/payrollSum = 0
			var/list/accounts = new()
			for(var/datum/db_record/record in data_core.bank.records)
				var/list/crewAccount = new()
				crewAccount["id"] = record["id"]
				crewAccount["wage"] = record["wage"]
				crewAccount["balance"] = record["current_money"]
				crewAccount["job"] = record["job"]
				crewAccount["name"] = record["name"]
				crewAccount["frozen"] = (record["name"] in FrozenAccounts)
				accounts += list(crewAccount)

				payrollSum += record["wage"]
			var/surplus = round(wagesystem.payroll_stipend - payrollSum)

			var/list/payroll = new()

			payroll["stipend"] = round(wagesystem.payroll_stipend)
			payroll["cost"] = payrollSum
			payroll["surplus"] = surplus
			payroll["total"] = round(wagesystem.total_stipend)
			data["payroll"] = payroll
			data["payrollActive"] = wagesystem.pay_active
			data["accounts"] = accounts
		. = data

/obj/machinery/computer/bank_data/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "bank1"
/obj/machinery/computer/bank_data/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "bank2"

#undef MAX_WAGES
#undef SHIPPING_BUDGET
#undef PAYROLL_BUDGET
#undef MEDICAL_BUDGET
