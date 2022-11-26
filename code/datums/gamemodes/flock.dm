/datum/game_mode/flock
	name = "flock"
	config_tag = "flock"

	shuttle_available = SHUTTLE_CALL_ENABLED
	shuttle_available_threshold = 12000 // 20 minutes

	antag_token_support = TRUE // this can allow the flock to have more members than usual, but should be rare
	escape_possible = FALSE

	latejoin_antag_compatible = TRUE
	latejoin_only_if_all_antags_dead = TRUE
	latejoin_antag_roles = list(ROLE_TRAITOR, ROLE_VAMPIRE, ROLE_CHANGELING, ROLE_ARCFIEND)

	do_random_events = FALSE
	do_antag_random_spawns = FALSE

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
	var/num_flock = clamp(src.starting_players < 50 ? 2 : round(src.starting_players / 25), src.roundstart_flock_min, src.roundstart_flock_max)

	var/list/flockminds_list = num_flock > 0 ? get_possible_enemies(ROLE_FLOCKMIND, 1) : list()
	var/list/flocktraces_list = num_flock - 1 > 0 ? get_possible_enemies(ROLE_FLOCKTRACE, num_flock - 1) : list()

	token_players = antag_token_list()
	if (!islist(token_players))
		token_players = list()
	else if (length(token_players))
		shuffle_list(token_players)
		for (var/datum/mind/tplayer as anything in token_players)
			src.traitors += tplayer
			logTheThing(LOG_ADMIN, tplayer.current, "redeemed an antag token for Flock gamemode.")
			message_admins("[key_name(tplayer.current)] redeemed an antag token for Flock gamemode.")

	if (length(flockminds_list) + length(flocktraces_list) + length(token_players) < src.roundstart_flock_min)
		boutput(world, "<span class='alert'><b>ERROR: Couldn't assign any players to the Flock, aborting Flock game mode pre-setup.</b></span>")
		return FALSE

	var/datum/mind/chosen_flockmind = pick(antagWeighter.choose(length(flockminds_list) ? flockminds_list : flocktraces_list, ROLE_FLOCKMIND, 1, TRUE) + token_players)
	src.traitors |= chosen_flockmind
	chosen_flockmind.special_role = ROLE_FLOCKMIND
	chosen_flockmind.assigned_role = "MODE"
	if (chosen_flockmind in token_players)
		token_players -= chosen_flockmind
	flocktraces_list -= chosen_flockmind

	var/list/chosen_flocktraces = ((num_flock - 1 - length(token_players) > 0) ? antagWeighter.choose(flocktraces_list, ROLE_FLOCKTRACE, \
									num_flock - 1 - length(token_players), TRUE) : list()) + token_players
	for (var/datum/mind/flock as anything in chosen_flocktraces)
		src.traitors |= flock
		flock.special_role = ROLE_FLOCKTRACE
		flock.assigned_role = "MODE"

	src.start_flockmind = chosen_flockmind

	return TRUE

/datum/game_mode/flock/post_setup()
	..()
	bestow_objective(src.start_flockmind, /datum/objective/specialist/flock)
	var/mob/living/intangible/flock/flockmind/flockmind = src.start_flockmind.current
	flockmind.flock.player_mod = max(0, round(src.starting_players / 25) - 2)
	src.start_flock = flockmind.flock

	var/turf/T = get_turf(flockmind)
	var/list/turf/spawn_area = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	for (var/datum/mind/flock as anything in src.traitors)
		if (flock.special_role == ROLE_FLOCKTRACE)
			T = pick(spawn_area)
			flock.current.make_flocktrace(T, flockmind.flock, TRUE)
			if (length(traitors <= 10))
				spawn_area -= T

	SPAWN(rand(1, 3) MINUTES)
		src.send_intercept()

/datum/game_mode/flock/check_finished()
	if (..())
		return TRUE
	if (no_automatic_ending)
		return FALSE
	if (src.start_flock.relay_finished)
		return TRUE
	return FALSE

/datum/game_mode/flock/victory_msg()
	if (src.start_flock.relay_finished)
		return "<b style='font-size:20px'>Flock victory!</b><br>The Flock successfully transmitted the Signal, leaving irreparable damage to the station."
	return "<b style='font-size:20px'>Station victory!</b><br>The crew succeeded in preventing the Flock conversion of the station."

/datum/game_mode/flock/declare_completion()
	boutput(world, src.victory_msg())
	..()

/datum/game_mode/flock/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested status information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "changeling")
	for (var/i = 1 to pick(2, 3))
		possible_modes -= pick(possible_modes)
	possible_modes.Insert(rand(length(possible_modes)), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/mode in possible_modes)
		intercepttext += i_text.build(mode, pick(ticker.minds))

	for_by_tcl(C, /obj/machinery/communications_dish)
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")

/datum/game_mode/flock/proc/process_flock_death()
	src.escape_possible = TRUE
	src.do_random_events = TRUE
	src.do_antag_random_spawns = TRUE

	src.shuttle_available_threshold = 0
