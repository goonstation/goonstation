#define BLOB_VICTORY_TILE_COUNT 500
/datum/game_mode/blob
	name = "Blob"
	config_tag = "blob"
	shuttle_available = SHUTTLE_AVAILABLE_DELAY
	shuttle_available_threshold = 20 MINUTES

	antag_token_support = TRUE
	var/const/blobs_minimum = 1
	var/const/blobs_possible = 4
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/finish_counter = 0
	escape_possible = 0

/datum/game_mode/blob/announce()
	boutput(world, "<b>The current game mode is - <font color='green'>Blob</font>!</b>")
	boutput(world, "<b>A dangerous alien organism is rapidly spreading throughout the station!</b>")
	boutput(world, "<b>You must kill it all while minimizing the damage to the station.</b>")

/datum/game_mode/blob/pre_setup()
	..()
	var/num_players = src.roundstart_player_count()

	var/i = rand(10, 15)
	var/num_blobs = clamp(round((num_players + i) / 20), blobs_minimum, blobs_possible)

	var/list/possible_blobs = get_possible_enemies(ROLE_BLOB, num_blobs)

	if (!possible_blobs || !islist(possible_blobs) || !possible_blobs.len || length(possible_blobs) < blobs_minimum)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeems an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeems an antag token.")
		//num_blobs = max(0, num_blobs - 1)

	var/list/chosen_blobs = antagWeighter.choose(pool = possible_blobs, role = ROLE_BLOB, amount = num_blobs, recordChosen = 1)
	traitors |= chosen_blobs
	for (var/datum/mind/blob in traitors)
		blob.special_role = ROLE_BLOB
		blob.assigned_role = "MODE"
		possible_blobs.Remove(blob)

	return 1

/datum/game_mode/blob/post_setup()
	..()
	emergency_shuttle.disabled = SHUTTLE_CALL_ENABLED
	for (var/datum/mind/blob in traitors)
		blob.add_antagonist(ROLE_BLOB, source = ANTAGONIST_SOURCE_ROUND_START)

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/blob/send_intercept()
	..(ticker.minds)
/datum/game_mode/blob/check_finished()
	if (..())
		return 1
	if (no_automatic_ending)
		return 0
	var/blobcount = 0
	var/tilecount = 0
	for (var/datum/mind/M in traitors)
		if (!M)
			continue
		if (M.special_role != ROLE_BLOB)
			continue
		if (isblob(M.current))
			var/mob/living/intangible/blob_overmind/O = M.current
			blobcount += 1
			tilecount += O.blobs.len
	for (var/datum/mind/M in Agimmicks)
		if (!M)
			continue
		if (M.special_role != ROLE_BLOB)
			continue
		if (isblob(M.current))
			var/mob/living/intangible/blob_overmind/O = M.current
			blobcount += 1
			tilecount += O.blobs.len
	if(tilecount < BLOB_VICTORY_TILE_COUNT*blobcount)
		return 0
	return 1

/datum/game_mode/blob/victory_msg()
	return "<span style='font-size:20px'><b>[victory_headline()]</b><br>[victory_body()]</span>"

/datum/game_mode/blob/victory_headline()
	if(src.finish_counter)
		return "Blob victory!"
	return "Crew victory!"

/datum/game_mode/blob/victory_body()
	if (src.finish_counter)
		return "The crew has failed to stop the overmind! The station is lost to the blob!"
	else
		return "All blobs have been exterminated!"

/datum/game_mode/blob/declare_completion()
	var/list/blobs = list()
	for (var/datum/mind/M in traitors)
		if (!M)
			continue
		if (isblob(M.current))
			blobs += M.current
	for (var/datum/mind/M in Agimmicks)
		if (!M)
			continue
		if (isblob(M.current))
			blobs += M.current
	src.finish_counter = length(blobs)
	if (src.finish_counter)
		var/mob/living/intangible/blob_overmind/blob = locate() in blobs
		blob.go_critical()
	boutput(world, src.victory_msg())
	..()

#undef BLOB_VICTORY_TILE_COUNT
