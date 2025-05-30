/datum/game_mode/salvager
	name = "Salvagers"
	config_tag = "salvager"

	shuttle_available = SHUTTLE_AVAILABLE_DELAY
	shuttle_available_threshold = 20 MINUTES
	antag_token_support = TRUE

	//NOTE: if you need to track something, put it here
	var/list/datum/mind/salvager_minds = list()
	var/list/datum/mind/distractions = list()
	var/const/minimum_salvagers = 3
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
#ifdef RP_MODE
	var/const/pop_divisor = 6
	var/const/antags_possible = 6
#else
	var/const/pop_divisor = 6
	var/const/antags_possible = 8 // buffed for distraction
#endif

/datum/game_mode/salvager/announce()
	boutput(world, "<B>The current game mode is - Salvagers!</B>")

/datum/game_mode/salvager/pre_setup()
	. = ..()
	var/list/possible_salvagers = list()
	#ifndef RP_MODE
	var/list/possible_traitors = list()
	var/list/possible_spy_thieves = list()
	var/distraction_num = rand(1,2)
	#endif

	var/num_players = src.roundstart_player_count()

	var/randomizer = rand(pop_divisor+1)
	var/target_antag_count = clamp( round((num_players + randomizer )/ pop_divisor ), 2, antags_possible)

	possible_salvagers = get_possible_enemies(ROLE_SALVAGER, target_antag_count)
	#ifndef RP_MODE
	if(distraction_num < 2) // Add more if you have any in mind
		possible_traitors = get_possible_enemies(ROLE_TRAITOR, distraction_num)
	else
		possible_spy_thieves = get_possible_enemies(ROLE_SPY_THIEF, distraction_num)
	#endif
	if (!length(possible_salvagers))
		//boutput(world, SPAN_ALERT("<b>ERROR: couldn't assign any players as Salvagers, aborting salvager round pre-setup.</b>"))
		return 0
	if( ( master_mode != config_tag )   \
	 && ( (length(possible_salvagers) < minimum_salvagers) || (target_antag_count < minimum_salvagers) ) )
		return 0

	// now that we've done everything that could cause the round to fail to start (in this proc, at least), we can deal with antag tokens
	token_players = antag_token_list()
	for (var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		salvager_minds += tplayer
		token_players.Remove(tplayer)
		target_antag_count = max(target_antag_count-1, 0)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	var/list/chosen_antags = antagWeighter.choose(pool = possible_salvagers, role = ROLE_SALVAGER, amount = target_antag_count, recordChosen = 1)
	salvager_minds |= chosen_antags
	for (var/datum/mind/salvager in salvager_minds)
		salvager.assigned_role = "MODE" //So they aren't chosen for other jobs.
		salvager.special_role = ROLE_SALVAGER
		possible_salvagers.Remove(salvager)

	#ifndef RP_MODE
	if (distraction_num >= 2)
		var/list/chosen_spy_thieves = antagWeighter.choose(pool = possible_spy_thieves, role = ROLE_SPY_THIEF, amount = distraction_num, recordChosen = 1)
		for (var/datum/mind/spy in chosen_spy_thieves)
			distractions += spy
			spy.special_role = ROLE_SPY_THIEF
			possible_spy_thieves.Remove(spy)
	else
		var/list/chosen_traitors = antagWeighter.choose(pool = possible_traitors, role = ROLE_TRAITOR, amount = distraction_num, recordChosen = 1)
		for (var/datum/mind/traitor in chosen_traitors)
			distractions += traitor
			traitor.special_role = ROLE_TRAITOR
			possible_traitors.Remove(traitor)
	#endif

	return 1

/datum/game_mode/salvager/post_setup()
	..()
	for (var/datum/mind/salvager in salvager_minds)
		equip_antag(salvager)
	#ifndef RP_MODE
	for (var/datum/mind/other in distractions)
		equip_antag(other)
	#endif
	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()
