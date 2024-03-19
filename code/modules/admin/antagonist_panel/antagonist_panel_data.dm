/**
 *	The global singleton datum responsible for generating and providing data to individual instances of antagonist panels.
 *	Such a datum is necessary due to the relatively large amount of antagonist data that is required to be processed with
 *	each update of individual antagonist panels; tab data may be collated once every update then stored in a cache in order
 *	to be fetched by antagonist panels.
 */
/datum/antagonist_panel_data
	/// An associative list of tab indexes and their repective tab instances.
	var/list/datum/antagonist_panel_tab/antagonist_panel_tabs
	/// A list of tab names and their respective tab index.
	var/list/list/antagonist_panel_tab_names
	/// An associative list of tab indexes and their repective cached tab data.
	var/list/list/ui_data_cache

/datum/antagonist_panel_data/New()
	. = ..()

	src.antagonist_panel_tabs = list()
	src.antagonist_panel_tab_names = list()
	src.ui_data_cache = list()

/// Returns the UI data for a specified antagonist panel tab, either fetching it from the cache or regenerating it depending on a cooldown.
/datum/antagonist_panel_data/proc/request_ui_data(tab_index)
	if (ON_COOLDOWN(global, "request_ui_data-[tab_index]", 0.9 SECONDS))
		return src.ui_data_cache[tab_index]

	src.get_antagonist_panel_tabs()

	var/list/tab_section_data
	var/list/antagonist_locations
	var/list/mortality_rates

	var/datum/antagonist_panel_tab/antagonist_tab = src.antagonist_panel_tabs[tab_index]
	if (antagonist_tab)
		tab_section_data = antagonist_tab.generate_section_data()
		antagonist_locations = antagonist_tab.generate_location_data()

	else
		mortality_rates = src.generate_mortality_rates()

	src.ui_data_cache[tab_index] = list(
		"tabs" = src.antagonist_panel_tab_names,
		"currentTabSections" = tab_section_data,
		"mindLocations" = antagonist_locations,
		"mortalityRates" = mortality_rates,
	)

	return src.ui_data_cache[tab_index]

/// Populates `antagonist_panel_tabs` and `antagonist_panel_tab_names` with the necessary antagonist tab types and names.
/datum/antagonist_panel_data/proc/get_antagonist_panel_tabs()
	//	A delay of 0.85 seconds ensures that `get_antagonist_panel_tabs()` runs at least once if `request_ui_data()` is only
	//	being called once every TGUI tick.
	if (ON_COOLDOWN(global, "get_antagonist_panel_tabs", 0.85 SECONDS))
		return

	var/list/datum/antagonist_panel_tab/new_antagonist_panel_tabs = list()
	src.antagonist_panel_tab_names = list()

	for (var/antagonist_role as anything in antagonists)
		var/list/datum/antagonist/antagonist_datums = antagonists[antagonist_role]
		if (!length(antagonist_datums))
			continue

		var/datum/antagonist/antagonist_type = antagonist_datums[1].type

		var/tab_type = initial(antagonist_type.antagonist_panel_tab_type)
		if (!tab_type)
			continue

		var/tab_name
		if (ispath(antagonist_type, /datum/antagonist/generic))
			var/datum/antagonist/generic/generic_antagonist_type = antagonist_type
			tab_name = initial(generic_antagonist_type.grouped_name)
		else
			tab_name = initial(antagonist_type.display_name)

		var/index
		if (ispath(tab_type, /datum/antagonist_panel_tab/generic))
			index = "[antagonist_type]"
		else
			index = "[tab_type]"

		if (new_antagonist_panel_tabs[index])
			continue

		var/datum/antagonist_panel_tab/new_tab
		if (src.antagonist_panel_tabs[index])
			new_tab = src.antagonist_panel_tabs[index]
		else
			new_tab = new tab_type(tab_name, antagonist_role)

		new_antagonist_panel_tabs[index] = new_tab
		src.antagonist_panel_tab_names += list(list(
			"tabName" = new_tab.tab_name,
			"index" = index,
		))

	src.antagonist_panel_tabs = new_antagonist_panel_tabs

/// Returns both crew and antagonist mortality rates.
/datum/antagonist_panel_data/proc/generate_mortality_rates()
	var/alive_antagonists = 0
	var/dead_antagonists = 0
	var/alive_crew = 0
	var/dead_crew = 0

	for(var/client/client as anything in clients)
		var/mob/M = client.mob
		if (isnewplayer(M))
			continue
		if(is_dead_or_ghost_role(M))
			if (M.mind?.is_antagonist())
				dead_antagonists++

			else
				dead_crew++

			continue

		if (M.mind?.is_antagonist())
			alive_antagonists++

		else
			alive_crew++

	return list(
		"antagonistsAlive" = alive_antagonists,
		"antagonistsDead" = dead_antagonists,
		"crewAlive" = alive_crew,
		"crewDead" = dead_crew,
	)
