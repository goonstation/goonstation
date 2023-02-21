/datum/game_mode/salvager
	name = "Salvagers"
	config_tag = "salvager"

	shuttle_available = SHUTTLE_AVAILABLE_DELAY
	shuttle_available_threshold = 20 MINUTES

	//NOTE: if you need to track something, put it here
	var/list/datum/mind/salvager_minds = list()
	var/const/antags_possible = 6

/datum/game_mode/salvager/announce()
	boutput(world, "<B>The current game mode is - Salvagers!</B>")

/datum/game_mode/salvager/pre_setup()
	var/list/possible_salvagers = list()

	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (player.ready)
			num_players++

	var/target_antag_count = clamp( round(num_players / 6 ), 2, antags_possible)

	possible_salvagers = get_possible_enemies(ROLE_SALVAGER, target_antag_count)
	if (!length(possible_salvagers))
		boutput(world, "<span class='alert'><b>ERROR: couldn't assign any players as Salvagers, aborting salvager round pre-setup.</b></span>")
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
	return TRUE

/datum/game_mode/salvager/post_setup()
	for (var/datum/mind/salvager in salvager_minds)
		equip_antag(salvager)
