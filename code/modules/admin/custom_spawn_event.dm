//this is for the admin Custom Ghost Spawn verb, which has nothing to do with the random event system because it sucks
/datum/spawn_event
	///All the roles we'll spawn, prioritises them in the order they are in in the list
	var/list/datum/spawn_event_role/roles_to_spawn = list()
	/// Name of the spawn event, shown to ghosts when asking "would you like to spawn as x?"
	var/title = null
	///How long does the popup stay up for?
	var/ghost_confirmation_delay = 30 SECONDS
	///Do we give them a popup or just spawn them directly?
	var/ask_permission = TRUE
	///Include DNR ghosts
	var/allow_dnr = FALSE

	New()
		. = ..()
		src.roles_to_spawn += new/datum/spawn_event_role()

	proc/contains_antag_role()
		for(var/datum/spawn_event_role/role in src.roles_to_spawn)
			if(role.antag_role)
				return TRUE
		return FALSE

	proc/get_title()
		if(!length(src.title))
			var/new_title = ""
			var/plural = ""
			var/datum/spawn_event_role/first_role = src.roles_to_spawn[1]
			if(length(src.roles_to_spawn) > 1)
				new_title += "part of a group containing "
				if(first_role.amount_to_spawn > 1)
					new_title += "a "
				else
					plural = "s"
			else if(first_role.amount_to_spawn > 1)
				new_title += "part of a group of "
				plural = "s"
			else
				new_title += "a "
			if(first_role.antag_role)
				new_title += "[get_antagonist_datum_type(first_role.antag_role).display_name] "
			new_title += "[first_role.get_mob_name()][plural] "
			src.title = new_title
		return src.title

	proc/do_spawn()
		if(!length(src.roles_to_spawn))
			return

		var/displayed_title = src.get_title()
		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as [displayed_title]?")
		text_messages.Add("You are eligible to be respawned as [displayed_title]. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of respawns. Please wait...")

		if (src.ask_permission)
			message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		var/list/datum/mind/candidates = dead_player_list(TRUE, src.ghost_confirmation_delay, text_messages,
			allow_dead_antags = TRUE,
			require_client = TRUE,
			do_popup = src.ask_permission,
			for_antag = src.contains_antag_role(),
			allow_dnr = src.allow_dnr
		)

		// We've collected all our candidates, hopefully.
		if (!length(candidates))
			message_admins("No ghosts responded to spawn event: [displayed_title]")
			return
		for (var/datum/spawn_event_role/role in src.roles_to_spawn)
			if (!length(candidates))
				break
			if (role.spawn_directly)
				role.amount_to_spawn = 1
			for (var/i in 1 to role.amount_to_spawn)
				if (!length(candidates))
					break
				var/datum/mind/mind = pick(candidates)
				candidates -= mind
				role.spawn_target(mind)


/datum/spawn_event_role
	var/thing_to_spawn = /mob/living/carbon/human/normal
	///If true, only a single ghost will be spawned and placed directly into the mob
	var/spawn_directly = FALSE
	///A custom location to spawn the mobs (can also be a landmark string)
	var/turf/spawn_loc = LANDMARK_LATEJOIN
	///How many copies of thing_to_spawn do we want?
	var/amount_to_spawn = 1
	///Antag role ID to assign to the players on spawn
	var/antag_role = null
	///Custom objective text to display to players on spawn
	var/objective_text = ""
	///Should antag datums give their default equipment (replaces whatever is currently equipped in those slots)
	var/equip_antag = TRUE
	///Should these newly spawned players show up on the manifest?
	var/add_to_manifest = FALSE
	///Let players pick their own name on respawning? (Can't be disabled if selected job normally allows it)
	var/choose_name = FALSE

	proc/get_spawn_loc()
		if (isturf(src.spawn_loc))
			return src.spawn_loc
		return pick_landmark(src.spawn_loc)

	proc/get_mob_name()
		if (ismob(src.thing_to_spawn))
			var/mob/mob = src.thing_to_spawn
			return mob.real_name || mob.name
		if (ispath(src.thing_to_spawn, /mob))
			var/mob/mob = src.thing_to_spawn
			return initial(mob.name)
		return src.thing_to_spawn //job name etc.

	proc/get_mob_instance(gender)
		if (ismob(src.thing_to_spawn))
			if (src.spawn_directly)
				return src.thing_to_spawn
			else
				return semi_deep_copy(src.thing_to_spawn, src.get_spawn_loc())

		if (ispath(src.thing_to_spawn, /mob))
			return new src.thing_to_spawn(src.get_spawn_loc())
		if (istext(src.thing_to_spawn)) //if it's a string then it's (hopefully) a job name
			var/mob/living/carbon/human/normal/M = new/mob/living/carbon/human/normal(src.get_spawn_loc())
			M.initializeBioholder(gender) //try to preserve gender if we can
			M.job = src.thing_to_spawn
			SPAWN(0)
				M.JobEquipSpawned(src.thing_to_spawn, no_special_spawn = TRUE)
			return M

	proc/spawn_target(var/datum/mind/mind)
		var/mob/new_mob = src.get_mob_instance(mind.current?.client?.preferences?.gender)
		//clean up some references, may help with random client crashes?
		new_mob.ckey = null
		new_mob.client = null
		new_mob.mind = null

		new_mob.ai?.die()
		if (ishuman(new_mob))
			var/mob/living/carbon/human/human = new_mob
			human.is_npc = FALSE
			human.ai_set_active(FALSE)
			human.abilityHolder.removeAbility(/datum/targetable/ai_toggle)

		message_admins("[key_name(mind.current)] respawned as \a [src.get_mob_name()]")
		logTheThing(LOG_ADMIN, mind.current, "respawned as \a [src.get_mob_name()] from a custom spawn event triggered by [key_name(usr)].")

		mind.transfer_to(new_mob)
		if (istext(src.thing_to_spawn)) //it's a job
			var/datum/job/job = find_job_in_controller_by_string(src.thing_to_spawn)
			new_mob.mind.assigned_role = src.thing_to_spawn
			if (src.add_to_manifest)
				var/obj/item/device/pda2/pda = locate() in new_mob
				global.data_core.addManifest(new_mob, "", "", pda?.net_id, "")
			if(istype(job) && job.change_name_on_spawn) //Will already be called by the job setup.
				src.choose_name = FALSE

		SPAWN(1) //job equip procs have to be SPAWN(0) so this has to be SPAWN(1) for them to get an uplink, yes I know but mob init order is cursed and evil
			if (src.antag_role == "generic_antagonist")
				mind.add_generic_antagonist("generic_antagonist", new_mob.real_name, do_equip = src.equip_antag, do_objectives = FALSE, do_relocate = FALSE, source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE)
			else if (src.antag_role)
				if (mind.get_antagonist(src.antag_role))
					mind.remove_antagonist(src.antag_role, ANTAGONIST_REMOVAL_SOURCE_OVERRIDE)
				mind.add_antagonist(src.antag_role, do_relocate = FALSE, do_objectives = FALSE, source = ANTAGONIST_SOURCE_ADMIN, do_equip = src.equip_antag, respect_mutual_exclusives = FALSE)
			else
				mind.wipe_antagonists()

		if(src.choose_name && !jobban_isbanned(new_mob, "Custom Names"))
			SPAWN(0)
				var/default = new_mob.real_name
				new_mob.choose_name(3, src.get_mob_name(), default)
		if (length(src.objective_text))
			if (src.antag_role)
				new /datum/objective/regular(src.objective_text, mind, mind.get_antagonist(src.antag_role))
			else
				new /datum/objective/crew/custom(src.objective_text, mind)
			SPAWN(0)
				tgui_alert(new_mob, "Your objective is: [src.objective_text]", "Objective", list("Ok"))

	ui_data()
		var/spawn_type = ""
		if (ismob(src.thing_to_spawn))
			spawn_type = "mob_ref"
		else if (src.thing_to_spawn == /mob/living/carbon/human/normal) //special case for a useful shortcut
			spawn_type = "random_human"
		else if (ispath(src.thing_to_spawn, /mob))
			spawn_type = "mob_type"
		else if (istext(src.thing_to_spawn))
			spawn_type = "job"

		var/loc_type = ""
		if (isturf(src.spawn_loc))
			loc_type = "turf_ref"
		else if (src.spawn_loc)
			loc_type = "landmark"

		var/is_a_mob = ispath(src.thing_to_spawn, /mob) || ismob(src.thing_to_spawn)
		var/is_a_human = ispath(src.thing_to_spawn, /mob/living/carbon/human) || ishuman(src.thing_to_spawn)
		//we want to display a warning if someone tries to apply an antag role to a non-human mob
		var/potentially_incompatible = is_a_mob && !is_a_human && src.antag_role
		//we want to display a warning if someone tries to spawn a job at a landmark it doesn't like (probably latejoin)
		var/job_wanted_location
		var/force_choose_name = FALSE
		if (spawn_type == "job")
			var/datum/job/chosen_job = find_job_in_controller_by_string(src.thing_to_spawn)
			force_choose_name = chosen_job.change_name_on_spawn //Job doesn't care, will give players the choice regardless
			if(force_choose_name)
				src.choose_name = TRUE
			if (chosen_job.special_spawn_location != src.spawn_loc)
				job_wanted_location = chosen_job.special_spawn_location

		return list(
			"ref" = ref(src),
			"thing_to_spawn" = (ispath(src.thing_to_spawn) || istext(src.thing_to_spawn)) ? src.thing_to_spawn : "\ref[src.thing_to_spawn]",
			"thing_name" = src.get_mob_name(),
			"spawn_directly" = src.spawn_directly,
			"spawn_loc" = src.spawn_loc,
			"amount_to_spawn" = src.amount_to_spawn,
			"antag_role" = src.antag_role,
			"objective_text" = src.objective_text,
			"spawn_type" = spawn_type,
			"loc_type" = loc_type,
			"job_wanted_location" = job_wanted_location,
			"incompatible_antag" = potentially_incompatible,
			"equip_antag" = src.equip_antag,
			"add_to_manifest" = src.add_to_manifest,
			"choose_name" = src.choose_name,
			"disable_choose_name" = force_choose_name,
		)

	ui_state(mob/user)
		return tgui_admin_state

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		switch (action)
			if ("select_mob")
				var/mob/selected = pick_ref(ui.user)
				if (istype(selected))
					src.thing_to_spawn = selected
				else
					boutput(ui.user, "That's not a mob, dingus.")
			if ("select_mob_type")
				src.thing_to_spawn = tgui_input_list(ui.user, "Select mob type", "Select type", concrete_typesof(/mob/living)) || src.thing_to_spawn
			if ("select_job")
				var/list/job_names = list()
				for (var/datum/job/job in (job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs))
					job_names |= job.name
				src.thing_to_spawn = tgui_input_list(ui.user, "Select job type", "Select type", job_names) || src.thing_to_spawn
			if ("set_random_human")
				src.thing_to_spawn = /mob/living/carbon/human/normal
			if ("select_turf")
				src.spawn_loc = get_turf(pick_ref(ui.user))
			if ("select_landmark")
				src.spawn_loc = tgui_input_list(ui.user, "Select landmark", "Select", landmarks) || src.spawn_loc
			if ("select_default_job_landmark")
				src.spawn_loc = find_job_in_controller_by_string(src.thing_to_spawn).special_spawn_location || src.spawn_loc
			if ("set_amount")
				src.amount_to_spawn = params["amount"]
				if (src.amount_to_spawn > 1)
					src.spawn_directly = FALSE
			if ("select_antag")
				var/antag_ids = list("generic_antagonist")
				for (var/datum/antagonist/antag as anything in concrete_typesof(/datum/antagonist))
					antag_ids |= initial(antag.id)
				src.antag_role = tgui_input_list(ui.user, "Select antagonist role", "Select role", antag_ids)
			if ("clear_antag")
				src.antag_role = null
			if ("set_equip")
				src.equip_antag = params["equip_antag"]
			if ("set_spawn_directly")
				src.spawn_directly = params["spawn_directly"]
			if ("set_objective_text")
				src.objective_text = params["objective_text"]
			if ("set_manifest")
				src.add_to_manifest = params["add_to_manifest"]
			if ("choose_name")
				src.choose_name = params["choose_name"]
		return TRUE

/datum/spawn_event_editor
	var/datum/spawn_event/spawn_event = new()
	///Set to true whenever player eligibility parameters change so we're not iterating global.minds every TGUI tick
	var/refresh_player_count = TRUE
	var/eligible_player_count = -1

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "SpawnEvent")
			ui.open()

	ui_data()
		var/list/role_data = list()
		for(var/datum/spawn_event_role/role in src.spawn_event.roles_to_spawn)
			role_data += list(role.ui_data())

		if (src.refresh_player_count)
			src.eligible_player_count = length(eligible_dead_player_list(TRUE, TRUE, src.spawn_event.contains_antag_role(), src.spawn_event.allow_dnr))
			src.refresh_player_count = FALSE

		return list(
			"roles" = role_data,
			"event_title" = src.spawn_event.title,
			"ghost_confirmation_delay" = src.spawn_event.ghost_confirmation_delay,
			"ask_permission" = src.spawn_event.ask_permission,
			"allow_dnr" = src.spawn_event.allow_dnr,
			"eligible_player_count" = src.eligible_player_count,
		)

	ui_static_data(mob/user)
		return list(
			"landmarks" = landmarks
		)

	ui_state(mob/user)
		return tgui_admin_state

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		// Forward the ui act to the role if its targeting a role and not to remove it
		var/datum/spawn_event_role/targeted_role = locate(params["role_ref"]) in src.spawn_event.roles_to_spawn
		if(!QDELETED(targeted_role) && istype(targeted_role) && (action != "remove_role"))
			return targeted_role.ui_act(action, params, ui, state)

		// Otherwise its targeting the event as a whole
		switch (action)
			if ("add_role")
				src.spawn_event.roles_to_spawn += new/datum/spawn_event_role()
			if ("remove_role")
				src.spawn_event.roles_to_spawn -= targeted_role
				qdel(targeted_role)
			if ("set_spawn_delay")
				src.spawn_event.ghost_confirmation_delay = params["spawn_delay"] //no validation, admins may href exploit if they wish
			if ("set_ask_permission")
				src.spawn_event.ask_permission = params["ask_permission"]
			if ("set_title")
				src.spawn_event.title = params["new_title"]
			if ("set_allow_dnr")
				src.refresh_player_count = TRUE
				src.spawn_event.allow_dnr = params["allow_dnr"]
			if ("spawn") //no accidental double clicks
				if (!ON_COOLDOWN(ui.user, "custom_spawn_event", 1 SECOND))
					var/role_names = list()
					for(var/datum/spawn_event_role/role in src.spawn_event.roles_to_spawn)
						role_names += "[role.amount_to_spawn] [role.antag_role] [role.get_mob_name()] "
					message_admins("[key_name(ui.user)] initiated a custom spawn event titled \"[src.spawn_event.title]\" of: [english_list(role_names)]")
					logTheThing(LOG_ADMIN, ui.user, "initiated a custom spawn event titled \"[src.spawn_event.title]\" of: [english_list(role_names)]")
					src.spawn_event.do_spawn()
			if ("refresh_player_count")
				src.refresh_player_count = TRUE
		return TRUE

/client/proc/cmd_custom_spawn_event()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Custom Ghost Spawn"
	set desc = "Set up a custom player spawn event."
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/datum/spawn_event_editor/E = new /datum/spawn_event_editor(src.mob)
	E.ui_interact(mob)
