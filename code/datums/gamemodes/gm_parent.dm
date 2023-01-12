/datum/game_mode
	var/name = "invalid" // Don't implement ticker.mode.name or .config_tag checks again, okay? I've had to swap them all to get game mode children to work.
	var/config_tag = null // Use istype(ticker.mode, /datum/game_mode/whatever) when checking instead, but this must be set in new game mode
	var/votable = 1
	var/probability = 0 // Overridden by the server config. If you don't have access to that repo, keep it 0.
	var/crew_shortage_enabled = 1

	var/shuttle_available = 1 // 0: Won't dock. | 1: Normal. | 2: Won't dock if called too early.
	var/shuttle_available_threshold = 12000 // 20 min. Only works when shuttle_available == 2.
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
	if (shuttle_available && shuttle_auto_call_time)
		process_auto_shuttle_call()

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
		try
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

				if (traitor.special_role == ROLE_CHANGELING && traitor.current)
					var/dna_absorbed = 0
					var/absorbed_identities = null
					var/datum/abilityHolder/changeling/C = traitor.current.get_ability_holder(/datum/abilityHolder/changeling)
					if (C && istype(C))
						absorbed_identities = list()
						dna_absorbed = max(0, C.absorbtions)
						for (var/DNA in C.absorbed_dna)
							absorbed_identities += DNA
					else
						dna_absorbed = "N/A (body destroyed)"

					stuff_to_output += "<B>Absorbed DNA:</b> [dna_absorbed]"
					stuff_to_output += "<B>Absorbed Identities: [isnull(absorbed_identities) ? "N/A (body destroyed)" : english_list(absorbed_identities)]"

				if (traitor.special_role == ROLE_VAMPIRE && traitor.current)
					var/blood_acquired = 0
					if (isvampire(traitor.current))
						blood_acquired = traitor.current.get_vampire_blood(1)
					else
						blood_acquired = "N/A (body destroyed)"
					stuff_to_output += "<B>Blood acquired:</b>  [blood_acquired][isnum(blood_acquired) ? " units" : ""]"

				if (traitor.special_role == ROLE_WEREWOLF)
					// Werewolves may not have the feed objective, so we don't want to make this output universal.
					for (var/datum/objective/specialist/werewolf/feed/O in traitor.objectives)
						if (O && istype(O, /datum/objective/specialist/werewolf/feed/))
							stuff_to_output += "<B>No. of victims:</b> [O.mobs_fed_on.len]"

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

				if (traitor.special_role == ROLE_HUNTER)
					// Same reasoning here, really.
					for (var/datum/objective/specialist/hunter/trophy/T in traitor.objectives)
						if (traitor.current && T && istype(T, /datum/objective/specialist/hunter/trophy))
							var/S = traitor.current.get_skull_value()
							stuff_to_output += "<B>Combined trophy value:</b> [S]"

				if (traitor.special_role == ROLE_BLOB)
					var/victims = length(traitor.blob_absorb_victims)
					stuff_to_output += "\ [victims <= 0 ? "Not a single person was" : "[victims] lifeform[s_es(victims)] were"] absorbed by them  <span class='success'>Players in Green</span>"
					if (victims)
						var/absorbed_announce = "They absorbed: "
						for (var/mob/living/carbon/human/AV in traitor.blob_absorb_victims)
							if(!AV || !AV.last_client || !AV.last_client.key)
								absorbed_announce += "[AV:real_name](NPC), "
							else
								absorbed_announce += "<span class='success'>[AV:real_name]([AV:last_client:key])</span>, "
						stuff_to_output += absorbed_announce

				if (traitor.special_role == ROLE_SPY_THIEF)
					var/purchases = length(traitor.purchased_traitor_items)
					var/stolen = length(traitor.spy_stolen_items)
					stuff_to_output += "They stole [stolen <= 0 ? "nothing" : "[stolen] items"]!"
					if (purchases)
						var/stolen_detail = "Items Thieved: "
						for (var/i in traitor.spy_stolen_items)
							stolen_detail += "[i], "
						var/rewarded_detail = "They Were Rewarded: "
						for (var/i in traitor.purchased_traitor_items)
							rewarded_detail += "[bicon(i:item)] [i:name], "
						rewarded_detail = copytext(rewarded_detail, 1, -2)
						stuff_to_output += stolen_detail
						stuff_to_output += rewarded_detail
						if (stolen >= 7)
							traitor.current?.unlock_medal("Professional thief", TRUE)

				if (traitor.special_role == ROLE_FLOCKMIND)
					for (var/flockname in flocks)
						var/datum/flock/flock = flocks[flockname]
						if (flock.flockmind_mind == traitor)
							stuff_to_output += "Peak total compute value reached: [flock.stats.peak_compute]"
							if(length(flock.trace_minds))
								stuff_to_output += "Flocktraces:"
								for (var/trace_name in flock.trace_minds)
									var/datum/mind/trace_mind = flock.trace_minds[trace_name]
									//the first character in this string is an invisible brail character, because otherwise DM eats my indentation
									stuff_to_output += "<b>⠀   [trace_name] (played by [trace_mind.displayed_key])<b>"

							if (flock.relay_finished)
								flock.flockmind_mind.current.unlock_medal("To the stars", TRUE)
								var/time = TIME
								for (var/mob/living/intangible/flock/trace/flocktrace as anything in flock.traces)
									if (time - flocktrace.creation_time >= 5 MINUTES)
										if (!istype(flocktrace.loc, /mob/living/critter/flock/drone))
											flocktrace.unlock_medal("To the stars", TRUE)
										else
											var/mob/living/critter/flock/drone/flockdrone = flocktrace.loc
											flockdrone.unlock_medal("To the stars", TRUE)

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
					if (traitor.special_role == ROLE_WIZARD && traitor.current)
						traitor.current.unlock_medal("You're no Elminster!", 1)
					if (traitor.special_role == ROLE_WRESTLER && traitor.current)
						traitor.current.unlock_medal("Cream of the Crop", 1)
					stuff_to_output += "<span class='success'>The [traitor.special_role] was successful!</span><br>"
				else
					stuff_to_output += "<span class='alert'>The [traitor.special_role] has failed!</span><br>"

	#ifdef DATALOGGER
			if (traitorwin)
				game_stats.Increment("traitorwin")
			else
				game_stats.Increment("traitorloss")
	#endif
		catch(var/exception/e)
			logTheThing(LOG_DEBUG, null, "Kyle|antag-runtime: [e.file]:[e.line] - [e.name] - [e.desc]")


	// Their antag status is revoked on death/implant removal/expiration, but we still want them to show up in the game over stats (Convair880).
	for (var/datum/mind/traitor in former_antagonists)
		try
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
		catch(var/exception/e)
			logTheThing(LOG_DEBUG, null, "kyle|former-antag-runtime: [e.file]:[e.line] - [e.name] - [e.desc]")

	// Display all antagonist datums. We arrange them like this so that each antagonist is bundled together by type
	for (var/V in concrete_typesof(/datum/antagonist))
		var/datum/antagonist/dummy = V
		for (var/datum/antagonist/A as anything in get_all_antagonists(initial(dummy.id)))
			#ifdef DATA_LOGGER
			game_stats.Increment(A.check_completion() ? "traitorwin" : "traitorloss")
			#endif
			var/antag_dat = A.handle_round_end(TRUE)
			if (A.display_at_round_end && length(antag_dat))
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
/datum/game_mode/proc/equip_antag(datum/mind/antag)
	var/objective_set_path = null
	// This is temporary for the new antagonist system, to prevent creating objectives for roles that have an associated datum.
	// It should be removed when all antagonists are on the new system.
	var/do_objectives = TRUE

	if (antag.assigned_role == "Chaplain" && antag.special_role == ROLE_VAMPIRE)
		// vamp will burn in the chapel before he can react
		if (prob(50))
			antag.special_role = ROLE_TRAITOR
		else
			antag.special_role = ROLE_CHANGELING

	switch (antag.special_role)
		if (ROLE_TRAITOR)
			antag.add_antagonist(ROLE_TRAITOR)
			do_objectives = FALSE

		if (ROLE_CHANGELING)
			objective_set_path = /datum/objective_set/changeling
			antag.current.make_changeling()

		if (ROLE_WIZARD)
			objective_set_path = pick(typesof(/datum/objective_set/traitor/rp_friendly))
			antag.current.unequip_all(1)

			if (!job_start_locations["wizard"])
				boutput(antag.current, "<B><span class='alert'>A starting location for you could not be found, please report this bug!</span></B>")
			else
				antag.current.set_loc(pick(job_start_locations["wizard"]))

			equip_wizard(antag.current)

			var/randomname
			if (antag.current.gender == "female")
				randomname = pick_string_autokey("names/wizard_female.txt")
			else
				randomname = pick_string_autokey("names/wizard_male.txt")

			SPAWN(0)
				var/newname = input(antag.current,"You are a Wizard. Would you like to change your name to something else?", "Name change",randomname)
				if(newname && newname != randomname)
					phrase_log.log_phrase("name-wizard", randomname, no_duplicates=TRUE)
				if (length(ckey(newname)) == 0)
					newname = randomname

				if (newname)
					if (length(newname) >= 26) newname = copytext(newname, 1, 26)
					newname = strip_html(newname)
					antag.current.real_name = newname
					antag.current.UpdateName()

		if (ROLE_WRAITH)
			generate_wraith_objectives(antag)

		if (ROLE_VAMPIRE)
			objective_set_path = /datum/objective_set/vampire
			antag.current.make_vampire()

		if (ROLE_HUNTER)
			antag.add_antagonist(ROLE_HUNTER)
			do_objectives = FALSE

		if (ROLE_GRINCH)
			objective_set_path = /datum/objective_set/grinch
			boutput(antag.current, "<h2><font color=red><B>You are a grinch!</B></font></h2>")
			antag.current.make_grinch()

		if (ROLE_BLOB)
			objective_set_path = /datum/objective_set/blob
			SPAWN(0)
				var/newname = input(antag.current, "You are a Blob. Please choose a name for yourself, it will show in the form: <name> the Blob", "Name change") as text

				if (newname)
					phrase_log.log_phrase("name-blob", newname, no_duplicates=TRUE)
					if (length(newname) >= 26) newname = copytext(newname, 1, 26)
					newname = strip_html(newname) + " the Blob"
					antag.current.real_name = newname
					antag.current.name = newname

		if (ROLE_FLOCKMIND)
			bestow_objective(antag, /datum/objective/specialist/flock)
			antag.current.make_flockmind()
		if (ROLE_SPY_THIEF)
			objective_set_path = /datum/objective_set/spy_theft
			SPAWN(1 SECOND) //dumb delay to avoid race condition where spy assignment bugs
				equip_spy_theft(antag.current)

			if (!src.spy_market)
				src.spy_market = new /datum/game_mode/spy_theft
				sleep(5 SECONDS) //Some possible bounty items (like organs) need some time to get set up properly and be assigned names
				src.spy_market.build_bounty_list()
				src.spy_market.update_bounty_readouts()

		if (ROLE_WEREWOLF)
			objective_set_path = /datum/objective_set/werewolf
			antag.current.make_werewolf()

		if (ROLE_ARCFIEND)
			antag.add_antagonist(ROLE_ARCFIEND)
			do_objectives = FALSE

	if (do_objectives)
		if (!isnull(objective_set_path)) // Cannot create objects of type null. [wraiths use a special proc]
			new objective_set_path(antag)
		var/obj_count = 1
		for (var/datum/objective/objective in antag.objectives)
			boutput(antag.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

/datum/game_mode/proc/check_win()

/datum/game_mode/proc/send_intercept(badguy_list)
	var/intercepttext = "Cent. Com. Update Requested status information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "vampire", ROLE_CHANGELING)
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

/datum/game_mode/proc/bestow_objective(var/datum/mind/traitor,var/objective_path)
	if (!istype(traitor) || !ispath(objective_path))
		return null

	var/datum/objective/O = new objective_path(null, traitor)

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


