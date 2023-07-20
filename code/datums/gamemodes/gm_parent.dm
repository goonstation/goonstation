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
	return 1

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
		command_alert("The shuttle has automatically been called for a shift change.  Please recall the shuttle to extend the shift.","Shift Shuttle Update")
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

// Did some streamlining here (Convair880).
/datum/game_mode/proc/declare_completion()
	var/list/datum/mind/antags = list()
	var/list/stuff_to_output = list()

	for (var/datum/mind/traitor in traitors)
		antags.Add(traitor)
	for (var/datum/mind/various in Agimmicks)
		antags.Add(various)

	for (var/datum/mind/traitor in antags)
		var/traitorwin = 1
		var/obj_count = 0
		var/traitor_name

		// This is a really hacky check to prevent traitors from being outputted twice if their primary antag role has an antagonist datum that could be used for data instead.
		// Once antagonist datums are completed, this check should be removed entirely.
		if (traitor.get_antagonist(traitor.special_role))
			continue

		if (traitor.current)
			traitor_name = "[traitor.current.real_name] (played by [traitor.displayed_key])"
		else
			traitor_name = "[traitor.displayed_key] (character destroyed)"

		if (traitor.special_role == ROLE_MINDHACK)
			stuff_to_output += "<B>[traitor_name]</B> was mindhacked!"
			continue // Objectives are irrelevant for mindhacks and thralls.
		else if (traitor.special_role == ROLE_VAMPTHRALL)
			stuff_to_output += "<B>[traitor_name]</B> was a vampire's thrall!"
			continue // Ditto.
		else if (traitor.special_role == ROLE_FLOCKTRACE)
			continue // Flocktraces are listed under their respective flockmind
		else
			if (traitor.late_special_role)
				stuff_to_output += "<B>[traitor_name]</B> was a late-joining [traitor.special_role]!"
			else if (traitor.random_event_special_role)
				stuff_to_output += "<B>[traitor_name]</B> was a random event [traitor.special_role]!"
			else
				stuff_to_output += "<B>[traitor_name]</B> was a [traitor.special_role]!"

			if (traitor.special_role == ROLE_SLASHER)
				var/foundmachete = FALSE
				for_by_tcl(M, /obj/item/slasher_machete)
					if(M.slasher_key == traitor.current.ckey)
						foundmachete = TRUE
						var/outputval = round((M.force - 15) / 2.5)
						stuff_to_output += "<B>Souls Stolen:</b> [outputval]"
						break
				if(!foundmachete)
					stuff_to_output += "<B>Souls Stolen:</b> They did not finish with a machete!"

			for (var/datum/objective/objective in traitor.objectives)
#ifdef CREW_OBJECTIVES
				if (istype(objective, /datum/objective/crew)) continue
#endif
				obj_count++
				if (objective.check_completion())
					stuff_to_output += "Objective #[obj_count]: [objective.explanation_text] <span class='success'><B>Success</B></span>"
					logTheThing(LOG_DIARY, traitor, "completed objective: [objective.explanation_text]")
					if (!isnull(objective.medal_name) && !isnull(traitor.current))
						traitor.current.unlock_medal(objective.medal_name, objective.medal_announce)
				else
					stuff_to_output += "Objective #[obj_count]: [objective.explanation_text] <span class='alert'>Failed</span>"
					logTheThing(LOG_DIARY, traitor, "failed objective: [objective.explanation_text]. Womp womp.")
					traitorwin = 0

		// Please use objective.medal_name for medals that are tied to a specific objective instead of adding them here.
		if (obj_count)
			if (traitorwin)
				if (traitor.current)
					traitor.current.unlock_medal("MISSION COMPLETE", 1)
				stuff_to_output += "<span class='success'>The [traitor.special_role] was successful!</span><br>"
			else
				stuff_to_output += "<span class='alert'>The [traitor.special_role] has failed!</span><br>"

	#ifdef DATALOGGER
			if (traitorwin)
				game_stats.Increment("traitorwin")
			else
				game_stats.Increment("traitorloss")
	#endif


	// Their antag status is revoked on death/implant removal/expiration, but we still want them to show up in the game over stats (Convair880).
	for (var/datum/mind/traitor in former_antagonists)
		var/traitor_name

		if (traitor.current)
			traitor_name = "[traitor.current.real_name] (played by [traitor.displayed_key])"
		else
			traitor_name = "[traitor.displayed_key] (character destroyed)"

		if (traitor.former_antagonist_roles.len)
			for (var/string in traitor.former_antagonist_roles)
				if (string == ROLE_MINDHACK)
					stuff_to_output += "<B>[traitor_name] was mindhacked!</B>"
				else if (string == ROLE_VAMPTHRALL)
					stuff_to_output += "<B>[traitor_name] was a vampire's thrall!</B>"
				else
					stuff_to_output += "<B>[traitor_name] was a [string]!</B>"

	// Display all antagonist datums.
	for (var/datum/antagonist/antagonist_role as anything in get_all_antagonists())
		#ifdef DATA_LOGGER
		game_stats.Increment(antagonist_role.check_completion() ? "traitorwin" : "traitorloss")
		#endif
		var/antag_dat = antagonist_role.handle_round_end(TRUE)
		if (antagonist_role.display_at_round_end && length(antag_dat))
			stuff_to_output.Add(antag_dat)

	boutput(world, stuff_to_output.Join("<br>"))

	return 1

/**
  * Get a list of viable candidates for an antagonist type and expected number of antagonists, taking antagonist preferences into account if possible.
  *
  * Arguments:
  * * type - requested antagonist type.
  * * number - requested number of antagonists. If it can't find that many it will try to look again, but ignoring antagonist preferences.
  */
/datum/game_mode/proc/get_possible_enemies(type,number)
	var/list/candidates = list()
	/// Used to fill in the quota if we can't find enough players with the antag preference on.
	var/list/unpicked_candidate_minds = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue
		if (jobban_isbanned(player, "Syndicate")) continue //antag banned

		if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !(player.mind in candidates))
			if (player.client.preferences.vars[get_preference_for_role(type)])
				candidates += player.mind
			else // eligible but has the preference off, keeping in mind in case we don't find enough candidates with it on to fill the gap
				unpicked_candidate_minds.Add(player.mind)

	logTheThing(LOG_DEBUG, null, "Picking [number] possible antagonists of type [type], \
									found [length(candidates)] players out of [length(candidates) + length(unpicked_candidate_minds)] who had that antag enabled.")

	if(length(candidates) < number) // ran out of eligible players with the preference on, filling the gap with other players
		logTheThing(LOG_DEBUG, null, "<b>Enemy Assignment</b>: Only [length(candidates)] players with be_[type] set to yes were ready. We need [number] so including players who don't want to be [type]s in the pool.")

		if(length(unpicked_candidate_minds))
			shuffle_list(unpicked_candidate_minds)
			var/iteration = 1
			while(length(candidates) < number)
				candidates += unpicked_candidate_minds[iteration]
				iteration++
				if (iteration > length(unpicked_candidate_minds)) // ran out of eligible clients
					break

	if(length(candidates) < number) // somehow failed to meet our candidate amount quota
		message_admins("<span class='alert'><b>WARNING:</b> get_possible_enemies was asked for more antagonists ([number]) than it could find candidates ([length(candidates)]) for. This could be a freak accident or an error in the code requesting more antagonists than possible. The round may have an irregular number of antagonists of type [type].")
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

	var/upperbound = 3
	if (allow_hijack)
		upperbound = 4

	var/objective_path = null
	var/picker = rand(1,upperbound)
	switch(picker)
		if(1)
			objective_path = /datum/objective/escape
		if(2)
			objective_path = /datum/objective/escape/survive
		if(3)
			objective_path = /datum/objective/escape/kamikaze
		if(4)
			objective_path = /datum/objective/escape/hijack

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
