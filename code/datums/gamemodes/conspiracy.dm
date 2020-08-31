/datum/game_mode/conspiracy
	name = "conspiracy"
	config_tag = "conspiracy"
	latejoin_antag_compatible = 1
	latejoin_only_if_all_antags_dead = 1 // No hunters until the conspiracy is dead, thanks

	var/maxConspirators = 6

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/conspiracy/announce()
	boutput(world, "<B>The current game mode is - Conspiracy!</B>")
	boutput(world, "<B>Trust no one.</B>")

/datum/game_mode/conspiracy/pre_setup() // Presetup does selection and marking of antags before mobs are spawned, postsetup actually gives them objectives
	var/numPlayers = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if(player.ready)
			numPlayers++

	var/numConspirators = max(2, min(round(numPlayers / 5), maxConspirators)) // Selects number of conspirators

	var/list/potentialAntags = getPotentialAntags(numConspirators)
	if (!potentialAntags.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		else
			traitors += tplayer
			token_players.Remove(tplayer)
		logTheThing("admin", tplayer.current, null, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	var/list/chosen_conspirator = antagWeighter.choose(pool = potentialAntags, role = "conspirator", amount = numConspirators, recordChosen = 1)
	traitors |= chosen_conspirator
	for (var/datum/mind/conspirator in traitors)
		conspirator.special_role = "conspirator"
		potentialAntags.Remove(conspirator)

	return 1

/datum/game_mode/conspiracy/post_setup()
	var/meetingPoint = "Your initial meet-up point is <b>[pick("the chapel", "the arcade", "the escape wing", "the bar", "the pool", "the aviary")].</b>"

	var/conspiratorList = "The conspiracy consists of: "
	for (var/datum/mind/conspirator in traitors)
		conspiratorList = conspiratorList + "<b>" + conspirator.current.name + "</b>, "

	var/pickedObjective = pick(typesof(/datum/objective/conspiracy))
	for(var/datum/mind/conspirator in traitors)
		ticker.mode.bestow_objective(conspirator, pickedObjective)

		conspirator.store_memory(meetingPoint)
		conspirator.store_memory(conspiratorList)
		for(var/datum/objective/objective in conspirator.objectives)
			boutput(conspirator.current, "<B>Objective</B>: [objective.explanation_text]")

		SHOW_CONSPIRACY_TIPS(conspirator.current)
		boutput(conspirator.current, conspiratorList)
		boutput(conspirator.current, meetingPoint)

	SPAWN_DBG (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/conspiracy/proc/getPotentialAntags(minimum_traitors=1)
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (ishellbanned(player)) continue //No treason for you
		if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
			if(player.client.preferences.be_traitor)
				candidates += player.mind

	if(candidates.len < minimum_traitors)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Only [candidates.len] players with be_traitor set to yes were ready. We need [minimum_traitors] traitors so including players who don't want to be traitors in the pool.")
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue

			if (ishellbanned(player)) continue //No treason for you
			if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind

				if ((minimum_traitors > 1) && (candidates.len >= minimum_traitors))
					break

	if(candidates.len < 1)
		return list()
	else
		return candidates

/datum/game_mode/traitor/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested staus information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "changeling")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(traitors))

	for (var/obj/machinery/communications_dish/C in by_type[/obj/machinery/communications_dish])
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
