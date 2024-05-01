/datum/game_mode/traitor
	name = "Traitor"
	config_tag = "traitor"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_TRAITOR)
	antag_token_support = TRUE

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/const/traitors_possible = 5

#ifdef RP_MODE
	var/const/pop_divisor = 10
#else
	var/const/pop_divisor = 8
#endif


/datum/game_mode/traitor/announce()
	boutput(world, "<B>The current game mode is - Traitor!</B>")
	boutput(world, "<B>There is a syndicate traitor on the [station_or_ship()]. Do not let the traitor succeed!!</B>")

/datum/game_mode/traitor/pre_setup()

	var/num_players = src.roundstart_player_count()

	var/randomizer = rand(7)
	var/num_traitors = 1
	var/num_wraiths = 0
	var/token_wraith = 0

	if(traitor_scaling)
		num_traitors = clamp(round((num_players + randomizer) / pop_divisor), 1, traitors_possible) // adjust the randomizer as needed

	if(num_traitors >= 4 && prob(10))
		num_traitors -= 1
		num_wraiths = 1

	var/list/possible_traitors = get_possible_enemies(ROLE_TRAITOR, num_traitors)

	if (!possible_traitors.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		if (num_wraiths && !(token_wraith))
			add_token_wraith()
		else
			traitors += tplayer
			token_players.Remove(tplayer)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")
		/*num_traitors--
		num_traitors = max(num_traitors, 0)*/

	var/list/chosen_traitors = antagWeighter.choose(pool = possible_traitors, role = ROLE_TRAITOR, amount = num_traitors, recordChosen = 1)
	traitors |= chosen_traitors
	for (var/datum/mind/traitor in traitors)
		// although this is assigned by the antagonist datum, we need to do it early in gamemode setup to let the job picker catch it
		traitor.special_role = ROLE_TRAITOR
		possible_traitors.Remove(traitor)

	if(num_wraiths)
		add_wraith(num_wraiths)

	return 1

/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		if (traitor.special_role == ROLE_WRAITH) // agony.
			traitor.add_antagonist(ROLE_WRAITH, source = ANTAGONIST_SOURCE_ROUND_START)
		else
			traitor.add_antagonist(ROLE_TRAITOR, source = ANTAGONIST_SOURCE_ROUND_START)
	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/traitor/send_intercept()
	..(src.traitors)

/datum/game_mode/traitor/declare_completion()
	. = ..()

/datum/game_mode/traitor/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	boutput(killer, "<b>Your laws have been changed!</b>")
	killer.law_rack_connection?.SetLawCustom("Objective Law Module", law, 1, TRUE, TRUE)
	killer.law_rack_connection?.UpdateLaws()

/datum/game_mode/traitor/proc/get_mob_list()
	var/list/mobs = list()

	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue
		mobs += player
	return mobs

/datum/game_mode/traitor/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue

		if (player.real_name != excluded_name)
			names += player.real_name

	if(!names.len)
		return null
	return pick(names)
