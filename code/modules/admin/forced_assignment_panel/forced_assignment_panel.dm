/// Increment when changes to data serialisation are made, please!
#define FORCED_ASSIGNMENT_DATA_VER 1

/client/proc/cmd_forced_assignment_panel()
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Forced Assignment Panel"
	set desc = "Designate jobs and antagonist roles for certain ckeys to force-spawn as."
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (src.holder.level >= LEVEL_MOD)
		global.forced_assignment_panel.ui_interact(src.mob)

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
			if (src.import_forced_assignments(user))
				. = TRUE

		if ("export_forced_assignments")
			src.export_forced_assignments(user)

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
			if (tgui_alert(user, "Confirm re-assignment for ckey [target_ckey][old_job ? " from [old_job.name]" : ""] to [new_job].", \
				"Confirmation", list("Confirm", "Cancel")) != "Confirm")
				return
			forced_assignment.change_job(new_job)
			message_admins("Admin [key_name(ui.user)] forced ckey [find_player(target_ckey) ? key_name(target_ckey) : \
				target_ckey] to roll [new_job] on round start!")
			logTheThing(LOG_ADMIN, ui.user, "added forced assignment [new_job] to ckey [target_ckey]")
			logTheThing(LOG_DIARY, ui.user, "added forced assignment [new_job] to ckey [target_ckey]", "admin")
			. = TRUE

		if ("edit_antagonist")
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
			forced_antagonist.do_equipment = antagonist_params[1] == "Yes" ? TRUE : FALSE
			forced_antagonist.do_objectives = antagonist_params[2] == "Yes" ? TRUE : FALSE
			forced_antagonist.custom_objective = antagonist_params[4]
			message_admins("Admin [key_name(ui.user)] edited ckey [find_player(target_ckey) ? key_name(target_ckey) : \
				target_ckey]'s designated forced antagonist role!")
			logTheThing(LOG_ADMIN, ui.user, "edited ckey [target_ckey]'s designated forced antagonist role")
			logTheThing(LOG_DIARY, ui.user, "edited ckey [target_ckey]'s designated forced antagonist role", "admin")
			. = TRUE

		if ("remove_job")
			var/target_ckey = params["ckey"]
			var/datum/forced_assignment/forced_assignment = src.get_assignment_by_ckey(user, target_ckey)
			if (!istype(forced_assignment, /datum/forced_assignment))
				return
			forced_assignment.forced_job = null
			message_admins("Admin [key_name(ui.user)] removed ckey [find_player(target_ckey) ? key_name(target_ckey) : \
				target_ckey]'s designated forced job role!")
			logTheThing(LOG_ADMIN, ui.user, "removed ckey [target_ckey]'s designated forced job role")
			logTheThing(LOG_DIARY, ui.user, "removed ckey [target_ckey]'s designated forced job role", "admin")
			. = TRUE

		if ("remove_antagonist")
			var/target_ckey = params["ckey"]
			var/datum/forced_assignment/forced_assignment = src.get_assignment_by_ckey(user, target_ckey)
			if (!istype(forced_assignment, /datum/forced_assignment))
				return
			var/datum/forced_antagonist/forced_antagonist = forced_assignment.forced_antags[params["displayName"]]
			if (!istype(forced_antagonist, /datum/forced_antagonist))
				return
			forced_assignment.forced_antags -= params["displayName"]
			qdel(forced_antagonist)
			message_admins("Admin [key_name(ui.user)] removed ckey [find_player(target_ckey) ? key_name(target_ckey) : \
				target_ckey]'s designated forced antagonist role!")
			logTheThing(LOG_ADMIN, ui.user, "removed ckey [target_ckey]'s designated forced antagonist role")
			logTheThing(LOG_DIARY, ui.user, "removed ckey [target_ckey]'s designated forced antagonist role", "admin")
			. = TRUE

/datum/forced_assignment_panel/proc/input_job(mob/caller)
	. = tgui_input_list(caller, "Designate forced job to assign.", "Designate job", \
		(global.job_controls.staple_jobs|global.job_controls.special_jobs|global.job_controls.hidden_jobs))

/// For continuous input of multiple antagonist roles to a single ckey. Why would you need more than the one?
/datum/forced_assignment_panel/proc/input_antagonist_roles(mob/caller, datum/forced_assignment/forced_assignment)
	var/list/output_buffer = list()
	while (TRUE)
		var/datum/forced_antagonist/new_forced_antagonist = src.input_antagonist(caller, TRUE, output_buffer, forced_assignment?.forced_antags)
		if (istype(new_forced_antagonist, /datum/forced_antagonist))
			output_buffer[new_forced_antagonist.display_name] = new_forced_antagonist
			continue
		break
	. = output_buffer

/// Cargo cult from `code\modules\admin\admin.dm`.
/datum/forced_assignment_panel/proc/input_antagonist(mob/caller, continuous = FALSE, list/datum/forced_antagonist/output_buffer, list/datum/forced_antagonist/existing_list)
	var/list/datum/forced_antagonist/combined_lists = output_buffer + (existing_list || list())
	var/list/eligible_antagonists = list()
	var/list/eligible_antagonist_types = concrete_typesof(/datum/antagonist) - (concrete_typesof(/datum/antagonist/subordinate))
	for (var/antag_path in eligible_antagonist_types)
		var/datum/antagonist/antag_role = antag_path
		eligible_antagonists[initial(antag_role.display_name)] = antag_path
	for (var/existing_antag in combined_lists)
		eligible_antagonists -= existing_antag
	if (!length(eligible_antagonists))
		boutput(caller, SPAN_ALERT("Unable to input antagonist role as no valid antagonist roles exist!"))
		return
	var/selected_antagonist_name = tgui_input_list(caller, "Designate forced antagonist role.[!!continuous && " Cancel to complete addition. \
		[length(output_buffer)] selected so far."]", "Designate antag roles", eligible_antagonists)
	if (!selected_antagonist_name)
		return
	for (var/forced_antagonist_index in combined_lists)
		var/datum/forced_antagonist/forced_antagonist_to_check = combined_lists[forced_antagonist_index]
		var/datum/antagonist/antagonist_to_check = get_antagonist_datum_type(forced_antagonist_to_check.id)
		if (!initial(antagonist_to_check.mutually_exclusive))
			continue
		if (tgui_alert(caller, "Current list has an antagonist role ([capitalize(initial(antagonist_to_check.display_name))]) that will not \
			naturally occur with others. Proceed anyway? This might cause !!FUN!! interactions.", "Force Antagonist", list("Yes", "Cancel")) != "Yes")
			return
	var/list/antagonist_params = src.adjust_antagonist_params(caller)
	if (!length(antagonist_params))
		return
	if (tgui_alert(usr, "Confirm selected antagonist [selected_antagonist_name]. Equipment and abilities will[antagonist_params[1] == "Yes" \
		? "" : " NOT"] be added.[antagonist_params[3]].", "Designate antag roles", list("Confirm", "Cancel")) != "Confirm")
		return
	var/datum/antagonist/selected_antagonist = eligible_antagonists[selected_antagonist_name]
	var/datum/forced_antagonist/new_forced_antagonist = new(initial(selected_antagonist.id), antagonist_params[1] == "Yes" ? TRUE : FALSE, \
		antagonist_params[2] == "Yes" ? TRUE : FALSE, antagonist_params[4])
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
					"antagID" = forced_antagonist.id,
					"displayName" = forced_antagonist.display_name,
					"doEquipment" = forced_antagonist.do_equipment || null,
					"doObjectives" = forced_antagonist.do_objectives || null,
					"customObjective" = forced_antagonist.custom_objective || null,
				)
				serialised_forced_antags[forced_antagonist_index] = serialised_forced_antag
			serialised_forced_assignment["forcedAntags"] = serialised_forced_antags
		.[forced_assignment.ckey] = serialised_forced_assignment

/datum/forced_assignment_panel/proc/decode_forced_assignments(list/decode_list, mob/caller)
	var/list/datum/forced_assignment/forced_assignment_buffer = list()
	for (var/forced_assignment_item_index in decode_list)
		var/forced_assignment_item = decode_list[forced_assignment_item_index]
		var/ckey = ""
		if (length(forced_assignment_item["ckey"]))
			ckey = forced_assignment_item["ckey"]
		if (ckey in global.job_controls.forced_assignments)
			boutput(caller, SPAN_ALERT("CKey [ckey] already has an entry in the forced assignments list! Skipping!"))
			continue
		var/job_name = ""
		if (length(forced_assignment_item["forcedJob"]))
			job_name = forced_assignment_item["forcedJob"]
		var/datum/job/new_job = null
		if (length(job_name))
			new_job = find_job_in_controller_by_string(job_name)
		var/list/datum/forced_antagonist/forced_antagonist_buffer = list()
		var/list/forced_antags_list = forced_assignment_item["forcedAntags"]
		if (length(forced_antags_list))
			for (var/forced_antagonist_item_index in forced_antags_list)
				var/forced_antagonist_item = forced_antags_list[forced_antagonist_item_index]
				var/antagonist_id = ""
				if (length(forced_antagonist_item["antagID"]))
					antagonist_id = forced_antagonist_item["antagID"]
				var/do_equipment = forced_antagonist_item["doEquipment"] ? TRUE : FALSE
				var/do_objectives = forced_antagonist_item["doObjectives"] ? TRUE : FALSE
				var/custom_objective = ""
				if (length(forced_antagonist_item["customObjective"]))
					custom_objective = forced_antagonist_item["customObjective"]
				var/datum/forced_antagonist/forced_antagonist = new(antagonist_id, do_equipment, do_objectives, custom_objective)
				forced_antagonist_buffer[forced_antagonist.display_name] = forced_antagonist
		var/datum/forced_assignment/forced_assignment = new(ckey, new_job, forced_antagonist_buffer)
		forced_assignment_buffer[forced_assignment.ckey] = forced_assignment
	if (!length(forced_assignment_buffer))
		return FALSE
	return forced_assignment_buffer

/datum/forced_assignment_panel/proc/export_forced_assignments(mob/caller)
	if (!length(global.job_controls.forced_assignments))
		return
	var/savefile/export = new()
	var/filename = "ForcedAssignmentsV[FORCED_ASSIGNMENT_DATA_VER]_[time2text(world.realtime,"YYYY-MM-DD")].sav"
	export["version"] << FORCED_ASSIGNMENT_DATA_VER
	export["body"] << src.serialise_forced_assignments()
	if (fexists(filename))
		fdel(filename)
	var/export_file = file(filename)
	export.ExportText("/", export_file)
	caller.client << ftp(export_file, filename)
	SPAWN(15 SECONDS)
		var/tries = 0
		while ((fdel(filename) == 0) && tries++ < 10)
			sleep(30 SECONDS)

/datum/forced_assignment_panel/proc/import_forced_assignments(mob/caller)
	var/file = input(caller) as file|null
	if (!file)
		return
	var/savefile/import = new()
	import.ImportText("/", file2text(file))
	var/file_version = null
	import["version"] >> file_version
	if (file_version != FORCED_ASSIGNMENT_DATA_VER)
		boutput(caller, SPAN_ALERT("The forced assignment file you are attempting to import is incompatible with the current version of the system!"))
		return
	var/list/forced_assignment_import_list = list()
	import["body"] >> forced_assignment_import_list
	var/list/datum/forced_assignment/decoded_forced_assignments = src.decode_forced_assignments(forced_assignment_import_list)
	if (!length(decoded_forced_assignments))
		boutput(caller, SPAN_ALERT("Forced assignment decoder returned an empty list!"))
		return
	global.job_controls.forced_assignments += decoded_forced_assignments
	message_admins("Admin [key_name(caller)] imported new forced assignments!")
	logTheThing(LOG_ADMIN, caller, "imported new forced assignments")
	logTheThing(LOG_DIARY, caller, "imported new forced assignments", "admin")
	. = TRUE
