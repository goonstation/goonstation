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
	var/list/datum/mind/former_antagonists = list() // For mindslaves and rogue cyborgs we'd want to show in the game over stats (Convair880).

	var/datum/game_mode/spy_theft/spy_market = 0	//In case any spies are spawned into a round that is NOT spy_theft, we need a place to hold their spy market.

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

			if (traitor.current)
				traitor_name = "[traitor.current.real_name] (played by [traitor.key])"
			else
				traitor_name = "[traitor.key] (character destroyed)"

			if (traitor.special_role == ROLE_MINDSLAVE)
				stuff_to_output += "<B>[traitor_name]</B> was a mindslave!"
				continue // Objectives are irrelevant for mindslaves and thralls.
			else if (traitor.special_role == ROLE_VAMPTHRALL)
				stuff_to_output += "<B>[traitor_name]</B> was a vampire's thrall!"
				continue // Ditto.
			else
				if (traitor.late_special_role)
					stuff_to_output += "<B>[traitor_name]</B> was a late-joining [traitor.special_role]!"
				else if (traitor.random_event_special_role)
					stuff_to_output += "<B>[traitor_name]</B> was a random event [traitor.special_role]!"
				else
					stuff_to_output += "<B>[traitor_name]</B> was a [traitor.special_role]!"

				if (traitor.special_role == ROLE_CHANGELING && traitor.current)
					var/dna_absorbed = 0
					var/datum/abilityHolder/changeling/C = traitor.current.get_ability_holder(/datum/abilityHolder/changeling)
					if (C && istype(C))
						dna_absorbed = max(0, C.absorbtions)
					else
						dna_absorbed = "N/A (body destroyed)"
					stuff_to_output += "<B>Absorbed DNA:</b> [dna_absorbed]"

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

				if (traitor.special_role == ROLE_TRAITOR)
					var/purchases = length(traitor.purchased_traitor_items)
					var/surplus = length(traitor.traitor_crate_items)
					stuff_to_output += "They purchased [purchases <= 0 ? "nothing" : "[purchases] item[s_es(purchases)]"] with their [syndicate_currency]![purchases <= 0 ? " [pick("Wow", "Dang", "Gosh", "Good work", "Good job")]!" : null]"
					if (purchases)
						var/item_detail = "They purchased: "
						for (var/i in traitor.purchased_traitor_items)
							item_detail += "[bicon(i:item)] [i:name], "
						item_detail = copytext(item_detail, 1, -2)
						if (surplus)
							item_detail += "<br>Their surplus crate contained: "
							for (var/i in traitor.traitor_crate_items)
								item_detail += "[bicon(i:item)] [i:name], "
							item_detail = copytext(item_detail, 1, -2)
						stuff_to_output += item_detail

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

				for (var/datum/objective/objective in traitor.objectives)
	#ifdef CREW_OBJECTIVES
					if (istype(objective, /datum/objective/crew)) continue
	#endif
					if (istype(objective, /datum/objective/miscreant)) continue

					obj_count++
					if (objective.check_completion())
						stuff_to_output += "Objective #[obj_count]: [objective.explanation_text] <span class='success'><B>Success</B></span>"
						logTheThing("diary",traitor,null,"completed objective: [objective.explanation_text]")
						if (!isnull(objective.medal_name) && !isnull(traitor.current))
							traitor.current.unlock_medal(objective.medal_name, objective.medal_announce)
					else
						stuff_to_output += "Objective #[obj_count]: [objective.explanation_text] <span class='alert'>Failed</span>"
						logTheThing("diary",traitor,null,"failed objective: [objective.explanation_text]. Womp womp.")
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
			logTheThing("debug", null, null, "Kyle|antag-runtime: [e.file]:[e.line] - [e.name] - [e.desc]")


	// Their antag status is revoked on death/implant removal/expiration, but we still want them to show up in the game over stats (Convair880).
	for (var/datum/mind/traitor in former_antagonists)
		try
			var/traitor_name

			if (traitor.current)
				traitor_name = "[traitor.current.real_name] (played by [traitor.key])"
			else
				traitor_name = "[traitor.key] (character destroyed)"

			if (traitor.former_antagonist_roles.len)
				for (var/string in traitor.former_antagonist_roles)
					if (string == ROLE_MINDSLAVE)
						stuff_to_output += "<B>[traitor_name] was a mindslave!</B>"
					else if (string == ROLE_VAMPTHRALL)
						stuff_to_output += "<B>[traitor_name] was a vampire's thrall!</B>"
					else
						stuff_to_output += "<B>[traitor_name] was a [string]!</B>"
		catch(var/exception/e)
			logTheThing("debug", null, null, "kyle|former-antag-runtime: [e.file]:[e.line] - [e.name] - [e.desc]")

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

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue
		if (ishellbanned(player)) continue //No treason for you

		if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !(player.mind in candidates))
			if (player.client.preferences.vars[get_preference_for_role(type)])
				candidates += player.mind

	if(length(candidates) < number)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Only [candidates.len] players with be_[type] set to yes were ready. We need [number] so including players who don't want to be [type]s in the pool.")

		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue
			if (ishellbanned(player)) continue //No treason for you

			if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !(player.mind in candidates))
				candidates += player.mind
				if ((number > 1) && (length(candidates) >= number))
					break

	if(length(candidates) < 1)
		return list()
	else
		return candidates

/datum/game_mode/proc/check_win()

/datum/game_mode/proc/send_intercept()

////////////////////////////
// Objective related code //
////////////////////////////

//what do we do when a mob dies
/datum/game_mode/proc/on_human_death(var/mob/M)

/datum/game_mode/proc/bestow_objective(var/datum/mind/traitor,var/objective_path)
	if (!istype(traitor) || !ispath(objective_path))
		return null

	var/datum/objective/O = new objective_path
	O.owner = traitor
	O.set_up()
	traitor.objectives += O

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

	var/datum/objective/O = new objective_path
	O.owner = traitor
	O.set_up()
	traitor.objectives += O

	return O
