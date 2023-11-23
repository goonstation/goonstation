#define BAN_PANEL_TAB_BAN_LIST "ban_list"
#define BAN_PANEL_TAB_JOB_BAN_LIST "job_ban_list"

#define BAN_PANEL_ACTION_SEARCH "ban_search"
#define BAN_PANEL_ACTION_SET_TAB "set_tab"

/// Admin Ban Panel
/datum/ban_panel
	var/datum/apiModel/Paginated/BanResourceList/banResourceList = null
	var/current_tab = BAN_PANEL_TAB_BAN_LIST

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
			src.banResourceList = bansHandler.getAll()
			. = TRUE
		if (BAN_PANEL_ACTION_SET_TAB)
			src.current_tab = params["value"]
			. = TRUE

#undef BAN_PANEL_TAB_BAN_LIST
#undef BAN_PANEL_TAB_JOB_BAN_LIST

#undef BAN_PANEL_ACTION_SEARCH
#undef BAN_PANEL_ACTION_SET_TAB
