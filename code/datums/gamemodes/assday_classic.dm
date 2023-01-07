/*
*
*       Warc's first babbo gamemode, copied wholesale from Traitor. h
*
*/
/datum/game_mode/assday
	name = "Everyone-Is-A-Traitor Mode"
	config_tag = "everyone-is-a-traitor"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_TRAITOR, ROLE_CHANGELING, ROLE_WRAITH)
	antag_token_support = TRUE

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/const/traitors_possible = 169

/datum/game_mode/assday/announce()
	boutput(world, "<B>The current game mode is - Everyone is a traitor!</B>")
	boutput(world, "<B>The entire crew of [station_or_ship()] has defected. Beware of dog.</B>")


/datum/game_mode/assday/pre_setup()

	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue
		if (player.ready)
			num_players++

	var/num_traitors = 1
	var/num_wraiths = 1
	var/token_wraith = 0

	if(traitor_scaling)
		num_traitors = max(1, num_players) // How many? all of em.

	if(prob(10))
		num_traitors -=1
		num_wraiths += 1


	var/list/possible_traitors = get_possible_enemies(ROLE_TRAITOR, num_traitors)

	if (!possible_traitors.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		if (num_wraiths && !(token_wraith))
			token_wraith = 1 // only allow 1 wraith to spawn
			var/datum/mind/twraith = pick(token_players) //Randomly pick from the token list so the first person to ready up doesn't always get it.
			traitors += twraith
			token_players.Remove(twraith)
			twraith.special_role = ROLE_WRAITH
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
		traitor.special_role = ROLE_TRAITOR
		possible_traitors.Remove(traitor)

	if(num_wraiths)
		var/list/possible_wraiths = get_possible_enemies(ROLE_WRAITH, num_wraiths)
		var/list/chosen_wraiths = antagWeighter.choose(pool = possible_wraiths, role = ROLE_WRAITH, amount = num_wraiths, recordChosen = 1)
		for (var/datum/mind/wraith in chosen_wraiths)
			traitors += wraith
			wraith.special_role = ROLE_WRAITH
			possible_wraiths.Remove(wraith)

	return 1

/datum/game_mode/assday/post_setup()
	for(var/datum/mind/traitor in traitors)
		switch(traitor.special_role)
			if(ROLE_TRAITOR)
				traitor.current.show_antag_popup("traitorhard")

			if (ROLE_WRAITH)
				generate_wraith_objectives(traitor)

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/assday/send_intercept()
	..(src.traitors)
/datum/game_mode/assday/declare_completion()
	return // don't call parent because we don't want to spam objectives of 80 traitors, thanks

/datum/game_mode/assday/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	boutput(killer, "<b>Your laws have been changed!</b>")
	killer.law_rack_connection?.SetLawCustom("Assday Law Module",law,1,true,true)
	killer.law_rack_connection?.UpdateLaws()

/datum/game_mode/assday/proc/get_mob_list()
	var/list/mobs = list()

	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue
		mobs += player
	return mobs

/datum/game_mode/assday/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue

		if (player.real_name != excluded_name)
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)
