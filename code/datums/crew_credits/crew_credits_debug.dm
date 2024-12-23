#ifdef CREW_CREDITS_DEBUGGING

/// DEBUG: Generates a fake crew member data entry.
/datum/crewCredits/proc/generate_fake_crew_member(real_name, role, dead, head)
	return list(list(
		"real_name" = real_name,
		"dead" = dead,
		"player" = capitalize(pick_string_autokey("names/monkey.txt")),
		"role" = role,
		"head" = head,
	))

/// DEBUG: Generate a fake carbon crew member name.
/datum/crewCredits/proc/fake_carbon_name()
	var/name_first = ""
	if (prob(50))
		name_first = capitalize(pick_string_autokey("names/first_male.txt"))

	else
		name_first = capitalize(pick_string_autokey("names/first_female.txt"))

	var/name_last = capitalize(pick_string_autokey("names/last.txt"))

	return name_first + " " + name_last

/// DEBUG: Populates `crew_tab_data` with fake crew member data entries.
/datum/crewCredits/proc/debug_generate_crew_member_data()
	var/has_head = FALSE
	var/what_role = ""

	while (length(src.crew_tab_data[CREW_TAB_SECTION_CAPTAIN]) < 1)
		src.crew_tab_data[CREW_TAB_SECTION_CAPTAIN] += src.generate_fake_crew_member(
			real_name = src.fake_carbon_name(),
			role = "Captain",
			dead = prob(20),
			head = TRUE,
		)

	while (length(src.crew_tab_data[CREW_TAB_SECTION_SECURITY]) < 8)
		if (!has_head)
			what_role = "Head of Security"

		else
			what_role = pick("Security Officer", "Security Assistant")

		src.crew_tab_data[CREW_TAB_SECTION_SECURITY] += src.generate_fake_crew_member(
			real_name = src.fake_carbon_name(),
			role = what_role,
			dead = prob(30),
			head = !has_head,
		)

		has_head = TRUE

	has_head = FALSE

	while (length(src.crew_tab_data[CREW_TAB_SECTION_MEDICAL]) < 8)
		if (!has_head)
			what_role = "Medical Director"

		else
			what_role = pick(200; "Medical Doctor", "Roboticist", "Geneticist")

		src.crew_tab_data[CREW_TAB_SECTION_MEDICAL] += src.generate_fake_crew_member(
			real_name = src.fake_carbon_name(),
			role = what_role,
			dead = prob(10),
			head = !has_head,
		)

		has_head = TRUE

	has_head = FALSE

	while (length(src.crew_tab_data[CREW_TAB_SECTION_SCIENCE]) < 4)
		if (!has_head)
			what_role = "Research Director"

		else
			what_role = "Scientist"

		src.crew_tab_data[CREW_TAB_SECTION_SCIENCE] += src.generate_fake_crew_member(
			real_name = src.fake_carbon_name(),
			role = what_role,
			dead = prob(50),
			head = !has_head,
		)

		has_head = TRUE

	has_head = FALSE

	while (length(src.crew_tab_data[CREW_TAB_SECTION_ENGINEERING]) < 8)
		if (!has_head)
			what_role = "Chief Engineer"

		else
			what_role = pick(300; "Engineer", 200; "Miner", "Quartermaster")

		src.crew_tab_data[CREW_TAB_SECTION_ENGINEERING] += src.generate_fake_crew_member(
			real_name = src.fake_carbon_name(),
			role = what_role,
			dead = prob(20),
			head = !has_head,
		)

		has_head = TRUE

	has_head = FALSE

	while (length(src.crew_tab_data[CREW_TAB_SECTION_CIVILIAN]) < 16)
		if (!has_head)
			what_role = "Head of Personnel"

		else
			what_role = pick("Communications Officer","Botanist","Apiculturist","Rancher","Bartender","Chef","Sous-Chef","Waiter","Clown","Mime","Chaplain","Mail Courier","Musician","Janitor","Coach","Boxer","Barber","Staff Assistant")

		src.crew_tab_data[CREW_TAB_SECTION_CIVILIAN] += src.generate_fake_crew_member(
			real_name = src.fake_carbon_name(),
			role = what_role,
			dead = prob(30),
			head = !has_head,
		)

		has_head = TRUE

	has_head = FALSE

	while (length(src.crew_tab_data[CREW_TAB_SECTION_SILICON]) < 8)
		var/name_to_use = ""
		if (!has_head)
			what_role = "AI"
			name_to_use = pick_string_autokey("names/ai.txt")
		else
			what_role = "Cyborg"
			name_to_use = borgify_name("Cyborg")

		src.crew_tab_data[CREW_TAB_SECTION_SILICON] += src.generate_fake_crew_member(
			real_name = name_to_use,
			role = what_role,
			dead = prob(10),
			head = !has_head,
		)

		has_head = TRUE

	has_head = FALSE

	while(length(src.crew_tab_data[CREW_TAB_SECTION_OTHER]) < 8)
		src.crew_tab_data[CREW_TAB_SECTION_OTHER] += src.generate_fake_crew_member(
			real_name = src.fake_carbon_name(),
			role = pick("Tourist", "Musician", "Union Rep", "Board Member", "Inspector", "Governor", "Diplomat")
		)

/// DEBUG: Generates a fake succinct antagonist data entry.
/datum/crewCredits/proc/generate_fake_succinct_antagonist(antagonist_role)
	return list(list(
		"antagonist_role" = antagonist_role,
		"real_name" = src.fake_carbon_name(),
		"player" = capitalize(pick_string_autokey("names/monkey.txt")),
		"dead" = prob(40),
	))

/// DEBUG: Populates `antagonist_tab_data` with fake crew member data entries.
/datum/crewCredits/proc/debug_generate_antagonist_data()
	var/list/eligible_jobs = (get_all_jobs() - security_jobs)
	var/list/generic_antagonist_types = (concrete_typesof(/datum/antagonist) - concrete_typesof(/datum/antagonist/subordinate) - concrete_typesof(/datum/antagonist/generic))
	var/list/subordinate_antagonist_types = concrete_typesof(/datum/antagonist/subordinate)
	var/list/other_antagonist_types = (concrete_typesof(/datum/antagonist/subordinate) + /datum/antagonist/revolutionary)
	var/list/objective_types = concrete_typesof(/datum/objective)

	while (length(src.antagonist_tab_data[ANTAGONIST_TAB_VERBOSE_DATA]) < 4)
		var/list/antagonist_roles = list(pick(generic_antagonist_types))
		if (prob(30))
			antagonist_roles += pick(generic_antagonist_types)

			if (prob(30))
				antagonist_roles += pick(generic_antagonist_types)

		var/list/antagonist_display_names = list()
		for (var/datum/antagonist/antagonist_role as anything in antagonist_roles)
			antagonist_display_names += capitalize(initial(antagonist_role.display_name))

		var/status = pick(
			"Alive, On Station",
			"Alive, At CentComm",
			"Alive, Off Station",
			"Dead, Body Destroyed",
			"Dead, On Station",
			"Dead, At CentComm",
			"Dead, Off Station",
		)

		var/list/objectives = list()
		while (length(objectives) < 4)
			var/datum/objective/objective = pick(objective_types)
			if (!length(initial(objective.explanation_text)))
				continue

			objectives += list(list(
				"explanation_text" = strip_html_tags(initial(objective.explanation_text)),
				"completed" = prob(50),
				)
			)

		var/list/statistics = list()
		while (length(statistics) < 3)
			statistics += list(list(
				"name" = "Test Statisic",
				"value" = "[rand(1, 100)]",
			))

		var/list/subordinate_antagonists = list()
		while (length(subordinate_antagonists) < 3)
			var/datum/antagonist/antagonist_role = pick(subordinate_antagonist_types)
			subordinate_antagonists += src.generate_fake_succinct_antagonist(
				capitalize(initial(antagonist_role.display_name))
			)

		var/list/data = list()
		data["antagonist_roles"] = english_list(antagonist_display_names)
		data["real_name"] = src.fake_carbon_name()
		data["player"] = capitalize(pick_string_autokey("names/monkey.txt"))
		data["job_role"] = pick(eligible_jobs)
		data["status"] = status
		data["objectives"] = objectives
		data["antagonist_statistics"] = statistics
		data["subordinate_antagonists"] = subordinate_antagonists

		src.antagonist_tab_data[ANTAGONIST_TAB_VERBOSE_DATA] += list(data)


	while (length(src.antagonist_tab_data[ANTAGONIST_TAB_SUCCINCT_DATA]) < 8)
		var/datum/antagonist/antagonist_role = pick(other_antagonist_types)
		src.antagonist_tab_data[ANTAGONIST_TAB_SUCCINCT_DATA] += src.generate_fake_succinct_antagonist(
				capitalize(initial(antagonist_role.display_name))
			)

#endif
