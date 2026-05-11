/client/proc/cmd_forced_assignment_panel()
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Forced Assignment Panel"
	set desc = "Designate jobs and antagonist roles for certain ckeys to force-spawn as."
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (isnull(src.holder.forced_assignment_panel))
		src.holder.forced_assignment_panel = new

	src.holder.forced_assignment_panel.ui_interact(src.mob)

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
		"currentState" = global.current_state,
	)

/datum/forced_assignment_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	USR_ADMIN_ONLY
	var/mob/user = ui.user
	switch (action)
		if ("add_forced_assignment")
			var/ckey = ckey(tgui_input_text(user, "Designate ckey to assign forced assignment.", "Designate ckey"))
			if (!ckey)
				return
			if (global.job_controls.forced_assignments[ckey])
				boutput(user, SPAN_ALERT("Requested ckey [ckey] already has a forced assignment!"))
				return
			var/new_assignment = src.input_job(user)
			var/list/datum/forced_antagonist/new_antagonists = src.input_antagonist_roles(user)
			if (tgui_alert(user, "Create forced assignment with parameters (ckey: [ckey], job: [new_assignment ? new_assignment : "n/a"]\
				[length(new_antagonists) ? ", [length(new_antagonists)] antag role[(length(new_antagonists) == 0 || length(new_antagonists) > 1) \
				? "s" : ""]" : ""])?", "Confirmation", list("Create", "Cancel")) != "Create")
				return
			var/datum/forced_assignment/forced_assignment = new(ckey, new_assignment, new_antagonists)
			global.job_controls.forced_assignments[ckey] = forced_assignment
			message_admins("Admin [key_name(ui.user)] forced ckey [find_player(ckey) ? key_name(ckey) : \
				ckey] to roll [!!new_assignment && " [new_assignment]"] on round start!")
			logTheThing(LOG_ADMIN, ui.user, "added forced assignment [!!new_assignment && " [new_assignment]"] to ckey [ckey]")
			logTheThing(LOG_DIARY, ui.user, "added forced assignment [!!new_assignment && " [new_assignment]"] to ckey [ckey]", "admin")
			. = TRUE

		if ("remove_forced_assignment")
			var/ckey = ckey(params["ckey"])
			if (!(ckey in global.job_controls.forced_assignments))
				boutput(user, SPAN_ALERT("Unable to find forced assignment attached to ckey [ckey]!"))
				return
			var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[ckey]
			if (!istype(forced_assignment, /datum/forced_assignment))
				return
			message_admins("Admin [key_name(ui.user)] removed ckey [find_player(ckey) ? key_name(ckey) : \
				ckey] from forced assignments on round start!")
			logTheThing(LOG_ADMIN, ui.user, "removed forced assignments from ckey [ckey]")
			logTheThing(LOG_DIARY, ui.user, "removed forced assignments from ckey [ckey]", "admin")
			qdel(forced_assignment)
			global.job_controls.forced_assignments -= ckey
			. = TRUE

		if ("clear_forced_assignments")
			if (!length(global.job_controls.forced_assignments))
				boutput(user, SPAN_ALERT("No forced assignments to clear!"))
				return
			if (tgui_alert(user, "Clear all forced assignments?", "Confirmation", list("Clear all", "Cancel")) != "Clear all")
				return
			src.clear_forced_assignments()
			message_admins("Admin [key_name(ui.user)] cleared all forced assignments!")
			logTheThing(LOG_ADMIN, ui.user, "cleared all forced assignments")
			logTheThing(LOG_DIARY, ui.user, "cleared all forced assignments", "admin")
			. = TRUE

		if ("import_forced_assignments")
			var/forced_assignment_import = input("Input forced assignment JSON.", "Import Forced Assignments") as message
			if (!length(forced_assignment_import))
				return
			if (tgui_alert(user, "Confirm forced assignment import. This may override any existing assignments!", "Confirmation", \
				list("Import", "Cancel")) != "Import")
				return
			var/list/forced_assignment_import_list = json_decode(forced_assignment_import)
			var/list/datum/forced_assignment/decoded_forced_assignments = src.decode_forced_assignments(forced_assignment_import_list)
			if (!length(decoded_forced_assignments))
				boutput(user, SPAN_ALERT("Forced assignment JSON decoder returned an empty list!"))
				return
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
			// todo file save instead
			user.Browse("<title>Forced Assignment Export</title><pre>[forced_assignment_export]</pre>", "window=forced_assignment_export;size=500x700")

		if ("open_player_options")
			if (!user.client) return
			for (var/mob/M in mobs)
				if (M.ckey != params["ckey"])
					continue
				user.client.holder.playeropt(M)
				break

		if ("private_message_player")
			if (!user.client) return
			for (var/mob/M in mobs)
				if (M.ckey != params["ckey"])
					continue
				do_admin_pm(M.ckey, user)
				break

		if ("edit_job")
			var/target_ckey = params["ckey"]
			if (!length(target_ckey))
				return
			if (!(target_ckey in global.job_controls.forced_assignments))
				return
			var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[target_ckey]
			var/datum/job/old_assignment = forced_assignment.forced_job
			var/new_assignment = src.input_job(user)
			if (!new_assignment)
				return
			if (tgui_alert(user, "Confirm re-assignment for ckey [target_ckey] from [old_assignment.name] to [new_assignment].", \
				"Confirmation", list("Confirm", "Cancel")) != "Confirm")
				return
			forced_assignment.change_job(new_assignment)
			message_admins("Admin [key_name(ui.user)] forced ckey [find_player(target_ckey) ? key_name(target_ckey) : \
				target_ckey] to roll [new_assignment] on round start!")
			logTheThing(LOG_ADMIN, ui.user, "added forced assignment [new_assignment] to ckey [target_ckey]")
			logTheThing(LOG_DIARY, ui.user, "added forced assignment [new_assignment] to ckey [target_ckey]", "admin")
			. = TRUE

		if ("edit_antagonist_role")
			. = TRUE

/datum/forced_assignment_panel/proc/input_job(mob/caller)
	. = tgui_input_list(caller, "Designate forced job to assign.", "Designate job", \
		(global.job_controls.staple_jobs|global.job_controls.special_jobs|global.job_controls.hidden_jobs))

/// For continuous input of multiple antagonist roles to a single ckey. Why would you need more than the one?
/datum/forced_assignment_panel/proc/input_antagonist_roles(mob/caller)
	. = list()
	while (TRUE)
		var/datum/forced_antagonist/new_forced_antagonist = src.input_antagonist(caller, continuous = TRUE, current_list = .)
		if (istype(new_forced_antagonist, /datum/forced_antagonist))
			.[new_forced_antagonist.display_name] = new_forced_antagonist
			continue
		break

/// Cargo cult from `code\modules\admin\admin.dm`.
/datum/forced_assignment_panel/proc/input_antagonist(mob/caller, continuous = FALSE, list/datum/forced_antagonist/current_list)
	var/list/eligible_antagonists = list()
	var/list/eligible_antagonist_types = concrete_typesof(/datum/antagonist) - (concrete_typesof(/datum/antagonist/subordinate) \
		+ concrete_typesof(/datum/antagonist/generic))
	for (var/antag_path in eligible_antagonist_types)
		var/datum/antagonist/antag_role = antag_path
		eligible_antagonists[initial(antag_role.display_name)] = antag_path
	for (var/existing_antag in current_list)
		eligible_antagonists -= existing_antag
	if (!length(eligible_antagonists))
		boutput(caller, SPAN_ALERT("Unable to input antagonist role as no valid antagonist roles exist!"))
		return
	var/selected_antagonist = tgui_input_list(caller, "Designate forced antagonist role.[!!continuous && " Cancel to complete addition. \
		[length(current_list)] selected so far."]", "Designate antag roles", eligible_antagonists)
	if (!selected_antagonist)
		return
	for (var/forced_antagonist_index in current_list)
		var/datum/forced_antagonist/forced_antagonist_to_check = current_list[forced_antagonist_index]
		var/datum/antagonist/antagonist_to_check = forced_antagonist_to_check.antagonist_path
		if (!initial(antagonist_to_check.mutually_exclusive))
			continue
		if (tgui_alert(caller, "Current list has an antagonist role ([initial(antagonist_to_check.display_name)]) that will not naturally occur with \
			others. Proceed anyway? This might cause !!FUN!! interactions.", "Force Antagonist", list("Yes", "Cancel")) != "Yes")
			return
	var/do_equipment = tgui_alert(caller, "Give the antagonist its default equipment? (Uplinks, clothing, special abilities, etc.)", \
		"Designate antag roles", list("Yes", "No", "Cancel"))
	if (do_equipment == "Cancel")
		return
	var/do_objectives = tgui_alert(caller, "Assign randomly-generated objectives?", "Designate antag roles", list("Yes", "No", "Custom"))
	var/custom_objective = ""
	if (do_objectives == "Custom")
		custom_objective = tgui_input_text(caller, "Input custom objective text", "Designate antag roles")
	var/do_objectives_text = ""
	switch (do_objectives)
		if ("No")
			do_objectives_text = " Objectives will not be present"
		if ("Yes")
			do_objectives_text = " Objectives will be generated automatically"
		if ("Custom")
			do_objectives_text = " A custom objective will be added"
	if (tgui_alert(usr, "Confirm selected antagonist [selected_antagonist]. Equipment and abilities will[do_equipment == "Yes" ? "" : " NOT"] be \
		added.[do_objectives_text].", "Designate antag roles", list("Confirm", "Cancel")) != "Confirm")
		return
	var/datum/forced_antagonist/new_forced_antagonist = new(eligible_antagonists[selected_antagonist], do_equipment, do_objectives,\
		custom_objective)
	. = new_forced_antagonist

/datum/forced_assignment_panel/proc/clear_forced_assignments()
	for (var/forced_assignment_index in global.job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[forced_assignment_index]
		qdel(forced_assignment)
	global.job_controls.forced_assignments = list()

/datum/forced_assignment_panel/proc/serialise_forced_assignments()
	. = list()
	for (var/forced_assignment_index in global.job_controls.forced_assignments)
		var/list/serialised_forced_assignment = list()
		var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[forced_assignment_index]
		var/datum/player/ckey_player = find_player(forced_assignment.ckey)
		serialised_forced_assignment = list(
			"ckey" = forced_assignment.ckey,
			"playerName" = ckey_player?.client?.mob?.name || null,
			"forcedJobInput" = forced_assignment.forced_job || null,
			"forcedJob" = forced_assignment.forced_job?.name || null,
			"forcedAntagInput" = forced_assignment.forced_antags_input || null,
		)
		if (length(forced_assignment.forced_antags))
			var/list/serialised_forced_antags = list()
			for (var/forced_antagonist_index in forced_assignment.forced_antags)
				var/list/serialised_forced_antag = list()
				var/datum/forced_antagonist/forced_antagonist = forced_assignment.forced_antags[forced_antagonist_index]
				serialised_forced_antag = list(
					"antagonistPath" = forced_antagonist.antagonist_path,
					"displayName" = forced_antagonist.display_name,
					"doEquipment" = forced_antagonist?.do_equipment || null,
					"doObjectives" = forced_antagonist?.do_objectives || null,
					"customObjective" = forced_antagonist?.custom_objective || null,
				)
				serialised_forced_antags[forced_antagonist_index] = serialised_forced_antag
			serialised_forced_assignment["forcedAntags"] = serialised_forced_antags
		.[forced_assignment.ckey] = serialised_forced_assignment

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
