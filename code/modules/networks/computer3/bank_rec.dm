/// Prevent input detection, used for networking
#define MENU_HOLD -1
#define MENU_MAIN 0
#define MENU_INDEX 1
#define MENU_IN_RECORD 2
#define MENU_FIELD_INPUT 3
#define MENU_SEARCH_INPUT 4
#define MENU_SEARCH_PICK 5
#define MENU_BALANCE_TRANSFER 6
#define MENU_STATION_BUDGET 7
#define MENU_BUDGET_TRANSFER 8
#define MENU_BUDGET_TRANSFER_FROM 9
#define MENU_BUDGET_TRANSFER_TO 10
#define MENU_BUDGET_TRANSFER_AMOUNT 11
#define MENU_STAFF_BONUS_TEAM 12
#define MENU_STAFF_BONUS_AMOUNT 13
#define MENU_STAFF_BONUS_REASON 14
#define MENU_PRINT_SETTINGS 15
#define MENU_SELECT_PRINTER 16

// menu options
// main menu
#define MENU_MAIN_OPT_QUIT 0
#define MENU_MAIN_OPT_INDEX 1
#define MENU_MAIN_OPT_SEARCH 2
#define MENU_MAIN_OPT_BUDGET 3
#define MENU_MAIN_OPT_PRINT 4
// budget menu
#define MENU_BUDGET_OPT_BACK 0
#define MENU_BUDGET_OPT_PAYROLL 1
#define MENU_BUDGET_OPT_TRANSFER 2
#define MENU_BUDGET_OPT_BONUS 3
// transfer menu
#define MENU_TRANSFER_OPT_BACK 0
#define MENU_TRANSFER_OPT_PAYROLL 1
#define MENU_TRANSFER_OPT_SHIPPING 2
#define MENU_TRANSFER_OPT_RESEARCH 3
// print menu
#define MENU_PRINT_OPT_BACK 0
#define MENU_PRINT_OPT_CONNECT 1
#define MENU_PRINT_OPT_SELECT 2
#define MENU_PRINT_OPT_PRINTLOG 3

// team bonuses
#define BONUS_BACK 0
#define BONUS_STATIONWIDE 1
#define BONUS_GENETICS 2
#define BONUS_ROBOTICS 3
#define BONUS_MEDICAL 4
#define BONUS_CARGO 5
#define BONUS_MINING 6
#define BONUS_ENGINEERING 7
#define BONUS_CATERING 8
#define BONUS_HYDROPONICS 9
#define BONUS_CIVILIAN 10
#define BONUS_RESEARCH 11
#define BONUS_SECURITY 12
#define BONUS_MAX_CHOICE 12

// record fields
// general record
#define FIELDNUM_NAME 1
#define FIELDNUM_FULLNAME 2
#define FIELDNUM_SEX 3
#define FIELDNUM_PRONOUNS 4
#define FIELDNUM_AGE 5
#define FIELDNUM_RANK 6
// bank record
#define FIELDNUM_WAGE 7
#define FIELDNUM_BALANCE 8
#define FIELDNUM_NOTES 9
#define FIELDNUM_DELETE "d"
#define FIELDNUM_NEWREC "new"

#define BONUS_REASON_MAX 200

/datum/computer/file/terminal_program/bank_records
	name = "BankBoss"
	size = 12
	req_access = list(access_money)
	var/tmp/menu = MENU_MAIN
	var/tmp/field_input = 0
	var/datum/record_database/record_database = list()
	var/datum/db_record/active_general = null
	var/datum/db_record/active_bank = null
	var/log_string = null
	var/list/datum/db_record/possible_active = null

	var/tmp/transfer_from = null
	var/tmp/transfer_to = null
	var/tmp/bonus_team = null
	var/tmp/list/datum/db_record/bonus_crew = list()
	var/tmp/bonus_amount = null

	/// Payroll-oriented team list, more granulary defined than department lists
	var/static/list/teams = list(
		"Stationwide",
		"Genetics",
		"Robotics",
		"Medical",
		"Cargo",
		"Mining",
		"Engineering",
		"Catering",
		"Hydroponics",
		"Civilian",
		"Research",
		"Security",
	)

	var/static/list/budgets = list(
		"Payroll",
		"Shipping",
		"Research",
	)

	var/static/list/team_to_job_datum = list(
		"Stationwide" = list(),
		"Genetics" = list(/datum/job/medical/geneticist),
		"Robotics" = list(/datum/job/medical/roboticist),
		"Cargo" = list(/datum/job/engineering/quartermaster, /datum/job/civilian/mail_courier),
		"Mining" = list(/datum/job/engineering/miner),
		"Engineering" = list(/datum/job/engineering/engineer, /datum/job/engineering/technical_assistant, /datum/job/command/chief_engineer),
		"Research" = list(/datum/job/research/scientist, /datum/job/research/research_assistant, /datum/job/command/research_director),
		"Catering" = list(/datum/job/civilian/chef, /datum/job/civilian/bartender, /datum/job/special/souschef, /datum/job/daily/waiter),
		"Hydroponics" = list(/datum/job/civilian/botanist, /datum/job/civilian/rancher),
		"Security" = list(/datum/job/security, /datum/job/command/head_of_security),
		"Medical" = list(/datum/job/medical/medical_doctor, /datum/job/medical/medical_assistant, /datum/job/command/medical_director),
		"Civilian" = list(/datum/job/civilian/janitor, /datum/job/civilian/chaplain, /datum/job/civilian/staff_assistant, /datum/job/civilian/clown,\
		/datum/job/special), //Who really makes the world go round? At least one of these guys
							//I can live with the sous chef getting paid in two categories
							//If you have a special role and you're on the manifest everything is probably normal
	)

	// printer stuff
	var/tmp/connected = FALSE
	var/tmp/server_netid = null
	var/tmp/potential_server_netid = null
	var/tmp/selected_printer = null
	var/tmp/list/known_printers = list()
	var/tmp/printer_status = "???"

	var/setup_logdump_name = "banklog"
	var/setup_mail_freq = FREQ_PDA

/datum/computer/file/terminal_program/bank_records/initialize()
	if (..())
		return TRUE

	src.record_database = data_core.general
	src.master.temp = null
	src.menu = MENU_MAIN
	src.field_input = 0

	src.log_string += "<br><b>LOGIN:</b> [src.authenticated]"

	src.print_text(src.mainmenu_text())

/datum/computer/file/terminal_program/bank_records/input_text(text)
	if(..())
		return

	var/list/command_list = parse_string(text)
	var/command = command_list[1]
	command_list -= command_list[1]

	switch(menu)
		if(MENU_MAIN)
			switch(text2num_safe(command))
				if(MENU_MAIN_OPT_QUIT)
					src.print_text("Quitting...")
					src.autosave_log()
					src.master.unload_program(src)
					return
				if(MENU_MAIN_OPT_INDEX)
					src.record_database = data_core.general
					src.menu = MENU_INDEX
					src.print_index()
				if(MENU_MAIN_OPT_SEARCH)
					src.print_text("Please enter target name, ID, or rank.")
					src.menu = MENU_SEARCH_INPUT
					return
				if(MENU_MAIN_OPT_BUDGET)
					src.print_budget()
					src.menu = MENU_STATION_BUDGET
					return
				if(MENU_MAIN_OPT_PRINT)
					src.print_settings()
					src.menu = MENU_PRINT_SETTINGS
					return

		if(MENU_INDEX)
			if (lowertext(command) == FIELDNUM_NEWREC)
				var/datum/db_record/general_record = new
				general_record["name"] = "New Record"
				general_record["full_name"] = "New Record"
				general_record["id"] = "[num2hex(rand(1, 0xffffff), 6)]"
				general_record["rank"] = "Unassigned"
				general_record["sex"] = "Other"
				general_record["pronouns"] = "Unknown"
				general_record["age"] = "Unknown"
				general_record["fingerprint"] = "Unknown"
				general_record["p_stat"] = "Active"
				general_record["m_stat"] = "Stable"
				data_core.general.add_record(general_record)
				src.active_general = general_record
				src.active_bank = null
				src.log_wrapper("Created new general record [general_record["id"]].")

				if (src.print_active_record())
					src.menu = MENU_IN_RECORD
				return

			var/index_number = round(max(text2num_safe(command), 0))
			if (index_number == 0)
				src.menu = MENU_MAIN
				src.master.temp = null
				src.print_text(mainmenu_text())
				return

			if (!istype(record_database) || index_number > record_database.records.len)
				src.print_text("Invalid record.")
				return

			var/datum/db_record/check = src.record_database.records[index_number]
			if (!check || !istype(check))
				src.print_text("<b>Error:</b> Record Data Invalid.")
				return

			src.active_general = check
			if (data_core.general.has_record(check))
				src.active_bank = data_core.bank.find_record("id", src.active_general["id"])
				if (!src.active_bank)
					data_core.bank.find_record("name", src.active_general["name"])

			src.log_string += "<br>Loaded record [src.active_general["id"]] for [src.active_general["name"]]"

			if (src.print_active_record())
				src.menu = MENU_IN_RECORD
			return
		if(MENU_IN_RECORD)
			switch(lowertext(command))
				if ("r")
					src.print_active_record()
					return
				if ("d")
					src.print_text("Are you sure? (Y/N)")
					src.field_input = FIELDNUM_DELETE
					src.menu = MENU_FIELD_INPUT
					return
				if ("p")
					if ((src.connected && src.selected_printer) && !src.network_record_print())
						src.print_text("Print instruction sent to remote printer.")
					else
						if (src.local_record_print())
							src.print_text("<b>Error:</b> No printer detected.")
						else
							src.print_text("Print instruction sent to local printer.")
					return
				if (FIELDNUM_NEWREC)
					if (src.active_bank)
						return

					var/datum/db_record/B = new /datum/db_record( )
					B["name"] = src.active_general["name"]
					B["id"] = src.active_general["id"]
					B["current_money"] = 0
					B["wage"] = 0
					B["pda_net_id"] = null
					B["notes"] = "No notes."
					data_core.bank.add_record(B)
					src.active_bank = B

					src.print_active_record()
					src.menu = MENU_IN_RECORD
					return

			var/field_number = round( max( text2num_safe(command), 0) )
			if (field_number == 0)
				src.menu = MENU_INDEX
				src.print_index()
				return

			src.field_input = field_number
			switch(field_number)
				if(FIELDNUM_NAME, FIELDNUM_FULLNAME, FIELDNUM_AGE, FIELDNUM_RANK, FIELDNUM_NOTES, FIELDNUM_WAGE)
					src.print_text("Please enter new value.")
					src.menu = MENU_FIELD_INPUT
					return

				if(FIELDNUM_SEX)
					src.print_text("Please select: (1) Female (2) Male (3) Other (0) Back")
					src.menu = MENU_FIELD_INPUT
					return

				if(FIELDNUM_PRONOUNS)
					var/list/pronoun_types = filtered_concrete_typesof(/datum/pronouns, /proc/pronouns_filter_is_choosable)
					var/list/text_parts = list("Please select: ")
					for (var/pronoun_type in pronoun_types)
						var/datum/pronouns/pronouns = get_singleton(pronoun_type)
						text_parts += pronouns.name
						text_parts += ", "
					text_parts += " (0) Back"
					src.print_text(jointext(text_parts, ""))
					src.menu = MENU_FIELD_INPUT
					return

				if(FIELDNUM_BALANCE)
					src.print_text("Amount to transfer. Enter '0' to cancel:")
					src.menu = MENU_FIELD_INPUT
					return

		if(MENU_FIELD_INPUT)
			if (!src.active_general)
				src.print_text("<b>Error:</b> Record invalid.")
				src.menu = MENU_INDEX
				return

			var/inputText = strip_html(text)
			switch(field_input)
				if(FIELDNUM_NAME)
					if (ckey(inputText))
						src.active_general["name"] = copytext(inputText, 1, FULLNAME_MAX)
					else
						return

				if(FIELDNUM_FULLNAME)
					if (ckey(inputText))
						src.active_general["full_name"] = copytext(inputText, 1, FULLNAME_MAX)
					else
						return

				if(FIELDNUM_SEX)
					switch (round(max(text2num_safe(command), 0)))
						if (1)
							src.active_general["sex"] = "Female"
						if (2)
							src.active_general["sex"] = "Male"
						if (3)
							src.active_general["sex"] = "Other"
						if (0)
							src.menu = MENU_IN_RECORD
							return
						else
							return

				if(FIELDNUM_PRONOUNS)
					if (inputText == "0")
						src.menu = MENU_IN_RECORD
						return
					var/list/pronoun_types = filtered_concrete_typesof(/datum/pronouns, /proc/pronouns_filter_is_choosable)
					for (var/pronoun_type in pronoun_types)
						var/datum/pronouns/pronouns = get_singleton(pronoun_type)
						if (pronouns.name == inputText)
							src.active_general["pronouns"] = pronouns.name
							return
					src.print_text("Invalid pronouns.")
					return

				if(FIELDNUM_AGE)
					var/newAge = round( min( text2num_safe(command), 99) )
					if (newAge < 1)
						src.print_text("Invalid age value. Please re-enter.")
						return

					src.active_general["age"] = newAge

				if(FIELDNUM_WAGE)
					if (!src.active_bank)
						src.print_text("No bank record loaded!")
						src.menu = MENU_IN_RECORD
						return
					var/newWage = round(text2num_safe(command))
					if (newWage < 0)
						src.print_text("<b>Error</b>: You cannot set a negative wage.")
						return
					if (newWage > 10000)
						src.print_text("<b>Warning:</b> Maximum wage is 10,000[CREDIT_SIGN]")
						newWage = 10000

					src.log_wrapper("Set wage for [src.active_general["name"]] from [src.active_bank["wage"]][CREDIT_SIGN] to [newWage][CREDIT_SIGN]")
					src.active_bank["wage"] = newWage

				if(FIELDNUM_BALANCE)
					if (inputText == "0")
						src.print_text("Transfer cancelled.")
						src.menu = MENU_IN_RECORD
						return
					if (!src.active_bank)
						src.print_text("No bank record loaded!")
						src.menu = MENU_IN_RECORD
						return

					var/balanceChange = round(text2num_safe(command))
					switch(balanceChange)
						if (-INFINITY to 0)
							if ((src.active_bank["current_money"] + balanceChange) < 0)
								src.print_text("<b>Warning:</b> [src.active_general["name"]] only has [src.active_bank["current_money"]][CREDIT_SIGN] in account!")
								balanceChange = -src.active_bank["current_money"]
							src.log_wrapper("Transferred [abs(balanceChange)][CREDIT_SIGN] from [src.active_general["name"]]'s account to payroll budget.")
							src.active_bank["current_money"] += balanceChange
							global.wagesystem.station_budget -= balanceChange // balanceChange is negative here, this adds to the budget
						if (0 to INFINITY)
							if (global.wagesystem.station_budget < balanceChange)
								src.print_text("<b>Warning:</b> Station budget only has [global.wagesystem.station_budget][CREDIT_SIGN] available!")
								balanceChange = global.wagesystem.station_budget
							src.log_wrapper("Transferred [abs(balanceChange)][CREDIT_SIGN] from payroll budget to [src.active_general["name"]]'s account.")
							src.active_bank["current_money"] += balanceChange
							global.wagesystem.station_budget -= balanceChange
					src.menu = MENU_IN_RECORD
				if(FIELDNUM_NOTES)
					if (!src.active_bank)
						src.print_text("No bank record loaded!")
						src.menu = MENU_IN_RECORD
						return
					if (ckey(inputText))
						src.active_bank["notes"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
					else
						return

				if(FIELDNUM_DELETE)
					switch(ckey(inputText))
						if ("y")
							if (src.active_bank)
								global.wagesystem.station_budget += src.active_bank["current_money"]
								src.log_wrapper("Transferred [src.active_bank["current_money"]][CREDIT_SIGN] from [src.active_bank["name"]] into payroll budget.")
								src.log_wrapper("Deleted bank record [src.active_bank["id"]] for [src.active_general["name"]]")
								qdel(src.active_bank)
								src.active_bank = null
								src.print_active_record()
								src.menu = MENU_IN_RECORD
							else if (src.active_general)
								src.log_wrapper("Deleted general record [src.active_general["id"]] for [src.active_general["name"]]")
								qdel(src.active_general)
								src.active_general = null
								src.menu = MENU_INDEX
								src.print_index()
						if ("n")
							src.menu = MENU_IN_RECORD
							src.print_text("Record preserved.")

			src.print_text("Field updated.")
			src.menu = MENU_IN_RECORD

		if(MENU_SEARCH_PICK)
			var/input = text2num_safe(ckey(strip_html(text)))
			if(isnull(input) || input < 0 || input >> length(src.possible_active))
				src.print_text("Cancelled")
				src.menu = MENU_MAIN
				return

			var/datum/db_record/result = src.possible_active[input]
			src.active_general = result
			src.active_bank = data_core.bank.find_record("id", src.active_general["id"])
			if(!src.active_bank)
				data_core.bank.find_record("name", src.active_general["name"])

			src.menu = MENU_IN_RECORD
			src.print_active_record()

		if(MENU_SEARCH_INPUT)
			var/searchText = ckey(strip_html(text))
			if (!searchText)
				return

			var/list/datum/db_record/results = list()
			for(var/datum/db_record/R as anything in data_core.general.records)
				var/haystack = jointext(list(ckey(R["name"]), ckey(R["dna"]), ckey(R["id"]), ckey(R["fingerprint"]), ckey(R["rank"])), " ")
				if(findtext(haystack, searchText))
					results += R

			var/datum/db_record/result = null
			if(length(results) == 1)
				result = results[1]
			else if(length(results) > 1)
				src.print_text("Multiple results found:")
				var/i = 1
				for(var/datum/db_record/R as anything in results)
					src.print_text("\[[i++]\] [R["name"]]")
				src.print_text("\[0\] Cancel")
				src.menu = MENU_SEARCH_PICK
				src.possible_active = results
				return

			if(!result)
				src.print_text("No results found.")
				src.menu = MENU_MAIN
				return

			src.active_general = result
			src.active_bank = data_core.bank.find_record("id", src.active_general["id"])
			if(!src.active_bank)
				data_core.bank.find_record("name", src.active_general["name"])

			src.menu = MENU_IN_RECORD
			src.print_active_record()
			return

		if(MENU_STATION_BUDGET)
			switch(round(text2num_safe(command)))
				if(MENU_BUDGET_OPT_BACK)
					src.menu = MENU_MAIN
					src.master.temp = null
					src.print_text(src.mainmenu_text())
					return
				if(MENU_BUDGET_OPT_PAYROLL)
					if (ON_COOLDOWN(global, "payroll_status_change", 10 SECONDS))
						src.print_text("<b>Error:</b> Nanotrasen policy forbids the modification station payroll status more than once every ten seconds!")
						return
					if (global.wagesystem.pay_active)
						global.wagesystem.pay_active = 0
						src.log_wrapper("Suspended station payroll.")
						command_alert("The payroll has been suspended until further notice. No further wages will be paid until the payroll is resumed.","Payroll Announcement", alert_origin = ALERT_STATION)
					else
						global.wagesystem.pay_active = 1
						src.log_wrapper("Resumed station payroll.")
						command_alert("The payroll has been resumed. Wages will now be paid into employee accounts normally.","Payroll Announcement", alert_origin = ALERT_STATION)
					src.print_budget()

				if(MENU_BUDGET_OPT_TRANSFER)
					src.menu = MENU_BUDGET_TRANSFER_FROM
					src.print_text("Select budget to transfer FROM:")
					src.print_transfer_opts()
				if(MENU_BUDGET_OPT_BONUS)
					src.menu = MENU_STAFF_BONUS_TEAM
					src.print_teams()


		if(MENU_BUDGET_TRANSFER_FROM)
			var/selection = round(text2num_safe(command))
			if (selection < 0 || selection > 3)
				return
			switch(selection)
				if(MENU_TRANSFER_OPT_BACK)
					src.menu = MENU_STATION_BUDGET
					src.print_budget()
					return
				if(MENU_TRANSFER_OPT_PAYROLL)
					src.transfer_from = MENU_TRANSFER_OPT_PAYROLL
				if(MENU_TRANSFER_OPT_SHIPPING)
					src.transfer_from = MENU_TRANSFER_OPT_SHIPPING
				if(MENU_TRANSFER_OPT_RESEARCH)
					src.transfer_from = MENU_TRANSFER_OPT_RESEARCH

			if (!src.transfer_from)
				return

			src.print_text("Transferring from the [src.budgets[src.transfer_from]] budget")

			src.menu = MENU_BUDGET_TRANSFER_TO
			src.print_text("Select budget to transfer TO. Enter '0' to return to menu.")
			src.print_transfer_opts()

		if(MENU_BUDGET_TRANSFER_TO)
			var/selection = round(text2num_safe(command))
			if (selection < 0 || selection > 3)
				return
			switch(selection)
				if(MENU_TRANSFER_OPT_BACK)
					src.menu = MENU_BUDGET_TRANSFER_FROM
					src.transfer_from = null
					src.print_text("Select budget to transfer FROM. Enter '0' to return re-select from.")
					src.print_transfer_opts()
					return
				if(MENU_TRANSFER_OPT_PAYROLL)
					src.transfer_to = MENU_TRANSFER_OPT_PAYROLL
				if(MENU_TRANSFER_OPT_SHIPPING)
					src.transfer_to = MENU_TRANSFER_OPT_SHIPPING
				if(MENU_TRANSFER_OPT_RESEARCH)
					src.transfer_to = MENU_TRANSFER_OPT_RESEARCH
			if(src.transfer_from == src.transfer_to)
				src.print_text("You can't transfer a budget into itself.")
				return

			if(!src.transfer_to)
				return

			src.print_text("Transferring to the [src.budgets[src.transfer_to]] budget")

			src.print_text("Input how much money to transfer. Enter '0' to return.")
			src.menu = MENU_BUDGET_TRANSFER_AMOUNT

		if(MENU_BUDGET_TRANSFER_AMOUNT)
			var/transfer_amount = round(text2num_safe(command))
			if (transfer_amount == 0)
				src.transfer_to = null
				src.menu = MENU_BUDGET_TRANSFER_TO
				src.print_text("Select budget to transfer TO. Enter '0' to return to menu.")
				src.print_transfer_opts()
			if(transfer_amount < 0)
				src.print_text("<b>Error:</b> You must choose a positive number to transfer!")
				src.print_text("How much money to transfer?")
				return
			switch(src.transfer_from)
				if(MENU_TRANSFER_OPT_PAYROLL)
					if (transfer_amount > global.wagesystem.station_budget)
						transfer_amount = global.wagesystem.station_budget
					global.wagesystem.station_budget -= transfer_amount
				if(MENU_TRANSFER_OPT_SHIPPING)
					if (transfer_amount > global.wagesystem.shipping_budget)
						transfer_amount = global.wagesystem.shipping_budget
					global.wagesystem.shipping_budget -= transfer_amount
				if(MENU_TRANSFER_OPT_RESEARCH)
					if (transfer_amount > global.wagesystem.research_budget)
						transfer_amount = global.wagesystem.research_budget
					global.wagesystem.research_budget -= transfer_amount

			switch(src.transfer_to)
				if(MENU_TRANSFER_OPT_PAYROLL)
					global.wagesystem.station_budget += transfer_amount
				if(MENU_TRANSFER_OPT_SHIPPING)
					global.wagesystem.shipping_budget += transfer_amount
				if(MENU_TRANSFER_OPT_RESEARCH)
					global.wagesystem.research_budget += transfer_amount

			src.transfer_from = null
			src.transfer_to = null

			src.log_wrapper("Transferred [transfer_amount][CREDIT_SIGN] from [src.budgets[src.transfer_from]] to [src.budgets[src.transfer_to]] budget.")

			src.menu = MENU_STATION_BUDGET
			src.print_budget()

		if(MENU_STAFF_BONUS_TEAM)
			if(!(world.time >= global.wagesystem.last_issued_bonus_time))
				src.print_text("Nanotrasen Regulations forbid issuing multiple staff incentives within five minutes.")
				src.menu = MENU_STATION_BUDGET
				src.print_budget()
				return
			var/choice = round(text2num_safe(command))
			if (choice == BONUS_BACK)
				src.menu = MENU_STATION_BUDGET
				src.print_budget()
				return
			if (choice > BONUS_MAX_CHOICE)
				src.print_text("<b>Error:</b> Invalid option [choice]. Should be between 1 and [BONUS_MAX_CHOICE]")
				return
			for (var/datum/db_record/record in data_core.general.records)
				if (choice == BONUS_STATIONWIDE)
					src.bonus_crew += record
					continue
				for(var/job_datum in src.team_to_job_datum[src.teams[choice]])
					for(var/datum/job/job_type as anything in concrete_typesof(job_datum))
						if (record["rank"] == job_type::name)
							src.bonus_crew += record
							goto next_record // pop out of both for loops
				next_record:

			if(length(src.bonus_crew) == 0)
				src.print_text("There are no eligible crew on this team.")
				src.print_teams()
				return

			src.bonus_team = choice
			src.print_text("Issuing bonus to the [src.teams[src.bonus_team]] team.")
			src.print_text("Please enter value of bonus. Enter '0' to re-select team.")
			src.menu = MENU_STAFF_BONUS_AMOUNT
			return

		if(MENU_STAFF_BONUS_AMOUNT)
			if(!(world.time >= global.wagesystem.last_issued_bonus_time))
				src.print_text("Nanotrasen Regulations forbid issuing multiple staff incentives within five minutes.")
				src.menu = MENU_STATION_BUDGET
				src.print_budget()
				return
			var/amount = round(text2num_safe(command))
			if (amount < 0)
				src.print_text("<b>Error:</b> Cannot issue a negative bonus amount!")
				src.print_text("Please enter value of bonus. Enter '0' to re-select team.")
				return
			if(amount == 0)
				src.bonus_crew.len = 0
				src.print_teams()
				src.menu = MENU_STAFF_BONUS_TEAM
				return

			src.bonus_amount = ceil(clamp(amount, 1, 999999))
			src.print_text("Issuing bonus of [src.bonus_amount][CREDIT_SIGN] to selected staff.")
			var/bonus_total = length(src.bonus_crew) * src.bonus_amount
			src.print_text("Total bonus cost will be [bonus_total][CREDIT_SIGN].")
			if (bonus_total > global.wagesystem.station_budget)
				src.print_text("<b>Error:</b> Payroll budget is only [global.wagesystem.station_budget][CREDIT_SIGN]!")
				src.print_text("Please enter value of bonus. Enter '0' to re-select team.")
				src.bonus_amount = 0
				return

			src.print_text("What is the reason for this staff bonus? Enter '0' to re-select amount.")
			src.menu = MENU_STAFF_BONUS_REASON
			return

		if(MENU_STAFF_BONUS_REASON)
			if(!(world.time >= global.wagesystem.last_issued_bonus_time))
				src.print_text("Nanotrasen Regulations forbid issuing multiple staff incentives within five minutes.")
				src.menu = MENU_STATION_BUDGET
				src.print_budget()
				return
			var/inputText = trimtext(strip_html(text))
			if (inputText == "0")
				src.print_text("Please enter value of bonus. Enter '0' to re-select team.")
				src.menu = MENU_STAFF_BONUS_AMOUNT
				src.bonus_amount = 0
				return

			if (length(inputText) == 0)
				src.print_text("<b>Error:</b> You must provide a reason for the bonus.")
				src.print_text("What is the reason for this staff bonus? Enter '0' to re-select amount.")
				return

			if (length(inputText) > 200)
				src.print_text("<b>Error:</b> Reason must be under 200 characters.")
				src.print_text("What is the reason for this staff bonus? Enter '0' to re-select amount.")
				return

			var/bonus_total = length(src.bonus_crew) * src.bonus_amount
			src.log_wrapper("Issued bonus of [src.bonus_amount][CREDIT_SIGN] ([bonus_total][CREDIT_SIGN] total) to team [src.teams[src.bonus_team]].")
			command_announcement(
				"Bonus of [src.bonus_amount][CREDIT_SIGN] issued to all [src.teams[src.bonus_team]] staff.<br>Reason: [inputText]",
				"Payroll Announcement by [src.authenticated] ([src.account.assignment])"
			)
			global.wagesystem.station_budget -= bonus_total
			global.wagesystem.last_issued_bonus_time = world.time
			for(var/datum/db_record/R as anything in src.bonus_crew)
				// we used to tax the clown but that just put money from the budget into the aether vOv
				R["current_money"] = (R["current_money"] + src.bonus_amount)
			src.bonus_amount = 0
			src.bonus_crew.len = 0
			src.menu = MENU_STATION_BUDGET
			src.print_budget()
			return
		if(MENU_PRINT_SETTINGS)
			switch(round(text2num_safe(command)))
				if(MENU_PRINT_OPT_BACK)
					src.menu = MENU_MAIN
					src.master.temp = null
					src.print_text(src.mainmenu_text())
					return
				if(MENU_PRINT_OPT_CONNECT)
					if(src.connected)
						src.disconnect_server()
						src.connected = FALSE
						src.master.temp = null
						src.print_settings()
						return
					if (src.server_netid)
						src.menu = MENU_HOLD
						src.connect_printserver(src.server_netid, 1)
						if (connected)
							src.master.temp = null
							src.print_text("Connection established to \[[server_netid]]!")
							src.print_settings()
							src.menu = MENU_PRINT_SETTINGS
							return
						src.menu = MENU_PRINT_SETTINGS
						src.print_text("Connection failed.")
						return

					src.menu = MENU_HOLD
					src.print_text("Searching for printserver...")
					if (src.ping_server(1))
						src.print_text("Unable to detect printserver!")
						src.menu = MENU_PRINT_SETTINGS
						return

					src.print_text("Printserver detected at \[[potential_server_netid]]<br>Connecting...")
					src.connect_printserver(potential_server_netid, 1)

					src.menu = MENU_PRINT_SETTINGS
					if (src.connected)
						src.master.temp = null
						src.print_text("Connection established to \[[server_netid]]!")
						src.print_settings()
						return

					src.print_text("Connection failed.")
					return
				if(MENU_PRINT_OPT_SELECT)
					src.menu = MENU_HOLD
					src.message_server("command=print&args=index")
					sleep(0.8 SECONDS)
					var/dat = "Known Printers:"
					if (!src.known_printers || !length(src.known_printers))
						dat += "<br> \[__] No printers known."
					else
						var/leadingZeroCount = length("[src.known_printers.len]")
						for (var/kp_index=1, kp_index <= src.known_printers.len, kp_index++)
							dat += "<br> \[[add_zero("[kp_index]",leadingZeroCount)]] [src.known_printers[kp_index]]"

					src.master.temp = null
					src.print_text("[dat]<br> (0) Return")
					src.menu = MENU_SELECT_PRINTER
					return
				if(MENU_PRINT_OPT_PRINTLOG)
					src.print_log()
					return


		if(MENU_SELECT_PRINTER)
			var/printerNumber = round(text2num_safe(command))
			if (printerNumber == 0)
				src.menu = MENU_PRINT_SETTINGS
				src.master.temp = null
				src.print_settings()
				return

			if (printerNumber < 1 || printerNumber > src.known_printers.len)
				return

			src.selected_printer = src.known_printers[printerNumber]
			src.menu = MENU_PRINT_SETTINGS
			src.master.temp = null
			src.print_text("Printer set.")
			src.print_settings()
			return

/datum/computer/file/terminal_program/bank_records/proc/mainmenu_text()
	var/dat = {"<center>B A N K B O S S 2</center><br>
	Welcome to BankBoss 2<br>
	<b>Commands:</b>
	<br>([MENU_MAIN_OPT_INDEX]) View bank records.
	<br>([MENU_MAIN_OPT_SEARCH]) Search for a record.
	<br>([MENU_MAIN_OPT_BUDGET]) View station budget.
	<br>([MENU_MAIN_OPT_PRINT]) Print options.
	<br>([MENU_MAIN_OPT_QUIT]) Quit."}

	return dat

/datum/computer/file/terminal_program/bank_records/proc/print_budget()
	src.master.temp = null
	src.print_text("<br><b>Station Budget</b>")
	src.print_text("Payroll Budget: [num2text(round(global.wagesystem.station_budget),50)][CREDIT_SIGN]")
	src.print_text("Shipping Budget: [num2text(round(global.wagesystem.shipping_budget),50)][CREDIT_SIGN]")
	src.print_text("Research Budget: [num2text(round(global.wagesystem.research_budget),50)][CREDIT_SIGN]")

	var/payroll = 0
	for(var/datum/db_record/R as anything in data_core.bank.records)
		payroll += R["wage"]
	var/surplus = round(global.wagesystem.payroll_stipend - payroll)
	src.print_text("<br><b>Payroll Cycle Details</b>")
	src.print_text("Per-Cycle Stipend: [num2text(round(global.wagesystem.payroll_stipend), 50)][CREDIT_SIGN]")
	src.print_text("Per-Cycle Cost: -[num2text(round(payroll),50)][CREDIT_SIGN]")
	if(surplus >= 0)
		src.print_text("<b>Payroll Surplus:</b> +[num2text(round(surplus),50)][CREDIT_SIGN]")
	else
		src.print_text("<b>Payroll Deficit:</b> [num2text(round(surplus),50)][CREDIT_SIGN]")


	src.print_text("<br><b>Commands:</b>")
	if(global.wagesystem.pay_active)
		src.print_text("([MENU_BUDGET_OPT_PAYROLL]) Suspend Payroll.")
	else
		src.print_text("([MENU_BUDGET_OPT_PAYROLL]) Resume Payroll.")
	src.print_text("([MENU_BUDGET_OPT_TRANSFER]) Transfer Funds Between Budgets.")
	src.print_text("([MENU_BUDGET_OPT_BONUS]) Issue Staff Bonus.")
	src.print_text("([MENU_BUDGET_OPT_BACK]) Go Back.")

/datum/computer/file/terminal_program/bank_records/proc/print_active_record()
	if (!src.active_general)
		src.print_text("<b>Error:</b> General record data corrupt.")
		return 0
	src.master.temp = null

	var/view_string = {"
	\[01]Name: [src.active_general["name"]] ID: [src.active_general["id"]]
	<br>\[02]Full Name: [src.active_general["full_name"]]
	<br>\[03]<b>Sex:</b> [src.active_general["sex"]]
	<br>\[04]<b>Pronouns:</b> [src.active_general["pronouns"]]
	<br>\[05]<b>Age:</b> [src.active_general["age"]]
	<br>\[06]<b>Rank:</b> [src.active_general["rank"]]
	<br>\[__]<b>Fingerprint:</b> [src.active_general["fingerprint"]]
	<br>\[__]<b>DNA:</b> [src.active_general["dna"]]
	<br>\[__]Photo: [istype(src.active_general["file_photo"], /datum/computer/file/image) ? "On File" : "None"]
	<br>\[__]Physical Status: [src.active_general["p_stat"]]
	<br>\[__]Mental Status: [src.active_general["m_stat"]]"}

	if(istype(src.active_bank) && data_core.bank.has_record(src.active_bank))
		view_string += {"<br><center><b>Bank Data:</b></center>
		<br>\[07]<b>Wage:</b> [src.active_bank["wage"]][CREDIT_SIGN]
		<br>\[08]<b>Balance:</b> [src.active_bank["current_money"]][CREDIT_SIGN]
		<br>\[09]<b>Notes:</b> [src.active_bank["notes"]]
		"}
	else
		view_string += "<br><br><b>Bank Record Lost!</b>"
		view_string += "<br>\[[FIELDNUM_NEWREC]] Create New Bank Record.<br>"

	view_string += {"
	<br>Enter field number to edit a field
	<br>(R) Redraw (D) Delete (P) Print (0) Return to index.
	"}

	src.print_text("<b>Record Data:</b><br>[view_string]")
	return 1

/datum/computer/file/terminal_program/bank_records/proc/print_index()
	src.master.temp = null
	var/dat = ""
	if(!src.record_database || !length(src.record_database.records))
		src.print_text("<b>Error:</b> No records found in database.")

	else
		dat = "Please select a record:"
		var/leadingZeroCount = length("[src.record_database.records.len]")
		for(var/x = 1, x <= src.record_database.records.len, x++)
			var/datum/db_record/R = src.record_database.records[x]
			if(!R || !istype(R))
				dat += "<br><b>\[[add_zero("[x]",leadingZeroCount)]]</b><font color=red>ERR: REDACTED</font>"
				continue

			dat += "<br><b>\[[add_zero("[x]",leadingZeroCount)]]</b>[R["id"]]: [R["name"]]"

	dat += "<br><br>Enter record number, or 0 to return."

	src.print_text(dat)
	return 1

/datum/computer/file/terminal_program/bank_records/proc/print_transfer_opts()
	src.print_text("([MENU_TRANSFER_OPT_PAYROLL]) Payroll, ([MENU_TRANSFER_OPT_SHIPPING]) Shipping, ([MENU_TRANSFER_OPT_RESEARCH]) Research, ([MENU_TRANSFER_OPT_BACK]) Back")

/datum/computer/file/terminal_program/bank_records/proc/print_teams()
	var/dat = ""
	dat += "Select a team to issue a bonus to:"

	var/leadingZeroCount = length("[length(src.teams)]")
	for (var/team in 1 to length(src.teams))
		dat += "<br><b>([add_zero("[team]", leadingZeroCount)])</b> [src.teams[team]]"

	dat += ("<br><br>Enter team number, or 0 to return.")

	src.print_text(dat)
	return
/datum/computer/file/terminal_program/bank_records/proc/print_settings()
	src.master.temp = null
	var/dat = "Options:"

	if (src.connected)
		dat += "<br>([MENU_PRINT_OPT_CONNECT]) Disconnect from print server."
		dat += "<br>([MENU_PRINT_OPT_SELECT]) Select printer."
		dat += "<br>([MENU_PRINT_OPT_PRINTLOG]) Print session log."
	else
		dat += "<br>([MENU_PRINT_OPT_CONNECT]) Connect to print server."
		dat += "<br>([MENU_PRINT_OPT_PRINTLOG]) Print session log (local)."

	dat += "<br>([MENU_PRINT_OPT_BACK]) Back."

	src.print_text(dat)
	return 1

/datum/computer/file/terminal_program/bank_records/proc/local_record_print()
	var/obj/item/peripheral/printcard = find_peripheral("LAR_PRINTER")
	if(!printcard)
		return 1

	//Okay, let's put together something to print.
	var/info = "<center><B>Bank Record</B></center><br>"
	if (istype(src.active_general, /datum/db_record) && data_core.general.has_record(src.active_general))
		info += {"
		Full Name: [src.active_general["full_name"]] ID: [src.active_general["id"]]
		<br><br>Sex: [src.active_general["sex"]]
		<br><br>Pronouns: [src.active_general["pronouns"]]
		<br><br>Age: [src.active_general["age"]]
		<br><br>Rank: [src.active_general["rank"]]
		<br><br>Fingerprint: [src.active_general["fingerprint"]]
		<br><br>DNA: [src.active_general["dna"]]
		<br><br>Photo: [istype(src.active_general["file_photo"], /datum/computer/file/image) ? "On File" : "None"]
		<br><br>Physical Status: [src.active_general["p_stat"]]
		<br><br>Mental Status: [src.active_general["m_stat"]]"}
	else
		info += "<b>General Record Lost!</b><br>"
	if ((istype(src.active_bank, /datum/db_record) && data_core.bank.has_record(src.active_bank)))
		info += {"
		<br><br><center><b>Bank Data</b></center><br>
		<br>Wage: [src.active_bank["wage"]][CREDIT_SIGN]
		<br>Balance: [src.active_bank["current_money"]][CREDIT_SIGN]
		<br>Notes: [src.active_bank["notes"]]
		"}
	else
		info += "<br><center><b>Bank Record Lost!</b></center><br>"
	info += "</tt>"

	var/datum/signal/signal = get_free_signal()
	signal.data["data"] = info
	signal.data["title"] = "Bank Record"
	src.peripheral_command("print",signal, "\ref[printcard]")
	return 0

/datum/computer/file/terminal_program/bank_records/proc/network_record_print()
	if (!connected || !selected_printer || !server_netid)
		return 1

	var/datum/computer/file/record/printRecord = new

	printRecord.fields += "title=Bank Record"
	printRecord.fields += "<center><B>Bank Record</B></center>"
	if (istype(src.active_general, /datum/db_record) && data_core.general.has_record(src.active_general))
		printRecord.fields += "Full Name: [src.active_general["full_name"]] ID: [src.active_general["id"]]"
		printRecord.fields += "Sex: [src.active_general["sex"]]"
		printRecord.fields += "Pronouns: [src.active_general["pronouns"]]"
		printRecord.fields += "Age: [src.active_general["age"]]"
		printRecord.fields += "Rank: [src.active_general["rank"]]"
		printRecord.fields += "Fingerprint: [src.active_general["fingerprint"]]"
		printRecord.fields += "DNA: [src.active_general["dna"]]"
		printRecord.fields += "Photo: [istype(src.active_general["file_photo"], /datum/computer/file/image) ? "On File" : "None"]"
		printRecord.fields += "Physical Status: [src.active_general["p_stat"]]"
		printRecord.fields += "Mental Status: [src.active_general["m_stat"]]"
	else
		printRecord.fields += "General Record Lost!"

	if ((istype(src.active_bank, /datum/db_record) && data_core.bank.has_record(src.active_bank)))
		printRecord.fields += ""
		printRecord.fields += "<center><B>Bank Data</B></center>"
		printRecord.fields += "Wage: [src.active_bank["wage"]][CREDIT_SIGN]"
		printRecord.fields += "Balance: [src.active_bank["current_money"]][CREDIT_SIGN]"
		printRecord.fields += "Notes: [src.active_bank["notes"]]"
	else
		printRecord.fields += "Bank Record Lost!"

	src.message_server("command=print&args=print [selected_printer]", printRecord)

/datum/computer/file/terminal_program/bank_records/proc/print_log()
	if ((src.connected && src.selected_printer && src.server_netid) && !src.network_log_print())
		src.print_text("Print instruction sent to remote printer.")
	else
		if (src.local_log_print())
			src.print_text("<b>Error:</b> No printer detected.")
		else
			src.print_text("Print instruction sent to local printer.")

/datum/computer/file/terminal_program/bank_records/proc/network_log_print()
	if (!connected || !selected_printer || !server_netid)
		return 1
	var/datum/computer/file/record/logdump = new /datum/computer/file/record
	logdump.fields += "title=BankBoss Session Log"
	for (var/line in splittext(src.log_string, "<br>"))
		logdump.fields += line
	src.message_server("command=print&args=print [selected_printer]", logdump)

/datum/computer/file/terminal_program/bank_records/proc/local_log_print()
	var/obj/item/peripheral/printcard = find_peripheral("LAR_PRINTER")
	if(!printcard)
		return 1

	var/datum/signal/signal = get_free_signal()
	signal.data["title"] = "Bank Record"
	signal.data["data"] = src.log_string
	src.peripheral_command("print", signal, "\ref[printcard]")
	return 0

/datum/computer/file/terminal_program/bank_records/proc/message_server(var/message, var/datum/computer/file/toSend)
	if (!connected || !server_netid || !message)
		return 1

	var/netCard = find_peripheral("NET_ADAPTER")
	if (!netCard)
		return 1

	var/datum/signal/termsignal = get_free_signal()

	termsignal.data["address_1"] = server_netid
	termsignal.data["data"] = message
	termsignal.data["command"] = "term_message"
	if (toSend)
		termsignal.data_file = toSend

	src.peripheral_command("transmit", termsignal, "\ref[netCard]")
	return 0

/datum/computer/file/terminal_program/bank_records/proc/connect_printserver(var/address, delayCaller=0)
	if (connected)
		return 1

	var/netCard = find_peripheral("NET_ADAPTER")
	if (!netCard)
		return 1

	var/datum/signal/signal = get_free_signal()

	signal.data["address_1"] = address
	signal.data["command"] = "term_connect"
	signal.data["device"] = "SRV_TERMINAL"
	var/datum/computer/file/user_data/user_data = account
	var/datum/computer/file/record/udat = null
	if (istype(user_data))
		udat = new

		var/userid = format_username(user_data.registered)

		udat.fields["userid"] = userid
		udat.fields["access"] = list2params(user_data.access)
		if (!udat.fields["access"] || !udat.fields["userid"])
			udat.dispose()
			return 1

		udat.fields["service"] = "print"

	if (udat)
		signal.data_file = udat

	src.peripheral_command("transmit", signal, "\ref[netCard]")
	if (delayCaller)
		sleep(0.8 SECONDS)
		return 0

	return 0

/datum/computer/file/terminal_program/bank_records/proc/disconnect_server()
	if (!server_netid)
		return 1

	var/netCard = find_peripheral("NET_ADAPTER")
	if (!netCard)
		return 1

	var/datum/signal/signal = get_free_signal()

	signal.data["address_1"] = server_netid
	signal.data["command"] = "term_disconnect"

	src.peripheral_command("transmit", signal, "\ref[netCard]")

	return 0

/datum/computer/file/terminal_program/bank_records/proc/ping_server(delayCaller=0)
	if (src.connected)
		return 1

	var/netCard = find_peripheral("NET_ADAPTER")
	if (!netCard)
		return 1

	src.potential_server_netid = null
	src.peripheral_command("ping", null, "\ref[netCard]")

	if (delayCaller)
		sleep(0.8 SECONDS)
		return (src.potential_server_netid == null)

	return

/datum/computer/file/terminal_program/bank_records/proc/autosave_log()
	if(!src.log_string) //Something is wrong.
		return

	if(src.holder.read_only)
		return

	var/filename = "[setup_logdump_name]-[ckey(src.authenticated)]-[ckey(time2text(world.timeofday, "hh:mm"))]"
	var/datum/computer/folder/logs_folder = src.get_folder_name("logs", src.holder.root)
	if (!logs_folder)
		return

	var/datum/computer/file/text/logdump = get_file_name(filename, logs_folder)
	if(logdump && !istype(logdump) || get_folder_name(filename, logs_folder))
		return

	if(logdump && istype(logdump))
		logdump.data = src.log_string
	else
		logdump = new /datum/computer/file/text
		logdump.name = filename
		logdump.data = src.log_string
		if(!logs_folder.add_file(logdump))
			logdump.dispose()
			return

/datum/computer/file/terminal_program/bank_records/receive_command(obj/source, command, datum/signal/signal)
	if ((..()) || (!signal))
		return

	if (!connected)
		if (signal.data["command"] == "ping_reply" && !potential_server_netid)

			if (signal.data["device"] == "PNET_MAINFRAME" && signal.data["sender"] && is_hex(signal.data["sender"]))
				src.potential_server_netid = signal.data["sender"]
				return

		else if (signal.data["command"] == "term_connect")
			src.server_netid = ckey(signal.data["sender"])
			src.connected = TRUE
			src.potential_server_netid = null
			if(signal.data["data"] != "noreply")
				var/datum/signal/termsignal = get_free_signal()

				termsignal.data["address_1"] = signal.data["sender"]
				termsignal.data["command"] = "term_connect"
				termsignal.data["device"] = "SRV_TERMINAL"
				termsignal.data["data"] = "noreply"

				src.peripheral_command("transmit", termsignal, "\ref[find_peripheral("NET_ADAPTER")]")

		return
	else
		if (signal.data["sender"] != server_netid)
			return

		if (!server_netid)
			src.connected = FALSE
			return

		switch(lowertext(signal.data["command"]))
			if ("term_message","term_file")
				var/list/data = params2list(signal.data["data"])
				if(!data || !data["command"])
					return

				var/list/commandList = splittext(data["command"], "|n")
				if (!commandList || !length(commandList))
					return

				switch (commandList[1])
					if ("print_index")
						if (length(commandList) > 1)
							known_printers = commandList.Copy(2)
						else
							known_printers = list()

					if ("print_status")
						if (length(commandList) > 1)
							printer_status = commandList[2]
						else
							printer_status = "???"
				return

			if ("term_disconnect")
				src.connected = FALSE
				src.server_netid = null
				src.print_text("Connection closed by printserver.")

			if("term_ping")
				if(signal.data["data"] == "reply")
					var/datum/signal/termsignal = get_free_signal()

					termsignal.data["address_1"] = signal.data["sender"]
					termsignal.data["command"] = "term_ping"

					src.peripheral_command("transmit", termsignal, "\ref[find_peripheral("NET_ADAPTER")]")
	return

///Wrapper for logging things to three different places: The admin LOG_STATION, the local computer log file, and to the terminal screen
/datum/computer/file/terminal_program/bank_records/proc/log_wrapper(log_text)
	logTheThing(LOG_STATION, usr, log_text)
	src.log_string += "<br>[log_text]"
	src.print_text(log_text)

#undef MENU_HOLD
#undef MENU_MAIN
#undef MENU_INDEX
#undef MENU_IN_RECORD
#undef MENU_FIELD_INPUT
#undef MENU_SEARCH_INPUT
#undef MENU_SEARCH_PICK
#undef MENU_BALANCE_TRANSFER
#undef MENU_STATION_BUDGET
#undef MENU_BUDGET_TRANSFER
#undef MENU_BUDGET_TRANSFER_FROM
#undef MENU_BUDGET_TRANSFER_TO
#undef MENU_BUDGET_TRANSFER_AMOUNT
#undef MENU_STAFF_BONUS_TEAM
#undef MENU_STAFF_BONUS_AMOUNT
#undef MENU_STAFF_BONUS_REASON
#undef MENU_PRINT_SETTINGS
#undef MENU_SELECT_PRINTER

#undef MENU_MAIN_OPT_QUIT
#undef MENU_MAIN_OPT_INDEX
#undef MENU_MAIN_OPT_SEARCH
#undef MENU_MAIN_OPT_BUDGET
#undef MENU_MAIN_OPT_PRINT

#undef MENU_BUDGET_OPT_BACK
#undef MENU_BUDGET_OPT_PAYROLL
#undef MENU_BUDGET_OPT_TRANSFER
#undef MENU_BUDGET_OPT_BONUS

#undef MENU_TRANSFER_OPT_BACK
#undef MENU_TRANSFER_OPT_PAYROLL
#undef MENU_TRANSFER_OPT_SHIPPING
#undef MENU_TRANSFER_OPT_RESEARCH

#undef MENU_PRINT_OPT_BACK
#undef MENU_PRINT_OPT_CONNECT
#undef MENU_PRINT_OPT_SELECT
#undef MENU_PRINT_OPT_PRINTLOG

#undef BONUS_BACK
#undef BONUS_STATIONWIDE
#undef BONUS_GENETICS
#undef BONUS_ROBOTICS
#undef BONUS_MEDICAL
#undef BONUS_CARGO
#undef BONUS_MINING
#undef BONUS_ENGINEERING
#undef BONUS_CATERING
#undef BONUS_HYDROPONICS
#undef BONUS_CIVILIAN
#undef BONUS_RESEARCH
#undef BONUS_SECURITY
#undef BONUS_MAX_CHOICE

#undef FIELDNUM_NAME
#undef FIELDNUM_FULLNAME
#undef FIELDNUM_SEX
#undef FIELDNUM_PRONOUNS
#undef FIELDNUM_AGE
#undef FIELDNUM_RANK

#undef FIELDNUM_WAGE
#undef FIELDNUM_BALANCE
#undef FIELDNUM_NOTES
#undef FIELDNUM_DELETE
#undef FIELDNUM_NEWREC

#undef BONUS_REASON_MAX
