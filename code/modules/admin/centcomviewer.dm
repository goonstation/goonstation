// API Documentation - https://centcom.melonmesa.com/swagger/index.html
/// Admin CentCom Viewer Panel for looking up public bans on other servers via the CentCom Viewer API
/datum/centcomviewer
	/// whether or not we are filtering inactive bans from view
	var/filterInactive = FALSE
	/// target key of the user, the centcom api will make it a ckey on its own
	var/target_key
	/// set if we need to force an update of the static data, used when we want to view a different player but have an old window still open
	var/force_static_data_update = FALSE

/datum/centcomviewer/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/centcomviewer/ui_status(mob/user)
  return tgui_admin_state.can_use_topic(src, user)

/datum/centcomviewer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CentComViewer")
		ui.open()
		force_static_data_update = FALSE
	else if (force_static_data_update)
		update_static_data(user, ui)
		force_static_data_update = FALSE

/datum/centcomviewer/ui_static_data(mob/user)
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "https://centcom.melonmesa.com/ban/search/[target_key]", "", "")
	request.begin_async()
	UNTIL(request.is_complete(), 10 SECONDS)
	var/datum/http_response/response = request.into_response()
	var/list/ban_data
	if (rustg_json_is_valid(response.body))
		ban_data = json_decode(response.body)
		if (ban_data["errors"])
			ban_data = list()
	else
		ban_data = list()
	. = list(
			"banData" = ban_data,
			"key" = target_key,
		)

/datum/centcomviewer/ui_data(mob/user)
	. = list(
			"filterInactive" = filterInactive
		)

/datum/centcomviewer/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle-filterInactive")
			filterInactive = !filterInactive
			. = TRUE
		if("updateKey")
			target_key = copytext(ckeyEx(params["value"]), 1, 100)
			update_static_data(ui.user, ui)
			. = TRUE
