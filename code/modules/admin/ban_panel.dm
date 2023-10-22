/// Admin Ban Panel
/datum/ban_panel

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

/datum/ban_panel/ui_act(action, params)
	. = ..()
	if (.)
		return
