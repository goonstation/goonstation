var/global/crew_creds = null

/// Debug option for filling out the end-game crew credits roster with fake names
#define CREDITS_DEBUGGING

/datum/crewCredits

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


#ifdef CREDITS_DEBUGGING
/// Debug proc to generate a fake crew member data bundle for TGUI
/datum/crewCredits/proc/generate_fake_crew_member(var/real_name, var/role, var/dead, var/head)
	. = list(list(
		"real_name" = real_name,
		"dead" = dead,
		"player" = capitalize(pick_string_autokey("names/monkey.txt")),
		"role" = role,
		"head" = head,
	))


/// Debug proc to generate a fake carbon crew member name
/datum/crewCredits/proc/fake_carbon_name()
	var/name_first = ""
	var/name_last = ""
	if (prob(50))
		name_first = capitalize(pick_string_autokey("names/first_male.txt"))
	else
		name_first = capitalize(pick_string_autokey("names/first_female.txt"))
	name_last = capitalize(pick_string_autokey("names/last.txt"))
	return name_first + " " + name_last
#endif

/// Generates the crew member data bundle for TGUI use
/datum/crewCredits/proc/bundle_crew_member_data(var/datum/mind/M)
	var/is_head = false
	if(M.special_role)
		if(!M.current) return

		. += list(list(
			"real_name" = M.current.real_name,
			"dead" = isdead(M.current),
			"player" = M.displayed_key,
			"role" = M.special_role,
			"head" = is_head,
		))
		return .

	if(!M.assigned_role) return

	if (M.assigned_role in list("Head of Security", "Head of Personnel", "Medical Director", "Research Director", "Chief Engineer", "AI"))
		is_head = true

	. +=list(list(
		"real_name" = M.current.real_name,
		"dead" = isdead(M.current),
		"player" = M.displayed_key,
		"role" = M.assigned_role,
		"head" = is_head,
	))

/datum/crewCredits/ui_static_data(mob/user)
	. = ..()
	if(crew_creds)
		logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] returning already-generated crew credits")
		return crew_creds

	logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] starting crew credits generation")
	var/list/antagonist = list()
	var/list/captain = list()
	var/list/security = list()
	var/list/medical = list()
	var/list/science = list()
	var/list/engineering = list()
	var/list/civilian = list()
	var/list/silicon = list()
	var/list/other = list()

	for(var/datum/mind/M in ticker.minds)

		// Antagonist?
		if(M.special_role)
			antagonist += bundle_crew_member_data(M)
		if(!M.assigned_role)
			continue

		if (M.assigned_role == "Captain")
			captain += bundle_crew_member_data(M)
		else if ((M.assigned_role in security_jobs) || (M.assigned_role in security_gimmicks))
			security += bundle_crew_member_data(M)
		else if ((M.assigned_role in medical_jobs) || (M.assigned_role in medical_gimmicks))
			medical += bundle_crew_member_data(M)
		else if ((M.assigned_role in science_jobs) || (M.assigned_role in science_gimmicks))
			science += bundle_crew_member_data(M)
		else if ((M.assigned_role in engineering_jobs) || (M.assigned_role in engineering_gimmicks))
			engineering += bundle_crew_member_data(M)
		else if ((M.assigned_role in service_jobs) || (M.assigned_role in service_gimmicks) || M.assigned_role == "Staff Assistant")
			civilian += bundle_crew_member_data(M)
		else if ((M.assigned_role == "AI") || (M.assigned_role == "Cyborg"))
			silicon += bundle_crew_member_data(M)
		else if (M.assigned_role == "Pathologist")
			#ifdef SCIENCE_PATHO_MAP
			science += bundle_crew_member_data(M)
			#else
			medical += bundle_crew_member_data(M)
			#endif
		else
			other += bundle_crew_member_data(M)

	logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done processing minds. info: A [length(antagonist)] C [length(captain)] S [length(security)] M [length(medical)] R [length(science)] E [length(engineering)] Cv [length(civilian)] Si [length(silicon)] X [length(other)]")

	/* ~ BEGIN FAKE CREW CREDITS GENERATION ~ */
	#ifdef CREDITS_DEBUGGING

	var/has_head = FALSE
	var/what_role = ""

	while (length(antagonist) < 4)
		antagonist += src.generate_fake_crew_member(
			real_name=src.fake_carbon_name(),
			role = pick("Vampire", "Werewolf", "Changeling", "Legworm", "Handspider", "Eyespider", "Traitor", "Spy-thief", "Blob", "Flockmind", "Flockbit", "Omnitraitor", "Nuclear Operative", "Hard-mode Traitor"),
			dead = prob(50),
		)
	while (length(captain) < 1)
		captain += src.generate_fake_crew_member(
			real_name=src.fake_carbon_name(),
			role= "Captain",
			dead=prob(20),
			head=TRUE
		)
	while (length(security) < 8)
		if (!has_head)
			what_role = "Head of Security"
		else
			what_role = pick("Security Officer", "Security Assistant")
		security += src.generate_fake_crew_member(
			real_name=src.fake_carbon_name(),
			role=what_role,
			dead=prob(30),
			head=!has_head
		)
		has_head=TRUE
	has_head=FALSE
	while (length(medical) < 8)
		if (!has_head)
			what_role = "Medical Director"
		else
			what_role = pick("Medical Doctor", "Medical Doctor", "Roboticist", "Geneticist") // weighted (for "realism")

		medical += src.generate_fake_crew_member(
			real_name=src.fake_carbon_name(),
			role=what_role,
			dead=prob(10),
			head=!has_head
		)
		has_head = TRUE
	has_head = FALSE
	while (length(science) < 4)
		if (!has_head)
			what_role = "Research Director"
		else
			what_role = "Scientist"
		science += src.generate_fake_crew_member(
			real_name=src.fake_carbon_name(),
			role=what_role,
			dead=prob(50),
			head=!has_head
		)
		has_head=TRUE
	has_head = FALSE
	while (length(engineering) < 8)
		if (!has_head)
			what_role = "Chief Engineer"
		else
			what_role = pick("Engineer", "Engineer", "Engineer", "Quartermaster", "Miner", "Miner") // weighted (for "realism")
		engineering += src.generate_fake_crew_member(
			real_name=src.fake_carbon_name(),
			role=what_role,
			dead=prob(20),
			head=!has_head
		)
		has_head = TRUE
	has_head = FALSE
	while (length(civilian) < 16)
		if (!has_head)
			what_role = "Head of Personnel"
		else
			what_role = pick("Communications Officer","Botanist","Apiculturist","Rancher","Bartender","Chef","Sous-Chef","Waiter","Clown","Mime","Chaplain","Mailman","Musician","Janitor","Coach","Boxer","Barber","Staff Assistant")
		civilian += src.generate_fake_crew_member(
			real_name=src.fake_carbon_name(),
			role=what_role,
			dead=prob(30),
			head=!has_head
		)
		has_head = TRUE
	has_head = FALSE
	while (length(silicon) < 8)
		var/name_to_use = ""
		if (!has_head)
			what_role = "AI"
			name_to_use = pick_string_autokey("names/ai.txt")
		else
			what_role = "Cyborg"
			name_to_use = borgify_name("Cyborg")
		silicon += src.generate_fake_crew_member(
			real_name=name_to_use,
			role=what_role,
			dead=prob(10),
			head=!has_head
		)
		has_head=TRUE
	has_head=FALSE
	while(length(other) < 8)
		other += src.generate_fake_crew_member(
			real_name = src.fake_carbon_name(),
			role=pick("Senator", "President", "CEO", "Board Member", "Mayor", "Vice-President", "Governor", "Diplomat" )
		)

	logTheThing(LOG_DEBUG, null, "Zamujasa/CREWCREDITS: [world.timeofday] done adding fake crew. info: A [length(antagonist)] C [length(captain)] S [length(security)] M [length(medical)] R [length(science)] E [length(engineering)] Cv [length(civilian)] Si [length(silicon)] X [length(other)]")

	#endif
	/* ~ END FAKE CREW CREDITS GENERATOR ~ */

	crew_creds = list(
		"groups" = list(
			list(
				"group" = "Antagonist" + (length(antagonist)==1 ? "" : "s"),
				"crew" = antagonist,
			),
			list(
				"group" = "Captain" + (length(captain)==1 ? "" : "s"),
				"crew" = captain,
			),
			list(
				"group" = "Security Department",
				"crew" = security,
			),
			list(
				"group" = "Medical Department",
				"crew" = medical,
			),
			list(
				"group" = "Science Department",
				"crew" = science,
			),
			list(
				"group" = "Engineering Department",
				"crew" = engineering,
			),
			list(
				"group" = "Civilian Department",
				"crew" = civilian,
			),
			list(
				"group" = "Silicon" + (length(silicon)==1 ? "": "s"),
				"crew" = silicon,
			),
			list(
				"group" = "Other",
				"crew" = other,
			),
		)
	)
	return crew_creds
