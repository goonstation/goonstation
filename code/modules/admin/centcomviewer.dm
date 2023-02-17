// API Documentation - https://centcom.melonmesa.com/swagger/index.html
/// Admin CentCom Viewer Panel for looking up public bans on other servers via the CentCom Viewer API
/datum/centcomviewer
	/// whether or not we are filtering inactive bans from view
	var/filterInactive = FALSE
	///target key of the user, the centcom api will make it a ckey on its own
	var/target_key

/datum/centcomviewer/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/centcomviewer/ui_status(mob/user)
  return tgui_admin_state.can_use_topic(src, user)

/datum/centcomviewer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CentComViewer")
		ui.open()
	else
		update_static_data(user, ui)

/datum/centcomviewer/ui_static_data(mob/user)
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "https://centcom.melonmesa.com/ban/search/[target_key]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	. = list(
			"banData" = response.body,
			"key" = target_key,
		)

/datum/centcomviewer/ui_data(mob/user)
	. = list(
			"filterInactive" = filterInactive
		)

/datum/centcomviewer/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle-filterInactive")
			filterInactive = !filterInactive
			. = TRUE
