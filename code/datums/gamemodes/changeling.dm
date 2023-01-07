/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_CHANGELING)
	antag_token_support = TRUE

	var/const/changelings_possible = 4

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

#ifdef RP_MODE
	var/const/pop_divisor = 20
#else
	var/const/pop_divisor = 15
#endif

/datum/game_mode/changeling/announce()
	boutput(world, "<B>The current game mode is - Changeling!</B>")
	boutput(world, "<B>There is a <span class='alert'>CHANGELING</span> on the station. Be on your guard! Trust no one!</B>")

/datum/game_mode/changeling/pre_setup()
	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if(player.ready)
			num_players++

	var/i = rand(5)
	var/num_changelings = clamp(round((num_players + i) / pop_divisor), 1, changelings_possible)

	var/list/possible_changelings = get_possible_enemies(ROLE_CHANGELING, num_changelings)

	if (!possible_changelings.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		src.traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeems an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeems an antag token.")
		//num_changelings = max(0, num_changelings - 1)

	var/list/chosen_changelings = antagWeighter.choose(pool = possible_changelings, role = ROLE_CHANGELING, amount = num_changelings, recordChosen = 1)
	traitors |= chosen_changelings
	for (var/datum/mind/changeling in traitors)
		changeling.special_role = ROLE_CHANGELING
		possible_changelings.Remove(changeling)

	return 1

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in src.traitors)
		if(istype(changeling))
			changeling.current.make_changeling()
			bestow_objective(changeling,/datum/objective/specialist/absorb)
			bestow_objective(changeling,/datum/objective/escape)

			//HRRFM horror form stuff goes here
			boutput(changeling.current, "<B><span class='alert'>You feel... HUNGRY!</span></B><br>")

			// Moved antag help pop-up to changeling.dm (Convair880).

			var/obj_count = 1
			for(var/datum/objective/objective in changeling.objectives)
				boutput(changeling.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
				obj_count++

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/changeling/send_intercept()
	..(src.traitors)
/datum/game_mode/changeling/declare_completion()
	..()

/datum/game_mode/changeling/proc/get_mob_list()
	var/list/mobs = list()

	for(var/client/C)
		var/mob/living/carbon/player = C.mob
		if (!istype(player)) continue
		mobs += player

	return mobs

/datum/game_mode/changeling/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		var/mob/living/carbon/player = C.mob
		if (!istype(player)) continue

		if ((player.real_name != excluded_name))
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)
