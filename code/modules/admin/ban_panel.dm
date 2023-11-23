#define BAN_PANEL_TAB_BAN_LIST "ban_list"
#define BAN_PANEL_TAB_JOB_BAN_LIST "job_ban_list"

#define BAN_PANEL_ACTION_SEARCH "ban_search"
#define BAN_PANEL_ACTION_PAGE_PREV "page_prev"
#define BAN_PANEL_ACTION_PAGE_NEXT "page_next"
#define BAN_PANEL_ACTION_SET_PER_PAGE "set_perpage"
#define BAN_PANEL_ACTION_SET_TAB "set_tab"

/// Admin Ban Panel
/datum/ban_panel
	var/datum/apiModel/Paginated/BanResourceList/banResourceList = null
	var/current_tab = BAN_PANEL_TAB_BAN_LIST
	var/current_page = 1
	var/per_page = 30

/datum/ban_panel/New()
	. = ..()
	src.banResourceList = bansHandler.getAll()

/datum/ban_panel/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/ban_panel/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/ban_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "BanPanel")
		ui.open()

/datum/ban_panel/ui_data(mob/user)
	. = ..()
	.["current_tab"] = src.current_tab
	.["per_page"] = src.per_page
	switch (src.current_tab)
		if (BAN_PANEL_TAB_BAN_LIST)
			.["ban_list"] = list(
				"search_response" = src.banResourceList?.ToList()
			)

/datum/ban_panel/ui_static_data(mob/user)
	. = ..()

/datum/ban_panel/ui_act(action, params)
	. = ..()
	if (.)
		return

	if (!usr.client) return

	switch (action)
		if (BAN_PANEL_ACTION_SEARCH)
			src.refresh_bans() // TODO: Actually search
			. = TRUE

		if (BAN_PANEL_ACTION_PAGE_PREV)
			var/prev_page = max(1, banResourceList.meta["current_page"] - 1)
			src.current_page = prev_page
			src.refresh_bans()
			. = TRUE

		if (BAN_PANEL_ACTION_PAGE_NEXT)
			var/next_page = min(banResourceList.meta["last_page"], banResourceList.meta["current_page"] + 1)
			src.current_page = next_page
			src.refresh_bans()
			. = TRUE

		if(BAN_PANEL_ACTION_SET_PER_PAGE)
			src.per_page = params["amount"]
			src.refresh_bans()
			. = TRUE

		if (BAN_PANEL_ACTION_SET_TAB)
			src.current_tab = params["value"]
			. = TRUE

/// Wrapper for /datum/bansHandler/proc/getAll
/datum/ban_panel/proc/refresh_bans(list/filters, sort_by, descending)
	src.banResourceList = bansHandler.getAll(
		filters = filters,
		sort_by = sort_by,
		descending = descending,
		page = src.current_page,
		per_page = src.per_page,
	)

#undef BAN_PANEL_TAB_BAN_LIST
#undef BAN_PANEL_TAB_JOB_BAN_LIST

#undef BAN_PANEL_ACTION_SEARCH
#undef BAN_PANEL_ACTION_PAGE_PREV
#undef BAN_PANEL_ACTION_PAGE_NEXT
#undef BAN_PANEL_ACTION_SET_PER_PAGE
#undef BAN_PANEL_ACTION_SET_TAB
