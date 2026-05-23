ABSTRACT_TYPE(/datum/nation)
/datum/nation
	var/name = ""
	/// For displaying the short-form on Passports.
	var/short_name = ""

	/// For passport UIs and minimap territory colours.
	var/nation_color = "#1a378d"
	var/control_point_marker = "point_neutral"

	/// The passport type that this nation should use.
	var/passport_type = /obj/item/passport

	/// The leader jobs of this nation, associated with the antagonist role that they are assigned.
	var/alist/leader_jobs = alist()

	/// The antagonist role that all citizens of the nation are assigned.
	var/citizen_role = null
	/// List of jobs which are assigned regular citizenship to this nation at roundstart. Checked FIRST. As /datum/job types.
	var/list/citizen_jobs = list()
	/// List of jobs categories which are assigned regular citizenship to this nation at roundstart. Checked SECOND. See `_std/defines/job.dm`.
	var/list/citizen_job_categories = list()

	var/alist/leaders = alist()
	var/list/datum/mind/citizens = list()

	var/can_capture = TRUE
	var/list/datum/nations_control_point/control_points = list()
	/// See `icons/obj/nations_control_point_computer.dmi`.
	var/control_point_icon_state = ""

/datum/nation/New()
	. = ..()

	for (var/job as anything in src.leader_jobs)
		src.leaders += src.leader_jobs[job]

/datum/nation/proc/add_leader(datum/mind/new_leader, role_id)
	var/datum/mind/current_leader = src.leaders[role_id]
	if (current_leader == new_leader)
		return

	if (current_leader)
		current_leader.add_antagonist(src.citizen_role, respect_mutual_exclusives = FALSE)
		logTheThing(LOG_GAMEMODE, src, "removed [key_name(current_leader)] as leader ([role_id]) of [src.name]!")

	src.leaders[role_id] = new_leader
	src.add_citizen(new_leader)
	logTheThing(LOG_GAMEMODE, src, "installed [key_name(new_leader)] as leader ([role_id]) of [src.name]!")

/datum/nation/proc/remove_leader(datum/mind/leader, role_id)
	src.remove_citizen(leader)
	if (src.leaders[role_id] != leader)
		return

	src.leaders[role_id] = null
	logTheThing(LOG_GAMEMODE, src, "removed [key_name(leader)] as leader ([role_id]) of [src.name]!")

/datum/nation/proc/is_leader(datum/mind/mind)
	for (var/role_id as anything in src.leaders)
		if (src.leaders[role_id] == mind)
			return TRUE

	return FALSE

/datum/nation/proc/add_citizen(datum/mind/new_citizen)
	if (new_citizen in src.citizens)
		return
	src.citizens += new_citizen
	logTheThing(LOG_GAMEMODE, src, "assigned [key_name(new_citizen)] to the nation of [src.name]!")

/datum/nation/proc/remove_citizen(datum/mind/citizen)
	if (!(citizen in src.citizens))
		return
	src.citizens -= citizen
	logTheThing(LOG_GAMEMODE, src, "removed [key_name(citizen)] from the nation of [src.name]!")

/datum/nation/proc/get_role_type(datum/mind/citizen)
	if (!(citizen in src.citizens))
		return
	var/role_id = src.citizen_role
	for (var/leader_id as anything in src.leaders)
		if (src.leaders[leader_id] == citizen)
			role_id = leader_id
			break
	var/datum/antagonist/nation/nation_antagonist_datum = citizen.get_antagonist(role_id)
	return nation_antagonist_datum?.role_type

/datum/nation/proc/get_short_name()
	if (length(src.short_name))
		return src.short_name
	return src.name

/datum/nation/proc/get_population()
	var/list/datum/mind/living_citizens = list()
	for (var/datum/mind/citizen as anything in src.citizens)
		if (!isalive(citizen.current) || !citizen.current?.client)
			continue
		living_citizens += citizen
	return length(living_citizens)

/datum/nation/un
	name = "United Nations"
	can_capture = FALSE
	passport_type = /obj/item/passport/un
	nation_color = "#24639a"
	leader_jobs = alist(
		/datum/job/command/captain = ROLE_UN_SECGEN,
		/datum/job/command/head_of_security = ROLE_UN_UNDSEC,
	)
	citizen_role = ROLE_UN
	citizen_jobs = list(
		/datum/job/civilian/AI,
		/datum/job/civilian/cyborg,
	)
	citizen_job_categories = list(
		JOB_SECURITY,
		JOB_NANOTRASEN,
	)

/datum/nation/clown
	name = "Clowntopia"
	passport_type = /obj/item/passport/clown
	nation_color = "#d73715"
	control_point_marker = "point_clown"
	control_point_icon_state = "clown"
	leader_jobs = alist(/datum/job/neutral/clown/ringmaster = ROLE_NATION_CLN_LEADER)
	citizen_role = ROLE_NATION_CLN
	citizen_jobs = list(
		/datum/job/neutral/clown,
		/datum/job/special/clown,
	)
	citizen_job_categories = list(JOB_CLOWN)

/datum/nation/engineering
	name = "The Great Technocracy (Actually a dictatorship) of the Engiland Empire"
	short_name = "Engiland"
	passport_type = /obj/item/passport/engineering
	nation_color = "#d37610"
	control_point_marker = "point_eng"
	control_point_icon_state = "engineering"
	leader_jobs = alist(/datum/job/command/chief_engineer = ROLE_NATION_ENG_LEADER)
	citizen_role = ROLE_NATION_ENG
	citizen_job_categories = list(JOB_ENGINEERING)

/datum/nation/medical
	name = "The Sovereign State of Medica"
	short_name = "Medica"
	passport_type = /obj/item/passport/medical
	nation_color = "#c9294e"
	control_point_marker = "point_med"
	control_point_icon_state = "medical"
	leader_jobs = alist(/datum/job/command/medical_director = ROLE_NATION_MED_LEADER)
	citizen_role = ROLE_NATION_MED
	citizen_job_categories = list(JOB_MEDICAL)

/datum/nation/research
	name = "The Science team!"
	short_name = "Team Science!"
	passport_type = /obj/item/passport/research
	nation_color = "#5a1d8a"
	control_point_marker = "point_sci"
	control_point_icon_state = "research"
	leader_jobs = alist(/datum/job/command/research_director = ROLE_NATION_SCI_LEADER)
	citizen_role = ROLE_NATION_SCI
	citizen_job_categories = list(JOB_RESEARCH)

/datum/nation/service
	name = "The Kingdom of Servicia"
	short_name = "Servicia"
	passport_type = /obj/item/passport/service
	nation_color = "#167935"
	control_point_marker = "point_ser"
	control_point_icon_state = "service"
	leader_jobs = alist(/datum/job/command/head_of_personnel = ROLE_NATION_SER_LEADER)
	citizen_role = ROLE_NATION_SER
	citizen_job_categories = list(JOB_CIVILIAN)

/datum/nation/supply
	name = "Greater Home Depot"
	short_name = "Greater Home Depot"
	passport_type = /obj/item/passport/supply
	nation_color = "#4a301b"
	control_point_marker = "point_sup"
	control_point_icon_state = "supply"
	leader_jobs = alist(/datum/job/command/supply_coordinator = ROLE_NATION_SUP_LEADER)
	citizen_role = ROLE_NATION_SUP
	citizen_job_categories = list(JOB_SUPPLY)
