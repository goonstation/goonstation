/datum/crewCredits
	var/crew_credits_data

	var/list/crew_tab_data
	var/list/antagonist_tab_data

/datum/crewCredits/New()
	. = ..()
	src.crew_tab_data = list(
		CREW_TAB_SECTION_ANTAGONIST = list(),
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

/// Populates `crew_credits_data` with the data to be passed to the UI.
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

	src.crew_credits_data = list(
		// Crew Tab Data:
		"groups" = list(
			list(
				"title" = "Antagonists",
				"crew" = src.crew_tab_data[CREW_TAB_SECTION_ANTAGONIST],
			),
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
	)

/// For a specified mind, creates an entry in `crew_tab_data` containing the applicable information.
/datum/crewCredits/proc/generate_crew_member_data(datum/mind/mind)
	if (mind.is_antagonist())
		src.crew_tab_data[CREW_TAB_SECTION_ANTAGONIST] += src.bundle_crew_member_data(mind, TRUE)

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
/datum/crewCredits/proc/bundle_crew_member_data(var/datum/mind/mind, generate_antagonist_data = FALSE)
	var/is_head = FALSE
	var/list/antagonist_display_names = list()

	if(mind.is_antagonist())
		for (var/datum/antagonist/antagonist_role in mind.antagonists)
			if (antagonist_role.pseudo || antagonist_role.vr || antagonist_role.silent)
				continue

			antagonist_display_names += capitalize(antagonist_role.display_name)

		if (generate_antagonist_data)
			return list(list(
				"real_name" = mind.current.real_name,
				"dead" = isdead(mind.current),
				"player" = mind.displayed_key,
				"role" = english_list(antagonist_display_names),
				"head" = is_head,
			))

	if (!mind.assigned_role)
		return

	// Determine whether this mind is a Head of Staff; if so they will be displayed at the top of their respective department's section.
	if ((mind.assigned_role in command_jobs) || (mind.assigned_role == "AI"))
		is_head = TRUE

	// If this mind is an antagonist, their antagonist roles will be displayed within their data entry.
	var/antag_roles_text = ""
	if (length(antagonist_display_names))
		antag_roles_text = " ([english_list(antagonist_display_names)])"

	return list(list(
		"real_name" = mind.current.real_name,
		"dead" = isdead(mind.current),
		"player" = mind.displayed_key,
		"role" = "[mind.assigned_role][antag_roles_text]",
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
		if (mind.current.z == Z_LEVEL_STATION)
			status = "Alive, On Station"
		else if (istype(get_area(mind.current), /area/centcom) || istype(get_area(mind.current), /area/shuttle/escape) )
			status = "Alive, At CentComm"
		else
			status = "Alive, Off Station"

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
	data["job_role"] = mind.assigned_role || "N/A"
	data["status"] = status
	data["objectives"] = objectives
	data["antagonist_statistics"] = antagonist_statistics
	data["subordinate_antagonists"] = subordinate_antagonists

	src.antagonist_tab_data[ANTAGONIST_TAB_VERBOSE_DATA] += list(data)
