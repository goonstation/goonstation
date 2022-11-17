/datum/game_mode/flock
	name = "flock"
	config_tag = "flock"

	shuttle_available = SHUTTLE_CALL_ENABLED
	shuttle_available_threshold = 12000 // 20 min

	antag_token_support = TRUE
	escape_possible = FALSE

	latejoin_antag_compatible = TRUE
	latejoin_only_if_all_antags_dead = TRUE
	latejoin_antag_roles = list(ROLE_TRAITOR, ROLE_VAMPIRE, ROLE_CHANGELING, ROLE_ARCFIEND)

	var/starting_players = 0
	var/datum/mind/start_flockmind = null
	var/datum/flock/start_flock = null
	// counts flockmind + up to 3 traces
	var/const/roundstart_flock_min = 1
	var/const/roundstart_flock_max = 4

/datum/game_mode/flock/announce()
	boutput(world, "<B>The current game mode is - Flock!</B>")
	boutput(world, "<B>A Flockmind has been stranded at the station and seeks to use its resources to transmit its Flock!</B>")
	boutput(world, "It's unclear if the Flock is hostile. However, it will do everything it can to transmit the Signal.</B>")

/datum/game_mode/flock/pre_setup()
	for (var/client/C as anything in clients)
		var/mob/new_player/player = C.mob
		if (!istype(player))
			continue
		if (player.ready)
			src.starting_players++

	// 1 flockmind up to 50 players, then at 50 players get 1 flocktrace, another for every 25 players more
	var/num_flock = clamp(src.starting_players < 50 ? 1 : round(src.starting_players / 25), roundstart_flock_min, roundstart_flock_max)

	var/list/possible_flock = get_possible_enemies(ROLE_FLOCKTRACE, num_flock)

	if (!length(possible_flock) || length(possible_flock) < roundstart_flock_min)
		boutput(world, "<span class='alert'><b>ERROR: Couldn't assign any players to the Flock, aborting Flock round pre-setup.</b></span>")
		return FALSE

	token_players = antag_token_list()
	for (var/datum/mind/tplayer as anything in token_players)
		if (!length(token_players))
			break
		traitors += tplayer
		token_players -= tplayer
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeemed an antag token for Flock gamemode.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token for Flock gamemode.")
		num_flock--
		if (num_flock == 0)
			break

	var/list/chosen_flock = antagWeighter.choose(possible_flock, ROLE_FLOCKTRACE, num_flock, TRUE)
	traitors |= chosen_flock
	for (var/datum/mind/flock in traitors)
		flock.special_role = ROLE_FLOCKTRACE
		flock.assigned_role = "MODE"
		possible_flock.Remove(flock)

	var/list/datum/mind/possible_flockminds = list()
	for (var/datum/mind/mind as anything in traitors)
		if (mind.current.client.preferences.be_flockmind)
			possible_flockminds += mind
	if (length(possible_flockminds))
		src.start_flockmind = pick(possible_flockminds)
	else
		src.start_flockmind = pick(traitors)

	return TRUE

/datum/game_mode/flock/post_setup()
	..()
	bestow_objective(start_flockmind, /datum/objective/specialist/flock)
	var/mob/living/intangible/flock/flockmind/flockmind = start_flockmind.current.make_flockmind()
	flockmind.flock.player_mod = max(0, round(src.starting_players / 25) - 2)
	start_flock = flockmind.flock

	for (var/datum/mind/flock as anything in traitors)
		if (flock.special_role != ROLE_FLOCKMIND)
			flock.current.make_flocktrace(get_turf(flockmind), flockmind.flock, TRUE)

	SPAWN(rand(1 MINUTE, 3 MINUTES))
		src.send_intercept()

/datum/game_mode/flock/check_finished()
	if (..())
		return TRUE
	if (no_automatic_ending)
		return FALSE
	if (start_flock.relay_finished)
		return TRUE
	return FALSE

/datum/game_mode/flock/victory_msg()
	if (start_flock.relay_finished)
	else
		return "<b style='font-size:20px'>Station victory!</b><br>The crew succeeded in preventing the Flock conversion of the station."

/datum/game_mode/flock/declare_completion()
	boutput(world, victory_msg())
	. = ..()

/datum/game_mode/flock/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested status information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "changeling")
	for (var/i = 0 to pick(2, 3))
		possible_modes -= pick(possible_modes)
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(ticker.minds))

	for_by_tcl(C, /obj/machinery/communications_dish)
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
