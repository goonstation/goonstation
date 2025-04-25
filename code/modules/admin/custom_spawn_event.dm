//this is for the admin Custom Ghost Spawn verb, which has nothing to do with the random event system because it sucks
/datum/spawn_event
	var/thing_to_spawn = null
	///If true, only a single ghost will be spawned and placed directly into the mob
	var/spawn_directly = FALSE
	///A custom location to spawn the mobs (can also be a landmark string)
	var/turf/spawn_loc = LANDMARK_LATEJOIN
	///How long does the popup stay up for?
	var/ghost_confirmation_delay = 30 SECONDS
	///Do we give them a popup or just spawn them directly?
	var/ask_permission = TRUE
	///How many copies of thing_to_spawn do we want?
	var/amount_to_spawn = 1
	///Antag role ID to assign to the players on spawn
	var/antag_role = null
	///Custom objective text to display to players on spawn
	var/objective_text = ""
	///Should antag datums give their default equipment (replaces whatever is currently equipped in those slots)
	var/equip_antag = TRUE
	///Include DNR ghosts
	var/allow_dnr = FALSE
	///Should these newly spawned players show up on the manifest?
	var/add_to_manifest = FALSE

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
			SPAWN(0)
				M.JobEquipSpawned(src.thing_to_spawn)
			return M

	proc/do_spawn()
		if (src.spawn_directly)
			src.amount_to_spawn = 1
		var/mob_name = src.get_mob_name()
		var/antag_name = ""
		if (src.antag_role)
			for (var/datum/antagonist/antag as anything in concrete_typesof(/datum/antagonist))
				if (initial(antag.id) == src.antag_role)
					antag_name = initial(antag.display_name)
					break
		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as [src.amount_to_spawn > 1 ? "part of a group of" : "a"] [antag_name] [mob_name][src.amount_to_spawn > 1 ? "s" : ""]?")
		text_messages.Add("You are eligible to be respawned as a [antag_name] [mob_name]. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of respawns. Please wait...")

		if (src.ask_permission)
			message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		var/list/datum/mind/candidates = dead_player_list(TRUE, src.ghost_confirmation_delay, text_messages,
			allow_dead_antags = TRUE,
			require_client = TRUE,
			do_popup = src.ask_permission,
			for_antag = !!src.antag_role,
			allow_dnr = src.allow_dnr
		)

		if (!length(candidates))
			message_admins("No ghosts responded to spawn event: [src.get_mob_name()]")
			return

		for (var/i in 1 to src.amount_to_spawn)
			if (!length(candidates))
				break
			var/datum/mind/mind = pick(candidates)
			candidates -= mind
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
				new_mob.mind.assigned_role = src.thing_to_spawn
				if (src.add_to_manifest)
					var/obj/item/device/pda2/pda = locate() in new_mob
					global.data_core.addManifest(new_mob, "", "", pda?.net_id, "")

			SPAWN(1) //job equip procs have to be SPAWN(0) so this has to be SPAWN(1) for them to get an uplink, yes I know but mob init order is cursed and evil
				if (src.antag_role == "generic_antagonist")
					mind.add_generic_antagonist("generic_antagonist", new_mob.real_name, do_equip = src.equip_antag, do_objectives = FALSE, do_relocate = FALSE, source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE)
				else if (src.antag_role)
					if (mind.get_antagonist(src.antag_role))
						mind.remove_antagonist(src.antag_role, ANTAGONIST_REMOVAL_SOURCE_OVERRIDE)
					mind.add_antagonist(src.antag_role, do_relocate = FALSE, do_objectives = FALSE, source = ANTAGONIST_SOURCE_ADMIN, do_equip = src.equip_antag, respect_mutual_exclusives = FALSE)
				else
					mind.wipe_antagonists()

			if (length(src.objective_text))
				if (src.antag_role)
					new /datum/objective/regular(src.objective_text, mind, mind.get_antagonist(src.antag_role))
				else
					new /datum/objective/crew/custom(src.objective_text, mind)
				SPAWN(0)
					tgui_alert(new_mob, "Your objective is: [src.objective_text]", "Objective", list("Ok"))

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
		var/spawn_type = ""
		if (ismob(src.spawn_event.thing_to_spawn))
			spawn_type = "mob_ref"
		else if (src.spawn_event.thing_to_spawn == /mob/living/carbon/human/normal) //special case for a useful shortcut
			spawn_type = "random_human"
		else if (ispath(src.spawn_event.thing_to_spawn, /mob))
			spawn_type = "mob_type"
		else if (istext(src.spawn_event.thing_to_spawn))
			spawn_type = "job"

		var/loc_type = ""
		if (isturf(src.spawn_event.spawn_loc))
			loc_type = "turf_ref"
		else if (src.spawn_event.spawn_loc)
			loc_type = "landmark"

		var/is_a_mob = ispath(src.spawn_event.thing_to_spawn, /mob) || ismob(src.spawn_event.thing_to_spawn)
		var/is_a_human = ispath(src.spawn_event.thing_to_spawn, /mob/living/carbon/human) || ishuman(src.spawn_event.thing_to_spawn)
		//we want to display a warning if someone tries to apply an antag role to a non-human mob
		var/potentially_incompatible = is_a_mob && !is_a_human && src.spawn_event.antag_role

		if (src.refresh_player_count)
			src.eligible_player_count = length(eligible_dead_player_list(TRUE, TRUE, !!src.spawn_event.antag_role, src.spawn_event.allow_dnr))
			src.refresh_player_count = FALSE

		return list(
			"thing_to_spawn" = (ispath(src.spawn_event.thing_to_spawn) || istext(src.spawn_event.thing_to_spawn)) ? src.spawn_event.thing_to_spawn : "\ref[src.spawn_event.thing_to_spawn]",
			"thing_name" = src.spawn_event.get_mob_name(),
			"spawn_directly" = src.spawn_event.spawn_directly,
			"spawn_loc" = src.spawn_event.spawn_loc,
			"ghost_confirmation_delay" = src.spawn_event.ghost_confirmation_delay,
			"amount_to_spawn" = src.spawn_event.amount_to_spawn,
			"antag_role" = src.spawn_event.antag_role,
			"objective_text" = src.spawn_event.objective_text,
			"spawn_type" = spawn_type,
			"loc_type" = loc_type,
			"incompatible_antag" = potentially_incompatible,
			"equip_antag" = src.spawn_event.equip_antag,
			"ask_permission" = src.spawn_event.ask_permission,
			"allow_dnr" = src.spawn_event.allow_dnr,
			"eligible_player_count" = src.eligible_player_count,
			"add_to_manifest" = src.spawn_event.add_to_manifest,
		)

	ui_static_data(mob/user)
		return list(
			"landmarks" = landmarks
		)

	ui_state(mob/user)
		return tgui_admin_state

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		switch (action)
			if ("select_mob")
				var/mob/selected = pick_ref(ui.user)
				if (istype(selected))
					src.spawn_event.thing_to_spawn = selected
				else
					boutput(ui.user, "That's not a mob, dingus.")
			if ("select_mob_type")
				src.spawn_event.thing_to_spawn = tgui_input_list(ui.user, "Select mob type", "Select type", concrete_typesof(/mob/living)) || src.spawn_event.thing_to_spawn
			if ("select_job")
				var/list/job_names = list()
				for (var/datum/job/job in (job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs))
					job_names |= job.name
				src.spawn_event.thing_to_spawn = tgui_input_list(ui.user, "Select job type", "Select type", job_names) || src.spawn_event.thing_to_spawn
			if ("set_random_human")
				src.spawn_event.thing_to_spawn = /mob/living/carbon/human/normal
			if ("select_turf")
				src.spawn_event.spawn_loc = get_turf(pick_ref(ui.user))
			if ("select_landmark")
				src.spawn_event.spawn_loc = tgui_input_list(ui.user, "Select landmark", "Select", landmarks) || src.spawn_event.spawn_loc
			if ("set_spawn_delay")
				src.spawn_event.ghost_confirmation_delay = params["spawn_delay"] //no validation, admins may href exploit if they wish
			if ("set_amount")
				src.spawn_event.amount_to_spawn = params["amount"]
				if (src.spawn_event.amount_to_spawn > 1)
					src.spawn_event.spawn_directly = FALSE
			if ("select_antag")
				var/antag_ids = list("generic_antagonist")
				for (var/datum/antagonist/antag as anything in concrete_typesof(/datum/antagonist))
					antag_ids |= initial(antag.id)
				src.spawn_event.antag_role = tgui_input_list(ui.user, "Select antagonist role", "Select role", antag_ids)
				src.refresh_player_count = TRUE //need to include or exclude antag banned players
			if ("clear_antag")
				src.spawn_event.antag_role = null
				src.refresh_player_count = TRUE
			if ("set_equip")
				src.spawn_event.equip_antag = params["equip_antag"]
			if ("set_spawn_directly")
				src.spawn_event.spawn_directly = params["spawn_directly"]
			if ("set_objective_text")
				src.spawn_event.objective_text = params["objective_text"]
			if ("set_ask_permission")
				src.spawn_event.ask_permission = params["ask_permission"]
			if ("set_allow_dnr")
				src.refresh_player_count = TRUE
				src.spawn_event.allow_dnr = params["allow_dnr"]
			if ("spawn") //no accidental double clicks
				if (!ON_COOLDOWN(ui.user, "custom_spawn_event", 1 SECOND))
					message_admins("[key_name(ui.user)] initiated a custom spawn event of [src.spawn_event.amount_to_spawn] [src.spawn_event.get_mob_name()] [src.spawn_event.antag_role]")
					logTheThing(LOG_ADMIN, ui.user, "initiated a custom spawn event of [src.spawn_event.amount_to_spawn] [src.spawn_event.get_mob_name()] [src.spawn_event.antag_role]")
					src.spawn_event.do_spawn()
			if ("refresh_player_count")
				src.refresh_player_count = TRUE
			if ("set_manifest")
				src.spawn_event.add_to_manifest = params["add_to_manifest"]
		return TRUE

/client/proc/cmd_custom_spawn_event()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Custom Ghost Spawn"
	set desc = "Set up a custom player spawn event."
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/datum/spawn_event_editor/E = new /datum/spawn_event_editor(src.mob)
	E.ui_interact(mob)
