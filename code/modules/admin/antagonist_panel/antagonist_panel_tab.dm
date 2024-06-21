/**
 *	Antagonist panel tab datums represent the individual tabs that may be present on an antagonist panel and are responsble
 *	for generating the specific data contained within them.
 */
/datum/antagonist_panel_tab
	/// The name of this tab to be displayed on the UI.
	var/tab_name

/// Returns data on the constituent sections of this tab, alongside the concomitant antagonist data.
/datum/antagonist_panel_tab/proc/generate_section_data()
	return

/// Returns a list of areas and coordinates for each player entry in the tab, indexed by mind.
/datum/antagonist_panel_tab/proc/generate_location_data()
	return



/datum/antagonist_panel_tab/generic
	/// The antagonist ID that this tab should display data for.
	var/antagonist_role

/datum/antagonist_panel_tab/generic/New(tab_name, antagonist_role)
	. = ..()
	src.tab_name = tab_name
	src.antagonist_role = antagonist_role

/datum/antagonist_panel_tab/generic/generate_section_data()
	var/list/datum/antagonist/antagonist_datums = get_all_antagonists(src.antagonist_role)

	var/list/list/antagonist_data_entries = list()
	for (var/datum/antagonist/antagonist_datum as anything in antagonist_datums)
		antagonist_data_entries += list(list(
			"mind_ref" = "\ref[antagonist_datum.owner]",
			"antagonist_datum" = "\ref[antagonist_datum]",
			"real_name" = antagonist_datum.owner.current.real_name,
			"ckey" = antagonist_datum.owner.displayed_key,
			"job" = get_job(antagonist_datum.owner),
			"dead" = is_dead_or_ghost_role(antagonist_datum.owner.current),
			"has_subordinate_antagonists" = !!length(antagonist_datum.owner.subordinate_antagonists),
		))

	return list(
		list(
			"sectionType" = "AntagonistList",
			"sectionData" = antagonist_data_entries,
		)
	)

/datum/antagonist_panel_tab/generic/generate_location_data()
	. = list()

	for (var/datum/antagonist/antagonist_datum as anything in get_all_antagonists(src.antagonist_role))
		var/turf/T = get_turf(antagonist_datum.owner.current)
		var/area/A = get_area(antagonist_datum.owner.current)
		.["\ref[antagonist_datum.owner]"] = list(
			"area" = A.name,
			"coordinates" = "([T.x], [T.y], [T.z])",
		)



/datum/antagonist_panel_tab/bundled
	/// An associateive list of section titles and antagonist IDs that this tab should display data for.
	var/list/name_antagonist_pairs

/datum/antagonist_panel_tab/bundled/generate_section_data()
	. = list()

	for (var/tab_name in src.name_antagonist_pairs)
		var/antagonist_role = src.name_antagonist_pairs[tab_name]

		var/list/datum/antagonist/antagonist_datums = get_all_antagonists(antagonist_role)
		var/list/list/antagonist_data_entries = list()

		for (var/datum/antagonist/antagonist_datum as anything in antagonist_datums)
			antagonist_data_entries += list(list(
				"mind_ref" = "\ref[antagonist_datum.owner]",
				"antagonist_datum" = "\ref[antagonist_datum]",
				"real_name" = antagonist_datum.owner.current.real_name,
				"ckey" = antagonist_datum.owner.displayed_key,
				"job" = get_job(antagonist_datum.owner),
				"dead" = is_dead_or_ghost_role(antagonist_datum.owner.current),
				"has_subordinate_antagonists" = !!length(antagonist_datum.owner.subordinate_antagonists),
			))

		. += list(list(
			"sectionType" = "AntagonistList",
			"sectionName" = tab_name,
			"sectionData" = antagonist_data_entries,
		))

/datum/antagonist_panel_tab/bundled/generate_location_data()
	. = list()

	for (var/tab_name in src.name_antagonist_pairs)
		var/antagonist_role = src.name_antagonist_pairs[tab_name]

		for (var/datum/antagonist/antagonist_datum as anything in get_all_antagonists(antagonist_role))
			var/turf/T = get_turf(antagonist_datum.owner.current)
			var/area/A = get_area(antagonist_datum.owner.current)

			.["\ref[antagonist_datum.owner]"] = list(
				"area" = A.name,
				"coordinates" = "([T.x], [T.y], [T.z])",
			)



/datum/antagonist_panel_tab/bundled/nuclear_operative
	tab_name = "Syndicate Operatives"
	name_antagonist_pairs = list(
		"Syndicate Commander" = ROLE_NUKEOP_COMMANDER,
		"Syndicate Operatives" = ROLE_NUKEOP,
		"Syndicate Gunbots" = ROLE_NUKEOP_GUNBOT,
	)

/datum/antagonist_panel_tab/bundled/nuclear_operative/generate_section_data()
	. = ..()

	for_by_tcl(nuclear_bomb, /obj/machinery/nuclearbomb)
		var/turf/T = get_turf(nuclear_bomb)
		var/area/A = get_area(nuclear_bomb)

		. += list(list(
			"sectionType" = "NuclearBombReadout",
			"sectionName" = nuclear_bomb.name,
			"sectionData" = list(
				"nuclearBomb" = "\ref[nuclear_bomb]",
				"maxHealth" = nuclear_bomb._max_health,
				"health" = nuclear_bomb._health,
				"timeRemaining" = "[nuclear_bomb.armed ? "[nuclear_bomb.get_countdown_timer()]" : "[formatTimeText(nuclear_bomb.timer_default)]"]",
				"area" = A.name,
				"coordinates" = "([T.x], [T.y], [T.z])",
			)
		))



/datum/antagonist_panel_tab/bundled/revolution
	tab_name = "The Revolution"
	name_antagonist_pairs = list(
		"Head Revolutionaries" = ROLE_HEAD_REVOLUTIONARY,
		"Revolutionaries" = ROLE_REVOLUTIONARY,
	)

	var/list/datum/mind/heads_of_staff

/datum/antagonist_panel_tab/bundled/revolution/New()
	. = ..()
	src.heads_of_staff = list()

/datum/antagonist_panel_tab/bundled/revolution/generate_section_data()
	. = list()

	src.heads_of_staff = list()
	for(var/client/client as anything in clients)
		if(client.mob.mind?.is_head_of_staff())
			src.heads_of_staff += client.mob.mind

	var/list/list/heads_of_staff_data_entries = list()
	for (var/datum/mind/mind as anything in src.heads_of_staff)
		heads_of_staff_data_entries += list(list(
			"mind_ref" = "\ref[mind]",
			"role" = mind.assigned_role,
			"real_name" = mind.current.real_name,
			"ckey" = mind.displayed_key,
			"dead" = is_dead_or_ghost_role(mind.current),
		))

	. += list(list(
		"sectionType" = "HeadsList",
		"sectionName" = "Heads Of Staff",
		"sectionData" = heads_of_staff_data_entries,
	))

	. += ..()

/datum/antagonist_panel_tab/bundled/revolution/generate_location_data()
	. = ..()

	for (var/datum/mind/mind as anything in src.heads_of_staff)
		var/turf/T = get_turf(mind.current)
		var/area/A = get_area(mind.current)

		.["\ref[mind]"] = list(
			"area" = A.name,
			"coordinates" = "([T.x], [T.y], [T.z])",
		)



/datum/antagonist_panel_tab/bundled/pirate
	tab_name = "Pirates"
	name_antagonist_pairs = list(
		"Pirate Captain" = ROLE_PIRATE_CAPTAIN,
		"Pirate First Mate" = ROLE_PIRATE_FIRST_MATE,
		"Pirares" = ROLE_PIRATE,
	)



/datum/antagonist_panel_tab/gang
	tab_name = "Gangs"

/datum/antagonist_panel_tab/gang/generate_section_data()
	. = list()

	for (var/datum/antagonist/gang_leader/gang_leader_datum as anything in get_all_antagonists(ROLE_GANG_LEADER))
		var/list/gang_section_data = list()

		gang_section_data += list(list(
			"sectionType" = "AntagonistList",
			"sectionName" = "Gang Leader",
			"sectionData" = list(list(
				"mind_ref" = "\ref[gang_leader_datum.owner]",
				"antagonist_datum" = "\ref[gang_leader_datum]",
				"real_name" = gang_leader_datum.owner.current.real_name,
				"ckey" = gang_leader_datum.owner.displayed_key,
				"job" = get_job(gang_leader_datum.owner),
				"dead" = is_dead_or_ghost_role(gang_leader_datum.owner.current),
			)),
		))

		var/list/gang_member_entries = list()
		for (var/datum/antagonist/subordinate/gang_member/gang_member_datum as anything in gang_leader_datum.owner.subordinate_antagonists)
			if (!istype(gang_member_datum))
				continue

			gang_member_entries += list(list(
				"mind_ref" = "\ref[gang_member_datum.owner]",
				"antagonist_datum" = "\ref[gang_member_datum]",
				"real_name" = gang_member_datum.owner.current.real_name,
				"ckey" = gang_member_datum.owner.displayed_key,
				"job" = get_job(gang_member_datum.owner),
				"dead" = is_dead_or_ghost_role(gang_member_datum.owner.current),
			))

		gang_section_data += list(list(
			"sectionType" = "AntagonistList",
			"sectionName" = "Gang Members",
			"sectionData" = gang_member_entries,
		))

		var/obj/ganglocker/locker = gang_leader_datum.gang.locker
		if (locker)
			var/turf/T = get_turf(locker)
			var/area/A = get_area(locker)

			gang_section_data += list(list(
				"sectionType" = "GangLockerReadout",
				"sectionName" = "Gang Locker",
				"sectionData" = list(
					"gangLocker" = "\ref[locker]",
					"area" = A.name,
					"coordinates" = "([T.x], [T.y], [T.z])",
				),
			))

		. += list(list(
			"sectionType" = "GangReadout",
			"sectionName" = gang_leader_datum.gang.gang_name,
			"sectionData" = gang_section_data,
		))

/datum/antagonist_panel_tab/gang/generate_location_data()
	. = list()

	for (var/datum/antagonist/antagonist_datum in (get_all_antagonists(ROLE_GANG_LEADER) + get_all_antagonists(ROLE_GANG_MEMBER)))
		var/turf/T = get_turf(antagonist_datum.owner.current)
		var/area/A = get_area(antagonist_datum.owner.current)
		.["\ref[antagonist_datum.owner]"] = list(
			"area" = A.name,
			"coordinates" = "([T.x], [T.y], [T.z])",
		)
