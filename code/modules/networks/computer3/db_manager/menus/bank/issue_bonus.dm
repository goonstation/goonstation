/datum/db_manager_menu/issue_bonus
	VAR_PRIVATE/team = null
	VAR_PRIVATE/amount = null
	VAR_PRIVATE/static/list/job_datums_by_team = list(
		"Stationwide"	= list(),
		"Security"		= list(/datum/job/security, /datum/job/command/head_of_security),
		"Medical"		= list(/datum/job/medical/medical_doctor, /datum/job/medical/medical_assistant, /datum/job/command/medical_director),
		"Genetics"		= list(/datum/job/medical/geneticist),
		"Robotics"		= list(/datum/job/medical/roboticist),
		"Research"		= list(/datum/job/research/scientist, /datum/job/research/research_assistant, /datum/job/command/research_director),
		"Engineering"	= list(/datum/job/engineering/engineer, /datum/job/engineering/technical_assistant, /datum/job/command/chief_engineer),
		"Cargo"			= list(/datum/job/engineering/quartermaster, /datum/job/civilian/mail_courier),
		"Mining"		= list(/datum/job/engineering/miner),
		"Catering"		= list(/datum/job/civilian/chef, /datum/job/civilian/bartender, /datum/job/special/random/souschef, /datum/job/daily/waiter),
		"Hydroponics"	= list(/datum/job/civilian/botanist, /datum/job/civilian/rancher),
		"Janitorial"	= list(/datum/job/civilian/janitor),
		"Civilian"		= list(/datum/job/civilian/chaplain, /datum/job/civilian/staff_assistant, /datum/job/civilian/clown, /datum/job/special),
	)
	VAR_PRIVATE/static/list/alist/cached_job_names_by_team = null
	VAR_PRIVATE/static/leading_zero_count = null

/datum/db_manager_menu/issue_bonus/New()
	. = ..()

	if (isnull(src.cached_job_names_by_team))
		src.cached_job_names_by_team = list()

		for (var/team as anything in src.job_datums_by_team)
			var/alist/cached_job_names = (src.cached_job_names_by_team[team] = alist())

			for (var/datum/job/job_type as anything in src.job_datums_by_team[team])
				for (var/datum/job/job_subtype as anything in global.concrete_typesof(job_type))
					cached_job_names[job_subtype::name] = TRUE

		src.leading_zero_count = length("[length(src.job_datums_by_team)]")

/datum/db_manager_menu/issue_bonus/load(team, amount)
	src.team = team
	src.amount = amount

	var/text = "<b>Payroll Budget:</b>       " + num2text(round(global.wagesystem.budgets[BUDGET_CAT_PAYROLL]), 50) + CREDIT_SIGN
	var/eligible_crew = length(src.get_bonus_crew())

	if (src.team)
		text += "<br><b>Issue Bonus To:</b>       " + src.team
		text += "<br><b>Eligible Crewmembers:</b> " + num2text(eligible_crew, 50)
	else
		text += "<br><b>Issue Bonus To:</b>"
		text += "<br><b>Eligible Crewmembers:</b>"

	if (src.amount)
		text += "<br><b>Bonus Per Crewmember:</b> " + num2text(src.amount, 50) + CREDIT_SIGN
		text += "<br><b>Total Bonus Cost:</b>     " + num2text(src.amount * eligible_crew, 50) + CREDIT_SIGN
	else
		text += "<br><b>Bonus Per Crewmember:</b>"
		text += "<br><b>Total Bonus Cost:</b>"

	if (!src.team)
		text += "<br><br>Select a team to issue a bonus to:"

		for (var/i in 1 to length(src.job_datums_by_team))
			text += "<br>    ([global.add_zero(i, src.leading_zero_count)]) [src.job_datums_by_team[i]]"

		text += "<br>    ([global.add_zero(0, src.leading_zero_count)]) Back<br>"

	else if (!src.amount)
		text += "<br><br>Please enter value of bonus. Enter '0' to re-select team."

	else
		text += "<br><br>What is the reason for this staff bonus? Enter '0' to re-select amount."

	src.parent.print_text(text)

/datum/db_manager_menu/issue_bonus/unload()
	src.team = null
	src.amount = null

/datum/db_manager_menu/issue_bonus/input_text(text)
	if (!src.team)
		var/command = global.text2num_safe(src.parent.parse_string(text)[1])
		var/index_number = round(max(command, 0))

		if (index_number == 0)
			src.parent.switch_menu_to("station_budget")
			return

		if (index_number > length(src.job_datums_by_team))
			src.parent.print_text("<b>Error:</b> Invalid choice.")
			return

		var/team_choice = src.job_datums_by_team[index_number]
		if (!length(src.get_bonus_crew(team_choice)))
			src.parent.print_text("<b>Error:</b> Team \"[team_choice]\" has no members.")
			return

		src.parent.switch_menu_to("issue_bonus", team_choice)

	else if (!src.amount)
		var/command = global.text2num_safe(src.parent.parse_string(text)[1])
		var/bonus = round(command)

		if (bonus == 0)
			src.parent.switch_menu_to("issue_bonus")
			return

		if (bonus < 0)
			src.parent.print_text("<b>Error:</b> Cannot issue a negative bonus amount!")
			return

		var/bonus_total = bonus * length(src.get_bonus_crew())
		var/budget = global.wagesystem.budgets[BUDGET_CAT_PAYROLL]
		if (bonus_total > budget)
			src.parent.print_text("<b>Error:</b> Attempted to allocate [bonus_total][CREDIT_SIGN], but payroll budget is only [budget][CREDIT_SIGN].")
			return

		src.parent.switch_menu_to("issue_bonus", src.team, bonus)

	else
		text = trimtext(strip_html(text))
		if (text == "0")
			src.parent.switch_menu_to("issue_bonus", src.team)
			return

		var/reason_length = length(text)
		if (!reason_length)
			src.parent.print_text("<b>Error:</b> You must provide a reason for the bonus.")
			return

		if (reason_length > 200)
			src.parent.print_text("<b>Error:</b> Reason must be under 200 characters.")
			return

		if (ON_COOLDOWN(global, "payroll_issue_bonus", 5 MINUTES))
			src.parent.print_text("<b>Error:</b> Nanotrasen regulations forbid issuing multiple staff incentives within five minutes.")
			return

		var/list/datum/db_record/personnel/bank/bonus_crew = src.get_bonus_crew()
		var/bonus_total = src.amount * length(bonus_crew)
		if (bonus_total > global.wagesystem.budgets[BUDGET_CAT_PAYROLL])
			src.parent.print_text("<b>Error:</b> Attempted to allocate [bonus_total][CREDIT_SIGN], but payroll budget is only [global.wagesystem.budgets[BUDGET_CAT_PAYROLL]][CREDIT_SIGN].")
			return

		logTheThing(LOG_STATION, usr, "issued a bonus of [src.amount][CREDIT_SIGN] ([bonus_total][CREDIT_SIGN] total) to team [src.team].")
		global.command_announcement(
			"Bonus of [src.amount][CREDIT_SIGN] issued to all [src.team] staff.<br>Reason: [text]",
			"Payroll Announcement by [src.parent.authenticated] ([src.parent.account.assignment])",
			'sound/misc/bingbong.ogg',
			alert_origin = ALERT_DEPARTMENT,
		)

		global.wagesystem.budgets[BUDGET_CAT_PAYROLL] -= bonus_total
		for (var/datum/db_record/personnel/bank/record as anything in bonus_crew)
			record["current_money"] = (record["current_money"] + src.amount)

		src.parent.switch_menu_to("station_budget")

/datum/db_manager_menu/issue_bonus/proc/get_bonus_crew(team)
	RETURN_TYPE(/list/datum/db_record/personnel/bank)
	team ||= src.team
	if (!team)
		return

	if (team == "Stationwide")
		return global.data_core.bank.records.Copy()

	. = list()
	var/alist/cached_job_names = src.cached_job_names_by_team[team]
	for (var/datum/db_record/record as anything in global.data_core.general.records)
		if (!cached_job_names[record["rank"]])
			continue

		. += global.data_core.bank.find_record("id", record["id"])
