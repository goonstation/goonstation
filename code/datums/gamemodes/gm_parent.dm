ABSTRACT_TYPE(/datum/game_mode)
/datum/game_mode
	var/name = "invalid" // Don't implement ticker.mode.name or .config_tag checks again, okay? I've had to swap them all to get game mode children to work.
	var/config_tag = null // Use istype(ticker.mode, /datum/game_mode/whatever) when checking instead, but this must be set in new game mode
	var/votable = 1
	var/regular = TRUE
	var/probability = 0 // Overridden by the server config. If you don't have access to that repo, keep it 0.
	var/crew_shortage_enabled = 1

	var/shuttle_available = 1 // 0: Won't dock. | 1: Normal. | 2: Won't dock if called too early.
	var/shuttle_available_threshold = 12000 // 20 min. Only works when shuttle_available == SHUTTLE_AVAILABLE_DELAY.
	var/shuttle_auto_call_time = 90 MINUTES // 120 minutes.  Shuttle auto-called at this time and then again at this time + 1/2 this time, then every 1/2 this time after that. Set to 0 to disable.
	var/shuttle_last_auto_call = 0
	var/shuttle_initial_auto_call_done = 0 // set to 1 after first call so we know to start checking shuttle_auto_call_time/2
	var/shuttle_prevent_recall_time = 120 MINUTES // After how long do we prevent recalling the Shuttle (only applied upon an automatic call)

	var/latejoin_antag_compatible = 0 // Ultimately depends on the global 'late_traitors' setting, though.
	var/latejoin_only_if_all_antags_dead = 0 // Don't spawn 'em until all antagonists are dead.
	var/list/latejoin_antag_roles = list() // Unrecognized roles default to traitor in mob/new_player/proc/makebad().

	var/list/datum/mind/traitors = list() // enemies assigned at round start
	var/list/datum/mind/token_players = list() //players redeeming an antag token
	var/list/datum/mind/Agimmicks = list() // admin assigned and certain gimmick enemies
	var/list/datum/mind/former_antagonists = list() // For mindhacks and rogue cyborgs we'd want to show in the game over stats (Convair880).

	var/datum/game_mode/spy_theft/spy_market = 0	//In case any spies are spawned into a round that is NOT spy_theft, we need a place to hold their spy market.

	var/antag_token_support = FALSE // players can redeem antag tokens for this game mode
	var/do_antag_random_spawns = 1
	var/do_random_events = 1
	var/escape_possible = 1		//for determining if players lose their held spacebux item on round end if they are able to "escape" in this mode.

/datum/game_mode/proc/announce()
	boutput(world, "<B>[src] did not define announce()</B>")

/datum/game_mode/proc/pre_setup()
	if (global.ticker.roundstart_player_count(FALSE) < 20)
		return FALSE
	return TRUE

/datum/game_mode/proc/post_setup()

// yes. fucking manufacturers
// Fuck.
// F U C K
/datum/game_mode/proc/post_post_setup()
	return

/datum/game_mode/proc/process()
	if (spy_market)
		spy_market.process()
	#ifndef NO_SHUTTLE_CALLS
	if (shuttle_available && shuttle_auto_call_time)
		process_auto_shuttle_call()
	#endif

/datum/game_mode/proc/process_auto_shuttle_call()
	if (emergency_shuttle.online && emergency_shuttle.direction == 1)
		return
	if (shuttle_last_auto_call + (shuttle_initial_auto_call_done ? shuttle_auto_call_time / 2 : shuttle_auto_call_time) <= ticker.round_elapsed_ticks)
		emergency_shuttle.incall()
		var/announcement = "The shuttle has automatically been called for a shift change."
		if(shuttle_prevent_recall_time <= ticker.round_elapsed_ticks)
			emergency_shuttle.can_recall = FALSE
			logTheThing(LOG_STATION, null, "Automatically disabled recalling of the Energency Shuttle.")
			announcement += " Central Command has prohibited further recalls."
		else
			announcement += " Please recall the shuttle to extend the shift."
		command_alert(announcement,"Shift Shuttle Update")
		shuttle_last_auto_call = ticker.round_elapsed_ticks
		if (!shuttle_initial_auto_call_done)
			shuttle_initial_auto_call_done = 1

/datum/game_mode/proc/check_finished()
	if(emergency_shuttle.location == SHUTTLE_LOC_RETURNED)
		return 1
	return 0

///An optional message to indicate who won the round
/datum/game_mode/proc/victory_msg()
	return ""

///Headline of the victory message
/datum/game_mode/proc/victory_headline()
	return ""

///Body of the victory message
/datum/game_mode/proc/victory_body()
	return ""


// Did some streamlining here (Convair880).
/datum/game_mode/proc/declare_completion()
	var/list/stuff_to_output = list()

	for (var/datum/antagonist/traitor in get_all_antagonists())
		var/obj_count = 0
		var/traitor_name
		var/datum/mind/criminal_mind = traitor.owner

		if (criminal_mind.current)
			traitor_name = "[criminal_mind.current.real_name] (played by [criminal_mind.displayed_key])"
		else
			traitor_name = "[criminal_mind.displayed_key] (character destroyed)"

		switch(traitor.id)
			if(ROLE_MINDHACK)
				stuff_to_output += "<B>[traitor_name]</B> was mindhacked!"
				continue // Objectives are irrelevant for mindhacks and thralls.
			if(ROLE_VAMPTHRALL)
				stuff_to_output += "<B>[traitor_name]</B> was a vampire's thrall!"
				continue // Ditto.
			if(ROLE_FLOCKTRACE)
				continue // Flocktraces are listed under their respective flockmind

		switch(traitor.assigned_by)
			if (ANTAGONIST_SOURCE_LATE_JOIN)
				stuff_to_output += "<B>[traitor_name]</B> was a late-joining [traitor.display_name]!"
			if (ANTAGONIST_SOURCE_RANDOM_EVENT)
				stuff_to_output += "<B>[traitor_name]</B> was a random event [traitor.display_name]!"
			else
				stuff_to_output += "<B>[traitor_name]</B> was a [traitor.display_name]!"

		if (traitor.id == ROLE_SLASHER)
			var/foundmachete = FALSE
			for_by_tcl(M, /obj/item/slasher_machete)
				if(M.slasher_key == criminal_mind.current.ckey)
					foundmachete = TRUE
					var/outputval = round((M.force - 15) / 2.5)
					stuff_to_output += "<B>Souls Stolen:</b> [outputval]"
					break
			if(!foundmachete)
				stuff_to_output += "<B>Souls Stolen:</b> They did not finish with a machete!"

		for (var/datum/objective/objective in traitor.objectives)
			obj_count++
			if (objective.check_completion())
				stuff_to_output += "Objective #[obj_count]: [objective.explanation_text] [SPAN_SUCCESS("<B>Success</B>")]"
				logTheThing(LOG_DIARY, criminal_mind, "completed objective: [objective.explanation_text]")
				if (!isnull(objective.medal_name) && !isnull(criminal_mind.current))
					criminal_mind.current.unlock_medal(objective.medal_name, objective.medal_announce)
			else
				stuff_to_output += "Objective #[obj_count]: [objective.explanation_text] [SPAN_ALERT("Failed")]"
				logTheThing(LOG_DIARY, criminal_mind, "failed objective: [objective.explanation_text]. Womp womp.")

		// Please use objective.medal_name for medals that are tied to a specific objective instead of adding them here.
		if (obj_count)
			if (traitor.check_success())
				stuff_to_output += "[SPAN_SUCCESS("The [traitor.display_name] was successful!")]<br>"
			else
				stuff_to_output += "[SPAN_ALERT("The [traitor.display_name] has failed!")]<br>"

	#ifdef DATALOGGER
		game_stats.Increment(traitor.check_success() ? "traitorwin" : "traitorloss")
	#endif

		traitor.handle_round_end(TRUE)

	boutput(world, stuff_to_output.Join("<br>"))

	return 1

/**
  * Get a list of viable candidates for an antagonist type and expected number of antagonists, taking antagonist preferences into account if possible.
  *
  * Arguments:
  * * type - requested antagonist type.
  * * number - requested number of antagonists. If it can't find that many it will try to look again, but ignoring antagonist preferences.
	* * allow_carbon - if this proc is ran mid-round this allows for /mob/living/carbon to be included in the list of candidates. (normally only new_player)
	* * filter_proc - a proc that takes a mob and returns TRUE if it should be included in the list of candidates.
	* * force_fill - if true, if not enough players have the role selectied, randomly select from all other players as well
  */
/datum/game_mode/proc/get_possible_enemies(type, number, allow_carbon=FALSE, filter_proc=null, force_fill = TRUE)
	var/list/candidates = list()
	/// Used to fill in the quota if we can't find enough players with the antag preference on.
	var/list/unpicked_candidate_minds = list()

	for(var/client/C)
		if (istype(C.mob, /mob/new_player))
			var/mob/new_player/new_player = C.mob
			if (!new_player.ready)
				continue
		else if(istype(C.mob, /mob/living/carbon))
			if(!allow_carbon)
				continue
			var/datum/job/job = find_job_in_controller_by_string(C.mob.job)
			if (job)
				if(!job.allow_traitors)
					continue
				if (!job.can_join_gangs && (type == ROLE_GANG_LEADER || type == ROLE_GANG_MEMBER))
					continue
		else
			continue
		if(filter_proc && !call(filter_proc)(C.mob))
			continue
		var/datum/mind/mind = C.mob.mind
		if (jobban_isbanned(C.mob, "Syndicate")) continue //antag banned

		if (!(mind in traitors) && !(mind in token_players) && !(mind in candidates))
			if (C.preferences.vars[get_preference_for_role(type)])
				candidates += mind
			else // eligible but has the preference off, keeping in mind in case we don't find enough candidates with it on to fill the gap
				unpicked_candidate_minds.Add(mind)

	logTheThing(LOG_DEBUG, null, "Picking [number] possible antagonists of type [type], \
									found [length(candidates)] players out of [length(candidates) + length(unpicked_candidate_minds)] who had that antag enabled.")

	if(length(candidates) < number && force_fill) // ran out of eligible players with the preference on, filling the gap with other players
		logTheThing(LOG_DEBUG, null, "<b>Enemy Assignment</b>: Only [length(candidates)] players with be_[type] set to yes were ready. We need [number] so including players who don't want to be [type]s in the pool.")

		if(length(unpicked_candidate_minds))
			shuffle_list(unpicked_candidate_minds)
			var/iteration = 1
			while(length(candidates) < number)
				candidates += unpicked_candidate_minds[iteration]
				iteration++
				if (iteration > length(unpicked_candidate_minds)) // ran out of eligible clients
					break

	if(length(candidates) < number && force_fill) // somehow failed to meet our candidate amount quota
		message_admins(SPAN_ALERT("<b>WARNING:</b> get_possible_enemies was asked for more antagonists ([number]) than it could find candidates ([length(candidates)]) for. This could be a freak accident or an error in the code requesting more antagonists than possible. The round may have an irregular number of antagonists of type [type]."))
		logTheThing(LOG_DEBUG, null, "<b>WARNING:</b> get_possible_enemies was asked for more antagonists ([number]) than it could find candidates ([length(candidates)]) for. This could be a freak accident or an error in the code requesting more antagonists than possible. The round may have an irregular number of antagonists of type [type].")

	if(length(candidates) < 1)
		return list()
	else
		return candidates

/// Set up an antag with default equipment, objectives etc as they would be in mixed
/// Should only be used for roundstart setup
/datum/game_mode/proc/equip_antag(datum/mind/antag)
	if (antag.assigned_role == "Chaplain" && antag.special_role == ROLE_VAMPIRE)
		// vamp will burn in the chapel before he can react
		if (prob(50))
			antag.special_role = ROLE_TRAITOR
		else
			antag.special_role = ROLE_CHANGELING

	antag.add_antagonist(antag.special_role, source = ANTAGONIST_SOURCE_ROUND_START)

	var/datum/antagonist/antag_datum = antag.get_antagonist(antag.special_role)
	if (!antag_datum.uses_pref_name)
		var/datum/player/player = antag.get_player()
		player.joined_names = list()
		antag.current.bioHolder.mobAppearance.flavor_text = null

/datum/game_mode/proc/check_win()

/datum/game_mode/proc/send_intercept(badguy_list)
	var/intercepttext = "Cent. Com. Update Requested status information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "vampire", "flock", ROLE_CHANGELING)
	for(var/i = 1 to pick(2, 3))
		possible_modes.Remove(pick(possible_modes))

	var/datum/intercept_text/i_text = new /datum/intercept_text

	for(var/g_mode in possible_modes)
		intercepttext += i_text.build(g_mode, pick((islist(badguy_list) && length(badguy_list)) ? badguy_list : ticker.minds))

	for_by_tcl(C, /obj/machinery/communications_dish)
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")

/datum/game_mode/proc/roundstart_player_count(loud = TRUE)
	return global.ticker.roundstart_player_count(loud)

////////////////////////////
// Objective related code //
////////////////////////////

//what do we do when a mob dies
/datum/game_mode/proc/on_human_death(var/mob/M)

/datum/game_mode/proc/bestow_objective(var/datum/mind/traitor, var/objective_path, var/datum/antagonist/antag_role)
	if (!istype(traitor) || !ispath(objective_path))
		return null

	var/datum/objective/O = new objective_path(null, traitor, antag_role)

	return O

/datum/game_mode/proc/bestow_random_escape_objective(var/datum/mind/traitor,var/allow_hijack = 0)
	if (!istype(traitor) || !isnum(allow_hijack))
		return null

	var/objective_path = null
	var/picker = rand(1,3)
	switch(picker)
		if(1)
			objective_path = /datum/objective/escape
		if(2)
			objective_path = /datum/objective/escape/survive
		if(3)
			objective_path = /datum/objective/escape/kamikaze


	var/datum/objective/O = new objective_path(null, traitor)

	return O


////////////////////////////////
// Special Antag related code //
////////////////////////////////

/datum/game_mode/proc/add_wraith(var/num_wraiths) // This simplifies adding a wraith during round setup as a single proc
	var/list/possible_wraiths = get_possible_enemies(ROLE_WRAITH, num_wraiths)
	var/list/chosen_wraiths = antagWeighter.choose(pool = possible_wraiths, role = ROLE_WRAITH, amount = num_wraiths, recordChosen = 1)
	for (var/datum/mind/wraith in chosen_wraiths)
		traitors += wraith
		wraith.special_role = ROLE_WRAITH
		possible_wraiths.Remove(wraith)

/datum/game_mode/proc/add_token_wraith(var/token_wraith) // Handles adding a token wraith
	token_wraith = 1 // only allow 1 wraith to spawn
	var/datum/mind/twraith = pick(token_players) //Randomly pick from the token list so the first person to ready up doesn't always get it.
	traitors += twraith
	token_players.Remove(twraith)
	twraith.special_role = ROLE_WRAITH


/proc/build_valid_game_modes()
	. = list()
	for (var/M in config.modes)
		. += M
	global.valid_modes += .
