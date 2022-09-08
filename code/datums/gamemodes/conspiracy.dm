/datum/game_mode/conspiracy
	name = "conspiracy"
	config_tag = "conspiracy"
	latejoin_antag_compatible = 1
	latejoin_only_if_all_antags_dead = 1 // No hunters until the conspiracy is dead, thanks

	var/maxConspirators = 6
	var/agent_radiofreq = 1401
	/// How many other antags to mix in with the conspiracy
	var/num_other_antags = 1
	var/other_antag_roles = list(ROLE_TRAITOR = 1, ROLE_CHANGELING = 1, ROLE_VAMPIRE = 1, ROLE_ARCFIEND = 1)
	var/list/datum/mind/other_antags

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

	var/numConspirators = clamp(round(numPlayers / 5), 2, maxConspirators) // Selects number of conspirators

	var/list/potentialAntags = get_possible_enemies(ROLE_CONSPIRATOR, numConspirators + num_other_antags)
	if (!potentialAntags.len)
		return 0

	other_antags = new()

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		if (length(other_antags) < num_other_antags)
			other_antags += tplayer
		else
			traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing("admin", tplayer.current, null, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	var/antag_role = pick(other_antag_roles)

	var/list/chosen_conspirator = antagWeighter.choose(pool = potentialAntags, role = ROLE_CONSPIRATOR, amount = numConspirators, recordChosen = 1)
	var/list/chosen_other_antags = antagWeighter.choose(pool = potentialAntags - chosen_conspirator, role = antag_role, amount = num_other_antags - length(other_antags), recordChosen = 1)
	traitors |= chosen_conspirator
	other_antags |= chosen_other_antags
	for (var/datum/mind/conspirator in traitors)
		conspirator.special_role = ROLE_CONSPIRATOR
		potentialAntags.Remove(conspirator)

	agent_radiofreq = random_radio_frequency()
	for (var/datum/mind/antag in other_antags)
		antag.special_role = antag_role

	return 1

/datum/game_mode/conspiracy/post_setup()
	var/meetingPoint = "Your initial meet-up point is <b>[pick("the chapel", "the bar", "disposals", "the arcade", "the escape wing", "crew quarters", "the pool", "the aviary")].</b>"

	var/conspiratorList = "The conspiracy consists of: "
	for (var/datum/mind/conspirator in traitors)
		var/conspirator_name
		if (conspirator.assigned_role == "Clown")
			conspirator_name = "a Clown"
		else
			conspirator_name = conspirator.current.real_name
		conspiratorList += "<b>[conspirator_name]</b>, "

	var/pickedObjective = pick(typesof(/datum/objective/conspiracy))
	for(var/datum/mind/conspirator in traitors)
		ticker.mode.bestow_objective(conspirator, pickedObjective)

		conspirator.store_memory(meetingPoint)
		conspirator.store_memory(conspiratorList)
		for(var/datum/objective/objective in conspirator.objectives)
			boutput(conspirator.current, "<B>Objective</B>: [objective.explanation_text]")

		equip_conspirator(conspirator.current)

		boutput(conspirator.current, conspiratorList)
		boutput(conspirator.current, meetingPoint)

	for (var/datum/mind/traitor in other_antags)
		equip_antag(traitor)

	traitors |= other_antags

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/conspiracy/proc/random_radio_frequency()
	var/list/blacklisted = list(0, 1451, 1457)
	blacklisted.Add(R_FREQ_BLACKLIST)

	do
		. = rand(1352, 1439)
	while (blacklisted.Find(.))

/datum/game_mode/conspiracy/send_intercept()
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

	for_by_tcl(C, /obj/machinery/communications_dish)
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
