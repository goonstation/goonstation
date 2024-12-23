#define get_job(mind) ((!mind.assigned_role || (mind.assigned_role == "MODE")) ? null : "[mind.assigned_role]")

/**
 *	Antagonist panel datums serve as per-UI-user datums that pass data fetched from the global antagonist panel data singleton
 *	to the UI. These datums will also store and pass user specific data such as the current tab and subordinate antagonist data
 *	requested by the UI user.
 */
/datum/antagonist_panel
	/// The global antagonist panel data generator and cache to request tab data from.
	var/static/datum/antagonist_panel_data/panel_data
	/// Antagonist datums from whom to generate subordinate antagonist data for.
	var/list/datum/antagonist/antagonist_datums_to_get_subordinate_data_for
	/// The current tab type displayed on the UI.
	var/current_tab

/datum/antagonist_panel/New()
	. = ..()

	src.panel_data ||= get_singleton(/datum/antagonist_panel_data)

	src.antagonist_datums_to_get_subordinate_data_for = list()

/datum/antagonist_panel/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/antagonist_panel/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/datum/antagonist_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AntagonistPanel")
		ui.open()

/datum/antagonist_panel/ui_data(mob/user)
	return src.panel_data.request_ui_data(src.current_tab) + list(
		"subordinateAntagonists" = src.generate_subordinate_antagonist_data()
	)

/datum/antagonist_panel/ui_static_data(mob/user)
	return list(
		"gameMode" = ticker?.mode?.name,
		"tabToOpenOn" = src.current_tab,
	)

/datum/antagonist_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return TRUE

	switch(action)
		if ("set_tab")
			src.current_tab = params["index"]
			src.antagonist_datums_to_get_subordinate_data_for = list()
			ui.send_update()

		if ("jump_to")
			var/atom/movable/target = locate(params["target"])

			if (istype(target, /datum/mind))
				var/datum/mind/mind = target
				target = mind.current

			if (!ui.user || !target)
				return

			ui.user.set_loc(get_turf(target))

		if ("admin_pm")
			var/datum/mind/mind = locate(params["mind_ref"])
			if (!ui.user || !mind?.ckey)
				return

			do_admin_pm(mind.ckey, ui.user)

		if ("player_options")
			var/datum/mind/mind = locate(params["mind_ref"])
			if (!ui.user || !mind?.current)
				return

			ui.user.client.cmd_admin_playeropt(mind.current)

		if ("view_variables")
			var/datum/antagonist/antagonist_datum = locate(params["antagonist_datum"])
			if (!ui.user || !antagonist_datum)
				return

			ui.user.client.debug_variables(antagonist_datum)

		if ("request_subordinate_antagonist_data")
			var/datum/antagonist/antagonist_datum = locate(params["antagonist_datum"])

			src.antagonist_datums_to_get_subordinate_data_for |= antagonist_datum
			ui.send_update()

		if ("unrequest_subordinate_antagonist_data")
			var/datum/antagonist/antagonist_datum = locate(params["antagonist_datum"])

			src.antagonist_datums_to_get_subordinate_data_for -= antagonist_datum
			ui.send_update()

/// Returns subordinate antagonist data for all antagonist datums listed in `antagonist_datums_to_get_subordinate_data_for`.
/datum/antagonist_panel/proc/generate_subordinate_antagonist_data()
	. = list()

	for (var/datum/antagonist/antagonist_datum as anything in src.antagonist_datums_to_get_subordinate_data_for)
		.["\ref[antagonist_datum]"] = list()

		for (var/datum/antagonist/subordinate_antagonist_datum as anything in antagonist_datum.owner.subordinate_antagonists)
			var/turf/T = get_turf(subordinate_antagonist_datum.owner.current)
			var/area/A = get_area(subordinate_antagonist_datum.owner.current)

			.["\ref[antagonist_datum]"] += list(list(
				"mind_ref" = "\ref[subordinate_antagonist_datum.owner]",
				"antagonist_datum" = "\ref[subordinate_antagonist_datum]",
				"display_name" = subordinate_antagonist_datum.display_name,
				"real_name" = subordinate_antagonist_datum.owner.current.real_name,
				"ckey" = subordinate_antagonist_datum.owner.displayed_key,
				"job" = get_job(subordinate_antagonist_datum.owner),
				"dead" = is_dead_or_ghost_role(subordinate_antagonist_datum.owner.current),

				"area" = A.name,
				"coordinates" = "([T.x], [T.y], [T.z])",
			))
