/datum/forced_assignment_panel

/datum/forced_assignment_panel/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/forced_assignment_panel/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/forced_assignment_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ForcedAssignmentPanel")
		ui.open()

/datum/forced_assignment_panel/ui_data(mob/user)
	. = list(
		"forcedAssignments" = src.serialise_forced_assignments(),
	)

/datum/forced_assignment_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	USR_ADMIN_ONLY
	switch (action)
		if ("add_forced_assignment")
			var/ckey = ckey(tgui_input_text(usr, "Designate ckey to assign forced assignment.", "Designate ckey"))
			if (!ckey)
				return FALSE
			if (global.job_controls.forced_assignments[ckey])
				boutput(usr, SPAN_ALERT("Requested ckey [ckey] already has a forced assignment!"))
				return FALSE
			var/datum/job/assignment = tgui_input_list(usr, "Designate forced job to assign.", "Designate job", \
										(global.job_controls.staple_jobs|global.job_controls.special_jobs|global.job_controls.hidden_jobs))
			var/assignment_name = assignment.name
			if (tgui_alert(usr, "Create forced assignment with parameters (ckey: [ckey], job: [assignment ? assignment_name : "n/a"])?", \
				"Confirmation", list("Create", "Cancel")) != "Create")
				return FALSE
			var/datum/forced_assignment/forced_assignment = new(ckey, assignment_name)
			global.job_controls.forced_assignments[ckey] = forced_assignment
			message_admins("Admin [key_name(ui.user)] forced ckey [find_player(forced_assignment.ckey) ? key_name(forced_assignment.ckey) : \
				forced_assignment.ckey] to roll [!!assignment && " [assignment_name]"] on round start!")
			logTheThing(LOG_ADMIN, ui.user, "added forced assignment [!!assignment && " [assignment_name]"] to ckey [forced_assignment.ckey]")
			logTheThing(LOG_DIARY, ui.user, "added forced assignment [!!assignment && " [assignment_name]"] to ckey [forced_assignment.ckey]", "admin")
			. = TRUE

		if ("remove_forced_assignment")
			var/ckey = ckey(params["ckey"])
			if (!(ckey in global.job_controls.forced_assignments))
				boutput(usr, SPAN_ALERT("Unable to find forced assignment attached to ckey [ckey]!"))
				return FALSE
			var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[ckey]
			if (!istype(forced_assignment, /datum/forced_assignment))
				return FALSE
			message_admins("Admin [key_name(ui.user)] removed ckey [find_player(forced_assignment.ckey) ? key_name(forced_assignment.ckey) : forced_assignment.ckey] \
							from forced assignments on round start!")
			logTheThing(LOG_ADMIN, ui.user, "removed forced assignments from ckey [forced_assignment.ckey]")
			logTheThing(LOG_DIARY, ui.user, "removed forced assignments from ckey [forced_assignment.ckey]", "admin")
			qdel(forced_assignment)
			global.job_controls.forced_assignments -= ckey
			. = TRUE

		if ("clear_forced_assignments")
			if (!length(global.job_controls.forced_assignments))
				boutput(usr, SPAN_ALERT("No forced assignments to clear!"))
				return FALSE
			if (tgui_alert(usr, "Clear all forced assignments?", "Confirmation", list("Clear all", "Cancel")) != "Clear all")
				return FALSE
			src.clear_forced_assignments()
			message_admins("Admin [key_name(ui.user)] cleared all forced assignments!")
			logTheThing(LOG_ADMIN, ui.user, "cleared all forced assignments")
			logTheThing(LOG_DIARY, ui.user, "cleared all forced assignments", "admin")
			. = TRUE

		if ("import_forced_assignments")
			var/forced_assignment_import = input("Input forced assignment JSON.", "Import Forced Assignments") as message
			if (!length(forced_assignment_import))
				return FALSE
			if (tgui_alert(usr, "Confirm forced assignment import. This may override any existing assignments!", "Confirmation", list("Import", "Cancel")) != "Import")
				return FALSE
			var/list/forced_assignment_import_list = json_decode(forced_assignment_import)
			var/list/datum/forced_assignment/decoded_forced_assignments = src.decode_forced_assignments(forced_assignment_import_list)
			if (!length(decoded_forced_assignments))
				boutput(usr, SPAN_ALERT("Forced assignment JSON decoder returned an empty list!"))
				return FALSE
			src.clear_forced_assignments()
			global.job_controls.forced_assignments = decoded_forced_assignments
			message_admins("Admin [key_name(ui.user)] imported new forced assignments!")
			logTheThing(LOG_ADMIN, ui.user, "imported new forced assignments")
			logTheThing(LOG_DIARY, ui.user, "imported new forced assignments", "admin")
			. = TRUE

		if ("export_forced_assignments")
			if (!length(global.job_controls.forced_assignments))
				return
			var/forced_assignment_export = json_encode(src.serialise_forced_assignments(), JSON_PRETTY_PRINT)
			usr.Browse("<title>Forced Assignment Export</title><pre>[forced_assignment_export]</pre>", "window=forced_assignment_export;size=500x700")

/datum/forced_assignment_panel/proc/clear_forced_assignments()
	for (var/forced_assignment_index in global.job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[forced_assignment_index]
		qdel(forced_assignment)
	global.job_controls.forced_assignments = list()

/datum/forced_assignment_panel/proc/serialise_forced_assignments()
	. = list()
	for (var/forced_assignment_index in global.job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[forced_assignment_index]
		if (!istype(forced_assignment, /datum/forced_assignment))
			continue
		var/datum/player/ckey_player = find_player(forced_assignment.ckey)
		.[forced_assignment.ckey] = list(
			"ckey" = forced_assignment.ckey,
			"playerName" = ckey_player?.client?.mob?.name || null,
			"forcedJob" = forced_assignment.forced_job?.name || null,
		)

/datum/forced_assignment_panel/proc/decode_forced_assignments(list/decode_list)
	var/list/datum/forced_assignment/forced_assignment_buffer = list()
	for (var/forced_assignment_item_index in decode_list)
		var/forced_assignment_item = decode_list[forced_assignment_item_index]
		var/ckey = null
		var/job_name = null
		if (length(forced_assignment_item["ckey"]))
			ckey = forced_assignment_item["ckey"]
		if (length(forced_assignment_item["forcedJob"]))
			job_name = forced_assignment_item["forcedJob"]
		var/datum/forced_assignment/forced_assignment = new(ckey, job_name)
		forced_assignment_buffer[forced_assignment.ckey] = forced_assignment
	if (!length(forced_assignment_buffer))
		return FALSE
	return forced_assignment_buffer

/client/proc/cmd_forced_assignment_panel()
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Forced Assignment Panel"
	set desc = "Designate jobs and antagonist roles for certain ckeys to force-spawn as."
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (isnull(src.holder.forced_assignment_panel))
		src.holder.forced_assignment_panel = new

	src.holder.forced_assignment_panel.ui_interact(src.mob)
