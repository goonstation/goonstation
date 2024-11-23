/datum/crewCredits
	var/crew_credits_data

	var/list/crew_tab_data
	var/list/antagonist_tab_data
	var/list/score_tab_data
	var/list/citation_tab_data

/datum/crewCredits/New()
	. = ..()
	src.crew_tab_data = list(
		CREW_TAB_SECTION_CAPTAIN = list(),
		CREW_TAB_SECTION_SECURITY = list(),
		CREW_TAB_SECTION_MEDICAL = list(),
		CREW_TAB_SECTION_SCIENCE = list(),
		CREW_TAB_SECTION_ENGINEERING = list(),
		CREW_TAB_SECTION_CIVILIAN = list(),
		CREW_TAB_SECTION_SILICON = list(),
		CREW_TAB_SECTION_OTHER = list(),
	)
	src.antagonist_tab_data = list(
		ANTAGONIST_TAB_GAME_MODE = capitalize(ticker.mode.name),
		ANTAGONIST_TAB_VERBOSE_DATA = list(),
		ANTAGONIST_TAB_SUCCINCT_DATA = list(),
	)
	src.score_tab_data = list(
		SCORE_TAB_SECTION_SECURITY = list(),
		SCORE_TAB_SECTION_SCIENCE = list(),
		SCORE_TAB_SECTION_ENGINEERING = list(),
		SCORE_TAB_SECTION_CIVILIAN = list(),
		SCORE_TAB_SECTION_ESCAPEE = list(),
	)
	src.citation_tab_data = list(
		CITATION_TAB_SECTION_TICKETS = list(),
		CITATION_TAB_SECTION_FINES = list(),
	)

	src.generate_crew_credits()

/datum/crewCredits/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/crewCredits/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/datum/crewCredits/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CrewCredits")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/crewCredits/ui_static_data(mob/user)
	return src.crew_credits_data

/// Populates each tab with the data to be passed to the UI.
/datum/crewCredits/proc/generate_crew_credits()
#ifdef CREW_CREDITS_DEBUGGING

	src.debug_generate_crew_member_data()
	src.debug_generate_antagonist_data()

#else

	for(var/datum/mind/mind as anything in ticker.minds)
		if (QDELETED(mind) || !mind.current)
			continue

		src.generate_crew_member_data(mind)
		src.generate_antagonist_data(mind)

#endif
	src.generate_score_data()
	src.generate_citation_data()

	src.crew_credits_data = list(
		// Crew Tab Data:
		"groups" = list(
			list(
				"title" = "Captain" + (length(src.crew_tab_data[CREW_TAB_SECTION_CAPTAIN]) == 1 ? "" : "s"),
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_CAPTAIN],
			),
			list(
				"title" = "Security Department",
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_SECURITY],
			),
			list(
				"title" = "Medical Department",
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_MEDICAL],
			),
			list(
				"title" = "Science Department",
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_SCIENCE],
			),
			list(
				"title" = "Engineering Department",
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_ENGINEERING],
			),
			list(
				"title" = "Civilian Department",
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_CIVILIAN],
			),
			list(
				"title" = "Silicons",
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_SILICON],
			),
			list(
				"title" = "Other",
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_OTHER],
			),
		),

		// Antagonists Tab Data:
		"game_mode" = src.antagonist_tab_data[ANTAGONIST_TAB_GAME_MODE],
		"verbose_antagonist_data" = src.antagonist_tab_data[ANTAGONIST_TAB_VERBOSE_DATA],
		"succinct_antagonist_data" = src.antagonist_tab_data[ANTAGONIST_TAB_SUCCINCT_DATA],

		// Score Tab Data:
		"total_score" = score_tab_data[SCORE_TAB_TOTAL_SCORE],
		"grade" = score_tab_data[SCORE_TAB_GRADE],
		"victory_headline" = score_tab_data[SCORE_TAB_VICTORY_HEADLINE],
		"victory_body" = score_tab_data[SCORE_TAB_VICTORY_BODY],
		"score_groups" = list(
			list(
				"title" = "Security Department",
				"entries" = src.score_tab_data[SCORE_TAB_SECTION_SECURITY],
			),
			list(
				"title" = "Engineering Department",
				"entries" = src.score_tab_data[SCORE_TAB_SECTION_ENGINEERING],
			),
			list(
				"title" = "Research Department",
				"entries" = src.score_tab_data[SCORE_TAB_SECTION_SCIENCE],
			),
			list(
				"title" = "Civilian Department",
				"entries" = src.score_tab_data[SCORE_TAB_SECTION_CIVILIAN],
			),
			list(
				"title" = "Statistics",
				"entries" = src.score_tab_data[SCORE_TAB_SECTION_ESCAPEE],
			),
		),

		// Tickets Tab Data:
		"tickets" = src.citation_tab_data[CITATION_TAB_SECTION_TICKETS],
		"fines" = src.citation_tab_data[CITATION_TAB_SECTION_FINES],
	)

/// For a specified mind, creates an entry in `crew_tab_data` containing the applicable information.
/datum/crewCredits/proc/generate_crew_member_data(datum/mind/mind)
	if(!mind.assigned_role)
		return

	var/crew_tab_section = CREW_TAB_SECTION_OTHER

	if (mind.assigned_role == "Captain")
		crew_tab_section = CREW_TAB_SECTION_CAPTAIN

	else if ((mind.assigned_role in security_jobs) || (mind.assigned_role in security_gimmicks))
		crew_tab_section = CREW_TAB_SECTION_SECURITY

	else if ((mind.assigned_role in medical_jobs) || (mind.assigned_role in medical_gimmicks))
		crew_tab_section = CREW_TAB_SECTION_MEDICAL

	else if ((mind.assigned_role in science_jobs) || (mind.assigned_role in science_gimmicks))
		crew_tab_section = CREW_TAB_SECTION_SCIENCE

	else if ((mind.assigned_role in engineering_jobs) || (mind.assigned_role in engineering_gimmicks))
		crew_tab_section = CREW_TAB_SECTION_ENGINEERING

	else if ((mind.assigned_role in service_jobs) || (mind.assigned_role in service_gimmicks) || mind.assigned_role == "Staff Assistant")
		crew_tab_section = CREW_TAB_SECTION_CIVILIAN

	else if ((mind.assigned_role == "AI") || (mind.assigned_role == "Cyborg"))
		crew_tab_section = CREW_TAB_SECTION_SILICON

	src.crew_tab_data["[crew_tab_section]"] += src.bundle_crew_member_data(mind)

/// Concatenates data on a specifed mind into a list in order to be appended to `crew_tab_data`.
/datum/crewCredits/proc/bundle_crew_member_data(var/datum/mind/mind)
	var/is_head = FALSE
	var/list/antagonist_display_names = list()

	if(mind.is_antagonist())
		for (var/datum/antagonist/antagonist_role in mind.antagonists)
			if (antagonist_role.pseudo || antagonist_role.vr || antagonist_role.silent)
				continue

			antagonist_display_names += capitalize(antagonist_role.display_name)

	if (!mind.assigned_role)
		return

	// Determine whether this mind is a Head of Staff; if so they will be displayed at the top of their respective department's section.
	if ((mind.assigned_role in command_jobs) || (mind.assigned_role == "AI"))
		is_head = TRUE

	// If this mind is an antagonist, their antagonist roles will be displayed within their data entry.
	var/antag_roles_text = ""
	if (length(antagonist_display_names))
		antag_roles_text = " ([english_list(antagonist_display_names)])"

	var/full_role = "[mind.assigned_role][antag_roles_text]"
	if (mind.assigned_role == "MODE") //I LOVE MODE I LOVE MODE
		full_role = english_list(antagonist_display_names)

	return list(list(
		"real_name" = mind.current.real_name,
		"dead" = isdead(mind.current) || isVRghost(mind.current),
		"player" = mind.displayed_key,
		"role" = full_role,
		"head" = is_head,
	))

/// For a specified mind, creates an entry in `antagonist_tab_data` containing the applicable information.
/datum/crewCredits/proc/generate_antagonist_data(datum/mind/mind)
	if (!mind.is_antagonist())
		return

	var/list/antagonist_display_names = list()
	var/list/antagonist_statistics = list()
	var/list/objectives = list()
	for (var/datum/antagonist/antagonist_role in mind.antagonists)
		if (antagonist_role.pseudo || antagonist_role.vr || antagonist_role.silent)
			continue

		// If this antagonist is subordinate and has a master, then they will be displayed under their master's antagonist information.
		if (istype(antagonist_role, /datum/antagonist/subordinate))
			var/datum/antagonist/subordinate/subordinate_antagonist_role = antagonist_role
			if (subordinate_antagonist_role.master)
				continue

		// Handle succinct antagonist data.
		if (antagonist_role.succinct_end_of_round_antagonist_entry)
			src.antagonist_tab_data[ANTAGONIST_TAB_SUCCINCT_DATA] += list(list(
				"antagonist_role" = capitalize(antagonist_role.display_name),
				"real_name" = antagonist_role.owner.current.real_name,
				"player" = antagonist_role.owner.displayed_key,
				"dead" = isdead(antagonist_role.owner.current),
				)
			)
			continue

		antagonist_display_names += capitalize(antagonist_role.display_name)

		// Display additional antagonist statistics, determined by the antagonist type.
		var/list/statistics = antagonist_role.get_statistics()
		if (length(statistics))
			antagonist_statistics += statistics

		// Display antagonist objectives.
		for (var/datum/objective/objective as anything in antagonist_role.objectives)
			objectives += list(list(
				"explanation_text" = strip_html_tags(objective.explanation_text),
				"completed" = objective.check_completion(),
				)
			)

	if (!length(antagonist_display_names))
		return

	// Determine whether this antagonist is dead or alive, and where they currently are.
	var/status = "Unknown"
	if (!isdead(mind.current))
		// status
		if(issilicon(mind.current))
			status = "Silicon, " // you made it, but not really
		else
			status = "Alive, "
		// where
		if (mind.current.z == Z_LEVEL_STATION)
			status += "On Station"
		else if (istype(get_area(mind.current), /area/centcom) || istype(get_area(mind.current), /area/shuttle/escape) )
			status += "At CentComm"
		else
			status += "Off Station"

	else
		var/mob/corpse

		if (istype(mind.current, /mob/dead))
			var/mob/dead/player = mind.current
			corpse = player.corpse

		else
			corpse = mind.current

		if (!corpse)
			status = "Dead, Body Destroyed"
		else if (corpse.z == Z_LEVEL_STATION)
			status = "Dead, On Station"
		else if (istype(get_area(corpse.z), /area/centcom) || istype(get_area(corpse.z), /area/shuttle/escape) )
			status = "Dead, At CentComm"
		else
			status = "Dead, Off Station"

	// Handle antagonists subordinate to this antagonist.
	var/list/subordinate_antagonists = list()
	for (var/datum/antagonist/subordinate/antagonist_role as anything in mind.subordinate_antagonists)
		subordinate_antagonists += list(list(
			"antagonist_role" = capitalize(antagonist_role.display_name),
			"real_name" = antagonist_role.owner.current.real_name,
			"player" = antagonist_role.owner.displayed_key,
			"dead" = isdead(antagonist_role.owner.current),
			)
		)

	var/list/data = list()
	data["antagonist_roles"] = english_list(antagonist_display_names)
	data["real_name"] = mind.current.real_name
	data["player"] = mind.displayed_key
	data["job_role"] = (mind.assigned_role && mind.assigned_role != "MODE") ? mind.assigned_role : "N/A" //stupid internal "MODE" job
	data["status"] = status
	data["objectives"] = objectives
	data["antagonist_statistics"] = antagonist_statistics
	data["subordinate_antagonists"] = subordinate_antagonists

	src.antagonist_tab_data[ANTAGONIST_TAB_VERBOSE_DATA] += list(data)

/// Station Score
/datum/crewCredits/proc/generate_score_data()
	if (score_tracker.score_calculated == 0)
		return


	src.score_tab_data[SCORE_TAB_VICTORY_HEADLINE] = ticker.mode.victory_headline()
	src.score_tab_data[SCORE_TAB_VICTORY_BODY] = ticker.mode.victory_body()
	src.score_tab_data[SCORE_TAB_TOTAL_SCORE] = round(score_tracker.final_score_all)
	src.score_tab_data[SCORE_TAB_GRADE] = "[score_tracker.grade]"

	src.score_tab_data[SCORE_TAB_SECTION_SECURITY] = list(
		list(
			"name" = "Crew Survival Rate",
			"type" = "colorPercent",
			"value" = round(score_tracker.score_crew_survival_rate),
		),
		list(
			"name" = "Enemy Failure Rate",
			"type" = "colorPercent",
			"value" = round(score_tracker.score_enemy_failure_rate),
		),
		list(
			"name" = "Monsieur Stirstir Survived",
			"value" = score_tracker.score_stirstir_alive ? "Yes" : "No",
		),
		list(
			"name" = "Total Department Score",
			"type" = "colorPercent",
			"value" =  round(score_tracker.final_score_sec),
		)
	)

	src.score_tab_data[SCORE_TAB_SECTION_ENGINEERING] = list(
		list(
			"name" = "Power Generated",
			"value" = "[engineering_notation(score_tracker.power_generated / 3600)]Wh",
		),
		list(
			"name" = "Station Structural Integrity",
			"type" = "colorPercent",
			"value" = round(score_tracker.score_structural_damage),
		),
		list(
			"name" = "Station Areas Powered",
			"type" = "colorPercent",
			"value" = round(score_tracker.score_power_outages),
		),
		list(
			"name" = "Total Department Score",
			"type" = "colorPercent",
			"value" = round(score_tracker.final_score_eng),
		),
	)

	src.score_tab_data[SCORE_TAB_SECTION_SCIENCE] = list(
		list(
			"name" = "Artifacts correctly analyzed",
			"value" = "[round(score_tracker.score_artifact_analysis)]% ([score_tracker.artifacts_correctly_analyzed]/[score_tracker.artifacts_analyzed])"
		),
		list(
			"name" = "Total Department Score",
			"type" = "colorPercent",
			"value" = round(score_tracker.final_score_res),
		),
	)

	src.score_tab_data[SCORE_TAB_SECTION_CIVILIAN] = list(
		list(
			"name" = "Overall Station Cleanliness",
			"type" = "colorPercent",
			"value" = round(score_tracker.score_cleanliness),
		),
		list(
			"name" = "Station Profitability",
			"type" = "colorPercent",
			"value" = round(score_tracker.score_expenses),
		),
		list(
			"name" = "Mails Delivered / Frauded",
			"value" = "[score_tracker.mail_opened] / [score_tracker.mail_fraud]"
		),
		list(
			"name" = "Total Department Score",
			"type" = "colorPercent",
			"value" = round(score_tracker.final_score_civ),
		),
	)

	if (score_tracker.richest_escapee)
		src.score_tab_data[SCORE_TAB_SECTION_ESCAPEE] += list(list(
			"name" = "Richest Escapee",
			"value" = "[score_tracker.richest_escapee.real_name] : [score_tracker.richest_total][CREDIT_SIGN]"
		))

	if (score_tracker.most_damaged_escapee)
		src.score_tab_data[SCORE_TAB_SECTION_ESCAPEE] += list(list(
			"name" = "Most Damaged Escapee",
			"value" = "[score_tracker.most_damaged_escapee.real_name] : [score_tracker.most_damaged_escapee.get_damage()]%"
		))

	if (length(score_tracker.command_pets_escaped))
		var/list/command_pet_data = list()
		for (var/atom/A in score_tracker.command_pets_escaped)
			command_pet_data += list(list(
				"iconBase64" = "[icon2base64(getFlatIcon(A, no_anim=TRUE))]",
				"name" = "[A.name]",
			))
		src.score_tab_data[SCORE_TAB_SECTION_ESCAPEE] += list(list(
				"name" = "Command Pets Escaped",
				"type" = "itemList",
				"value" = command_pet_data
		))

	if (length(score_tracker.pets_escaped))
		var/list/other_pet_data = list()
		for (var/atom/A in score_tracker.pets_escaped)
			other_pet_data += list(list(
				"iconBase64" = "[icon2base64(getFlatIcon(A, no_anim=TRUE))]",
				"name" = "[A.name]",
			))
		src.score_tab_data[SCORE_TAB_SECTION_ESCAPEE] += list(list(
				"name" = "Other Pets Escaped",
				"type" = "itemList",
				"value" = other_pet_data
		))

	if (score_tracker.acula_blood)
		src.score_tab_data[SCORE_TAB_SECTION_ESCAPEE] += list(list(
			"name" = "Dr. Acula Blood Total",
			"value" =  "[score_tracker.acula_blood]u"
		))

	if (score_tracker.beepsky_alive)
		src.score_tab_data[SCORE_TAB_SECTION_ESCAPEE] += list(list(
			"name" = "Beepsky?",
			"value" = "Yes"
		))
	src.score_tab_data[SCORE_TAB_SECTION_ESCAPEE] += list(generate_heisenhat_data())


/// Heisenbee's hat
/datum/crewCredits/proc/generate_heisenhat_data()
	. = list()
	.["name"] = "Heisenbee's Hat"
	var/found_hb = FALSE
	var/tier = world.load_intra_round_value("heisenbee_tier")
	for(var/obj/critter/domestic_bee/heisenbee/HB in by_cat[TR_CAT_PETS])
		var/obj/item/hat = HB.original_hat
		if (hat && !hat.disposed)
			.["type"] = "itemList"
			if(hat.loc != HB)
				var/atom/movable/AM = hat.loc
				while(istype(AM) && !istype(AM, /mob))
					AM = AM.loc
				var/mob/M = AM
				.["value"] = list(list(
					"name" = "[hat] (tier [HB.original_tier]) \[STOLEN[istype(M) ? " BY [M]": ""]\]",
					"iconBase64" = icon2base64(getFlatIcon(hat, no_anim=TRUE)),
				))
				if(HB.hat)
					var/dead = HB.alive ? "" : "(dead) "
					.["value"] += list(list(
						"name" = "someone put [HB.hat] on [dead][HB] but that doesn't count",
						"iconBase64" = icon2base64(getFlatIcon(HB, no_anim=TRUE)),
					))
			else if(!HB.alive)
				.["value"] = list(list(
					"name" = "[hat] (tier [HB.original_tier]) \[🐝 MURDERED!\]",
					"iconBase64" = icon2base64(getFlatIcon(HB, no_anim=TRUE)),
				))
			else
				.["value"] = list(list(
					"name" = "[hat] (tier [HB.original_tier])",
					"iconBase64" = icon2base64(getFlatIcon(HB, no_anim=TRUE)),
				))
		else if(HB.alive)
			if(hat)
				.["value"] = list(list(
					"name" = "\[DESTROYED!\]"
				))
			else
				.["value"] = list(list(
					"name" = "No hat yet",
				))
		else if (hat)
			.["type"] = "itemList"
			.["value"] = list(list(
				"name" = "\[DESTROYED!\] \[🐝 MURDERED!\]",
				"iconBase64" = icon2base64(getFlatIcon(hat, no_anim=TRUE)),
			))
		else
			.["value"] = list(list(
				"name" = "No hat yet. \[🐝 MURDERED!\]",
			))

		found_hb = TRUE
		.["type"] = "itemList"
		break

	if(!found_hb)
		.["value"] = "Heisenbee is missing, [tier ? "but the hat is safe at tier [tier]" : "and has no hat"]."

/// Tickets/Fines
/datum/crewCredits/proc/generate_citation_data()
	if(length(data_core.tickets))
		var/list/people_with_tickets = list()
		for (var/datum/ticket/T in data_core.tickets)
			people_with_tickets |= T.target

		for(var/ticket_target in people_with_tickets)
			var/list/tickets = list()
			for(var/datum/ticket/ticket in data_core.tickets)
				if(ticket.target == ticket_target)
					tickets += list(list(
						"reason" = html_decode(ticket.reason),
						"issuer" = html_decode(ticket.issuer),
						"issuer_job" = html_decode(ticket.issuer_job),
					))
			src.citation_tab_data[CITATION_TAB_SECTION_TICKETS] += list(list(
				"name" = html_decode(ticket_target),
				"citations" = tickets,
			))

	if(length(data_core.fines))
		var/list/people_with_fines = list()
		for (var/datum/fine/F in data_core.fines)
			people_with_fines |= F.target

		for(var/fine_target in people_with_fines)
			var/list/fines = list()
			for(var/datum/fine/fine in data_core.fines)
				if(fine.target == fine_target)
					fines += list(list(
						"reason" = fine.reason,
						"issuer" = fine.issuer,
						"issuer_job" = fine.issuer_job,
						"amount" = fine.amount,
						"approver" = fine.approver,
						"approver_job" = fine.approver_job,
						"paid_amount" = fine.paid_amount,
						"paid" = fine.paid
					))

			src.citation_tab_data[CITATION_TAB_SECTION_FINES] += list(list(
				"name" = fine_target,
				"citations" = fines,
			))
