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
			var/datum/job/new_job = src.input_job(user)
			var/list/datum/forced_antagonist/new_antagonists = src.input_antagonist_roles(user)
			if (tgui_alert(user, "Create forced assignment with parameters (ckey: [ckey], job: [new_job ? new_job.name : "n/a"]\
				[length(new_antagonists) ? ", [length(new_antagonists)] antag role[(length(new_antagonists) == 0 || length(new_antagonists) > 1) \
				? "s" : ""]" : ""])?", "Confirmation", list("Create", "Cancel")) != "Create")
				return
			var/datum/forced_assignment/forced_assignment = new(ckey, new_job, new_antagonists)
			global.job_controls.forced_assignments[ckey] = forced_assignment
			message_admins("Admin [key_name(ui.user)] added a forced assignment to ckey [find_player(ckey) ? key_name(ckey) : ckey] ([new_job \
				? new_job : ""][length(new_antagonists) ? ", [length(new_antagonists)] antag roles" : ""]) on round start!")
			logTheThing(LOG_ADMIN, ui.user, "added forced assignment to ckey [find_player(ckey) ? key_name(ckey) : ckey] \
				([new_job ? new_job : ""][length(new_antagonists) ? ", [length(new_antagonists)] antag roles" : ""]) on round start")
			logTheThing(LOG_DIARY, ui.user, "added forced assignment to ckey [find_player(ckey) ? key_name(ckey) : ckey] \
				([new_job ? new_job : ""][length(new_antagonists) ? ", [length(new_antagonists)] antag roles" : ""]) on round start", "admin")
			. = TRUE

		if ("remove_forced_assignment")
			var/ckey = ckey(params["ckey"])
			var/datum/forced_assignment/forced_assignment = src.get_assignment_by_ckey(user, ckey)
			if (!istype(forced_assignment, /datum/forced_assignment))
				return
			message_admins("Admin [key_name(ui.user)] removed ckey [find_player(ckey) ? key_name(ckey) : \
				ckey] from forced assignments on round start!")
			logTheThing(LOG_ADMIN, ui.user, "removed forced assignment from ckey [ckey]")
			logTheThing(LOG_DIARY, ui.user, "removed forced assignment from ckey [ckey]", "admin")
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
			// user.Browse("<title>Forced Assignment Export</title><pre>[forced_assignment_export]</pre>", "window=forced_assignment_export;size=500x700")
			var/filename = "ForcedAssignments_[limit_chars(capitalize_each_word((config.server_name)), include_nums = TRUE, include_letters = TRUE)]_\
				[time2text(world.realtime,"YYYY-MM-DD")].txt"
			user.client << ftp(forced_assignment_export, filename)

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

		if ("edit_ckey")
			var/old_ckey = ckey(params["ckey"])
			var/datum/forced_assignment/forced_assignment = src.get_assignment_by_ckey(user, old_ckey)
			if (!istype(forced_assignment, /datum/forced_assignment))
				return
			var/new_ckey = ckey(tgui_input_text(user, "Designate ckey to assign forced assignment.", "Designate ckey"))
			if (!new_ckey)
				return
			if (global.job_controls.forced_assignments[new_ckey])
				boutput(user, SPAN_ALERT("Requested ckey [new_ckey] already has a forced assignment!"))
				return
			if (tgui_alert(user, "Confirm replacement from ckey [old_ckey] to [new_ckey].", "Confirmation", list("Confirm", "Cancel")) != "Confirm")
				return
			forced_assignment.ckey = new_ckey
			global.job_controls.forced_assignments -= old_ckey
			global.job_controls.forced_assignments[new_ckey] = forced_assignment
			message_admins("Admin [key_name(ui.user)] re-designated a forced assignment from ckey [find_player(old_ckey) ? key_name(old_ckey) : \
				old_ckey] to [find_player(new_ckey) ? key_name(new_ckey) : new_ckey]!")
			logTheThing(LOG_ADMIN, ui.user, "re-designated a forced assignment from ckey [old_ckey] to [new_ckey]")
			logTheThing(LOG_DIARY, ui.user, "re-designated a forced assignment from ckey [old_ckey] to [new_ckey]", "admin")
			. = TRUE

		if ("edit_job")
			var/target_ckey = params["ckey"]
			if (!length(target_ckey))
				return
			var/datum/forced_assignment/forced_assignment = src.get_assignment_by_ckey(user, target_ckey)
			if (!istype(forced_assignment, /datum/forced_assignment))
				return
			var/datum/job/old_job = forced_assignment.forced_job
			var/datum/job/new_job = src.input_job(user)
			if (!new_job)
				return
			if (tgui_alert(user, "Confirm re-assignment for ckey [target_ckey] from [old_job.name] to [new_job].", \
				"Confirmation", list("Confirm", "Cancel")) != "Confirm")
				return
			forced_assignment.change_job(new_job)
			message_admins("Admin [key_name(ui.user)] forced ckey [find_player(target_ckey) ? key_name(target_ckey) : \
				target_ckey] to roll [new_job] on round start!")
			logTheThing(LOG_ADMIN, ui.user, "added forced assignment [new_job] to ckey [target_ckey]")
			logTheThing(LOG_DIARY, ui.user, "added forced assignment [new_job] to ckey [target_ckey]", "admin")
			. = TRUE

		if ("add_antagonist_roles")
			var/target_ckey = params["ckey"]
			var/datum/forced_assignment/forced_assignment = src.get_assignment_by_ckey(user, target_ckey)
			if (!istype(forced_assignment, /datum/forced_assignment))
				return
			var/list/datum/forced_antagonist/new_antagonists = src.input_antagonist_roles(user, forced_assignment)
			if (!length(new_antagonists))
				return
			if (tgui_alert(user, "Confirm addition of [length(new_antagonists)] antag roles to [target_ckey]'s forced assignment.", "Confirmation", \
				list("Confirm", "Cancel")) != "Confirm")
				return
			forced_assignment.forced_antags += new_antagonists
			message_admins("Admin [key_name(ui.user)] added [length(new_antagonists)] more antag roles to [find_player(target_ckey) \
				? key_name(target_ckey) : target_ckey]'s forced assignment!")
			logTheThing(LOG_ADMIN, ui.user, "added [length(new_antagonists)] more antag roles to ckey [target_ckey]'s forced assignment")
			logTheThing(LOG_DIARY, ui.user, "added [length(new_antagonists)] more antag roles to ckey [target_ckey]'s forced assignment", "admin")
			. = TRUE

		if ("edit_antagonist_role")
			var/target_ckey = params["ckey"]
			var/datum/forced_assignment/forced_assignment = src.get_assignment_by_ckey(user, target_ckey)
			if (!istype(forced_assignment, /datum/forced_assignment))
				return
			var/datum/forced_antagonist/forced_antagonist = forced_assignment.forced_antags[params["displayName"]]
			if (!istype(forced_antagonist, /datum/forced_antagonist))
				return
			var/list/antagonist_params = src.adjust_antagonist_params(user)
			if (!length(antagonist_params))
				return
			if (tgui_alert(usr, "Confirm selected antagonist [forced_antagonist.display_name]. Equipment and abilities will[antagonist_params[1] == "Yes" \
				? "" : " NOT"] be added.[antagonist_params[3]].", "Designate antag roles", list("Confirm", "Cancel")) != "Confirm")
				return
			forced_antagonist.do_equipment = antagonist_params[1]
			forced_antagonist.do_objectives = antagonist_params[2]
			forced_antagonist.custom_objective = antagonist_params[4]
			. = TRUE

/datum/forced_assignment_panel/proc/input_job(mob/caller)
	. = tgui_input_list(caller, "Designate forced job to assign.", "Designate job", \
		(global.job_controls.staple_jobs|global.job_controls.special_jobs|global.job_controls.hidden_jobs))

/// For continuous input of multiple antagonist roles to a single ckey. Why would you need more than the one?
/datum/forced_assignment_panel/proc/input_antagonist_roles(mob/caller, datum/forced_assignment/forced_assignment)
	. = list()
	if (istype(forced_assignment, /datum/forced_assignment))
		. = forced_assignment.forced_antags
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
	var/list/antagonist_params = src.adjust_antagonist_params(caller)
	if (!length(antagonist_params))
		return
	if (tgui_alert(usr, "Confirm selected antagonist [selected_antagonist]. Equipment and abilities will[antagonist_params[1] == "Yes" \
		? "" : " NOT"] be added.[antagonist_params[3]].", "Designate antag roles", list("Confirm", "Cancel")) != "Confirm")
		return
	var/datum/forced_antagonist/new_forced_antagonist = new(eligible_antagonists[selected_antagonist], antagonist_params[1], antagonist_params[2], \
		antagonist_params[4])
	. = new_forced_antagonist

/datum/forced_assignment_panel/proc/adjust_antagonist_params(mob/caller)
	. = list()
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
	. = list(do_equipment, do_objectives, do_objectives_text, custom_objective)

/datum/forced_assignment_panel/proc/clear_forced_assignments()
	for (var/forced_assignment_index in global.job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[forced_assignment_index]
		qdel(forced_assignment)
	global.job_controls.forced_assignments = list()

/datum/forced_assignment_panel/proc/get_assignment_by_ckey(mob/caller, ckey)
	if (!(ckey in global.job_controls.forced_assignments))
		boutput(caller, SPAN_ALERT("Unable to find forced assignment attached to ckey [ckey]!"))
		return
	var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[ckey]
	if (!istype(forced_assignment, /datum/forced_assignment))
		return
	. = forced_assignment

/datum/forced_assignment_panel/proc/serialise_forced_assignments()
	. = list()
	for (var/forced_assignment_index in global.job_controls.forced_assignments)
		var/list/serialised_forced_assignment = list()
		var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[forced_assignment_index]
		var/datum/player/ckey_player = find_player(forced_assignment.ckey)
		serialised_forced_assignment = list(
			"ckey" = forced_assignment.ckey,
			"playerName" = ckey_player?.client?.mob?.name || null,
			"forcedJob" = forced_assignment.forced_job?.name || null,
		)
		if (length(forced_assignment.forced_antags))
			var/list/serialised_forced_antags = list()
			for (var/forced_antagonist_index in forced_assignment.forced_antags)
				var/list/serialised_forced_antag = list()
				var/datum/forced_antagonist/forced_antagonist = forced_assignment.forced_antags[forced_antagonist_index]
				serialised_forced_antag = list(
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
